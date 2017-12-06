 //<>//
// draw colours
// draw rings

PGraphics img;

void setup() {
  size(1200, 1200);
  img = createGraphics(1200, 1200);
  smooth();


  //  for (int x = 0; x < width; x++) {
  //   for (int y = 0; y < height; y++) {
  //     println("Position: X: " + x+ " Y: " + y);
  //    colourInPixel(x,y);
  //   } 
  //  }
  //  

  float radius = 60;
  for (int i = 0; i < 6; i++) {
    drawWavyCircle(radius, 0, 0);
    radius += 100;
  }

  //  img.save("output.png");
  image(img, 0, 0);
}

void draw() {
  colorMode(HSB);
  strokeWeight(2);
  strokeCap(ROUND);
  float shift = 0;
  float levels = 10.0;
  float d = 0;
  float cX = width/2;
  float cY = height/2;

  for (int i = 0; i < 12; i++) {
    for (int j = floor (levels); j > 0; j--) {

      float pos = j/levels;

      float sat = lerp(15.0, 255.0, sin(PI * pos/2.0));
      float bri = lerp(255.0, 0, sin(PI * pos/2.0));
      fill(shift + 255 * i/12.0, sat, bri);


      d =  1.0 * dist(0, 0, cX, cY) * j / levels;
      float p = d * sin(PI/6.0);
      float q = p / tan(5.0 * PI / 12.0);

      pushMatrix();
      translate(cX, cY);
      rotate(i * PI/6.0 );

      arc(0, 0, 2*d, 2*d, 0, PI/6.0);


      line(0, 0, d, 0);
      line(0, 0, d-q, p);

      //    triangle(0,0,d,0,d-q,p);
      popMatrix();
    }
  }
  println(d);
  fill(255, 0, 200);
  ellipseMode(CENTER);
//  ellipse(cX, cY, 2*d, 2*d);

  noLoop();
}

void drawWavyCircle(float r, float f, float a) {
  img.beginDraw();
  img.stroke(0);
  img.strokeWeight(4);
  img.strokeCap(ROUND);

  float radius = r;
  float points = 12;

  float waveScale = a;
  float waveFreq = f;

  float cX = width/2;
  float cY = height/2;

  float oldX = radius;
  float oldY = 0;

  //  float h1scale = random(0.5);
  //  float h2scale = random(0.5);
  //  float h3scale = random(0.5);
  //  float h4scale = random(0.5);

  //  println(h1scale + " " + h2scale + " " + h3scale + " " + h4scale);

  for (int i = 0; i <= points; i++) {
    float theta = i * TWO_PI / points;
    float shift = waveScale * sin(waveFreq * theta);

    //    shift += h1scale * waveScale * sin(waveFreq*2*theta);
    //    shift += h2scale * waveScale * sin(waveFreq*3*theta);
    //    shift += h3scale * waveScale * sin(waveFreq*4*theta);
    //    shift += h4scale * waveScale * sin(waveFreq*5*theta);

    float x = (radius + shift) * cos(theta);
    float y = (radius + shift) * sin(theta);
    img.line(oldX+cX, oldY+cY, x+cX, y+cY);
    oldX = x;
    oldY = y;
  }
  img.endDraw();
}

void mouseClicked( ) {
  saveFrame("output2.png");
}


void colourInPixel(float x, float y) {
  int cX = width/2;
  int cY = height/2;

  float dx = x - cX;
  float dy = y - cX;
  float r = sqrt(sq(dx) + sq(y));
  float theta = asin(abs(dy) / r);

  if (dy < 0 && dx < 0) theta += PI;
  if (dy >= 0 && dx < 0) theta = PI - theta;
  if (dy < 0 && dx >= 0 ) theta = TWO_PI - theta;

  img.beginDraw();
  img.colorMode(HSB);
  img.stroke(theta * 255 / TWO_PI, 255 * 2 * r/width, 255 - 255 * 2 * r/width);
  img.fill(theta * 255 / TWO_PI, 255 * 2 * r/width, 255 - 255 * 2 * r/width);
  img.point(x, y);
  img.endDraw();
}
