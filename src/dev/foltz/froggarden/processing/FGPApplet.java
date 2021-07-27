package dev.foltz.froggarden.processing;

import processing.core.PApplet;

public class FGPApplet extends PApplet {
    @Override
    public void settings() {
        this.size(500, 500);
        this.noSmooth();
    }

    @Override
    public void setup() {
        this.getSurface().setResizable(true);
        this.frameRate(60);
    }

    @Override
    public void draw() {
        this.background(204);
        this.ellipse(this.mouseX, this.mouseY, 25, 25);
    }
}
