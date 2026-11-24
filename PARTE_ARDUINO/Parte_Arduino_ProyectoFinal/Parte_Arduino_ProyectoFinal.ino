
int pinX = A0;
int pinY = A1;

int pinDash = 2;
int pinSeleccion = 3;

int led = 13;

unsigned long tiempoAnterior = 0;

void setup()
{
  pinMode(pinDash, INPUT_PULLUP);
  pinMode(pinSeleccion, INPUT_PULLUP);

  pinMode(led, OUTPUT);

  Serial.begin(9600);
}

void loop()
{
  // -------- LEER JOYSTICK --------
  int x = analogRead(pinX);
  int y = analogRead(pinY);

  // -------- LEER BOTONES --------
  int dash = !digitalRead(pinDash);
  int seleccionar = !digitalRead(pinSeleccion);

  // -------- ENVIAR DATOS A PROCESSING -------- // LO QUE ENVIA ES ALGO ASÍ: 512,512,0,0
  if (millis() - tiempoAnterior >= 30)
  {
    Serial.print(x);
    Serial.print(",");
    Serial.print(y);
    Serial.print(",");
    Serial.print(dash);
    Serial.print(",");
    Serial.println(seleccionar);

    tiempoAnterior = millis();
  }

  // -------- RECIBIR DATOS DE PROCESSING --------
  if (Serial.available() > 0)
  {
    char dato = Serial.read();

    if (dato == 'L')
    {
      digitalWrite(led, HIGH);
      tiempoAnterior = millis();
    }
  }

  // Apagar LED después de 200 ms
  static unsigned long inicioLED = 0;

  if (digitalRead(led) == HIGH)
  {
    if (inicioLED == 0)
    {
      inicioLED = millis();
    }

    if (millis() - inicioLED >= 200)
    {
      digitalWrite(led, LOW);
      inicioLED = 0;
    }
  }
}
