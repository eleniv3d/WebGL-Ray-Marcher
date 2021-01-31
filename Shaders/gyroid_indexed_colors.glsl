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

// resolution
uniform vec3 pixelResolution;

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
    int cIdx = int(float(floor( ( d * .5 + .5) * steps + .5 ) ) );
    vec3 color;
    if (cIdx == 0) {
        color = color1;
    } else if (cIdx == 1) {
        color = color2;
    } else if (cIdx == 2) {
        color = color3;
    } else if (cIdx == 3) {
        color = color4;
    } else if (cIdx == 4) {
        color = color5;
    } else if (cIdx == 5) {
        color = color6;
    } else if (cIdx == 6) {
        color = color7;
    } else if (cIdx == 7) {
        color = color8;
    } else if (cIdx == 8) {
        color = color9;
    } else if (cIdx == 9) {
        color = color10;
    } else {
        color = vec3(1.0);
    }
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
    vec3 p = translate( rotate( vec3(gl_FragCoord.xy, zHeight) ) );
    p = p - mod(p, pixelResolution);
    float d = GetDist(p);
    
    vec3 n = colorFromDistance(d * 2.);

    gl_FragColor = vec4(n, 1.);
}