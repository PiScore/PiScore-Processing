String rootPath;

String[] launch = { null, null, null };
String[] reboot = {"sudo", "reboot"};
String[] shutdown = {"sudo", "shutdown", "now"};
String[] deleteAnnotations = { null, null, null };

String annotationsPath;
File annotationsFile;
String backupPath;
String backupFile;

PImage bLaunch, bReboot, bShutdown, bTerminal, bDelete, bCheck, bCross, bEmpty, bEdit, bEditSelected;
PImage tReboot, tShutdown, tTerminal, tDelete;

String[] numpadArray = { "7", "8", "9", "4", "5", "6", "1", "2", "3", "0", ".", "\u2190" };
String[] numpadDecisionArray = { "Cancel", "Accept" };

String[] clientpArray = { null };
String clientpPath;
File clientpFile;
boolean clientp;

String[] serverIpAddrArray = { null };
String serverIpAddrPath;
File serverIpAddrFile;
String serverIpAddr;
String serverIpAddrTemp;

boolean loadingp = false;
boolean deletep = false;
boolean ipEditp = false;
int deleteTimeout = 0;

String currentTime;

final int fps = 10;
int loadingCounter = 0;

final int iconSize = 50;
final int iconSizeLarge = 100;
final int iconPadding = 10;
final int textPadding = 5;

void setup () {
  frameRate(fps);
  size(800, 480);
  smooth();
  cursor(HAND);

  rootPath = sketchPath("../../");

  serverIpAddrPath = sketchPath("../../etc/server-ip-addr.txt");
  serverIpAddrFile = new File(serverIpAddrPath);
  if (serverIpAddrFile.exists()) {
    serverIpAddrArray = loadStrings(serverIpAddrPath);
  } else {
    serverIpAddrArray[0] = "192.168.0.14"; // Arbitrary default
    saveStrings(serverIpAddrPath, serverIpAddrArray);
  }
  serverIpAddr = serverIpAddrArray[0];
  serverIpAddrTemp = serverIpAddr + "_";

  clientpPath = sketchPath("../../etc/clientp.txt");
  clientpFile = new File(clientpPath);
  if (clientpFile.exists()) {
    clientpArray = loadStrings(clientpPath);
  } else {
    clientpArray[0] = "false"; // Defaults to server
    saveStrings(clientpPath, clientpArray);
  }
  clientp = boolean(clientpArray[0]);

  launch[0] = "/usr/local/bin/processing-java";
  launch[1] = "--sketch=" + rootPath + "sketches/sketch_Server/";
  launch[2] = "--run";

  deleteAnnotations[0] = "mv";
  deleteAnnotations[1] = rootPath + "files/annotations.png";

  backupPath = rootPath + "files/annotationBackup/";

  bLaunch = loadImage("./gui/white-100px-flash-outlined-thin-circular-button.png");
  bReboot = loadImage("./gui/circular-arrow-in-rounded-button.png");
  bShutdown = loadImage("./gui/power-outlined-circular-button.png");
  bTerminal = loadImage("./gui/monitor-circular-thin-button.png");
  bDelete = loadImage("./gui/trash-can-circular-outlined-button.png");
  bCheck = loadImage("./gui/white-50px-checkmark-outlined-circular-button.png");
  bCross = loadImage("./gui/close-cross-thin-circular-button.png");
  bEmpty = loadImage("./gui/white-50px-empty-circular-button.png");
  bEdit = loadImage("./gui/white-50px-edit-pencil-outline-in-circular-button.png");
  bEditSelected = loadImage("./gui/selected-white-50px-edit-pencil-outline-in-circular-button.png");

  tReboot = loadImage("./guiText/reboot.png");
  tShutdown = loadImage("./guiText/shutdown.png");
  tTerminal = loadImage("./guiText/terminal.png");
  tDelete = loadImage("./guiText/delete.png");
}

void draw() {
  background(color(0, 90, 158)); 

  if (!loadingp) {
    fill(255);
    textAlign(CENTER, TOP);
    textSize(32);
    text("Example Score", (width/2), (iconSize+iconPadding));
    textSize(20);
    text("by David Stephen Grant", (width/2), (iconSize+iconPadding+42));

    if (!ipEditp) {
      image(bLaunch, ((width/2)-(iconSizeLarge*0.5)), ((height/2)-(iconSizeLarge*0.5)));
      fill(255);
      textAlign(CENTER, CENTER);
      textSize(14);
      text("Launch", (width/2), ((height/2)+(iconSizeLarge*0.5)+iconPadding));
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

  if (loadingp) {
    if (loadingCounter < (fps * 15)) { //Timeout
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
    }
  }
}

void mousePressed() {
  if (!loadingp) {
    //Launch
    if (!ipEditp) {
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
        serverIpAddrTemp = serverIpAddrTemp.substring(0, serverIpAddrTemp.length()-2);
        serverIpAddrTemp = serverIpAddrTemp + "_";
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
      currentTime = (year() + "-" + month() + "-" + day() + "-" + hour() + "-" + minute() + "-" + second() + "-" + millis());
      backupFile = (backupPath + currentTime + "-annotations" + ".png");
      deleteAnnotations[2] = backupFile;
      annotationsPath = sketchPath("../../files/annotations.png");
      annotationsFile = new File(annotationsPath);

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
        if (annotationsFile.exists())
        {
          exec(deleteAnnotations);
        }
        deletep = false;
        deleteTimeout = 0;
      }
    }
  }
}