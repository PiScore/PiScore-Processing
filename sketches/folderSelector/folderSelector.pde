String   rootPath;

String[] projectArray = { null };
String   projectPath;
File     projectFile;

void setup() {
  rootPath = sketchPath("../../");
  
  projectPath = rootPath + "etc/project-path.txt";
  projectFile = new File(projectPath);
  if (projectFile.exists()) {
    projectArray = loadStrings(projectPath);
  } else {
    projectArray[0] = rootPath;
    saveStrings(projectPath, projectArray);
  }
  selectFolder("Set project folder...", "folderSelected", new File(projectArray[0]));
}

void folderSelected(File selection) {
  if (selection == null) {
    exit();
  } else {
    projectArray[0] = selection.getAbsolutePath();
    saveStrings(projectPath, projectArray);
    exit();
  }
}