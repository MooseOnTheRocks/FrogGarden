PImage IMG_FROG_SITTING;
PImage IMG_FROG_JUMPING;
PImage IMG_FROG_RIBBITING;
PImage IMG_FROG_CROAKING;
SoundFile SOUND_FROG_RIBBITING;
SoundFile SOUND_FROG_CROAKING;
final float FROG_SPEED_MAX = 10.0f;
final float FROG_SIZE_MIN = 1;
final float FROG_SIZE_MAX = 4;

final int SITTING = 0;
final int JUMPING = 1;
final int RIBBITING = 2;
final int CROAKING = 3;

class Frog {
    PVector pos;
    PVector vel;
    PVector acc;
    float size;
    Box hitBox;
    PImage img;
    boolean onGround;
    int stateTime;
    int state;
    boolean facingRight;
    int tintHue, tintSat, tintBright;
    String name;
    
    Frog(float size) {
        this(size, "Froggy");
    }
    
    Frog(float size, String name) {
        pos = new PVector();
        vel = new PVector();
        acc = new PVector();
        this.size = constrain(size, FROG_SIZE_MIN, FROG_SIZE_MAX);
        hitBox = new Box(pos, new PVector());
        img = IMG_FROG_SITTING;
        //float xyr = img.width / (float) img.height;
        float w = size;
        float h = (float) img.height / (float) img.width * size;
        hitBox.resize(w / 2, h / 2);
        onGround = true;
        state = SITTING;
        facingRight = true;
        tintHue = (int) random(360);
        tintSat = (int) random(0, 30);
        tintBright = (int) random(90, 100);
        this.name = name;
    }
    
    void turnAround() {
        facingRight = !facingRight;
        stateTime = 0;
    }
    
    void croak() {
        if (!onGround) {
            return;
        }
        SOUND_FROG_CROAKING.amp(map(size * size, FROG_SIZE_MIN * FROG_SIZE_MIN, FROG_SIZE_MAX * FROG_SIZE_MAX, 0.1, 0.7));
        SOUND_FROG_CROAKING.rate(map(size, FROG_SIZE_MIN, FROG_SIZE_MAX, 1.1, 0.75));
        SOUND_FROG_CROAKING.play();
        
        state = CROAKING;
        stateTime = 0;
        
    }
    
    void ribbit() {
        if (!onGround) {
            return;
        }
        SOUND_FROG_RIBBITING.amp(map(size * size, FROG_SIZE_MIN * FROG_SIZE_MIN, FROG_SIZE_MAX * FROG_SIZE_MAX, 0.1, 0.7));
        SOUND_FROG_RIBBITING.rate(map(size, FROG_SIZE_MIN, FROG_SIZE_MAX, 1.25, 0.90));
        SOUND_FROG_RIBBITING.play();
        state = RIBBITING;
        stateTime = 0;
    }
    
    void jump() {
        if (!onGround) {
            return;
        }
        state = JUMPING;
        stateTime = 0;
        //pos.y -= 2;
        float f = 0.75;//random(size / 2, 1.5 * size);
        applyForce(new PVector(f / 3 * (facingRight ? 1 : -1), -f));
    }
    
    void update(ArrayList<Box> colliders) {
        applyForce(new PVector(0, 0.05));
        vel.add(acc);
        vel.limit(FROG_SPEED_MAX);
        acc.set(0, 0);
        
        onGround = false;
        // Bug: frog jumps into wall, remove tiles below, frog is floating.
        Sweep sweep = hitBox.sweepInto(colliders, vel);
        if (sweep.time < 1 && sweep.hit != null) {
            // Inside object already
            //if (sweep.time == 0) {
            //    vel.set(0, 0);
            //    Hit hit = sweep.hit.collider.intersectAABB(hitBox);
            //    //println("oonnngaaa");
            //    if (hit != null) {
            //        //println("goin up");
            //        //pos.set(pos.x, hit.collider.pos.y - (hitBox.half.y + hit.collider.half.y + EPSILON));
            //    }
            //    return;
            //}
            if (sweep.hit.normal.x != 0) {
                vel.x *= sweep.time - EPSILON;
            }
            if (sweep.hit.normal.y != 0) {
                vel.y *= sweep.time - EPSILON;
            }
            pos.add(vel);
            if (sweep.hit.normal.y < 0) {
                onGround = true;
                vel.set(0, 0);
            }
        }
        else {
            pos.add(vel);
        }
        tick();
    }
    
