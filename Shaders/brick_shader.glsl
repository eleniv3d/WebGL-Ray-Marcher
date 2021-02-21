#define MAX_STEPS 500
#define MAX_DIST 200.
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

// colors
uniform vec3 color1;
uniform vec3 color2;
const float inverseMaxSteps = 1. / float(MAX_STEPS);
const float clampScale = 1.;
const float inverseClampScale = 1. / clampScale;
const vec3 lightPos = vec3(15.);

const float bandHeight = .02;
const float doubleBH = bandHeight * 2.;
const float squareBH = bandHeight * bandHeight;

const float pinSpacing = 2.;
const float pinHeight = 3.;
const float tolerance = .01;
const float pinBottomR = .2;
const float pinTopR = .1;

const float brickL = 2.;
const float brickW = 1.;
const float brickH = 2.;

const vec3 pinAStart = vec3(-.5*pinSpacing,-.5*brickL,0);
const vec3 pinAEnd = vec3(-.5*pinSpacing,pinHeight-.5*brickL,0);
const vec3 pinBStart = vec3(.5*pinSpacing,-.5*brickL,0);
const vec3 pinBEnd = vec3(.5*pinSpacing,pinHeight-.5*brickL,0);

const vec2 cylinderA = vec2(-.5*brickL,0);
const vec2 cylinderB = vec2(.5*brickL,0);

const vec4 planeMain = vec4(0.,0.,1.,0);
const vec4 planeSecA = vec4(-1.0,0.,0.,.5*brickL);
const vec4 planeSecB = vec4(1.0,0.,0.,.5*brickL);

const vec4 planeBottom = vec4(0.,-1.,0.,.5*brickH);
const vec4 planeTop = vec4(0.,1.,0,.5*brickH);
const vec4 planeConeTop = vec4(0.,1.,0,pinHeight-.5*brickH);

const vec4 b_pln = vec4(.0, 0., 1., 10.);
const vec4 b_pln_ref = vec4(.0, 0., 1., 9.0);

const float backgroundD = MAX_DIST*.5;
const vec3 backgroundColor = vec3(0.07058823529411765, 0.0392156862745098, 0.5607843137254902);
const vec3 objColor = vec3(0.6627450980392157, 0.06666666666666667, 0.00392156862745098);

const float tang = pinHeight / (pinBottomR - pinTopR);
const float delta = tang * pinBottomR;
const float angle = atan(tang);
const vec2 csVec = vec2(cos(angle), sin(angle));

const vec3 pinMidA = vec3(-.5*pinSpacing,delta-.5*brickL,0);
const vec3 pinMidB = vec3( .5*pinSpacing,delta-.5*brickL,0);

float intersectSDF(float distA, float distB) {
    return max(distA, distB);
}
 
float unionSDF(float distA, float distB) {
    return min(distA, distB);
}
 
float differenceSDF(float distA, float distB) {
    return max(distA, -distB);
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

float sdBands(vec3 p) {
    float val = mod(p.y, doubleBH);
    val -= bandHeight;
    val = sqrt(squareBH - val * val);
    return -val;
}

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
    float d=sdLine(p, cylinderA, cylinderB)-brickW;

    float d_g=.3*sdGyroid(p, fScales.x*sdGyroid(p, fScales.y));
    d+=d_g;
    d=differenceSDF(d, d);

    float d_t=sdPlane(p, planeTop);
    d = intersectSDF(d, d_t);

    d=unionSDF(sdCone(p - pinMidA, csVec), d);
    d=unionSDF(sdCone(p - pinMidB, csVec), d);

    float d_b=sdPlane(p, planeBottom);
    float d_cb=sdPlane(p, planeConeTop);

    d=intersectSDF(d, d_cb);
    d=intersectSDF(d, d_b);

    return d;
}

float GetDist(vec3 p) {
    // return sdCookie(p);
    p*=globalScale;
    float d=sdCookie(p);
    // d=unionSDF(sdCappedCone(p, pinBStart, pinBEnd, pinBottomR, pinTopR), d);

    d+=sdBands(p);
    return d*globalScale;
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

    vec3 ro = vec3(5., 1., 0.);
    ro.yx *= Rot(-m.y);
    ro.xz *= Rot(-m.x);
    // ro.xz *= Rot(5.3 + m.x * TAU);

    vec3 rd = R(uv, ro, vec3(0), .58);
    float d = RayMarch(ro, rd);

    vec3 n;
    if (d < backgroundD) {
        float l = GetLight(ro+d*rd);
        n = color2 * clamp(l, .5, 1.);
    } else {
        n = color1;
    }
    

    gl_FragColor = vec4(n, 1.);
}