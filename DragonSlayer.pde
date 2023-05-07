//--------->Andrea Del Corto_Gabriele Giovannelli_3IA<---------
//Librerie aggiuntive per gestione suoni
import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

import gifAnimation.*;//libreria aggiuntiva per  gif animate
//------CANNONE------
float angolo;
float modifAngolo;//Modifica angolo.
int cannon_w, cannon_h, munizioni=6;//largezza altezza cannone.
Boolean shot=false;
PImage proiettile;
PImage canna;
PImage baseCan;
float proietX, proietY;
float angoloProiet;
float Vx, Vy;
float power=5;
Boolean powerMove=true;
float shotSpeed;
//------COLLISIONI------
Boolean collisione=false;
float explX, explY;
Gif explosion;
//------ENEMY------
Gif enemy;
float enemyX, enemyY;
float enemySpeed;
int enemyLife=3;
Boolean enemyDown=true;
PImage scudo;
float scudoX, scudoY, scudoSpeed=8;
Boolean scudoDown=true;
PImage scudo2;
float scudo2X, scudo2Y, scudoSpeed2=20;
Boolean scudoDown2=true;
//-----GENERALI-----
int allShot=0;
int goodShot=0;
int cont=0;
int punt=0;
int level=1;
int trasp=255;
color c = color(242, 142, 11);
PImage logo;
PImage sfondo;
PImage ground;
PImage puntBar;
PFont font;
//------MENU-----
float butStartX=10, butStartY=150;
float butMenuX=10, butMenuY=250;
Boolean win=true;
Boolean start=false;
PImage button;
PImage tabellone;
//---------SOUNDS---------
Minim minim, minim2, minim3, minim4;
AudioPlayer explosionSound, gameSong, shotCannon, menuSong;

void setup() {
  size(800, 600);
  sfondo = loadImage("./img/sfondo.gif");
  background(sfondo);
  frameRate(30);
  canna = loadImage("./img/canna.gif");
  baseCan = loadImage("./img/base.gif");
  cannon_w = canna.width;
  cannon_h = canna.height;
  angolo = 0;
  modifAngolo = 0.05;
  puntBar = loadImage("./img/puntBar.gif");
  font = createFont("./font/ALBA____.TTF", 25);
  textFont(font);
  proiettile = loadImage("./img/proiettile2.gif");
  ground = loadImage("./img/groundFiamme.gif");
  enemy = new Gif(this, "./img/drago.gif");
  explosion = new Gif(this, "./img/explosion.gif");
  logo = loadImage("./img/logo.gif");
  tabellone = loadImage("./img/tabellone.gif");
  minim = new Minim(this);
  explosionSound = minim.loadFile("./sounds/boom1.wav");

  minim2 = new Minim(this);
  gameSong = minim2.loadFile("./sounds/gameMusic.mp3");

  minim3 = new Minim(this);
  shotCannon = minim3.loadFile("./sounds/shotCannon.wav");

  minim4 = new Minim(this);
  menuSong = minim4.loadFile("./sounds/menuMusic.mp3");

  menuSong.play();
  menuSong.loop();
  enemy.play();
  scudo = loadImage("./img/scudo.gif");
  scudo2 = loadImage("./img/scudo2.gif");
  button = loadImage("./img/button.png");
  proietY=height-(cannon_h+ground.height+5);
  proietX=baseCan.width/2;
  enemyX = width-enemy.width;
  enemyY = puntBar.height;
  scudoX = enemyX-40;
  scudoY = enemyY+20;
  scudo2X = scudoX-(scudo.width+20);
  scudo2Y = scudoY;
  enemySpeed=2;
  fill(c);
  textSize(25);
}

