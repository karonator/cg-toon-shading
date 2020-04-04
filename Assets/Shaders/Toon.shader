Shader "karonator/Shading/Toon"
{
	Properties
	{
		_DiffTex("Diffuse texture", 2D) = "white" {}

		_StepsCount("Steps count", Int) = 4
		_LUTTex("Toon LUT texture", 2D) = "white" {}

		_Ambient("Ambient coeff", Range(0, 1)) = 0.1
		_RimAmount("Rim Amount", Range(0, 1)) = 0.8

		_SpecMin("Specular range min", Range(0, 1)) = 0.02
		_SpecMax("Specular range max", Range(0, 1)) = 0.07
	}
	SubShader
	{
		Pass
		{
			Tags { "LightMode" = "ForwardAdd" }
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			sampler2D _DiffTex;

			int _StepsCount;
			sampler2D _LUTTex;

			float _Ambient;
			float _RimAmount;

			float _SpecMin;
			float _SpecMax;

			struct vertex_data
			{
				float4 vertex: POSITION;
				float3 normal: NORMAL0;
				float2 uv: TEXCOORD0;
			};

			struct fragment_data
			{
				float4 pos: POSITION;
				float4 pos_world: TEXCOORD1;

				float3 normal: NORMAL0;
				float2 uv : TEXCOORD0;
			};

			fragment_data vert(vertex_data v)
			{
				fragment_data o;

				o.pos = UnityObjectToClipPos(v.vertex);
				o.pos_world = mul(unity_ObjectToWorld, v.vertex);

				o.uv = v.uv;
				o.normal = normalize(mul(float4(v.normal, 0.0), unity_WorldToObject).xyz);
				return o;
			}

			fixed4 frag(fragment_data i) :COLOR
			{
				float3 L = normalize(_WorldSpaceLightPos0 - i.pos_world);
				float3 N = normalize(i.normal);
				float3 V = normalize(_WorldSpaceCameraPos - i.pos_world);
				
                float lambert = max(dot(L, N) + _Ambient, 0.0);

                // stepped lambert shading (variant 1)
                float step_size = 1.0 / _StepsCount;
                float result = round(lambert / step_size) * step_size;

                // using lut texture (variant 2)
			    // float result = tex2D(_LUTTex, float2(lambert, 0.5));

				// specular
				float3 R = reflect(-L, N);
				float spec = pow(saturate(dot(R, V)), 100);
				float specularSmooth = smoothstep(_SpecMin, _SpecMax, spec);
				result += specularSmooth;

				// rim
				float4 rim = 1 - dot(V, N);
				float rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rim);
				result += rimIntensity;

				float3 color = tex2D(_DiffTex, i.uv);
				return float4(color * result, 1.0);
			}

			ENDCG
		}
	}

	Fallback "VertexLit"
}
