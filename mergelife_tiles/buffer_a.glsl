struct Rule {
   int[8] v;
};



float randv(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

Rule randRule(float extra)
{
    Rule r;
    for (int i=0; i<8; i++) {
    	r.v[i] = int(float(0x100) * randv(vec2(iTime + extra, i*5))) * 256 +
                 int(float(0x100) * randv(vec2(iTime + extra, 9+i*7)));
    }
    return r;
}

int[8] sortRule(int[8] base_rule)
{
    int a[8];
    for (int i=0; i<8; i++) {
        a[i] = (base_rule[i] << 8) + i;
    }
    for (int i=0; i<8; i++) {
        for (int j=0; j<7; j++) {
            if (a[j] > a[j+1]) {
                int t = a[j];
                a[j] = a[j+1];
                a[j+1] = t;
            }
        }
    }
    return a;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    if (int(fragCoord.x) < 16) {
        if (iFrame % rule_frames == 0){  
            if (int(fragCoord.y) == 0 || iFrame == 0) {
                int[8] rule = int[8](0xcb97, 0x6a74, 0x88c0, 0x28aa, 0x1b6a, 0x834b, 0x4fe8, 0x60ac);
                int rule_index = 3-int(fragCoord.y)+(iFrame / rule_frames);
                int rule_count = rules.length() / 8;
                if (random_rules && (rule_index >= rule_count) || (rule_index < 0)) {
                    rule = randRule(fragCoord.y).v;
                } else {
                    rule_index = rule_index % rule_count;
                    for (int j=0; j<8; j++) {
                        rule[j] = rules[rule_index * 8 + j];
                    }
                }
                int a[8] = sortRule(rule);
                int i = int(fragCoord.x);
                if (i < 8) {
                    int v= a[i];
                    fragColor = vec4(float((v >> 16) & 0xff)/255.0, float((v >> 8) & 0xff)/256.0, float((v >> 0) & 0xff)/256.00, 0 );
                } else {
                	int v= rule[i-8];
                    fragColor = vec4(float((v >> 8) & 0xff)/256.0, float((v >> 0) & 0xff)/256.0, 0, 0 );
                }
            } else {
                fragColor = texelFetch( iChannel0, ivec2(fragCoord)+ivec2(0, -1), 0 );
            }
        } else {
            ivec2 p = ivec2(fragCoord);
            fragColor = texelFetch( iChannel0, ivec2(fragCoord), 0 );
        }
    } else {
        fragColor = vec4(0);
    }
}