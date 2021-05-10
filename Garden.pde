SoundFile SOUND_AMBIENT;
// Length of day in seconds
final float DAY_LENGTH = 60 * 10;

class Garden {
    ArrayList<Frog> frogs;
    ArrayList<Plant> plants;
    ArrayList<Box> colliders;
    TileChunk chunk;
    float timeOfDay;
    Frog selectedFrog;
    float darkness;
    int width;
    int height;
    LightMap lightMap;
    
    Garden(int width) {
        this.width = min(width, 256);
        this.height = 64;
        frogs = new ArrayList<Frog>();
        Frog froggy = new Frog(4);
        froggy.pos.set(width / 2 - froggy.hitBox.half.x, -froggy.hitBox.half.y);
        frogs.add(froggy);
        plants = new ArrayList<Plant>();
        int p = (int) sqrt(max(width, height));
        chunk = new TileChunk(0, 0, p, TileType.EMPTY);
        //chunk.split();
        colliders = new ArrayList<Box>();
        generateTerrain();
        //generatePlants();
        lightMap = new LightMap(width, height);
    }
    
    boolean modifyAt(int x, int y, TileType type) {
        if (x >= width || y >= height || x < 0 || y < 0) return false;
        if (chunk.modifyAt(x, y, type)) {
            return true;
        }
        return false;
    }
    
    TileType tileAt(int x, int y) {
        return chunk.tileAt(x, y);
    }
    
    void computeHitBoxes() {
        colliders.clear();
        int boundaryWidth = 10;
        int boundaryHeight = 50;
        colliders.add(new Box(new PVector(-boundaryWidth / 2, height - boundaryHeight / 2), new PVector(boundaryWidth / 2, boundaryHeight / 2)));
        colliders.add(new Box(new PVector(width + boundaryWidth / 2, height - boundaryHeight / 2), new PVector(boundaryWidth / 2, boundaryHeight / 2)));
        chunk.gatherHitBoxes(colliders);
    }
    
    void generateTerrain() {
        noiseSeed((int) random(1000));
        for (int i = 0; i < width; i++) {
            int h = (int) map(noise(1000 + i * 0.08), 0.2, 0.8, 4 * height / 5f, 2 * height / 5f);
            for (int j = 0; j < h; j++) {
                if (j < h / 2) {
                    modifyAt(i, height - j, TileType.STONE);
                }
                else {
                    modifyAt(i, height - j, TileType.DIRT);
                }
            }
            for (int j = 0; j < 2; j++) {
                modifyAt(i, height - h - j, TileType.GRASS);
            }
            for (int j = 1; j < 4; j++) {
                modifyAt(i, height - h + j, TileType.GRASS_DARK);
            }
        }
        chunk.join();
        chunk.optimize();
        computeHitBoxes();
    }
    
    void generatePlants() {
        for (int i = 0; i < width; i += 1) {
            int y = height - 1;
            while (tileAt(i, y) != TileType.EMPTY) {
                y--;
            }
            if (random(1) > 0.6) {
                spawnPlant(i, y + 1);
            }
        }
    }
    
    void update() {
        timeOfDay = (float) (((DAY_LENGTH * FPS / 2) + frameCount) % (FPS * DAY_LENGTH)) / (FPS * DAY_LENGTH);
        ArrayList<Plant> toRemove = new ArrayList<Plant>();
        for (Plant plant : plants) {
            if (!plant.canExist()) {
                toRemove.add(plant);
            }
        }
        plants.removeAll(toRemove);
        
        for (Frog frog : frogs) {
            if (frog.equals(selectedFrog)) {
                frog.onGround = false;
                frog.state = JUMPING;
                frog.stateTime = 0;
                frog.pos.set(GX(mouseX), GY(mouseY));
                frog.vel.set(0, 0);
                frog.tick();
            }
            else {
                frog.update(colliders);
            }
        }
    }
    
