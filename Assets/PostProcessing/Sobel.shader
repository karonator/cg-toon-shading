Shader "karonator/PostProcess/Sobel"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
			
			sampler2D _CameraDepthTexture;
			sampler2D _MainTex;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f inp):SV_Target
            {
				float3x3 KernelX = { -1, 0, 1, -2, 0, 2, -1, 0, 1 };
				float3x3 KernelY = { -1, -2, -1, 0, 0, 0, 1, 2, 1 };

				float dx = 1.0 / _ScreenParams.x;
				float dy = 1.0 / _ScreenParams.y;

				float GX = 0;
				float GY = 0;

				for (int i = 0; i < 3; i++) {

					for (int j = 0; j < 3; j++) {
						float2 tex_coord = float2(inp.uv.x + (i - 1) * dx, inp.uv.y + (j - 1) * dy);

						float depth = tex2D(_CameraDepthTexture, tex_coord).r;
						depth = Linear01Depth(depth) * 70;
						
						GX += KernelX[i][j] * depth;
						GY += KernelY[i][j] * depth;
					}
				}
				float sobel_result = sqrt(pow(GX, 2) + pow(GY, 2));

				float3 color = tex2D(_MainTex, inp.uv);
				return float4(color * (1.0 - sobel_result), 1.0);
            }
            ENDCG
        }
    }
}
