PImage gatito, rayos;

// Estado de las teclas
boolean derecha = false;
boolean izquierda = false;
boolean arriba = false;
boolean abajo = false;
boolean dash = false;

long tiempo, tiempoanterior = 0;

// Movimiento del teclado
int movX = 0;
int movY = 0;

// Estela del Dash
float anteriorX, anteriorY;
int transparencia = 0;

// Proyectil (Naranjas)
float xProj, yProj;
float velocidadProyectil = 2;
float dx, dy;
boolean activo = true;

// Configuración de corazones y vida
int[][] figura = {
  {0, 1, 0, 1, 0},
  {1, 1, 1, 1, 1},
  {1, 1, 1, 1, 1},
  {0, 1, 1, 1, 0},
  {0, 0, 1, 0, 0}
};
int posX = 5;
int posY = 5;
int tam = 4;

// Cuadrado / límites
int limiteX = 350;
int limiteY = 150;

class Jugador {
  int vida = 10;
  float x = 500;
  float y = 300;
  float velocidad = 4;
  int direccionMirada = 1; // 1 para un lado, -1 para voltear la imagen

  void mover(float mx, float my) {
    x += mx * velocidad;
    y += my * velocidad;

    // Mantener al gatito dentro de los bordes de la pantalla
    x = constrain(x, 30, width - 30);
    y = constrain(y, 30, height - 30);
  }

  void mostrar() {
    pushMatrix();
    translate(x, y);
    scale(direccionMirada, 1); // Voltea la imagen automáticamente según la dirección
    imageMode(CENTER);
    image(gatito, 0, 0, 60, 60);
    imageMode(CORNER);
    popMatrix();
  }
}

Jugador gato;

void setup() {
  size(1000, 600);

  gatito = loadImage("gatito.png");
  rayos = loadImage("rayos.png");
  rayos.resize(1000, 600);

  gato = new Jugador();

  xProj = 0;
  yProj = height / 2;
}

void draw() {
  background(0);
  tiempo = millis();

  // --- RAYOS (Aparecen si la vida es menor o igual a 3) ---
  if (gato.vida <= 3) {
    float opacidadRayos = map(sin(frameCount * 0.20), -1, 1, 100, 255);
    tint(255, opacidadRayos);
    image(rayos, 1, 1);
    noTint();
  }

  // --- DIBUJAR CORAZONES CON EFECTO DE LATIDO ---
  fill(255, 0, 0);
  stroke(255, 0, 0);

  for (int i = 0; i < gato.vida; i++) {
    float velocidadLatido = 0.025 * (11 - gato.vida);
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
    gato.direccionMirada = -1; // Ajusta a 1 o -1 según hacia dónde mire tu imagen base
  }
  if (izquierda) {
    movX--;
    gato.direccionMirada = 1;
  }

  movY = 0;
  if (abajo) movY++;
  if (arriba) movY--;

  // --- MECÁNICA DE DASH ---
  if (dash && tiempo - tiempoanterior >= 1000) {
    anteriorX = gato.x;
    anteriorY = gato.y;

    gato.mover(movX * 15, movY * 15);

    transparencia = 150;
    tiempoanterior = tiempo;
  } else {
    gato.mover(movX, movY);
  }

  // --- DIBUJAR ESTELA DEL DASH ---
  if (transparencia > 0) {
    pushMatrix();
    translate(anteriorX, anteriorY);
    scale(gato.direccionMirada, 1);
    tint(255, transparencia);
    imageMode(CENTER);
    image(gatito, 0, 0, 60, 60);
    imageMode(CORNER);
    noTint();
    popMatrix();

    transparencia -= 3;
  }

  // --- DIBUJAR AL GATO ---
  gato.mostrar();

  // --- NARANJAS QUE PERSIGUEN AL GATO ---
  if (activo == false) {
    nuevoProyectil();
    activo = true;
  }

  if (activo) {
    dx = gato.x - xProj;
    dy = gato.y - yProj;

    // Normalizar dirección
    float distancia = dist(xProj, yProj, gato.x, gato.y);

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
      gato.vida = gato.vida - 1;
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
