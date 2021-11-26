class RenderQueue {

	// PApplet parent;
	// PGraphics renderer;
	ArrayList<String> modes; // svg, png, svgRaw
	ArrayList<String> sourceList;
	ArrayList<String> povList;
	String timestamp;
	String target;

	RenderQueue() {
		this.modes = new ArrayList<String>();
		this.sourceList = new ArrayList<String>();
		this.povList = new ArrayList<String>();
	}

	void addQueue(ArrayList<String> getModes, ArrayList<String> getsourceList, ArrayList<String> getPovList) {
		if (getModes.size() > 0) {
			this.modes.addAll(getModes);
			this.sourceList.addAll(getsourceList);
			this.povList.addAll(getPovList);
		}
	}

	void add(String getMode, String getSource, String getPov) {
		this.modes.add(getMode);
		this.sourceList.add(getSource);
		this.povList.add(getPov);
		this.timestamp = "" + year() + month() + day() + hour() + minute() + second();
	}

	void removeFirst() {
		if(this.modes.size() > 0) {
			this.modes.remove(0);
			this.sourceList.remove(0);
			this.povList.remove(0);
		}
	}

	void startRender() {
		String currentFile = sourceFile	;
		String newPOV = this.povList.get(0);
		String newFile = this.sourceList.get(0);
		String mode = this.modes.get(0);
		this.target = "renders/" + this.timestamp + "/" + fileBasename(newFile) + "-" + fileBasename(newPOV) + ".png";
		this.removeFirst();

		// setup SVG for render
		if(newFile != currentFile) {
			daf.setSource(newFile);
		}

		// setup POV for render
		camera.setState( readPOV(newPOV), 0 );

		// setup render Mode
		renderer.beginDraw();
		renderer.background(backgroundColor);
	}

	void saveRender() {
		// save
		saveFrame(sketchPath() + "/trash");
		renderer.save(target);
		renderer.endDraw();

		println("export finished !");
		isRendering = false;
		loop();
	}
}
