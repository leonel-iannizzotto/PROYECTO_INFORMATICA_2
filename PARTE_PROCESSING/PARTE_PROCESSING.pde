PImage personaje, rayos, prueba, prueba2; // Declaracion de tipo imagen

// Estado de las teclas
boolean derecha = false;
boolean izquierda = false;
boolean arriba = false;
boolean abajo = false;
boolean dash = false;

// Delay para dash
long tiempo, tiempoanterior = 0;

// Movimiento
int movX = 0; // 1 es derecha y -1 es izquierda
int movY = 0; // -1 es arriba y 1 es abajo. En este caso los pixeles aumentan hacia abajo en la pantalla

// Estela que deja el dash
float anteriorX, anteriorY;
int anteriorDireccion = 1; // hacia dónde miraba el gato cuando hizo el dash
int transparencia = 0;

// Proyectil (Naranjas)
float xProj, yProj; // Pocision horizontal y vertical
float velocidadProyectil = 2; // velocidad modificable
float dx, dy; // direcciones hacia el jugador
boolean activo = true; // dice si hay proyectil

// Dibujo de corazon de vida
int[][] figura = {
  {0, 1, 0, 1, 0},
  {1, 1, 1, 1, 1},
  {1, 1, 1, 1, 1},
  {0, 1, 1, 1, 0},
  {0, 0, 1, 0, 0}
};
int posX = 5; // pocision inicial en x
int posY = 5; // posicion inicial en y
int tam = 4; // tamaño de corazon

// posicion de dibujo del cuadrado
int limiteX = 350;
int limiteY = 150;

// =============== CLASE DEL PERSONAJE ==================
class Jugador 
{
  int vida = 10;
  float x = 500; // pocicion inicial
  float y = 300; // posicion inicial
  float velocidad = 4; // cambio por ciclo
  int direccionMirada = 1; // 1 para un lado, -1 para voltear la imagen

  // Animación de caminata
  float animFase = 0;       // acumula el "tiempo" de la caminata
  float animIntensidad = 0; // 0 = quieto, 1 = caminando a pleno
  
  // -------- FUNCION MOVER PERSONAJE -------------
  void mover(float mx, float my) 
  {
    x += mx * velocidad; // modifica la posicion en x
    y += my * velocidad; // modifica la posicion en y

    // Mantener al personaje dentro de los bordes del cuadro blanco
    x = constrain(x, 370, 630);
    y = constrain(y, 172, 435);
  }

  // -------- FUNCION ANIMAR PERSONAJE --------------
  // Una vez por frame, indica si el jugador se está moviendo
  void animar(boolean caminando) 
  {
    float objetivo; // quiere llegar a 1 cuando camina o quiere llegar a 0 cuando no camina
      if (caminando)
      {
        objetivo = 1;
      }
      else
      {
        objetivo = 0;
      }
    animIntensidad = lerp(animIntensidad, objetivo, 0.15); // para cambiar entre caminando y no caminando de manera suave. lerp sube de a poco la intensidad hasta el objetivo a una velocidad de 0.15

    // La fase avanza solo si se mueve
    if (caminando) 
    {
      animFase = animFase + 0.25; // sube indefinidamente, permite generar el movimiento con sin()
    }
  }

  // -------- FUNCION MOSTRAR PERSONAJE ----------------
  void mostrar() 
  {
    // Cálculo de los efectos
    float rebote   = abs(sin(animFase)) * 6 * animIntensidad;       // salto en píxeles
    float balanceo = sin(animFase) * 0.12 * animIntensidad;         // rotación en radianes
    float escalaX  = 1 + sin(animFase * 2) * 0.06 * animIntensidad; // squash & stretch
    float escalaY  = 1 - sin(animFase * 2) * 0.06 * animIntensidad;

    pushMatrix();
    translate(x, y - rebote);
    rotate(balanceo);
    scale(direccionMirada * escalaX, escalaY); // volteo y squash en un solo scale
    imageMode(CENTER);
    image(personaje, 0, 0, 60, 60);
    imageMode(CORNER);
    popMatrix();
  }
}

Jugador jugador;

// ======================== SETUP ================================
void setup() {
  size(1000, 600);

  personaje = loadImage("gatito.png");
  rayos = loadImage("rayos.png");
  prueba = loadImage("prueba.png");
  prueba2= loadImage("donpollo.png");
  
  rayos.resize(1000, 600);
  jugador = new Jugador();

  xProj = 0;
  yProj = height / 2;
}

