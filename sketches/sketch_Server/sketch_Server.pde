//PiScore - a system for playing back video scores and keeping in sync
//across multiple devices.
//Copyright (C) 2016  David Stephen Grant
//    
//This file is part of PiScore.
//
//PiScore is free software: you can redistribute it and/or modify
//it under the terms of the GNU General Public License as published by
//the Free Software Foundation, either version 3 of the License, or
//(at your option) any later version.
//
//PiScore is distributed in the hope that it will be useful,
//but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//GNU General Public License for more details.
//
//You should have received a copy of the GNU General Public License
//along with PiScore.  If not, see <http://www.gnu.org/licenses/>.
//
//Included musical scores are not licensed under GPLv3 and may be
//protected by Copyright.

import processing.net.*;
Server scoreServer;
Client scoreClient;

String[] serverIpAddrArray = { null };
String serverIpAddrPath;
File serverIpAddrFile;
String serverIpAddr;
int    serverPort = 5208;
String receiveData;
int receiveInt = 0;

PImage score, clefs, annotations;
PImage editIcon, resetIcon, pencilIcon, eraserIcon, exitIcon, exitYes, exitNo, playIcon, pauseIcon, prevIcon, nextIcon;
String annotationsPath;
File annotationsFile;
PGraphics annotationsCanvas;
boolean annotationsChangedp = false; // Only save when annotationsChangedp

String[] clientpArray = { null };
String clientpPath;
File clientpFile;
boolean clientp;

String[] vOffsetArray = { null };
String vOffsetPath;
File vOffsetFile;
int vOffset;

String[] zoomArray = { null };
String zoomPath;
File zoomFile;
float zoom;

// To export frames set export to true
final boolean export = false;

final int fps = 25; // Frame rate

final int start = 122;  // Enter px for first event here
final int end = 19921;  // Enter px for "final barline" here
final float dur = 540;    // Enter durata in seconds here

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
int iconPanelWidth;

int scoreX;
int scoreXScaled;
int editOffsetValue;
int editOffset = 0;
int editOffsetScaled = 0;
int scoreXadj;
int scoreXadjScaled;
int localScoreX = 0;
int playheadPos;
int adjStart;
int adjStartScaled;
int adjEnd;

int smoothScroller = 0;
int frameCounter = 0;
boolean playingp = false; // playingp is only kept updated when !clientp
int incrValue = 0;

void setup() {
  frameRate(fps);
  size(800, 480);
  noSmooth();

  serverIpAddrPath = sketchPath("../../etc/server-ip-addr.txt");
  serverIpAddrFile = new File(serverIpAddrPath);
  if (serverIpAddrFile.exists()) {
    serverIpAddrArray = loadStrings(serverIpAddrPath);
  } else {
    serverIpAddrArray[0] = "192.168.0.14"; // Arbitrary default
    saveStrings(serverIpAddrPath, serverIpAddrArray);
  }
  serverIpAddr = serverIpAddrArray[0];
  
  vOffsetPath = sketchPath("../../etc/voffset.txt");
  vOffsetFile = new File(vOffsetPath);
  if (vOffsetFile.exists()) {
    vOffsetArray = loadStrings(vOffsetPath);
  } else {
    vOffsetArray[0] = "0";
    saveStrings(vOffsetPath, vOffsetArray);
  }
  vOffset = int(vOffsetArray[0]);
  
  zoomPath = sketchPath("../../etc/zoom.txt");
  zoomFile = new File(zoomPath);
  if (zoomFile.exists()) {
    zoomArray = loadStrings(zoomPath);
  } else {
    zoomArray[0] = "1.0";
    saveStrings(zoomPath, zoomArray);
  }
  zoom = float(zoomArray[0]);

  clientpPath = sketchPath("../../etc/clientp.txt");
  clientpFile = new File(clientpPath);
  if (clientpFile.exists()) {
    clientpArray = loadStrings(clientpPath);
  } else {
    clientpArray[0] = "false"; // Defaults to server
    saveStrings(clientpPath, clientpArray);
  }
  clientp = boolean(clientpArray[0]);

  if (!clientp) {
    scoreServer = new Server(this, serverPort);
  } else {
    scoreClient = new Client(this, serverIpAddr, serverPort);
  }

  score = loadImage("../../files/SCORE.PNG");
  clefs = loadImage("../../files/SCORE_CLEFS.PNG");
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

  iconPanelWidth = (iconSize+(iconPadding*2));

  playheadPos = round(width * 0.2);

  adjStart = (start - playheadPos);
  adjStartScaled = round((start*zoom) - playheadPos);
  adjEnd = (end - playheadPos);

  editOffsetValue = round(((width)/5*3));

  if (export) {
    playingp = true;
    incrValue  = 1;
  }
} 

