import processing.sound.*;

final int FPS = 60;
int PIXEL_SIZE = 4;

NameGenerator nameGenerator;
PFont mono;
Garden garden;
Camera camera;

float pwidth, pheight;

void setup() {
    size(500, 500);
    surface.setResizable(true);
    noSmooth();
    frameRate(FPS);
    
    // Resources
    SOUND_FROG_RIBBITING = new SoundFile(this, "sounds/ribbit.mp3");
    SOUND_FROG_CROAKING = new SoundFile(this, "sounds/croak.mp3");
    SOUND_AMBIENT = new SoundFile(this, "sounds/ambient.mp3");
    IMG_FROG_SITTING = loadImage("textures/frog_sit.png");
    IMG_FROG_JUMPING = loadImage("textures/frog_jump.png");
    IMG_FROG_RIBBITING = loadImage("textures/frog_ribbit.png");
    IMG_FROG_CROAKING = loadImage("textures/frog_croak.png");
    TILES_GRASS = new PImage[1];
    TILES_GRASS[0] = loadImage("textures/grass_0.png");
    TILES_GRASS_DARK = new PImage[1];
    TILES_GRASS_DARK[0] = loadImage("textures/grass_dark_0.png");
    //TILES_GRASS[1] = loadImage("textures/grass_1.png");
    //TILES_GRASS[2] = loadImage("textures/grass_2.png");
    //TILES_GRASS[3] = loadImage("textures/grass_3.png");
    TILES_DIRT = new PImage[1];
    TILES_DIRT[0] = loadImage("textures/dirt_0.png");
    TILES_STONE = new PImage[1];
    TILES_STONE[0] = loadImage("textures/stone_0.png");
    PLANTS_MUSHROOM = new PImage[3];
    PLANTS_MUSHROOM[0] = loadImage("textures/mushroom_0.png");
    PLANTS_MUSHROOM[1] = loadImage("textures/mushroom_1.png");
    PLANTS_MUSHROOM[2] = loadImage("textures/mushroom_big_0.png");
    //MUSHROOMS_BIG = new PImage[1];
    //MUSHROOMS_BIG[0] = loadImage("textures/mushroom_big_0.png");
    PLANTS_FLOWER = new PImage[2];
    PLANTS_FLOWER[0] = loadImage("textures/flower_0.png");
    PLANTS_FLOWER[1] = loadImage("textures/flower_1.png");
    mono = createFont("font.TTF", 20);
    
    textFont(mono);
    String[] names = loadStrings("names.txt");
    nameGenerator = new NameGenerator(names, 2);
    
    garden = new Garden(200);
    garden.lightMap.computeLightMapForGarden();
    camera = new Camera(0, 0);
    camera.recenter();
    
    pwidth = width;
    pheight = height;
}

void renderInGame(PImage image, float x, float y) {
    renderInGame(image, x, y, image.width / (float) TILE_SIZE, image.height / (float) TILE_SIZE);
}

// TODO: Render flipped images (as a flag?)
void renderInGame(PImage image, float x, float y, float w, float h) {
    float sx = SX(x) + camera.pos.x;
    float sy = SY(y) + camera.pos.y;
    if (sx > width || sy > height || sx < -w * TILE_SIZE * PIXEL_SIZE || sy < -h * TILE_SIZE * PIXEL_SIZE) return;
    pushMatrix();
    image(image, SX(x), SY(y), w * TILE_SIZE * PIXEL_SIZE, h * TILE_SIZE * PIXEL_SIZE);
    popMatrix();
}

