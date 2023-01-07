HashMap<Integer, String> IDNumberBiomeType = new HashMap<Integer, String>();
HashMap<Integer, Integer> IDNumberColourRGB = new HashMap<Integer, Integer>();

// You can change these variables
int n = 200;
float blinksPerSecond = 60; // Recommended Range: 10-100
int numOfCities = 10; // Intially you wil have n different cities however those cities may merge together as the time goes on.
int deforestationAwarenessRate = 100; // 100 being 100%, 60 being 60%, Recommended Range: 0-100
int waterPollutionAwarernessRate = 100; // 100 being 100%, 60 being 60%, Recommended Range: 0-100
int airPollutionAwarenessRate = 100; // 100 being 100%, 60 being 60%, Recommended Range: 0-100

int[][] terrain = new int[n][n];
float NOISE_INCREMENT = 0.05*(200/float(n));
int[][] air = new int[n][n];
int[][] xSpeeds = new int[n][n];
int[][] ySpeeds = new int[n][n];
int[][] airNext = new int[n][n];
int[][] xSpeedsNext = new int[n][n];
int[][] ySpeedsNext = new int[n][n];

void displayTheMap() {
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      noStroke();
      fill(IDNumberColourRGB.get(terrain[i][j]));
      square(j * 800.0/n, 0, 800.0/n);
    }
    translate(0, 800.0/n);
  }

  translate(0, -800);
}

void generateTerrain() {
  float detail = map(10, 0, width, 0.1, 0.6);
  noiseDetail(8, detail);

  float rowOff = 0.0;
  for (int i=0; i<n; i++) {
    rowOff += NOISE_INCREMENT;
    float colOff = 0.0;
    for (int j=0; j<n; j++) {
      colOff += NOISE_INCREMENT;

      float value = noise(rowOff, colOff)*255;
      if (0 < value && value < 80) {
        terrain[i][j] = 2;
      } else
        terrain[i][j] = 3;
    }
  }

  for (int i=0; i<n; i++) {
    rowOff += NOISE_INCREMENT;
    float colOff = 0.0;
    for (int j=0; j<n; j++) {
      colOff += NOISE_INCREMENT;

      float value = noise(rowOff, colOff)*255;
      if (0 < value && value < 70) {
        terrain[i][j] = 0;
      }
    }
  }
}

void StartBuildingCities() {
  int c = 0;

  while (c != numOfCities) {
    int i = int(random(0, n));
    int j = int(random(0, n));

    if (IDNumberBiomeType.get(terrain[i][j]) == "Desert") {
      terrain[i][j] = 4;
      c++;
    }
  }
}

void CitiesExpanding() {
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
    outerloop:
      if (IDNumberBiomeType.get(terrain[i][j]) == "City") {
        int r = int(random(0, 10 + millis() / 5000));
        if (r != 0) continue;
        for (int x = -1; x < 2; x++) {
          for (int y = -1; y < 2; y++) {
            if (x != 0 || y != 0) {
              try {
                int a = int(random(0, 2));
                if (a != 0) continue;
                if (IDNumberBiomeType.get(terrain[i + x][j + y]) == "Desert") { 
                  terrain[i + x][j + y] = 4;
                  break outerloop;
                }
                int s = int(random(0, 100/(100-deforestationAwarenessRate+1)));
                if (s != 0) continue;
                if (IDNumberBiomeType.get(terrain[i + x][j + y]) == "Forest") { 
                  terrain[i + x][j + y] = 3;
                  break outerloop;
                }
              }
              catch(Exception e) {
              }
            }
          }
        }
      }
    }
  }
}

void CitiesPollutingWater() {
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
    outerloop:
      if (IDNumberBiomeType.get(terrain[i][j]) == "City") {
        for (int x = -1; x < 2; x++) {
          for (int y = -1; y < 2; y++) {
            if (x != 0 || y != 0) {
              try {
                int s = int(random(0, 1000));
                if (s != 0) continue;
                if (IDNumberBiomeType.get(terrain[i + x][j + y]) == "Water") { 
                  terrain[i + x][j + y] = 1;
                  break outerloop;
                }
              }
              catch(Exception e) {
              }
            }
          }
        }
      } else if (IDNumberBiomeType.get(terrain[i][j]) == "Contaminated Water") {
        for (int x = -1; x < 2; x++) {
          for (int y = -1; y < 2; y++) {
            if (x != 0 || y != 0) {
              try {
                int s = int(random(0, 100/(100-waterPollutionAwarernessRate+1)));
                if (s != 0) continue;
                int t = int(random(0, 40));
                if (t != 0) continue;
                if (IDNumberBiomeType.get(terrain[i + x][j + y]) == "Water") { 
                  terrain[i + x][j + y] = 1;
                  break outerloop;
                }
              }
              catch(Exception e) {
              }
            }
          }
        }
      } else if (IDNumberBiomeType.get(terrain[i][j]) == "Forest") {
        for (int x = -1; x < 2; x++) {
          for (int y = -1; y < 2; y++) {
            if (x != 0 || y != 0) {
              try {
                int t = int(random(0, 1000));
                if (t != 0) continue;
                if (IDNumberBiomeType.get(terrain[i + x][j + y]) == "Contaminated Water") { 
                  terrain[i][j] = 3;
                  break outerloop;
                }
              }
              catch(Exception e) {
              }
            }
          }
        }
      }
    }
  }
}

void scrubNext() {  
  airNext = new color[n][n];
  xSpeedsNext = new int[n][n];
  ySpeedsNext = new int[n][n];
}


