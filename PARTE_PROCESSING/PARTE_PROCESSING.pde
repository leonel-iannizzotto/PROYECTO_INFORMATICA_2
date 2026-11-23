float x, y;
float velocidad = 5;
float dx, dy;
boolean activo=true;
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
//cuadrado
int limiteX =350;
int limiteY =150;


void setup(){
size(1000,600);
gatito = loadImage("gatitoterminado.png");
rayos = loadImage("rayos.png");
rayos.resize(1000, 600); // ================ HACER LO MISMO PARA CADA FOTO ==========
noCursor();
     x = 0;
     y = height / 2;
vida=10;

}

void draw(){
background(0);
// --- RAYOS ----
if (vida<=3){
  // --- EFECTO DE PULSO / TITILEO EN LOS RAYOS ---
  // map convierte el valor de sin() (que va de -1 a 1) a una opacidad entre 100 y 255
  float opacidadRayos = map(sin(frameCount * 0.15), -1, 1, 100, 255);
  tint(255, opacidadRayos); // Aplica transparencia variable
  
  image(rayos, 1, 1);
  
  noTint(); // ¡Importante! Desactivar el tint para que el gatito y los corazones no se vuelvan transparentes
}

// --- DIBUJAR CORAZONES CON EFECTO DE LATIDO ---
  fill(255, 0, 0);  
  stroke(255, 0, 0);
  
  for(int i = 0; i < vida; i++) {
    
    // 1. Calcular la velocidad del latido según la vida restante
    // (A menor vida, más rápido palpita: multiplicamos por (11 - vida))
    float velocidadLatido = 0.025 * (11 - vida); 
    
    // 2. Generar el factor de escala usando sin()
    // sin() devuelve valores entre -1 y 1. Lo usamos para variar el tamaño.
    float latido = sin(frameCount * velocidadLatido) * 0.2; // 0.3 controla qué tan fuerte es el brinco
    
    // Escala final (1.0 es el tamaño normal, sumamos el latido)
    float escalaActual = 1.0 + latido; 

    for (int fila = 0; fila < figura.length; fila++) {
      for (int columna = 0; columna < figura[fila].length; columna++) {

        if (figura[fila][columna] == 1) {
          // Aplicamos la escala al tamaño 'tam' y a la posición relativa
          float tamDinamico = tam * escalaActual;
          
          // Posición base del corazón actual separada por 'i'
          float xCorazon = posX * 5 * i + (columna * tam * escalaActual);
          float yCorazon = posY + (fila * tam * escalaActual);

          rect(xCorazon, yCorazon, tamDinamico, tamDinamico);
        }
      }
    }
  }
 
  //dibujar gatito
image(gatito, mouseX-50, mouseY-50,60,60); // el gato es de 60x60
//naranjas que persiguen al gato
if (activo == false) {
nuevoProyectil();
  activo = true;
}
 if(activo){

 dx = mouseX - x; //direccion de movimiento en x
 dy = mouseY - y; //direccion de movimiento en y

  // Normalizar dirección
  float distancia = dist(x, y, mouseX, mouseY);

  if (distancia > 0) { //si existe distancia
    dx = dx / distancia;
    dy = dy / distancia;
  }
  // Mover proyectil
  x = x + dx * velocidad; //posicion actual mas direccion por velocidad
  y = y + dy * velocidad;

  // Dibujar proyectil
  if(distancia>20){ //si la distancia es muy pequeña
  fill(255, 80, 0);
  noStroke();
  ellipse(x, y, 20, 20);
  }else{ 
  activo=false; 
  vida=vida-1;
  } 
 }
   noFill(); // dibujar cuadrado blanco
  stroke(255);
  rect(limiteX, limiteY, 300, 300);
}

 void nuevoProyectil() {

  int borde = int(random(4));

  if (borde == 0) {
    x = 0;
    y = random(height);
  }

  if (borde == 1) {
    x = width;
    y = random(height);
  }

  if (borde == 2) {
    x = random(width);
    y = 0;
  }

  if (borde == 3) {
    x = random(width);
    y = height;
  }
}
