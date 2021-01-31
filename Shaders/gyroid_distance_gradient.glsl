// webgl link

precision mediump float;

uniform float time;
uniform vec2 resolution;
uniform float fractalIncrementer;


// Gyroid Marching
const float tau = 6.2831853072;
const float staticZ = 0.;

// function parameters
uniform float scaleGyroidA;
uniform float scaleGyroidB;

// const float scaleGyroidA = .02;
// const float scaleGyroidB = .5;

float sGA = .01;
float sGB = 1.;

// float sGA = scaleGyroidA;
// float sGB = scaleGyroidB;

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
    float d_g = sdGyroid(p, sGB * sdGyroid(p, sGA) );

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
    // vec2 uv = (gl_FragCoord.xy - .5 * resolution.xy) / resolution.y;
    // vec2 m = mouse.xy/ resolution.xy;

    // vec3 col = vec3(GetNormal(fragCoord) );
    
    float d = GetDist(vec3(gl_FragCoord.xy, 0), sGA, sGB);
    vec3 n = colorFromDistance(d);

    gl_FragColor = vec4(n, 1.);
}