Shader "Custom/ColorWheel" {
    Properties {
        _MainTex("Main Texture", 2D) = "white" { }
        _ColoringMode("Coloring Mode", Int) = 0
        _RotationFrequency("Rotation Frequencty", Range(0, 100)) = 25

        // `UI.Mask` depends on it.
        [HideInInspector] _StencilComp("Stencil Comparison", Float) = 8
        [HideInInspector] _Stencil("Stencil ID", Float) = 0
        [HideInInspector] _StencilOp("Stencil Operation", Float) = 0
        [HideInInspector] _StencilWriteMask("Stencil Write Mask", Float) = 255
        [HideInInspector] _StencilReadMask("Stencil Read Mask", Float) = 255
        [HideInInspector] _ColorMask("Color Mask", Float) = 15
    }
    Subshader {
        // `UI.Mask` depends on it.
        Stencil {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp] 
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }
        ColorMask [_ColorMask]

        // Making alpha color component work.
        Blend SrcAlpha OneMinusSrcAlpha

        Pass {
            CGPROGRAM

            #pragma vertex on_vertex
            #pragma fragment on_fragment

            #include "UnityCG.cginc"

            uniform sampler2D _MainTex;
            uniform int _ColoringMode;
            uniform fixed _RotationFrequency;

            static inline fixed3 hsv_to_rgb(in fixed h, in fixed s, in fixed v);
            static inline fixed3 color_wheel(in fixed x, in fixed y, in fixed delta_phi);
            static inline fixed4 blend_colors(in fixed4 color_1, in fixed4 color_2, int mode);
            
            void on_vertex(
                in  float4 vertex       : POSITION,
                in  float2 uv           : TEXCOORD0,
                out float4 out_position : SV_POSITION,
                out float2 out_uv       : TEXCOORD0)
            {
                out_position = UnityObjectToClipPos(vertex);
                out_uv = uv;
            }

            void on_fragment(
                in  float4 position : SV_POSITION,
                in  float2 uv       : TEXCOORD0,
                out fixed4 color    : SV_TARGET0)
            {
                fixed x = uv.x * 2 - 1;
                fixed y = uv.y * 2 - 1;

                fixed4 pixel = tex2D(_MainTex, uv);
                color = blend_colors(
                    pixel,
                    fixed4(color_wheel(x, y, _RotationFrequency * _Time), 1),
                    _ColoringMode);
            }

            static inline fixed3 hsv_to_rgb(in fixed h, in fixed s, in fixed v)
            {
                fixed i = h * 6;
                fixed j = floor(i);
                fixed k = i - j;

                fixed a = v * (1 - s);
                fixed b = v * (1 - s * k);
                fixed c = v * (1 - s * (1 - k));

                switch (j) {
                case 0:
                    return fixed3(v, c, a);
                case 1:
                    return fixed3(b, v, a);
                case 2:
                    return fixed3(a, v, c);
                case 3:
                    return fixed3(a, b, v);
                case 4:
                    return fixed3(c, a, v);
                default:
                    return fixed3(v, a, b);
                }
            }

            static inline fixed3 color_wheel(in fixed x, in fixed y, in fixed delta_phi)
            {
                fixed rho = sqrt(x * x + y * y);
                fixed phi = (int)(y <= 0) + atan2(y, x) / UNITY_TWO_PI;

                fixed h = (phi + delta_phi) % 1;
                fixed s = 1;
                fixed v = 1;

                return hsv_to_rgb(h, s, v);
            }
            
            static inline fixed4 blend_colors(in fixed4 color_1, in fixed4 color_2, int mode)
            {
                switch (mode) {
                case 0:
                    return color_1 * color_2;
                case 1:
                    return (color_1 + color_2) / 2;
                case 2:
                    return (color_1.a != 0) * color_2;
                default:
                    return color_1;
                }
            }

            ENDCG
        }
    }
}
