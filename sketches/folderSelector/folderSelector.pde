String rootPath;
File   rootFile;


void setup() {
  rootPath = sketchPath("../../");
  rootFile = new File(rootPath);
  
  selectFolder("Please select a folder", "folderSelected", rootFile);
}

void folderSelected(File selection) {
  if (selection == null) {
    exit();
  } else {
    println("User selected " + selection.getAbsolutePath());
  }
}