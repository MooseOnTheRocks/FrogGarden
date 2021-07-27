package dev.foltz.froggarden.garden;

public class Camera {
    public float x, y;

    public Camera() {
        x = 0;
        y = 0;
    }

    public void setPos(float x, float y) {
        this.x = x;
        this.y = y;
    }
}
