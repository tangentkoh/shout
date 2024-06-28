float playerx = 400;
float playery = 880;
float playersize = 20;
float playermove = 8;
float enemyx = 400;
float enemyy = 160;
float enemysize = 60;
float enemymove = 2;
int enemylife = 200;
int enemydir = 1;
float time = 60;
int interval = 100; 
int lastTime = 0;
boolean gameOver = false;
boolean isStart = false; 
int lunaticmode = 0;
ArrayList<Ball> balls; 
Danmaku01 danmaku;
PVector[] enemySources;

void setup() {
    size(820, 1080);
    PFont font = createFont("Meiryo", 50);
    textFont(font);
    stroke(240, 240, 240);
    balls = new ArrayList<Ball>();
    danmaku = new Danmaku01();
    setupEnemySources(false); // 初期設定はノーマルモード
}

void draw() {
    while (!isStart) { 
        background(0);
        fill(255);
        textSize(50);
        text("バレットシューティング", 120, 400);
        textSize(40);
        text("sキーを押してスタート", 200, 820);
        if (keyPressed && key == 's') {
            isStart = true;
            lunaticmode = 0;
            setupEnemySources(false); // ノーマルモード
            danmaku.setLunaticMode(false); // ノーマルモード
        }
        if (keyPressed && key == 'l') {
            isStart = true;
            lunaticmode = 1;
            setupEnemySources(true); // ルナティックモード
            danmaku.setLunaticMode(true); // ルナティックモード
        }
        return;
    }
    background(20, 20, 20);
    fill(240, 240, 240);
    textSize(30);
    text(lunaticmode == 0 ? "「プロシキバレットヘルN」" : "「プロシキバレットヘルL」", 0, 30);
    if(lunaticmode == 1 && time < 30){text("逆転「リバースコントロール」", 0, 60);}
    text(time, 350, 100);

    if (enemylife > 0 && time > 0) {
        fill(220, 0, 0);
        rect(enemyx, enemyy, enemysize, enemysize);
        fill(20, 220, 220);
        rect(enemyx - 20, enemyy - 20, enemylife / 2, 10);
        enemyx += enemymove * enemydir;
        if (enemyx > 500 || enemyx < 220) {
            enemydir *= -1;
        }
        if (lunaticmode == 1) {
            enemySources[0].set(enemyx + 30, enemyy);
            enemySources[1].set(enemyx - enemysize / 2, enemyy);
            enemySources[2].set(enemyx + enemysize + 30, enemyy);
            enemySources[3].set(enemyx - enemysize / 2, enemyy + 30);
            enemySources[4].set(enemyx + enemysize + 30, enemyy + 30);
        } else {
            enemySources[0].set(enemyx + 30, enemyy);
            enemySources[1].set(enemyx - enemysize / 2, enemyy);
            enemySources[2].set(enemyx + enemysize + 30, enemyy);
        }
        danmaku.update();
    }

    if (!gameOver) {
        fill(0, 0, 220);
        rect(playerx, playery, playersize, playersize);
        if (lunaticmode == 0 || time>= 30){
        if (up) playery -= playermove;
        if (down) playery += playermove;
        if (left) playerx -= playermove;
        if (right) playerx += playermove;
        }
        else{
        if (up) playery += playermove;
        if (down) playery -= playermove;
        if (left) playerx += playermove;
        if (right) playerx -= playermove;  
        }
        if (shift) playermove = 4;
        else playermove = 8;
        if (playerx < 0) playerx = 0;
        if (playerx > width - playersize) playerx = width - playersize;
        if (playery < 0) playery = 0;
        if (playery > height - playersize) playery = height - playersize;

        int currentTime = millis();
        if (z) {
            if (currentTime - lastTime > interval) {
                balls.add(new Ball(playerx + 10, playery));
                lastTime = currentTime;
            }
        }
        for (int i = balls.size() - 1; i >= 0; i--) {
            Ball ball = balls.get(i);
            ball.update();
            ball.display();
            if (ball.y < 0) {
                balls.remove(i);
            } else if (enemyx <= ball.x && ball.x <= enemyx + enemysize && enemyy <= ball.y && ball.y <= enemyy + enemysize) {
                enemylife -= 1;
                balls.remove(i);
            }
        }
    }

    if (gameOver) {
        fill(140, 0, 0);
        textSize(40);
        text("敗北者じゃけぇ", 50, 500);
        return;
    }

    if (time <= 0) {
        fill(0, 0, 140);
        textSize(40);
        text("よく耐えたね。", 50, 500);
        return;
    } else if (enemylife <= 0) {
        fill(0, 0, 140);
        textSize(60);
        text("完全勝利！", 50, 500);
        return;
    }

    time -= 0.015;
}

