class LightMap {
    int width, height;
    PImage map;
    color[] darknessMap = new color[] { 0x00000000, 0x19000000, 0x4b000000, 0x96000000, 0xc8000000, 0xff000000 };
    int r = 12;
    
    LightMap(int width, int height) {
        this.width = width;
        this.height = height;
        map = createImage(width, height, ARGB);
    }
    
    void setGT(int x, int y, color c) {
        if (alpha(map.get(x, y)) > alpha(c)) {
            map.set(x, y, c);
        }
    }
    
    void computeAt(int x, int y) {
        if (x < 0 || y < 0 || x >= width || y >= height) return;
        if (garden.tileAt(x, y) != TileType.EMPTY && y != 0) return;
        for (int a = -(r-1); a < r; a++) {
            for (int b = -(r-1); b < r; b++) {
                int xx = x + a;
                int yy = y + b;
                int d = (int) dist(x, y, xx, yy);
                color c = lerpColor(0x00000000, 0xff000000, (float) d / (sqrt(2) * r/2));
                setGT(xx, yy, c);
            }
        }
    }
    
    void updateAt(int x, int y, int rr) {
        map.loadPixels();
        // Set region to complete darkness.
        for (int i = -(rr - 1); i < rr; i++) {
            for (int j = -(rr - 1); j < rr; j++) {
                map.set(x + i, y + j, darknessMap[darknessMap.length - 1]);
            }
        }
        // Make tiles near empty tiles brighter
        for (int i = -(rr + r - 1); i < rr + r; i++) {
            for (int j = -(rr + r - 1); j < rr + r; j++) {
                computeAt(x + i, y + j);
            }
        }
        map.updatePixels();
    }
    
    void computeLightMapForGarden() {
        map.loadPixels();
        // Start with complete darkness.
        for (int i = 0; i < garden.width; i++) {
            for (int j = 0; j < garden.height; j++) {
                map.set(i, j, darknessMap[darknessMap.length - 1]);
            }
        }
        // Make tiles near empty tiles brighter
        for (int i = 0; i < garden.width; i++) {
            for (int j = -1; j < garden.height; j++) {
                computeAt(i, j);
                //TileType type = garden.tileAt(i, j);
                //if (type == TileType.EMPTY) {
                //    for (int a = -(r-1); a < r; a++) {
                //        for (int b = -(r-1); b < r; b++) {
                //            int d = (int) dist(i, j, i + a, j + b);
                //            //int index = (int) map(d, 0, sqrt(2)*r, 0, darknessMap.length - 1);
                //            //println(a, b, index, d);
                //            //color c = darknessMap[index];
                            
                //            color c = lerpColor(0x00000000, 0xff000000, (float) d / (sqrt(2) * r/2));
                //            //println(d, sqrt(2)*r, (float) d / sqrt(2)*r, c);
                //            setGT(i + a, j + b, c);
                //        }
                //    }
                //}
            }
        }
        map.updatePixels();
    }
    
    void render() {
        image(map, 0, 0, width * TILE_SIZE * PIXEL_SIZE, height * TILE_SIZE * PIXEL_SIZE);
    }
}
