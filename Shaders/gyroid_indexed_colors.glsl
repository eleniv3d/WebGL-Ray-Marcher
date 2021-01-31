// webgl link
precision mediump float;

uniform float time;
uniform vec2 resolution;
uniform float fractalIncrementer;


// Gyroid Marching
const float tau = 6.2831853072;
const float staticZ = 0.;

// general transformation
uniform vec3 mvVec;
uniform float alpha;

// function parameters
uniform vec2 gyroidScales;
uniform float zHeight;
uniform float steps;

// color scheme
uniform vec3 color1;
uniform vec3 color2;
uniform vec3 color3;
uniform vec3 color4;
uniform vec3 color5;
uniform vec3 color6;
uniform vec3 color7;
uniform vec3 color8;
uniform vec3 color9;
uniform vec3 color10;

vec3[] colors = vec3[
    color1,
    color2,
    color3,
    color4,
    color5,
    color6,
    color7,
    color8,
    color9,
    color10,
]

float sdGyroid(vec3 p, float scale) {
    p *= scale;
    float d = dot(sin(p), cos(p.yzx) );
    d *= .3333;
	return d;
}

float GetDist(vec3 p) {
    float d_g = sdGyroid(p, gyroidScales.x * sdGyroid(p, gyroidScales.y) );

    return d_g;
}

float GetDist(vec3 p, float scaleA, float scaleB) {
    float d_g = sdGyroid(p, scaleB * sdGyroid(p, scaleA) );

    return d_g;
}

float GetDist(vec2 p) {
    return GetDist(vec3(p, staticZ));
}

vec3 colorFromDistance(float d) {
    int cIdx = int(float(floor( ( d * .5 + .5) * steps + .5 ) ) / steps);
    return colors[cIdx];
}

vec3 translate(vec3 p, vec3 mv) {
    return (p + mv);
}

vec3 translate(vec3 p) {
    return translate(p, mvVec);
}

vec3 rotate(vec3 p, float a) {
    return vec3(
        p.x * cos(a) - p.y * sin(a),
        p.x * sin(a) + p.y * cos(a),
        p.z
    );
}

vec3 rotate(vec3 p) {
    return rotate(p, alpha);
}

void main()
{
    vec3 p = translate( rotate( vec3(gl_FragCoord.xy, zHeight) ) );
    float d = GetDist(p);
    
    vec3 n = colorFromDistance(d * 2.);

    gl_FragColor = vec4(n, 1.);
}