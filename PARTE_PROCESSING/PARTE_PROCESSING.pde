// =============================================================== VARIABLES ======================================================================================
PImage personaje, rayos, enrique, donpollo; // Declaracion de tipo imagen

// Estado de las teclas
boolean derecha = false;
boolean izquierda = false;
boolean arriba = false;
boolean abajo = false;
boolean dash = false;

// Delay para dash
long tiempo, tiempoanterior = 0;
int esperaDash = 1000;

// Movimiento
int movX = 0; // 1 es derecha y -1 es izquierda
int movY = 0; // -1 es arriba y 1 es abajo. En este caso los pixeles aumentan hacia abajo en la pantalla

// Estela que deja el dash
float anteriorX, anteriorY;
int anteriorDireccion = 1; // hacia dónde miraba el gato cuando hizo el dash
int transparencia = 0;

// Proyectil (Naranjas)
float xProyectil, yProyectil; // Pocision horizontal y vertical de proyectil
float velocidadProyectil = 2; // velocidad modificable
float dx, dy; // direcciones hacia el jugador
boolean activo = true; // dice si hay proyectil

// Dibujo de corazon de vida // 0 no dibuja, 1 es rojo
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

// posicion de dibujo del cuadrado blanco
int limiteX = 350;
int limiteY = 150;

// =================== INTRO ======================
boolean enIntro = true;   // true = se está mostrando la presentación
boolean saliendo = false; // true = terminó el último diálogo y la pantalla se oscurece
int lineaActual = 0;      // variable de control para el diálogo que se muestra
int inicioIntro, inicioLinea, inicioSalida; // millis() en que empezó cada etapa

String[] nombres = {"Don Pollo", "Enrique"}; // 0 = Don Pollo, 1 = Enrique
int[] quienHabla = {1, 0, 1, 0, 1, 0}; // hablan 1 vez cada uno

String[] dialogos = {
  "¡Bienvenido a los Juegos de la Muerte!",
  "Aquí solo sobrevive el que sabe esquivar.",
  "Los juegos no acaban hasta que alguien muera.",
  "Cada golpe te quita una vida. Tienes diez.",
  "Muévete con las flechas y haz dash con ESPACIO.",
  "Que comiencen los juegos... buena suerte."
};

float msPorLetra = 45;   // velocidad de escritura (más chico = más rápido)
int pausaDialogo = 1500; // espera después de escribir cada línea (ms)
int duracionTransicion = 500;  // duración del fundido de entrada y de salida (ms)

// Posición de los personajes en la intro
int polloX = 100;
int ranaX = 450;
int personajesY = 40;

// =============== MENÚ DE SELECCIÓN DE PERSONAJE ==================
boolean enMenu = false;            // true mientras se muestra el menú
PImage[] opciones = new PImage[4]; // imágenes de los personajes elegibles
String[] archivosPersonajes = {"gatito.png", "amongus.png", "patito.png", "homero.png"}; 
String[] nombresPersonajes = {"Gatito", "Among Us", "Patito", "Homero"};

int seleccion = 0;        // personaje elegido (0 a 3). // al pasar el último vuelve al primero
float separacion = 240;   // distancia horizontal entre un personaje y el siguiente

// ==================================== CLASE PERSONAJE =============================================
class Jugador 
{
  int vida = 10;
  float x = 500; // pocicion inicial
  float y = 300; // posicion inicial
  float velocidad = 4; // cambio por ciclo
  int direccionMirada = 1; // 1 para un lado, -1 para voltear la imagen

  // Animación de caminata
  float animFase = 0;       // acumula el "tiempo" de la caminata // se usa como angulo en el seno
  float animIntensidad = 0; // 0 = quieto, 1 = caminando a pleno
  
  // -------- FUNCION MOVER PERSONAJE -------------
  void mover(float mx, float my) 
  {
    x += mx * velocidad; // modifica la posicion en x
    y += my * velocidad; // modifica la posicion en y

    // Mantener al personaje dentro de los bordes del cuadro blanco
    x = constrain(x, 370, 630); // x no puede ser menor que 370 ni mayor que 630
    y = constrain(y, 172, 435);
  }

