package dev.foltz.froggarden;

import dev.foltz.froggarden.processing.FGPApplet;
import processing.core.PApplet;

public class FrogGarden {
    public static void main(String[] args) {
        String[] sketchArgs = {"dev.foltz.froggarden.processing.FGPApplet"};
        FGPApplet sketch = new FGPApplet();
        PApplet.runSketch(sketchArgs, sketch);
    }
}
