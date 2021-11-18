import processing.svg.*;

import java.util.*;

import geomerative.*;
import controlP5.*;
import peasy.PeasyCam;

PeasyCam camera;
int record = 0;

ControlP5 cp5;
ControlFrame controlFrame;
PGraphics renderer;

Wavizator daf;

// Redimensionner
float scaling = 1;
float zoom = 1;
void setScaling() { scaling = (float)width/2000*zoom; }

/* Controllable Variables */

// Zoom

// File
String svgFiles[];
String sourceFile = "DAF.svg";

// Colors
color backgroundColor = color(255,255,255);
color innerStrokeColor = color(0, 0, 255);
color outerStrokeColor = color(255, 0, 0);

// StrokeWeight
float innerStrokeWidth = 2;
float outerStrokeWidth = 2;

// Alpha
float innerStrokeAlpha = 10;
float outerStrokeAlpha = 0;

// Curviness
float innerCurviness = 0.01;
float outerCurviness = 1;

// Generated Shape
float outerShapeScaling = 1.25;
float outerShapeTwistZ = 0.25;
float outerShapeTwistX = 0.01;
float outerShapeTwistY = 0.01;
float outerShapeGeometry = 0.5;

// Waves
int nWaves = 4;
float waveLength = 4;
float waveScale = 1;
float waveSpeed = 1;

// Poygonizer
int subdivision = 5;

// Blending
int numberOfSteps = 20;
float blendingHeight = 200;

// ControlP5
int margin = 15;
int sideMargin = 20;
int fieldX = sideMargin;
int fieldY = sideMargin;
int fieldHeight = 20;
int fieldWidth = 255;

class ControlFrame extends PApplet {

	int w, h;
	PApplet parent;
	
	public ControlFrame(PApplet _parent, int _w, int _h, String _name) {
		super();   
		parent = _parent;
		w=_w;
		h=_h;
		PApplet.runSketch(new String[]{this.getClass().getName()}, this);
	}

	public void settings() {
		size(w, h);
	}

	public void setup() {
		cp5 = new ControlP5(this);
		createControls();
	}

	void draw() {
		backgroundColor = cp5.get(BetterColorPicker.class, "backgroundColor").getColorValue();
		innerStrokeColor = cp5.get(BetterColorPicker.class, "innerStrokeColor").getColorValue();
		outerStrokeColor = cp5.get(BetterColorPicker.class, "outerStrokeColor").getColorValue();
		background(30);
		fill(color(255,255,0));
		textSize(15);
		text("* Settings marked with asterisks may cause slow rendering, especially when used in conjonction", sideMargin, height-16); 
	}

	Slider ezSlider(String id, String label, float min, float max) {
		Slider slider = cp5.addSlider(id)
		.setPosition(fieldX,fieldY)
		.setSize(fieldWidth, fieldHeight)
		.setRange(min, max)
		.setCaptionLabel(label)
		.plugTo(parent, id);
		slider.getCaptionLabel().align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
		fieldY += fieldHeight+margin+15;
		return slider;
	}