  // -------- FUNCION ANIMAR PERSONAJE --------------
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
  // lee las de caminar y animar y las usa para darle los efectos 
  void mostrar() 
  {
    // Cálculo de los efectos
    float rebote   = abs(sin(animFase)) * 6 * animIntensidad; // calcula los pixeles que salta el personaje //abs es valor absoluto (oscila entre 0 y 1) // 6 es la amplitud máxima
    float balanceo = sin(animFase) * 0.12 * animIntensidad; // calcula cuanto se inclina para los lados

    pushMatrix(); // guarda una copia de la matriz actual // para solo modificar el personaje
      translate(x, y - rebote); // aplica efecto de rebote en ejeY // mueve el origen a las coordenadas X,Y para luego en image
      rotate(balanceo); // lo rota un cierto ángulo
      scale(direccionMirada, 1); // lo gira dependiendo donde mira
      imageMode(CENTER); // x e y son el centro de la imagen, no la esquina
      image(personaje, 0, 0, 60, 60); // origen modificado en translate
      imageMode(CORNER); // restaura el modo normal
    popMatrix();// recupera la copia guardada, descarta todos los cambios
  }
}
Jugador jugador;

// =============================================================== SETUP ======================================================================================
void setup() 
{
  size(1000, 600); // tamaño pantalla

  // Personajes del menú de selección
  for (int i = 0; i < opciones.length; i++) 
  {
    opciones[i] = loadImage(archivosPersonajes[i]); // carga los personajes
  }
  personaje = opciones[0];
  rayos = loadImage("rayos.png");
  enrique = loadImage("prueba.png");
  donpollo = loadImage("donpollo.png");
  rayos.resize(1000, 600);

  jugador = new Jugador(); // crea a jugador de clase Jugador

  xProyectil = 0;
  yProyectil = height / 2;

  // Arranca la presentación // se reproduce en draw() solo una vez
  inicioIntro = millis();
  inicioLinea = millis();
}

