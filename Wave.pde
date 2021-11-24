class Wave {

	int nSubwaves, nPoints, xspacing, w;
	float[] theta, speeds, amplitude, dx, yvalues;

	Wave(int getnSubwaves, int getNPoints) { this.setWave(getnSubwaves, getNPoints); }

	// set wave settings
	void setWave(int getnSubwaves, int getNPoints) {
		// get
		this.nPoints = getNPoints;									// total # of waves to add together
		this.nSubwaves = getnSubwaves;								// number of datapoints in the waves
		// setup
		this.theta = new float[nSubwaves];	   						// Store different time values and parallel universes
		this.speeds = new float[nSubwaves];      					// Store different speeds for each waves
		this.amplitude = new float[nSubwaves];   					// Height of wave
		this.dx = new float[nSubwaves];          					// Value for incrementing X, to be calculated as a function of period and xspacing
		this.yvalues = new float [nPoints];  	  					// Using an array to store height values for the wave
		this.xspacing = 100;										// How far apart should each horizontal location be spaced (will this be necessary ?)

		for (int i = 0; i < nSubwaves; i++) {
			this.amplitude[i] = (i+3)*(i+3)*random(1,2)+random(2,5);
			this.speeds[i] = 1/(this.amplitude[i])*random(0.5,1.5);
			this.theta[i] = this.speeds[i];
			float period = this.amplitude[i]*random(2,6)*pow(waveLength, 2); 					// How many pixels before the wave repeats
			this.dx[i] = (TWO_PI / period) * this.xspacing;
		}
	}
	void calc() {
		for (int i = 0; i < this.nPoints; i++) { this.yvalues[i] = 0; }		// Resets yvalues each frame
		for (int waveIndex = 0; waveIndex < this.nSubwaves; waveIndex++) {						// Accumulate wave height values
			this.theta[waveIndex] += this.speeds[waveIndex]*pow(waveSpeed, 2);
			float x = this.theta[waveIndex];
			for (int i = 0; i < nPoints; i++) {
				if (waveIndex % 2 == 0)  this.yvalues[i] += sin(x)*this.amplitude[waveIndex]*pow(waveScale, 2)/4;	// Alternate between sine and cosine
				else this.yvalues[i] += cos(x)*this.amplitude[waveIndex]*pow(waveScale, 2)/4;
				x+=this.dx[waveIndex];
			}
		}
	}
	float[] getWave() { return this.yvalues; }
}