void setNextGeneration() {
  scrubNext(); 

  for (int i=0; i<n; i++) {
    for (int j=0; j<n; j++) {

      int sx = xSpeeds[i][j];
      int sy = ySpeeds[i][j];

      if (air[i][j] == 1) {
        try {
          int iNext = i + sx;
          int jNext = j + sy;

          if (airNext[iNext][jNext] == 0) {
            airNext[iNext][jNext] = 1; 
            xSpeedsNext[iNext][jNext] = sx;
            ySpeedsNext[iNext][jNext] = sy;
          } else {
            airNext[i][j] = air[i][j]; 
            xSpeedsNext[i][j] = sx;
            ySpeedsNext[i][j] = sy;
          }
        }

        catch( Exception e) {
          airNext[i][j] = 1;
          if (i < 10 ||  (n - 10) < i)
            xSpeedsNext[i][j] = -sx;
          else
            xSpeedsNext[i][j] = sx;
          if (j < 10 ||  (n - 10) < j)
            ySpeedsNext[i][j] = -sy;
          else
            ySpeedsNext[i][j] = sy;
        }
      }

      if ( airNext[i][j] != 1 ) {
        airNext[i][j] = 0; 
        xSpeedsNext[i][j] = 0; 
        ySpeedsNext[i][j] = 0;
      }
    }
  }
}

void copyNextGenerationToCurrentGeneration() {
  for (int i=0; i<n; i++) 
    for (int j=0; j<n; j++) {
      air[i][j] = airNext[i][j];
      xSpeeds[i][j] = xSpeedsNext[i][j];
      ySpeeds[i][j] = ySpeedsNext[i][j];
    }
}

void displayAirPollution() {
  setNextGeneration();
  copyNextGenerationToCurrentGeneration();

  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      if (air[i][j] == 1) {
        noStroke();
        fill(100, 100, 100, 100);
        square(j * 800.0/n, 0, 800.0/n);
      }
    }
    translate(0, 800.0/n);
  }
  translate(0, -800);
}

void CitiesPollutingTheAir() {
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      if (IDNumberBiomeType.get(terrain[i][j]) == "City") {
        int c = int(random(0, 2));
        if (c != 0) continue;
        int r = int(random(0, 100/(100-airPollutionAwarenessRate+1) + millis() / 1000));
        if (r != 0) continue;
        if (air[i][j] == 0) {
          air[i][j] = 1;
          xSpeeds[i][j] = int(random(-10, 10));
          ySpeeds[i][j] = int(random(-10, 10));

          while (xSpeeds[i][j] == 0 && ySpeeds[i][j] == 0) {
            xSpeeds[i][j] = int(random(-10, 10));
            ySpeeds[i][j] = int(random(-10, 10));
          }
        }
      }
    }
  }
}

void ForestsAndAlgaeCleaningTheAir() {
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
      if (air[i][j] == 1 && (IDNumberBiomeType.get(terrain[i][j]) == "Forest" || IDNumberBiomeType.get(terrain[i][j]) == "Water")) {
        int r = int(random(0, 2));
        if (r != 0) continue;
        air[i][j] = 0;
        xSpeeds[i][j] = 0;
        ySpeeds[i][j] = 0;
      }
    }
  }
}

void NatureHealingItselfSlowly() {
  for (int i = 0; i < n; i++) {
    for (int j = 0; j < n; j++) {
    outerloop:
      if (IDNumberBiomeType.get(terrain[i][j]) == "Water") {
        for (int x = -1; x < 2; x++) {
          for (int y = -1; y < 2; y++) {
            if (x != 0 || y != 0) {
              try {
                int s = int(random(0, 5000));
                if (s != 0) continue;
                if (IDNumberBiomeType.get(terrain[i + x][j + y]) == "Contaminated Water") { 
                  terrain[i + x][j + y] = 0;
                  break outerloop;
                }
              }
              catch(Exception e) {
              }
            }
          }
        }
      } else if (IDNumberBiomeType.get(terrain[i][j]) == "Forest") {
        for (int x = -1; x < 2; x++) {
          for (int y = -1; y < 2; y++) {
            if (x != 0 || y != 0) {
              try {
                int s = int(random(0, 5000));
                if (s != 0) continue;
                if (IDNumberBiomeType.get(terrain[i + x][j + y]) == "Desert") { 
                  terrain[i + x][j + y] = 2;
                  break outerloop;
                }
              }
              catch(Exception e) {
              }
            }
          }
        }
      }
    }
  }
}

void setup() {
  IDNumberBiomeType.put(0, "Water");
  IDNumberBiomeType.put(1, "Contaminated Water");
  IDNumberBiomeType.put(2, "Forest");
  IDNumberBiomeType.put(3, "Desert");
  IDNumberBiomeType.put(4, "City");

  IDNumberColourRGB.put(0, #00BFFF);
  IDNumberColourRGB.put(1, #1b1834);
  IDNumberColourRGB.put(2, #228B22);
  IDNumberColourRGB.put(3, #f2ffcc);
  IDNumberColourRGB.put(4, #FFD700);

  size(800, 800);

  frameRate(blinksPerSecond);

  generateTerrain();
  StartBuildingCities();
}

void draw() {
  background(0);
  displayTheMap();
  CitiesExpanding();
  CitiesPollutingWater();
  CitiesPollutingTheAir();
  ForestsAndAlgaeCleaningTheAir();
  NatureHealingItselfSlowly();
  displayAirPollution();
}
