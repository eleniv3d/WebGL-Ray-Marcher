#define MAX_STEPS 500
#define MAX_DIST 500.
#define SURF_DIST .001
#define TAU 6.283185
#define UNDERSTEP .5

// webgl parameters
precision mediump float;

uniform vec2 mousePosition;
uniform float time;
uniform vec2 resolution;
uniform float fractalIncrementer;

// function parameters
uniform vec3 fScales;
uniform float globalScale;
uniform vec3 pScales;

// movement vectors
uniform vec3 mvVec;

// colors
uniform vec3 color1;
uniform vec3 color2;
const float inverseMaxSteps = 1. / float(MAX_STEPS);
const float clampScale = 1.;
const float inverseClampScale = 1. / clampScale;
const vec3 lightPos = vec3(15.);

// brick parameters
uniform vec2 wL;
uniform vec2 th;
uniform float h;

uniform float a;
vec3 alphaCST = vec3(cos(a), sin(a), tan(a));

const vec4 sdPA = vec4(0,0,1,0);
vec4 sdPB = vec4(0,0,-1,h);

const float backgroundD = MAX_DIST*.5;
// const vec3 backgroundColor = vec3(0.07058823529411765, 0.0392156862745098, 0.5607843137254902);
// const vec3 objColor = vec3(0.6627450980392157, 0.06666666666666667, 0.00392156862745098);

// angle
vec3 pointTransformation(vec3 p){
    return vec3(p.x, p.z, -p.y);
}

float intersectSDF(float distA, float distB) {
    return max(distA, distB);
}
 
float unionSDF(float distA, float distB) {
    return min(distA, distB);
}
 
float differenceSDF(float distA, float distB) {
    return max(distA, -distB);
}

float sdRec(vec2 p, vec2 cPt) {
    vec2 q = abs(p)-cPt;
    return length(max(q,0.0)) + min(max(q.x,q.y),0.0);
}

float sdTaperedRec(vec3 p, vec2 cPt, vec3 alfaCST) {
    cPt-=vec2(-p.z*alfaCST.x);
    return sdRec(p.xy, cPt)*alfaCST.z;
}

float sdLine(vec2 p, vec2 a, vec2 b) {
    float d=distance(a, b);
    float l2 = d*d;
    if(l2 == 0.0) return d;
    
    vec2 b_a = b-a;
    float t = clamp(dot(p - a, b_a) / l2, 0., 1.);
    vec2 j = a + t * (b_a);
    
    return distance(p, j);
}

float sdLine(vec3 p, vec2 a, vec2 b) {
    return sdLine(p.xz, a, b);
}

float sdPlane(vec3 p, vec4 pln){
    return dot(p,pln.xyz) - pln.w;
}

mat2 Rot(float a) {
    float s = sin(a);
    float c = cos(a);
    return mat2(c, -s, s, c);
}

float sdCylinder( vec3 p, vec2 c, float th )
{
  return length(p.xz-c.xy)-th;
}

float smin(float a, float b, float k) {
    float h = clamp(.5  + .5 * (b - a) / k, .0, 1.);
    return mix(b, a, h) - k * h * (1.0 - h);
}

// float sdBands(vec3 p) {
//     float val = mod(p.y, doubleBH);
//     val -= bandHeight;
//     val = sqrt(squareBH - val * val);
//     return -val;
// }

float sdGyroid(vec3 p, float scale) {
    p *= scale;
    float d = dot(sin(p), cos(p.yzx) );
    d *= .3333;
	return d;
}

float sdCone( vec3 p, vec2 c )
{
    // c is the sin/cos of the angle
    vec2 q = vec2( length(p.xz), -p.y );
    float d = length(q-c*max(dot(q,c), 0.0));
    return abs(d * ((q.x*c.y-q.y*c.x<0.0)?-1.0:1.0));
}

float sdCookie(vec3 p) {
    // vec2 baseVec = vec2(5,2);

    float sdTR = sdTaperedRec(p, wL, alphaCST);
    float dBox = sdRec(p.xy, wL - vec2(th));
    
    float sdPA = sdPlane(p, sdPA);
    float sdPB = sdPlane(p, sdPB);

    float dP = -max(sdPA, sdPB);

    float d = min(dBox, sdTR);
    d = max(-dP, d);
    // d = max(sdPA, -d);
    // d = max(sdPB, -d);

    return d;
}