class Ball {
    float x, y;
    float speed;

    Ball(float x, float y) {
        this.x = x;
        this.y = y;
        this.speed = 20;
    }

    void update() {
        y -= speed;
    }

    void display() {
        fill(0, 0, 180);
        ellipse(x, y, 10, 10);
    }
}

class Bullet {
    PVector position;
    PVector velocity;
    float angle;

    Bullet() {
        this.position = new PVector();
        this.velocity = new PVector();
        this.angle = 0;
    }

    boolean update() {
        position.add(velocity);
        draw();
        return collisionField();
    }

    void draw() {}

    boolean collisionField() {
        return !(position.x > 0 && position.x < width && position.y > 0 && position.y < height);
    }

    void setPosition(PVector position) {
        this.position = position;
    }

    void setVelocity(PVector velocity) {
        this.velocity = velocity;
        this.angle = this.velocity.heading();
    }
}

class Danmaku {
    ArrayList<Bullet> bullets;

    Danmaku() {
        bullets = new ArrayList<Bullet>();
    }

    void update() {
        updateBullets();
        checkCollisionWithPlayer();
    }

    void updateBullets() {
        for (int i = bullets.size() - 1; i >= 0; i--) {
            Bullet bullet = bullets.get(i);
            if (bullet.update()) {
                bullets.remove(i);
            }
        }
    }

    void checkCollisionWithPlayer() {
        for (Bullet bullet : bullets) {
            if (dist(bullet.position.x, bullet.position.y, playerx + playersize / 2, playery + playersize / 2) < playersize / 2) {
                gameOver = true;
            }
        }
    }
}

class Bullet01 extends Bullet {
    Bullet01() {
        super();
    }

    void draw() {
        fill(180, 0, 0);
        push();
        translate(position.x, position.y);
        rotate(angle);
        ellipse(0, 0, 10, 10);
        pop();
    }
}

class Danmaku01 extends Danmaku {
    float bulletInterval;
    float nextBulletTime;
    boolean isLunaticMode;

    Danmaku01() {
        super();
        bulletInterval = 100;
        nextBulletTime = millis();
        isLunaticMode = false;
    }

    void setLunaticMode(boolean mode) {
        isLunaticMode = mode;
    }

    void update() {
        super.update();
        if (millis() >= nextBulletTime) {
            int bulletsToFire = isLunaticMode ? 2 : 2; // ルナティックモードでは2発、通常モードでは2発
            for (PVector source : enemySources) {
                if (source != null) {
                    for (int i = 0; i < bulletsToFire; i++) {
                        Bullet01 bullet = new Bullet01();
                        bullet.setPosition(source.copy());
                        bullet.setVelocity(PVector.random2D().mult(5));
                        bullets.add(bullet);
                    }
                }
            }
            nextBulletTime = millis() + bulletInterval;
            if (bulletInterval > 0.6) {
                bulletInterval -= 0.1;
            }
        }
    }
}

void setupEnemySources(boolean lunatic) {
    if (lunatic) {
        enemySources = new PVector[5];
        enemySources[0] = new PVector(enemyx + 30, enemyy);
        enemySources[1] = new PVector(enemyx - enemysize / 2, enemyy);
        enemySources[2] = new PVector(enemyx + enemysize + 30, enemyy);
        enemySources[3] = new PVector(enemyx - enemysize / 2, enemyy + 30);
        enemySources[4] = new PVector(enemyx + enemysize + 30, enemyy + 30);
    } else {
        enemySources = new PVector[3];
        enemySources[0] = new PVector(enemyx + 30, enemyy);
        enemySources[1] = new PVector(enemyx - enemysize / 2, enemyy);
        enemySources[2] = new PVector(enemyx + enemysize + 30, enemyy);
    }
}

boolean up, down, left, right, shift, z;

void keyPressed() {
    if (keyCode == UP) up = true;
    if (keyCode == DOWN) down = true;
    if (keyCode == LEFT) left = true;
    if (keyCode == RIGHT) right = true;
    if (keyCode == SHIFT) shift = true;
    if (key == 'z') z = true;
}

void keyReleased() {
    if (keyCode == UP) up = false;
    if (keyCode == DOWN) down = false;
    if (keyCode == LEFT) left = false;
    if (keyCode == RIGHT) right = false;
    if (keyCode == SHIFT) shift = false;
    if (key == 'z') z = false;
}