// =================================================================== DRAW ==================================================================================
void draw() 
{
  // -------- INTRO --------
  if (enIntro) 
  {
    dibujarIntro();
    return;
  }

  // -------- MENÚ ---------
  if (enMenu) 
  {
    dibujarMenu();
    return;
  }

  background(0);
  tiempo = millis();

  // ------- RAYOS  ---------
  if (jugador.vida <= 3) 
  {
    float opacidadRayos = map(sin(frameCount * 0.20), -1, 1, 100, 255); // frameCount sirve de angulo para sen() // al variar entre -1 y 1 oscila entre 100 y 255 de opacidad // 0.20 es la velocidad
    tint(255, opacidadRayos); // indica como se dibujan las imagenes hasta noTint
      image(rayos, 1, 1);
    noTint();
  }

  // --- CORAZONES CON EFECTO DE LATIDO ---
  fill(255, 0, 0); // color rojo
  stroke(255, 0, 0); // bordes rojos

  for (int i = 0; i < jugador.vida; i++) 
  {
    float velocidadLatido = 0.025 * (11 - jugador.vida); // mientras menos vida, mas rapido
    float latido = sin(frameCount * velocidadLatido) * 0.2; // usa velocidadLatido como angulo
    float escalaActual = 1.0 + latido; // escala variable de los corazones
    
    // dibujo de cada corazon
    for (int fila = 0; fila < figura.length; fila++) 
    {
      for (int columna = 0; columna < figura[fila].length; columna++) 
      {
        if (figura[fila][columna] == 1) 
        {
          float tamDinamico = tam * escalaActual; // modifica tamaño constantemente
          float xCorazon = posX * 5 * i + (columna * (tam * escalaActual)); // separa cada 25 pixeles y le da la posicion a cada cuadradito en columna
          float yCorazon = posY + (fila * (tam * escalaActual)); // la posicion en y no varía con i

          rect(xCorazon, yCorazon, tamDinamico, tamDinamico); // dibuja cada pixel del corazon
        }
      }
    }
  }

  // ------ CALCULAR DIRECCIÓN DEL TECLADO ------
  movX = 0;
  if (derecha) 
  {
    movX++;
    jugador.direccionMirada = -1;
  }
  if (izquierda) 
  {
    movX--;
    jugador.direccionMirada = 1;
  }

  movY = 0;
  if (abajo) movY++;
  if (arriba) movY--;

  // ------ MECÁNICA DE DASH ------
  if (dash && tiempo - tiempoanterior >= esperaDash) // con delay de 1 segundo
  {
    // guarda la posicion y direccion de cuando se hizo
    anteriorX = jugador.x;
    anteriorY = jugador.y;
    anteriorDireccion = jugador.direccionMirada;

    jugador.mover(movX * 15, movY * 15); // ejecuta el dash (hace que se mueva muy rapido)

    transparencia = 150; // inicial 
    tiempoanterior = tiempo; // nuevo tiempo para comparar
  } 
  else 
  {
    jugador.mover(movX, movY);
  }

  // ----- DIBUJAR ESTELA DEL DASH -----
  if (transparencia > 0) 
  {
    pushMatrix(); // solo modifica la estela hasta popMatrix()
      translate(anteriorX, anteriorY); // posiciona el centro en las coordenadas anteriores
      scale(anteriorDireccion, 1); // lo escala dependiendo la direccion que tenia
        tint(255, transparencia); // se desvanece de a poco
          imageMode(CENTER);
          image(personaje, 0, 0, 60, 60); // imprime la estela
          imageMode(CORNER);
        noTint();
    popMatrix();

    transparencia = transparencia - 3;
  }

  // ---- DIBUJAR AL GATO CON ANIMACIONES ----
  jugador.animar(movX != 0 || movY != 0); // true si hay alguna flecha presionada
  jugador.mostrar();

  // ----- NARANJAS QUE PERSIGUEN AL GATO -----
  if (activo == false) 
  {
    nuevoProyectil();
    activo = true;
  }

  // ----- PERSIGUEN AL JUGADOR -----
  if (activo) 
  {
    dx = jugador.x - xProyectil;
    dy = jugador.y - yProyectil;
    
    float distancia = dist(xProyectil, yProyectil, jugador.x, jugador.y);

    // normaliza el vector (dx,dy) para obtener solo la direccion hacia el jugador
    if (distancia > 0) 
    {
      dx = dx / distancia;
      dy = dy / distancia;
    }

    // mover proyectil
    xProyectil = xProyectil + dx * velocidadProyectil;
    yProyectil = yProyectil + dy * velocidadProyectil;

    // Dibujar proyectil o colisión
    if (distancia > 20) 
    {
      fill(255, 80, 0);
      noStroke(); // sin bordes
      ellipse(xProyectil, yProyectil, 20, 20);
    } else {
      activo = false; // llegó al jugador
      jugador.vida = jugador.vida - 1; // quita una vida
    }
  }

  // -------- CUADRADO BLANCO --------
  noFill(); // sin pintar el interior
  stroke(255); // bordes blancos
  rect(limiteX, limiteY, 300, 300); 
  
  // -------- BARRA DE DASH (solo aparece mientras se carga) --------
  float cargado = tiempo - tiempoanterior; // ms desde el último dash
  if (cargado < esperaDash)
  {
    float anchoBarra = map(cargado, 0, esperaDash, 150, 0); // crece de 0 a 300 píxeles
    stroke(0);
    fill(26, 82, 140); // color azulado
    rect(425, 465, anchoBarra, 5);
  }
}

// =================================================================== FUNCIONES ==================================================================================

