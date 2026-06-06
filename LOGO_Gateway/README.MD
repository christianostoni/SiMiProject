2 — Permessi sulla porta seriale (solo la prima volta)

  sudo usermod -a -G dialout pi
  # Fai logout e login per applicare, oppure:
  newgrp dialout


3 — Compila e flasha

  arduino-cli compile --fqbn esp8266:esp8266:d1_mini \
    --upload \
    --port /dev/ttyUSB0 \
    /home/pi/SiMiProject/logo_gateway/arduino_code/LOGO_Gateway/
  
  I file ModbusLogo.cpp e ModbusLogo.h nella stessa cartella vengono compilati automaticamente insieme al .ino.

4 — Monitor seriale (debug)

  arduino-cli monitor --port /dev/ttyUSB0 --config baudrate=115200

  Per uscire: Ctrl+C.

  ▎ Assicurati che il baud rate corrisponda a quello nel tuo Serial.begin(...) nel codice ESP.



arduino-cli compile --fqbn esp8266:esp8266:d1_mini \
    --upload \
    --port /dev/ttyUSB0 \
    --verbose \
    /home/pi/SiMiProject/logo_gateway/arduino_code/LOGO_Gateway/
  
  Così vedi ogni file che sta compilando e capisci se è bloccato o sta lavorando.

