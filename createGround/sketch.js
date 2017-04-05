function setup() {
  var h=14;
  var w=5;
  
  createCanvas(256*w, h);
  background(0);
  stroke(255);
  fill(255);

var a = new Array(h);
for (var i = 0; i < h; i++) {
  a[i] = new Array(256*w);
  for (var j=0; j<256*w; j++) {
    a[i][j]=".";
  }
}


  beginShape();
  for (var x = 0; x < width; x++) {
	var nx = map(x, 0, width, 0, 80);
	var y  = floor((h+6) * noise(nx))-3;
	if (y<0) y=0;
	if (y>h-1) y=h-1;
	rect(x,y,1,1);
	a[y][x]="*";
  }
  endShape();

var all="";
for (var i = 0; i < h; i++) {
  var s="";
  for (var j=0; j<256*w; j++) {
    s=s+a[i][j];
  }
  all=all+s+"\r\n";
}
  var t = document.getElementById("t");
  t.value=all;
}



function draw() {
}
