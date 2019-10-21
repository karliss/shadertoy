

vec4 ballD(in vec2 ipos, in vec2 ballp)
{
    float d = distance(ipos, ballp)/BALL_SIZE;
    return vec4(clamp(sign(1.0-d), 0.0, 1.0)*(1.-d) * float(ballp.x > 0.0)) ;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float scale = iMouse.z > 0.0 && iMouse.x < 30.0 ? clamp(SIZE*(iMouse.y/iResolution.y), 0.01, SIZE) : 1.0;
    ivec2 cellIndex = ivec2(fragCoord / SIZE * scale);
    vec2 cellp = mod(fragCoord, SIZE * scale)/(SIZE * scale);

    vec4 res = vec4(0.0, 0.0, 0.0, 1.0);
    vec2 worldPos = fragCoord * scale;
    float overlaps = 0.0;
    vec4 normSum = vec4(0.0);
    for (int x=-1; x<=1; x++) {
        for (int y=-1; y<=1; y++) {
            
            ivec2 tp = max(cellIndex+ivec2(x,y), ivec2(0));
            
        	vec4 ball  = texelFetch( iChannel0, tp, 0 );
            vec2 p = ball.xy;
            vec2 vel = ball.zw;

            p *= iResolution.xy;
            
            float d = distance(worldPos, p.xy)/BALL_SIZE;
            normSum += vec4(p.xy-worldPos, 0.0, 0.0)/BALL_SIZE*(d < 1.0 ? 1.0 : 0.0);
            vec4 shade = vec4(clamp(sign(1.0-d), 0.0, 1.0)*(1.-d) * float(ball.x > 0.0)) ;
            //vec4 shade = vec4(d < 1.0 ? 1.0 : 0.0) ;
            //res=max(res, shade*vec4(vel.x,-vel.x-vel.y,vel.y, 1.0));
            res=max(res, shade);
            overlaps += d < 1.0 ? 1.0 : 0.0;
        }
    }
    fragColor = res;
    //fragColor = res * vec4(2.0 - overlaps, 3.0 - 2.0*overlaps, 1.0, 1.0);
    //fragColor = normSum+vec4(1.0, 1.0, 1.0,1.0)*0.5;

    // Output to screen
    //fragColor = vec4(col,1.0);
}