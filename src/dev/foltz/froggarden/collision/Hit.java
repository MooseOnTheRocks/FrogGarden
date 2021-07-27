package dev.foltz.froggarden.collision;

import processing.core.PVector;

public class Hit {
    public Box collider;
    public PVector pos;
    public PVector delta;
    public PVector normal;
    public float time;

    public Hit(Box collider) {
        this.collider = collider;
        pos = new PVector();
        delta = new PVector();
        normal = new PVector();
        time = 0;
    }
}
