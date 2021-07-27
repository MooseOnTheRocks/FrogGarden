package dev.foltz.froggarden;

import dev.foltz.froggarden.backend.processing.FGPApplet;
import dev.foltz.froggarden.garden.Camera;
import dev.foltz.froggarden.garden.Garden;
import dev.foltz.froggarden.garden.TileChunk;
import processing.core.PApplet;
import processing.core.PImage;

public class FrogGarden {
    // Target frames per second
    public static final int FPS = 60;
    // Used for collision calculations
    public static final float EPSILON = 1e-4f;
    // Screen pixels per virtual pixel
    public static final int PIXEL_SIZE = 2;
    // Virtual pixels per tile
    public static final int TILE_SIZE = 4;
    // Screen pixels per tile
    public static final int PIXELS_PER_TILE = PIXEL_SIZE * TILE_SIZE;

    public static PImage TILE_GRASS;

    public static Garden garden;
    public static Camera camera;

    static int prevTileCount = 0;

    public static void update() {
        garden.update();
        if (prevTileCount != TileChunk.tileCount) {
            System.out.println("tileCount: " + TileChunk.tileCount);
            prevTileCount = TileChunk.tileCount;
        }
    }

    public static void render() {
        sketch.background(204);
        // Translate to center of screen.
        sketch.translate(sketch.width / 2, sketch.height / 2);
        // Pan with camera position.
        sketch.translate(-camera.x * PIXELS_PER_TILE, -camera.y * PIXELS_PER_TILE);
        garden.render();
    }

    public static FGPApplet sketch;
    public static void main(String[] args) {
        String[] sketchArgs = {"dev.foltz.froggarden.processing.FGPApplet"};
        sketch = new FGPApplet();
        PApplet.runSketch(sketchArgs, sketch);

        TILE_GRASS = sketch.loadImage("textures/grass_0.png");

        garden = new Garden();
        camera = new Camera();
        camera.setPos(garden.width / 2, garden.height / 2);
    }
}
