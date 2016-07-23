String scorePath;

void setup() {
  selectFolder("Please select a folder", "folderSelected");
}

void folderSelected(File selection) {
  if (selection == null) {
    exit();
  } else {
    println("User selected " + selection.getAbsolutePath());
  }
}