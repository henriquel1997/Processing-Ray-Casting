int[][] map = {
{1,1,1,1,0,0,0,1,1,1,1},
{1,0,0,0,0,0,0,1,0,0,1},
{1,0,0,0,0,0,1,1,0,0,1},
{1,0,0,0,0,0,0,0,0,1,1},
{1,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,1},
{1,1,1,1,1,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,1},
{1,0,0,0,0,0,0,0,0,0,1},
{1,1,1,1,1,1,1,1,1,1,1}};
int mapSquareSize = 20;
int mapWindowSize = mapSquareSize*map.length;
                
float locationX = 5.5;
float locationY = 5.5;
float fov = 20;
float cameraAngle = 108;
float[] raysX;
float[] raysY;
float maxDis = map.length;

color colorPosition = color(178, 34, 34);
color colorWall = color(0, 0, 0);
color colorFloor = color(255, 255, 255);
color colorRay = color(255,255,0);
color colorSky = color(135,206,235);

void draw() {
  clear();
  rayCastingVision();
  drawMap(width - mapWindowSize, height - mapWindowSize);
  cameraAngle+=1;
  if(cameraAngle >= 360){
    cameraAngle = 0;
  }
}

void setup() {
  //size(800, 450);
  fullScreen();
  raysX = new float[width];
  raysY = new float[width];
}

void rayCastingVision(){
  //Desenha o ceu e o chão
  noStroke();
  fill(colorSky);
  rect(0, 0, width, height/2);
  fill(colorFloor);
  rect(0, height/2, width, height/2);
  
  //Define a posição das paredes com Ray Tracing
  for(int i = 0; i < width; i++){
    float x = locationX;
    float y = locationY;
    float angle = cameraAngle + fov * (((float) i + 0.5)/width) - fov/2;
    if(angle >= 360){
      angle -= 360;
    }
    if(angle < 0){
      angle += 360;
    } //<>// //<>//
    float dirX = cos(radians(angle));
    float dirY = sin(radians(angle));
    
    while(!isWall(x, y)){
      
      int squareX = floor(x);
      int squareY = floor(y);
      
      if(x == squareX && angle > 90 && angle < 270){
        squareX -= 1;
      }
      
      if(y == squareY && angle > 180){
        squareY -= 1;
      }
      
      if(isWall(squareX, squareY)){
        break;
      }
      
      float[] newPos = intersecaoQuadrado(x, y, dirX, dirY, squareX, squareY);
      
      if(newPos != null && newPos.length >= 2){
        x = newPos[0];
        y = newPos[1];
      }
    }
    
    raysX[i] = x;
    raysY[i] = y;
    
    //Desenha a parede
    stroke(1);
    float distance = (pow(locationX - x, 2) + pow(locationY - y, 2));
    float wallHeight = height * (1 - distance/pow(maxDis, 2));
    float difTam = height - wallHeight;
    color(colorWall);
    line(i, difTam/2, i, height - difTam);
  }
}

enum Direction{
  UP, DOWN, LEFT, RIGHT, NONE
} //<>//

float[] intersecaoQuadrado(//Ponto dentro do Quadrado
                        float posX, float posY, 
                        //Vetor indicando a direção
                        float dirX, float dirY, 
                        //Dois pontos do quadrado
                        int minX, int minY){
         
  int maxX = minX + 1;
  int maxY = minY + 1;
  
  //Verifica se o ponto está dentro do quadrado
  if((posX < minX) || (posX > maxX) || (posY < minY) || (posY > maxY)){
     return null; 
  }
  
  //Verifica se o vetor não é zero
  if(dirX*dirX + dirY*dirY == 0){
    return null;
  }
  
  Direction xIntersec = Direction.NONE;
  Direction yIntersec = Direction.NONE;
  float distX = 0;
  float distY = 0;
  
  if(dirX > 0){
    xIntersec = Direction.RIGHT;
    distX = (maxX - posX)/dirX;
  }else if(dirX < 0){
    xIntersec = Direction.LEFT;
    distX = (minX - posX)/dirX;
  }
  
  if(dirY > 0){
    yIntersec = Direction.UP;
    distY = (maxY - posY)/dirY;
  }else if(dirY < 0){
    yIntersec = Direction.DOWN;
    distY = (minY - posY)/dirY;
  }
  
  if(xIntersec == Direction.NONE && yIntersec == Direction.NONE){
    return null;
  }
  
  if(xIntersec == Direction.NONE){
    float x = posX + distY*dirX;
    float y = posY + distY*dirY;
    return new float[]{x, y};
  }else if(yIntersec == Direction.NONE){
    float x = posX + distX*dirX;
    float y = posY + distY*dirY;
    return new float[]{x, y};
  }
  
  if(distY < distX){
    float x = posX + distY*dirX;
    float y = posY + distY*dirY;
    return new float[]{x, y};
  } 
  
  float x = posX + distX*dirX;
  float y = posY + distX*dirY;
  return new float[]{x, y};
}

boolean isWall(float x, float y){
  int intX = floor(x);
  int intY = floor(y);
  return intX < 0 || intY < 0 || intX > map.length || intY > map[0].length || map[intY][intX] == 1;
}

void drawMap(int posX, int posY){
  //Desenha o mapa
  stroke(4);
  for(int x = 0; x < map.length; x++){
    for(int y = 0; y < map[x].length; y++){
      color cor = colorFloor;
      switch(map[y][x]){
        case 1:
          cor = colorWall;
          break;
      }
      
      fill(cor);
      rect(coordConv(x, posX), coordConv(y, posY), mapSquareSize, mapSquareSize);
    }
  }
  
  //Desenha os Raios
  if(raysX.length == raysY.length && raysX.length > 1){
    fill(colorRay);
    noStroke();
    float x = coordConv(locationX, posX);
    float y = coordConv(locationY, posY);
    for(int i = 1; i < raysX.length; i++){
        triangle(x, y,
                 coordConv(raysX[i-1], posX), 
                 coordConv(raysY[i-1], posY), 
                 coordConv(raysX[i], posX), 
                 coordConv(raysY[i], posY));
    }
  }
  
  //Desenha a posição
  stroke(4);
  fill(colorPosition);
  ellipse(coordConv(locationX, posX), 
          coordConv(locationY, posY), 
          mapSquareSize, 
          mapSquareSize);
}

float coordConv(float f){
    return coordConv(f, 0);
}

float coordConv(float f, float offset){
    return f*mapSquareSize + offset;
}
