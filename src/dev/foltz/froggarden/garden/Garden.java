package dev.foltz.froggarden.garden;

import dev.foltz.froggarden.FrogGarden;
// TODO: Dirty -- don't want to use this import.
import processing.core.PApplet;

import java.util.ArrayList;

public class Garden {
    // TODO: Make this a list of chunks.
    // Want to have many chunks horizontally.
    //     - Infinitely many? (lazy loading, etc.)
    // Fixed vertical height for now?
    TileChunk chunk;
    private ArrayList<Frog> frogs;
    public int width;
    public int height;

    public Garden() {
        int p = (int) Math.sqrt(16);
        this.width = p*p;
        this.height = p*p;
        chunk = new TileChunk(p*p/2, p*p/2, p, TileType.GRASS);
        // Set top half to air.
        for (int i = 0; i < chunk.s; i++) {
            for (int j = 0; j < chunk.s / 2; j++) {
                chunk.setAt(i, j, TileType.EMPTY);
            }
        }
        // No froggies yet :c
        frogs = new ArrayList<>();
    }

    public void update() {
        for (Frog frog : frogs) {
            frog.update();
        }
    }

    public void render() {
        // Pain
        PApplet sketch = FrogGarden.sketch;
        sketch.push();
        chunk.render();
        for (Frog frog : frogs) {
            frog.render();
        }
        sketch.pop();
    }
}