	void createControls() {
		PFont arialSmall = createFont("arial", 13);
		PFont arialBig = createFont("arial", 20);
		cp5.setFont( arialSmall );

		// View
		Textlabel viewTitle = cp5.addTextlabel("viewTitle").setText("View").setFont(arialBig).setPosition(fieldX,fieldY);
		fieldY += fieldHeight + margin-10;
		Textlabel backgroundColorLabel = cp5.addTextlabel("backgroundColorLabel").setText("BACKGROUND COLOR").setFont(arialSmall).setPosition(fieldX-5,fieldY);
		fieldY += margin+3;
		BetterColorPicker backgroundColorPicker = new BetterColorPicker(cp5,"backgroundColor").setPosition(fieldX,fieldY).setColorValue(backgroundColor);
		backgroundColorPicker.getCaptionLabel().setVisible(true).align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
		fieldY += 60+margin;
		Slider zoomSlider = ezSlider("zoom", "Zoom", 0, 3).setValue(zoom).onChange(changeZoom);
		ScrollableList fileSelector = cp5.addScrollableList("sourceFile").setPosition(fieldX,fieldY).setSize(fieldWidth,round(fieldHeight*5.2)).setBarHeight(fieldHeight).setItemHeight(fieldHeight).onEnter(toFront).onChange(changeSource)
		.addItems( Arrays.asList(svgFiles) );
		fileSelector.close();
		fieldY += fieldHeight+margin;
		Button capture2DSVGButton = cp5.addButton("SVG").setPosition(fieldX,fieldY).setSize(fieldWidth/2-2,fieldHeight).onClick(capture);
		fieldX += fieldWidth/2 + 4;
		Button captureSVGButton = cp5.addButton("SVG RAW").setPosition(fieldX,fieldY).setSize(fieldWidth/2-2,fieldHeight).onClick(capture3D);
		fieldY += fieldHeight+4;
		fieldX = sideMargin;
		Button capturePNGButton = cp5.addButton("PNG").setPosition(fieldX,fieldY).setSize(fieldWidth/2-2,fieldHeight).onClick(capturePNG);
		fieldX += fieldWidth/2 + 4;
		// Button captureSVGButton = cp5.addButton("SVG RAW").setPosition(fieldX,fieldY).setSize(fieldWidth/2-2,fieldHeight).onClick(capture3D);

		// Inner Stroke
		fieldY = sideMargin;
		fieldX = sideMargin*2+fieldWidth;
		Textlabel innerTitle = cp5.addTextlabel("innerTitle").setText("Inner Stroke").setFont(arialBig).setPosition(fieldX,fieldY);
		fieldY += fieldHeight + margin-10;
		Textlabel innerStrokeColorLabel = cp5.addTextlabel("innerStrokeColorLabel").setText("STROKE COLOR").setFont(arialSmall).setPosition(fieldX-5,fieldY);
		fieldY += margin+3;
		BetterColorPicker innerStrokeColorPicker = new BetterColorPicker(cp5,"innerStrokeColor").setPosition(fieldX,fieldY).setColorValue(innerStrokeColor);
		fieldY += 60+margin;
		Slider innerStrokeAlphaSlider = ezSlider("innerStrokeAlpha", "Opacity", 0, 10).setValue(innerStrokeAlpha);
		Slider innerStrokeWidthSlider = ezSlider("innerStrokeWidth", "Thickness", 0, 10).setValue(innerStrokeWidth);
		Slider innerCurvinessSlider = ezSlider("innerCurviness", "Curviness", 0.01, 1).setValue(innerCurviness);

		// Outer Stroke
		fieldY = sideMargin;
		fieldX = sideMargin*3+fieldWidth*2;
		Textlabel outerTitle = cp5.addTextlabel("outerTitle").setText("Outer Stroke").setFont(arialBig).setPosition(fieldX,fieldY);
		fieldY += fieldHeight + margin-10;
		Textlabel outerStrokeColorLabel = cp5.addTextlabel("outerStrokeColorLabel").setText("STROKE COLOR").setFont(arialSmall).setPosition(fieldX-5,fieldY);
		fieldY += margin+3;
		BetterColorPicker outerStrokeColorPicker = new BetterColorPicker(cp5,"outerStrokeColor").setPosition(fieldX,fieldY).setColorValue(outerStrokeColor);
		fieldY += 60+margin;
		Slider outerStrokeAlphaSlider = ezSlider("outerStrokeAlpha", "Opacity", 0, 10).setValue(outerStrokeAlpha);
		Slider outerStrokeWidthSlider = ezSlider("outerStrokeWidth", "Thickness", 0, 10).setValue(outerStrokeWidth);
		Slider outerCurvinessSlider = ezSlider("outerCurviness", "Curviness", 0.01, 1).setValue(outerCurviness);

		// Global Settings
		fieldY = 290;
		fieldX = sideMargin;
		Textlabel globalTitle = cp5.addTextlabel("globalTitle").setText("Global").setFont(arialBig).setPosition(fieldX,fieldY);
		fieldY += fieldHeight + margin+10;
		Slider subdivisionSlider = ezSlider("subdivision", "Subdivision (*)", -10, 10).setValue(subdivision).onChange(changePolygon);
		Slider numberOfStepsSlider = ezSlider("numberOfSteps", "Number of Lines (*)", 1, 200).setValue(numberOfSteps);
		Slider blendingHeightSlider = ezSlider("blendingHeight", "Depth", -1500, 1500).setValue(blendingHeight);
		Slider outerShapeScalingSlider = ezSlider("outerShapeScaling", "Spread", 0, 5).setValue(outerShapeScaling).onChange(changeOuterParams);

		// Wave Settings
		fieldY = 290;
		fieldX = sideMargin*2+fieldWidth;
		Textlabel waveTitle = cp5.addTextlabel("waveTitle").setText("Wave").setFont(arialBig).setPosition(fieldX,fieldY);
		fieldY += fieldHeight + margin+10;
		Slider waveScaleSlider = ezSlider("waveScale", "Wave Scale", 0, 10).setValue(waveScale).onChange(changeWaves);
		Slider waveLengthSlider = ezSlider("waveLength", "Wave length", 1, 10).setValue(waveLength).onChange(changeWaves);
		Slider waveSpeedSlider = ezSlider("waveSpeed", "Speed", 0, 3).setValue(waveSpeed).onChange(changeWaves);
		Slider nWavesSlider = ezSlider("nWaves", "Complexity (*)", 1, 10).setValue(nWaves).onChange(changeWaves);


		// Outer Shape
		fieldY = 290;
		fieldX = sideMargin*3+fieldWidth*2;
		Textlabel outerShapeTitle = cp5.addTextlabel("outerShapeTitle").setText("OuterShape").setFont(arialBig).setPosition(fieldX,fieldY);
		fieldY += fieldHeight + margin+10;
		Slider outerShapeGeometrySlider = ezSlider("outerShapeGeometry", "Circleness", 0, 1).setValue(outerShapeGeometry).onChange(changeOuterParams);
		Slider outerShapeTwistZSlider = ezSlider("outerShapeTwistZ", "Twist Z", -2, 2).setValue(outerShapeTwistZ);
		Slider outerShapeTwistXSlider = ezSlider("outerShapeTwistX", "Twist X", -2, 2).setValue(outerShapeTwistX);
		Slider outerShapeTwistYSlider = ezSlider("outerShapeTwistY", "Twist Y", -2, 2).setValue(outerShapeTwistY);

		// Random
		fieldY = 540;
		fieldX = sideMargin;
		Textlabel randomizeTitle = cp5.addTextlabel("randomizeTitle").setText("Randomize Fields").setFont(arialBig).setPosition(fieldX,fieldY);
		fieldX += fieldWidth + sideMargin;
		// View Buttons
		Button selectAllButton = cp5.addButton("all").setPosition(fieldX,fieldY).setSize(fieldWidth/3-(margin*2/3),fieldHeight).onClick(selectAll);
		fieldX += fieldWidth/3-(margin*2/3) + margin;
		Button selectNoneButton = cp5.addButton("none").setPosition(fieldX,fieldY).setSize(fieldWidth/3-(margin*2/3),fieldHeight).onClick(selectNone);
		fieldX += fieldWidth/3-(margin*2/3) + margin;
		Button selectRecommendedButton = cp5.addButton("reco.").setPosition(fieldX,fieldY).setSize(fieldWidth/3-(margin*2/3),fieldHeight).onClick(selectRecommended);
		fieldX += fieldWidth/3-(margin*2/3) + sideMargin;
		Button randomizeButton = cp5.addButton("randomize").setPosition(fieldX,fieldY).setSize(fieldWidth,fieldHeight).onClick(randomizeClick);
		fieldX = sideMargin;
		fieldY += fieldHeight + margin;

		CheckBox checkBoxes = cp5.addCheckBox("checkBoxes")
			.setPosition(fieldX,fieldY)
			.setSize(fieldHeight, fieldHeight)
			.setItemsPerRow(3)
			.setSpacingColumn(fieldWidth-fieldHeight+sideMargin)
			.setSpacingRow(margin/2)
			.addItem("Background Color", 1)
			.addItem("Inner Color", 2)
			.addItem("Outer Color", 3)
			.addItem("Zoom", 3)
			.addItem("Inner Opacity", 5)
			.addItem("Outer Opacity", 6)
			.addItem("Spacer1", 7)
			.addItem("Inner Thickness", 8)
			.addItem("Outer Thickness", 9)
			.addItem("Spacer2", 10)
			.addItem("Inner Curviness", 11)
			.addItem("Outer Curviness", 12)
			.addItem("Subdivision", 13)
			.addItem("Wave Scale", 14)
			.addItem("Circleness", 15)
			.addItem("Number of lines", 16)
			.addItem("Wave Length", 17)
			.addItem("Twist Z", 18)
			.addItem("Global Depth", 19)
			.addItem("Wave Speed", 20)
			.addItem("Twist X", 21)
			.addItem("Spread", 22)
			.addItem("Wave complexity", 23)
			.addItem("Twist Y", 24);
		checkBoxes.getItem(6).setVisible(false);
		checkBoxes.getItem(9).setVisible(false);


	} // end of create controls

} // end of control frame

