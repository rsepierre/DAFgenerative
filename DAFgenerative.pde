import processing.svg.*;
import processing.dxf.*;
import processing.pdf.*;
// import nervoussystem.obj.*;

import java.util.*;
import java.io.IOException;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

import geomerative.*;
import controlP5.*;
import peasy.*;

PeasyCam camera;
int record = 0;

ControlP5 cp5;
ControlFrame controlFrame;
PGraphics renderer;

Wavizator daf;
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
	isRendering = (renderQueue.modes.size() > 0);
	int currentHeight = height;
	int currentWidth = width;
	if(isRendering) {
		renderQueue.startRender();
	}

	background(backgroundColor);
	translate(width/2, height/2);
	daf.render();

	if(isRendering) {
		renderQueue.saveRender();
	}
}

// Setup camera
void setCam() {
	camera = new PeasyCam(this, width/2, height/2, 0, height);
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
	}
}

void settings() {
	size(1500, 1000, P3D);
	pixelDensity(displayDensity());
}

void setup() {
	// Settings
	surface.setResizable(true);
	registerMethod("pre", this);
	renderer = createGraphics(3000, 2000, P3D);
	renderQueue = new RenderQueue();

	hint(DISABLE_ASYNC_SAVEFRAME);

	// Geomerative
	RG.init(this);
	RG.ignoreStyles(true);

	// ControlP5
	svgFiles = new File(sketchPath() + "/data").list();
	povFiles = new File(sketchPath() + "/pov").list();
	sourceFile = svgFiles[0];
	controlFrame = new ControlFrame(this, 847, 847, "Controls");
	
	// Camera 
	setCam();
	
	// DAF
	daf = new Wavizator(sourceFile);
}