// ============ CINEMÁTICA DE PRESENTACIÓN ================
void dibujarIntro() 
{
  int ahora = millis(); // tiempo para usar en los calculos de tiempo
  
  String texto = dialogos[lineaActual]; // guarda a donde está ubicado
  
  if (!saliendo && ahora - inicioLinea > texto.length() * msPorLetra + pausaDialogo) // mientras no sea saliendo de la presentacion y pasó mas tiempo para cada frase, pasa a la siguiente
  {
    if (lineaActual < dialogos.length - 1) // se fija si hay otro dialogo
    {
      lineaActual++;
      inicioLinea = ahora;
    } else {
      saliendo = true;
      inicioSalida = ahora;
    }
  }

  texto = dialogos[lineaActual];
  int hablando = quienHabla[lineaActual]; // 0 habla don pollo y 1 habla enrique
  boolean hablaPollo = (hablando == 0); // condicion para que sea true

  // --- efecto máquina de escribir ---
  int letras = constrain(int((ahora - inicioLinea) / msPorLetra), 0, texto.length()); //cantidad de letras que va aumentando // constrain limita entre 0 y el largo del texto
  boolean escribiendo = (letras < texto.length()); // condicion para que sea true

  // --- Saltito del personaje al hablar ---
  int saltito = 0;
  if (escribiendo) 
  {
    saltito = int(abs(sin(ahora * 0.02)) * 4); // 4 es la amplitud máxima // 0.02 la velocidad
  }

  pushStyle(); // guarda la configuracion de colores
  
  background(0);
  
  // --- PERSONAJES EN INTRO ---
  if (hablaPollo) 
  {
    tint(255);
    image(donpollo, polloX, personajesY - saltito);
    tint(90);
    image(enrique, ranaX, personajesY);
  }
  else
  {
    tint(90);
    image(donpollo, polloX, personajesY);
    tint(255);
    image(enrique, ranaX, personajesY - saltito);
  }
  noTint();

  // --- DIBUJA SUBTÍTULOS ---
  textAlign(CENTER, CENTER); // da la colocacion centrada
  textSize(22); // tamaño de los nombres
  if (hablaPollo) 
  {
    fill(255, 200, 0); // color amarillo
  } 
  else 
  {
    fill(140, 220, 60); // color verde
  }
  text(nombres[hablando], width / 2, 470);

  textAlign(LEFT, CENTER); // de izquierda a derecha
  textSize(28);
  fill(255);
  float xTexto = ((width/2) - (textWidth(texto) / 2)); // posicion para que quede centrada
  text(texto.substring(0, letras), xTexto, 520); // le va pasando de a poco las letras

  // --- SKIP DE INTRO ---
  textAlign(RIGHT, BOTTOM);
  textSize(16);
  fill(150); // gris, para que no distraiga
  text("SKIP <ESPACIO>", width - 20, height - 15);

  // --- TRANSICION ---
  float transicion = 0;
  if (ahora - inicioIntro < duracionTransicion) // transicion cuando arranca el programa
  {
    transicion = map(ahora - inicioIntro, 0, duracionTransicion, 255, 0); // valor para la opacidad del caudro negro
  }
  if (saliendo) // transicion cuando termina la intro
  {
    transicion = constrain(map(ahora - inicioSalida, 0, duracionTransicion, 0, 255), 0, 255); // valor para la opacidad del caudro negro
  }
  noStroke();
  fill(0, transicion); // fill(negro, transparencia)
  rect(0, 0, width, height); // cuadro negro que ocupa toda la pantalla
  
  popStyle(); // restaura la configuracion de colores

  // saca la intro y mete el menú
  if (saliendo && ahora - inicioSalida >= duracionTransicion) 
  {
    enIntro = false;
    enMenu = true; // sigue el menú de selección de personaje
  }
}

