// Control Frame Layout 
int margin = 15;
int sideMargin = 20;
int fieldX = sideMargin;
int fieldY = sideMargin;
int fieldHeight = 20;
int fieldWidth = 255;

// Controls

// Text Labels
Textlabel viewTitle;
Textlabel backgroundColorLabel;
Textlabel innerTitle;
Textlabel innerStrokeColorLabel;
Textlabel outerTitle;
Textlabel outerStrokeColorLabel;
Textlabel globalTitle;
Textlabel waveTitle;
Textlabel outerShapeTitle;
Textlabel randomizeTitle;

// Color Pickers
BetterColorPicker backgroundColorPicker;
BetterColorPicker innerStrokeColorPicker;
BetterColorPicker outerStrokeColorPicker;

// Sliders
Slider zoomSlider;
Slider innerStrokeAlphaSlider;
Slider outerStrokeAlphaSlider;
Slider innerStrokeWidthSlider;
Slider outerStrokeWidthSlider;
Slider innerCurvinessSlider;
Slider outerCurvinessSlider;
Slider subdivisionSlider;
Slider waveScaleSlider;
Slider outerShapeCirclenessSlider;
Slider numberOfStepsSlider;
Slider waveLengthSlider;
Slider outerShapeTwistZSlider;
Slider blendingHeightSlider;
Slider waveSpeedSlider;
Slider outerShapeTwistXSlider;
Slider outerShapeScalingSlider;
Slider nWavesSlider;
Slider outerShapeTwistYSlider;

// Scrollable lists
ScrollableList povSelector;
ScrollableList fileSelector;

// Buttons
Button capture2DSVGButton;
Button captureSVGButton;
Button capturePNGButton;
Button captureDXFButton;
Button captureSuperButton;
Button savePOVButton;
Button selectAllButton;
Button selectNoneButton;
Button selectRecommendedButton;
Button randomizeButton;

