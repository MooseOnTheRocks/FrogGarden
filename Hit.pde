class Hit {
    Box collider;
    PVector pos;
    PVector delta;
    PVector normal;
    float time;
    
    Hit(Box collider) {
        this.collider = collider;
        pos = new PVector();
        delta = new PVector();
        normal = new PVector();
        time = 0;
    }
}
