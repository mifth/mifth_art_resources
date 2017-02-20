// Vertex shader
// PicMat Material
// implemented by akira for 3D-Coat
// inspired by an article from nvidia developer site:
// http://developer.nvidia.com/object/nvision08-bwotf.html  slide no.109 - 111
uniform mat4 g_WorldViewProjectionMatrix;
uniform mat4 g_WorldViewMatrix;
uniform mat4 ShadowTM;
uniform vec3 g_ViewerPos;

in vec3 Pos;
in vec3 Normal;
in vec4 Color;
in vec4 Color2;

out vec3 w_Normal;
out vec3 v_Normal;
out vec3 v_Pos;
out vec4 v_Color;
out vec4 v_Color2;
out vec3 VDir;
#ifdef SHADOWS
out vec3 SPos;
#endif
out vec3 v_MPos;

void main() {
	vec4 P = vec4(Pos, 1.0);
	vec4 p2=P * g_WorldViewProjectionMatrix;
	gl_Position = p2;
	w_Normal = normalize(Normal);
	v_Normal=(vec4(Normal, 0.0) * g_WorldViewMatrix).xyz;
	v_Pos.xyz=Pos.xyz;
	vec4 v4=P * ShadowTM;
	v_Color=Color;
	v_Color2=Color2;
	v_Color.w = saturate(Color.w*2.0 - 1.0);
	v_Color.xyz *= v_Color.w;	
	v_MPos=Pos;
	v_Color2.y = length(Normal);
	v_Color2.w = 1.0/p2.w;
#ifdef SHADOWS
	SPos = v4.xyz;
	SPos.y=1.0-SPos.y;
#endif
	VDir = normalize( (Pos.xyz  - g_ViewerPos) );
}

// Fragment shader

in vec3 w_Normal;
in vec3 v_Normal;
in vec3 v_Pos;
in vec4 v_Color;
in vec4 v_Color2;
in vec3 VDir;
#ifdef SHADOWS
in vec3 SPos;
#endif
in vec3 v_MPos;

uniform sampler2D CustomSampler1;//corresponds to Shaders/CustomSampler1.dds;
uniform sampler2D CustomSampler3;
uniform sampler2D ShadowSampler;

uniform float LDiffuse;
uniform float LAmbient;
uniform vec3 LDir;
uniform vec4 CurrColor;
uniform float ShadowMin;

uniform vec4 ColorModulation;
uniform float Opacity;
uniform vec4  LightColor;
uniform vec3  LDirNormalized;
uniform vec3 g_LocalViewDir;

uniform float GridConst;

uniform vec3 CavityCo;
uniform vec3 LocalRightDir;
uniform vec3 LocalUpDir;
uniform float cavityIntensity;
uniform float bulgeIntensity;
uniform vec4 cavityColor;
uniform vec4 bulgeColor;
uniform vec3 ExtraGamma;
uniform mat4 g_WorldViewMatrix;
uniform float PaintOpacity;
uniform float Inverse;
//@insert:contrast
 
out vec4 FragColor;
void main() {
        if(mod(gl_FragCoord.x+gl_FragCoord.y,2.0)==GridConst)discard;
	vec3 N=normalize(v_Normal);
	float dd=clamp(v_Color2.y-1.0,0.0,1.0) * 0.45;

	vec3 wN = normalize(w_Normal);
	vec3 viewN = normalize(N);
#ifdef FLAT_SHADING
	wN = normalize(cross(dFdy(v_MPos),dFdx(v_MPos)))*Inverse;
	viewN = normalize((vec4(wN, 0.0)*g_WorldViewMatrix).xyz);
#endif //FLAT_SHADING
	
#ifdef SHADOWS
	float darkside = ShadowMin+clamp(dot(wN, -LDir) * 1.5, 0.0, 1.0);
	vec4 m=texture(ShadowSampler,SPos.xy);
	vec3 d=vec3(1.0,1.0/255.0,1.0/255.0/255.0);
	float mpl=clamp(1.1-(SPos.z-dot(m.xyz,d))*1200.0,0.25,1.0);
	mpl = min(mpl,darkside);
	mpl = min(1.0, mpl + LAmbient)*1.2;
#else
	float mpl=1.0;
#endif               	
	vec2 PicMatUV = vec2(viewN.x * 0.5 +0.5, viewN.y * 0.5 - 0.5);
	PicMatUV = 1.0 - PicMatUV;
	vec4 DiffuseColor = texture(CustomSampler1, PicMatUV);
	DiffuseColor.xyz *= getmodf(DiffuseColor.xyz);
	vec4 colmod = ColorModulation;

#ifdef USE_CAVITY
	vec3 ViewDir = normalize(VDir);
	vec3 dxx=dFdx(w_Normal);
	vec3 dyy=dFdy(w_Normal);
	float  ca0 = (CavityCo.x*v_Color2.w+CavityCo.y)*(dot(dxx,LocalRightDir)+dot(dyy,LocalUpDir));

	float cavity = saturate(ca0*cavityIntensity);
	colmod.xyz = mix(colmod.xyz,cavityColor.xyz,vec3(cavity));

	cavity = saturate(-ca0*bulgeIntensity);
	colmod.xyz = mix(colmod.xyz,bulgeColor.xyz,vec3(cavity));
#endif //USE_CAVITY
	
	vec4 C = DiffuseColor * (LDiffuse * mpl) * colmod * 2.0;
	float Diff = (C.x+C.y+C.z)/3.0;
	float popc = v_Color.w*PaintOpacity;
	C.xyz = C.xyz*(1.0-popc) + Diff*v_Color.xyz*PaintOpacity;

	vec4 c4=texture(CustomSampler3,vec2(dd*2.22,0))*(C.x+C.y+C.z+3.0)/6.0;
	C=lerp(C,c4,dd);
	C.w = Opacity;

	vec3  refl2 = g_LocalViewDir-2.0*wN*dot(g_LocalViewDir,wN);
	float S2 = max(0.0,dot(refl2,LDirNormalized));
	float fr2 = pow(S2,1.0+v_Color2.x*v_Color2.x*64.0)*v_Color2.x;
	C.xyz+=vec3(fr2,fr2,fr2);

	FragColor = C*LightColor;
}