// CheckBoxes
CheckBox checkBoxes;

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
		backgroundColor = backgroundColorPicker.getColorValue();
		innerStrokeColor = innerStrokeColorPicker.getColorValue();
		outerStrokeColor = outerStrokeColorPicker.getColorValue();
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
		viewTitle = cp5.addTextlabel("viewTitle").setText("View").setFont(arialBig).setPosition(fieldX,fieldY);
		fieldY += fieldHeight + margin-10;
		backgroundColorLabel = cp5.addTextlabel("backgroundColorLabel").setText("BACKGROUND COLOR").setFont(arialSmall).setPosition(fieldX-5,fieldY);
		fieldY += margin+3;
		backgroundColorPicker = new BetterColorPicker(cp5,"backgroundColor").setPosition(fieldX,fieldY).setColorValue(backgroundColor);
		backgroundColorPicker.getCaptionLabel().setVisible(true).align(ControlP5.LEFT, ControlP5.TOP_OUTSIDE).setPaddingX(0);
		fieldY += 60+margin;
		zoomSlider = ezSlider("zoom", "Zoom", 0, 3).setValue(zoom).onChange(changeZoom);
		povSelector = cp5.addScrollableList("Choose POV").setPosition(fieldX,fieldY-25).setSize(fieldWidth,round(fieldHeight*5.2)).setBarHeight(fieldHeight).setItemHeight(fieldHeight).onEnter(toFront).onChange(changePOV)
		.addItems( Arrays.asList(povFiles) );
		povSelector.close();
		fileSelector = cp5.addScrollableList("sourceFile").setPosition(fieldX,fieldY).setSize(fieldWidth,round(fieldHeight*5.2)).setBarHeight(fieldHeight).setItemHeight(fieldHeight).onEnter(toFront).onChange(changeSource)
		.addItems( Arrays.asList(svgFiles) );
		fileSelector.close();
		fieldY += fieldHeight+margin;
		capture2DSVGButton = cp5.addButton("SVG (not working)").setPosition(fieldX,fieldY).setSize(fieldWidth/2-2,fieldHeight).onClick(captureSVG);
		fieldX += fieldWidth/2 + 4;
		captureSVGButton = cp5.addButton("PDF (raw)").setPosition(fieldX,fieldY).setSize(fieldWidth/2-2,fieldHeight).onClick(captureRaw);
		fieldY += fieldHeight+4;
		fieldX = sideMargin;
		capturePNGButton = cp5.addButton("PNG").setPosition(fieldX,fieldY).setSize(fieldWidth/2-2,fieldHeight).onClick(capturePNG);
		fieldX += fieldWidth/2 + 4;
		captureSuperButton = cp5.addButton("super").setPosition(fieldX,fieldY).setSize(fieldWidth/2-2,fieldHeight).onClick(captureSuper);
		fieldY += fieldHeight+4;
		fieldX = sideMargin;
		savePOVButton = cp5.addButton("savePOV").setPosition(fieldX,fieldY).setSize(fieldWidth/2-2,fieldHeight).onClick(savePOV);
		fieldX += fieldWidth/2 + 4;
		captureDXFButton = cp5.addButton("save DXF").setPosition(fieldX,fieldY).setSize(fieldWidth/2-2,fieldHeight).onClick(captureDXF);

		// Inner Stroke
		fieldY = sideMargin;
		fieldX = sideMargin*2+fieldWidth;
		innerTitle = cp5.addTextlabel("innerTitle").setText("Inner Stroke").setFont(arialBig).setPosition(fieldX,fieldY);
		fieldY += fieldHeight + margin-10;
		innerStrokeColorLabel = cp5.addTextlabel("innerStrokeColorLabel").setText("STROKE COLOR").setFont(arialSmall).setPosition(fieldX-5,fieldY);
		fieldY += margin+3;
		innerStrokeColorPicker = new BetterColorPicker(cp5,"innerStrokeColor").setPosition(fieldX,fieldY).setColorValue(innerStrokeColor);
		fieldY += 60+margin;
		innerStrokeAlphaSlider = ezSlider("innerStrokeAlpha", "Opacity", 0, 10).setValue(innerStrokeAlpha);
		innerStrokeWidthSlider = ezSlider("innerStrokeWidth", "Thickness", 0, 10).setValue(innerStrokeWidth);
		innerCurvinessSlider = ezSlider("innerCurviness", "Curviness", 0.01, 1).setValue(innerCurviness);

		// Outer Stroke
		fieldY = sideMargin;
		fieldX = sideMargin*3+fieldWidth*2;
		outerTitle = cp5.addTextlabel("outerTitle").setText("Outer Stroke").setFont(arialBig).setPosition(fieldX,fieldY);
		fieldY += fieldHeight + margin-10;
		outerStrokeColorLabel = cp5.addTextlabel("outerStrokeColorLabel").setText("STROKE COLOR").setFont(arialSmall).setPosition(fieldX-5,fieldY);
		fieldY += margin+3;
		outerStrokeColorPicker = new BetterColorPicker(cp5,"outerStrokeColor").setPosition(fieldX,fieldY).setColorValue(outerStrokeColor);
		fieldY += 60+margin;
		outerStrokeAlphaSlider = ezSlider("outerStrokeAlpha", "Opacity", 0, 10).setValue(outerStrokeAlpha);
		outerStrokeWidthSlider = ezSlider("outerStrokeWidth", "Thickness", 0, 10).setValue(outerStrokeWidth);
		outerCurvinessSlider = ezSlider("outerCurviness", "Curviness", 0.01, 1).setValue(outerCurviness);

		// Global Settings
		fieldY = 290;
		fieldX = sideMargin;
		globalTitle = cp5.addTextlabel("globalTitle").setText("Global").setFont(arialBig).setPosition(fieldX,fieldY);
		fieldY += fieldHeight + margin+10;
		subdivisionSlider = ezSlider("subdivision", "Subdivision (*)", -10, 10).setValue(subdivision).onChange(changePolygon);
		numberOfStepsSlider = ezSlider("numberOfSteps", "Number of Lines (*)", 1, 200).setValue(numberOfSteps);
		blendingHeightSlider = ezSlider("blendingHeight", "Depth", -1500, 1500).setValue(blendingHeight);
		outerShapeScalingSlider = ezSlider("outerShapeScaling", "Spread", -50, 50).setValue(outerShapeScaling).onChange(changeOuterParams);

		// Wave Settings
		fieldY = 290;
		fieldX = sideMargin*2+fieldWidth;
		waveTitle = cp5.addTextlabel("waveTitle").setText("Wave").setFont(arialBig).setPosition(fieldX,fieldY);
		fieldY += fieldHeight + margin+10;
		waveScaleSlider = ezSlider("waveScale", "Wave Scale", 0, 10).setValue(waveScale).onChange(changeWaves);
		waveLengthSlider = ezSlider("waveLength", "Wave length", 1, 10).setValue(waveLength).onChange(changeWaves);
		waveSpeedSlider = ezSlider("waveSpeed", "Speed", 0, 3).setValue(waveSpeed).onChange(changeWaves);
		nWavesSlider = ezSlider("nWaves", "Complexity (*)", 1, 10).setValue(nWaves).onChange(changeWaves);

		// Outer Shape
		fieldY = 290;
		fieldX = sideMargin*3+fieldWidth*2;
		outerShapeTitle = cp5.addTextlabel("outerShapeTitle").setText("OuterShape").setFont(arialBig).setPosition(fieldX,fieldY);
		fieldY += fieldHeight + margin+10;
		outerShapeCirclenessSlider = ezSlider("outerShapeCircleness", "Circleness", 0, 1).setValue(outerShapeCircleness).onChange(changeOuterParams);
		outerShapeTwistZSlider = ezSlider("outerShapeTwistZ", "Twist Z", -2, 2).setValue(outerShapeTwistZ);
		outerShapeTwistXSlider = ezSlider("outerShapeTwistX", "Twist X", -2, 2).setValue(outerShapeTwistX);
		outerShapeTwistYSlider = ezSlider("outerShapeTwistY", "Twist Y", -2, 2).setValue(outerShapeTwistY);

		// Random
		fieldY = 540;
		fieldX = sideMargin;
		randomizeTitle = cp5.addTextlabel("randomizeTitle").setText("Randomize Fields").setFont(arialBig).setPosition(fieldX,fieldY);
		fieldX += fieldWidth + sideMargin;
		// View Buttons
		selectAllButton = cp5.addButton("all").setPosition(fieldX,fieldY).setSize(fieldWidth/3-(margin*2/3),fieldHeight).onClick(selectAll);
		fieldX += fieldWidth/3-(margin*2/3) + margin;
		selectNoneButton = cp5.addButton("none").setPosition(fieldX,fieldY).setSize(fieldWidth/3-(margin*2/3),fieldHeight).onClick(selectNone);
		fieldX += fieldWidth/3-(margin*2/3) + margin;
		selectRecommendedButton = cp5.addButton("reco.").setPosition(fieldX,fieldY).setSize(fieldWidth/3-(margin*2/3),fieldHeight).onClick(selectRecommended);
		fieldX += fieldWidth/3-(margin*2/3) + sideMargin;
		randomizeButton = cp5.addButton("randomize").setPosition(fieldX,fieldY).setSize(fieldWidth,fieldHeight).onClick(randomizeClick);
		fieldX = sideMargin;
		fieldY += fieldHeight + margin;

		checkBoxes = cp5.addCheckBox("checkBoxes")
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

