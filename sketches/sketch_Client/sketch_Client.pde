import processing.net.*; 
Client scoreClient; 

PImage score;
PImage clefs;
PImage annotations;
String annotationsPath;
File annotationsFile;
PGraphics annotationsCanvas;

final int fps = 25;

boolean editMode = false;
int penSize = 2;

final color black = color(0, 0, 0);
final color red = color(255, 0, 0);
final color transparent = color(0, 0);

String serverIP = "192.168.0.22";
int    serverPort = 5208;
String receiveData;
int receiveInt = 0;
int playheadPos;

void setup() {
  frameRate(fps);
  size(800, 480);
  noSmooth();

  scoreClient = new Client(this, serverIP, serverPort);

  score = loadImage("../files/SCORE480p.PNG");
  clefs = loadImage("../files/SCORE480p_clefs.PNG");
  annotationsCanvas = createGraphics(score.width, score.height);
  annotationsPath = sketchPath("../files/annotations.png");
  annotationsFile = new File(annotationsPath);
  if (annotationsFile.exists())
  {
    annotations = loadImage("../files/annotations.png");
    annotationsCanvas.beginDraw();
    annotations.loadPixels();
    annotationsCanvas.loadPixels();
    arrayCopy(annotations.pixels, annotationsCanvas.pixels);
    annotationsCanvas.updatePixels();
    annotationsCanvas.endDraw();
  } else {
    // To avoid crashes when saving files without contents
    annotationsCanvas.beginDraw();
    annotationsCanvas.endDraw();
  }

  playheadPos = round(width * 0.2);
} 

void draw() {
  background(255);

if (!editMode) {
  // Packages can get lost, concatenated or scrambled in transit.
  // Therefore multiple integrity checks are performed.
  if (scoreClient.available() > 0) { 
    receiveData = scoreClient.readString();
    if (receiveData.charAt(0) == '+' | receiveData.charAt(0) == '-') {
      if (receiveData.length() == 7) {
        receiveInt = int(receiveData);
      } else {
        if (receiveData.length() > 7) {
          receiveInt = int(receiveData.substring(0, 7));
        }
      }
    }
  }
}

  print("Received Package: ");
  print(receiveData);
  print ("  int(): ");
  println(receiveInt);

  image(score, receiveInt, 0);
  
  image(annotationsCanvas, receiveInt, 0);

  if (receiveInt < 0) {
    image(clefs, 0, 0);
  }

  // Draw ID markers
  for (int i = 0, j = 0; i < score.width; i+=500, j++) {
    textSize(32);
    fill(0, 102, 153);
    if (i != 0) {
      text(j, (i+receiveInt), 32);
    }
  }

  // Draw playhead
  stroke(255, 0, 0);
  strokeWeight(5);
  strokeCap(SQUARE);
  line(playheadPos, 0, playheadPos, height);
  
  if (editMode) {
    // Causes problems; ID markers jump downwards when edit mode is engaged
    //fill(255, 0, 0);
    //textSize(25);
    //textAlign(CENTER, TOP);
    //text("EDIT MODE", 0, 15, width, height);
    noFill();
    stroke(255, 0, 0);
    strokeWeight(10);
    rect(5, 5, width-10, height-10);
    stroke(255, 0, 0);
    strokeWeight(1);
    ellipse(mouseX, mouseY, penSize, penSize);
  }
  
  if (editMode) {
    noCursor();
  } else {
    cursor(CROSS);
  }
}

void mousePressed() {
  if (editMode) {
    if (mouseButton == LEFT) {
      drawFunctionBegin(black);
    }
    if (mouseButton == RIGHT) {
      drawFunctionBegin(red);
    }
  }
}

void mouseDragged() {
  if (editMode) {
    if (mouseButton == LEFT) {
      drawFunctionContinue(black);
    }
    if (mouseButton == RIGHT) {
      drawFunctionContinue(red);
    }
  }
}

void mouseReleased() {
  if (editMode) {
    if (mouseButton == LEFT) {
      //drawFunctionEnd(black);
    }
    if (mouseButton == RIGHT) {
      //drawFunctionEnd(red);
      eraseFunction(red);
    }
  }
}

void drawFunctionBegin(color c) {
  annotationsCanvas.beginDraw();
  annotationsCanvas.noStroke();
  annotationsCanvas.fill(c);
  annotationsCanvas.ellipse(mouseX-receiveInt, mouseY, penSize, penSize);
  annotationsCanvas.endDraw();
}

void drawFunctionContinue(color c) {
  annotationsCanvas.beginDraw();
    annotationsCanvas.stroke(c);
    annotationsCanvas.strokeWeight(penSize);
    annotationsCanvas.line(pmouseX-receiveInt, pmouseY, mouseX-receiveInt, mouseY);
  annotationsCanvas.endDraw();
}

void drawFunctionEnd(color c) {
  annotationsCanvas.beginDraw();
    annotationsCanvas.stroke(c);
    annotationsCanvas.strokeWeight(penSize);
    annotationsCanvas.line(pmouseX-receiveInt, pmouseY, mouseX-receiveInt, mouseY);
  annotationsCanvas.endDraw();
}

void eraseFunction(color c) {
  annotationsCanvas.loadPixels();
  for (int i = 0; i < annotationsCanvas.width*annotationsCanvas.height; i++) {
    if (annotationsCanvas.pixels[i] == c) {
      annotationsCanvas.pixels[i] = transparent;
    }
  }
  annotationsCanvas.updatePixels();
}

void keyPressed() {
//  if (key == 32) { // Play/pause with space bar
//    if (playToggle == 0) {
//      incrValue = 1;
//      playToggle = 1;
//    } else {
//      incrValue = 0;
//      playToggle = 0;
//    }
//  }

  //if (key == 'r') { // 'reset': set counter to 0
  //  loop(); //in case noLoop() is active
  //  incrValue = 0;
  //  playToggle = 0;
  //  frameCounter = 0;
  //}

  //if (key == 'n') { // 'next': skip forward 5 seconds
  //  frameCounter+=(5*fps);
  //}
  //if (key == 'N') { // 'Next': skip forward 30 seconds
  //  frameCounter+=(30*fps);
  //}
  //if (key == 'b') { // 'back': skip backwards 5 seconds
  //  frameCounter-=(5*fps);
  //}
  //if (key == 'B') { // 'Back': skip backwards 30 seconds
  //  frameCounter-=(30*fps);
  //}
  
  if (key == 'e') {
    if (!editMode) {
      editMode = true;
    } else {
      editMode = false;
      annotationsCanvas.save("../files/annotations.png");
    }
  }

  if (key == '1') {
    penSize = 2;
  }
  if (key == '2') {
    penSize = 5;
  }
  if (key == '3') {
    penSize = 10;
  }
  if (key == '4') {
    penSize = 25;
  }
  if (key == '5') {
    penSize = 100;
  }
}