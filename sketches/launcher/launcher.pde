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

String[] launch = { null, null, null };
String[] wizard = { null, null, null };
String[] reboot = {"sudo", "reboot"};
String[] shutdown = {"sudo", "shutdown", "now"};
String[] deleteAnnotations = { "mv", null, null };

String[] licenseText;

String backupPath;
String backupFile;

PImage bLaunch, bReboot, bShutdown, bTerminal, bDelete, bCheck, bCross, bEmpty, bEdit, bEditSelected, bAbout, bFolder, bFile, bMusicalNote;
PImage tReboot, tShutdown, tTerminal, tDelete, tAbout;
PShape psIcon;

String[] numpadArray = { "7", "8", "9", "4", "5", "6", "1", "2", "3", "0", ".", "\u2190" };
String[] numpadDecisionArray = { "Cancel", "Confirm" };

String[] projectArray = { null };
String   projectPath;
File     projectFile;
String   projectParent;
String   projectName;

String[] clientpArray = { null };
String clientpPath;
File clientpFile;
boolean clientp;

String userSettingsPath;
File userSettingsFile;
boolean userSettingsp = false;

String[] serverIpAddrArray = { null };
String serverIpAddrPath;
File serverIpAddrFile;
String serverIpAddr;
String serverIpAddrTemp;

boolean loadingp = false;
boolean loadingSleep = false;
boolean deletep = false;
boolean ipEditp = false;
boolean aboutp = false;
int deleteTimeout = 0;

String dateStamp, timeStamp;

final int fps = 10;
int loadingCounter = 0;

final int iconSize = 50;
final int iconSizeLarge = 100;
final int psIconSize = 70;
final int iconPadding = 10;
final int textPadding = 5;

void setup () {
  size(800, 480);
  frameRate(fps);
  smooth();
  cursor(HAND);

  rootPath = ((new File((new File (sketchPath(""))).getParent())).getParent());

  licenseText = loadStrings(rootPath + "/LICENSE-SHORT");

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
  serverIpAddrTemp = serverIpAddr + "_";

  clientpPath = rootPath + "/etc/clientp";
  clientpFile = new File(clientpPath);
  if (clientpFile.exists()) {
    clientpArray = loadStrings(clientpPath);
  } else {
    clientpArray[0] = "false"; // Defaults to server
    saveStrings(clientpPath, clientpArray);
  }
  clientp = boolean(clientpArray[0]);

  userSettingsPath = projectParent + "/" + projectName + ".piscore";
  userSettingsFile = new File(userSettingsPath);
  if (userSettingsFile.exists()) {
    userSettingsp = true;
  }

  launch[0] = "/usr/local/bin/processing-java";
  launch[1] = "--sketch=" + rootPath + "/sketches/PiScore/";
  launch[2] = "--run";

  wizard[0] = "/usr/local/bin/processing-java";
  wizard[1] = "--sketch=" + rootPath + "/sketches/wizard/";
  wizard[2] = "--run";

  backupPath = rootPath + "/etc/backup/";

  bLaunch = loadImage(rootPath + "/gui/white-100px-flash-outlined-thin-circular-button.png");
  bReboot = loadImage(rootPath + "/gui/white-circular-arrow-in-rounded-button.png");
  bShutdown = loadImage(rootPath + "/gui/white-power-outlined-circular-button.png");
  bTerminal = loadImage(rootPath + "/gui/white-monitor-circular-thin-button.png");
  bDelete = loadImage(rootPath + "/gui/white-trash-can-circular-outlined-button.png");
  bCheck = loadImage(rootPath + "/gui/white-50px-checkmark-outlined-circular-button.png");
  bCross = loadImage(rootPath + "/gui/white-close-cross-thin-circular-button.png");
  bEmpty = loadImage(rootPath + "/gui/white-50px-empty-circular-button.png");
  bEdit = loadImage(rootPath + "/gui/white-50px-edit-pencil-outline-in-circular-button.png");
  bEditSelected = loadImage(rootPath + "/gui/white-selected-50px-edit-pencil-outline-in-circular-button.png");
  bAbout = loadImage(rootPath + "/gui/white-50px-arroba-outlined-circular-button.png");
  bFolder = loadImage(rootPath + "/gui/white-50px-folder-outline-in-circular-button.png");
  bMusicalNote = loadImage(rootPath + "/gui/white-50px-musical-note-symbol-in-circular-button-outlined-symbol.png");

  tReboot = loadImage(rootPath + "/gui/white-reboot.png");
  tShutdown = loadImage(rootPath + "/gui/white-shutdown.png");
  tTerminal = loadImage(rootPath + "/gui/white-terminal.png");
  tDelete = loadImage(rootPath + "/gui/white-delete.png");
  tAbout = loadImage(rootPath + "/gui/white-about.png");
  

  psIcon = loadShape(rootPath + "/gui/icon/PiScore-icon-white.svg");
}