// CallBacks
CallbackListener toFront = new CallbackListener() {
	public void controlEvent(CallbackEvent theEvent) {
		theEvent.getController().bringToFront();
	}
};

CallbackListener changePOV = new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
	String newPOV = (String)povSelector.getItem( (int)povSelector.getValue() ).get("name");
	camera.setState( readPOV(newPOV), 300 );
	povFiles = new File(sketchPath() + "/pov").list();
	povSelector.setItems( Arrays.asList(povFiles) );
}};

CallbackListener changeSource = new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
	String newSource = (String)fileSelector.getItem( (int)fileSelector.getValue() ).get("name");
	daf.setSource(newSource);
	svgFiles = new File(sketchPath() + "/data").list();
	fileSelector.setItems( Arrays.asList(svgFiles) );
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

CallbackListener captureSVG = new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
	renderQueue.add("svg",null,null);
}};

CallbackListener captureRaw = new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
	renderQueue.add("pdf",null,null);
}};

CallbackListener capturePNG = new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
	renderQueue.add("png",null,null);
}};

CallbackListener captureDXF = new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
	renderQueue.add("dxf",null,null);
}};

CallbackListener captureSuper = new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
	println("List of SVGs : " + svgFiles);
	println("List of POVs : " + povFiles);
	for (int i = 0; i < svgFiles.length; i++) {	
		for (int j = 0; j < povFiles.length; j++) {
			renderQueue.add("png",svgFiles[i],povFiles[j]);
		}
	}
}};

