// buffer D - store and update amount of water in each cell

vec4 getv(vec2 p) {
	return texelFetch(iChannel0, ivec2(p), 0);
}

vec4 getm(vec2 p) {
	return texelFetch(iChannel1, ivec2(p), 0);
}




void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    if (iFrame == 0) {
    	fragColor = vec4(0.0, 0.0, 0.0, 0.0);
    } else {
        vec2 p = fragCoord;
    	vec4 v = getv(p);
        if (length(p - iMouse.xy) < 10. && iMouse.z > 0.) {
        	v.x += 0.008;
        }
        
        float sh = hv(p);
        v.x += SMALL_DROP_SIZE * step(SMALL_DROP_RATE, sh) * sh;  // add little bit of water everywhere all the time
        
        if (hv(vec2(1, 0)) < fract(iTime) * BIG_DROP_RATE) { // once in a while add big drop somewhere in the picture
        	vec2 dp = vec2(hv(vec2(iTime, 0)), hv(vec2(0, 1)));
			dp *= iResolution.xy;
            float size = hv(vec2(2, 0));
			if (distance(dp, p) < BIG_DROP_SIZE * mix(0.5, 1., size)) {
                v.x += BIG_DROP_DEPTH;
			}
        }
        
        vec4 moveOut = getm(p);
        vec4 moveIn = vec4(
        	getm(p + vec2(-1., 0.)).z,
            getm(p + vec2(0., -1.)).w,
            getm(p + vec2(1., 0.)).x,
            getm(p + vec2(0., 1.)).y   
        );
        
        v.x += 1.0*dot(vec4(1.), moveIn-moveOut);
        
        v = clamp(v, 0.0, 1.0);
        if (p.y <= 1. || p.x < 1. || p.x > iResolution.x - 2. || p.y > iResolution.y - 2.) {
            v.x = 0.;
        }
        fragColor = v;
    }
}