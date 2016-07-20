import processing.net.*;
Server scoreServer;
Client scoreClient;

//Client variables
String serverIP = "192.168.0.14";
int    serverPort = 5208;
String receiveData;
int receiveInt = 0;

PImage score, clefs, annotations;
PImage editIcon, resetIcon, pencilIcon, eraserIcon, exitIcon, exitYes, exitNo, playIcon, pauseIcon, prevIcon, nextIcon;
String annotationsPath;
File annotationsFile;
PGraphics annotationsCanvas;
boolean annotationsChangedp = false; // Only save when annotationsChangedp

//To run as client set to true
final boolean clientp = false;

// To export frames set export to true
final boolean export = false;

final int fps = 25; // Frame rate

final int start = 122;  // Enter px for first event here
final int end = 19921;  // Enter px for "final barline" here
final float dur = 540;    // Enter durata in seconds here
final float preRoll = 8;  // Preroll in seconds (adds to total durata)

final int preRollFrames = ceil(preRoll * fps);
final float totalFrames = ceil(dur * fps); // float for use as divisor

boolean exitDialog = false;
int exitTimeout = 0;

boolean editMode = false;
boolean pencilMode = true;
boolean eraserMode = false;
int penSize = 2;

final color black = color(0, 0, 0);
final color red = color(255, 0, 0);
final color transparent = color(0, 0);
final color buttonBGcolor = color(255, 255, 255);
final color buttonActiveColor = color(255, 0, 0);
final int iconSize = 50;
final int iconPadding = 10;

int scoreX;
int editOffset = 0;
int scoreXadj;
int localScoreXadj = 0;
int preRollOffset;
int playheadPos;

int adjStart;
int adjEnd;

int frameCounter = 0;
boolean playingp = false; // playingp is only kept updated when !clientp
int incrValue = 0;