void draw() {
  smooth();
  background(color(0, 90, 158));

  if (!loadingp) {
    fill(255);
    if (!ipEditp) {
      if (!userSettingsp) {
        tint(255, 70);
      }
      image(bLaunch, ((width/2)-(iconSizeLarge*0.5)), ((height/2)-(iconSizeLarge*0.5)));
      noTint();
      if (userSettingsp) {
        fill(255);
      } else {
        fill(255, 255, 255, 70);
      }
      textAlign(CENTER, CENTER);
      textSize(14);
      text("Launch", (width/2), ((height/2)+(iconSizeLarge*0.5)+iconPadding));
    }

    if (!ipEditp) {
      image(bFolder, width-iconPadding-iconSize, iconPadding);
      fill(255);
      textAlign(RIGHT, TOP);
      textSize(14);
      text("Current score:\n" + projectArray[0], width/3, iconPadding, ((width/3*2)-((iconPadding*2)+iconSize)), height-iconPadding); //Text spills down the screen for long path names
    }

    if (!ipEditp) {
      image(bMusicalNote, width-iconPadding-iconSize, (iconPadding*2)+iconSize);
      fill(255);
      textAlign(RIGHT, CENTER);
      textSize(14);
      if (userSettingsp) {
        fill(255);
        text("Score setup wizard", (width-(iconPadding*2)-iconSize), (iconPadding*2)+(iconSize*0.5)+iconSize);
      } else {
        fill(255, 0, 0);
        text("WARNING: no score information found - please run score setup wizard", (width-(iconPadding*2)-iconSize), (iconPadding*2)+(iconSize*0.5)+iconSize);
      }
    }

    if (!ipEditp) {
      fill(255);
      textAlign(LEFT, CENTER);
      textSize(14);
      text("Launch as Server", ((iconPadding*2)+iconSize), (iconPadding+(iconSize*0.5)));
      if (clientp) {
        image(bEmpty, iconPadding, iconPadding);
      } else {
        image(bCheck, iconPadding, iconPadding);
      }
    }

    if (clientp) {
      fill(255);
      textAlign(LEFT, CENTER);
      textSize(14);
      text(("Connect to server:\n" + serverIpAddr), ((iconPadding*2)+iconSize), ((iconPadding*2)+iconSize+(iconSize*0.5)));
      if (!ipEditp) {
        image(bEdit, iconPadding, (iconPadding*2)+iconSize);
      } else {
        image(bEditSelected, iconPadding, (iconPadding*2)+iconSize);
      }
    }
    if (ipEditp) {
      textAlign(LEFT, TOP);
      textSize(16);
      text("Please enter IP addr.:", iconPadding, ((iconPadding*3)+(iconSize*2)));
      textSize(20);
      text(serverIpAddrTemp, iconPadding, ((iconPadding*3)+(iconSize*2)+18));

      noStroke();
      fill(color(255, 100, 100));
      rect(iconPadding, ((iconPadding*4)+(iconSize*2)+18+22), (iconSize*1.5)+(iconPadding*0.5), iconSize, 10);
      fill(color(100, 255, 100));
      rect(iconPadding+(iconSize*1.5)+(iconPadding*1.5), ((iconPadding*4)+(iconSize*2)+18+22), (iconSize*1.5)+(iconPadding*0.5), iconSize, 10);
      textAlign(CENTER, CENTER);
      textSize(16);
      fill(color(155, 0, 0));
      text(numpadDecisionArray[0], (iconPadding+               (iconSize*1.5*0.5)+(iconPadding*0.25)), ((iconPadding*4)+(iconSize*2)+18+22+(iconSize*0.5)));
      fill(color(0, 155, 0));
      text(numpadDecisionArray[1], (iconPadding+(iconSize*1.5)+(iconSize*1.5*0.5)+(iconPadding*1.75)), ((iconPadding*4)+(iconSize*2)+18+22+(iconSize*0.5)));

      for (int i = 0; i < 12; i++) {
        noStroke();
        fill(255);
        rect(iconPadding+((iconPadding+iconSize)*(i % 3)), ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(i/3))), iconSize, iconSize, 10);
        fill(color(0, 90, 158));
        textAlign(CENTER, CENTER);
        textSize(42);
        text(numpadArray[i], iconPadding+((iconPadding+iconSize)*(i % 3))+(iconSize*0.5), ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(i/3))+(iconSize*0.5)));
      }
    }

    image(bTerminal, ((width/2)-(iconSize*0.5)-iconSize-(iconPadding*2)), (height-iconSize-(tTerminal.height)-(textPadding*2)));
    image(tTerminal, ((width/2)-(iconSize*0.5)-iconSize-(iconPadding*2)), (height-textPadding-tTerminal.height));

    image(bShutdown, ((width/2)-(iconSize*0.5)), (height-iconSize-(tShutdown.height)-(textPadding*2)));
    image(tShutdown, ((width/2)-(iconSize*0.5)), (height-textPadding-tShutdown.height));

    image(bReboot, ((width/2)-(iconSize*0.5)+iconSize+(iconPadding*2)), (height-iconSize-(tReboot.height)-(textPadding*2)));
    image(tReboot, ((width/2)-(iconSize*0.5)+iconSize+(iconPadding*2)), (height-textPadding-tReboot.height));

    image(bDelete, (width-iconSize-iconPadding), (height-iconSize-(tDelete.height)-(textPadding*2)));
    image(tDelete, (width-iconSize-iconPadding), (height-textPadding-tDelete.height));

    if (deletep) {
      if (deleteTimeout < fps*3) {
        image(bCross, (width-iconSize-iconPadding), (height-(iconSize*2)-(iconPadding)-(tDelete.height)-(textPadding*2)));
        image(bCheck, (width-iconSize-iconPadding), (height-(iconSize*3)-(iconPadding*2)-(tDelete.height)-(textPadding*2)));
        deleteTimeout++;
      } else {
        deletep = false;
        deleteTimeout = 0;
      }
    }
  }

  if (aboutp) {
    noStroke();
    fill(color(0, 90, 158)); 
    rect(0, 0, width, height);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(20);
    for ( int i = 0; i < licenseText.length; i++) {
      text(licenseText[i], 0, ((i-((licenseText.length)*0.5))*(textPadding+20)), width, height);
    }
    textAlign(CENTER, BOTTOM);
    text("Press anywhere to return...", width/2, height-textPadding);
  }
  if (!ipEditp) {
      shape(psIcon, iconPadding, height-iconPadding-psIconSize, psIconSize, psIconSize);
      fill(255);
    textAlign(LEFT, BOTTOM);
    textSize(10);
      text("PiScore", iconPadding+5, height-11);
    }

  if (loadingp) {
    if (loadingCounter < (fps * 10)) { //Timeout
      if ((loadingCounter % fps) < (fps*0.5)) {
        fill(255);
        textSize(20);
        textAlign(CENTER, CENTER);
        text("Loading...", width/2, height/2);
      }
      loadingCounter++;
    } else {
      loadingCounter = 0;
      loadingp = false;
      loadingSleep = true;

      noStroke();
      fill(0); 
      rect(0, 0, width, height);
      fill(255);
      textAlign(CENTER, CENTER);
      textSize(20);
      text("Sleeping...", width/2, height/2);
      textAlign(CENTER, BOTTOM);
      text("Press anywhere to resume...", width/2, height-textPadding);

      noLoop();
    }
  }
}

