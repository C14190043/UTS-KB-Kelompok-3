final int SIZE = 20;
final int hidden_nodes = 16;
final int hidden_layers = 1;
final int fps = 100; //mengubah fps

int highscore = 0;

float mutationRate = 0.1; //mengubah kemungkinan mutasi

boolean replayBest = true;  //hanya memperlihatkan snake yang terbaik dalam setiap generasi
boolean modelLoaded = false;

PFont font;

ArrayList<Integer> evolution;

Snake model;

Population pop;

public void settings() {
  size(1200,800);
}

void setup() {
  font = createFont("VCR_OSD_MONO_1.001.ttf",32);
  evolution = new ArrayList<Integer>();
  frameRate(fps);
  pop = new Population(4000); //ganti jumlah populasi
}

void draw() {
  background(34, 35, 35);
  noFill();
  stroke(240, 246, 240);
  line(400,0,400,height);
  rectMode(CORNER);
  rect(400 + SIZE,SIZE,width-400-40,height-40);
  textFont(font);
  if(!modelLoaded) {
    if(pop.done()) {
        highscore = pop.bestSnake.score;
        pop.calculateFitness();
        pop.naturalSelection();
    } else {
        pop.update();
        pop.show(); 
    }
    fill(240, 246, 240);
    textSize(20);
    textAlign(LEFT);
    text("GEN : "+pop.gen,40,50);
    text("MOVES LEFT : "+pop.bestSnake.moveLeft,40,80);
    text("BEST FITNESS : "+pop.bestFitness,40,110);
    text("MUTATION RATE : "+mutationRate*100+"%",40,140);
    text("SCORE : "+pop.bestSnake.score,120,height-45);
    text("HIGHSCORE : "+highscore,120,height-15);
  } else {
    model.look();
    model.think();
    model.move();
    model.show();
    if(model.dead) {
      Snake newmodel = new Snake();
      newmodel.brain = model.brain.clone();
      model = newmodel;
    }
    textSize(20);
    fill(240, 246, 240);
    textAlign(LEFT);
    text("SCORE : "+model.score,120,height-45);
  }
}
