// Metode som må kjøres på serversiden for å regne ut korrekt temperatur
// Tar voltage til input, som igjen er output fra getTemp metoden fra Arduino.

public double getTemp(double voltage) {
	double R = 10000.0; // Fixed resistance in the voltage divider
	double logRt,Rt,T;
	double a1 = 0.003354016, b1 = 0.0002569850, c1 = 0.000002620131, d1= 0.00000006383091;
	Rt = R*((1023.0/ voltage) - 1.0 );
	logRt = Math.log(Rt/R);
	T = Math.pow((a1 + b1*logRt + c1*logRt*logRt + d1*logRt*logRt*logRt),-1) - 273.15;
	return T;
}