void randomize() {
	CheckBox checkBoxes = cp5.get(CheckBox.class, "checkBoxes");
	float[] checkValues = checkBoxes.getArrayValue();
	if (checkValues[0] == 1) {
		randomizeSlider("backgroundColor-red");
		randomizeSlider("backgroundColor-green");
		randomizeSlider("backgroundColor-blue");
	}
	if (checkValues[1] == 1) {
		randomizeSlider("innerStrokeColor-red");
		randomizeSlider("innerStrokeColor-green");
		randomizeSlider("innerStrokeColor-blue");
	}
	if (checkValues[2] == 1) {
		randomizeSlider("outerStrokeColor-red");
		randomizeSlider("outerStrokeColor-green");
		randomizeSlider("outerStrokeColor-blue");
	}
	if (checkValues[3] == 1) { randomizeSlider("zoom"); }
	if (checkValues[4] == 1) { randomizeSlider("innerStrokeAlpha"); }
	if (checkValues[5] == 1) { randomizeSlider("outerStrokeAlpha"); }
	// if (checkValues[6] == 1) { randomizeSlider(""); } it's a spacer
	if (checkValues[7] == 1) { randomizeSlider("innerStrokeWidth"); }
	if (checkValues[8] == 1) { randomizeSlider("outerStrokeWidth"); }
	// if (checkValues[9] == 1) { randomizeSlider(""); } it's a spacer
	if (checkValues[10] == 1) { randomizeSlider("innerCurviness"); }
	if (checkValues[11] == 1) { randomizeSlider("outerCurviness"); }
	if (checkValues[12] == 1) { randomizeSlider("subdivision"); }
	if (checkValues[13] == 1) { randomizeSlider("waveScale"); }
	if (checkValues[14] == 1) { randomizeSlider("outerShapeGeometry"); }
	if (checkValues[15] == 1) { randomizeSlider("numberOfSteps"); }
	if (checkValues[16] == 1) { randomizeSlider("waveLength"); }
	if (checkValues[17] == 1) { randomizeSlider("outerShapeTwistZ"); }
	if (checkValues[18] == 1) { randomizeSlider("blendingHeight"); }
	if (checkValues[19] == 1) { randomizeSlider("waveSpeed"); }
	if (checkValues[20] == 1) { randomizeSlider("outerShapeTwistX"); }
	if (checkValues[21] == 1) { randomizeSlider("outerShapeScaling"); }
	if (checkValues[22] == 1) { randomizeSlider("nWaves"); }
	if (checkValues[23] == 1) { randomizeSlider("outerShapeTwistY"); }
}

