A real-time 2D fluid dynamics simulator built with Processing 4 for my grade 12 CS project. 
Implements an Eulerian approach to CFD (computer fluid dynamics) to provide a lightweight tool where users can draw obstacles, adjust airflow settings, and 
observe real-time simulations based on a simplified Navier-Stokes equations. All the math for semi-Lagrangian advection and a pressure projection step was 
based on Matthias Müller's "Ten Minute Physics -- How to write an Eulerian fluid simulator with 200 lines of code" Youtube Video and Jos Stam’s Real-Time Fluid Dynamics for Games paper.

How to run:

### Method 1: Using the Processing IDE (Recommended)

This is the simplest way to run the project.

1.  **Download Processing:** Get the free Processing Development Environment (PDE) from the [official website](https://processing.org/download/).
2.  **Open the Sketch:**
    * Download this project's folder.
    * Open the Processing IDE.
    * Go to `File > Open...` and navigate to this project's folder.
    * Select the main `.pde` file.
3.  **Run the Sketch:** Click the "Run" (triangle) button at the top of the IDE.



### Method 2: Using the Command Line (Advanced)

You can also run this sketch from your terminal if you have `processing-java` installed.

1.  **Install `processing-java`:**
    * Open the Processing IDE.
    * Go to `Tools > Install "processing-java"` and follow the instructions.
2.  **Navigate to the Project:** Open your terminal or command prompt and use `cd` to navigate into this project's directory (the folder that contains the `.pde` file).
    ```sh
    cd path/to/your/sketch_folder
    ```
3.  **Run the Command:**
    ```sh
    processing-java --sketch=$(pwd) --run
    ```