void mousePressed() {
  if (!loadingp) {
    if (aboutp || loadingSleep ) {
      aboutp = false;
      loadingSleep = false;
      //Check for userSettings
      userSettingsPath = projectParent + "/" + projectName + ".piscore";
      userSettingsFile = new File(userSettingsPath);
      if (userSettingsFile.exists()) {
        userSettingsp = true;
      }
      loop();
    } else {
      //Launch
      if (!ipEditp && userSettingsp) {
        if (
          (mouseX > ((width/2)-(iconSizeLarge*0.5))) &
          (mouseX < ((width/2)+(iconSizeLarge*0.5))) &
          (mouseY > ((height/2)-(iconSizeLarge*0.5))) &
          (mouseY < ((height/2)+(iconSizeLarge*0.5)))
          ) {
          loadingp = true;
          exec(launch);
        }
      }
      //Edit current project folder
      if (!ipEditp) {
        if (
          (mouseX > width-(iconPadding+iconSize)) &
          (mouseX < width-iconPadding) &
          (mouseY > iconPadding) &
          (mouseY < (iconPadding+iconSize))
          ) {
          selectInput("Select score...", "fileSelected", new File(projectArray[0]));
        }
      }
      //Score setup wizard
      if (!ipEditp) {
        if (
          (mouseX > width-(iconPadding+iconSize)) &
          (mouseX < width-iconPadding) &
          (mouseY > (iconPadding*2)+iconSize) &
          (mouseY < (iconPadding*2)+iconSize*2)
          ) {
          loadingp = true;
          exec(wizard);
        }
      }
      //Launch as Server checkbox
      if (!ipEditp) {
        if (
          (mouseX > iconPadding) &
          (mouseX < (iconPadding+iconSize)) &
          (mouseY > iconPadding) &
          (mouseY < (iconPadding+iconSize))
          ) {
          if (clientp)
          {
            clientpArray[0] = "false";
          } else {
            clientpArray[0] = "true";
          }
          clientp = boolean(clientpArray[0]);
          saveStrings(clientpPath, clientpArray);
        }
      }
      //Edit IP
      if (
        (mouseX > iconPadding) &
        (mouseX < (iconPadding+iconSize)) &
        (mouseY > (iconPadding*2)+iconSize) &
        (mouseY < ((iconPadding*2)+(iconSize*2)))
        ) {
        if (clientp) {
          if (!ipEditp) {
            ipEditp = true;
          }
        }
      }


      if (ipEditp) {

        //rect(iconPadding, ((iconPadding*4)+(iconSize*2)+18+22), (iconSize*1.5)+(iconPadding*0.5), iconSize, 10);
        //rect(iconPadding+(iconSize*1.5)+(iconPadding*1.5), ((iconPadding*4)+(iconSize*2)+18+22), (iconSize*1.5)+(iconPadding*0.5), iconSize, 10);


        //NUMPAD DECISION
        if (
          (mouseX > iconPadding) &
          (mouseX < iconPadding+(iconSize*1.5)+(iconPadding*0.5)) &
          (mouseY > ((iconPadding*4)+(iconSize*2)+18+22)) &
          (mouseY < ((iconPadding*4)+(iconSize*2)+18+22)+iconSize)
          ) {
          ipEditp = false;
          serverIpAddrTemp = serverIpAddr + "_";
        }

        if (
          (mouseX > iconPadding+(iconSize*1.5)+(iconPadding*1.5)) &
          (mouseX < iconPadding+(iconSize*1.5)+(iconPadding*1.5)+((iconSize*1.5)+(iconPadding*0.5))) &
          (mouseY > ((iconPadding*4)+(iconSize*2)+18+22)) &
          (mouseY < ((iconPadding*4)+(iconSize*2)+18+22)+iconSize)
          ) {
          ipEditp = false;
          serverIpAddrArray[0] = serverIpAddrTemp.substring(0, serverIpAddrTemp.length()-1);
          serverIpAddr = serverIpAddrArray[0];
          saveStrings(serverIpAddrPath, serverIpAddrArray);
        }

        //NUMPAD
        if (
          (mouseX > iconPadding+((iconPadding+iconSize)*(0))) &
          (mouseX < iconPadding+((iconPadding+iconSize)*(0))+iconSize) &
          (mouseY > ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(0)))) &
          (mouseY < ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(0))+iconSize))
          ) {
          serverIpAddrTemp = serverIpAddrTemp.substring(0, serverIpAddrTemp.length()-1);
          serverIpAddrTemp = serverIpAddrTemp + "7_";
        }
        if (
          (mouseX > iconPadding+((iconPadding+iconSize)*(1))) &
          (mouseX < iconPadding+((iconPadding+iconSize)*(1))+iconSize) &
          (mouseY > ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(0)))) &
          (mouseY < ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(0))+iconSize))
          ) {
          serverIpAddrTemp = serverIpAddrTemp.substring(0, serverIpAddrTemp.length()-1);
          serverIpAddrTemp = serverIpAddrTemp + "8_";
        }
        if (
          (mouseX > iconPadding+((iconPadding+iconSize)*(2))) &
          (mouseX < iconPadding+((iconPadding+iconSize)*(2))+iconSize) &
          (mouseY > ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(0)))) &
          (mouseY < ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(0))+iconSize))
          ) {
          serverIpAddrTemp = serverIpAddrTemp.substring(0, serverIpAddrTemp.length()-1);
          serverIpAddrTemp = serverIpAddrTemp + "9_";
        }
        if (
          (mouseX > iconPadding+((iconPadding+iconSize)*(0))) &
          (mouseX < iconPadding+((iconPadding+iconSize)*(0))+iconSize) &
          (mouseY > ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(1)))) &
          (mouseY < ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(1))+iconSize))
          ) {
          serverIpAddrTemp = serverIpAddrTemp.substring(0, serverIpAddrTemp.length()-1);
          serverIpAddrTemp = serverIpAddrTemp + "4_";
        }
        if (
          (mouseX > iconPadding+((iconPadding+iconSize)*(1))) &
          (mouseX < iconPadding+((iconPadding+iconSize)*(1))+iconSize) &
          (mouseY > ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(1)))) &
          (mouseY < ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(1))+iconSize))
          ) {
          serverIpAddrTemp = serverIpAddrTemp.substring(0, serverIpAddrTemp.length()-1);
          serverIpAddrTemp = serverIpAddrTemp + "5_";
        }
        if (
          (mouseX > iconPadding+((iconPadding+iconSize)*(2))) &
          (mouseX < iconPadding+((iconPadding+iconSize)*(2))+iconSize) &
          (mouseY > ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(1)))) &
          (mouseY < ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(1))+iconSize))
          ) {
          serverIpAddrTemp = serverIpAddrTemp.substring(0, serverIpAddrTemp.length()-1);
          serverIpAddrTemp = serverIpAddrTemp + "6_";
        }
        if (
          (mouseX > iconPadding+((iconPadding+iconSize)*(0))) &
          (mouseX < iconPadding+((iconPadding+iconSize)*(0))+iconSize) &
          (mouseY > ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(2)))) &
          (mouseY < ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(2))+iconSize))
          ) {
          serverIpAddrTemp = serverIpAddrTemp.substring(0, serverIpAddrTemp.length()-1);
          serverIpAddrTemp = serverIpAddrTemp + "1_";
        }
        if (
          (mouseX > iconPadding+((iconPadding+iconSize)*(1))) &
          (mouseX < iconPadding+((iconPadding+iconSize)*(1))+iconSize) &
          (mouseY > ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(2)))) &
          (mouseY < ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(2))+iconSize))
          ) {
          serverIpAddrTemp = serverIpAddrTemp.substring(0, serverIpAddrTemp.length()-1);
          serverIpAddrTemp = serverIpAddrTemp + "2_";
        }
        if (
          (mouseX > iconPadding+((iconPadding+iconSize)*(2))) &
          (mouseX < iconPadding+((iconPadding+iconSize)*(2))+iconSize) &
          (mouseY > ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(2)))) &
          (mouseY < ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(2))+iconSize))
          ) {
          serverIpAddrTemp = serverIpAddrTemp.substring(0, serverIpAddrTemp.length()-1);
          serverIpAddrTemp = serverIpAddrTemp + "3_";
        }
        if (
          (mouseX > iconPadding+((iconPadding+iconSize)*(0))) &
          (mouseX < iconPadding+((iconPadding+iconSize)*(0))+iconSize) &
          (mouseY > ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(3)))) &
          (mouseY < ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(3))+iconSize))
          ) {
          serverIpAddrTemp = serverIpAddrTemp.substring(0, serverIpAddrTemp.length()-1);
          serverIpAddrTemp = serverIpAddrTemp + "0_";
        }
        if (
          (mouseX > iconPadding+((iconPadding+iconSize)*(1))) &
          (mouseX < iconPadding+((iconPadding+iconSize)*(1))+iconSize) &
          (mouseY > ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(3)))) &
          (mouseY < ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(3))+iconSize))
          ) {
          serverIpAddrTemp = serverIpAddrTemp.substring(0, serverIpAddrTemp.length()-1);
          serverIpAddrTemp = serverIpAddrTemp + "._";
        }
        if (
          (mouseX > iconPadding+((iconPadding+iconSize)*(2))) &
          (mouseX < iconPadding+((iconPadding+iconSize)*(2))+iconSize) &
          (mouseY > ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(3)))) &
          (mouseY < ((iconPadding*5)+(iconSize*3)+18+22+((iconSize+iconPadding)*(3))+iconSize))
          ) {
          if ( (serverIpAddrTemp.length()) > 1) {
            serverIpAddrTemp = serverIpAddrTemp.substring(0, serverIpAddrTemp.length()-2);
            serverIpAddrTemp = serverIpAddrTemp + "_";
          }
        }
      }


      //About
      if (!ipEditp) {
        if (
          (mouseX > iconPadding) &
          (mouseX < (iconPadding+psIconSize)) &
          (mouseY > (height-iconPadding-psIconSize)) &
          (mouseY < (height-iconPadding))
          ) {
          aboutp = true;
        }
      }
      //Terminal
      if (
        (mouseX > ((width/2)-(iconSize*0.5)-iconSize-(iconPadding*2))) &
        (mouseX < ((width/2)-(iconSize*0.5)-iconSize-(iconPadding*2))+iconSize) &
        (mouseY > (height-iconSize-(tTerminal.height)-(textPadding*2))) &
        (mouseY < (height-iconSize-(tTerminal.height)-(textPadding*2))+iconSize)
        ) {
        exit();
      }
      //Shutdown
      if (
        (mouseX > ((width/2)-(iconSize*0.5))) &
        (mouseX < ((width/2)-(iconSize*0.5))+iconSize) &
        (mouseY > (height-iconSize-(tTerminal.height)-(textPadding*2))) &
        (mouseY < (height-iconSize-(tTerminal.height)-(textPadding*2))+iconSize)
        ) {
        exec(shutdown);
      }
      //Reboot
      if (
        (mouseX > ((width/2)-(iconSize*0.5)+iconSize+(iconPadding*2))) &
        (mouseX < ((width/2)-(iconSize*0.5)+iconSize+(iconPadding*2))+iconSize) &
        (mouseY > (height-iconSize-(tTerminal.height)-(textPadding*2))) &
        (mouseY < (height-iconSize-(tTerminal.height)-(textPadding*2))+iconSize)
        ) {
        exec(reboot);
      }
      //Delete Annotations
      if (
        (mouseX > (width-iconSize-iconPadding)) &
        (mouseX < (width-iconSize-iconPadding)+iconSize) &
        (mouseY > (height-iconSize-(tTerminal.height)-(textPadding*2))) &
        (mouseY < (height-iconSize-(tTerminal.height)-(textPadding*2))+iconSize)
        ) {
        dateStamp = (year() + "-" + month() + "-" + day());
        timeStamp = (hour() + "-" + minute() + "-" + second());
        backupFile = (backupPath + projectName + "-annotations" + dateStamp + timeStamp + ".png");
        deleteAnnotations[1] = projectParent + "/" + projectName + "-annotations.png";
        deleteAnnotations[2] = backupFile;

        deletep = true;
      }

      if (deletep) {
        if (
          (mouseX > (width-iconSize-iconPadding)) &
          (mouseX < (width-iconSize-iconPadding)+iconSize) &
          (mouseY > (height-(iconSize*2)-(iconPadding)-(tDelete.height)-(textPadding*2))) &
          (mouseY < (height-(iconSize*2)-(iconPadding)-(tDelete.height)-(textPadding*2))+iconSize)
          ) {
          deletep = false;
          deleteTimeout = 0;
        }
        if (
          (mouseX > (width-iconSize-iconPadding)) &
          (mouseX < (width-iconSize-iconPadding)+iconSize) &
          (mouseY > (height-(iconSize*3)-(iconPadding*2)-(tDelete.height)-(textPadding*2))) &
          (mouseY < (height-(iconSize*3)-(iconPadding*2)-(tDelete.height)-(textPadding*2))+iconSize)
          ) {
          if ((new File (projectParent + "/" + projectName + "-annotations.png")).exists())
          {
            exec(deleteAnnotations);
          }
          deletep = false;
          deleteTimeout = 0;
        }
      }
    }
  }
}

void fileSelected(File selection) {
  if (selection != null) {
    projectArray[0] = selection.getAbsolutePath();
    saveStrings(projectPath, projectArray);
    //Update paths
    projectParent = (new File (projectArray[0])).getParent();
    projectName = getNameWithoutExt(new File (projectArray[0]));
    //Check for userSettings
    userSettingsp = false;
    userSettingsPath = projectParent + "/" + projectName + ".piscore";
    userSettingsFile = new File(userSettingsPath);
    if (userSettingsFile.exists()) {
      userSettingsp = true;
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