// float sdRoundCookie(vec3 p) {
//     float d=sdLine(p, cylinderA, cylinderB)-brickW;

//     float d_g=.3*sdGyroid(p, fScales.x*sdGyroid(p, fScales.y));
//     d+=d_g;
//     d=differenceSDF(d, d);

//     float d_t=sdPlane(p, planeTop);
//     d = intersectSDF(d, d_t);

//     d=unionSDF(sdCone(p - pinMidA, csVec), d);
//     d=unionSDF(sdCone(p - pinMidB, csVec), d);

//     float d_b=sdPlane(p, planeBottom);
//     float d_cb=sdPlane(p, planeConeTop);

//     d=intersectSDF(d, d_cb);
//     d=intersectSDF(d, d_b);

//     return d;
// }

float sdBox(vec3 p, vec3 bPt, vec3 cPt) {
    vec3 q = abs(p+bPt)-cPt;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sdBox(vec3 p, vec3 cPt) {
    vec3 q = abs(p)-cPt;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float GetDist(vec3 p) {
    p = pointTransformation(p)+mvVec;
    // return sdCookie(p);
    p*=globalScale;
    // float d=sdRoundCookie(p);
    // // d=unionSDF(sdCappedCone(p, pinBStart, pinBEnd, pinBottomR, pinTopR), d);

    // d+=sdBands(p);
    // return d*globalScale;
    
    return sdCookie(p);
}

float RayMarch(vec3 ro, vec3 rd) {
    float d0 = 0.;

    for (int i = 0; i < MAX_STEPS; i++) {
        vec3 p = ro + rd * d0;
        float dS = GetDist(p) * UNDERSTEP;
        d0 += dS;

        if (d0 > MAX_DIST || dS < SURF_DIST) break;
    }

    return d0;
}

vec3 GetNormal(vec3 p)
{
    float d=GetDist(p);// Distance
    vec2 e=vec2(.01,0);// Epsilon
    
    vec3 n=d-vec3(
        GetDist(p-e.xyy),// e.xyy is the same as vec3(.01,0,0). The x of e is .01. this is called a swizzle
        GetDist(p-e.yxy),
        GetDist(p-e.yyx));

    n=vec3(n.xz, -n.y);

    return normalize(n);
}

float GetLight(vec3 p)
{
    vec3 l=normalize(lightPos-p);// Light Vector
    vec3 n=GetNormal(p);// Normal Vector
     
    float dif=dot(n,l);// Diffuse light
    dif=clamp(dif,0.,1.);// Clamp so it doesnt go below 0
     
    // Shadows
    float d=RayMarch(p+n*SURF_DIST*2.,l);
     
    if(d<length(lightPos-p))dif*=.1;
     
    return dif;
}

vec3 R(vec2 uv, vec3 p, vec3 l, float z) {
    vec3 f = normalize(l - p),
        r = normalize(cross(vec3(0, 1, 0), f)),
        u = cross(f, r),
        c = p + f * z,
        i = c + uv.x * r + uv.y * u,
        d = normalize(i - p);
    return d;
}

void main()
{
    vec2 uv = (gl_FragCoord.xy - .5 * resolution.xy) / resolution.y;
    vec2 m = mousePosition / resolution.xy;

    vec3 ro = vec3(-5., 1., 5.);
    ro.yx *= Rot(-m.y);
    ro.xz *= Rot(-m.x);
    // ro.xz *= Rot(5.3 + m.x * TAU);

    vec3 rd = R(uv, ro, vec3(0), .58);
    float d = RayMarch(ro, rd);

    vec3 n;
    if (d < backgroundD) {
        // float l = GetLight(ro+d*rd);
        // n = 1.5*color2 * clamp(l, .5, 1.);
        n=abs(GetNormal(ro+d*rd));
    } else {
        n = color1;
    }

    gl_FragColor = vec4(n, 1.);
}