final float CAMERA_PAN_SPEED = PIXEL_SIZE * 12;

class Camera {
    PVector pos;
    float w, h;
    float zoom;
    PVector wanted;
    boolean moveLeft;
    boolean moveRight;
    
    Camera(float x, float y) {
        pos = new PVector(x, y);
        wanted = pos.copy();
        moveLeft = false;
        moveRight = false;
        w = width;
        h = height;
    }
    
    void recenter() {
         w = width;
         h = height;
         camera.wanted.set(width / 2 - (garden.width * TILE_SIZE * PIXEL_SIZE) / 2, (height - garden.height * TILE_SIZE * PIXEL_SIZE));
    }
    
    void update() {
        if (moveLeft && moveRight) {}
        else if (moveLeft) {
            wanted.set(pos.x + CAMERA_PAN_SPEED, pos.y);
        }
        else if (moveRight) {
            wanted.set(pos.x - CAMERA_PAN_SPEED, pos.y);
        }
        PVector delta = PVector.sub(wanted, pos);
        if (delta.mag() < 2) {
            wanted.set(pos);
        }
        else {
            move(delta.mult(0.1));
        }
    }
    
    void view() {
        //translate(width / 2, height / 2);
        translate(pos.x, pos.y + PIXEL_SIZE);
        scale(width / w, height / h);
    }
    
    void move(PVector delta) {
        pos.add(delta);
    }
}
