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
//Included musical scores are not issued with any license and may
//be protected by Copyright.

import processing.net.*;
import processing.sound.*;

Server scoreServer;
Client scoreClient;

String rootPath;

String[] serverIpAddrArray = { null };
String serverIpAddrPath;
File serverIpAddrFile;
String serverIpAddr;
int    serverPort = 5208;
String receiveData;
int receiveInt = 0;

PImage score, clefs, annotations;
PImage editIcon, resetIcon, pencilIcon, eraserIcon, exitIcon, exitYes, exitNo, playIcon, pauseIcon, prevIcon, nextIcon, plusIcon, minusIcon, zoomIcon, upIcon, downIcon, zeroIcon, saveIcon;
String annotationsPath;
File annotationsFile;
PGraphics annotationsCanvas;
boolean annotationsChangedp = false; // Only save when annotationsChangedp

String[] projectArray = { null };
String   projectPath;
File     projectFile;
String   projectParent;
String   projectName;

String[] audioArray = { null };
String   audioPath;
File     audioFile;
SoundFile playbackFile;

String[] userSettingsArray = { null, null, null, null, null, null, null, null };
String userSettingsPath;
File userSettingsFile;
float[] userSettings = { 0, 0, 0, 0, 0, 0, 0, 0 };

String[] clientpArray = { null };
String clientpPath;
File clientpFile;
boolean clientp;

// To export frames set export to true
final boolean export = false;

final int fps = 25; // Frame rate

int start;
int end;
int clefsStart;
int clefsEnd;
float dur;
float preRoll;
float zoom;
int vOffset;

boolean navigationChangedp = false;

float totalFrames; // float for use as divisor

float screenScale = 1.0;

boolean exitDialog = false;
int exitTimeout = 0;

boolean zoomDialog = false;

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
int frameCounter;
boolean playingp = false; // playingp is only kept updated when !clientp
int incrValue = 0;

boolean audioplayingp = false;

int saveTextOpacity = 0;