void setup() {
  frameRate(fps);
  size(800, 480);
  noSmooth();

  if (!clientp) {
    scoreServer = new Server(this, serverPort);
  } else {
    scoreClient = new Client(this, serverIP, serverPort);
  }

  score = loadImage("../../files/SCORE480p.PNG");
  clefs = loadImage("../../files/SCORE480p_clefs.PNG");
  annotationsCanvas = createGraphics(score.width, score.height);
  annotationsPath = sketchPath("../../files/annotations.png");
  annotationsFile = new File(annotationsPath);
  if (annotationsFile.exists())
  {
    annotations = loadImage("../../files/annotations.png");
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
  editIcon = loadImage("../../files/gui/edit-pencil-outline-in-circular-button.png");
  resetIcon = loadImage("../../files/gui/two-arrows-in-circular-outlined-interface-button.png");
  pencilIcon = loadImage("../../files/gui/pencil-outline-in-circular-button.png");
  eraserIcon = loadImage("../../files/gui/edit-eraser-outline-in-circular-button.png");
  exitIcon = loadImage("../../files/gui/upload-up-arrow-outline-in-circular-button.png");
  exitYes = loadImage("../../files/gui/checkmark-outlined-circular-button.png");
  exitNo = loadImage("../../files/gui/close-cross-thin-circular-button.png");
  playIcon = loadImage("../../files/gui/play-rounded-button-outline.png");
  pauseIcon = loadImage("../../files/gui/pause-thin-rounded-button.png");
  prevIcon = loadImage("../../files/gui/rewind-double-arrow-outlined-circular-button.png");
  nextIcon = loadImage("../../files/gui/fast-forward-thin-outlined-symbol-in-circular-button.png");


  playheadPos = round(width * 0.2);

  adjStart = (start - playheadPos);
  adjEnd = (end - playheadPos);

  if (export) {
    playingp = true;
    incrValue  = 1;
  }
} 

void draw() {
  background(255);
  cursor(CROSS);

  if (!clientp) {
    // Replace "frameCounter" with frame number to inspect specific frame
    scoreX = calcXPos(frameCounter);
    preRollOffset = calcOffset(preRollFrames);
    scoreXadj = (scoreX+preRollOffset);

    scoreServer.write(nfp(scoreXadj, 6));

    if (!editMode) {
      localScoreXadj = scoreXadj;
    }
    image(score, localScoreXadj-editOffset, 0);
    image(annotationsCanvas, localScoreXadj-editOffset, 0);

    if (localScoreXadj-editOffset < 0) {
      image(clefs, 0, 0);
    }
  } else {
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

    image(score, receiveInt, 0);

    image(annotationsCanvas, receiveInt, 0);

    if (receiveInt < 0) {
      image(clefs, 0, 0);
    }
  }

  // Draw ID markers
  for (int i = 0, j = 0; i < score.width; i+=500, j++) {
    textSize(32);
    fill(0, 102, 153);
    if (i != 0) {
      if (!clientp) {
        text(j, (i+localScoreXadj-editOffset), 32);
      } else {
        text(j, (i+receiveInt), 32);
      }
    }
  }

  // Draw playhead
  if (!editMode) {
    stroke(255, 0, 0);
    strokeWeight(5);
    strokeCap(SQUARE);
    line(playheadPos, 0, playheadPos, height);
  }

  // penSize cursor
  if (editMode) {
    if (mouseX < (width-iconSize-(iconPadding*2))) {
      noFill();
      stroke(255, 0, 0);
      strokeWeight(1);
      ellipse(mouseX, mouseY, penSize, penSize);
    }
  }

  //ICON PANEL
  if (editMode) {
    noStroke();
    fill(0, 0, 0, 31);
    rect((width-iconSize-(iconPadding*2)), 0, (iconSize+(iconPadding*2)), height);
  }

  //EDIT ICON
  // Raspberry Pi 3 cannot keep time as server while drawing annotations.
  // Therefore annotations are disabled for server while playingp == true

  if (!playingp) {
    noStroke();
    if (!editMode) {
      fill(buttonBGcolor);
    } else {
      fill(buttonActiveColor);
    }
    ellipse((width-iconSize-iconPadding+(iconSize*0.5)), iconPadding+(iconSize*0.5), iconSize, iconSize);
    image(editIcon, (width-iconSize-iconPadding), iconPadding, iconSize, iconSize);
  }

  //PENCIL/RESET ICON
  if (editMode) {
    noStroke();
    fill(buttonBGcolor);
    ellipse((width-iconSize-iconPadding+(iconSize*0.5)), (iconSize+(iconPadding*3)+(iconSize*0.5)), iconSize, iconSize);

    if (pencilMode) {
      noStroke();
      fill(buttonActiveColor);
      ellipse((width-iconSize-iconPadding+(iconSize*0.5)), (iconSize+(iconPadding*3)+(iconSize*0.5)), iconSize, iconSize);
    }
    image(pencilIcon, (width-iconSize-iconPadding), (iconSize+(iconPadding*3)), iconSize, iconSize);
  } else {
    if (!clientp) {
      noStroke();
      fill(buttonBGcolor);
      ellipse((width-iconSize-iconPadding+(iconSize*0.5)), (iconSize+(iconPadding*3)+(iconSize*0.5)), iconSize, iconSize);
      image(resetIcon, (width-iconSize-iconPadding), (iconSize+(iconPadding*3)), iconSize, iconSize);
    }
  }

  //ERASER/PLAY/PAUSE ICON
  if (editMode) {
    noStroke();
    fill(buttonBGcolor);
    ellipse((width-iconSize-iconPadding+(iconSize*0.5)), ((iconSize*2)+(iconPadding*5)+(iconSize*0.5)), iconSize, iconSize);

    if (eraserMode) {
      noStroke();
      fill(buttonActiveColor);
      ellipse((width-iconSize-iconPadding+(iconSize*0.5)), ((iconSize*2)+(iconPadding*5)+(iconSize*0.5)), iconSize, iconSize);
    }
    image(eraserIcon, (width-iconSize-iconPadding), ((iconSize*2)+(iconPadding*5)), iconSize, iconSize);
  } else {
    if (!clientp) {
      noStroke();
      fill(buttonBGcolor);
      ellipse((width-iconSize-iconPadding+(iconSize*0.5)), ((iconSize*2)+(iconPadding*5)+(iconSize*0.5)), iconSize, iconSize);
      if (playingp) {
        image(pauseIcon, (width-iconSize-iconPadding), ((iconSize*2)+(iconPadding*5)), iconSize, iconSize);
      } else {
        image(playIcon, (width-iconSize-iconPadding), ((iconSize*2)+(iconPadding*5)), iconSize, iconSize);
      }
    }
  }

  if (!clientp) {
    //PREV ICON
    noStroke();
    fill(buttonBGcolor);
    ellipse((width-iconSize-iconPadding+(iconSize*0.5)), ((iconSize*3)+(iconPadding*7)+(iconSize*0.5)), iconSize, iconSize);
    image(prevIcon, (width-iconSize-iconPadding), ((iconSize*3)+(iconPadding*7)), iconSize, iconSize);
    //NEXT ICON
    noStroke();
    fill(buttonBGcolor);
    ellipse((width-iconSize-iconPadding+(iconSize*0.5)), ((iconSize*4)+(iconPadding*9)+(iconSize*0.5)), iconSize, iconSize);
    image(nextIcon, (width-iconSize-iconPadding), ((iconSize*4)+(iconPadding*9)), iconSize, iconSize);
  }

  //EXIT ICON
  if (!editMode) {
    noStroke();
    fill(buttonBGcolor);
    ellipse((width-iconSize-iconPadding+(iconSize*0.5)), height-(iconSize*0.5)-iconPadding, iconSize, iconSize);
    image(exitIcon, (width-iconSize-iconPadding), height-iconSize-iconPadding, iconSize, iconSize);
    if (exitDialog) {
      if (exitTimeout < fps*3) {
        noStroke();
        fill(255);
        ellipse((width-(iconSize*2)-(iconPadding*3)+(iconSize*0.5)), height-(iconSize*0.5)-iconPadding, iconSize, iconSize);
        ellipse((width-(iconSize*3)-(iconPadding*5)+(iconSize*0.5)), height-(iconSize*0.5)-iconPadding, iconSize, iconSize);
        image(exitNo, (width-(iconSize*2)-(iconPadding*3)), height-iconSize-iconPadding, iconSize, iconSize);
        image(exitYes, (width-(iconSize*3)-(iconPadding*5)), height-iconSize-iconPadding, iconSize, iconSize);
        exitTimeout++;
      } else {
        exitDialog = false;
        exitTimeout = 0;
      }
    }
  }

  // Redraw
  if (frameCounter < (totalFrames + preRollFrames)) {
    if (export) {
      saveFrame("../../export/frames/score#######.png");
    }
  } else {
    if (export) {
      noLoop();
    }
    incrValue = 0;
    playingp = false;
  }

  frameCounter+=(incrValue);
}

int calcXPos(int frame) {
  float px;
  float xPos;

  if (frame == 0) {
    px = 0;
  } else {
    px = (frame / totalFrames);
  }

  xPos = (((px * adjEnd) + ((1 - px) * adjStart)) * -1);
  return round(xPos);
}

int calcOffset(int frame) {
  float px;
  float xPos;

  if (frame == 0) {
    px = 0;
  } else {
    px = (frame / totalFrames);
  }

  xPos = (px * adjEnd);
  return round(xPos);
}

void mousePressed() {
  //EXIT DIALOG
  if (exitDialog) {
    if ((mouseY > height-iconSize-iconPadding) && (mouseY < (height-iconPadding))) {
      if ((mouseX > (width-(iconSize*2)-(iconPadding*3))) && mouseX < (width-iconSize-(iconPadding*3))) {
        exitDialog = false;
        exitTimeout = 0;
      }
      if ((mouseX > (width-(iconSize*3)-(iconPadding*5))) && mouseX < (width-(iconSize*2)-(iconPadding*5))) {
        exit();
      }
    }
  }


  if ((mouseX > (width-iconSize-iconPadding)) && (mouseX < width-iconPadding)) {
    //EDIT MODE

    if (mouseY < (iconSize+(iconPadding*1)) && mouseY > iconPadding) {
      if (!playingp) {
        if (!editMode) {
          editMode = true;
        } else {
          pencilMode = true;
          penSize = 2;
          eraserMode = false;
          editMode = false;
          editOffset = 0;
          println(annotationsChangedp);
          if (annotationsChangedp) {
            annotationsChangedp = false; // reset
            annotationsCanvas.save("../../files/annotations.png");
          }
        }
      }
    }

    //PENCIL/RESET
    if (mouseY > (iconSize+(iconPadding*3)) && mouseY < ((iconSize*2)+(iconPadding*3))) {
      if (editMode) {
        if (!pencilMode) {
          pencilMode = true;
          eraserMode = false;
          penSize = 2;
        }
      } else {
        if (!clientp) {
          loop(); //in case noLoop() is active
          incrValue = 0;
          playingp = false;
          frameCounter = 0;
        }
      }
    }

    //ERASER/PLAY/PAUSE
    if (mouseY > ((iconSize*2)+(iconPadding*5)) && mouseY < ((iconSize*3)+(iconPadding*5))) {
      if (editMode) {
        if (!eraserMode) {

          pencilMode = false;
          eraserMode = true;
          penSize = 20;
        }
      } else {
        if (!clientp) {
          if (playingp == false) {
            incrValue = 1;
            playingp = true;
          } else {
            incrValue = 0;
            playingp = false;
          }
        }
      }
    }

    if (!clientp) {
      //PREV
      if (mouseY > ((iconSize*3)+(iconPadding*7)) && mouseY < ((iconSize*4)+(iconPadding*7))) {
        if (editMode) {
          editOffset = editOffset - (width/5*3);
        } else {
          frameCounter = frameCounter - (width/5*3);
        }
      }
      //NEXT
      if (mouseY > ((iconSize*4)+(iconPadding*9)) && mouseY < ((iconSize*5)+(iconPadding*9))) {
        if (editMode) {
          editOffset = editOffset + (width/5*3);
        } else {
          frameCounter = frameCounter + (width/5*3);
        }
      }
    }


    //EXIT
    if ((mouseY > (height-iconSize-iconPadding)) && mouseY < (height-iconPadding)) {
      if (!editMode) {
        exitDialog = true;
        //exit();
      }
    }
  }


  if (mouseX < (width-iconSize-(iconPadding*2))) {
    if (editMode) {
      if (!annotationsChangedp) {
        // Notify when annotations are made
        annotationsChangedp = true;
      }
      if (pencilMode) {
        drawFunctionBegin(black);
      }
      if (eraserMode) {
        drawFunctionBegin(red);
      }
    }
  }
}


void mouseDragged() {
  if (mouseX < (width-iconSize-(iconPadding*2))) {
    if (editMode) {
      if (!annotationsChangedp) {
        // Notify when annotations are made
        annotationsChangedp = true;
      }
      if (pencilMode) {
        drawFunctionContinue(black);
      }
      if (eraserMode) {
        drawFunctionContinue(red);
      }
    }
  }
}

void mouseReleased() {
  if (editMode) {
    if (eraserMode) {
      eraseFunction(red);
    }
  }
}


void drawFunctionBegin(color c) {
  annotationsCanvas.beginDraw();
  annotationsCanvas.noStroke();
  annotationsCanvas.fill(c);
  if (!clientp) {
    annotationsCanvas.ellipse(mouseX-localScoreXadj+editOffset, mouseY, penSize, penSize);
  } else {
    annotationsCanvas.ellipse(mouseX-receiveInt, mouseY, penSize, penSize);
  }
  annotationsCanvas.endDraw();
}

void drawFunctionContinue(color c) {
  annotationsCanvas.beginDraw();
  annotationsCanvas.stroke(c);
  annotationsCanvas.strokeWeight(penSize);
  if (!clientp) {
    annotationsCanvas.line(pmouseX-localScoreXadj+editOffset, pmouseY, mouseX-localScoreXadj+editOffset, mouseY);
  } else {
    annotationsCanvas.line(pmouseX-receiveInt, pmouseY, mouseX-receiveInt, mouseY);
  }
  annotationsCanvas.endDraw();
}

void drawFunctionEnd(color c) {
  annotationsCanvas.beginDraw();
  annotationsCanvas.stroke(c);
  annotationsCanvas.strokeWeight(penSize);
  if (!clientp) {
    annotationsCanvas.line(pmouseX-localScoreXadj+editOffset, pmouseY, mouseX-localScoreXadj+editOffset, mouseY);
  } else {
    annotationsCanvas.line(pmouseX-receiveInt, pmouseY, mouseX-receiveInt, mouseY);
  }

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