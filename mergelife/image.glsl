void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float scale = 1.0;
    
    if (length(fragCoord - vec2(0, iResolution.y)) < min(iResolution.x, iResolution.y)*0.85) {
        scale = 0.25;
    }
    vec4 c0 = texelFetch( iChannel0, ivec2(fragCoord * scale), 0);
    vec4 c1 = texelFetch( iChannel1, ivec2(fragCoord * scale), 0);
    vec4 c2 = texelFetch( iChannel2, ivec2(fragCoord * scale), 0);
    if (c0 == c2) {
        /*if (int(fragCoord.x) % 2 == 0) {
        	fragColor = c0;
        } else {
            fragColor = c1;
        }*/
        // try to reduce some of the flickering without making picture too blurry
        fragColor = 0.5 * (c1 + c0); 
    } else {
        fragColor = c0;
    }
    //fragColor = fragColor.zzzz;
}