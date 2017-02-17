// Vertex shader
//@insert:mcubes_vs
// Pixel shader

struct VS_OUTPUT {
	float4 Pos  : POSITION;
	float3 N    : TEXCOORD1;
	float4 C    : TEXCOORD2;
	float4 C2   : TEXCOORD3;
#ifdef SHADOWS
	float3 SPos : TEXCOORD4;
#endif
	float4 Extra : TEXCOORD5;
	float3 VDir : TEXCOORD6;
	float3 MPos : TEXCOORD7;
};

sampler CustomSampler1;//color texture
sampler CustomSampler2;//normalmap
sampler CustomSampler3;//freeze indicator
sampler CustomSampler4;//gloss modulator
sampler CustomSampler5;//metall modulator


sampler Panorama;
sampler ShadowSampler;


float4 		Color;
float4 		CurrColor;
float3 		LDir;
float3 		LDirNormalized;
float3 		VDir;
float  		LDiffuseC;
float  		LDiffuse22C;
float  		LAmbient;
float  		ShadowMin;
float4 		LightColor;
float3 		g_LocalViewDir;
float  		Opacity;
float  		GridConst;
float  		PanoramaShift;
float  		RefShade;
float3x3 	PanMatrix;
float3x3 	WPanMatrix;
float4 		Freshnel;
float4 		mip_ref;
float  		Bumpness;
float  		cavityIntensity;
float4 		cavityColor;
float  		cavityGloss;
float  		cavityMetall;
float  		bulgeIntensity;
float4 		bulgeColor;
float  		bulgeGloss;
float  		bulgeMetall;
float 		SSS_Degree;




float3		LocalRightDir;
float3		LocalUpDir;
float3		CavityCo;

#ifdef USE_DEPTH
               
sampler DepthSampler;
float 		du;
float 		dv;
float 		depK1;
float 		depK2;
float3x3 	g_ViewWorldMatrix3;

#endif



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
float4 main( const VS_OUTPUT v,float4 sp : VPOS ) : COLOR {
	//@insert:mcubes_ps

	//@insert:ggx_layers

	//@insert:ext_light_core

	return color;        
}