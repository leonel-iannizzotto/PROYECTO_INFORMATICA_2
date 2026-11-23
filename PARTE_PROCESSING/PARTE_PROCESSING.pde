float x, y;
float velocidad = 5;
float dx, dy;
boolean activo=true;
void setup(){
size(800,600);
noCursor();
     x = 0;
     y = height / 2;
}

void draw(){
background(0);
stroke(220,0,0);
fill(220,0,0);
 rect(mouseX-25/1.5 ,mouseY-5/1.5    ,50/1.5    ,10/1.5);
 rect(mouseX-20/1.5 ,mouseY+5/1.5    ,40/1.5    ,5/1.5);
 rect(mouseX-15/1.5 ,mouseY+10/1.5   ,30/1.5    ,5/1.5);
 rect(mouseX-10/1.5 ,mouseY+15/1.5   ,20/1.5    ,5/1.5);
 rect(mouseX-5/1.5  ,mouseY+20/1.5   ,10/1.5    ,5/1.5);
 rect(mouseX-20/1.5 ,mouseY-10/1.5   ,15/1.5    ,5/1.5);
 rect(mouseX+5/1.5  ,mouseY-10/1.5   ,15/1.5    ,5/1.5);

 stroke(250,0,0);
fill(250,0,0);
 rect(mouseX+10/1.5 ,mouseY-5/1.5    ,10/1.5    ,5/1.5);
 rect(mouseX+15/1.5 ,mouseY          ,5/1.5     ,5/1.5);
if (activo == false) {
nuevoProyectil();
  activo = true;
}
 if(activo){

 dx = mouseX - x; //direccion de movimiento en x
 dy = mouseY - y; //direccion de movimiento en y

  // Normalizar dirección
  float distancia = dist(x, y, mouseX, mouseY);

  if (distancia > 0) {
    dx = dx / distancia;
    dy = dy / distancia;
  }

  // Mover proyectil
  x = x + dx * velocidad;
  y = y + dy * velocidad;

  // Dibujar proyectil
  if(distancia>20){
  fill(255, 80, 0);
  noStroke();
  ellipse(x, y, 20, 20);
  }else{
  activo=false;
  }
  
 }
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
