﻿// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Hidden/DarkRoomSpotlightEffect"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_LightTex("Light Texture", 2D) = "white" {}
		_LampPos("Lamp Position", Vector) = (0,0,0,0)
		_CursorPos("Cursor Position", Vector) = (0,0,0,0)
		_FadeStart("Fade Start Distance", Float) = 5
		_FadeEnd("Fade End Distance", Float) = 10
		_CursorFadeEnd("Cursor Fade End Distance", Float) = 10
		_PulseSpeed("Pulse Speed", Float) = 10
		_AlphaPow("Pulse Exponent", Float) = .5
		_CursorAlphaPow("Cursor Pulse Exponent", Float) = .5
		_PulseAmpInv("Pulse Amplitude Inverse", Float) = 15
		_CursorPulseAmpInv("Cursor Pulse Amplitude Inverse", Float) = 15
		_LampAlphaBoost("Lamp Alpha Boost", Float) = 0
		_LampRadiusBoost("Lamp Radius Boost", Float) = 0
		_CursorAlphaBoost("Cursor Alpha Boost", Float) = 0
		
		_LampAnim("Lamp Animation Boost", Float) = 0
		_CursorAnim("Cursor Animation Boost", Float) = 0
		_FlipX("Flip X", Float) = 0
	}

	SubShader
	{
		Tags
		{
			"Queue" = "Transparent"
			"RenderType"="Transparent"
			"PreviewType" = "Plane"
		}
		Pass
		{
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float3 wpos : TEXCOORD1;
				float3 vpos : TEXCOORD2;
                float4 uvColor : COLOR;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float2 uv : TEXCOORD0;
				float3 wpos : TEXCOORD1;
				float3 vpos : TEXCOORD2;
                float4 uvColor : COLOR;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
                o.uvColor = v.uvColor;
				
				// World position calculations
				float3 worldPos = mul (unity_ObjectToWorld, v.vertex).xyz;
				o.wpos = worldPos;
				o.vpos = v.vertex.xyz;
				return o;
			}
			
			sampler2D _MainTex;
			sampler2D _LighTex;
			float4 _LampPos;
			float4 _CursorPos;
			float _FadeStart;
			float _FadeEnd;
			float _CursorFadeEnd;
			float _PulseSpeed;
			float _PulseAmpInv;
			float _CursorPulseAmpInv;
			float _AlphaPow;
			float _CursorAlphaPow;
			float _LampAlphaBoost;
			float _CursorAlphaBoost;
			float _LampAnim;
			float _CursorAnim;
			float _FlipX;
			float _LampRadiusBoost;

			float distance(float2 a, float2 b)
			{
				return sqrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2));
			}

			float4 frag(v2f i) : SV_Target
			{
				if (_FlipX > .5)
					i.uv.x = 1.0-i.uv.x;

				float4 color = tex2D(_MainTex, i.uv);
                color *= i.uvColor;

				if (_FlipX > .5)
					i.uv.x = 1.0-i.uv.x;

				float lampDistance = distance((float2)i.wpos, (float2)_LampPos);
				float lampAlpha = (lampDistance - _FadeStart) / abs((_FadeEnd + _LampRadiusBoost) - _FadeStart);
				lampAlpha *= 1 + (sin(_Time.w * .8 * _PulseSpeed) / _PulseAmpInv);
				//lampAlpha = clamp(lampAlpha, 0, 1);
				lampAlpha = pow(lampAlpha, _AlphaPow);
				//if (lampAlpha < 1)
				lampAlpha = clamp(lampAlpha, 0, 1);
				lampAlpha -= _LampAlphaBoost;
				lampAlpha -= _LampAnim;
				lampAlpha = clamp(lampAlpha, 0, 1);

				float cursorDistance = distance((float2)i.wpos, (float2)_CursorPos);
				float cursorAlpha = (cursorDistance - _FadeStart) / abs(_CursorFadeEnd - _FadeStart);
				cursorAlpha *= 1 + (sin(_Time.w * .7 * _PulseSpeed) / _CursorPulseAmpInv);
				cursorAlpha = clamp(cursorAlpha, 0, 1);
				cursorAlpha = pow(cursorAlpha, _CursorAlphaPow);
				cursorAlpha -= _CursorAlphaBoost;
				cursorAlpha -= _CursorAnim;
				cursorAlpha = clamp(cursorAlpha, 0, 1);

				float alpha = 1 - ((1 - lampAlpha) + (1 - cursorAlpha));
				color.a *= clamp(alpha, 0, 1);

				return color;
			}
			ENDCG
		}
	}
}