vec4 getv(vec2 p) {
	return texelFetch(iChannel0, ivec2(p), 0);
}


void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = fragCoord/iResolution.xy ;
    
    
  	vec4 a = texture(iChannel0, uv);
    vec3 dp = vec3(0.9, 0.9, 0)/iResolution.xyx;
    vec4 b = texture(iChannel0, uv+dp.xz);
    vec4 c = texture(iChannel0, uv+dp.zy);
    float dx = a.x-b.x;
    float dy = a.x-c.x;
    vec3 normal = normalize(vec3(vec2(dx, dy), 1.0));
    vec3 iray = normalize(vec3(fragCoord.xy-0.5*iResolution.xy, 1.2*iResolution.y));
    vec3 d1 = refract(iray, normal, 1.3);
   
                      
    vec4 im = texture(iChannel1, d1);
    vec3 it = im.xyz;
    float l = length(it);
    it *= 0.8;
    im.xyz = it;
    

   	vec4 v = getv(fragCoord * 1.);
    vec4 color = vec4(0.);
    if (v.x < 0.01) {
    	color = mix(vec4(0., 0., 0., 1.), vec4(1., 0., 0., 1.), smoothstep(0.0, 0.03, v.x));
    } else if (v.x < 0.1) {
    	color = mix(vec4(1., 0., 0., 1.), vec4(0., 1., 0., 1.), smoothstep(0.01, 0.1, v.x));
    } else {
        color = mix(vec4(0., 1., 0., 1.), vec4(0., 0., 1., 1.), smoothstep(0.1, 1.0, v.x));
    }
    
    
    fragColor = im;// +color;
    //fragColor = color;
}