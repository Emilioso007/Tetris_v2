final int tileSize = 32;
final int screenWidth = 10;
final int screenHeight = 20;

boolean newPiece;

//PVector array used to store
//the coordinates of the minos
//of a tetrimino
PVector[] tetrimino;

//PVector used to rotete
//the tetriminos
PVector translation;

//the old blocks in level, not
//yet removed
color[][] garbage;

int score;

//Special functions, where we
//are allowed to use viables
//to set screen size
void settings() {
  size(screenWidth*tileSize, screenHeight*tileSize);
}

void setup() {

  frameRate(5);
  
  score = 0;

  //the tetriminos which a 'dead'
  //we store them in a boolean
  //array, as we only need to
  //if they are there or not
  garbage = new color[screenWidth][screenHeight];

  for (int x = 0; x < screenWidth; x++) {
    for (int y = 0; y < screenHeight; y++) {
      garbage[x][y] = color(0, 0, 0);
    }
  }

  //should we create a new
  //tetrimino at the start
  //of next loop
  newPiece = true;

  //used to rotate the tetriminos
  //try and figure out how it
  //works. HARD
  translation = new PVector(0, 0);
}

void draw() {
  if (newPiece) {
    translation = new PVector(0, 0);
    tetrimino = createNewPiece();
    newPiece = false;
  }

  background(0);

  //draw the minos of the active
  //tetrimino.
  for (int i = 0; i < 4; i++) {
    PVector mino = tetrimino[i];
    fill(tetrimino[4].x, tetrimino[4].y, tetrimino[4].z);
    rect(mino.x*tileSize, mino.y*tileSize, tileSize, tileSize);
  }

  //draw garbage
  for (int y = 0; y < screenHeight; y++) {
    for (int x = 0; x < screenWidth; x++) {
      if (garbage[x][y] != color(0, 0, 0)) {
        fill(garbage[x][y]);
        rect(x*tileSize, y*tileSize, tileSize, tileSize);
      }
    }
  }

  //mino hasn't hit the lower bounds
  //of the level or garbage
  for (int i = 4-1; i >= 0; i--) {

    if (tetrimino[i].y >= 0) { //we don't check collision if piece is above the sceen
      if (tetrimino[i].y >= screenHeight-1 || garbage[(int)tetrimino[i].x][(int)tetrimino[i].y+1] != color(0, 0, 0)) {
        newPiece = true;
      }
    }

    //when a new piece is to be generated
    //we put the current piece to garbage

    if (newPiece) {
      for (int j = 0; j < 4; j++) {
        if ((int)tetrimino[j].y >= 0) {
          garbage[(int)tetrimino[j].x][(int)tetrimino[j].y] = color(tetrimino[4].x, tetrimino[4].y, tetrimino[4].z);
        } else {
          textAlign(CENTER);
          textSize(50);
          //fill(255, 0, 0);
          //text("GAME OVER!", width/2, height/2);
          fill(0);
          for (int x = -2; x < 3; x++) {
            //  for(int y = -1; y < 2; y++){
            //    text("LIKE THIS!", 20+x,20+y);
            //  }
            text("GAME OVER!", width/2+x, height/2);
            text("GAME OVER!", width/2, height/2+x);
          }
          fill(255, 0, 0);
          text("GAME OVER!", width/2, height/2);
          stop();
        }
      }
      break;
    }
  }

  if (!newPiece) {
    for (int i = 4-1; i >= 0; i--) {
      PVector mino = tetrimino[i];
      mino.add(new PVector(0, 1));
    }
    translation.add(new PVector(0, 1));
  }

  //check for cleared lines
  for (int y = 0; y < screenHeight; y++) {
    boolean lineClear = true;
    score++;
    for (int x = 0; x < screenWidth; x++) {
      if (garbage[x][y] == color(0, 0, 0)) {
        lineClear = false;
        score--;
        break;
      }
    }
    if (lineClear) {
      for (int i = y; i > 0; i--) {
        for (int x = 0; x < screenWidth; x++) {
          garbage[x][i] = garbage[x][i-1];
          
        }
      }
    }
  }
  fill(255);
  textSize(25);
  text("Score: " + score, 100, 100);
}

void keyPressed() {
  int currKey = keyCode;
  PVector[] newLocation = new PVector[5];

  if (key == CODED) {
    switch (currKey) {
    case LEFT:
      //copy the tetrimino and move it left
      //if the new location is valid
      PVector copyTetrimino[] = new PVector[5];
      for (int i = 0; i < 4; i++) {
        copyTetrimino[i] = tetrimino[i].copy().sub(new PVector(1, 0));
      }
      copyTetrimino[4] = tetrimino[4].copy();
      if (!collision(copyTetrimino)) {
        tetrimino = copyTetrimino;
        translation.sub(new PVector(1, 0));
      }

      break;
    case RIGHT:
      //copy the tetrimino and move it right
      //if the new location is valid
      PVector copyTetrimino2[] = new PVector[5];
      for (int i = 0; i < 4; i++) {
        copyTetrimino2[i] = tetrimino[i].copy().add(new PVector(1, 0));
      }
      copyTetrimino2[4] = tetrimino[4].copy();
      if (!collision(copyTetrimino2)) {
        tetrimino = copyTetrimino2;
        translation.add(new PVector(1, 0));
      }

      break;
    case UP:
      //iterate through all minos in the
      //tetrimino, copy and rotate them
      //we then check if the new location
      //is valid, if yes we use the new
      //copy as the current tetrimino
      for (int i = 0; i < 4; i++) {
        PVector mino = tetrimino[i].copy();
        mino.set(new PVector(
          round(mino.copy().sub(translation).rotate(radians(-90)).add(translation).x),
          round(mino.copy().sub(translation).rotate(radians(-90)).add(translation).y)));
        newLocation[i] = mino;
      }
      newLocation[4] = tetrimino[4].copy();
      if (!collision(newLocation)) {
        tetrimino = newLocation;
      }

      break;
    case DOWN:
      for (int i = 0; i < 4; i++) {
        PVector mino = tetrimino[i].copy();
        mino.set(new PVector(
          round(mino.copy().sub(translation).rotate(radians(90)).add(translation).x),
          round(mino.copy().sub(translation).rotate(radians(90)).add(translation).y)));
        newLocation[i] = mino;
      }
      newLocation[4] = tetrimino[4].copy();
      if (!collision(newLocation)) {
        tetrimino = newLocation;
      }

      break;
    }
  }
}

//ASSIGNMENTS
//GREEN
//*Have the tetriminos spawn at the top above of the screen DONE
//*Implement the remaining tetriminos DONE
//*Implement game over
//*Implement score
//*Have the game speed up as time goes on
//YELLOW
//*Rotate tetriminos around their center
//*Refactor the code, so that it is easier to read.
//RED
//*Allow the player to move the tetriminos left and right multiple times before it moves down
//*Implement a hold/swap function
//*Implement a preview of the next piece
//*Implement a 'hard drop' function
