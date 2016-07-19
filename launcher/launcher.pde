//WARNING!
//This sketch runs shell commands with hard coded paths.
//Use with caution.

String[] launchServer = {"/usr/local/bin/processing-java", "--sketch=/home/pi/Documents/Scores/dev/sketch_Server/", "--run"};
String[] launchClient = {"/usr/local/bin/processing-java", "--sketch=/home/pi/Documents/Scores/dev/sketch_Client/", "--run"};
String[] reboot = {"sudo", "reboot"};
String[] shutdown = {"sudo", "shutdown", "now"};
String[] deleteAnnotations = { "mv", "/home/pi/Documents/Scores/dev/files/annotations.png", null };

String annotationsPath;
File annotationsFile;
String backupPath = "/home/pi/Documents/Scores/dev/files/annotationBackup/";
String backupFile;

PImage bLaunchServer, bLaunchClient, bReboot, bShutdown, bTerminal, bDelete, bCheck, bCross;
PImage tReboot, tShutdown, tTerminal, tDelete;

boolean loadingp = false;
boolean deletep = false;
int deleteTimeout = 0;

String currentTime;

final int fps = 10;
int loadingCounter = 0;

final int iconSize = 50;
final int iconPadding = 10;
final int textPadding = 5;

void setup () {
  frameRate(fps);
  size(800, 480);
  smooth();
  cursor(HAND);

  bLaunchServer = loadImage("./gui/add-circular-button-thin-symbol.png");
  bLaunchClient = loadImage("./gui/flash-outlined-thin-circular-button.png");
  bReboot = loadImage("./gui/circular-arrow-in-rounded-button.png");
  bShutdown = loadImage("./gui/power-outlined-circular-button.png");
  bTerminal = loadImage("./gui/monitor-circular-thin-button.png");
  bDelete = loadImage("./gui/trash-can-circular-outlined-button.png");
  bCheck = loadImage("./gui/checkmark-outlined-circular-button.png");
  bCross = loadImage("./gui/close-cross-thin-circular-button.png");

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
    //image(tTitle, ((width*0.5)-(tTitle.width*0.5)), (iconSize+iconPadding));
    
    image(bLaunchServer, ((width/2)-(iconSize*0.5)-iconSize-(iconPadding*2)), ((height/2)-(iconSize)-iconPadding));
    fill(255);
    textAlign(LEFT, CENTER);
    textSize(14);
    text("Launch Server", ((width/2)-(iconSize*0.5)-iconPadding), ((height/2)-(iconSize/2)-iconPadding));

    image(bLaunchClient, ((width/2)-(iconSize*0.5)-iconSize-(iconPadding*2)), ((height/2)+iconPadding));
   fill(255);
textAlign(LEFT, CENTER);
    textSize(14);
    text("Launch Client", ((width/2)-(iconSize*0.5)-iconPadding), ((height/2)+iconPadding+(iconSize/2)));


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
    //Launch Server
    if (
      (mouseX > ((width/2)-(iconSize*0.5)-iconSize-(iconPadding*2))) &
      (mouseX < ((width/2)-(iconSize*0.5)-iconSize-(iconPadding*2)+iconSize)) &
      (mouseY > ((height/2)-(iconSize/2)-(iconSize/2)-iconPadding)) &
      (mouseY < ((height/2)-(iconSize/2)-(iconSize/2)-iconPadding)+iconSize)
      ) {
      loadingp = true;
      exec(launchServer);
    }
    //Launch Client
    if (
      (mouseX > ((width/2)-(iconSize*0.5)-iconSize-(iconPadding*2))) &
      (mouseX < ((width/2)-(iconSize*0.5)-iconSize-(iconPadding*2)+iconSize)) &
      (mouseY > ((height/2)+(iconSize/2)-(iconSize/2)+iconPadding)) &
      (mouseY < ((height/2)+(iconSize/2)-(iconSize/2)+iconPadding)+iconSize)
      ) {
      loadingp = true;
      exec(launchClient);
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
      annotationsPath = sketchPath("../files/annotations.png");
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