// ================= MENÚ DE SELECCIÓN DE PERSONAJE =================
void dibujarMenu() 
{
  int n = opciones.length;
  pushStyle(); 
  background(0);

  // --- Título ---
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(52);
  text("Selecciona tu personaje", width / 2, 70);

  // --- Los vecinos ---
  int anterior = seleccion - 1;
  if (anterior < 0)          // si se pasó por abajo del primero
  {
    anterior = n - 1;        // vuelve al último
  }
  int siguiente = seleccion + 1;
  if (siguiente >= n)        // si se pasó por arriba del último
  {
    siguiente = 0;           // vuelve al primero
  }
  
  // pasa los datos necesarios a la funcion dibujarPersonaje
  dibujarPersonaje(opciones[anterior], width / 2 - separacion, 210, 100); // izquierda, chico y apagado
  dibujarPersonaje(opciones[siguiente], width / 2 + separacion, 210, 100); // derecha, chico y apagado
  dibujarPersonaje(opciones[seleccion], width / 2, 330, 255);             // centro, grande y completo

  // Nombre del personaje que está al centro
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(30);
  text(nombresPersonajes[seleccion], width / 2, 440);

  // Ayuda en el menú
  fill(200);
  textSize(16);
  text("Flechas izquierda / derecha: elegir          ENTER: jugar", width / 2, 540);
  popStyle();
}

// ------ DIBUJAR PERSONAJES EN MENU -------
void dibujarPersonaje(PImage img, float x, float tam, float opacidad) 
{
  tint(255, opacidad); 
  imageMode(CENTER);
  image(img, x, 290, tam, tam);
  imageMode(CORNER);
  noTint();
}

// ----- MOVER SELECCION EN MENÚ --------
void moverSeleccion(int dir) 
{
  int n = opciones.length;
  seleccion = seleccion + dir;   // dir vale 1 si va a la derecha o -1 para ir a la izquierda

  if (seleccion < 0)             // se pasó del primero hacia atrás
  {
    seleccion = n - 1;           // vuelve al último
  }
  if (seleccion >= n)            // se pasó del último hacia adelante
  {
    seleccion = 0;               // vuelve al primero
  }
}

// ----- COMIENZA EL JUEGO -------
void comenzarJuego() 
{
  personaje = opciones[seleccion];
  enMenu = false;
}

// ================= FUNCIONES DENTRO DEL JUEGO =================
// --------- GENERADOR DE NARANJAS ---------
void nuevoProyectil() 
{
  int borde = int(random(4)); // genera una naranja en cualquier borde

  if (borde == 0) {
    xProyectil = 0;
    yProyectil = random(height);
  } else if (borde == 1) {
    xProyectil = width;
    yProyectil = random(height);
  } else if (borde == 2) {
    xProyectil = random(width);
    yProyectil = 0;
  } else if (borde == 3) {
    xProyectil = random(width);
    yProyectil = height;
  }
}

// -------- KEY PRESSED ----------
void keyPressed() 
{
  if (enIntro) // solo se puede saltear con el skip
  {
    if (key == ' ' && !saliendo)
    {
      saliendo = true;          // empieza la salida
      inicioSalida = millis();  // reinicia el cronómetro del fundido
    }
    return;                     // el resto de las teclas se ignoran
  }

  // EN EL MENÚ SE USAN FLECHAS DE LOS COSTADOS PARA SELECCIONAR Y <ENTER> PARA EMPEZAR
  if (enMenu) 
  {
    if (keyCode == RIGHT) moverSeleccion(1);
    if (keyCode == LEFT) moverSeleccion(-1);
    if (key == ENTER) comenzarJuego();
    return;
  }

  // MOVIMIENTO DEL GATO EN EL JUEGO
  if (keyCode == RIGHT) derecha = true;
  if (keyCode == LEFT) izquierda = true;
  if (keyCode == UP) arriba = true;
  if (keyCode == DOWN) abajo = true;
  if (key == ' ') dash = true;
}

// DETECTA CUANDO SE DEJA DE APRETAR UNA TECLA
void keyReleased() 
{
  if (enIntro || enMenu) return;
  if (keyCode == RIGHT) derecha = false;
  if (keyCode == LEFT) izquierda = false;
  if (keyCode == UP) arriba = false;
  if (keyCode == DOWN) abajo = false;
  if (key == ' ') dash = false;
}
