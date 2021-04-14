#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D buffer;
uniform vec2 size;
uniform int nbStates;
uniform int threshold;

void main() {
    float dx = 1.0 / size.x;
    float dy = 1.0 / size.y;

    vec2 uv = gl_FragCoord.xy / size;

    vec4 s = texture2D(buffer, uv);
    vec4 r = s;

    float ns;
    float n;

    ns = mod(s.r * 255.0 + 1.0, float(nbStates));
    n = 0.0;
    n += float(texture2D(buffer, mod(uv + vec2(dx,   0), 1.0)).r * 255.0 == ns);
    n += float(texture2D(buffer, mod(uv - vec2(dx,   0), 1.0)).r * 255.0 == ns);
    n += float(texture2D(buffer, mod(uv + vec2( 0,  dy), 1.0)).r * 255.0 == ns);
    n += float(texture2D(buffer, mod(uv - vec2( 0,  dy), 1.0)).r * 255.0 == ns);
    n += float(texture2D(buffer, mod(uv + vec2(dx,  dy), 1.0)).r * 255.0 == ns);
    n += float(texture2D(buffer, mod(uv - vec2(dx,  dy), 1.0)).r * 255.0 == ns);
    n += float(texture2D(buffer, mod(uv + vec2(dx, -dy), 1.0)).r * 255.0 == ns);
    n += float(texture2D(buffer, mod(uv - vec2(dx, -dy), 1.0)).r * 255.0 == ns);
    n += float(s.b * 255.0 == ns);
    if (n >= float(threshold)) {
        r.r = ns / 255.0;
    }

    ns = mod(s.g * 255.0 + 1.0, float(nbStates));
    n = 0.0;
    n += float(texture2D(buffer, mod(uv + vec2(dx,   0), 1.0)).g * 255.0 == ns);
    n += float(texture2D(buffer, mod(uv - vec2(dx,   0), 1.0)).g * 255.0 == ns);
    n += float(texture2D(buffer, mod(uv + vec2( 0,  dy), 1.0)).g * 255.0 == ns);
    n += float(texture2D(buffer, mod(uv - vec2( 0,  dy), 1.0)).g * 255.0 == ns);
    n += float(texture2D(buffer, mod(uv + vec2(dx,  dy), 1.0)).g * 255.0 == ns);
    n += float(texture2D(buffer, mod(uv - vec2(dx,  dy), 1.0)).g * 255.0 == ns);
    n += float(texture2D(buffer, mod(uv + vec2(dx, -dy), 1.0)).g * 255.0 == ns);
    n += float(texture2D(buffer, mod(uv - vec2(dx, -dy), 1.0)).g * 255.0 == ns);
    n += float(s.r * 255.0 == ns);
    if (n >= float(threshold)) {
        r.g = ns / 255.0;
    }

    ns = mod(s.b * 255.0 + 1.0, float(nbStates));
    n = 0.0;
    n += float(texture2D(buffer, mod(uv + vec2(dx,   0), 1.0)).b * 255.0 == ns);
    n += float(texture2D(buffer, mod(uv - vec2(dx,   0), 1.0)).b * 255.0 == ns);
    n += float(texture2D(buffer, mod(uv + vec2( 0,  dy), 1.0)).b * 255.0 == ns);
    n += float(texture2D(buffer, mod(uv - vec2( 0,  dy), 1.0)).b * 255.0 == ns);
    n += float(texture2D(buffer, mod(uv + vec2(dx,  dy), 1.0)).b * 255.0 == ns);
    n += float(texture2D(buffer, mod(uv - vec2(dx,  dy), 1.0)).b * 255.0 == ns);
    n += float(texture2D(buffer, mod(uv + vec2(dx, -dy), 1.0)).b * 255.0 == ns);
    n += float(texture2D(buffer, mod(uv - vec2(dx, -dy), 1.0)).b * 255.0 == ns);
    n += float(s.g * 255.0 == ns);
    if (n >= float(threshold)) {
        r.b = ns / 255.0;
    }

    gl_FragColor = r;
}