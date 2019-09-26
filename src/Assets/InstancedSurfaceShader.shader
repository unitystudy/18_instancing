﻿Shader "Custom/InstancedSurfaceShader"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
		_DisplacementMap("Displacement (RG)", 2D) = "white" {}// ☆追加
	}
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
//      #pragma surface surf Standard fullforwardshadows
		#pragma surface surf Standard fullforwardshadows vertex:vert// ☆頂点シェーダを変更する

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

		sampler2D _MainTex;
		sampler2D _DisplacementMap;// ☆追加

        struct Input
        {
            float2 uv_MainTex;
        };

        half _Glossiness;
        half _Metallic;
//        fixed4 _Color; // ★削除

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
			UNITY_DEFINE_INSTANCED_PROP(fixed4, _Color)// ★追加
        UNITY_INSTANCING_BUFFER_END(Props)

		// ☆頂点シェーダを追加
		void vert(inout appdata_full v) {
			float2 d = tex2Dlod(_DisplacementMap, float4(v.vertex.xy, 0, 0)).xy;// 2次元ノイズの読み込み
			v.vertex.xz += (v.vertex.y + 1.0) * d.xy * 10;// 高いほど大きく揺らす
		}
		void surf (Input IN, inout SurfaceOutputStandard o)
        {
            // Albedo comes from a texture tinted by color
//			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;// ★下記に変更
			fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * UNITY_ACCESS_INSTANCED_PROP(Props, _Color);
			o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

