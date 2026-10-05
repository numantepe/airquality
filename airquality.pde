// Biome types
final int WATER = 0;
final int CONTAMINATED_WATER = 1;
final int FOREST = 2;
final int DESERT = 3;
final int CITY = 4;

// Indexed by biome type
color[] biomeColour = { #00BFFF, #1b1834, #228B22, #f2ffcc, #FFD700 };
final color SMOG_COLOUR = 0x64646464; // Grey (100, 100, 100) with an alpha of 100

// You can change these variables
int n = 200;
float blinksPerSecond = 60; // Recommended Range: 10-100
int numOfCities = 10; // Initially you will have numOfCities different cities, however those cities may merge together as time goes on.
int deforestationAwarenessRate = 100; // 100 being 100%, 60 being 60%, Range: 0-100
int waterPollutionAwarenessRate = 100; // 100 being 100%, 60 being 60%, Range: 0-100
int airPollutionAwarenessRate = 100; // 100 being 100%, 60 being 60%, Range: 0-100

int[][] terrain = new int[n][n];
int[][] terrainNext = new int[n][n];
float NOISE_INCREMENT = 0.05*(200/float(n));
int[][] air = new int[n][n];
int[][] xSpeeds = new int[n][n];
int[][] ySpeeds = new int[n][n];
int[][] airNext = new int[n][n];
int[][] xSpeedsNext = new int[n][n];
int[][] ySpeedsNext = new int[n][n];

PImage terrainImage;
PImage smogImage;

boolean inBounds(int i, int j)
{
  return 0 <= i && i < n && 0 <= j && j < n;
}

boolean chance(float probability)
{
  return random(1) < probability;
}

// 100% awareness gives a 1% chance of harm, 0% awareness gives a 100% chance
float harmChance(int awarenessRate)
{
  return (101 - awarenessRate) / 100.0;
}

// Based on frames rather than the clock, so the simulation runs the same on slow and fast computers
float secondsElapsed()
{
  return frameCount / blinksPerSecond;
}

void displayTheMap()
{
  terrainImage.loadPixels();
  for (int i = 0; i < n; i++)
  {
    for (int j = 0; j < n; j++)
    {
      terrainImage.pixels[i * n + j] = biomeColour[terrain[i][j]];
    }
  }
  terrainImage.updatePixels();
  image(terrainImage, 0, 0, width, height);
}

void generateTerrain()
{
  float detail = map(10, 0, width, 0.1, 0.6);
  noiseDetail(8, detail);

  float rowOff = 0.0;
  for (int i=0; i<n; i++)
  {
    rowOff += NOISE_INCREMENT;
    float colOff = 0.0;
    for (int j=0; j<n; j++)
    {
      colOff += NOISE_INCREMENT;

      float value = noise(rowOff, colOff)*255;
      if (0 < value && value < 80)
      {
        terrain[i][j] = FOREST;
      }
      else
        terrain[i][j] = DESERT;
    }
  }

  for (int i=0; i<n; i++)
  {
    rowOff += NOISE_INCREMENT;
    float colOff = 0.0;
    for (int j=0; j<n; j++)
    {
      colOff += NOISE_INCREMENT;

      float value = noise(rowOff, colOff)*255;
      if (0 < value && value < 70)
      {
        terrain[i][j] = WATER;
      }
    }
  }
}

void startBuildingCities()
{
  IntList deserts = new IntList();
  for (int i = 0; i < n; i++)
  {
    for (int j = 0; j < n; j++)
    {
      if (terrain[i][j] == DESERT)
      {
        deserts.append(i * n + j);
      }
    }
  }

  // If the map has fewer deserts than numOfCities, build as many cities as fit
  deserts.shuffle();
  int cities = min(numOfCities, deserts.size());
  for (int c = 0; c < cities; c++)
  {
    int cell = deserts.get(c);
    terrain[cell / n][cell % n] = CITY;
  }
}

// Turns the first neighbour of type `from` that passes the chance into `to`
void convertOneNeighbour(int i, int j, int from, int to, float probability)
{
  for (int x = -1; x < 2; x++)
  {
    for (int y = -1; y < 2; y++)
    {
      if ((x == 0 && y == 0) || !inBounds(i + x, j + y)) continue;
      if (terrain[i + x][j + y] == from && chance(probability))
      {
        terrainNext[i + x][j + y] = to;
        return;
      }
    }
  }
}

// True if any neighbour of the given type passes the chance
boolean neighbourTriggers(int i, int j, int biome, float probability)
{
  for (int x = -1; x < 2; x++)
  {
    for (int y = -1; y < 2; y++)
    {
      if ((x == 0 && y == 0) || !inBounds(i + x, j + y)) continue;
      if (terrain[i + x][j + y] == biome && chance(probability))
      {
        return true;
      }
    }
  }
  return false;
}

// A city changes at most one neighbouring cell per frame
void cityExpandsOnce(int i, int j)
{
  for (int x = -1; x < 2; x++)
  {
    for (int y = -1; y < 2; y++)
    {
      if ((x == 0 && y == 0) || !inBounds(i + x, j + y)) continue;
      if (!chance(0.5)) continue;

      int neighbour = terrain[i + x][j + y];
      if (neighbour == DESERT)
      {
        terrainNext[i + x][j + y] = CITY;
        return;
      }
      if (neighbour == FOREST && chance(harmChance(deforestationAwarenessRate)))
      {
        terrainNext[i + x][j + y] = DESERT;
        return;
      }
    }
  }
}

void citiesExpanding()
{
  // Cities grow more slowly as time goes on
  float activeChance = 1 / (10 + secondsElapsed() / 5);

  for (int i = 0; i < n; i++)
  {
    for (int j = 0; j < n; j++)
    {
      if (terrain[i][j] == CITY && chance(activeChance))
      {
        cityExpandsOnce(i, j);
      }
    }
  }
}

void citiesPollutingWater()
{
  float spreadChance = harmChance(waterPollutionAwarenessRate) / 40;

  for (int i = 0; i < n; i++)
  {
    for (int j = 0; j < n; j++)
    {
      if (terrain[i][j] == CITY)
      {
        convertOneNeighbour(i, j, WATER, CONTAMINATED_WATER, 0.001);
      }
      else if (terrain[i][j] == CONTAMINATED_WATER)
      {
        convertOneNeighbour(i, j, WATER, CONTAMINATED_WATER, spreadChance);
      }
      else if (terrain[i][j] == FOREST && neighbourTriggers(i, j, CONTAMINATED_WATER, 0.001))
      {
        terrainNext[i][j] = DESERT;
      }
    }
  }
}

void natureHealingItselfSlowly()
{
  for (int i = 0; i < n; i++)
  {
    for (int j = 0; j < n; j++)
    {
      if (terrain[i][j] == WATER)
      {
        convertOneNeighbour(i, j, CONTAMINATED_WATER, WATER, 1 / 5000.0);
      }
      else if (terrain[i][j] == FOREST)
      {
        convertOneNeighbour(i, j, DESERT, FOREST, 1 / 5000.0);
      }
    }
  }
}

// Every rule reads this frame's terrain and writes to terrainNext, so a change
// made in this frame can't trigger more changes until the next frame
void updateTerrain()
{
  for (int i = 0; i < n; i++)
  {
    arrayCopy(terrain[i], terrainNext[i]);
  }

  citiesExpanding();
  citiesPollutingWater();
  natureHealingItselfSlowly();

  int[][] swap = terrain;
  terrain = terrainNext;
  terrainNext = swap;
}

boolean trySetSmog(int i, int j, int sx, int sy)
{
  if (airNext[i][j] != 0) return false;
  airNext[i][j] = 1;
  xSpeedsNext[i][j] = sx;
  ySpeedsNext[i][j] = sy;
  return true;
}

// Puts a smog particle in the next generation, or in a free cell next to it if that cell is taken
void placeSmog(int i, int j, int sx, int sy)
{
  if (trySetSmog(i, j, sx, sy)) return;
  for (int x = -1; x < 2; x++)
  {
    for (int y = -1; y < 2; y++)
    {
      if (inBounds(i + x, j + y) && trySetSmog(i + x, j + y, sx, sy)) return;
    }
  }
  // Every nearby cell is full, so this particle merges into the smog around it
}

void moveSmog()
{
  for (int i = 0; i < n; i++)
  {
    for (int j = 0; j < n; j++)
    {
      airNext[i][j] = 0;
      xSpeedsNext[i][j] = 0;
      ySpeedsNext[i][j] = 0;
    }
  }

  for (int i = 0; i < n; i++)
  {
    for (int j = 0; j < n; j++)
    {
      if (air[i][j] != 1) continue;

      int sx = xSpeeds[i][j];
      int sy = ySpeeds[i][j];
      int iNext = i + sx;
      int jNext = j + sy;

      if (!inBounds(iNext, jNext))
      {
        // Bounce off the edge of the map and stay in place for this frame
        if (iNext < 0 || iNext >= n) sx = -sx;
        if (jNext < 0 || jNext >= n) sy = -sy;
        placeSmog(i, j, sx, sy);
      }
      else if (airNext[iNext][jNext] == 0)
      {
        placeSmog(iNext, jNext, sx, sy);
      }
      else
      {
        // The cell ahead is taken, so wait in place
        placeSmog(i, j, sx, sy);
      }
    }
  }

  int[][] swap = air;
  air = airNext;
  airNext = swap;
  swap = xSpeeds;
  xSpeeds = xSpeedsNext;
  xSpeedsNext = swap;
  swap = ySpeeds;
  ySpeeds = ySpeedsNext;
  ySpeedsNext = swap;
}

void displayAirPollution()
{
  moveSmog();

  smogImage.loadPixels();
  for (int i = 0; i < n; i++)
  {
    for (int j = 0; j < n; j++)
    {
      smogImage.pixels[i * n + j] = (air[i][j] == 1) ? SMOG_COLOUR : 0;
    }
  }
  smogImage.updatePixels();
  image(smogImage, 0, 0, width, height);
}

void citiesPollutingTheAir()
{
  // Less smog with more awareness, and less as time goes on
  float smogChance = 0.5 / (1 / harmChance(airPollutionAwarenessRate) + secondsElapsed());

  for (int i = 0; i < n; i++)
  {
    for (int j = 0; j < n; j++)
    {
      if (terrain[i][j] == CITY && air[i][j] == 0 && chance(smogChance))
      {
        air[i][j] = 1;
        do
        {
          xSpeeds[i][j] = int(random(-10, 10));
          ySpeeds[i][j] = int(random(-10, 10));
        }
        while (xSpeeds[i][j] == 0 && ySpeeds[i][j] == 0);
      }
    }
  }
}

void forestsAndAlgaeCleaningTheAir()
{
  for (int i = 0; i < n; i++)
  {
    for (int j = 0; j < n; j++)
    {
      boolean cleaner = terrain[i][j] == FOREST || terrain[i][j] == WATER;
      if (air[i][j] == 1 && cleaner && chance(0.5))
      {
        air[i][j] = 0;
        xSpeeds[i][j] = 0;
        ySpeeds[i][j] = 0;
      }
    }
  }
}

void setup()
{
  size(800, 800);
  noSmooth(); // Keeps cells as sharp squares when the map is scaled up

  frameRate(blinksPerSecond);

  terrainImage = createImage(n, n, RGB);
  smogImage = createImage(n, n, ARGB);

  generateTerrain();
  startBuildingCities();
}

void draw()
{
  displayTheMap();
  updateTerrain();
  citiesPollutingTheAir();
  forestsAndAlgaeCleaningTheAir();
  displayAirPollution();
}
