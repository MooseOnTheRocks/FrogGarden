package dev.foltz.froggarden.backend.processing;

import dev.foltz.froggarden.FrogGarden;
import processing.core.PApplet;
import processing.core.PImage;

public class FGPApplet extends PApplet {
    @Override
    public void settings() {
        this.size(500, 500);
        this.noSmooth();
    }

    @Override
    public void setup() {
        this.getSurface().setResizable(true);
        this.getSurface().setTitle("FrogGarden");
        this.frameRate(FrogGarden.FPS);
    }

    @Override
    public void draw() {
        FrogGarden.update();
        FrogGarden.render();
    }
}
