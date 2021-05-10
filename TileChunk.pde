class TileChunk implements Renderable {
    final int x, y;
    final int p;
    final int s;
    final TileChunk[] subChunks;
    TileType type;
    Box hitBox;

    TileChunk(int x, int y, int p, TileType type) {
        assert(p >= 0);
        this.x = x;
        this.y = y;
        this.p = p;
        this.type = type;
        s = (int) pow(2, p);
        subChunks = new TileChunk[4];
        PVector pos = new PVector(x + s / 2f, y + s / 2f);
        hitBox = new Box(pos.copy(), new PVector(s / 2f, s / 2f));
    }

    boolean isEmpty() {
        return (isTile() || !hasSubChunks()) && type == TileType.EMPTY;
    }

    TileType tileAt(int x, int y) {
        if (x >= this.x + s || y >= this.y + s) return TileType.EMPTY;
        if (x < this.x || y < this.y) return TileType.EMPTY;
        if (!hasSubChunks()) {
            return type;
        }
        for (TileChunk sub : subChunks) {
            if (sub == null) continue;
            TileType t = sub.tileAt(x, y);
            if (t != TileType.EMPTY) {
                return t;
            }
        }
        return TileType.EMPTY;
    }

    ArrayList<Box> gatherHitBoxes(ArrayList<Box> boxes) {
        if (hasSubChunks()) {
            for (TileChunk sub : subChunks) {
                if (sub == null) continue;
                sub.gatherHitBoxes(boxes);
            }
        } else {
            if (type != TileType.EMPTY) {
                boxes.add(hitBox);
            }
        }

        return boxes;
    }

    void optimize() {
        if (subChunks == null) return;
        if (isWhole()) return;
        
        for (int i = 0; i < subChunks.length; i++) {
            if (subChunks[i] == null) continue;
            if (subChunks[i].isEmpty()) {
                subChunks[i] = null;
            }
        }
        if (!hasSubChunks()) type = TileType.EMPTY;
    }
    
    boolean isWhole() {
        if (isTile() && type != TileType.EMPTY) return true;
        if (!hasSubChunks() && type != TileType.EMPTY) return true;
        if (!hasSubChunks() && type == TileType.EMPTY) return false;
        for (TileChunk sub : subChunks) {
            if (sub == null || !sub.isWhole()) return false;
        }
        return true;
    }

    void join() {
        if (isTile()) return;
        if (!hasSubChunks()) return;
        for (TileChunk sub : subChunks) {
            if (sub == null) continue;
            sub.join();
        }
        if (!isWhole()) return;
        for (TileChunk sub : subChunks) {
            if (sub.type == TileType.EMPTY || sub.isEmpty() || sub.type != subChunks[0].getType()) {
                return;
            }
        }
        type = subChunks[0].getType();
        for (int i = 0; i < subChunks.length; i++) {
            subChunks[i] = null;
        }
    }
    
    boolean hasSubChunks() {
        for (int i = 0; i < subChunks.length; i++) {
            if (subChunks[i] != null) {
                return true;
            }
        }
        return false;
    }
    
    boolean isTile() {
        return p == 0;
    }

    void split() {
        if (isTile()) return;
        if (hasSubChunks()) return;
        int np = p - 1;
        int half = s / 2;
        subChunks[0] = new TileChunk(x, y, np, type);
        subChunks[1] = new TileChunk(x + half, y, np, type);
        subChunks[2] = new TileChunk(x + half, y + half, np, type);
        subChunks[3] = new TileChunk(x, y + half, np, type);
        type = TileType.EMPTY;
    }

    boolean modifyAt(int x, int y, TileType newType) {
        if (x >= this.x + s || y >= this.y + s) return false;
        if (x < this.x || y < this.y) return false;
        if (isTile()) {
            if (type == newType) {
                return false;
            }
            else {
                type = newType;
                return true;
            }
        }
        if (!hasSubChunks() && type == newType) return false;
        
        split();
        for (TileChunk sub : subChunks) {
            if (sub == null) continue;
            if (sub.modifyAt(x, y, newType)) {
                join();
                return true;
            }
        }
        return false;
    }

    void render() {
        if (!hasSubChunks()) {
            if (type == TileType.EMPTY) return;
            pushMatrix();
            pushStyle();
            PImage tile = type.alternatives[0];
            colorMode(HSB, 360, 100, 100, 100);
            float p = garden.darkness;
            tint(250, p * 85, 90 + (1-(p*p)) * 10);
            renderInGame(tile, x, y, s, s);
            popStyle();
            popMatrix();
        }
        else {
            for (TileChunk sub : subChunks) {
                if (sub == null) continue;
                sub.render();
            }
        }
    }

    TileType getType() {
        return type;
    }
}
