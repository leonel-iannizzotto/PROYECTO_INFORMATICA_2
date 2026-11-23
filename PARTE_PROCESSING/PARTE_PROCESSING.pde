float x, y;
float velocidad = 5;
float dx, dy;
boolean activo=true;
PImage gatito;
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
noCursor();
     x = 0;
     y = height / 2;
vida=10;

}

void draw(){
background(0);
 
 //dibujar corazones
  fill(255, 0, 0); 
  stroke(255,0,0);
  for(int i=0;i<vida;i++){
  for (int fila = 0; fila < figura.length; fila++) {
    for (int columna = 0; columna < figura[fila].length; columna++) {

      if (figura[fila][columna] == 1) {

        float x = posX*5*i + columna * tam;
        float y = posY + fila * tam;

        rect(x, y, tam, tam);
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
