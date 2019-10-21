
vec4 getV(in vec2 p){
    if (p.x < 0.001 || p.y < 0.001) return vec4(0);
	return texelFetch( iChannel0, ivec2(p), 0 )* vec4(iResolution.xy, 1.0, 1.0);
}

float rand(vec2 co){
  return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void sim_step( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 middle = SIZE * (fragCoord);
    bool mouseReset = iMouse.z > 0.0 && iMouse.x >= iResolution.x - 30.0 && iMouse.y >= iResolution.y - 30.0;
    if (iFrame == 0 || mouseReset) {
        ivec2 iv = ivec2(fragCoord);
        if ((iv.x + iv.y) %2 == 0 && iv.y % 2 == 0 && iv.y < H) {
    		fragColor = vec4((middle+ (rand(fragCoord)-0.5)* SIZE*0.25), 0, 0);
        } else {
        	fragColor = vec4(0); // -2.0*BALL_SIZE
        }
    } else {
        // check if ball needs to transition between cells
        vec4 v = vec4(0); 
        for (int x=-1; x<=1; x++) {
            for (int y=-1; y<=1; y++) {
                
                vec2 np = fragCoord + vec2(x,y);
                vec4 p = getV(np);
                v += float(trunc(middle/SIZE) == trunc(p.xy/SIZE)) * p;
            }
        }
        // movement calculations
        if (v.x > 0.0){
            
            vec2 dr = vec2(0);//vec2(0.0, -0.01);
            
            // collision checks
            float stress = 0.0;
            for (int x=-2; x<=2; x++) {
                for (int y=-2; y<=2; y++) {

                    if (x !=0 || y != 0) 
                    {
                        vec4 p = getV(fragCoord + vec2(x,y));
                        if (p.x > 0.0) {
                            vec2 d2 = (v - p).xy;
                            float l = length(d2);
                            float f = BALL_D - l;
                            if (l >= 0.001* BALL_SIZE &&  f > 0.0) {
                                float f2 = f / (BALL_D);
                                f2 +=  SQ_K*f2*f2;
                                f2 *= BALL_D;
                                vec2 force_part = E_FORCE * normalize(d2)*f2;
                                stress += abs(force_part.x)+abs(force_part.y);
                                dr += force_part;
                            }
                        }

                    }
                }
            }
            
            // force from mouse
            vec2 mouseDir = v.xy - iMouse.xy;
            float d2 = dot(mouseDir, mouseDir);
            dr += M * MOUSE_F *
                max(stress, 1.0) *
                float(iMouse.x > 30.0)*clamp(iMouse.z, 0.0, 1.0) * // mouse clicked outside zoom region
                mouseDir * BALL_SIZE / max(d2, 0.01); //  normalize(mouseDir) / (length(mouseDir)/BALL_SIZE)

            // movement calculation
            vec2 pos = v.xy;
            float damp_k = length(dr)>0.001? DAMP_K : 1.0; // don't apply damping to freely flying balls
            dr += G * M; // gravity
            vec2 vel = damp_k * v.zw + dr / M;
            vel = clamp(vel, vec2(-1.0), vec2(1.0));
            
            vec2 dpos = vel * VEL_LIMIT;

            
            pos += dpos;


            v = vec4(pos, vel);

            v = clamp(v, vec4(vec2(BALL_SIZE *(1.0 + sin(pos.y)*0.1),BALL_SIZE), vec2(-1.0)),
                      	 vec4(SIZE*iResolution.xy-vec2(BALL_SIZE), vec2(1.0)));


            fragColor = v; 
        } else {
        	fragColor = v;
        }
            
    }
	fragColor /= vec4(iResolution.xy, 1.0, 1.0);//vec4(fragColor.xy/iResolution.xy, f0, 0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    sim_step(fragColor, fragCoord);
}