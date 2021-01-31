var mesh, timer, shaderProgram;

var params = {};
params.color1 = { h:251, s:0.3, v:0.8 };
array1 = HSVtoRGB(params.color1);

params.color2 = { h:342, s:0.7, v:0.7 };
array2 = HSVtoRGB(params.color2);

var color1 = new function () {
    this.r = array1[0];
    this.g = array1[1];
    this.b = array1[2];
}

var color2 = new function () {
    this.r = array2[0];
    this.g = array2[1];
    this.b = array2[2];
}

var scales = new function () {
    this.gyroidA = -1.80;
    this.gyroidB = -1.00;
    this.zHeight = 0.;
    this.steps = 8;
}

var shader = new function () {
    this.type = "gyroid";
}

// start() is the main function that gets called first by index.html
var start = function () {

    // Initialize the WebGL 2.0 canvas
    initCanvas();

    // Create timer that will be used for fragment shader
    timer = new Timer();

    // Read in, compile, and create a shader program
    shaderProgram = new Shader('vertShader', 'fragShader');
    // Activate the shader program
    shaderProgram.UseProgram();

    // Set vertices of the mesh to be the canonical screen space
    var vertices = [
        -1.0, -1.0,
        1.0, 1.0,
        -1.0, 1.0,
        1.0, -1.0
    ];

    // Set indices for the vertices above
    var indices = [2, 0, 1,
        1, 0, 3];

    // Create a mesh based upon the defined vertices and indices
    mesh = new Mesh(vertices, indices, shaderProgram);

    // Render the scene
    drawScene();
};

// starts the canvas and gl
var initCanvas = function () {
    canvas = document.getElementById('game-surface');
    gl = canvas.getContext('webgl2');   // WebGL 2

    gl.enable(gl.DEPTH_TEST);
    gl.enable(gl.BLEND);
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

    // btn = document.getElementById("save");
    // btn.addEventListener('click', saveTIFF);

    var gui = new dat.GUI();

    hsv1 = gui.addColor(params, 'color1');
    hsv2 = gui.addColor(params, 'color2');

    hsv1.onChange(function(value) {        
        bg = HSVtoRGB(value);
        color1.r = bg[0];
        color1.g = bg[1];
        color1.b = bg[2];

    });

    hsv2.onChange(function(value) {        
        bg = HSVtoRGB(value);
        color2.r = bg[0];
        color2.g = bg[1];
        color2.b = bg[2];
    });

    var folder3 = gui.addFolder('scales');
    folder3.add(scales, 'gyroidA', -3.00, 3.00);
    folder3.add(scales, 'gyroidB', -3.00, 3.00);
    folder3.add(scales, 'zHeight', -1000.00, 1000.00);
    folder3.add(scales, 'steps', 2, 10);

    folder3.open()

    var folder4 = gui.addFolder('shader');
    folder4.add(shader, 'type', ["gyroid", "mandelbulb", "spheres", "clouded"]).onChange(function () {

        switchShader(shader)
    });

    // var link = document.createElement( 'a' );
    // link.style.display = 'none';
    // document.body.appendChild( link );

}

var drawScene = function () {
    normalSceneFrame = window.requestAnimationFrame(drawScene);

    // Adjust scene for any canvas resizing
    resize(gl.canvas);
    // Update the viewport to the current canvas size
    gl.viewport(0, 0, gl.canvas.width, gl.canvas.height);

    // Set background color to sky blue, used for debug purposes
    gl.clearColor(0.53, 0.81, 0.92, 1.0);
    gl.clear(gl.COLOR_BUFFER_BIT | gl.DEPTH_BUFFER_BIT);

    // Update the timer
    timer.Update();


    // Set uniform values of the fragment shader
    shaderProgram.SetUniformVec2("resolution", [gl.canvas.width, gl.canvas.height]);
    shaderProgram.SetUniform1f("time", timer.GetTicksInRadians());
    shaderProgram.SetUniform1f("fractalIncrementer", timer.GetFractalIncrement());

    shaderProgram.SetUniformColor("color1", color1);
    shaderProgram.SetUniformColor("color2", color2);

    shaderProgram.SetUniformVec2("gyroidScales", [
        Math.pow(10., scales.gyroidA),
        Math.pow(10., scales.gyroidB)
    ]);

    shaderProgram.SetUniform1f("zHeight", scales.zHeight);
    shaderProgram.SetUniform1f("steps", Math.round(scales.steps) - 1. );
    
    console.log("steps : " + (Math.round(scales.steps) - 1.) );

    // shaderProgram.SetUniform1f("gyroidA", Math.pow(10., scales.gyroidA) );
    // shaderProgram.SetUniform1f("gyroidB", Math.pow(10., scales.gyroidA) );

    // console.log(Math.pow(10., scales.gyroidA) );
    // console.log(Math.pow(10., scales.gyroidB) );

    // Tell WebGL to draw the scene
    mesh.Draw();
}

//switch between different shaders

function switchShader() {

    if (shader.type == "mandelbulb") {
        frag = 'fragShader2'
    } else if (shader.type == "gyroid") {
        frag = 'fragShader'
    } else if (shader.type == "spheres") {
        frag = 'fragShader3'
    } else if (shader.type == "clouded") {
        frag = 'fragShader4'
    }
    shaderProgram = new Shader('vertShader', frag);
    // Activate the shader program
    shaderProgram.UseProgram();

}

// function saveTIFF() {
//     var canvas = document.getElementById('game-surface');

//     canvas.toBlob(function (blob) {
//         var newImg = document.createElement("img"),
//             url = URL.createObjectURL(blob);

//         newImg.onload = function () {
//             // no longer need to read the blob so it's revoked
//             URL.revokeObjectURL(url);
//         };

//         newImg.src = url;
//         document.body.appendChild(newImg);
//         //window.location.href = "img";
//     });
// }

function HSVtoRGB(h, s, v) {
    var r, g, b, i, f, p, q, t;
    if (arguments.length === 1) {
        s = h.s, v = h.v, h = h.h;
    }
    // adjust to match p5 format
    h = h/360;
    i = Math.floor(h * 6);
    f = h * 6 - i;
    p = v * (1 - s);
    q = v * (1 - f * s);
    t = v * (1 - (1 - f) * s);
    switch (i % 6) {
        case 0: r = v, g = t, b = p; break;
        case 1: r = q, g = v, b = p; break;
        case 2: r = p, g = v, b = t; break;
        case 3: r = p, g = q, b = v; break;
        case 4: r = t, g = p, b = v; break;
        case 5: r = v, g = p, b = q; break;
    }
    // return an array for use in p5js
    return [
        Math.round(r),
        Math.round(g),
        Math.round(b)];
}

// resizes canvas to fit browser window
var resize = function (canvas) {
    // Lookup the size the browser is displaying the canvas.
    var displayWidth = canvas.clientWidth;
    var displayHeight = canvas.clientHeight;

    // Check if the canvas is not the same size.
    if (canvas.width !== displayWidth || canvas.height !== displayHeight) {
        // Make the canvas the same size
        canvas.width = displayWidth;
        canvas.height = displayHeight;
        aspectRatio = displayWidth / displayHeight;
    }
}