void draw() {
  background(255);
  if (editMode) {
    fill(0, 0, 0, 50);
    rect(0, 0, (width-iconPanelWidth), height);
  }
  
  cursor(CROSS);
  if (!clientp) {
    // Replace "frameCounter" with frame number to inspect specific frame
    scoreX = calcXPos(frameCounter);
    scoreXScaled = round(scoreX*zoom);
    scoreServer.write(nfp(scoreX, 6));

    if (!editMode) {
      localScoreX = scoreXScaled;
    }
  } else {
    if (!editMode) {
      // Packages can get lost, concatenated or scrambled in transit.
      // Therefore multiple integrity checks are performed.
      if (scoreClient.available() > 0) { 
        receiveData = scoreClient.readString();
        if (receiveData.charAt(0) == '+' | receiveData.charAt(0) == '-') {
          if (receiveData.length() == 7) {
            localScoreX = int(receiveData);
            localScoreX = round(localScoreX * zoom);
          } else {
            if (receiveData.length() > 7) {
              localScoreX = int(receiveData.substring(0, 7));
              localScoreX = round(localScoreX * zoom);
            }
          }
        }
      }
    }
  }

  if (smoothScroller != 0) {
    int pxPerFrame = round((editOffsetValue/(fps*0.1)));
    if (abs(smoothScroller) < pxPerFrame) {
      smoothScroller = 0;
    } else {
      if (smoothScroller > 0) {
        smoothScroller = smoothScroller - pxPerFrame;
      }
      if (smoothScroller < 0) {
        smoothScroller = smoothScroller + pxPerFrame;
      }
    }
  }

  image(score, localScoreX-(editOffset-smoothScroller)+playheadPos-(start*zoom), vOffset, (score.width)*zoom, (score.height)*zoom);
  image(annotationsCanvas, localScoreX-(editOffset-smoothScroller)+playheadPos-(start*zoom), vOffset, (annotationsCanvas.width)*zoom, (annotationsCanvas.height)*zoom);

  if (((clefs.width)*zoom) < playheadPos) {
    if (localScoreX-editOffset < (0 + adjStartScaled)) {
      image(clefs, 0, vOffset, (clefs.width)*zoom, (clefs.height)*zoom);
    }
  }


  // Draw ID markers
  for (int i = 0, j = 0; i < score.width; i+=500, j++) {
    textAlign(CENTER, TOP);
    textSize(32);
    fill(0, 102, 153);
    text(j, (round(i*zoom)+localScoreX-(editOffset-smoothScroller)+playheadPos), 0);
  }

  // Draw playhead and IP
  if (!editMode) {
    stroke(255, 0, 0, 150);
    strokeWeight(5);
    strokeCap(SQUARE);
    line(playheadPos, 0, playheadPos, height);
  } else {
    fill(0, 102, 0);
    textAlign(LEFT, BOTTOM);
    textSize(12);
    if (clientp) {
      text(("Connected to Server at " + scoreClient.ip()), 0, height);
    }
  }

  // penSize cursor
  if (editMode) {
    if (mouseX < (width-(iconSize+(iconPadding*2)))) {
      noFill();
      stroke(255, 0, 0);
      strokeWeight(1);
      ellipse(mouseX, mouseY, penSize*zoom, penSize*zoom);
    }
  }

  //ICON PANEL
  if (editMode) {
    noStroke();
    fill(0, 0, 0, 50);
    rect((width-iconPanelWidth), 0, iconPanelWidth, height);
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

  if (!clientp || editMode) {
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
  if (frameCounter < totalFrames) {
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

  xPos = (((px * adjEnd) + (((1 - px) - 1) * adjStart)) * -1);
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
  if (smoothScroller == 0) {
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
          editOffsetScaled = 0;
          smoothScroller = 0;
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

    if (!clientp || editMode) {
      //PREV
      if (mouseY > ((iconSize*3)+(iconPadding*7)) && mouseY < ((iconSize*4)+(iconPadding*7))) {
        if (editMode) {
          editOffset = editOffset - editOffsetValue;
          smoothScroller = smoothScroller - editOffsetValue;
          editOffsetScaled = round(editOffset/zoom);
        } else {
          frameCounter = frameCounter - (fps*5);
        }
      }
      //NEXT
      if (mouseY > ((iconSize*4)+(iconPadding*9)) && mouseY < ((iconSize*5)+(iconPadding*9))) {
        if (editMode) {
          editOffset = editOffset + editOffsetValue;
          smoothScroller = smoothScroller + editOffsetValue;
          editOffsetScaled = round(editOffset/zoom);
        } else {
          frameCounter = frameCounter + (fps*5);
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


  if (mouseX > ((clefs.width)*zoom) && mouseX < (width-iconSize-(iconPadding*2))) {
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
}


void mouseDragged() {
  if (mouseX > clefs.width && mouseX < (width-iconSize-(iconPadding*2))) {
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
  annotationsCanvas.ellipse((mouseX/zoom)-((localScoreX/zoom)-editOffsetScaled)+(adjStartScaled/zoom), ((mouseY/zoom)-(vOffset/zoom)), penSize, penSize);
  annotationsCanvas.endDraw();
}

void drawFunctionContinue(color c) {
  annotationsCanvas.beginDraw();
  annotationsCanvas.stroke(c);
  annotationsCanvas.strokeWeight(penSize);
  annotationsCanvas.line((pmouseX/zoom)-((localScoreX/zoom)-editOffsetScaled)+(adjStartScaled/zoom), ((pmouseY/zoom)-(vOffset/zoom)), (mouseX/zoom)-((localScoreX/zoom)-editOffsetScaled)+(adjStartScaled/zoom), ((mouseY/zoom)-(vOffset/zoom)));
  annotationsCanvas.endDraw();
}

void drawFunctionEnd(color c) {
  annotationsCanvas.beginDraw();
  annotationsCanvas.stroke(c);
  annotationsCanvas.strokeWeight(penSize);
  annotationsCanvas.line((pmouseX/zoom)-((localScoreX/zoom)-editOffsetScaled)+(adjStartScaled/zoom), ((pmouseY/zoom)-(vOffset/zoom)), (mouseX/zoom)-((localScoreX/zoom)-editOffsetScaled)+(adjStartScaled/zoom), ((mouseY/zoom)-(vOffset/zoom)));
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