void randomizeSlider(String sliderName) {
	Slider slider = cp5.get(Slider.class, sliderName);
	float rand = random( slider.getMin(), slider.getMax() );
	slider.setValue(rand);
}

CallbackListener toFront = new CallbackListener() {
	public void controlEvent(CallbackEvent theEvent) {
		theEvent.getController().bringToFront();
	}
};

CallbackListener changeSource = new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
	ScrollableList dropdown = cp5.get(ScrollableList.class, "sourceFile");
	String newSource = (String)dropdown.getItem( (int)dropdown.getValue() ).get("name");
	daf.setSource(newSource);
}};

CallbackListener changePolygon = new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
	daf.setPolygon();
}};

CallbackListener changeOuterParams = new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
	daf.setupOuter();
}};

CallbackListener changeWaves = new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
	daf.setupWaves();
}};

CallbackListener changeZoom = new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
	setScaling();
}};

CallbackListener randomizeClick = new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
	randomize();
}};

CallbackListener selectAll = new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
	CheckBox checkBoxes = cp5.get(CheckBox.class, "checkBoxes");
	checkBoxes.activateAll();
}};

CallbackListener selectNone = new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
	CheckBox checkBoxes = cp5.get(CheckBox.class, "checkBoxes");
	checkBoxes.deactivateAll();
}};

