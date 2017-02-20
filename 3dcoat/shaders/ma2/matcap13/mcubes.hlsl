// Vertex shader
// PicMat Material
// implemented by akira for 3D-Coat 
// inspired by an article from nvidia developer site:
// http://developer.nvidia.com/object/nvision08-bwotf.html slide no.109 - 111
float4x4 g_WorldViewProjectionMatrix;
float4x4 g_WorldViewMatrix;
float4x4 ShadowTM;
float3 g_ViewerPos;
float4 Sphere;

struct VS_INPUT {
	float3 Pos       : POSITION;
	float3 Normal    : TEXCOORD0;
	float4 Color     : TEXCOORD1;
	float4 Color2	 : TEXCOORD2;
};

struct VS_OUTPUT {
	float4 Pos  : POSITION;
	float3 vN   : TEXCOORD0;
	float3 N    : TEXCOORD1;
	float3 VDir : TEXCOORD2;
	float4 Color: TEXCOORD3;
#ifdef SHADOWS
	float3 SPos : TEXCOORD4;
#endif
	float4 C2   : TEXCOORD5;
	float3 MPos : TEXCOORD6;
	
};

VS_OUTPUT main(const VS_INPUT In) {
	VS_OUTPUT Out;
	float4 P = float4(In.Pos, 1.0);
	Out.Pos = mul(P, g_WorldViewProjectionMatrix);
#ifdef SHADOWS
	Out.SPos = mul(P, ShadowTM);
	Out.SPos.xy+=float2(1.0/4096.0f,1.0/4096.0f);
#endif
	Out.MPos  = In.Pos;
	Out.Color = In.Color;
	Out.Color.w = saturate(In.Color.w*2.0 - 1.0);
	Out.Color.xyz *= Out.Color.w;	
	Out.C2= In.Color2;
	Out.C2.y = length(In.Normal);
	Out.C2.w = 1.0/Out.Pos.w;
	Out.N = normalize(In.Normal);
	Out.vN = mul(float4(In.Normal, 0.0), g_WorldViewMatrix).xyz;
	Out.VDir = normalize(In.Pos.xyz-g_ViewerPos);
	return Out;
}

// Pixel shader

struct VS_OUTPUT {
	float4 Pos  : POSITION;
	float3 vN   : TEXCOORD0;
	float3 N    : TEXCOORD1;
	float3 VDir : TEXCOORD2;
	float4 Color: TEXCOORD3;
#ifdef SHADOWS
	float3 SPos : TEXCOORD4;
#endif
	float4 C2   : TEXCOORD5;
	float3 MPos : TEXCOORD6;
};


float4 Color;
float3 LDir;
float LDiffuse;
float LAmbient;
float ShadowMin;
sampler CustomSampler1;//corresponds to texture Shaders/CustomSampler1.dds
sampler CustomSampler3;
sampler ShadowSampler;
float4x4 g_WorldViewMatrix;
float4 CurrColor;
float4 ColorModulation;
float Opacity;
float4 LightColor;
float3 LDirNormalized;
float3 g_LocalViewDir;
float GridConst;
float3 CavityCo;
float3 LocalRightDir;
float3 LocalUpDir;
float cavityIntensity;
float bulgeIntensity;
float4 cavityColor;
float4 bulgeColor;
float3 ExtraGamma;
float PaintOpacity;
float Inverse;
//@insert:contrast

float4 main( const VS_OUTPUT v,float4 sp : VPOS ) : COLOR {
	if(((sp.x+sp.y)%2.0)==GridConst)discard;
       	float L=v.C2.y;
	float3 wN=v.N;
	float dd=clamp(L-1.0,0.0,1.0) * 0.45;
	float3 viewN = normalize(v.vN);

#ifdef FLAT_SHADING
	wN = normalize(cross(ddx(v.MPos),ddy(v.MPos)))*Inverse;
	viewN = normalize(mul(float4(wN, 0.0), g_WorldViewMatrix).xyz);
#endif //FLAT_SHADING

#ifdef SHADOWS
	float darkside = ShadowMin+clamp(dot(wN, -LDir)*1.5 , 0.0, 1.0);	 
	float3 m=tex2D(ShadowSampler,v.SPos.xy).xyz;
	float3 d=float3(1.0,1.0/255.0,1.0/255.0/255.0);
	float mpl=clamp(1.1-(v.SPos.z-dot(m,d)) * 1200,0.25,1.0);
	mpl = min(mpl,darkside);
	mpl = min(1.0, mpl + LAmbient)*1.2;
#else 	//!SHADOWS
	float mpl = 1.0;
#endif  //SHADOWS

	float2 PicMatUV = float2(viewN.x * 0.5 +0.5, viewN.y * 0.5 - 0.5);
	PicMatUV = 1.0 - PicMatUV;
	float4 DiffuseColor = tex2D(CustomSampler1, PicMatUV);
	DiffuseColor.xyz *= getmodf(DiffuseColor.xyz);
	float4 colmod = ColorModulation;

#ifdef USE_CAVITY
	float3 ViewDir = normalize(v.VDir);
	float3 dxx=ddx(v.N);
	float3 dyy=ddy(v.N);
	float  ca0 = (CavityCo.x*v.C2.w+CavityCo.y)*(dot(dxx,LocalRightDir)-dot(dyy,LocalUpDir));

	float cavity = saturate(ca0*cavityIntensity);
	colmod.xyz = lerp(colmod.xyz,cavityColor.xyz,cavity);

	cavity = saturate(-ca0*bulgeIntensity);
	colmod.xyz = lerp(colmod.xyz,bulgeColor.xyz,cavity);
#endif //USE_CAVITY
	float4 C = DiffuseColor * (LDiffuse * mpl) * colmod * 2.0;// * v.Color
	float Diff = (C.x+C.y+C.z)/3.0;
	float popc = v.Color.w*PaintOpacity;
	C.xyz = C.xyz*(1.0-popc) + Diff*v.Color.xyz*PaintOpacity;

	float4 c4=tex2D(CustomSampler3,float2(dd*2.22,0))*(C.x+C.y+C.z+3.0)/6.0;
	C=lerp(C,c4,dd);
	C.w = Opacity;	
	float3  refl2 = g_LocalViewDir-2.0*wN*dot(g_LocalViewDir,wN);
	float S2 = max(0.0,dot(refl2,LDirNormalized));
	float fr2 = pow(S2,1.0+v.C2.x*v.C2.x*64.0)*v.C2.x;
	C.xyz += float3(fr2,fr2,fr2);
  
	return C;//*LightColor;        
}