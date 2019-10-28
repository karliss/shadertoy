//BUFFER B - calculate amount of water moving between neighbour cells

vec4 getv(vec2 p) {
	return texelFetch(iChannel0, ivec2(p), 0);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    if (iFrame  == 0) {
    	fragColor = vec4(0.);
    } else {
        vec2 p = fragCoord;
        float vp = getv(p).x;
        vec4 dv = vec4(
            getv(p + vec2(-1., 0.)).x,
            getv(p + vec2(0., -1.)).x,
            getv(p + vec2(1., 0.)).x,
            getv(p + vec2(0., 1.)).x
        );

        
        // atract to water in close area
        vec2 fd = vec2(0.);
        float size = vp;
        for (int dy=-R; dy<=R; dy++){
            for (int dx=-R; dx<=R; dx++) {
                if (dx == 0 && dy == 0 || (dx * dx + dy * dy > R * R)) {
                    continue;
                }

                float a = getv(p+vec2(dx, dy)).x;
                size += a;
                vec2 dir = vec2(dx, dy);
                vec2 ndir = normalize(dir);
                vec2 c= pow(a, 0.4)*0.25 * ndir / pow(length(dir),0.9);
                if (a > 0.06) {
                    c *= 2. + a*1.;
                }
                fd += c;
            }
        }
        // add gravity with tweaks to make smaller droplets stick
        vec2 down = vec2(0, -1.0)*10.81*vp;
        if (vp > 0.06) {
            down *= 1.+1.*pow(vp, 1.)+0.01*size;
        } else {
            down *= 0.05;
        }
        fd += down;

        vec4 dif = max(vec4(vp)-dv, 0.); // spread to neighbours that have less water
        if (p.x <= 1.) {
            dv.x = 0.;
        }
        if (p.y <= 1.) {
           dv.y = 0.;
        }
        dif *= 0.16;
        if (vp < 0.02) {
             dif *= 0.5;
        }

        vec4 fa = vec4(abs(min(fd.xy, 0.)), max(fd.xy, 0.)); //add force from attraction and gravity
        dif += fa * 0.008;
        dif *= 1.;

        // try to avoid going in to negative values or exceeding maximum
        float sm = dot(dif, vec4(1.));
        float red = sm == 0. ? 1.0 : min(vp, sm)/sm;
        dif *= red;
        dif = min(dif, vec4(1.)-dv);
        fragColor = dif;
    }
}