CallbackListener capture = new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
	record = 1;
}};

CallbackListener capture3D = new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
	record = 2;
}};

CallbackListener capturePNG = new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
	record = 3;
}};

CallbackListener selectRecommended = new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
	CheckBox checkBoxes = cp5.get(CheckBox.class, "checkBoxes");
	checkBoxes.deactivateAll();
	checkBoxes.getItem(0).toggle();		// bg color
	checkBoxes.getItem(1).toggle();		// inner color
	checkBoxes.getItem(2).toggle();		// outer color
	// checkBoxes.getItem(3).toggle();		// zoom
	// checkBoxes.getItem(4).toggle();		// inner alpha
	checkBoxes.getItem(5).toggle();		// outer alpha
	// spacer
	// checkBoxes.getItem(7).toggle();		// inner thickness
	// checkBoxes.getItem(8).toggle();		// outer thickness
	// spacer
	// checkBoxes.getItem(10).toggle();		// inner curviness
	// checkBoxes.getItem(11).toggle();		// outer curviness
	// checkBoxes.getItem(12).toggle();		// subdivision
	// checkBoxes.getItem(13).toggle();	// wave scale
	checkBoxes.getItem(14).toggle();	// circleness
	checkBoxes.getItem(15).toggle();	// number of lines
	checkBoxes.getItem(16).toggle();	// wave length
	// checkBoxes.getItem(17).toggle();	// wave twist Z
	checkBoxes.getItem(18).toggle();	// detph
	checkBoxes.getItem(19).toggle();	// wave speed
	// checkBoxes.getItem(20).toggle();	// twist X
	checkBoxes.getItem(21).toggle();	// spread
	// checkBoxes.getItem(22).toggle();	// wave complexity
	// checkBoxes.getItem(23).toggle();	// twist y
}};

class Wavizator { //badass name
	RShape source;
	RShape polygon;
	RPoint[][] pathGroup;
	ArrayList<PVector> centroids;
	ArrayList< ArrayList<PVector> > coreShapes;
	ArrayList< ArrayList<PVector> > outerShapes;
	ArrayList< ArrayList<PVector> > outerWavyShapes;
	int nShapes;
	Wave[] waves;

	Wavizator(String svgSource) {
		this.setSource(svgSource);
	}

	// Convert Geomerative Points to List of Vectors
	ArrayList<PVector> shapeFromPath(RPoint[] path) {
		ArrayList<PVector> result = new ArrayList<PVector>();
		for (int i = 0; i < path.length; i++) {
			float x = path[i].x;
			float y = path[i].y;
			if (x == path[(i+1)%path.length].x && y == path[(i+1)%path.length].y) {
				// don't import duplicate points
			} else {
				result.add(new PVector(x,y));
			}
		}
		return result;
	}

