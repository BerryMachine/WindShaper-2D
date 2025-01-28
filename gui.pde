/* =========================================================
 * ====                   WARNING                        ===
 * =========================================================
 * The code in this tab has been generated from the GUI form
 * designer and care should be taken when editing this file.
 * Only add/edit code inside the event handlers i.e. only
 * use lines between the matching comment tags. e.g.

 void myBtnEvents(GButton button) { //_CODE_:button1:12356:
     // It is safe to enter your event code here  
 } //_CODE_:button1:12356:
 
 * Do not rename this tab!
 * =========================================================
 */

synchronized public void win_draw1(PApplet appc, GWinData data) { //_CODE_:window1:443863:
  appc.background(230);
} //_CODE_:window1:443863:

public void preset_change(GDropList source, GEvent event) { //_CODE_:Presets:291406:
  obstacles = new ArrayList<Obstacle>(); // reset obstacles
  scene.loadPreset(int(source.getSelectedText())); // load new chosen preset
  customGUI(); // update GUI values
  scene.setupScene();
} //_CODE_:Presets:291406:

public void toolDeleteSelected(GImageToggleButton source, GEvent event) { //_CODE_:toolDelete:642196:
  changeMouseMode(MouseMode.DELETE, source);
} //_CODE_:toolDelete:642196:

public void toolLineSelected(GImageToggleButton source, GEvent event) { //_CODE_:toolLine:211004:
  changeMouseMode(MouseMode.LINE, source);
} //_CODE_:toolLine:211004:

public void toolCircleSelected(GImageToggleButton source, GEvent event) { //_CODE_:toolCircle:781370:
  changeMouseMode(MouseMode.CIRCLE, source);
} //_CODE_:toolCircle:781370:

public void toolMoveSelected(GImageToggleButton source, GEvent event) { //_CODE_:toolMove:607553:
  changeMouseMode(MouseMode.MOVE, source);
} //_CODE_:toolMove:607553:

public void UploadText(GTextField source, GEvent event) { //_CODE_:UploadField:233608:

} //_CODE_:UploadField:233608:

public void UploadFile(GButton source, GEvent event) { //_CODE_:UploadButton:455040:
  try {
    scene.read_config(UploadField.getText().trim()); // trim whitespaces
    obstacles = new ArrayList<Obstacle>(); // reset obstacles
    scene.read_obstacles(UploadField.getText().trim()); // upload new obstacles
    customGUI();
    scene.setupScene();
  } catch (RuntimeException e) {
    println("[ERROR] Corrupted or missing file (check data folder): " + e);
  }
} //_CODE_:UploadButton:455040:

public void ExportFile(GButton source, GEvent event) { //_CODE_:ExportButton:441661:
  scene.write_config(ExportField.getText().trim());
  scene.write_obstacles(ExportField.getText().trim());
} //_CODE_:ExportButton:441661:

public void ExportText(GTextField source, GEvent event) { //_CODE_:ExportField:637908:

} //_CODE_:ExportField:637908:

public void SmokeSepChange(GSlider source, GEvent event) { //_CODE_:SmokeSepSlider:984815:
  scene.smoke_sep = SmokeSepSlider.getValueI();
  scene.setupScene();
} //_CODE_:SmokeSepSlider:984815:

public void SmokeSizeChange(GSlider source, GEvent event) { //_CODE_:SmokeSizeSlider:513617:
  scene.smoke_size = SmokeSizeSlider.getValueI();
  scene.setupScene();
} //_CODE_:SmokeSizeSlider:513617:

public void InvelocityChange(GSlider source, GEvent event) { //_CODE_:InvelocitySlider:918243:
  scene.invelocity = InvelocitySlider.getValueF();
  scene.setupScene();
} //_CODE_:InvelocitySlider:918243:

public void ShowGravityChecked(GCheckbox source, GEvent event) { //_CODE_:ShowGravityCheck:605610:
  scene.show_gravity = ShowGravityCheck.isSelected();
} //_CODE_:ShowGravityCheck:605610:

public void ShowPressureChecked(GCheckbox source, GEvent event) { //_CODE_:ShowPressureCheck:207702:
  scene.show_pressure = ShowPressureCheck.isSelected();
} //_CODE_:ShowPressureCheck:207702:

public void ShowSmokeChecked(GCheckbox source, GEvent event) { //_CODE_:ShowSmokeCheck:961781:
  scene.show_smoke = ShowSmokeCheck.isSelected();
} //_CODE_:ShowSmokeCheck:961781:

public void FPSChecked(GCheckbox source, GEvent event) { //_CODE_:FPSCheck:905053:
  scene.show_fps = FPSCheck.isSelected();
} //_CODE_:FPSCheck:905053:

public void InvelocityDirectionChoice(GDropList source, GEvent event) { //_CODE_:InvelocityDirection:684147:
  if (InvelocityDirection.getSelectedText().equals("Right")) {scene.direction = 0;}
  else if (InvelocityDirection.getSelectedText().equals("Left")) {scene.direction = 1;}
  else if (InvelocityDirection.getSelectedText().equals("Up")) {scene.direction = 2;}
  else if (InvelocityDirection.getSelectedText().equals("Down")) {scene.direction = 3;}
  else {println("Error: " + InvelocityDirection.getSelectedText());}
  scene.setupScene();
} //_CODE_:InvelocityDirection:684147:

