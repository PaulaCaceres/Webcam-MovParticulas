//CAPTURA VIDEO//
import processing.video.*;
Capture video;
int camPixels;
PImage antesPixels;
//CAPTURA VIDEO//

boolean verBola = false;

//WRITER//
/*
PrintWriter output;
 String mouseRecord;
 */
//WRITER//

//READER//
// Variables globales para el reader
BufferedReader reader;
// String line para sacar lo que leyó reader
String line;
// ArrayList de PVector para guardar la información grabada en el .txt
ArrayList<PVector> movimiento;
int i = 0;
//READER//


// Objeto mover del tipo Mover (class creada)
Mover m;
// Declarar ArrayList. Llenarlo con objetos Vehicle
ArrayList<Mover> movers;
int cuantas = 40;
PImage fondo;

void setup() {
  size(1280, 720);
  hint(ENABLE_DEPTH_SORT);
  
  //CAPTURA VIDEO//
  String[] cameras = Capture.list();
  printArray(cameras);
  
  // Empezar la captura
  video = new Capture(this, width, height);
  // Para elegir la cámara 
  // video = new Capture(this, cameras[0]);
  
  //Capturar imágenes de la cámara
  video.start();
  
  camPixels = video.width * video.height;
  // Almacenar la imagen anterior (el fondo) en un array
  antesPixels = new PImage (video.width, video.height);
  // Cargar los pixeles para poder manipularlos
  loadPixels();
  //CAPTURA VIDEO//

  // READER //
  // Se crea un objeto para que lea el archivo "positions.txt"
  reader = createReader("positions.txt"); 
  // Iniciar el ArrayList de PVector vacío
  movimiento = new ArrayList<PVector>();

  // Prueba leer el .txt a menos que sea nulo o tenga un problema
  try {  
    // readLine() saca la información del archivo .txt que leyó el reader  
    line = reader.readLine();
  } 
  catch (IOException e) {
    e.printStackTrace();
    line = null;
  }
  // Si line está vacía o con error, dejar de leer..
  if (line == null) {    
    noLoop();
    // .. sino crear un ArrayList movimiento y separar line por parejas
  } else {                
    // Meter el array que devuelve split (line) en el array lista
    String[] lista = split(line, ",");
    // Chequear que el array lista contenga los valores de line separados
    // printArray(lista);
    // Meter cada elemento del array lista en el ArrayList movimiento
    // usando un for que corre tantas veces como elementos haya en lista
    for (int i = 0; i < lista.length - 1; i++) {
      // Chequear que el array lista esté lleno con los valores de split line
      // println(lista[i]);
      // Meter el array que devuelve split(lista) en el array xy  
      String[] xy = split(lista[i], "-");
      // Chequear que el array xy esté lleno con los valores split lista
      // println(xy[0] + "," + xy[1]);
      // Nuevo vector valores para sumarle al ArrayList movimiento en cada bucle del for
      PVector valores = new PVector();
      valores.x = float(xy[0]);
      valores.y = float(xy[1]);
      // print(valores.x+"-"+valores.y+"--");
      // Agregar el vector nuevo (valores) hasta la cantidad de lista.length
      movimiento.add(valores);
      //print(movimiento);
    }
  }  
  // READER //

  fondo = loadImage ("fondo.png");
  // Iniciar ArrayList. 
  // Añadir un objeto Vehicle a vehicles hasta completar la cantidad de la variable cuantas
  movers = new ArrayList<Mover>();
  for (int i = 0; i < cuantas; i++) {
    movers.add(new Mover());
  }
}


void draw() {
  //background(0);
  
  
  //CAPTURA VIDEO//
  int threshold = 350000000;
  int presenceSum = 0;
    
   if (video.available()) {
    // Leer nuevo frame de video
    video.read(); 
    // Hacer disponibles los pixels del video
    video.loadPixels(); 
    
    // Diferencia entre el frame actual y el fondo almacenado
    // Límite para comparar si el cambio entre las dos imágenes es mayor a...
    
    
    // Para cada pixel de video de la cámara, tomar el color actual y el anterior de ese pixel
    for (int i = 0; i < camPixels; i++) { 
      color currentColor = video.pixels[i];
      color backgroundColor = antesPixels.pixels[i];
      
      // Extraer los colores de los píxeles del frame actual
      int currentR = (currentColor >> 16) & 0xFF;
      int currentG = (currentColor >> 8) & 0xFF;
      int currentB = currentColor & 0xFF;
      
      // Extraer los colores de los píxeles del fondo
      int backgroundR = (backgroundColor >> 16) & 0xFF;
      int backgroundG = (backgroundColor >> 8) & 0xFF;
      int backgroundB = backgroundColor & 0xFF;
    
      // Computar la diferencia entre los colores
      int diffR = abs(currentR - backgroundR);
      int diffG = abs(currentG - backgroundG);
      int diffB = abs(currentB - backgroundB);
      
      // Sumar las diferencias a la cuenta
      presenceSum += diffR + diffG + diffB;
      
      // Renderizar la imagen diferente en la pantalla
      pixels[i] = color(diffR, diffG, diffB);
    }
    
   //Ver los pixeles del array que cambiaron y escribir la diferencia
   updatePixels();
   println(presenceSum); 
   
   image(fondo, 0, 0);
   
     i = i+1;

  if (i>=movimiento.size()) {
    i=0;
  }

  PVector mov = new PVector();
  //mov = movimiento.get(i);
  mov.y = sin(millis()/500.0)*300 + 300;
  mov.x = sin(millis()/1000.0)*900 + width/2;
  if (verBola) ellipse(mov.x, mov.y, 10, 10);
  // Crear vector mouse para guardar la posición del mouse en x e y
  // Comentarlo si ya se grabó "positions.txt"
  // PVector mouse = new PVector(mouseX, mouseY); 
  //pushMatrix();
 // translate(-width, 0, 0);
  for (Mover m : movers) {  
    m.arrive(mov);        // Update the location
    m.update();
    m.display();          // Display the Mover
    m.separate(movers);   //if (mov.x < height/4)
  }
  //popMatrix();
   
   //Si la diferencia es mayor al límite
   if (presenceSum > threshold) {
      //movers.remove(i);
      fill(200,255,200);
      ellipse(500,500,100,100);
      } 
  }

  // WRITER //
  /*
    if (mousePressed == true) {
   // llenar String mouseRecord con las parejas x e y separadas
   mouseRecord = mouseRecord+mouseX+"-"+mouseY+",";
   print(mouseRecord);         
   } 
   */
  // WRITER //
 
}

// WRITER //
/*
void mouseReleased() {
 output.print(mouseRecord);  // Write the coordinate to the file
 output.flush();             // Writes the remaining data to the file
 output.close();             // Finishes the file
 exit();                     // Stops the program
 }
 */
// WRITER //


void mouseReleased() {
  verBola = !verBola;
}