void draw() {
    // Window resized
    if (pwidth != width || pheight != height) {
        pwidth = width;
        pheight = height;
        camera.w = pwidth;
        camera.h = pheight;
        camera.recenter();
    }
    
    camera.update();
    garden.update();
    
    pushMatrix();
    camera.view();
    garden.render();
    //if (dirty) {
        //rect(SX(ptopleft.x), SY(ptopleft.y), (pbotright.x - ptopleft.x) * TILE_SIZE * PIXEL_SIZE, (pbotright.y - ptopleft.y) * TILE_SIZE * PIXEL_SIZE);
        //println(ptopleft, pbotright);
    //}
    popMatrix();
    
    text("FPS: " + round(frameRate), 50, 50);
    text("ToD: " + garden.timeOfDay, 50, 70);
    text("PosG: " + GX(mouseX) + ", " + GY(mouseY), 50, 90);
}

void mousePressed() {
    if (mouseButton == LEFT) {
        TileType type = garden.chunk.tileAt((int) GX(mouseX), (int) GY(mouseY));
        println(type);
    }
    else if (mouseButton == RIGHT) {
        garden.pickupFrog(GX(mouseX), GY(mouseY));
    }
}

void paintTiles(int x, int y, int r, TileType topType, TileType botType) {
    if (!dirty) {
        ptopleft.set(x, y);
        pbotright.set(x, y);
    }
    for (int i = x - r; i < x + r; i++) {
        for (int j = y - r; j < y + r; j++) {
            float d = dist(x, y, i, j);
            if (d <= r) {
                if (ptopleft.x > i) ptopleft.x = i;
                if (ptopleft.y > j) ptopleft.y = j;
                if (pbotright.x < i) pbotright.x = i;
                if (pbotright.y < j) pbotright.y = j;
                if (j > y) {
                    garden.modifyAt(i, j, botType);
                }
                else {
                    garden.modifyAt(i, j, topType);
                }
            }
        }
    }
}

PVector ptopleft = new PVector();
PVector pbotright = new PVector();
boolean dirty = false;
void mouseDragged() {
    if (mouseButton == LEFT) {
        int x = (int) GX(mouseX);
        int y = (int) GY(mouseY);
        paintTiles(x, y, 5, TileType.EMPTY, TileType.EMPTY);
        dirty = true;
    }
    else if (mouseButton == RIGHT) {
        if (garden.selectedFrog != null) return;
        int x = (int) GX(mouseX);
        int y = (int) GY(mouseY);
        paintTiles(x, y, 3, TileType.GRASS, TileType.GRASS_DARK);
        dirty = true;
    }
}

void mouseReleased() {
    garden.dropFrog();
    if (dirty) {
        dirty = false;
        garden.computeHitBoxes();
        if (garden.lightMap != null) {
            float w = pbotright.x - ptopleft.x;
            float h = pbotright.y - ptopleft.y;
            int x = (int) (ptopleft.x + w);
            int y = (int) (ptopleft.y + h);
            garden.lightMap.updateAt(x, y, (int) (max(w, h)) * 2);
        }
    }
}

void keyPressed() {
    if (key == 'r') {
        garden = new Garden(garden.width);
        garden.lightMap.computeLightMapForGarden();
        camera.recenter();
    }
    else if (key == ' ') {
        garden.spawnRandomFrog(GX(mouseX), GY(mouseY));
    }
    else if (key == 'j') {
        garden.chunk.join();
        garden.computeHitBoxes();
    }
    else if (key == 'p') {
        garden.generatePlants();
        garden.spawnPlant(GX(mouseX), GY(mouseY));
    }
    else if (key == '-') {
        PIXEL_SIZE = max(PIXEL_SIZE - 1, 1);
        camera.recenter();
    }
    else if (key == '=') {
        PIXEL_SIZE = min(PIXEL_SIZE + 1, 5);
        camera.recenter();
    }
    else {
        switch (keyCode) {
            case UP:
                break;
            case DOWN:
                break;
            case LEFT:
                camera.moveLeft = true;
                break;
            case RIGHT:
                camera.moveRight = true;
                break;
        }
    }
}

void keyReleased() {
    switch (keyCode) {
        case UP:
            break;
        case DOWN:
            break;
        case LEFT:
            camera.moveLeft = false;
            break;
        case RIGHT:
            camera.moveRight = false;
            break;
    }
}
