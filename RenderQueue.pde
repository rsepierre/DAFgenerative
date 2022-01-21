class RenderQueue {
	ArrayList<String> modes; // svg, png, svgRaw
	ArrayList<String> sourceList;
	ArrayList<String> povList;
	String timestamp;
	String target;
	String mode;

	RenderQueue() {
		modes = new ArrayList<String>();
		sourceList = new ArrayList<String>();
		povList = new ArrayList<String>();
	}

	void addQueue(ArrayList<String> getModes, ArrayList<String> getsourceList, ArrayList<String> getPovList) {
		if (getModes.size() > 0) {
			modes.addAll(getModes);
			sourceList.addAll(getsourceList);
			povList.addAll(getPovList);
		}
	}

	void add(String getMode, String getSource, String getPov) {
		modes.add(getMode);
		sourceList.add(getSource);
		povList.add(getPov);
		timestamp = "" + year() + month() + day() + hour() + minute() + second();
	}

	void removeFirst() {
		if(modes.size() > 0) {
			modes.remove(0);
			sourceList.remove(0);
			povList.remove(0);
		}
	}

	void startRender() {
		String currentFile = sourceFile;
		String newPOV = ( povList == null ? povList.get(0) : "customView" );
		String newFile = ( sourceList == null ? sourceList.get(0) : currentFile  );
		this.mode = modes.get(0);
		this.target = "renders/" + this.timestamp + "/" + fileBasename(newFile) + "-" + fileBasename(newPOV) + "." + mode;
		this.removeFirst();

		// setup SVG for render
		if(newFile != currentFile) {
			daf.setSource(newFile);
		}

		// setup POV for render
		if (newPOV != "customView") {
			camera.setState( readPOV(newPOV), 0 );
		}
		
		switch(mode) {
			case "jpg":
				// PNG rendering
				if (renderer.width != w) {
					renderer.setSize(w,h);
				}
				renderer.beginDraw();
				renderer.background(backgroundColor);
				break;
			case "svg":
				beginRaw(SVG, target);
				break;
			case "pdf":
				// hint(DISABLE_DEPTH_TEST);
				beginRaw(PDF, target);
				break;
			case "png":
				// TIF rendering
				if (renderer.width != w*4) {
					renderer.setSize(w*4,h*4);
				}
				renderer.beginDraw();
				renderer.background(backgroundColor);
				break;
			default:
				println("error : No supported mode selected");
		}
		
	}

	void saveRender() {

		switch(mode) {
			case "jpg":
				saveFrame(sketchPath() + "/trash"); // weird hack to make enable renderer to finish drawing before saving
				renderer.save(target);
				renderer.endDraw();
				break;
			case "svg":
				endRaw();
				break;
			case "pdf":
				endRaw();
				break;
			case "png":
				saveFrame(sketchPath() + "/trash"); // weird hack to make enable renderer to finish drawing before saving
				renderer.save(target);
				renderer.endDraw();
				break;
			default:
				println("error : No supported mode selected");
		}
		println("EXPORTED: " + target);
		isRendering = false;

	}
}
