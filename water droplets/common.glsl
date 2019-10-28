const float BIG_DROP_RATE = 0.15;
const float BIG_DROP_SIZE = 10.;
const float BIG_DROP_DEPTH = 0.2;

const float SMALL_DROP_RATE = 0.001;
const float SMALL_DROP_SIZE = 0.000003;

const int R = 4; // watter attraction radius


//------------------------------
// Hash without Sine
// Creative Commons Attribution-ShareAlike 4.0 International Public License
// Created by David Hoskins.
float hash12(vec2 p)
{
	vec3 p3  = fract(vec3(p.xyx) * .1031);
    p3 += dot(p3, p3.yzx + 33.33);
    return fract((p3.x + p3.y) * p3.z);
}
#define hv(p) hash12((p * .152 + iTime * 1500. + 50.0))
//----------------------------