public void StreamlineChecked(GCheckbox source, GEvent event) { //_CODE_:StreamlineCheck:251690:
  scene.show_streamline = StreamlineCheck.isSelected();
  scene.setupScene();
} //_CODE_:StreamlineCheck:251690:

public void RefreshClick(GButton source, GEvent event) { //_CODE_:Refresh:783125:
  scene.setupScene();
} //_CODE_:Refresh:783125:

public void PauseClick(GButton source, GEvent event) { //_CODE_:Pause:982304:
  scene.paused = !scene.paused;
} //_CODE_:Pause:982304:

public void ExitClick(GButton source, GEvent event) { //_CODE_:Exit:668292:
  scene.write_config("");
  scene.write_obstacles(""); // autosave before exiting
  exit();
} //_CODE_:Exit:668292:



// Create all the GUI controls. 
// autogenerated do not edit
public void createGUI(){
  G4P.messagesEnabled(false);
  G4P.setGlobalColorScheme(GCScheme.BLUE_SCHEME);
  G4P.setMouseOverEnabled(false);
  surface.setTitle("Sketch Window");
  window1 = GWindow.getWindow(this, "Window title", 0, 0, 360, 480, JAVA2D);
  window1.noLoop();
  window1.setActionOnClose(G4P.KEEP_OPEN);
  window1.addDrawHandler(this, "win_draw1");
  Presets = new GDropList(window1, 128, 72, 208, 96, 3, 10);
  Presets.setItems(loadStrings("list_291406"), 0);
  Presets.setLocalColorScheme(GCScheme.PURPLE_SCHEME);
  Presets.addEventHandler(this, "preset_change");
  toolDelete = new GImageToggleButton(window1, 32, 160, "delete-icon.png", "delete-icon.png", 2, 1);
  toolDelete.addEventHandler(this, "toolDeleteSelected");
  toolLine = new GImageToggleButton(window1, 32, 320, "line-icon.png", 2, 1);
  toolLine.addEventHandler(this, "toolLineSelected");
  toolCircle = new GImageToggleButton(window1, 32, 240, "circle-icon.png", 2, 1);
  toolCircle.addEventHandler(this, "toolCircleSelected");
  toolMove = new GImageToggleButton(window1, 32, 80, "movement-icon.png", "movement-icon.png", 2, 1);
  toolMove.addEventHandler(this, "toolMoveSelected");
  Title = new GLabel(window1, 80, 0, 200, 50);
  Title.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  Title.setText("WINDSHAPER 2D");
  Title.setLocalColorScheme(GCScheme.CYAN_SCHEME);
  Title.setOpaque(false);
  explain1 = new GLabel(window1, 120, 48, 224, 16);
  explain1.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  explain1.setText("Choose a preset or upload your own!");
  explain1.setOpaque(false);
  explain2 = new GLabel(window1, 128, 152, 216, 16);
  explain2.setTextAlign(GAlign.CENTER, GAlign.CENTER);
  explain2.setText("Export JSON file of current simulation");
  explain2.setOpaque(false);
  ToolsTitle = new GLabel(window1, 32, 48, 64, 16);
  ToolsTitle.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  ToolsTitle.setText("Tools");
  ToolsTitle.setOpaque(false);
  UploadField = new GTextField(window1, 128, 112, 120, 24, G4P.SCROLLBARS_NONE);
  UploadField.setPromptText("Enter filename.json");
  UploadField.setOpaque(true);
  UploadField.addEventHandler(this, "UploadText");
  UploadButton = new GButton(window1, 256, 112, 80, 24);
  UploadButton.setText("Upload!");
  UploadButton.addEventHandler(this, "UploadFile");
  ExportButton = new GButton(window1, 256, 176, 80, 24);
  ExportButton.setText("Export!");
  ExportButton.addEventHandler(this, "ExportFile");
  ExportField = new GTextField(window1, 128, 176, 120, 24, G4P.SCROLLBARS_NONE);
  ExportField.setPromptText("Enter filename");
  ExportField.setOpaque(true);
  ExportField.addEventHandler(this, "ExportText");
  SmokeSepSlider = new GSlider(window1, 128, 256, 104, 40, 10.0);
  SmokeSepSlider.setShowValue(true);
  SmokeSepSlider.setShowLimits(true);
  SmokeSepSlider.setLimits(25, 1, 50);
  SmokeSepSlider.setNumberFormat(G4P.INTEGER, 0);
  SmokeSepSlider.setOpaque(false);
  SmokeSepSlider.addEventHandler(this, "SmokeSepChange");
  SettingsTitle = new GLabel(window1, 128, 216, 216, 20);
  SettingsTitle.setTextAlign(GAlign.CENTER, GAlign.MIDDLE);
  SettingsTitle.setText("Settings");
  SettingsTitle.setOpaque(false);
  SmokeSizeSlider = new GSlider(window1, 128, 312, 104, 40, 10.0);
  SmokeSizeSlider.setShowValue(true);
  SmokeSizeSlider.setShowLimits(true);
  SmokeSizeSlider.setLimits(25, 1, 100);
  SmokeSizeSlider.setNumberFormat(G4P.INTEGER, 0);
  SmokeSizeSlider.setOpaque(false);
  SmokeSizeSlider.addEventHandler(this, "SmokeSizeChange");
  InvelocitySlider = new GSlider(window1, 128, 368, 104, 40, 10.0);
  InvelocitySlider.setShowValue(true);
  InvelocitySlider.setShowLimits(true);
  InvelocitySlider.setLimits(500.0, 100.0, 1000.0);
  InvelocitySlider.setNumberFormat(G4P.DECIMAL, 2);
  InvelocitySlider.setOpaque(false);
  InvelocitySlider.addEventHandler(this, "InvelocityChange");
  SmokeSepLabel = new GLabel(window1, 128, 240, 104, 16);
  SmokeSepLabel.setText("Smoke Separation");
  SmokeSepLabel.setOpaque(false);
  SmokeSizeLabel = new GLabel(window1, 128, 296, 104, 16);
  SmokeSizeLabel.setText("Smoke Width");
  SmokeSizeLabel.setOpaque(false);
  SmokeInvelocityLabel = new GLabel(window1, 128, 352, 104, 16);
  SmokeInvelocityLabel.setText("Inwards Velocity");
  SmokeInvelocityLabel.setOpaque(false);
  ShowGravityCheck = new GCheckbox(window1, 240, 272, 104, 24);
  ShowGravityCheck.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  ShowGravityCheck.setText("Show Gravity");
  ShowGravityCheck.setOpaque(false);
  ShowGravityCheck.addEventHandler(this, "ShowGravityChecked");
  ShowPressureCheck = new GCheckbox(window1, 240, 296, 104, 24);
  ShowPressureCheck.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  ShowPressureCheck.setText("Show Pressure");
  ShowPressureCheck.setOpaque(false);
  ShowPressureCheck.addEventHandler(this, "ShowPressureChecked");
  ShowPressureCheck.setSelected(true);
  ShowSmokeCheck = new GCheckbox(window1, 240, 328, 104, 24);
  ShowSmokeCheck.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  ShowSmokeCheck.setText("Show Smoke");
  ShowSmokeCheck.setOpaque(false);
  ShowSmokeCheck.addEventHandler(this, "ShowSmokeChecked");
  ShowSmokeCheck.setSelected(true);
  FPSCheck = new GCheckbox(window1, 240, 376, 104, 24);
  FPSCheck.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  FPSCheck.setText("Show FPS");
  FPSCheck.setOpaque(false);
  FPSCheck.addEventHandler(this, "FPSChecked");
  InvelocityDirection = new GDropList(window1, 240, 240, 104, 120, 4, 10);
  InvelocityDirection.setItems(loadStrings("list_684147"), 0);
  InvelocityDirection.setLocalColorScheme(GCScheme.PURPLE_SCHEME);
  InvelocityDirection.addEventHandler(this, "InvelocityDirectionChoice");
  StreamlineCheck = new GCheckbox(window1, 240, 352, 104, 24);
  StreamlineCheck.setIconAlign(GAlign.LEFT, GAlign.MIDDLE);
  StreamlineCheck.setText("Streamlines");
  StreamlineCheck.setOpaque(false);
  StreamlineCheck.addEventHandler(this, "StreamlineChecked");
  Refresh = new GButton(window1, 32, 424, 72, 24);
  Refresh.setText("Refresh");
  Refresh.addEventHandler(this, "RefreshClick");
  Pause = new GButton(window1, 144, 424, 72, 24);
  Pause.setTextAlign(GAlign.CENTER, GAlign.CENTER);
  Pause.setText("Play/Pause");
  Pause.addEventHandler(this, "PauseClick");
  Exit = new GButton(window1, 256, 424, 72, 24);
  Exit.setText("Exit");
  Exit.addEventHandler(this, "ExitClick");
  window1.loop();
}

// Variable declarations 
// autogenerated do not edit
GWindow window1;
GDropList Presets; 
GImageToggleButton toolDelete; 
GImageToggleButton toolLine; 
GImageToggleButton toolCircle; 
GImageToggleButton toolMove; 
GLabel Title; 
GLabel explain1; 
GLabel explain2; 
GLabel ToolsTitle; 
GTextField UploadField; 
GButton UploadButton; 
GButton ExportButton; 
GTextField ExportField; 
GSlider SmokeSepSlider; 
GLabel SettingsTitle; 
GSlider SmokeSizeSlider; 
GSlider InvelocitySlider; 
GLabel SmokeSepLabel; 
GLabel SmokeSizeLabel; 
GLabel SmokeInvelocityLabel; 
GCheckbox ShowGravityCheck; 
GCheckbox ShowPressureCheck; 
GCheckbox ShowSmokeCheck; 
GCheckbox FPSCheck; 
GDropList InvelocityDirection; 
GCheckbox StreamlineCheck; 
GButton Refresh; 
GButton Pause; 
GButton Exit; 