    void render() {
        background(calcSkyColor());
        
        for (Plant plant : plants) {
            plant.render();
            //drawBox(plant.hitBox);
        }
        
        for (Frog frog : frogs) {
            if (frog == selectedFrog) {
                frog.renderInfo();
            }
            frog.render();
            //pushStyle();
            //stroke(255, 0, 0);
            //drawBox(frog.hitBox);
            //popStyle();
        }
        
        chunk.render();
        //for (Box box : colliders) {
        //    drawBox(box);
        //}
        lightMap.render();
        
        float p = darkness;
        if (p > 0.25) {
            p = map(p, 0.30, 1, 0, 1);
            SOUND_AMBIENT.amp(p*p*0.7);
            if (!SOUND_AMBIENT.isPlaying()) {
                SOUND_AMBIENT.loop();
            }
        }
        else {
            SOUND_AMBIENT.stop();
        }
    }
    
    color calcSkyColor() {
        color DAWN = color(150, 110, 32);
        color DAY = color(80, 206, 240);
        color DUSK = color(142, 33, 78);
        color NIGHT = color(15, 15, 60);
        color from = DAY;
        color to = DAY;
        float hour = timeOfDay * 24;
        float p = 0;
        // Dawn is from 5 to 6
        if (hour >= 5 && hour < 6) {
            from = NIGHT;
            to = DAWN;
            p = (hour - 5) / (float) (6 - 5);
            darkness = lerp(1, 0.5, p);
        }
        // Sunrise from 6 to 7
        else if (hour >= 6 && hour < 7) {
            from = DAWN;
            to = DAY;
            p = (hour - 6) / (float) (7 - 6);
            //println("sunrise");
            darkness = lerp(0.5, 0, p);
        }
        // Day is from 7 to 17
        else if (hour >= 7 && hour < 17) {
            from = DAY;
            to = DAY;
            p = (hour - 7) / (float) (17 - 7);
            darkness = 0;
            //println("day");
        }
        // Sunset is from 17 to 18
        else if (hour >= 17 && hour < 19) {
            from = DAY;
            to = DUSK;
            p = (hour - 17) / (float) (19 - 17);
            //println("sunset");
            darkness = lerp(0, 0.75, p);
        }
        // Dusk is from 18 to 20
        else if (hour >= 19 && hour < 21) {
            from = DUSK;
            to = NIGHT;
            p = (hour - 19) / (float) (21 - 19);
            //println("dusk");
            darkness = lerp(0.75, 1, p);
        }
        // Night is from 20 to 5
        else if (hour >= 20 && hour < 24) {
            from = NIGHT;
            to = NIGHT;
            p = (hour - 20) / (float) (24 - 20);
            //println("night");
            darkness = 1;
        }
        else if (hour >= 0 && hour < 5) {
            from = NIGHT;
            to = NIGHT;
            p = hour / 5f;
            //println("night");
            darkness = 1;
        }
        
        return lerpColor(from, to, p);
    }
    
    void dropFrog() {
        if (selectedFrog != null) {
            selectedFrog.vel.set(1 * (mouseX - pmouseX) / PIXEL_SIZE / TILE_SIZE, 1 * (mouseY - pmouseY) / PIXEL_SIZE / TILE_SIZE);
            selectedFrog.vel.limit(2);
        }
        selectedFrog = null;
    }
    
    Frog frogAt(float x, float y) {
        PVector pos = new PVector(x, y);
        for (Frog frog : frogs) {
            if (frog.hitBox.intersectPoint(pos) != null) {
                return frog;
            }
        }
        return null;
    }
    
    void pickupFrog(float x, float y) {
        selectedFrog = frogAt(x, y);
        if (selectedFrog != null) {
            selectedFrog.ribbit();
        }
    }
    
    void spawnPlant(float x, float y) {
        PlantType type = PlantType.values()[(int) random(PlantType.values().length)];
        Plant plant = null;
        switch (type) {
            case MUSHROOM:
                plant = new Mushroom(x, y, random(1, 4));
                break;
            case FLOWER:
                plant = new Flower(x, y, random(1, 2));
                break;
        }
        if (plant != null && plant.canExist()) {
            plants.add(plant);
        }
    }
    
    void spawnRandomFrog(float x, float y) {
        float size = random(FROG_SIZE_MIN, FROG_SIZE_MAX);
        Frog froggy = new Frog(size, nameGenerator.genName());
        froggy.pos.set(x, y);
        if (random(1) > 0.5) {
            froggy.turnAround();
        }
        frogs.add(froggy);
    }
}
