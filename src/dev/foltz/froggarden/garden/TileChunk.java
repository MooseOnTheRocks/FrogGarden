package dev.foltz.froggarden.garden;

import dev.foltz.froggarden.FrogGarden;
// TODO: Dirty -- don't want to use this import.
import processing.core.PApplet;

import static dev.foltz.froggarden.util.RenderUtil.screenCoord;

public class TileChunk {
    // Tracing: number of living TileChunks.
    // TODO: Create method to count children instead of this
    public static int tileCount = 0;

    // Center of chunk.
    private final int x, y;
    // Power of 2 describing chunk size and number of children.
    // p == 0 means s == 1, which is a single tile (not a chunk).
    public final int p;
    // Size, in tiles.
    // Area of tiles = s * s
    // s = 2^p
    public final int s;
    // 0: top-left, 1: top-right, 2: bottom-left, 3: bottom-right
    private TileChunk[] subChunks;
    private TileType type;
    private boolean dirty;

    public TileChunk(int x, int y, int p, TileType type) {
        assert p >= 0;
        this.x = x;
        this.y = y;
        this.p = p;
        this.s = (int) Math.pow(2, p);
        subChunks = null;
        this.type = type;
        dirty = false;
        tileCount += 1;
    }

    public boolean hasSubChunks() {
        return p != 0 && (subChunks != null && subChunks.length != 0);
    }

    public void markDirty() {
        this.dirty = true;
    }

    public void setAt(int x, int y, TileType type) {
        if (p != 0) {
            float h = s / 2f;
            // If x, y are out of bounds just return.
            if (x < this.x - h || x >= this.x + h) return;
            if (y < this.y - h || y >= this.y + h) return;
            // Otherwise we are within this chunk somewhere.
            // TODO: Optimization -- don't split if chunk is contiguous and type == this.type
            if (!hasSubChunks()) split();
//            for (TileChunk sub : subChunks) {
//                sub.setAt(x, y, type);
//            }
            if (x < this.x && y < this.y)      subChunks[0].setAt(x, y, type);
            else if (x >= this.x && y < this.y) subChunks[1].setAt(x, y, type);
            else if (x < this.x && y >= this.y) subChunks[2].setAt(x, y, type);
            else if (x >= this.x && y >= this.y) subChunks[3].setAt(x, y, type);
        }
        // Single tile, no subchunks.
        else if (this.x == x && this.y == y) {
            this.type = type;
            markDirty();
        }
    }

    public void split() {
        if (p == 0 || hasSubChunks()) return;
        float h = s / 4f;
        int np = p - 1;
        subChunks = new TileChunk[4];
        subChunks[0] = new TileChunk((int) (x - h), (int) (y - h), np, type);
        subChunks[1] = new TileChunk((int) (x + h), (int) (y - h), np, type);
        subChunks[2] = new TileChunk((int) (x - h), (int) (y + h), np, type);
        subChunks[3] = new TileChunk((int) (x + h), (int) (y + h), np, type);
        type = TileType.EMPTY;
        markDirty();
    }

    public void render() {
        PApplet sketch = FrogGarden.sketch;
        // Render a single tile
        if (p == 0 && type != TileType.EMPTY) {
            sketch.push();
            int len = screenCoord(1);
            sketch.image(FrogGarden.TILE_GRASS, screenCoord(x), screenCoord(y), len, len);
            sketch.pop();
        }
        // Render sub chunks
        else if (hasSubChunks()) {
            for (TileChunk sub : subChunks) {
                if (sub != null) sub.render();
            }
        }
        // Render contiguous chunk
        else if (type != TileType.EMPTY) {
            sketch.push();
            int len = screenCoord(s);
            sketch.image(FrogGarden.TILE_GRASS, screenCoord(x - s / 2f), screenCoord(y - s / 2f), len, len);
            sketch.pop();
        }
    }
}
