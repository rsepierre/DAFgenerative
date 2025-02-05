import processing.svg.*;
import processing.pdf.*;
import processing.dxf.*;
// import nervoussystem.obj.*;

import java.util.*;
import java.io.IOException;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

import geomerative.*;
import controlP5.*;

import newpeasy.*;
PeasyCam camera;
double[] moveInput = new double[] { 0, 0, 0 };
PeasyDragHandler PanDragHandler;
float PANNING_SPEED=3;


int record = 0;

ControlP5 cp5;
ControlFrame controlFrame;
PGraphics renderer;

ShapeGenerator daf;
boolean isRendering;
RenderQueue renderQueue;

// Redimensionner
float scaling = 1;
void setScaling() { scaling = (float)width/2000*zoom; }

/* Controllable Variables */

// Zoom
float zoom = 1;

// File
String svgFiles[];
String povFiles[];
String sourceFile;

// Colors
color backgroundColor = color(0,0,0);
color innerStrokeColor = color(255, 255, 255);
color outerStrokeColor = color(255, 255, 255);

// StrokeWeight
float innerStrokeWidth = 1.5;
float outerStrokeWidth = 0;

// Alpha
float innerStrokeAlpha = 10;
float outerStrokeAlpha = 10;

// Curviness
float innerCurviness = 0.01;
float outerCurviness = 1;

// Generated Shape
float outerShapeScaling = 17;
float outerShapeTwistZ = 0;
float outerShapeTwistX = 0;
float outerShapeTwistY = 0;
float outerShapeCircleness = 0.4;

// Fills
boolean fillbg = true;
boolean fillshape = false;

// Waves
int nWaves = 4;
float waveLength = 5;
float waveScale = 1;
float waveSpeed = 0.5;

// Poygonizer
int subdivision = 0;

// Blending
int numberOfSteps = 15;
float blendingHeight = 100;

void draw() {
	if (frameCount == 10) { createControlFrame(); }

	isRendering = (renderQueue.modes.size() > 0);
	if(isRendering) {
		renderQueue.startRender();
	}

	noStroke();

	camera.beginHUD();
	camera.endHUD();

	translate(width/2, height/2);
	move();

	if (fillbg == true) { background(backgroundColor); }
	daf.render();

	if(isRendering) {
		renderQueue.saveRender();
	}
}

// Setup camera
void setCam() {
	camera = new PeasyCam(this, 0, 0, 0, height);
	camera.setViewport(0, 0, width, height);
	camera.feed();
}

// Detect Resize
int w, h;
void pre() {
	if (w != width || h != height) {
		w = width;
		h = height;
		setScaling();
		setCam();
		PanDragHandler = camera.getPanDragHandler();
		camera.setWheelHandler(null);
		camera.setRightDragHandler(PanDragHandler);
	}
}

// Create control Frame
void createControlFrame() {
	controlFrame = new ControlFrame(this, 847, 847, "Controls");
	controlFrame.getSurface().setLocation(25,25);
}

void settings() {
	size(1500, 1000, P3D);
}

void move() {
	camera.move(moveInput[0], moveInput[1], moveInput[2]);
}

void keyReleased() {
	if (key == CODED) {
		// reset X
		if(keyCode == LEFT || keyCode == RIGHT) { moveInput[0] = 0; }
		// reset y
		if(keyCode == UP || keyCode == DOWN) { moveInput[1] = 0; }
		// reset z
		if(keyCode == SHIFT) { moveInput[2] = 0; }
	} else {
		// reset z
		if (keyCode == 32) { moveInput[2] = 0; }
  }
}

void keyPressed() {
  if (key == CODED) {
	switch(keyCode) {
		// x
		case LEFT:
			moveInput[0] = -PANNING_SPEED;
		break;
		case RIGHT:
			moveInput[0] = PANNING_SPEED;
		break;
		// y
		case UP:
			moveInput[1] = -PANNING_SPEED;
		break;
		case DOWN:
			moveInput[1] = PANNING_SPEED;
		break;

		//z backward
		case SHIFT:
			moveInput[2] = PANNING_SPEED;
		break;
	}
  } else {
	  // z forward
	  if (keyCode == 32) {
		  moveInput[2] = -PANNING_SPEED;
	  }
  }
}

void setup() {
	// Settings
	surface.setResizable(true);
	registerMethod("pre", this);
	renderer = createGraphics(width, height, P3D);
	renderQueue = new RenderQueue();

	hint(DISABLE_ASYNC_SAVEFRAME);

	// Geomerative
	RG.init(this);
	RG.ignoreStyles(true);

	// ControlP5
	svgFiles = new File(sketchPath() + "/data").list();
	povFiles = new File(sketchPath() + "/pov").list();
	sourceFile = svgFiles[0];

	// Positions windows side by side
	surface.setLocation( (847+50), 25);
	
	// Camera 
	setCam();
	
	// DAF
	daf = new ShapeGenerator(sourceFile);
}
