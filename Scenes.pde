class Scene {
  // CONSTANTS
  float GRAVITY = -9.81;
  float DT = 1.0 / 60.0; // time step
  int ITERS = 60; // number of stress-solving iterations (accuracy)
  float OVERRELAXATION = 1.9; // smoothen pressure solve
  float DENSITY = 1000.0;
  
  // VARIABLES
  int smoke_size;    // width of smoke
  int smoke_sep;     // separation between adjacent stream lines
  int direction;     // direction of airflow (0 -> "right", 1 -> "left", 2 -> "up", 3 -> "down")
  float invelocity;  // speed of airflow
  
  // toggleable settings
  boolean show_gravity;
  boolean show_smoke;
  boolean show_pressure;
  boolean show_streamline;
  
  boolean show_fps = false;
  boolean paused = false;
  
  Scene (int preset) {
    loadPreset(preset);
    setupScene();
  }
  
  void loadPreset (int preset) { // load basic presets
    obstacles.add(new CircleObstacle(width/4, height/2, N, 75.0)); // first obstacle
    
    switch (preset) { // 3 presets to choose from
      case 1: // normal
        smoke_size = 25;
        smoke_sep = 25;
        direction = 0;
        show_streamline = false;
        invelocity = 500;
        show_gravity = false;
        show_smoke = true;
        show_pressure = false;
        break;
      case 2: // pressure gradient
        smoke_size = 25;
        smoke_sep = 25;
        direction = 0;
        show_streamline = false;
        invelocity = 500;
        show_gravity = false;
        show_smoke = true;
        show_pressure = true;
        break;
      case 3: // streamlines
        smoke_size = 80;
        smoke_sep = 12;
        direction = 0;
        show_streamline = true;
        invelocity = 500;
        show_gravity = false;
        show_smoke = true;
        show_pressure = false;
        break;
    }
  }
  
  void setupScene() {
    // init fluid
    fluid = new Fluid(this, this.DENSITY, N, N, CELLSIZE);
    
    // mark cells as solid where obstacles lie
    fluid.updateCells(obstacles);
    
    // init rendering smoke
    addSmoke(fluid);
  }

  void read_config(String fname) {
    JSONObject config_json;
    
    // load file
    if (fname != "") { // custom
      config_json = loadJSONObject("data/" + fname + ".json");
    } else { // autosave
      config_json = loadJSONObject("data/Autosave.json");
    }
  
    // intense error handling to avoid crashing
  
    if (!config_json.isNull("smoke_size")) {
      smoke_size = config_json.getInt("smoke_size");
    } else {
      println("[Warning] 'smoke_size' not found in JSON. Using default = 25");
      smoke_size = 25;
    }
  
    if (!config_json.isNull("smoke_sep")) {
      smoke_sep = config_json.getInt("smoke_sep");
    } else {
      println("[Warning] 'smoke_sep' not found in JSON. Using default = 10");
      smoke_sep = 10;
    }
  
    if (!config_json.isNull("direction")) {
      direction = config_json.getInt("direction");
    } else {
      println("[Warning] 'direction' not found in JSON. Using default = 0 (right)");
      direction = 0;
    }
  
    if (!config_json.isNull("invelocity")) {
      invelocity = config_json.getFloat("invelocity");
    } else {
      println("[Warning] 'invelocity' not found in JSON. Using default = 500");
      invelocity = 500;
    }
  
    if (!config_json.isNull("show_gravity")) {
      show_gravity = config_json.getBoolean("show_gravity");
    } else {
      println("[Warning] 'show_gravity' not found. Default = false");
      show_gravity = false;
    }
  
    if (!config_json.isNull("show_smoke")) {
      show_smoke = config_json.getBoolean("show_smoke");
    } else {
      println("[Warning] 'show_smoke' missing. Default = true");
      show_smoke = true;
    }
  
    if (!config_json.isNull("show_pressure")) {
      show_pressure = config_json.getBoolean("show_pressure");
    } else {
      println("[Warning] 'show_pressure' not found. Default = false");
      show_pressure = false;
    }
  
    if (!config_json.isNull("show_streamline")) {
      show_streamline = config_json.getBoolean("show_streamline");
    } else {
      println("[Warning] 'show_streamline' missing. Default = false");
      show_streamline = false;
    }
  }

  
  void write_config (String fname) {
    JSONObject config_json = new JSONObject();
    
    // store data in JSON
    config_json.setInt("smoke_size", smoke_size);
    config_json.setInt("smoke_sep", smoke_sep);
    config_json.setInt("direction", direction);
    config_json.setFloat("invelocity", invelocity);
    
    config_json.setBoolean("show_gravity", show_gravity);
    config_json.setBoolean("show_smoke", show_smoke);
    config_json.setBoolean("show_pressure", show_pressure);
    config_json.setBoolean("show_streamline", show_streamline);
    
    // write to file
    if (fname != "") { // custom
      try {
        saveJSONObject(config_json, "data/" + fname + ".json");
      } catch (Exception e) {
        println("[Error] Failed to save config file: " + e.getMessage());
      } 
    } else { // autosave
      saveJSONObject(config_json, "data/Autosave.json");
    }
    
  }


  void write_obstacles (String fname) {
    JSONArray obs_array = new JSONArray();
    int i = 0;
    
    
    for (Obstacle obs : obstacles) {
      JSONObject obs_json = new JSONObject();
      obs_json.setString("type", obs.type);
      obs_json.setFloat("origin_x", obs.origin.x);
      obs_json.setFloat("origin_y", obs.origin.y);
      obs_json.setInt("N", obs.N);
      
      // if circle, store radius
      if (obs.type.equals("CIRCLE")) {
        obs_json.setFloat("radius", ((CircleObstacle)obs).radius);
      }
      
      else if (obs.type.equals("LINE")) {
        obs_json.setFloat("endpoint_x", ((LineObstacle)obs).endpoint.x);
        obs_json.setFloat("endpoint_y", ((LineObstacle)obs).endpoint.y);
      }
      
      obs_array.setJSONObject(i, obs_json);
      i++;
    }
    
    if (fname != "") { // custom
      try {
        saveJSONArray(obs_array, "data/" + fname + "_obstacles.json");
      } catch (Exception e) {
        println("[Error] Failed to save obstacles: " + e.getMessage());
      }
    } else { // autosave
      saveJSONArray(obs_array, "data/Autosave_obstacles.json");
    }  
  }
  
  void read_obstacles (String fname) {
    JSONArray obs_array;
    
    if (fname != "") { // custom
      obs_array = loadJSONArray("data/"+fname+"_obstacles.json"); 
    } else { // autosave
      obs_array = loadJSONArray("data/Autosave_obstacles.json");
    }
    
    // reconstruct each obstacle
    for (int i = 0; i < obs_array.size(); i++) {
      JSONObject obs_json = obs_array.getJSONObject(i);
      
      String type = obs_json.getString("type");
      
      float origin_x = obs_json.getFloat("origin_x");
      float origin_y = obs_json.getFloat("origin_y");
      int N = obs_json.getInt("N");
      
      // circle obstacles
      if (type.equals("CIRCLE")) {
        float radius = obs_json.getFloat("radius");
        obstacles.add(new CircleObstacle(origin_x, origin_y, N, radius));  
      }
      
      else if (type.equals("LINE")) {
        float endpoint_x = obs_json.getFloat("endpoint_x");
        float endpoint_y = obs_json.getFloat("endpoint_y");
        obstacles.add(new LineObstacle(origin_x, origin_y, N, endpoint_x, endpoint_y));
      }
      
      //
    }
  }
  
  void addSmoke(Fluid f) {
    if (show_streamline) { // if showing streamlines
      int new_smoke_size = smoke_size / (N/smoke_sep); // divide smoke size evently into lines
      
      // add according to direction of inflow
      if (direction == 0) { // left -> right
        for (int j = 0; j < f.numY - new_smoke_size; j+=smoke_sep) { // intervals
          for (int k = 0; k < new_smoke_size; k++) {f.smoke[j+k] = 0.0;} // k is width of each streamline
        } 
      } else if (direction == 1) { // left <- right
        for (int j = 0; j < f.numY - new_smoke_size; j+=smoke_sep) {
          for (int k = 0; k < new_smoke_size; k++) {f.smoke[IX(f.numX-1, j+k)] = 0.0;}
        }
      } else if (direction == 2) { // down -> up
        for (int i = 0; i < f.numX - new_smoke_size; i+=smoke_sep) {
          for (int k = 0; k < new_smoke_size; k++) {f.smoke[IX(i+k, f.numY-1)] = 0.0;}
        } 
      } else if (direction == 3) {
        for (int i = 0; i < f.numX - new_smoke_size; i+=smoke_sep) { // down <- up
          for (int k = 0; k < new_smoke_size; k++) {f.smoke[IX(i+k, 0)] = 0.0;}
        }
      }
    }
    
    else { // if no streamlines
      int lower_bound = f.numY/2 - smoke_size/2;
      int upper_bound = f.numY/2 + smoke_size/2;
        
      if (direction == 0) { // left -> right
        for (int j = 0; j < f.numY; j++) {
          if (lower_bound <= j && j <= upper_bound) {f.smoke[j] = 0.0;}
          else {f.smoke[j] = 1.0;}
        } 
      } else if (direction == 1) { // left <- right
        for (int j = 0; j < f.numY; j++) {
          if (lower_bound <= j && j <= upper_bound) {f.smoke[IX(f.numX-1, j)] = 0.0;}
          else {f.smoke[j] = 1.0;}
        }
      } else if (direction == 2) {
        for (int i = 0; i < f.numY; i++) { // down -> up
          if (lower_bound <= i && i <= upper_bound) {f.smoke[IX(i, f.numY-1)] = 0.0;}
          else {f.smoke[i] = 1.0;}
        } 
      } else if (direction == 3) {
        for (int i = 0; i < f.numY; i++) { // down <- up
          if (lower_bound <= i && i <= upper_bound) {f.smoke[IX(i, 0)] = 0.0;}
          else {f.smoke[i] = 1.0;}
        }
      }
    }
    
  }
  // current frames-per-second at top-right corner
  void fpsDisplay() {
    // fps counter
    textAlign(RIGHT, TOP);
    textSize(24);
    fill(125);
    text("fps: " + frameRate, width - 10, 10);
  }
  
}
