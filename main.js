var mesh, timer, shaderProgram;

var color1 = new function() {
	this.r = 0.;
	this.g = 0.;
	this.b = 0.;
}

var color2 = new function() {
	this.r = 1.;
	this.g = 1.;
	this.b = 1.;
}

var scales = new function() {
    this.gyroidA = -1.00;
    this.gyroidB = 0.00;
}

var shader = new function() {
	this.type = "gyroid";
}

// start() is the main function that gets called first by index.html
var start = function() {
    
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
        1.0,  1.0,
        -1.0,  1.0,
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
var initCanvas = function() {
	canvas = document.getElementById('game-surface');
    gl = canvas.getContext('webgl2');   // WebGL 2

	gl.enable(gl.DEPTH_TEST);
    gl.enable(gl.BLEND);
    gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);

    var gui = new dat.GUI();

    var folder = gui.addFolder('color1');
	folder.add(color1, 'r', 0.0, 1.0);
    folder.add(color1, 'b', 0.0, 1.0);
    folder.add(color1, 'g', 0.0, 1.0);

    var folder2 = gui.addFolder('color2');
    folder2.add(color2, 'r', 0.0, 1.0);
    folder2.add(color2, 'b', 0.0, 1.0);
    folder2.add(color2, 'g', 0.0, 1.0);

    var folder3 = gui.addFolder('scales');
    folder3.add(scales, 'gyroidA', -3.00, 3.00);
    folder3.add(scales, 'gyroidB', -3.00, 3.00);

    var folder4 = gui.addFolder('shader');
	folder4.add(shader, 'type', ["gyroid", "mandelbulb", "spheres"]).onChange( function () {

		switchShader(shader)
	} );
}

var drawScene = function() {
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

    shaderProgram.SetUniform1f("gyroidA", Math.pow(10., scales.gyroidA) );
    shaderProgram.SetUniform1f("gyroidB", Math.pow(10., scales.gyroidB) );

    console.log(Math.pow(10., scales.gyroidA) );
    console.log(Math.pow(10., scales.gyroidB) );

    // Tell WebGL to draw the scene
    mesh.Draw();
}

//switch between different shaders

function switchShader() {

	if (shader.type == "mandelbulb"){
       frag = 'fragShader2' 
    }else if(shader.type == "gyroid"){
        frag = 'fragShader'
    }else if(shader.type =="spheres"){
        frag = 'fragShader3'
    }
    shaderProgram = new Shader('vertShader', frag);
    // Activate the shader program
    shaderProgram.UseProgram();

}


// resizes canvas to fit browser window
var resize = function(canvas) {
    // Lookup the size the browser is displaying the canvas.
    var displayWidth  = canvas.clientWidth;
    var displayHeight = canvas.clientHeight;

    // Check if the canvas is not the same size.
    if (canvas.width  !== displayWidth || canvas.height !== displayHeight) {
        // Make the canvas the same size
        canvas.width  = displayWidth;
        canvas.height = displayHeight;
        aspectRatio = displayWidth / displayHeight;
    }
}
