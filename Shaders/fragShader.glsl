#ifdef GL_ES
precision mediump float;
#endif

uniform sampler2D buffer;
uniform vec2 size;
uniform int nbStates;

void main() {
    vec4 v = texture2D(buffer, gl_FragCoord.xy / size);
    // "wrong" color tranformation to brighten the result a bit
    gl_FragColor = vec4(1.0 - v.rgb * float(255 / nbStates), 1.0);
}