CallbackListener savePOV = new CallbackListener() { public void controlEvent(CallbackEvent theEvent) {
	writePOV();
	povFiles = new File(sketchPath() + "/pov").list();
	povSelector.setItems( Arrays.asList(povFiles) );
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


// Randomize Controls
void randomize() {
	float[] checkValues = checkBoxes.getArrayValue();
	if (checkValues[0] == 1) {
		randomizeSlider( cp5.get( Slider.class, "backgroundColor-red") );
		randomizeSlider( cp5.get( Slider.class, "backgroundColor-green") );
		randomizeSlider( cp5.get( Slider.class, "backgroundColor-blue") );
	}
	if (checkValues[1] == 1) {
		randomizeSlider( cp5.get( Slider.class, "innerStrokeColor-red") );
		randomizeSlider( cp5.get( Slider.class, "innerStrokeColor-green") );
		randomizeSlider( cp5.get( Slider.class, "innerStrokeColor-blue") );
	}	
	if (checkValues[2] == 1) {
		randomizeSlider( cp5.get( Slider.class, "outerStrokeColor-red") );
		randomizeSlider( cp5.get( Slider.class, "outerStrokeColor-green") );
		randomizeSlider( cp5.get( Slider.class, "outerStrokeColor-blue") );
	}
	if (checkValues[3] == 1) { randomizeSlider(zoomSlider); }
	if (checkValues[4] == 1) { randomizeSlider(innerStrokeAlphaSlider); }
	if (checkValues[5] == 1) { randomizeSlider(outerStrokeAlphaSlider); }
	// if (checkValues[6] == 1) { randomizeSlider(); } it's a spacer
	if (checkValues[7] == 1) { randomizeSlider(innerStrokeWidthSlider); }
	if (checkValues[8] == 1) { randomizeSlider(outerStrokeWidthSlider); }
	// if (checkValues[9] == 1) { randomizeSlider(); } it's a spacer
	if (checkValues[10] == 1) { randomizeSlider(innerCurvinessSlider); }
	if (checkValues[11] == 1) { randomizeSlider(outerCurvinessSlider); }
	if (checkValues[12] == 1) { randomizeSlider(subdivisionSlider); }
	if (checkValues[13] == 1) { randomizeSlider(waveScaleSlider); }
	if (checkValues[14] == 1) { randomizeSlider(outerShapeCirclenessSlider); }
	if (checkValues[15] == 1) { randomizeSlider(numberOfStepsSlider); }
	if (checkValues[16] == 1) { randomizeSlider(waveLengthSlider); }
	if (checkValues[17] == 1) { randomizeSlider(outerShapeTwistZSlider); }
	if (checkValues[18] == 1) { randomizeSlider(blendingHeightSlider); }
	if (checkValues[19] == 1) { randomizeSlider(waveSpeedSlider); }
	if (checkValues[20] == 1) { randomizeSlider(outerShapeTwistXSlider); }
	if (checkValues[21] == 1) { randomizeSlider(outerShapeScalingSlider); }
	if (checkValues[22] == 1) { randomizeSlider(nWavesSlider); }
	if (checkValues[23] == 1) { randomizeSlider(outerShapeTwistYSlider); }
}

// Randomize One Slider
void randomizeSlider(Slider slider) {
	float rand = random( slider.getMin(), slider.getMax() );
	slider.setValue(rand);
}


void writePOV() {
	CameraState pov = camera.getState();
	String path = sketchPath() + "/pov/POV-" + millis() + ".pov";
	File file = new File(path);
	try {
		FileOutputStream f = new FileOutputStream(file);
		ObjectOutputStream o = new ObjectOutputStream(f);
		o.writeObject(pov);
		o.close();
		println("POV saved : " + file.getAbsolutePath() );
	} catch (Exception e) {
       e.printStackTrace();
	   println("Error saving POV : " + file.getAbsolutePath() );
    }
}

CameraState readPOV(String filename) {
	CameraState pov;
	String path = sketchPath() + "/pov/" + filename;
	File file = new File(path);
	try {
		FileInputStream fi = new FileInputStream(file);
		ObjectInputStream oi = new ObjectInputStream(fi);
		pov = (CameraState) oi.readObject();
		oi.close();
		fi.close();
		println("POV loaded : " + file.getAbsolutePath() );
		return (CameraState)pov;
	} catch (Exception e) {
       e.printStackTrace();
	   println("Error loading POV" + file.getAbsolutePath() );
	   return camera.getState();
    }
}

String fileBasename(String fileName) {
	int slashIndex = fileName.lastIndexOf('/');
	if(slashIndex == -1) { slashIndex = 0; }
	int dotIndex = fileName.lastIndexOf('.');
	if(dotIndex == -1) { dotIndex = fileName.length(); }
	return fileName.substring(slashIndex, dotIndex);
 }
