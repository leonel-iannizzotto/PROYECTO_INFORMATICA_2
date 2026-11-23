float x, y;
float velocidad = 5;
float dx, dy;
boolean activo = true;

// Una sola imagen para el personaje
PImage gatito, rayos;

int[][] figura = {
  {0, 1, 0, 1, 0},
  {1, 1, 1, 1, 1},
  {1, 1, 1, 1, 1},
  {0, 1, 1, 1, 0},
  {0, 0, 1, 0, 0}
};

// COORDENADAS DEL DIBUJO
int posX = 5;
int posY = 5;
// DIMENSIONES DE CADA CUADRADO
int tam = 4;
int vida;

// Cuadrado / límites
int limiteX = 350;
int limiteY = 150;

// Para la animación de caminata del gatito
float animFase = 0;       
float animIntensidad = 0; 
float prevMouseX;         
int direccionMirada = 1;  // 1 para un lado, -1 para voltear la imagen

void setup() {
  size(1000, 600);
  
  // Cargamos una sola imagen
  gatito = loadImage("gatito.png");  
  rayos = loadImage("rayos.png");
  rayos.resize(1000, 600); 
  
  noCursor();
  x = 0;
  y = height / 2;
  vida = 10;
  
  prevMouseX = mouseX;
}

void draw() {
  background(0);
  
  // --- RAYOS (Aparecen si la vida es menor o igual a 3) ---
  if (vida <= 3) {
    float opacidadRayos = map(sin(frameCount * 0.20), -1, 1, 100, 255);
    tint(255, opacidadRayos); 
    image(rayos, 1, 1);
    noTint(); 
  }

  // --- DIBUJAR CORAZONES CON EFECTO DE LATIDO ---
  fill(255, 0, 0);  
  stroke(255, 0, 0);
  
  for (int i = 0; i < vida; i++) {
    float velocidadLatido = 0.025 * (11 - vida); 
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
 
  // --- ANIMACIÓN Y DIRECCIÓN DEL GATITO CON 1 SOLA FOTO ---
  float movimiento = dist(mouseX, mouseY, pmouseX, pmouseY);
  boolean caminando = movimiento > 0.5;

  float objetivo = caminando ? 1 : 0;
  animIntensidad = lerp(animIntensidad, objetivo, 0.15);

  if (caminando) {
    animFase += 0.25 + constrain(movimiento * 0.01, 0, 0.15);
  }

  // Detectar hacia dónde se mueve el mouse para voltear la imagen horizontalmente
  if (mouseX > prevMouseX) {
    direccionMirada = -1; // Voltea la imagen hacia la derecha (ajusta a 1 si tu imagen mira al revés)
  } else if (mouseX < prevMouseX) {
    direccionMirada = 1;  // Imagen normal hacia la izquierda
  }
  prevMouseX = mouseX;

  // Cálculo de efectos
  float rebote   = abs(sin(animFase)) * 6 * animIntensidad;        
  float balanceo = sin(animFase) * 0.12 * animIntensidad;          
  // Multiplicamos escalaX por direccionMirada para espejar la imagen sin perder la animación
  float escalaX  = (1 + sin(animFase * 2) * 0.06 * animIntensidad) * direccionMirada;  
  float escalaY  = 1 - sin(animFase * 2) * 0.06 * animIntensidad;

  // Dibujar el gatito espejado y animado
  pushMatrix();
  translate(mouseX, mouseY - rebote); 
  rotate(balanceo);
  scale(escalaX, escalaY); // Aquí ocurre la magia del espejo
  imageMode(CENTER);
  image(gatito, 0, 0, 60, 60);
  imageMode(CORNER);   
  popMatrix();

  // --- NARANJAS QUE PERSIGUEN AL GATO ---
  if (activo == false) {
    nuevoProyectil();
    activo = true;
  }
  
  if (activo) {
    dx = mouseX - x; 
    dy = mouseY - y; 

    float distancia = dist(x, y, mouseX, mouseY);

    if (distancia > 0) { 
      dx = dx / distancia;
      dy = dy / distancia;
    }
    
    x = x + dx * velocidad; 
    y = y + dy * velocidad;

    if (distancia > 20) { 
      fill(255, 80, 0);
      noStroke();
      ellipse(x, y, 20, 20);
    } else { 
      activo = false; 
      vida = vida - 1;
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
    x = 0;
    y = random(height);
  } else if (borde == 1) {
    x = width;
    y = random(height);
  } else if (borde == 2) {
    x = random(width);
    y = 0;
  } else if (borde == 3) {
    x = random(width);
    y = height;
  }
}
