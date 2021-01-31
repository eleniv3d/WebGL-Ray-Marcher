// webgl link
precision mediump float;

uniform float time;
uniform vec2 resolution;
uniform float fractalIncrementer;

uniform float zHeight;
uniform float steps;

// Gyroid Marching
const float tau = 6.2831853072;
const float staticZ = 0.;

// function parameters
uniform vec2 gyroidScales;

// color scheme
uniform vec3 color1;
uniform vec3 color2;

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

vec3 GetNormal(vec3 p) {
	float d = GetDist(p);
    vec2 e = vec2(.01, 0);
    
    vec3 n = d - vec3(
        GetDist(p-e.xyy),
        GetDist(p-e.yxy),
        GetDist(p-e.yyx)
    );
    
    return -normalize(n);
    // return abs(normalize(n) );
}

vec3 colorFromDistance(float d) {
    vec3 color = mix(color1,color2,d * .5 + .5);

    return color;
}

void main()
{
    float d = GetDist(vec3(gl_FragCoord.xy, zHeight) ) * steps;
    float stepped = floor( (d * steps) );
    vec3 n = colorFromDistance(stepped / steps);

    gl_FragColor = vec4(n, 1.);
}