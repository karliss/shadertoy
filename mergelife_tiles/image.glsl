vec2 getChar(vec2 uv,  int c)
{     
    float x =  (float(c%16)+ uv.x );   
    float y = (15. - float(c/16) + uv.y);     
    return vec2(x, y)/16.;
}

int base16ToAscii(int v) {
    if (v >= 0 && v < 16) {     
    	return  v <= 9 ? v + 0x30 : v + 0x41 - 10;
    }
    return 0x3f;
}

vec4 textP(in vec2 fragCoord)
{
    vec2 p = fragCoord / text_size;
    int row = int(p.y);
    int col = int(p.x);
    vec2 uv = fract(p);
    if (row > 0 || col >= 39) {
    	return vec4(0);    
    }
    int asc = 0x40;
    if (col % 5 == 4) {
        asc = 0x2d;
    } else {
    	int gr = col / 5;
        int char = (col % 5);
        int rule_index = get_rule_index_for_pos(iFrame, iMouse.xy, iResolution, iTime);
        vec4 word = texelFetch( iChannel2, ivec2(8 + gr, rule_index), 0)*256.0 + vec4(0.01);
        int v = int(word.x)*256 + int(word.y);
        int c = (v >> (4 * (3 - char))) & 0xf;
        asc = base16ToAscii(c);
    }
    vec4 tv = texture( iChannel3, getChar(uv, asc)).xxxx;
    tv.w = 0.7;
    return tv;
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float scale = 1.0;
    
    /*if (length(fragCoord - vec2(0, iResolution.y)) < min(iResolution.x, iResolution.y)*0.15) {
        scale = 0.25;
    }*/
    vec2 target = fragCoord * scale;
    if (length(fragCoord-iMouse.xy) < 128.0) {
        scale = 0.25;
        target = iMouse.xy + (fragCoord-iMouse.xy)*scale;
    }
    
    vec4 c0 = texelFetch( iChannel0, ivec2(target), 0);
    if (c0.w > 0.5) {
    	vec4 c1 = texelFetch( iChannel1, ivec2(target), 0);
        c0 = 0.5 * (c0 + c1);
    }
    fragColor = c0;
    vec4 text = textP(fragCoord);
    fragColor = text * text.w + (fragColor * (1.-text.w));
    //fragColor = fragColor.zzzz;
}