void setup() {
  frameRate(fps);
  size(800, 480);
  noSmooth();

  rootPath = ((new File((new File (sketchPath(""))).getParent())).getParent());

  projectPath = rootPath + "/etc/project-path";
  projectFile = new File(projectPath);
  if (projectFile.exists()) {
    projectArray = loadStrings(projectPath);
  } else {
    projectArray[0] = rootPath + "/examplescore/examplescore.png"; // Default to example score
    saveStrings(projectPath, projectArray);
  }
  projectParent = (new File (projectArray[0])).getParent();
  projectName = getNameWithoutExt(new File (projectArray[0]));

  serverIpAddrPath = rootPath + "/etc/server-ip-addr";
  serverIpAddrFile = new File(serverIpAddrPath);
  if (serverIpAddrFile.exists()) {
    serverIpAddrArray = loadStrings(serverIpAddrPath);
  } else {
    serverIpAddrArray[0] = "192.168.0.14"; // Arbitrary default
    saveStrings(serverIpAddrPath, serverIpAddrArray);
  }
  serverIpAddr = serverIpAddrArray[0];

  clientpPath = rootPath + "/etc/clientp";
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

  if (!clientp) {
    audioPath = rootPath + "/etc/audio-path";
    audioFile = new File(audioPath);
    if (audioFile.exists()) {
      audioArray = loadStrings(audioPath);
      playbackFile = new SoundFile(this, audioArray[0]);
    } // else audioArray[0] = null
  }

  userSettingsPath = projectParent + "/" + projectName + ".piscore";
  userSettingsFile = new File(userSettingsPath);
  if (userSettingsFile.exists()) {
    userSettingsArray = loadStrings(userSettingsPath);
    for (int i = 0; i < (userSettingsArray.length); i++) {
      userSettings[i] = float(userSettingsArray[i]);
    }
  } else {
    // Defaults adjusted for example score
    userSettings[0] = -284.0;
    userSettings[1] = -13404.0;
    userSettings[2] = -160.0;
    userSettings[3] = -240.0;
    userSettings[4] = 180.0;
    userSettings[5] = 4.0;
    userSettings[6] = 1.0;
    userSettings[7] = 0.0;
    for (int i = 0; i < (userSettings.length); i++) {
      userSettingsArray[i] = str((userSettings[i]));
    }
    saveStrings(userSettingsPath, userSettingsArray);
  }

  start =      int(-userSettings[0]);
  end =        int(-userSettings[1]);
  clefsStart = int(-userSettings[2]);
  clefsEnd =   int(-userSettings[3]);
  dur =        userSettings[4];
  preRoll =    userSettings[5];
  zoom =       userSettings[6];
  vOffset =    int(userSettings[7]);
  if (clefsStart < 0) {
    clefsStart = 0;
  }
  if (clefsEnd < clefsStart) {
    clefsEnd = clefsStart;
  }

  score = loadImage(projectArray[0]);
  clefs = score.get(clefsStart, 0, clefsEnd-clefsStart, score.height);

  totalFrames = ceil(dur * fps);
  frameCounter = round(-(preRoll*fps));

  annotationsCanvas = createGraphics(score.width, score.height);
  annotationsPath = projectParent + "/" + projectName + "-annotations.png";
  annotationsFile = new File(annotationsPath);
  if (annotationsFile.exists())
  {
    annotations = loadImage(annotationsPath);
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
  editIcon = loadImage(rootPath + "/gui/black-edit-pencil-outline-in-circular-button.png");
  resetIcon = loadImage(rootPath + "/gui/black-two-arrows-in-circular-outlined-interface-button.png");
  pencilIcon = loadImage(rootPath + "/gui/black-pencil-outline-in-circular-button.png");
  eraserIcon = loadImage(rootPath + "/gui/black-edit-eraser-outline-in-circular-button.png");
  exitIcon = loadImage(rootPath + "/gui/black-upload-up-arrow-outline-in-circular-button.png");
  exitYes = loadImage(rootPath + "/gui/black-checkmark-outlined-circular-button.png");
  exitNo = loadImage(rootPath + "/gui/black-close-cross-thin-circular-button.png");
  playIcon = loadImage(rootPath + "/gui/black-play-rounded-button-outline.png");
  pauseIcon = loadImage(rootPath + "/gui/black-pause-thin-rounded-button.png");
  prevIcon = loadImage(rootPath + "/gui/black-rewind-double-arrow-outlined-circular-button.png");
  nextIcon = loadImage(rootPath + "/gui/black-fast-forward-thin-outlined-symbol-in-circular-button.png");
  plusIcon = loadImage(rootPath + "/gui/black-add-circular-button-thin-symbol.png");
  minusIcon = loadImage(rootPath + "/gui/black-minus-sign-in-a-circle.png");
  zoomIcon = loadImage(rootPath + "/gui/black-magnifier-search-interface-circular-button.png");
  upIcon = loadImage(rootPath + "/gui/black-up-rounded-button-outline.png");
  downIcon = loadImage(rootPath + "/gui/black-down-rounded-button-outline.png");
  zeroIcon = loadImage(rootPath + "/gui/black-zero-circular-graphics-button-outlined-symbol.png");
  saveIcon = loadImage(rootPath + "/gui/black-projector-outlined-symbol-in-circular-button.png");

  screenScale = (height/float(score.height));

  iconPanelWidth = (iconSize+(iconPadding*2));

  playheadPos = round(width * 0.2);

  editOffsetValue = round(((width)/5*3));

  if (export) {
    playingp = true;
    incrValue  = 1;
  }
} 

void draw() {
  background(255);

  println(frameCounter);


  if (!clientp) {
    if (playingp) {
      if (frameCounter >= 0) {
        if (audioArray[0] != null) {
          if (!audioplayingp) {
            audioplayingp = true;
            playbackFile.jump(float(frameCounter/fps));
            //playbackFile.play();
          }
        }
      }
    }
  }

  adjStart = (start - playheadPos);
  adjStartScaled = round((start*zoom) - playheadPos);
  adjEnd = (end - playheadPos);

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

  image(score, localScoreX-(editOffset-smoothScroller)+playheadPos-(start*zoom), vOffset, round((score.width)*zoom), (score.height)*zoom);
  image(annotationsCanvas, localScoreX-(editOffset-smoothScroller)+playheadPos-(start*zoom), vOffset, (annotationsCanvas.width)*zoom, (annotationsCanvas.height)*zoom);

  if ((((clefs.width)*zoom)) < playheadPos) {
    if (localScoreX-editOffset+(clefsStart*zoom) < (0 + adjStartScaled)) {
      image(clefs, 0, vOffset, (clefs.width)*zoom, (clefs.height)*zoom);
    }
  }


  // Draw ID markers
  for (int i = 0, j = 0; i < (score.width)-playheadPos; i+=((score.width)/dur*10), j++) {
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
    if (clientp) {
      fill(0, 128, 0);
      textAlign(LEFT, BOTTOM);
      textSize(12);
      text(("Connected to Server at " + scoreClient.ip()), 0, height);
    }
  }

  if (frameCounter < totalFrames) {
    if (export) {
      saveFrame(rootPath + "/etc/export/frames/score#######.png");
    }
  }

  // Draw save text?
  if (saveTextOpacity != 0) {
    int perFrame = round(255/(fps*3));
    if (saveTextOpacity < perFrame) {
      saveTextOpacity = 0;
    } else {
      saveTextOpacity -= perFrame;
    }
    fill(0, 128, 0, saveTextOpacity);
    textAlign(RIGHT, CENTER);
    textSize(32);
    text("Saved!", (width-iconSize-(iconPadding*2)), ((iconSize*5)+(iconPadding*6)+(iconSize*0.5)));
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
    ellipse((width-iconSize-iconPadding+(iconSize*0.5)), (iconSize+(iconPadding*2)+(iconSize*0.5)), iconSize, iconSize);

    if (pencilMode) {
      noStroke();
      fill(buttonActiveColor);
      ellipse((width-iconSize-iconPadding+(iconSize*0.5)), (iconSize+(iconPadding*2)+(iconSize*0.5)), iconSize, iconSize);
    }
    image(pencilIcon, (width-iconSize-iconPadding), (iconSize+(iconPadding*2)), iconSize, iconSize);
  } else {
    if (!clientp) {
      noStroke();
      fill(buttonBGcolor);
      ellipse((width-iconSize-iconPadding+(iconSize*0.5)), (iconSize+(iconPadding*2)+(iconSize*0.5)), iconSize, iconSize);
      image(resetIcon, (width-iconSize-iconPadding), (iconSize+(iconPadding*2)), iconSize, iconSize);
    }
  }

  //ERASER/PLAY/PAUSE ICON
  if (editMode) {
    noStroke();
    fill(buttonBGcolor);
    ellipse((width-iconSize-iconPadding+(iconSize*0.5)), ((iconSize*2)+(iconPadding*3)+(iconSize*0.5)), iconSize, iconSize);

    if (eraserMode) {
      noStroke();
      fill(buttonActiveColor);
      ellipse((width-iconSize-iconPadding+(iconSize*0.5)), ((iconSize*2)+(iconPadding*3)+(iconSize*0.5)), iconSize, iconSize);
    }
    image(eraserIcon, (width-iconSize-iconPadding), ((iconSize*2)+(iconPadding*3)), iconSize, iconSize);
  } else {
    if (!clientp) {
      noStroke();
      fill(buttonBGcolor);
      ellipse((width-iconSize-iconPadding+(iconSize*0.5)), ((iconSize*2)+(iconPadding*3)+(iconSize*0.5)), iconSize, iconSize);
      if (playingp) {
        image(pauseIcon, (width-iconSize-iconPadding), ((iconSize*2)+(iconPadding*3)), iconSize, iconSize);
      } else {
        image(playIcon, (width-iconSize-iconPadding), ((iconSize*2)+(iconPadding*3)), iconSize, iconSize);
      }
    }
  }

  if (!clientp || editMode) {
    //PREV ICON
    noStroke();
    fill(buttonBGcolor);
    ellipse((width-iconSize-iconPadding+(iconSize*0.5)), ((iconSize*3)+(iconPadding*4)+(iconSize*0.5)), iconSize, iconSize);
    image(prevIcon, (width-iconSize-iconPadding), ((iconSize*3)+(iconPadding*4)), iconSize, iconSize);
    //NEXT ICON
    noStroke();
    fill(buttonBGcolor);
    ellipse((width-iconSize-iconPadding+(iconSize*0.5)), ((iconSize*4)+(iconPadding*5)+(iconSize*0.5)), iconSize, iconSize);
    image(nextIcon, (width-iconSize-iconPadding), ((iconSize*4)+(iconPadding*5)), iconSize, iconSize);
  }

  //ZOOM/SAVE ICON
  if (editMode) {
    noStroke();
    if (annotationsChangedp || navigationChangedp) {
      fill(160, 255, 160);
    } else {
      fill(255, 255, 255, 70);
      tint(255, 70);
    }
    ellipse((width-iconSize-iconPadding+(iconSize*0.5)), ((iconSize*5)+(iconPadding*6)+(iconSize*0.5)), iconSize, iconSize);
    image(saveIcon, (width-iconSize-iconPadding), ((iconSize*5)+(iconPadding*6)), iconSize, iconSize);
    noTint();
  } else {
    if (!playingp) {
      noStroke();
      if (!zoomDialog) {
        fill(buttonBGcolor);
      } else {
        fill(buttonActiveColor);
      }
      ellipse((width-iconSize-iconPadding+(iconSize*0.5)), ((iconSize*5)+(iconPadding*6)+(iconSize*0.5)), iconSize, iconSize);
      image(zoomIcon, (width-iconSize-iconPadding), ((iconSize*5)+(iconPadding*6)), iconSize, iconSize);
    }
    if (zoomDialog) {
      noStroke();
      fill(255);
      ellipse((width-(iconSize*2)-(iconPadding*2)+(iconSize*0.5)), ((iconSize*4)+(iconPadding*5)+(iconSize*0.5)), iconSize, iconSize);
      ellipse((width-(iconSize*2)-(iconPadding*2)+(iconSize*0.5)), ((iconSize*5)+(iconPadding*6)+(iconSize*0.5)), iconSize, iconSize);
      ellipse((width-(iconSize*2)-(iconPadding*2)+(iconSize*0.5)), ((iconSize*6)+(iconPadding*7)+(iconSize*0.5)), iconSize, iconSize);
      image(plusIcon, (width-(iconSize*2)-(iconPadding*2)), ((iconSize*4)+(iconPadding*5)), iconSize, iconSize);
      image(zeroIcon, (width-(iconSize*2)-(iconPadding*2)), ((iconSize*5)+(iconPadding*6)), iconSize, iconSize);
      image(minusIcon, (width-(iconSize*2)-(iconPadding*2)), ((iconSize*6)+(iconPadding*7)), iconSize, iconSize);
      noStroke();
      fill(255);
      ellipse((width-(iconSize*3)-(iconPadding*3)+(iconSize*0.5)), ((iconSize*4)+(iconPadding*5)+(iconSize*0.5)), iconSize, iconSize);
      ellipse((width-(iconSize*3)-(iconPadding*3)+(iconSize*0.5)), ((iconSize*5)+(iconPadding*6)+(iconSize*0.5)), iconSize, iconSize);
      ellipse((width-(iconSize*3)-(iconPadding*3)+(iconSize*0.5)), ((iconSize*6)+(iconPadding*7)+(iconSize*0.5)), iconSize, iconSize);
      image(upIcon, (width-(iconSize*3)-(iconPadding*3)), ((iconSize*4)+(iconPadding*5)), iconSize, iconSize);
      image(zeroIcon, (width-(iconSize*3)-(iconPadding*3)), ((iconSize*5)+(iconPadding*6)), iconSize, iconSize);
      image(downIcon, (width-(iconSize*3)-(iconPadding*3)), ((iconSize*6)+(iconPadding*7)), iconSize, iconSize);
    }
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
        ellipse((width-(iconSize*2)-(iconPadding*2)+(iconSize*0.5)), height-(iconSize*0.5)-iconPadding, iconSize, iconSize);
        ellipse((width-(iconSize*3)-(iconPadding*3)+(iconSize*0.5)), height-(iconSize*0.5)-iconPadding, iconSize, iconSize);
        image(exitNo, (width-(iconSize*2)-(iconPadding*2)), height-iconSize-iconPadding, iconSize, iconSize);
        image(exitYes, (width-(iconSize*3)-(iconPadding*3)), height-iconSize-iconPadding, iconSize, iconSize);
        exitTimeout++;
      } else {
        exitDialog = false;
        exitTimeout = 0;
      }
    }
  }

  // Redraw
  if (frameCounter < totalFrames) {
    // looping...
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

    if ((mouseX > (width-iconSize-iconPadding)) && (mouseX < width-iconPadding)) {
      //EDIT MODE

      if (mouseY < (iconSize+(iconPadding*1)) && mouseY > iconPadding) {
        if (!playingp) {
          if (!editMode) {
            editMode = true;
            zoomDialog = false;
          } else {
            pencilMode = true;
            penSize = 2;
            eraserMode = false;
            editMode = false;
            editOffset = 0;
            editOffsetScaled = 0;
            smoothScroller = 0;
          }
        }
      }

      //PENCIL/RESET
      if (mouseY > (iconSize+(iconPadding*2)) && mouseY < ((iconSize*2)+(iconPadding*2))) {
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
            frameCounter = round(-(preRoll*fps));
          }
        }
      }

      //ERASER/PLAY/PAUSE
      if (mouseY > ((iconSize*2)+(iconPadding*3)) && mouseY < ((iconSize*3)+(iconPadding*3))) {
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
              playbackFile.stop();
              audioplayingp = false;
            }
          }
        }
      }

      if (!clientp || editMode) {
        //PREV
        if (mouseY > ((iconSize*3)+(iconPadding*4)) && mouseY < ((iconSize*4)+(iconPadding*4))) {
          if (editMode) {
            editOffset = editOffset - editOffsetValue;
            smoothScroller = smoothScroller - editOffsetValue;
            editOffsetScaled = round(editOffset/zoom);
          } else {
            frameCounter = frameCounter - (fps*5);
            playbackFile.stop(); // Will re-cue and autorestart at next frame
            audioplayingp = false;
          }
        }
        //NEXT
        if (mouseY > ((iconSize*4)+(iconPadding*5)) && mouseY < ((iconSize*5)+(iconPadding*5))) {
          if (editMode) {
            editOffset = editOffset + editOffsetValue;
            smoothScroller = smoothScroller + editOffsetValue;
            editOffsetScaled = round(editOffset/zoom);
          } else {
            frameCounter = frameCounter + (fps*5);
            playbackFile.stop(); // Will re-cue and autorestart at next frame
            audioplayingp = false;
          }
        }
      }

      //ZOOM/SAVE
      if (mouseY > ((iconSize*5)+(iconPadding*6)) && mouseY < ((iconSize*6)+(iconPadding*6))) {

        //SAVE
        if (editMode) {
          if (navigationChangedp) {
            navigationChangedp = false;
            saveStrings(userSettingsPath, userSettingsArray);
            saveTextOpacity = 255;
          }
          if (annotationsChangedp) {
            annotationsChangedp = false;
            annotationsCanvas.save(annotationsPath);
            saveTextOpacity = 255;
          }
        } else {
          //ZOOM
          if (!playingp) {
            if (!zoomDialog) {
              zoomDialog = true;
            } else {
              zoomDialog = false;
            }
          }
        }
      }

      //EXIT
      if ((mouseY > (height-iconSize-iconPadding)) && mouseY < (height-iconPadding)) {
        if (!editMode) {
          exitDialog = true;
        }
      }
    }

    //ZOOM DIALOG
    if (zoomDialog) {
      if (!playingp) {
        if ((mouseX > (width-(iconSize*2)-(iconPadding*2))) && mouseX < (width-iconSize-(iconPadding*2))) {
          if (mouseY > ((iconSize*4)+(iconPadding*5)) && mouseY < ((iconSize*5)+(iconPadding*5))) {
            navigationChangedp = true;
            zoom = zoom + 0.5;
            userSettingsArray[6] = str(zoom);
          }
          if (mouseY > ((iconSize*5)+(iconPadding*6)) && mouseY < ((iconSize*6)+(iconPadding*6))) {
            navigationChangedp = true;
            zoom = screenScale;
            userSettingsArray[6] = str(zoom);
          }
          if (mouseY > ((iconSize*6)+(iconPadding*7)) && mouseY < ((iconSize*7)+(iconPadding*7))) {
            navigationChangedp = true;
            if ((zoom - 0.5) < screenScale) {
              zoom = screenScale;
            }
            if (zoom > screenScale) {
              zoom = zoom - 0.5;
              userSettingsArray[6] = str(zoom);
            }
          }
        }
        if ((mouseX > (width-(iconSize*3)-(iconPadding*3))) && mouseX < (width-(iconSize*2)-(iconPadding*3))) {
          if (mouseY > ((iconSize*4)+(iconPadding*5)) && mouseY < ((iconSize*5)+(iconPadding*5))) {
            navigationChangedp = true;
            vOffset = vOffset + round(50*zoom);
            userSettingsArray[7] = str(vOffset);
          }
          if (mouseY > ((iconSize*5)+(iconPadding*6)) && mouseY < ((iconSize*6)+(iconPadding*6))) {
            navigationChangedp = true;
            vOffset = 0;
            userSettingsArray[7] = str(vOffset);
          }
          if (mouseY > ((iconSize*6)+(iconPadding*7)) && mouseY < ((iconSize*7)+(iconPadding*7))) {
            navigationChangedp = true;
            vOffset = vOffset - round(50*zoom);
            userSettingsArray[7] = str(vOffset);
          }
        }
      }
    }

    //EXIT DIALOG
    if (exitDialog) {
      if ((mouseY > height-iconSize-iconPadding) && (mouseY < (height-iconPadding))) {
        if ((mouseX > (width-(iconSize*2)-(iconPadding*2))) && mouseX < (width-iconSize-(iconPadding*2))) {
          exitDialog = false;
          exitTimeout = 0;
        }
        if ((mouseX > (width-(iconSize*3)-(iconPadding*3))) && mouseX < (width-(iconSize*2)-(iconPadding*3))) {
          if (navigationChangedp) {
            navigationChangedp = false;
            saveStrings(userSettingsPath, userSettingsArray);
          }
          if (annotationsChangedp) {
            annotationsChangedp = false;
            annotationsCanvas.save(annotationsPath);
          }
          exit();
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
  if (mouseX > ((clefs.width)*zoom) && mouseX < (width-iconSize-(iconPadding*2))) {
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

String getNameWithoutExt (File infile) {
  String name = infile.getName();
  int pos = name.lastIndexOf(".");
  if (pos > 0) {
    name = name.substring(0, pos);
  }
  return name;
}