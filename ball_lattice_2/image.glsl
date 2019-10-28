

vec4 ballD(in vec2 ipos, in vec2 ballp)
{
    float d = distance(ipos, ballp)/BALL_SIZE;
    return vec4(clamp(sign(1.0-d), 0.0, 1.0)*(1.-d) * float(ballp.x > 0.0)) ;
}

float line(vec2 a, vec2 b, vec2 p) {
    vec2 pa = p - a;
	vec2 ba = b - a;
	float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0);
    vec2 v =  pa - ba*h ;
    return length(v);
}

vec2 addAngle(vec2 a, vec2 b)
{
    return mat2(a.x, a.y, -a.y, a.x)*b;
}

vec2 times6(vec2 a)
{
    vec2 t2 = addAngle(a, a);
    vec2 t3 = addAngle(t2, a);
    return addAngle(t3, t3);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float scale = iMouse.z > 0.0 && iMouse.x < 30.0 ? clamp(SIZE*(iMouse.y/iResolution.y), 0.01, SIZE) : 1.0;
    vec2 fcord = fragCoord * scale + iMouse.xy * vec2(1.0, 0.3);
    ivec2 cellIndex = ivec2(fcord / SIZE);
    vec2 cellp = mod(fcord, SIZE * scale)/(SIZE * scale);


    vec2 worldPos = fcord;
    float overlaps = 0.0;
    vec4 normSum = vec4(0.0);
    vec4 res = vec4(0);
    float cnt = 1.;
    
    //vec4 pos = vec4(0);
    for (int x=-2; x<=2; x++) {
        for (int y=-2; y<=2; y++) {
            
            ivec2 tp = max(cellIndex+ivec2(x,y), ivec2(0));
        	vec4 ball  = texelFetch( iChannel0, tp, 0 );
            vec2 p = ball.xy;
            vec2 vel = ball.zw;
            p *= iResolution.xy;
            
              for (int x2=-1; x2<=1; x2++) {
        		for (int y2=-1; y2<=1; y2++) {
            
                    ivec2 tp2 = max(cellIndex+ivec2(x2,y2), ivec2(0));
                    vec4 ball2  = texelFetch( iChannel0, tp2, 0 );
                    vec2 p2= ball2.xy;
                    p2 *= iResolution.xy;
                    
                    vec2 ab = p - p2;
                    float abl = dot(ab, ab);;
                    float ds = (line(p, p2, fcord));
                    if (abl < BALL_D * BALL_D * 1.1 && ds < 0.3+scale  ) {
                        //ds = sqrt(ds);
                    	//float a = atan(ab.y, ab.x)+0.0;
                        //a *= 6.0; // multiply angle by six so that everying in hexagonal lattice have the same color
                        //vec4 color = max(vec4(sin(a), cos(a), -sin(a)-cos(a), 1.0), 0.0);
                        //vec2 t6=times6(normalize(ab));
                        vec2 t6 = times6(ab/(BALL_D)); // length(ab) ~ BALL_D
                        vec4 color = max(vec4(t6.y, t6.x, -t6.x-t6.y, 1.0), 0.0);
                        
                        //res = mix(res, color * (1.-smoothstep(0.3, 0.3+scale, ds)), 1./cnt);
                        //cnt += (1.-smoothstep(0.3, 0.3+scale, ds));
                        res = max(res, color * (1.-smoothstep(0.3, 0.3+scale, ds))); // Thanks FabriceNeyret2                 
                    }
                }
              }
        }
    }
    fragColor = res;
    //fragColor = res * vec4(2.0 - overlaps, 3.0 - 2.0*overlaps, 1.0, 1.0);
    //fragColor = normSum+vec4(1.0, 1.0, 1.0,1.0)*0.5;

    // Output to screen
    //fragColor = vec4(col,1.0);
}