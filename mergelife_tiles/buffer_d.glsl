

vec4 getv(ivec2 d, vec2 fragCoord)
{
	ivec2 size = ivec2(iResolution);
    
    ivec2 p = ivec2(fragCoord)+d;
    
    bvec2 lt = lessThan(p, ivec2(0));
    bvec2 gt = greaterThanEqual(p, size);
    
    p = p + (ivec2(lt) * size) - (ivec2(gt) * size);
    
    return texelFetch( iChannel1, p, 0 );
}


vec4 getv2(ivec2 p)
{
    return texelFetch( iChannel0, p, 0 );
}

float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

vec4 getColor(float v) {
    int i = int(v) % 8;
    return vec4(i & 1, (i >> 1) & 1, (i >> 2) & 1, 0);
}




void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec4 t = getv(ivec2(0), fragCoord);
    fragColor= t;
    
    
    bool need_refresh = ((iFrame*2 + int(BLOCK_SIZE*sin(0.1 * iTime + fragCoord.x/BLOCK_SIZE)
                                       			*sin(0.1 * iTime + fragCoord.y/BLOCK_SIZE))) % randomize_data_period) < 8;
	 
    if(iFrame == 0 || need_refresh /*|| (length(iMouse.xy-fragCoord))<5.0*/)
    {
        fragColor.x=rand(fragCoord+vec2(123.0, 321.0));
        fragColor.y=rand(-fragCoord.yx);
        fragColor.z=rand(-fragCoord+ vec2(53.0, 4689.0));
    }
    else if (iFrame > 2)
    {
     
        vec4 r0[8];
        float alpha[8];
        float beta[8];
        float col[8];
        
		int rule_index = get_rule_index_for_pos(iFrame, fragCoord, iResolution, iTime);
        for (int j=0; j<8; j++) {
        	vec4 r0 =getv2(ivec2(j, rule_index));
            alpha[j] = r0.x * 8.0 * 255.0;
            beta[j] = r0.y * 256.0;
            if (beta[j] > 127.0) {
            	beta[j] -= 256.0;
            }
            col[j]=r0.z*256.0;
        }
        
		vec4 u=vec4(0.0);
       
        u += getv(ivec2(-1, -1), fragCoord);
        u += getv(ivec2( 0, -1), fragCoord);
        u += getv(ivec2( 1, -1), fragCoord);
        
        u += getv(ivec2(-1,  1), fragCoord);      
        u += getv(ivec2( 0,  1), fragCoord);
        u += getv(ivec2( 1,  1), fragCoord);
        
        u += getv(ivec2(-1,  0), fragCoord);
        u += getv(ivec2( 1,  0), fragCoord);
        float s = floor(((u.x + u.y + u.z)*255.0)/3.0);
     
        vec4 res = fragColor;
        vec4 d = vec4(0);
        bool done = false;
        for (int i=0; i<8; i++) {
            if (!done && s < alpha[i]) {
                float b = float(beta[i]);
                if (b < 0.0) {
                    vec4 k = getColor(col[i] + 1.0);
                    d = (k - res) * (-b)/128.0;
                } else {
                    vec4 k = getColor(col[i]);
                    d = (k - res) * b/127.0;
                }
                done = true;
                //break; doesn't work
            }
        }
        d = floor(d * 255.0)/255.0;
        //d=getv(ivec2(-1, 0), fragCoord);
        vec4 c0 = t + d;
        c0.w = 0.;
        fragColor = c0;
        vec4 c2 = texelFetch( iChannel3, ivec2(fragCoord), 0);
        if (c0.xyz == c2.xyz) {
        	c0.w = 1.;
        }
       	fragColor = c0;
    }
}