// webgl link
precision mediump float;

uniform float time;
uniform vec2 resolution;
uniform float fractalIncrementer;


// Gyroid Marching
const float tau = 6.2831853072;
const float pi = 3.1415926536;
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
    // float dRemap = float(floor( ( d * .5 + .5) * steps + .5 ) ) / steps;
    float dRemap = d * .5 + .5;
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

vec3 uvMapping(vec2 uv){
    float alfa = uv.x*pScales.x;
    float r = (1.5 + cos(pi + alfa*8.)) * pScales.z;
    vec3 v3 = vec3(cos(alfa)*r, sin(alfa)*r, uv.y*pScales.y);
    return v3;
}

void main()
{
    vec2 scaledVec = (gl_FragCoord.xy - resolution * .5) * globalScale;
    // scaledVec = scaledVec - mod(scaledVec, pixelResolution.xy);
    // p.z = p.z + zHeight;
    vec3 p = vec3(scaledVec, zHeight);
    
    p = translate( rotate( p ) );
    p = uvMapping(p.xy);
    
    float d = GetDist(p);
    
    vec3 n = colorFromDistance(d * 2.);

    gl_FragColor = vec4(n, 1.);
}