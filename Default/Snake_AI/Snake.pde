class Snake {
   
  int score = 1;
  int moveLeft = 200;  //jumlah gerakan sebelum snake tewas
  int lifetime = 0;  //jumlah waktu snake hidup
  int xVel, yVel;
  int foodItterate = 0;  //itterator untuk run through foodlist (untuk replay)
  
  float fitness = 0;
  
  boolean dead = false;
  boolean replay = false;  //jika snake adalah snake terbaik dlm generasi, akan di replay
  
  float[] vision;  //snakes vision
  float[] decision;  //snakes decision
  
  PVector head;
  
  ArrayList<PVector> body;  //snakes body
  ArrayList<Food> foodList;  //daftar posisi makanan (untuk replay best snake)
  
  Food food;
  NeuralNet brain;
  
  Snake() {
    this(hidden_layers);
  }
  
  Snake(int layers) {
    head = new PVector(800,height/2);
    food = new Food();
    body = new ArrayList<PVector>();
    vision = new float[24];
    decision = new float[4];
    foodList = new ArrayList<Food>();
    foodList.add(food.clone());
    brain = new NeuralNet(24,hidden_nodes,4,layers);
    body.add(new PVector(800,(height/2)+SIZE));  
    body.add(new PVector(800,(height/2)+(2*SIZE)));
    score+=2;      
  }
  
  Snake(ArrayList<Food> foods) {  //constructor untuk daftar makanan agar best snake dapat di replay
     replay = true;
     vision = new float[24];
     decision = new float[4];
     body = new ArrayList<PVector>();
     foodList = new ArrayList<Food>(foods.size());
     for(Food f: foods) {  //clone semua posisi makanan
       foodList.add(f.clone());
     }
     food = foodList.get(foodItterate);
     foodItterate++;
     head = new PVector(800,height/2);
     body.add(new PVector(800,(height/2)+SIZE));
     body.add(new PVector(800,(height/2)+(2*SIZE)));
     score+=2;
  }
  
  boolean bodyCollide(float x, float y) {  //cek posisi menabrak tubuh
     for(int i = 0; i < body.size(); i++) {
        if(x == body.get(i).x && y == body.get(i).y)  {
           return true;
        }
     }
     return false;
  }
  
  boolean foodCollide(float x, float y) {  //cek poisisi menabrak (memakan) makanan
     if(x == food.pos.x && y == food.pos.y) {
         return true;
     }
     return false;
  }
  
  boolean wallCollide(float x, float y) {  //cek posisi menabrak tembok
     if(x >= width-(SIZE) || x < 400 + SIZE || y >= height-(SIZE) || y < SIZE) {
       return true;
     }
     return false;
  }
  
  void show() {  //menunjukkan snake
     food.show();
     fill(240, 246, 240);
     stroke(0);
     for(int i = 0; i < body.size(); i++) {
       rect(body.get(i).x,body.get(i).y,SIZE,SIZE);
     }
     if(dead) {
       fill(150);
     } else {
       fill(240, 246, 240);
     }
     rect(head.x,head.y,SIZE,SIZE);
  }
  
  void move() {  //move the snake
     if(!dead){
       if(!modelLoaded) {
         lifetime++;
         moveLeft--;
       }
       if(foodCollide(head.x,head.y)) {
          eat();
       }
       shiftBody();
       if(wallCollide(head.x,head.y)) {
         dead = true;
       } else if(bodyCollide(head.x,head.y)) {
         dead = true;
       } else if(moveLeft <= 0) {
         dead = true;
       }
     }
  }
  
  void eat() {  //eat food
    int len = body.size()-1;
    score++;
    if(!modelLoaded) {
      if(moveLeft < 400) {
        if(moveLeft > 300) {
           moveLeft = 400; 
        } else {
          moveLeft += 100;
        }
      }
    }
    body.add(new PVector(body.get(len).x,body.get(len).y));
    if(!replay) {
      food = new Food();
      while(bodyCollide(food.pos.x,food.pos.y)) {
         food = new Food();
      }
      foodList.add(food);
    } else {  //mendapatkan daftar makanan untuk replay
      food = foodList.get(foodItterate);
      foodItterate++;
    }
  }
  
  void shiftBody() {  //geser badan mengikuti kepala
    float tempx = head.x;
    float tempy = head.y;
    head.x += xVel;
    head.y += yVel;
    float temp2x;
    float temp2y;
    for(int i = 0; i < body.size(); i++) {
       temp2x = body.get(i).x;
       temp2y = body.get(i).y;
       body.get(i).x = tempx;
       body.get(i).y = tempy;
       tempx = temp2x;
       tempy = temp2y;
    } 
  }
  
  Snake cloneForReplay() {  //clone snake untuk replay
     Snake clone = new Snake(foodList);
     clone.brain = brain.clone();
     return clone;
  }
  
  Snake clone() {  //clone snake
     Snake clone = new Snake(hidden_layers);
     clone.brain = brain.clone();
     return clone;
  }
  
  Snake crossover(Snake parent) {  //crossover
     Snake child = new Snake(hidden_layers);
     child.brain = brain.crossover(parent.brain);
     return child;
  }
  
  void mutate() {  //mutasi
     brain.mutate(mutationRate); 
  }
  
  void calculateFitness() {  //perhitungan fitness score
     if(score < 10) {
        fitness = floor(lifetime) * pow(2,score);
     } else {
        fitness = floor(lifetime);
        fitness *= pow(2,10);
        fitness *= (score-9);
     }
  }
  
  void look() {  //melihat 8 arah dan cek untuk makanan, badan, dan tembok
    vision = new float[24];
    float[] temp = lookInDirection(new PVector(-SIZE,0));
    vision[0] = temp[0];
    vision[1] = temp[1];
    vision[2] = temp[2];
    temp = lookInDirection(new PVector(-SIZE,-SIZE));
    vision[3] = temp[0];
    vision[4] = temp[1];
    vision[5] = temp[2];
    temp = lookInDirection(new PVector(0,-SIZE));
    vision[6] = temp[0];
    vision[7] = temp[1];
    vision[8] = temp[2];
    temp = lookInDirection(new PVector(SIZE,-SIZE));
    vision[9] = temp[0];
    vision[10] = temp[1];
    vision[11] = temp[2];
    temp = lookInDirection(new PVector(SIZE,0));
    vision[12] = temp[0];
    vision[13] = temp[1];
    vision[14] = temp[2];
    temp = lookInDirection(new PVector(SIZE,SIZE));
    vision[15] = temp[0];
    vision[16] = temp[1];
    vision[17] = temp[2];
    temp = lookInDirection(new PVector(0,SIZE));
    vision[18] = temp[0];
    vision[19] = temp[1];
    vision[20] = temp[2];
    temp = lookInDirection(new PVector(-SIZE,SIZE));
    vision[21] = temp[0];
    vision[22] = temp[1];
    vision[23] = temp[2];
  }
  
  float[] lookInDirection(PVector direction) {  //function melihat sebuah arah, dipakai di fuction atas
    float look[] = new float[3];
    PVector pos = new PVector(head.x,  head.y);
    float distance = 0;
    boolean foodFound = false;
    boolean bodyFound = false;
    pos.add(direction);
    distance +=1;
    while (!wallCollide(pos.x,pos.y)) {
      if(!foodFound && foodCollide(pos.x,pos.y)) {
        foodFound = true;
        look[0] = 1;
      }
      if(!bodyFound && bodyCollide(pos.x,pos.y)) {
         bodyFound = true;
         look[1] = 1;
      }
      pos.add(direction);
      distance +=1;
    }
    look[2] = 1/distance;
    return look;
  }
  
  void think() {  //pilih gerakan
      decision = brain.output(vision);
      int maxIndex = 0;
      float max = 0;
      for(int i = 0; i < decision.length; i++) {
        if(decision[i] > max) {
          max = decision[i];
          maxIndex = i;
        }
      }
      
      switch(maxIndex) {
         case 0:
           moveUp();
           break;
         case 1:
           moveDown();
           break;
         case 2:
           moveLeft();
           break;
         case 3: 
           moveRight();
           break;
      }
  }
  
  void moveUp() { 
    if(yVel!=SIZE) {
      xVel = 0; yVel = -SIZE;
    }
  }
  void moveDown() { 
    if(yVel!=-SIZE) {
      xVel = 0; yVel = SIZE; 
    }
  }
  void moveLeft() { 
    if(xVel!=SIZE) {
      xVel = -SIZE; yVel = 0; 
    }
  }
  void moveRight() { 
    if(xVel!=-SIZE) {
      xVel = SIZE; yVel = 0;
    }
  }
}