	// Imports new SVG
	void setSource(String svgSource) {
		this.source = RG.loadShape(svgSource);
		this.source.centerIn(g, 100, 1, 1);
	this.setPolygon(); } /*
	↓ */
	void setPolygon() {
		if (subdivision < 0) {
			RG.setPolygonizer(RG.UNIFORMSTEP);
			RG.setPolygonizerStep( abs(subdivision) );
			try { cp5.get(Slider.class, "subdivision").setValueLabel("Subdivisions: " + abs(subdivision) ); } catch (Exception e) { }
		} else if (subdivision < 1) {
			RG.setPolygonizer(RG.ADAPTATIVE);
			try { cp5.get(Slider.class, "subdivision").setValueLabel("Original"); } catch (Exception e) { }
		} else {
			float length = height/2/pow(subdivision,2);
			RG.setPolygonizer(RG.UNIFORMLENGTH);
			RG.setPolygonizerLength(length);
			try { cp5.get(Slider.class, "subdivision").setValueLabel("Uniform Length: " + (int)length + "px"); } catch (Exception e) { }
		}
		
		this.polygon = RG.polygonize(this.source);		
		this.pathGroup = this.polygon.getPointsInPaths();
		this.nShapes = this.pathGroup.length;
	this.setupCore(); } /*
	↓ */
	void setupCore() {
		this.coreShapes = new ArrayList<ArrayList<PVector>>();
		this.centroids = new ArrayList<PVector>();
		for (int i = 0; i < this.nShapes; i++) {
			RPoint centroid = this.polygon.children[i].getCentroid();
			println("print x");
			println(centroid.x);
			println("print y");
			println(centroid.y);
			println("add");
			this.centroids.add( new PVector(centroid.x, centroid.y));
			println(this.centroids.get(i));
			this.coreShapes.add(shapeFromPath(pathGroup[i]));
		}
	this.setupOuter(); } /*
	↓ */
	void setupOuter() {
		this.outerShapes = new ArrayList<ArrayList<PVector>>();
		for (int i = 0; i < this.nShapes; i++) {
			this.outerShapes.add(proceduralShape(coreShapes.get(i), centroids.get(i), outerShapeScaling, outerShapeGeometry));
		}
	this.setupWaves(); } /*
	↓ */
	void setupWaves() {
		this.waves = new Wave[this.nShapes];
		this.outerWavyShapes = new ArrayList<ArrayList<PVector>>();
		for (int i = 0; i < this.nShapes; i++) {
			this.outerWavyShapes.add(new ArrayList<PVector>());
			this.waves[i] = new Wave(4, this.coreShapes.get(i).size());
			this.waves[i].calc();
		}
	} /* no need to call render();
	↓ */
	void render() {
		try {
			for (int i = 0; i < this.nShapes; i++) {
				if (waveSpeed != 0) { this.waves[i].calc(); }
					addwave(this.outerShapes.get(i), this.outerWavyShapes.get(i), this.waves[i].getWave() );
					blendShapes(this.coreShapes.get(i), this.outerWavyShapes.get(i));
			}	
		} catch (Exception e) {
			println("Calcs and Rendering not synchronized, frame skipped");
		}
	}

} // end of Wavizator

ArrayList<PVector> proceduralShape(ArrayList<PVector> seedShape, PVector seedCentroid, float multiplier, float getShapeness) {
	// multiplier defines how bigger the procedural shape is to the seedShape
	// for geometry -1 is a square, 0 is the original shape, 1 is a circle
	int nPoints = seedShape.size();
	if (nPoints == 0) { return new ArrayList<PVector>(); }

	ArrayList<PVector> proceduralShape = new ArrayList<PVector>();
	int totalMag = 0;
	int averageMag = 0;
	for (int i = 0; i < (nPoints); i++) {
		totalMag += seedShape.get(i).copy().sub(seedCentroid).mag();
	}
	averageMag = totalMag/nPoints;

	for (int i = 0; i < (nPoints); i++) {
		PVector direction = seedShape.get(i).copy().sub(seedCentroid);
		float newMag = lerp(direction.mag(), averageMag, getShapeness);
		direction.setMag(newMag*multiplier);
		proceduralShape.add(seedCentroid.copy().add(direction));
	}
	return proceduralShape;
}

void addwave(ArrayList<PVector> originShape, ArrayList<PVector> targetShape, float[] wave) {
	int nPoints = originShape.size();
	if (targetShape.size() == 0) {
		for (int i = 0; i < (nPoints); i++) {
			targetShape.add(new PVector());
		}
	}
	for (int i = 0; i < (nPoints); i++) {
		PVector point =	originShape.get(i).copy();
		float yVal = (wave[i] + wave[(i+2)%nPoints] + 2*wave[(i+1)%nPoints] )/4;
		point.setMag((point.mag()+yVal));
		targetShape.get(i).set(point);
	}
}

