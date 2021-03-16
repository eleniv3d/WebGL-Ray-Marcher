#define MAX_STEPS 1000
#define MAX_DIST 500.
#define SURF_DIST .001
#define TAU 6.283185
#define UNDERSTEP .2

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

// interlock area
uniform vec3 rA;
uniform vec3 rB;
uniform float interlockThickness;

// geometry pairs in function of the thickness

// defining the base recs
vec2 recCAA = vec2(-rA.x*.5, rA.y);
vec2 recCAB = vec2(rA.x*.5, rA.y + rA.z);

vec2 rAcPt = vec2(0., rA.y - .5*rA.z);
vec2 rAC = recCAB - rAcPt;

vec2 recCBA = vec2(-rB.x*.5, rB.y);
vec2 recCBB = vec2(rB.x*.5, rB.y + rB.z);

vec2 rBcPt = .5 * (recCBA + recCBB);
vec2 rBC = recCBB - rBcPt;

float triH = (recCAA.y - recCBB.y) / (1. - rB.x/rA.x);
vec2 tcPt = vec2(0., rA.y-triH);
vec2 tC = vec2(rA.x*.5, triH);

float thicknessShift = interlockThickness / atan(tC.y / tC.x);

vec2 rAPosC = vec2(rAC.x + interlockThickness, rAC.y + interlockThickness);
vec2 rAPosCpt = vec2(rAcPt.x, rAcPt.y+thicknessShift*.5);
vec2 rBPosC = vec2(rBC.x + thicknessShift, rBC.y + interlockThickness + thicknessShift);
vec2 rBPosCpt = vec2(rBcPt.x, rBcPt.y + interlockThickness-thicknessShift);
vec2 tPosC = vec2(tC.x + interlockThickness, tC.y + 2. * thicknessShift);
vec2 tPosCpt = vec2(tcPt);
vec4 bPlnPos = vec4(0,1,0,-interlockThickness);

vec2 rANegC = vec2(rAC);
vec2 rANegCpt = vec2(rAcPt);
vec2 rBNegC = vec2(rBC);
vec2 rBNegCpt = vec2(rBcPt);
vec2 tNegC = vec2(tC);
vec2 tNegCpt = vec2(tcPt);
vec4 bPlnNeg = vec4(0,1,0,interlockThickness);

// offsetting all the points
// rAPosCpt=vec2(rAPosCpt.x, rAPosCpt.y+thicknessShift*.5);
// rAPosC+=vec2(interlockThickness);
// rBPosC+=vec2(thicknessShift, interlockThickness + thicknessShift);
// tPosC+=vec2(interlockThickness, 2. * thicknessShift);

// rANegCpt.y-=thicknessShift*.5;
// rANegC-=vec2(interlockThickness);
// rBNegCpt.y-=interlockThickness-thicknessShift;
// rBNegC-=vec2(thicknessShift, interlockThickness + thicknessShift);
// tNegC-=vec2(interlockThickness, 2. * thicknessShift);

// geoFromRecs(recA, recB, interlockThickness, rANegC, rANegCpt, rBNegC, rBNegCpt, tNegCpt, tNegC, bPlnNeg);

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

float sdCapsule( vec3 p, vec3 a, vec3 b, float r )
{
  vec3 pa = p - a, ba = b - a;
  float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
  return length( pa - ba*h ) - r;
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

float sdTriangleIsosceles(in vec2 p, in vec2 q)
{
    p.x = abs(p.x);
    vec2 a = p - q*clamp( dot(p,q)/dot(q,q), 0.0, 1.0 );
    vec2 b = p - q*vec2( clamp( p.x/q.x, 0.0, 1.0 ), 1.0 );
    float s = -sign( q.y );
    vec2 d = min( vec2( dot(a,a), s*(p.x*q.y-p.y*q.x) ),
                  vec2( dot(b,b), s*(p.y-q.y)  ));
    return -sqrt(d.x)*sign(d.y);
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

float sdCookieSplit(vec3 p) {
    float dPlane = sdPlane(p, bPlnPos);
    float dRecA = sdRec(p.xy - rAPosCpt, rAPosC);
    float dRecB = sdRec(p.xy - rBPosCpt, rBPosC);
    float dTri = sdTriangleIsosceles(p.xy - tNegCpt, tNegC);

    // float d = min(min(dPlane, dTri), min(dRecA, dRecB));
    float d = min(dRecA, dRecB);
    // d = min(dTri, d);
    // return d;
    // return min(dPlane, dTri);
    return dTri;
}

float sdSchwarP(vec3 p, float scale) {
    p *= scale;
    p = cos(p);
    float d = p.x + p.y + p.z;
    d *= .3333;
    return d;
}

float sdSchwarD(vec3 p, float scale) {
    p *= scale;
    vec3 s = sin(p);
    vec3 c = cos(p);

    float d = (
        s.x * s.y * c.z + 
        s.x * c.y * c.z + 
        c.x * s.y * c.z + 
        c.x * c.y * s.z 
    );

    d *= .25;

    return d;
}

float sdPattern(vec3 p) {
    p -= pScales;
    float d_g = sdGyroid(p, fScales.x * sdGyroid(p, fScales.y));// * sdSchwarD(p, fScales.z)));
    return d_g;
}

float sdCookie(vec3 p) {
    // vec2 baseVec = vec2(5,2);

    float sdTR = sdTaperedRec(p, wL, alphaCST);
    float dBox = sdRec(p.xy, wL - vec2(th));
    
    float sdPA = sdPlane(p, sdPA);
    float sdPB = sdPlane(p, sdPB);

    float dP = -max(sdPA, sdPB);
    float dPat = sdPattern(p);

    float d = min(dBox, sdTR);
    // float d = sdCookieSplit(p);
    d = max(-dP, max(d, -dPat));
    // d = max(sdPA, -d);
    // d = max(sdPB, -d);

    return d;
}

float GetDist(vec3 p) {
    p = pointTransformation(p)+mvVec;
    // return sdCookie(p);
    p*=globalScale;
    // float d=sdRoundCookie(p);
    // // d=unionSDF(sdCappedCone(p, pinBStart, pinBEnd, pinBottomR, pinTopR), d);

    // d+=sdBands(p);
    // return d*globalScale;
    
    // return max(sdCookie(p), -sdCookieSplit(p));
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