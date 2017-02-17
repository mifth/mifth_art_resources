// Vertex shader
//@insert:mcubes_vs
// Fragment shader

in	vec4 oPos;
in	vec3 oN;
in	vec4 oC;
in	vec4 oC2;
#ifdef SHADOWS
in vec3 oSPos;
#endif
in vec4 oExtra;
in vec3 oVDir;
in vec3 oMPos;

uniform sampler2D CustomSampler1;//color texture
uniform sampler2D CustomSampler2;//normalmap
uniform sampler2D CustomSampler3;//freeze indicator
uniform sampler2D CustomSampler4;//gloss modulator
uniform sampler2D CustomSampler5;//metall modulator
uniform sampler2D Panorama;
uniform sampler2D ShadowSampler;

uniform vec4 		Color;
uniform vec4 		CurrColor;
uniform vec3 		LDir;
uniform vec3 		LDirNormalized;
uniform vec3 		VDir;
uniform float  		LDiffuseC;
uniform float  		LDiffuse22C;
uniform float  		LAmbient;
uniform float  		ShadowMin;
uniform vec4 		LightColor;
uniform vec3 		g_LocalViewDir;
uniform float  		Opacity;
uniform float  		GridConst;
uniform float  		PanoramaShift;
uniform float  		RefShade;
uniform mat3x3 		PanMatrix;
uniform mat3x3 		WPanMatrix;
uniform vec4 		Freshnel;
uniform vec4 		mip_ref;
uniform float  		Bumpness;
uniform float  		cavityIntensity;
uniform vec4 		cavityColor;
uniform float  		cavityGloss;
uniform float  		cavityMetall;
uniform float 		bulgeIntensity;
uniform vec4 		bulgeColor;
uniform float  		bulgeGloss;
uniform float  		bulgeMetall;
uniform vec3		CavityCo;
uniform vec3 		LocalRightDir;
uniform vec3 		LocalUpDir;
uniform float 		IncSign;
uniform float 		SSS_Degree;

out vec4 FragColor;

#ifdef USE_DEPTH
               
uniform sampler2D 	DepthSampler;
uniform float 		du;
uniform float 		dv;
uniform float 		depK1;
uniform float 		depK2;
uniform mat3x3 		g_ViewWorldMatrix3;

#endif

uniform mat4 g_WorldViewProjectionMatrix;

#define TC_DEFINED
#define MODULATE_GM
#define MODULATE_COLOR
#define MODULATE_OPACITY

#define FUZZ
#define CLEAR_COAT
#define ARTISTIC
//@insert:ext_pbs_h
//@insert:ggx_variables
//@insert:contrast

void main()  {
	//@insert:mcubes_ps
	//@insert:ggx_layers
	//@insert:ext_light_core
	
	FragColor = color;        
}