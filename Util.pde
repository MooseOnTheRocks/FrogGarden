float GX(float screenX) {
    return (screenX - camera.pos.x) / TILE_SIZE / PIXEL_SIZE;
}

float GY(float screenY) {
    return (screenY - camera.pos.y) / TILE_SIZE / PIXEL_SIZE;
}

float SX(float gardenX) {
    return gardenX * PIXEL_SIZE * TILE_SIZE;// - camera.pos.x;
}

float SY(float gardenY) {
    return gardenY * PIXEL_SIZE * TILE_SIZE;// - camera.pos.y;
}

float clamp(float val, float min, float max) {
    return val < min ? min : (val > max ? max : val);
}

float sign(float x) {
    return x < 0 ? -1 : 1;
}

boolean equal(float a, float b, float delta) {
    return abs(a - b) <= delta;
}

int R(float x) {
    return (int) (x - (x % PIXEL_SIZE));
}

PImage repeatImage(PImage img) {
    PImage transformed = createImage(img.width * 2, img.height * 2, ARGB);
    transformed.loadPixels();
    img.loadPixels();
    for (int i = 0; i < img.width; i++) {
        for (int j = 0; j < img.height; j++) {
            int pixel = img.get(i, j);
            transformed.set(i, j, pixel);
            transformed.set(i + img.width, j, pixel);
            transformed.set(i + img.width, j + img.height, pixel);
            transformed.set(i, j + img.height, pixel);
        }
    }
    transformed.updatePixels();
    return transformed;
}

void drawBox(Box box) {
    pushStyle();
    noFill();
    //image(image, SX(x), SY(y), w * PIXEL_SIZE, h * PIXEL_SIZE);
    float x = box.pos.x - box.half.x;
    float y = box.pos.y - box.half.y;
    float w = box.half.x * 2;
    float h = box.half.y * 2;
    rect(x * TILE_SIZE * PIXEL_SIZE, y * TILE_SIZE * PIXEL_SIZE, w * TILE_SIZE * PIXEL_SIZE, h * TILE_SIZE * PIXEL_SIZE);
    popStyle();
}
