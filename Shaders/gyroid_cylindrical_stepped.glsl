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
uniform vec3 mvVecUV;
uniform vec3 mvVecP;
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

// cylinder
uniform float cylinderMultiplierN;
uniform float cylinderMultiplierM;
uniform float cylinderRadiusBase;

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

// vec3 translate(vec3 p) {
//     return 
// }

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
    float r = cylinderRadiusBase+cos(pi+alfa*cylinderMultiplierM)*cos(pi+alfa*cylinderMultiplierN);
    r = r * pScales.z;
    vec3 v3 = vec3(cos(alfa)*r, sin(alfa)*r, uv.y*pScales.y);
    return v3;
}

vec3 translateForUV(vec3 p){
    p = translate( p, mvVecUV);
    return uvMapping(p.xy);
}

vec3 translateForDistance(vec3 p) {
    return translate( rotate( p ), mvVecP);
}

vec3 positionManagement(vec3 p){
    vec3 uv = translateForUV(p);
    return translateForDistance(uv);
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