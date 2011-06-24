double getTemp() {
  int port = 0;     // Analog input 0 on the board
  double voltage = (double) analogRead(port);
  return voltage;
}