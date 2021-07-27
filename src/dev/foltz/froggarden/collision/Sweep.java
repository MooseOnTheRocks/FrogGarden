package dev.foltz.froggarden.collision;

import processing.core.PVector;

public class Sweep {
    public Hit hit;
    public PVector pos;
    public float time;

    public Sweep() {
        hit = null;
        pos = new PVector();
        time = 1;
    }
}
