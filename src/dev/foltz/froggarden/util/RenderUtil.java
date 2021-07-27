package dev.foltz.froggarden.util;

import dev.foltz.froggarden.FrogGarden;

import static dev.foltz.froggarden.FrogGarden.PIXELS_PER_TILE;

public class RenderUtil {
    public static int screenCoord(float gameCoord) {
        return (int) (gameCoord * PIXELS_PER_TILE);
    }

    public static float gameCoordX(int screenCoordX) {
        return (screenCoordX - FrogGarden.camera.x) / PIXELS_PER_TILE;
    }

    public static float gameCoordY(int screenCoordY) {
        return (screenCoordY - FrogGarden.camera.y) / PIXELS_PER_TILE;
    }
}
