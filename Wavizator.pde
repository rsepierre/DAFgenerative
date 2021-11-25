class Wavizator {

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
		// this.source.centerIn(g, 100, 1, 1); if you want to force shape resize
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
			this.outerShapes.add(proceduralShape(coreShapes.get(i), centroids.get(i), outerShapeScaling, outerShapeCircleness));
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
				this.blendShapes(this.coreShapes.get(i), this.outerWavyShapes.get(i));
			}
		} catch (Exception e) {
			e.printStackTrace();
			println("Calcs and Rendering not synchronized, frame skipped");
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
	} // end of blendShapes();

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
			direction.setMag(newMag+(multiplier*abs(multiplier)*scaling));
			proceduralShape.add(seedCentroid.copy().add(direction));
		}
		return proceduralShape;
	} // end of proceduralShape();

	// Draws a set of vectors as a shape (curveVertex)
	void drawShape(ArrayList<PVector> shape, float getZ, float getCurviness, float getStrokeWidth, float getAlpha, color getColor) {
		int nPoints = shape.size();
		if (nPoints >= 0) {
			// Drawing Settings
			beginShape();
			// noFill();
			fill(backgroundColor);
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
	} // end of drawShape();

	void addwave(ArrayList<PVector> originShape, ArrayList<PVector> targetShape, float[] wave) {
		int nPoints = originShape.size();
		float difference = wave[0] - wave[nPoints-1]; // get the difference between first and last point
		if (targetShape.size() == 0) {
			for (int i = 0; i < (nPoints); i++) {
				targetShape.add(new PVector());
			}
		}


		for (int i = 0; i < (nPoints); i++) {
			PVector point =	originShape.get(i).copy();
			float yVal = wave[i] + difference/nPoints*i;
			point.setMag((point.mag()+yVal));
			targetShape.get(i).set(point);
		}
	} // end of addWave()

}
