package dev.foltz.froggarden.util;

public class MathUtil {
    public static float sign(float val) {
        return val > 0 ? 1 : (val < 0 ? -1 : 0);
    }

    public static float abs(float val) {
        return val >= 0 ? val : -val;
    }

    public static float clamp(float val, float min, float max) {
        return val < min ? min : (val > max ? max : val);
    }

    public static float min(float a, float b) {
        return a > b ? b : a;
    }

    public static float max(float a, float b) {
        return a < b ? b : a;
    }
}
