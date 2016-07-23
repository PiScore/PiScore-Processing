String   rootPath;

String[] folderArray = { null };
String   folderPath;
File     folderFile;

void setup() {
  rootPath = sketchPath("../../");
  
  folderPath = rootPath + "etc/prev-folder-path.txt";
  folderFile = new File(folderPath);
  if (folderFile.exists()) {
    folderArray = loadStrings(folderPath);
  } else {
    folderArray[0] = rootPath;
    saveStrings(folderPath, folderArray);
  }
  
  selectFolder("Please select a folder", "folderSelected", new File(folderArray[0]));
}

void folderSelected(File selection) {
  if (selection == null) {
    exit();
  } else {
    println("User selected " + selection.getAbsolutePath());
    folderArray[0] = selection.getAbsolutePath();
    saveStrings(folderPath, folderArray);
    exit();
  }
}