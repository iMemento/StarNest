
Shader "ShaderMan/StarNest"
{
	Properties
	{
		_iMouse ("iMouse", Vector) = (0,0,0,0)
	}

	SubShader
	{
		Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

		Pass
		{
			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct VertexInput {
		    fixed4 vertex : POSITION;
			fixed2 uv:TEXCOORD0;
		    fixed4 tangent : TANGENT;
		    fixed3 normal : NORMAL;
		};
			
		struct VertexOutput
		{
			fixed4 pos : SV_POSITION;
			fixed2 uv:TEXCOORD0;
		};
			
		float4 _iMouse;


		#define iterations 17
		#define formuparam 0.53

		#define volsteps 20
		#define stepsize 0.1

		#define zoom   0.800
		#define tile   0.850
		#define speed  0.010 

		#define brightness 0.0015
		#define darkmatter 0.300
		#define distfading 0.730
		#define saturation 0.850

		VertexOutput vert (VertexInput v)
		{
			VertexOutput o;
			o.pos = UnityObjectToClipPos (v.vertex);
			o.uv = v.uv;
			return o;
		}
			
		fixed4 frag(VertexOutput i) : SV_Target
		{
			// get coords and direction
			fixed2 uv = i.uv / 1-.5;
			uv.y *= 1 / 1;
			fixed3 dir = fixed3(uv*zoom, 1.);
			fixed time = _Time.y * speed + .25;

			// mouse rotation
			fixed a1 = .5 + _iMouse.x / 1 * 2.;
			fixed a2= .8 + _iMouse.y / 1 * 2.;
			fixed2x2 rot1 = fixed2x2(cos(a1),sin(a1),-sin(a1),cos(a1));
			fixed2x2 rot2 = fixed2x2(cos(a2),sin(a2),-sin(a2),cos(a2));
			dir.xz = mul(dir.xz, rot1);
			dir.xy = mul(dir.xy, rot2);
			fixed3 from = fixed3(1.,.5,0.5);
			from += fixed3(time*2.,time,-2.);
			from.xz = mul(from.xz, rot1);
			from.xy = mul(from.xy, rot2);
	
			// volumetric rendering
			fixed s = 0.1, fade = 1.;
			fixed3 v = fixed3(0., 0., 0.);
			for (int r = 0; r < volsteps; r++)
			{
				fixed3 p = from + s * dir * .5;
				p = abs(fixed3(tile, tile, tile)-fmod(p, fixed3(tile*2., tile*2., tile*2.))); // tiling fold
				fixed pa, a = pa = 0.;
				for (int i = 0; i < iterations; i++)
				{
					p = abs(p) / dot(p,p) - formuparam; // the magic formula
					a += abs(length(p)-pa); // absolute sum of average change
					pa = length(p);
				}

				float dm = max(0., darkmatter - a * a * .001); //dark matter
				a *= a * a; // add contrast
				if (r > 6) fade *= 1. - dm; // dark matter, don't render near
				//v+=vec3(dm,dm*.5,0.);
				v += fade;
				v += fixed3(s, s * s, s * s * s * s) * a * brightness * fade; // coloring based on distance
				fade *= distfading; // distance fading
				s += stepsize;
			}
			v = lerp(fixed3(length(v), length(v), length(v)), v, saturation); //color adjust
			return fixed4(v * .01, 1.);	
		}
	ENDCG
	}
  }
}

