var mesh, timer, shaderProgram;

var params = new function() {
    this.color1 = { h:10, s:1., v:0.8 };
    this.color2 = { h:100, s:0.7, v:0.7 };
    this.color3 = { h:50, s:1., v:0.8 };
    this.color4 = { h:200, s:0.7, v:0.7 };
    this.color5 = { h:80, s:1., v:0.8 };
    this.color6 = { h:300, s:0.7, v:0.7 };
    this.color7 = { h:140, s:1., v:0.8 };
    this.color8 = { h:60, s:0.7, v:0.7 };
    this.color9 = { h:240, s:1., v:0.8 };
    this.color10 = { h:160, s:0.7, v:0.7 };
};

color1 = HSVtoRGB(params.color1);
color2 = HSVtoRGB(params.color2);
color3 = HSVtoRGB(params.color3);
color4 = HSVtoRGB(params.color4);
color5 = HSVtoRGB(params.color5);
color6 = HSVtoRGB(params.color6);
color7 = HSVtoRGB(params.color7);
color8 = HSVtoRGB(params.color8);
color9 = HSVtoRGB(params.color9);
color10 = HSVtoRGB(params.color10);

var scales = new function () {
    this.gyroidA = -1.80;
    this.gyroidB = -1.00;
    this.zHeight = 0.;
}

var abstractionLevel = new function () {
    this.steps = 8;
    this.resolution = 1.;
}

var transformation = new function() {
    this.x = 0.0;
    this.y = 0.0;
    this.z = 0.0;
    this.rz = 0.0;
}

function powF(value) {
    return Math.pow(10., value) - 1.0;
}

var shader = new function() {
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

    var folder = gui.addFolder('colors');
    hsv1 = folder.addColor(params, 'color1');
    hsv2 = folder.addColor(params, 'color2');
    hsv3 = folder.addColor(params, 'color3');
    hsv4 = folder.addColor(params, 'color4');
    hsv5 = folder.addColor(params, 'color5');
    hsv6 = folder.addColor(params, 'color6');
    hsv7 = folder.addColor(params, 'color7');
    hsv8 = folder.addColor(params, 'color8');
    hsv9 = folder.addColor(params, 'color9');
    hsv10 = folder.addColor(params, 'color10');

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

    hsv2.onChange(function(value) {        
        bg = HSVtoRGB(value);
        color3.r = bg[0];
        color3.g = bg[1];
        color3.b = bg[2];
    });

    hsv2.onChange(function(value) {        
        bg = HSVtoRGB(value);
        color4.r = bg[0];
        color4.g = bg[1];
        color4.b = bg[2];
    });

    hsv2.onChange(function(value) {        
        bg = HSVtoRGB(value);
        color5.r = bg[0];
        color5.g = bg[1];
        color5.b = bg[2];
    });

    hsv2.onChange(function(value) {        
        bg = HSVtoRGB(value);
        color6.r = bg[0];
        color6.g = bg[1];
        color6.b = bg[2];
    });

    hsv2.onChange(function(value) {        
        bg = HSVtoRGB(value);
        color7.r = bg[0];
        color7.g = bg[1];
        color7.b = bg[2];
    });

    hsv2.onChange(function(value) {        
        bg = HSVtoRGB(value);
        color8.r = bg[0];
        color8.g = bg[1];
        color8.b = bg[2];
    });

    hsv2.onChange(function(value) {        
        bg = HSVtoRGB(value);
        color9.r = bg[0];
        color9.g = bg[1];
        color9.b = bg[2];
    });

    hsv2.onChange(function(value) {        
        bg = HSVtoRGB(value);
        color10.r = bg[0];
        color10.g = bg[1];
        color10.b = bg[2];
    });

    var folder3 = gui.addFolder('scales');
    folder3.add(scales, 'gyroidA', -3.00, 3.00);
    folder3.add(scales, 'gyroidB', -3.00, 3.00);
    folder3.add(scales, 'zHeight', -1000.00, 1000.00);

    var folder4 = gui.addFolder('moving');
    folder4.add(transformation, 'x', 0., 5.);
    folder4.add(transformation, 'y', 0., 5.);
    folder4.add(transformation, 'z', 0., 5.);
    folder4.add(transformation, 'rz', -3.1415927, 3.1415927);

    var folder5 = gui.addFolder('shader');
	folder5.add(shader, 'type', [
        "gyroid",
        "mandelbulb",
        "spheres",
        "clouded",
        "indexedGyroid"
    ]).onChange( function () {

		switchShader(shader)
    } );
    
    var folder6 = gui.addFolder('abstraction level');
    folder6.add(abstractionLevel, 'resolution', 1, 10);
    folder6.add(abstractionLevel, 'steps', 2, 10);
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
    shaderProgram.SetUniformColor("color3", color3);
    shaderProgram.SetUniformColor("color4", color4);
    shaderProgram.SetUniformColor("color5", color5);
    shaderProgram.SetUniformColor("color6", color6);
    shaderProgram.SetUniformColor("color7", color7);
    shaderProgram.SetUniformColor("color8", color8);
    shaderProgram.SetUniformColor("color9", color9);
    shaderProgram.SetUniformColor("color10", color10);

    shaderProgram.SetUniformVec2("gyroidScales", [
        Math.pow(10., scales.gyroidA),
        Math.pow(10., scales.gyroidB)
    ]);

    shaderProgram.SetUniform1f("zHeight", scales.zHeight);
    shaderProgram.SetUniform1f("steps", Math.round(abstractionLevel.steps) - 1. );
    shaderProgram.SetUniformVec3("pixelResolution", [
        abstractionLevel.resolution, 
        abstractionLevel.resolution, 
        abstractionLevel.resolution
    ] );
    
    shaderProgram.SetUniform1f("alpha", transformation.rz);
    shaderProgram.SetUniformVec3("mvVec", [Math.pow(10., transformation.x), Math.pow(10., transformation.y), Math.pow(10., transformation.z) ]);

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
    } else if (shader.type == "indexedGyroid") {
        frag = 'fragShader5'
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
    h = h/360.;
    i = Math.floor(h * 6.);
    f = h * 6. - i;
    p = v * (1. - s);
    q = v * (1. - f * s);
    t = v * (1. - (1. - f) * s);
    switch (i % 6.) {
        case 0: r = v, g = t, b = p; break;
        case 1: r = q, g = v, b = p; break;
        case 2: r = p, g = v, b = t; break;
        case 3: r = p, g = q, b = v; break;
        case 4: r = t, g = p, b = v; break;
        case 5: r = v, g = p, b = q; break;
    }
    // return an array for use in p5js
    return new function () {
        this.r = r;
        this.g = g;
        this.b = b;
    }
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
