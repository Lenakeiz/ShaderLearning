Shader "Toon/Basic Outline - Transparent" {
	Properties {
		_Color ("Main Color", Color) = (.5,.5,.5,1)
		_OutlineColor ("Outline Color", Color) = (0,0,0,1)
		_Outline ("Outline width", Range (.002, 0.03)) = .005
		_MainTex ("Base (RGB)", 2D) = "white" { }
		_ToonShade ("ToonShader Cubemap(RGB)", CUBE) = "" { }
	}	
	
	CGINCLUDE
	#include "UnityCG.cginc"
	ENDCG
	
	SubShader {
		UsePass "Toon/BasicTransparent/BASE"
		UsePass "Toon/Basic Outline/OUTLINE"
	}
	Fallback "Toon/Basic"
}