    void tick() {
        // not anymore: Determine hitbox from state.
        //float ph = hitBox.half.y;
        if (!onGround) {
            state = JUMPING;
        }
        if (state == JUMPING && onGround) {
            state = SITTING;
        }
        switch (state) {
            case JUMPING:
                stateTime = 0;
                img = IMG_FROG_JUMPING;
                break;
            case RIBBITING:
                switch (stateTime++) {
                    case 0:
                        img = IMG_FROG_RIBBITING;
                        break;
                    default:
                        if (stateTime >= 15) {
                            state = SITTING;
                            stateTime = 0;
                        }
                        break;
                }
                break;
            case CROAKING:
                switch (stateTime++) {
                    case 0:
                    case 45:
                        img = IMG_FROG_RIBBITING;
                        break;
                    case 10:
                        img = IMG_FROG_CROAKING;
                        break;
                    default:
                        if (stateTime >= 50) {
                            state = SITTING;
                            stateTime = 0;
                        }
                        break;
                }
                break;
            case SITTING:
            default:
                stateTime += 1;
                if (stateTime > 100) {
                    switch ((int) random(5)) {
                        case 0:
                            //croak();
                            jump();
                            break;
                        case 1:
                            ribbit();
                            break;
                        case 2:
                            if (garden.timeOfDay > 0.5 && random(1) > 0.5) {
                                croak();
                            }
                            else {
                                stateTime = 0;
                            }
                            break;
                        case 3:
                            turnAround();
                            break;
                        case 4:
                            stateTime = 0;
                            break;
                    }
                }
                img = IMG_FROG_SITTING;
                break;
        }
        //hitBox.resize(img.width * size / 2, img.height * size / 2);
        // Reposition frog for new hitbox
        //float deltaY = hitBox.half.y - ph;
        //pos.add(0, -deltaY);
    }
    
    void renderInfo() {
        pushMatrix();
        pushStyle();
        float w = hitBox.half.x * 2;
        float h = hitBox.half.y * 2;
        float x = (pos.x - w / 2);
        float y = (pos.y - h / 2);
        translate(x * TILE_SIZE * PIXEL_SIZE, y * TILE_SIZE * PIXEL_SIZE);
        text(name, (w * PIXEL_SIZE * TILE_SIZE - textWidth(name)) / 2, -PIXEL_SIZE * 2);
        popStyle();
        popMatrix();
    }
    
    void render() {
        pushMatrix();
        pushStyle();
        colorMode(HSB, 360, 100, 100);
        tint(tintHue, tintSat, map(garden.darkness, 0, 1, 1, 0.4) * tintBright);
        float w = hitBox.half.x * 2;
        float h = hitBox.half.y * 2;
        float x = (pos.x - w / 2);
        float y = (pos.y - h / 2 + (hitBox.half.y - h / 2));
        if (!facingRight) {
            translate((pos.x + w / 2) * TILE_SIZE * PIXEL_SIZE, y * TILE_SIZE * PIXEL_SIZE);
            scale(-1, 1);
        }
        else {
            translate((pos.x - w / 2) * TILE_SIZE * PIXEL_SIZE, y * TILE_SIZE * PIXEL_SIZE);
        }
        float rw = map(img.width, 0, IMG_FROG_SITTING.width, 0, size);
        float rh = map(img.height, 0, IMG_FROG_SITTING.height, 0, ((float) IMG_FROG_SITTING.height / (float) IMG_FROG_SITTING.width) * size);
        image(img, 0, (h - rh) * TILE_SIZE * PIXEL_SIZE + 0.5, rw * TILE_SIZE * PIXEL_SIZE, rh * TILE_SIZE * PIXEL_SIZE);
        popStyle();
        popMatrix();
    }
    
    void applyForce(PVector force) {
        acc.add(force);
    }
}
