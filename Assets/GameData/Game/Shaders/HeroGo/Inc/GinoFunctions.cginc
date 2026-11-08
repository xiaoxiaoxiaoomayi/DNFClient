#ifndef GINO_CG_INCLUDE
#define GINO_CG_INCLUDE



	// Simple Noise Functions
	inline float simple_noise_randomValue (float2 uv)
    {
        return frac(sin(dot(uv, float2(12.9898, 78.233)))*43758.5453);
    }
                
    inline float simple_noise_interpolate (float a, float b, float t)
    {
        return (1.0-t)*a + (t*b);
    }

                
    inline float simple_valueNoise (float2 uv)
    {
        float2 i = floor(uv);
        float2 f = frac(uv);
        f = f * f * (3.0 - 2.0 * f);

        uv = abs(frac(uv) - 0.5);
        float2 c0 = i + float2(0.0, 0.0);
        float2 c1 = i + float2(1.0, 0.0);
        float2 c2 = i + float2(0.0, 1.0);
        float2 c3 = i + float2(1.0, 1.0);
        float r0 = simple_noise_randomValue(c0);
        float r1 = simple_noise_randomValue(c1);
        float r2 = simple_noise_randomValue(c2);
        float r3 = simple_noise_randomValue(c3);

        float bottomOfGrid = simple_noise_interpolate(r0, r1, f.x);
        float topOfGrid = simple_noise_interpolate(r2, r3, f.x);
        float t = simple_noise_interpolate(bottomOfGrid, topOfGrid, f.y);
        return t;
    }
                    void SimpleNoise_float(float2 UV, float Scale, out float Out)
                    {
                        float t = 0.0;
                
                        float freq = 1;
                        float amp = 0.125;
                        t += simple_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
                
                        freq = 2;
                        amp = 0.25;
                        t += simple_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
                
                        freq = 4;
                        amp = 0.5;
                        t += simple_valueNoise(float2(UV.x*Scale/freq, UV.y*Scale/freq))*amp;
                
                        Out = t;
                    }
            //-------------------------------------------------------------------------------------
            // End Simple Noise Functions
            //-------------------------------------------------------------------------------------

			//Voronoi Functions
        inline float2 unity_voronoi_noise_randomVector (float2 UV, float offset)
        {
            float2x2 m = float2x2(15.27, 47.63, 99.41, 89.98);
            UV = frac(sin(mul(UV, m)) * 46839.32);
            return float2(sin(UV.y*+offset)*0.5+0.5, cos(UV.x*offset)*0.5+0.5);
        }

            void Unity_Voronoi_float(float2 UV, float AngleOffset, float CellDensity, out float Out, out float Cells)
            {
                float2 g = floor(UV * CellDensity);
                float2 f = frac(UV * CellDensity);
                float t = 8.0;
                float3 res = float3(8.0, 0.0, 0.0);

                for(int y=-1; y<=1; y++)
                {
                    for(int x=-1; x<=1; x++)
                    {
                        float2 lattice = float2(x,y);
                        float2 offset = unity_voronoi_noise_randomVector(lattice + g, AngleOffset);
                        float d = distance(lattice + offset, f);

                        if(d < res.x)
                        {

                            res = float3(d, offset.x, offset.y);
                            Out = res.x;
                            Cells = res.y;

                        }
                    }

                }

            }
			//-------------------------------------------------------------------------------------
            // End Voronoi Functions
            //-------------------------------------------------------------------------------------

#endif