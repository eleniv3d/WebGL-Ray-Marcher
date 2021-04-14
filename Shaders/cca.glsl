// Cyclic Cellular Automata
// WHY does it fail on rules with states>5

#ifdef GL_ES
precision mediump float;
#endif

#extension GL_OES_standard_derivatives : enable

uniform float time;
uniform vec2 resolution;
uniform vec2 mouse;
uniform sampler2D backbuffer;

// 313 by David Griffeath
const int range=1; int threshold=3; int states=3; bool moore=true;
// Boiling by Jason Rampe
// int range=2; int threshold=2; int states=6; bool moore=false; 
// Bootstrap by David Griffeath
// int range=2; int threshold=11; int states=3; bool moore=true; 
// CCA by David Griffeath
// const int range=1; int threshold=1; int states=14; bool moore=false; 
// Cyclic Spirals by David Griffeath
// int range=3; int threshold=5; int states=8; bool moore=true; 
// Lava Lamp by Jason Rampe
// int range=3; int threshold=15; int states=3; bool moore=true; 
// Lava Lamp 2 by Jason Rampe
// int range=2; int threshold=10; int states=3; bool moore=true; 
// Maps by Mirek Wojtowicz
// int range=2; int threshold=3; int states=5; bool moore=false; 
// Stripes by Mirek Wojtowicz
// int range=3; int threshold=4; int states=5; bool moore=false; 

//returns passed cell state between 0 and 1
//uv is texture coordinates between 0 and 1
float getCell(vec2 uv) {
    //backbuffer alpha channel stores CA cell states
    return texture2D(backbuffer,uv).a;
}

void main( void ) {
    //poition is pixel location scaled to between 0 and 1
    vec2 position = gl_FragCoord.xy/resolution.xy;
    //uv is pixel coordinates
    vec2 uv = gl_FragCoord.xy;
    
    if(mouse.y>0.99){} else //cursor at top edge stops random cursor circle being drawn
    if ((time<0.5) || //first half a second shows random static
        (mouse.x>0.99) || //cursor at right edge randomizes screen
        (length(position-mouse) < 0.025)) //random pixel around mouse location
    {
        //rnd1 floating point between 0 and 1
        float rnd1 = mod(fract(sin(dot(position + time * 0.001, vec2(14.9898,78.233))) * 43758.5453), 1.0);
        //convert to integer between 0 and states-1
        int tmp = int(rnd1*float(states));
        //convert back to floating point between 0 and 1
        float shade=float(tmp)/float(states);
        gl_FragColor=vec4(shade,shade,shade,shade);
        return;
    }

    //cursor at left edge clears the screen
    if (mouse.x<0.01) {
        gl_FragColor=vec4(vec3(0.0),0.0);
        return;
    }

    //CCA
    int currentCellState = int(getCell(position)*float(states));
    int nextCellState = currentCellState + 1;
    if (nextCellState >= states) { nextCellState=0; }

    //count nunber of neighbor cells with a cell value of nextCellState
    int count = 0;
    //Moore neighborhood
    if (moore==true) {
        for (int y=-range; y<=range; y++) {
            for (int x=-range; x<=range; x++) {
                if (x==0 && y==0) {
                    //skip current cell
                } else {
                    vec2 offset=vec2(float(x)/resolution.x,float(y)/resolution.y);
                    int neighborCellState = int(getCell(position+offset)*float(states));
                    if ( neighborCellState == nextCellState) { 
                        count++; 
                    }
                }    
            } 
        }
    }
    //Von Neumann neighborhood
    if (moore==false) {
        for (int y=-range; y<=range; y++) {
            //int looprange = range-abs(y);
            //for (int x=-looprange; x<=looprange; x++) {
            for (int x=-range; x<=range; x++) {
				int looprange = int(int(range)-int(abs(float(y))));
				if (x<-looprange) { continue; }
				if (x>looprange) { continue; }
                if (x==0 && y==0) {
                    //skip current cell
                } else {
                    vec2 offset=vec2(float(x)/resolution.x,float(y)/resolution.y);
                    int neighborCellState = int(getCell(position+offset)*float(states));
                    if ( neighborCellState == nextCellState) { 
                        count++; 
                    }
                }    
            } 
        }
    }
    
    //update current cell based on count
    int cell;
    if (count>=threshold) {
        cell=nextCellState;
    } else {
        cell=currentCellState;
    }

    //color shading
    float shade=float(cell)/float(states);
    gl_FragColor = vec4(shade,shade,shade,shade);
}
