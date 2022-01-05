import processing.sound.*;
import hype.*;
import hype.extended.behavior.*;
import hype.extended.colorist.*;
import hype.extended.layout.*;
import hype.interfaces.*;




// Size of cells
int cellSize = 25;


SoundFile soundfile;


// How likely for a cell to be alive at start (in percentage)
float probabilityOfAliveAtStart = 15;

// Variables for timer
int interval = 700;
int lastRecordedTime = 0;
int numColors = 100;
// Colors for active/inactive cells
color alive = color(120,10,10); //dark red



color dead = color(255); //white
color t1 = color(255,255,0); //yello
color t2 = color (0,0,255); //blue
color no_neighbor = color( 232,0,245); //pink
color  yes_neighbor = color (0); //black

// Array of cells
int[][] cells; 
// Buffer to record the state of the cells and use this while changing the others in the interations
int[][] cellsBuffer; 

//color[] t_colors = new color[numColors]; 


// Pause
boolean pause = false;




//////////////////////////////////////////////////////////////////////////////////////////
void setup() {
  size (1200, 650);

// Load a soundfile
  soundfile = new SoundFile(this, "vibraphon.aiff");

  // These methods return useful infos about the file
  println("SFSampleRate= " + soundfile.sampleRate() + " Hz");
  println("SFSamples= " + soundfile.frames() + " samples");
  println("SFDuration= " + soundfile.duration() + " seconds");

  // Play the file in a loop
  soundfile.loop();
  // Instantiate arrays 
  cells = new int[width/cellSize][height/cellSize];
  cellsBuffer = new int[width/cellSize][height/cellSize];

  // This stroke will draw the background grid
  stroke(1);

  noSmooth();

  // Initialization of cells
  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      float state = random (100);
      if (state > probabilityOfAliveAtStart) { 
        state = 0;
      }
      else {
        state = 1;
      }
      cells[x][y] = int(state); // Save state of each cell
    }
  }
  background(0); // Fill in black in case cells don't cover all the windows
}

 
void draw() {

 
  PImage colours = loadImage("colours.jpg");
  color c = colours.get(mouseX, mouseY);
//color c = landscape.get(X, Y);
//  //Draw grid  
  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      if (cells[x][y]==1) {
        fill(c);
          
        
    
      }
      else {
        fill(dead); // If dead
      }
      
      // center of cell 
      float cx = x*cellSize + cellSize/2;
      float cy = y*cellSize + cellSize/2;
      float ch = cellSize/2; // half cell 
      
      //ellipse(x*cellSize + cellSize/2, y*cellSize + cellSize/2, cellSize, cellSize);
     triangle(cx-ch, cy-ch, cx-ch, cy+ch, cx+ch, cy-ch);
      
     triangle(cx+ch, cy-ch, cx-ch, cy+ch, cx+ch, cy+ch);
      
    }
  }
  // Iterate if timer ticks
  if (millis()-lastRecordedTime>interval) {
    if (!pause) {
      iteration();
      lastRecordedTime = millis();
    }
  }

  // Create  new cells manually on pause
  if (pause && mousePressed) {
    // Map and avoid out of bound errors
    int xCellOver = int(map(mouseX, 0, width, 0, width/cellSize));
    xCellOver = constrain(xCellOver, 0, width/cellSize-1);
    int yCellOver = int(map(mouseY, 0, height, 0, height/cellSize));
    yCellOver = constrain(yCellOver, 0, height/cellSize-1);
    
     // Map mouseX from 0.25 to 4.0 for playback rate. 1 equals original playback speed,
  // 2 is twice the speed and will sound an octave higher, 0.5 is half the speed and
  // will make the file sound one ocative lower.
    float playbackSpeed = map(mouseX, 0, width, 0.25, 4.0);
    soundfile.rate(playbackSpeed);

  // Map mouseY from 0.2 to 1.0 for amplitude
    float amplitude = map(mouseY, 0, width, 0.2, 1.0);
    soundfile.amp(amplitude);

  // Map mouseY from -1.0 to 1.0 for left to right panning
    float panning = map(mouseY, 0, height, -1.0, 1.0);
    soundfile.pan(panning);

// PImage landscape = loadImage("landscape.jpg");
//background(mountains);
//noStroke();
//color c = landscape.get(mouseX, mouseY);
    // Check against cells in buffer
    if (cellsBuffer[xCellOver][yCellOver]==1) { // Cell is alive
      cells[xCellOver][yCellOver]=0; // Kill
  
     
 

      
    }
    else { // Cell is dead
      cells[xCellOver][yCellOver]=1; // Make alive
       
          


    }
  } 
  
  else if (pause && !mousePressed) { // And then save to buffer once mouse goes up
    // Save cells to buffer (so we opeate with one array keeping the other intact)
    for (int x=0; x<width/cellSize; x++) {
      for (int y=0; y<height/cellSize; y++) {
        cellsBuffer[x][y] = cells[x][y];
      }
    }
  }
}


void iteration() { // When the clock ticks
  // Save cells to buffer (so we opeate with one array keeping the other intact)
  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      cellsBuffer[x][y] = cells[x][y];
    }
  }

  // Visit each cell:
  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      // And visit all the neighbours of each cell
      int neighbours = 0; // We'll count the neighbours
      for (int xx=x-1; xx<=x+1;xx++) {
        for (int yy=y-1; yy<=y+1;yy++) {  
          if (((xx>=0)&&(xx<width/cellSize))&&((yy>=0)&&(yy<height/cellSize))) { // Make sure you are not out of bounds
            if (!((xx==x)&&(yy==y))) { // Make sure to to check against self
              if (cellsBuffer[xx][yy]==1){
                neighbours ++; // Check alive neighbours and count them
              }
            } // End of if
          } // End of if
        } // End of yy loop
      } //End of xx loop
      // We've checked the neigbours: apply rules!
      if (cellsBuffer[x][y]==1) { // The cell is alive: kill it if necessary
        if (neighbours < 3 || neighbours > 4) {
          cells[x][y] = 0; // Die unless it has 3 or 4 neighbours
          
          
        }
      } 
      else { // The cell is dead: make it live if necessary      
        if (neighbours == 3 ) {
          cells[x][y] = 1; // Only if it has 3 neighbours
          
        }
      } // End of if
    } // End of y loop
  } // End of x loop
} // End of function




void keyPressed() {
  if (key=='r' || key == 'R') {
    // Restart: reinitialization of cells
    for (int x=0; x<width/cellSize; x++) {
      for (int y=0; y<height/cellSize; y++) {
        float state = random (100);
        if (state > probabilityOfAliveAtStart) {
          state = 0;
        }
        else {
          state = 1;
        }
        cells[x][y] = int(state); // Save state of each cell
      }
    }
  }
  if (key==' ') { // On/off of pause
    pause = !pause;
  }
  if (key=='c' || key == 'C') { // Clear all
    for (int x=0; x<width/cellSize; x++) {
      for (int y=0; y<height/cellSize; y++) {
        cells[x][y] = 0; // Save all to zero
      }
    }
  }
}