void draw() {
  background(0);
  tiempo = millis();
image(prueba2,670,110);
image(prueba,550,90);

  // --- RAYOS (Aparecen si la vida es menor o igual a 3) ---
  if (jugador.vida <= 3) {
    float opacidadRayos = map(sin(frameCount * 0.20), -1, 1, 100, 255);
    tint(255, opacidadRayos);
    image(rayos, 1, 1);
    noTint();
  }

  // --- DIBUJAR CORAZONES CON EFECTO DE LATIDO ---
  fill(255, 0, 0);
  stroke(255, 0, 0);

  for (int i = 0; i < jugador.vida; i++) {
    float velocidadLatido = 0.025 * (11 - jugador.vida);
    float latido = sin(frameCount * velocidadLatido) * 0.2;
    float escalaActual = 1.0 + latido;

    for (int fila = 0; fila < figura.length; fila++) {
      for (int columna = 0; columna < figura[fila].length; columna++) {

        if (figura[fila][columna] == 1) {
          float tamDinamico = tam * escalaActual;
          float xCorazon = posX * 5 * i + (columna * tam * escalaActual);
          float yCorazon = posY + (fila * tam * escalaActual);

          rect(xCorazon, yCorazon, tamDinamico, tamDinamico);
        }
      }
    }
  }

  // --- CALCULAR DIRECCIÓN DEL TECLADO ---
  movX = 0;
  if (derecha) {
    movX++;
    jugador.direccionMirada = -1; // Ajusta a 1 o -1 según hacia dónde mire tu imagen base
  }
  if (izquierda) {
    movX--;
    jugador.direccionMirada = 1;
  }

  movY = 0;
  if (abajo) movY++;
  if (arriba) movY--;

  // --- MECÁNICA DE DASH ---
  if (dash && tiempo - tiempoanterior >= 1000) {
    anteriorX = jugador.x;
    anteriorY = jugador.y;
    anteriorDireccion = jugador.direccionMirada;

    jugador.mover(movX * 15, movY * 15);

    transparencia = 150;
    tiempoanterior = tiempo;
  } else {
    jugador.mover(movX, movY);
  }

  // --- DIBUJAR ESTELA DEL DASH ---
  if (transparencia > 0) {
    pushMatrix();
    translate(anteriorX, anteriorY);
    scale(anteriorDireccion, 1);
    tint(255, transparencia);
    imageMode(CENTER);
    image(personaje, 0, 0, 60, 60);
    imageMode(CORNER);
    noTint();
    popMatrix();

    transparencia -= 3;
  }

  // --- DIBUJAR AL GATO (con animación de saltitos) ---
  jugador.animar(movX != 0 || movY != 0); // true si hay alguna flecha presionada
  jugador.mostrar();

  // --- NARANJAS QUE PERSIGUEN AL GATO ---
  if (activo == false) {
    nuevoProyectil();
    activo = true;
  }

  if (activo) {
    dx = jugador.x - xProj;
    dy = jugador.y - yProj;

    // Normalizar dirección
    float distancia = dist(xProj, yProj, jugador.x, jugador.y);

    if (distancia > 0) {
      dx = dx / distancia;
      dy = dy / distancia;
    }

    // Mover proyectil
    xProj = xProj + dx * velocidadProyectil;
    yProj = yProj + dy * velocidadProyectil;

    // Dibujar proyectil o colisión
    if (distancia > 20) {
      fill(255, 80, 0);
      noStroke();
      ellipse(xProj, yProj, 20, 20);
    } else {
      activo = false;
      jugador.vida = jugador.vida - 1;
    }
  }

  // --- CUADRADO BLANCO ---
  noFill();
  stroke(255);
  rect(limiteX, limiteY, 300, 300);
}

void nuevoProyectil() {
  int borde = int(random(4));

  if (borde == 0) {
    xProj = 0;
    yProj = random(height);
  } else if (borde == 1) {
    xProj = width;
    yProj = random(height);
  } else if (borde == 2) {
    xProj = random(width);
    yProj = 0;
  } else if (borde == 3) {
    xProj = random(width);
    yProj = height;
  }
}

// Presionar tecla
void keyPressed() {
  if (keyCode == RIGHT) derecha = true;
  if (keyCode == LEFT) izquierda = true;
  if (keyCode == UP) arriba = true;
  if (keyCode == DOWN) abajo = true;
  if (key == ' ') dash = true;
}

// Soltar tecla
void keyReleased() {
  if (keyCode == RIGHT) derecha = false;
  if (keyCode == LEFT) izquierda = false;
  if (keyCode == UP) arriba = false;
  if (keyCode == DOWN) abajo = false;
  if (key == ' ') dash = false;
}
