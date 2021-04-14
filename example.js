"use strict";

var gl;
var quadBuf;
var programInfo = {};
var fbInfo = [];
var currTex = 0;
var attachments;
var running = true;
var uniforms = {
    buffer: null,
    size: null,
    nbStates: 7,
    threshold: 2,
};

// fill the current texture with random data
function randomizeCurrTex() {
    var w = gl.drawingBufferWidth;
    var h = gl.drawingBufferHeight;
    var len = w * h * 4;
    var data = new Uint8Array(len);
    while (len--) {
        data[len] = Math.random() * uniforms.nbStates;
    }
    gl.bindTexture(gl.TEXTURE_2D, fbInfo[currTex].attachments[0]);
    gl.texImage2D(gl.TEXTURE_2D, 0, gl.RGBA, w, h, 0, gl.RGBA, gl.UNSIGNED_BYTE, data);
}

function init() {
    var canvas = document.getElementById("canvas");
    canvas.width = canvas.clientWidth;
    canvas.height = canvas.clientHeight;

    gl = canvas.getContext("webgl");

    var arrays = {
        position: {
            numComponents: 2,
            data: new Float32Array([-1.0, -1.0, 1.0, -1.0, -1.0, 1.0, 1.0, 1.0]),
        }
    };
    quadBuf = twgl.createBufferInfoFromArrays(gl, arrays);

    var createProgramInfo = function(frag) {
        var p = twgl.createProgramFromScripts(gl, ["vert-passthrough", "frag-" + frag]);
        return twgl.createProgramInfoFromProgram(gl, p);
    }
    programInfo.display = createProgramInfo("display");
    programInfo.update = createProgramInfo("update");

    attachments = [{ format: gl.RGBA }];
    fbInfo.push(twgl.createFramebufferInfo(gl, attachments));
    fbInfo.push(twgl.createFramebufferInfo(gl, attachments));

    randomizeCurrTex();

    var gui = new dat.GUI();
    gui.close();
    gui.add(uniforms, 'nbStates', 3, 12, 1).onChange(randomizeCurrTex);
    gui.add(uniforms, 'threshold', 2, 4, 1).onChange(randomizeCurrTex);
    gui.add(window, 'running').onChange(animate);
}

function animate() {
    if (!running) {
        return;
    }

    window.requestAnimationFrame(animate, gl.canvas);

    if (twgl.resizeCanvasToDisplaySize(gl.canvas)) {
        twgl.resizeFramebufferInfo(gl, fbInfo[0], attachments);
        twgl.resizeFramebufferInfo(gl, fbInfo[1], attachments);
        randomizeCurrTex();
    }

    gl.viewport(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight);
    uniforms.size = [gl.drawingBufferWidth, gl.drawingBufferHeight];

    // update automata
    uniforms.buffer = fbInfo[currTex].attachments[0];
    currTex = (currTex + 1) % 2;

    gl.bindFramebuffer(gl.FRAMEBUFFER, fbInfo[currTex].framebuffer);
    gl.useProgram(programInfo.update.program);
    twgl.setBuffersAndAttributes(gl, programInfo.display, quadBuf);
    twgl.setUniforms(programInfo.update, uniforms);
    twgl.drawBufferInfo(gl, quadBuf, gl.TRIANGLE_STRIP);

    // render on screen
    uniforms.buffer = fbInfo[currTex].attachments[0];

    gl.bindFramebuffer(gl.FRAMEBUFFER, null);
    gl.useProgram(programInfo.display.program);
    twgl.setBuffersAndAttributes(gl, programInfo.update, quadBuf);
    twgl.setUniforms(programInfo.display, uniforms);
    twgl.drawBufferInfo(gl, quadBuf, gl.TRIANGLE_STRIP);
}

init();
animate();