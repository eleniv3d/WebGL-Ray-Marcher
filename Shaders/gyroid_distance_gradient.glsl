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
uniform vec3 fScales;
uniform vec3 pScales;
uniform float zHeight;
uniform float steps;

// color scheme
uniform vec3 color1;
uniform vec3 color2;

// resolution
uniform vec3 pixelResolution;
uniform float globalScale;

float sdGyroid(vec3 p, float scale) {
    p *= scale;
    float d = dot(sin(p), cos(p.yzx) );
    d *= .3333;
	return d;
}

float GetDist(vec3 p) {
    float d_g = sdGyroid(p, fScales.x * sdGyroid(p, fScales.y) );
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
    float dRemap = float(floor( ( d * .5 + .5) * steps + .5 ) ) / steps;
    vec3 color = mix(color1,color2, dRemap );

    return color;
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
    vec3 p = vec3(gl_FragCoord.xy, zHeight);
    p = p - mod(p, pixelResolution / globalScale);
    p = translate( rotate( p ) );
    
    float d = GetDist(p * globalScale);
    
    vec3 n = colorFromDistance(d * 2.);

    gl_FragColor = vec4(n, 1.);
}