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

String rootPath;

PImage score, clefs;

String[] projectArray = { null };
String   projectPath;
File     projectFile;
String   projectParent;
String   projectName;

String[] xpositionsArray = { null, null, null, null, null, null };
String xpositionsPath;
File xpositionsFile;
int[] xpositions = { 0, 0, 0, 0, 0, 0 };

final int fps = 10; // Frame rate

float screenScale = 1.0;

int setPosition;

int wizardStep = 0;
String[] wizardText = { null, null, null, null };

final int iconSize = 50;
final int iconPadding = 10;

PImage bFastBack, bBack, bMinus, bPlus, bPlay, bFastForward, bCheck;

int playheadPos;

void setup() {
  frameRate(fps);
  size(800, 480);
  noSmooth();

  rootPath = ((new File((new File (sketchPath(""))).getParent())).getParent());

  playheadPos = round(width * 0.2);

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

  score = loadImage(projectArray[0]);
  clefs = loadImage(projectParent + "/" + projectName + "-clefs.png");

  screenScale = (height/float(score.height));

  xpositionsPath = projectParent + "/" + projectName + "-xpositions.piscore";
  xpositionsFile = new File(xpositionsPath);
  if (xpositionsFile.exists()) {
    xpositionsArray = loadStrings(xpositionsPath);
    for (int i = 0; i < (xpositionsArray.length); i++) {
      xpositions[i] = int(xpositionsArray[i]);
    }
  } else {
    xpositions[1] = -score.width;
  }

  setPosition = xpositions[wizardStep];

  bFastBack = loadImage(rootPath + "/gui/black-rewind-double-arrow-outlined-circular-button.png");
  bBack = loadImage(rootPath + "/gui/black-back-rounded-button-outline.png");
  bMinus = loadImage(rootPath + "/gui/black-minus-sign-in-a-circle.png");
  bPlus = loadImage(rootPath + "/gui/black-add-circular-button-thin-symbol.png");
  bPlay = loadImage(rootPath + "/gui/black-play-rounded-button-outline.png");
  bFastForward = loadImage(rootPath + "/gui/black-fast-forward-thin-outlined-symbol-in-circular-button.png");
  bCheck = loadImage(rootPath + "/gui/black-checkmark-outlined-circular-button.png");

  wizardText[0] = "Set music start position";
  wizardText[1] = "Set music end position";
  wizardText[2] = "Set clef start position";
  wizardText[3] = "Set clef end position";
} 

void draw() {
  background(255);
  cursor(CROSS);

  if (wizardStep < 4) {
    image(score, (playheadPos+setPosition), 0, (score.width), (score.height));

    // Draw playhead and IP
    stroke(255, 0, 0, 150);
    strokeWeight(5);
    strokeCap(SQUARE);
    line(playheadPos, 0, playheadPos, height);

    fill(255, 0, 0);
    textAlign(CENTER, TOP);
    textSize(20);

    text(wizardText[wizardStep], (width/2), iconPadding);

    noStroke();
    fill(255);
    ellipse(((width+iconPadding)/2)+(iconSize/2)-((iconSize+iconPadding)*3), (height-iconPadding-iconSize)+(iconSize/2), iconSize, iconSize);
    image(bFastBack, ((width+iconPadding)/2)-((iconSize+iconPadding)*3), (height-iconPadding-iconSize), iconSize, iconSize);
    ellipse(((width+iconPadding)/2)+(iconSize/2)-((iconSize+iconPadding)*2), (height-iconPadding-iconSize)+(iconSize/2), iconSize, iconSize);
    image(bBack, ((width+iconPadding)/2)-((iconSize+iconPadding)*2), (height-iconPadding-iconSize), iconSize, iconSize);
    ellipse(((width+iconPadding)/2)+(iconSize/2)-((iconSize+iconPadding)*1), (height-iconPadding-iconSize)+(iconSize/2), iconSize, iconSize);
    image(bMinus, ((width+iconPadding)/2)-((iconSize+iconPadding)*1), (height-iconPadding-iconSize), iconSize, iconSize);
    ellipse(((width+iconPadding)/2)+(iconSize/2), (height-iconPadding-iconSize)+(iconSize/2), iconSize, iconSize);
    image(bPlus, ((width+iconPadding)/2), (height-iconPadding-iconSize), iconSize, iconSize);
    ellipse(((width+iconPadding)/2)+(iconSize/2)+((iconSize+iconPadding)*1), (height-iconPadding-iconSize)+(iconSize/2), iconSize, iconSize);
    image(bPlay, ((width+iconPadding)/2)+((iconSize+iconPadding)*1), (height-iconPadding-iconSize), iconSize, iconSize);
    ellipse(((width+iconPadding)/2)+(iconSize/2)+((iconSize+iconPadding)*2), (height-iconPadding-iconSize)+(iconSize/2), iconSize, iconSize);
    image(bFastForward, ((width+iconPadding)/2)+((iconSize+iconPadding)*2), (height-iconPadding-iconSize), iconSize, iconSize);
  }
  ellipse((width-iconPadding-iconSize+(iconSize/2)), (height-iconPadding-iconSize)+(iconSize/2), iconSize, iconSize);
  image(bCheck, (width-iconPadding-iconSize), (height-iconPadding-iconSize), iconSize, iconSize);
}

void mousePressed() {
  if (wizardStep < 4) {
    if (mouseY > height-(iconSize+iconPadding) && mouseY < height-iconPadding) {
      if ( mouseX > ((width+iconPadding)/2)-((iconSize+iconPadding)*3)
        && mouseX < ((width+iconPadding)/2)-((iconSize+iconPadding)*3)+iconSize) {
        setPosition+=150;
      }
      if ( mouseX > ((width+iconPadding)/2)-((iconSize+iconPadding)*2)
        && mouseX < ((width+iconPadding)/2)-((iconSize+iconPadding)*2)+iconSize) {
        setPosition+=20;
      }
      if ( mouseX > ((width+iconPadding)/2)-(iconSize+iconPadding)
        && mouseX < ((width+iconPadding)/2)-((iconSize+iconPadding))+iconSize) {
        setPosition+=1;
      }
      if ( mouseX > ((width+iconPadding)/2)
        && mouseX < ((width+iconPadding)/2)+iconSize) {
        setPosition-=1;
      }
      if ( mouseX > ((width+iconPadding)/2)+((iconSize+iconPadding)*1)
        && mouseX < ((width+iconPadding)/2)+((iconSize+iconPadding)*1)+iconSize) {
        setPosition-=20;
      }
      if ( mouseX > ((width+iconPadding)/2)+((iconSize+iconPadding)*2)
        && mouseX < ((width+iconPadding)/2)+((iconSize+iconPadding)*2)+iconSize) {
        setPosition-=150;
      }
    }
  }

  if ( mouseX > (width-iconPadding-iconSize)
    && mouseX < (width-iconPadding)
    && mouseY > height-(iconSize+iconPadding)
    && mouseY < height-iconPadding) {
    xpositions[wizardStep] = setPosition;
    wizardStep++;
    if (wizardStep < (xpositions.length)) {
      setPosition = xpositions[wizardStep];
    } else {
      for (int i = 0; i < (xpositions.length); i++) {
        xpositionsArray[i] = str((xpositions[i]));
      }
      saveStrings(xpositionsPath, xpositionsArray);
      exit();
    }
  }
}


String getNameWithoutExt (File infile) {
  String name = infile.getName();
  int pos = name.lastIndexOf(".");
  if (pos > 0) {
    name = name.substring(0, pos);
  }
  return name;
}