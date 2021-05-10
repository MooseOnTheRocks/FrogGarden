enum PlantType {
    MUSHROOM(PLANTS_MUSHROOM),
    FLOWER(PLANTS_FLOWER);
    
    final PImage alternatives[];
    private PlantType(PImage[] alternatives) {
        this.alternatives = alternatives;
    }
}

abstract class Plant implements Physical, Renderable {
    PVector pos;
    Box hitBox;
    PlantType type;
    float size;
    int alt;
    
    Plant(float x, float y, float size, PlantType type) {
        this.size = size;
        this.type = type;
        y = (int) y;
        alt = (int) random(type.alternatives.length);
        PImage img = type.alternatives[alt];
        float w = size;
        float h = (float) img.height / (float) img.width * size;
        pos = new PVector(x, y - h / 2);
        hitBox = new Box(pos, new PVector(w / 2, h / 2));
    }
    
    boolean canExist() {
        // Check for tiles within plant hitbox.
        for (float i = -hitBox.half.x; i < hitBox.half.x; i++) {
            for (float j = -hitBox.half.y; j < hitBox.half.y; j++) {
                float x = (int) (pos.x + i);
                float y = (int) (pos.y + j);
                //ellipse(SX(x + 0.5), SY(y + 0.5), 4, 4);
                if (garden.tileAt((int) x, (int) y) != TileType.EMPTY) {
                    return false;
                }
            }
        }
        // Check for tiles beneath plant.
        for (float i = -round(hitBox.half.x); i < hitBox.half.x; i++) {
            float x = (pos.x + i);
            float y = (pos.y + hitBox.half.y);
            //rect(x * TILE_SIZE * PIXEL_SIZE, y * TILE_SIZE * PIXEL_SIZE, TILE_SIZE * PIXEL_SIZE, TILE_SIZE * PIXEL_SIZE);
            if (garden.tileAt((int) x, (int) y) == TileType.EMPTY) {
                return false;
            }
        }
        return true;
    }
    
    void render() {
        pushMatrix();
        translate(0, 0.5);
        renderInGame(type.alternatives[alt], pos.x - hitBox.half.x, pos.y - hitBox.half.y, hitBox.half.x * 2, hitBox.half.y * 2);
        popMatrix();
    }
    
    PVector getPos() {
        return pos;
    }
    
    Box getHitBox() {
        return hitBox;
    }
}