void blendShapes(ArrayList<PVector> coreShape, ArrayList<PVector> targetShape) {

	ArrayList<ArrayList<PVector>> betweenShapes = new ArrayList<ArrayList<PVector>>();
	int nPoints = coreShape.size();

	for (int i = 0; i < numberOfSteps; i++) {
		ArrayList<PVector> stepShape = new ArrayList<PVector>();
		for (int j = 0; j < nPoints; j++) {
			PVector targetPoint;
			targetPoint = targetShape.get(j);
			PVector drawnPoint = coreShape.get(j).copy();
			float progress = (float)i*(1/(float)numberOfSteps);
			drawnPoint.lerp(targetPoint, progress);
			stepShape.add(drawnPoint);
		}
		betweenShapes.add(stepShape);
	}

	pushMatrix();

		for (int i=0; i<betweenShapes.size(); i++) {
			float progress = (float)i*1/(float)numberOfSteps;
			float shapeHeight = -blendingHeight*progress;
			float strokeWidth = lerp(pow(innerStrokeWidth,2), pow(outerStrokeWidth,2), progress);
			float strokeCurviness = lerp(innerCurviness, outerCurviness, progress);
			float strokeAlpha = lerp(pow(innerStrokeAlpha,2)*2.5, pow(outerStrokeAlpha,2)*2.5, progress);
			color strokeColor = lerpColor(innerStrokeColor, outerStrokeColor, progress);
			rotateZ(PI*pow(outerShapeTwistZ,3)/(float)numberOfSteps);
			rotateX(PI*pow(outerShapeTwistX,3)/(float)numberOfSteps);
			rotateY(PI*pow(outerShapeTwistY,3)/(float)numberOfSteps);
			drawShape(betweenShapes.get(i), shapeHeight, strokeCurviness, strokeWidth, strokeAlpha, strokeColor);
		}

	popMatrix();
}

// Draws a set of vectors as a shape (curveVertex)
void drawShape(ArrayList<PVector> shape, float getZ, float getCurviness, float getStrokeWidth, float getAlpha, color getColor) {
	int nPoints = shape.size();
	if (nPoints >= 0) {
		// Drawing Settings
		beginShape(); noFill();
		stroke(getColor, getAlpha);
		strokeWeight(getStrokeWidth*scaling);
		curveTightness(1-getCurviness);

		for (int i = 0; i < (nPoints+3); i++) {
			float x = (float)shape.get(i%nPoints).x*scaling;
			float y = (float)shape.get(i%nPoints).y*scaling;
			float z = getZ*scaling;
			if (record == 1) {
				curveVertex(x,y);
			} else {
				curveVertex(x, y, z);
			}
		}
		endShape();
	}
}

// Setup camera
void setCam() {
	camera = new PeasyCam(this, width/2, height/2, 0, height);
	camera.setViewport(0, 0, width, height);
	camera.feed();
}

void settings() {
	size(1500, 1000, P3D);
	pixelDensity(displayDensity());
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

void draw() {
	int currentHeight = height;
	int currentWidth = width;
	int startrecord = record; // synchronise framerate with button clic
	if (startrecord == 1) {
		println("start 2D SVG export...");
		beginRecord(SVG, "export/export2D-####.svg");
	} else if (startrecord == 2) {
		println("start 3D SVG export...");
		beginRaw(SVG, "export/export3D-####.svg");
		hint(ENABLE_DEPTH_SORT);
	} else if (startrecord == 3) {
		renderer.beginDraw();
		renderer.background(backgroundColor);
		println("starting PNG HD export...");
	}

	background(backgroundColor);

	// Draw Scene
	translate(width/2, height/2);
	daf.render();

	if (startrecord == 1) { 
		endRecord();
	} else if (startrecord == 2) {
		endRaw();
	} else if (startrecord == 3) {
		renderer.save("export/exportPNG-" + frameCount + ".png");
		renderer.endDraw();
	}
	if (startrecord > 0) {
		println("export finished !");
		record = 0;
	}
}

void setup() {
	// Settings
	surface.setResizable(true);
	registerMethod("pre", this);

	// Geomerative
	RG.init(this);
	RG.ignoreStyles(true);

	// ControlP5
	svgFiles = new File(sketchPath() + "/data").list();
	controlFrame = new ControlFrame(this, 847, 847, "Controls");
	renderer = createGraphics(3000, 2000, P3D);
	
	// Camera 
	setCam();
	
	// DAF
	daf = new Wavizator("DAF.svg");
}