void draw() {
  background(sfondo);
  if (start==false)menu();
  else {//Inizio gioco.
    if (win==true) {
      scudoMove();
      if (level>=3)scudo2Move();
      enemyMoveState();
      ambiente();
      pushMatrix();
      if (shot==true) {
        //proietX+=power;
        //proietY = (angoloProiet*proietX) + height-(ground.height+baseCan.height+8);
        println("power:" +power );
        proietX += Vx;
        proietY += Vy;
        image(proiettile, proietX, proietY);
      }
      popMatrix();
      pushMatrix();
      translate(15, height-(cannon_h/2+ground.height));   //In alto a sinistra per rotazione.
      rotate(angolo);                                     //Rotazione
      translate(-15, -(height-(cannon_h/2+ground.height)));//traslazione al punto originario.
      image(canna, 0, height-(cannon_h+ground.height+cannon_h/3), cannon_w, cannon_h);
      popMatrix();
      image(baseCan, 0, height-(ground.height + baseCan.height));
      collision();
      image(enemy, enemyX, enemyY);
      tint(255);
      if (enemyLife==0 && shot==false) {//Next Level
        trasp=255;//x visualizzazione livello.
        punt+=15;
        level++;
        enemySpeed+=0.5;
        scudoSpeed+=2.5;
        enemyLife=3;
        munizioni+=3;
      }
      if (munizioni==0 && shot==false )win=false;//End game
    } else {//sconfitta
      image(tabellone, 10, 10);
      fill(0);
      text("Hai raggiunto il livello "+  level + " !", 35, 90);
      text("Colpi a segno: " + goodShot, 35, 125);
      text("Colpi sparati: " + allShot, 35, 150);
      text("Punteggio: " + punt, 35, 175);
      fill(c);
      image(button, butMenuX, butMenuY);
      text("Menù", 50, butMenuY+30);
    }
  }
}
void scudoMove() {
  if (scudoY<height-(ground.height+scudo.height) && scudoDown==true) {
    scudoY+=scudoSpeed;
  } else {
    scudoDown=false;
    if (scudoY>puntBar.height && scudoDown==false) {
      scudoY-=scudoSpeed;
    } else scudoDown=true;
  }
  image(scudo, scudoX, scudoY);
}
void scudo2Move() {
  if (scudo2Y<height-(ground.height+scudo2.height) && scudoDown2==true) {
    scudo2Y+=scudoSpeed2;
  } else {
    scudoDown2=false;
    if (scudo2Y>puntBar.height && scudoDown2==false) {
      scudo2Y-=scudoSpeed2;
    } else scudoDown2=true;
  }
  image(scudo2, scudo2X, scudo2Y);
}
void menu() {
  background(sfondo);
  image(logo, width/2-logo.width/2, 5);
  image(button, 10, 150);
  text("Start", 50, 182);
}
void enemyMoveState() {
  fill(380-enemyLife*40, 0, 0);
  rect(enemyX, enemyY-15, enemyLife*40, 15);
  fill(c);
  if (enemyY<height-(ground.height+enemy.height) && enemyDown==true) {
    enemyY+=enemySpeed;
  } else {
    enemyDown=false;
    if (enemyY>puntBar.height && enemyDown==false) {
      enemyY-=enemySpeed;
    } else enemyDown=true;
  }
}
void ambiente() {
  image(puntBar, 8, 5);
  text("Livello: "+level, width/2-60, puntBar.height-10);
  text("Punteggio: " + punt, 40, puntBar.height-10);
  text("Munizioni: " + munizioni, width-200, puntBar.height-10);
  trasp-=5;
  fill(255, 255, 255, trasp);
  textSize(35);
  text("Level: " + level, width/2-30, height/2-10);
  textSize(25);
  image(ground, 0, height-ground.height);
  fill(0);
  //-----Power bar-----
  println("power: "+power);
  rect(20, height-15, 100, 15);//Static power bar
  fill(0, power*10, 0);
  rect(20, height-15, power*4, 15);//Dinamic power bar
  fill(c);
  textSize(15);
  text("POWER", 25, height-2);
  textSize(25);
  if (power<=25 && powerMove==true)power++;
  if (power>25)power=5;
  fill(c);
}
void collision() {
  if (cont<30 && collisione==true)cont++;
  else {
    cont=0;
    collisione=false;
    explosion.stop();
    explosionSound.rewind();
  }
  if (proietY<=puntBar.height || proietX>=width-(proiettile.width) || ((proietX>=scudoX && proietX<=scudoX+scudo.width) && (proietY>=scudoY && proietY<=scudoY+scudo.height)) || proietY>=height-(ground.height+proiettile.height) || ((proietX>=scudo2X && proietX<=scudo2X+scudo2.width) && (proietY>=scudo2Y && proietY<=scudo2Y+scudo2.height) && level>=3)) {//Collisione ambiente
    println("collisione ambiente");
    shot=false;
    collisione=true;
    explosionSound.play();
    explosion.play();
    explX = proietX-(explosion.width/2);
    explY = proietY-(explosion.height/2);
    proietX=baseCan.width/2;
    proietY=height-(cannon_h+ground.height+5);
    power=5;
  } else {
    if (proietX>=enemyX+enemy.width/3 && (proietY>enemyY && proietY<enemyY+enemy.height)) {//Nemico colpito
      println("collisione enemy");
      tint(0, 150, 204);
      shot=false;
      collisione=true;
      punt+=5;
      goodShot++;
      explosionSound.play();
      explosion.play();
      explX = proietX-(explosion.width/2);
      explY = proietY-(explosion.height/2);
      proietX=baseCan.width/2;
      proietY=height-(cannon_h+ground.height+5);
      enemyLife--;
      munizioni++;
      power=5;
    }
  }
  if (cont!=0 && cont<30)image(explosion, explX, explY);
}
void mousePressed() {
  if (start==false && ((mouseX>=butStartX && mouseX<=butStartX+button.width) && (mouseY>=butStartY && mouseY<=butStartY+button.height)) ) {//Scelta menu
    menuSong.pause();
    gameSong.play();
    gameSong.loop();
    start=true;
  }
  if (win==false && ((mouseX>=butMenuX && mouseX<=butMenuX+button.width) && (mouseY>=butMenuY && mouseY<=butMenuY+button.height))) {//Ritorno al menu
    start=false;
    win=true;
    gameSong.pause();
    menuSong.play();
    menuSong.loop();
    explosion.stop();
    explosionSound.rewind();
    //inizializzazione variabili
    punt=0;
    munizioni=6;
    enemyLife=3;
    level=1;
    enemySpeed=2;
    scudoSpeed=8;
    scudoSpeed2=20;
    allShot=0;
    goodShot=0;
  }
}
void keyPressed() {
  if (start==true) {
    if (keyCode==RIGHT) {
      println("rx");
      if (angolo<0)
        angolo+=modifAngolo;
    }
    if (keyCode==LEFT) {
      println("sx");
      if (angolo>-(PI/2-0.3))
        angolo-=modifAngolo;
    }
    if (key==' ') {
      if (shot==false  && munizioni>0 && win==true) {//power--> min:5 max:25
        println("spazio");
        if (shot==false  && munizioni>0) {
          shotSpeed=power;
          powerMove=false;
        }
      }
    }
  }
}
void keyReleased() {
  if (key==' ' && shot==false && win==true) {
    powerMove=true;
    shotCannon.play();
    shotCannon.rewind();
    shot=true;
    munizioni--;
    allShot++;
    angoloProiet=angolo;
    Vx = shotSpeed*cos(angoloProiet);
    Vy = shotSpeed*sin(angoloProiet);
  }
}
