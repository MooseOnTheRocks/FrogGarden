// Adapted from: https://noonat.github.io/intersect/
final float EPSILON = 1e-4;

class Box {
    PVector pos;
    PVector half;
    
    Box(PVector pos, PVector half) {
        this.pos = pos;
        this.half = half;
    }
    
    void resize(float w, float h) {
        half.set(w, h);
    }
    
    Hit intersectSegment(PVector pos, PVector delta, float paddingX, float paddingY) {
        final float scaleX = 1f / delta.x;
        final float scaleY = 1f / delta.y;
        final float signX = sign(scaleX);
        final float signY = sign(scaleY);
        final float nearTimeX = (this.pos.x - signX * (half.x + paddingX) - pos.x) * scaleX;
        final float nearTimeY = (this.pos.y - signY * (half.y + paddingY) - pos.y) * scaleY;
        final float farTimeX = (this.pos.x + signX * (half.x + paddingX) - pos.x) * scaleX;
        final float farTimeY = (this.pos.y + signY * (half.y + paddingY) - pos.y) * scaleY;
        
        if (nearTimeX > farTimeY || nearTimeY > farTimeX) {
            return null;
        }
        
        final float nearTime = nearTimeX > nearTimeY ? nearTimeX : nearTimeY;
        final float farTime = farTimeX < farTimeY ? farTimeX : farTimeY;
        
        if (nearTime >= 1 || farTime <= 0) {
            return null;
        }
        
        final Hit hit = new Hit(this);
        hit.time = clamp(nearTime, 0, 1);
        if (nearTimeX > nearTimeY) {
            hit.normal.x = -signX;
            hit.normal.y = 0;
        }
        else {
            hit.normal.x = 0;
            hit.normal.y = -signY;
        }
        hit.delta.x = (1f - hit.time) * -delta.x;
        hit.delta.y = (1f - hit.time) * -delta.y;
        hit.pos.x = pos.x + delta.x * hit.time;
        hit.pos.y = pos.y + delta.y * hit.time;
        return hit;
    }
    
    Hit intersectPoint(PVector point) {
        final float dx = point.x - pos.x;
        final float px = half.x - abs(dx);
        if (px <= 0) {
            return null;
        }
        
        final float dy = point.y - pos.y;
        final float py = half.y - abs(dy);
        if (py <= 0) {
            return null;
        }
        
        final Hit hit = new Hit(this);
        if (px < py) {
            final float sx = sign(dx);
            hit.delta.x = px * sx;
            hit.normal.x = sx;
            hit.pos.x = pos.x + (half.x * sx);
            hit.pos.y = point.y;
        }
        else {
            final float sy = sign(dy);
            hit.delta.y = py * sy;
            hit.normal.y = sy;
            hit.pos.x = point.x;
            hit.pos.y = pos.y + (half.y * sy);
        }
        return hit;
    }
    
    Hit intersectAABB(Box box) {
        final float dx = box.pos.x - pos.x;
        final float px = (box.half.x + half.x) - abs(dx);
        if (px <= 0) {
            return null;
        }
        
        final float dy = box.pos.y - pos.y;
        final float py = (box.half.y + half.y) - abs(dy);
        if (py <= 0) {
            return null;
        }
        
        final Hit hit = new Hit(this);
        if (px < py) {
            final float sx = sign(dx);
            hit.delta.x = px * sx;
            hit.normal.x = sx;
            hit.pos.x = pos.x + (half.x * sx);
            hit.pos.y = box.pos.y;
        }
        else {
            final float sy = sign(dy);
            hit.delta.y = py * sy;
            hit.normal.y = sy;
            hit.pos.x = box.pos.x;
            hit.pos.y = pos.y + (half.y * sy);
        }
        return hit;
    }
    
    Sweep sweepAABB(Box box, PVector delta) {
        final Sweep sweep = new Sweep();
        if (delta.x == 0 && delta.y == 0) {
            sweep.pos.set(box.pos.x, box.pos.y);
            sweep.hit = box.intersectAABB(this);
            if (sweep.hit != null) {
                sweep.hit.time = 0;
                sweep.time = 0;
            }
            else {
                sweep.time = 1;
            }
            return sweep;
        }
        
        sweep.hit = intersectSegment(box.pos, delta, box.half.x, box.half.y);
        if (sweep.hit != null) {
            sweep.time = clamp(sweep.hit.time - EPSILON, 0, 1);
            sweep.pos.set(box.pos.x + delta.x * sweep.time, box.pos.y + delta.y * sweep.time);
            final PVector direction = delta.copy();
            direction.normalize();
            sweep.hit.pos.x = clamp(sweep.hit.pos.x + direction.x * box.half.x, pos.x - half.x, pos.x + half.x);
            sweep.hit.pos.y = clamp(sweep.hit.pos.y + direction.y * box.half.y, pos.y - half.y, pos.y + half.y);
        }
        else {
            sweep.pos.x = box.pos.x + delta.x;
            sweep.pos.y = box.pos.y + delta.y;
            sweep.time = 1;
        }
        return sweep;
    }
    
    Sweep sweepInto(ArrayList<Box> colliders, PVector delta) {
        Sweep nearest = new Sweep();
        nearest.time = 1;
        nearest.pos.x = pos.x + delta.x;
        nearest.pos.y = pos.y + delta.y;
        for (Box collider : colliders) {
            // Breaks everything? Why?
            //float dx = pos.x - collider.pos.x;
            //float dy = pos.y - collider.pos.y;
            //if (abs(dx) > half.x + collider.half.x || abs(dy) > half.y + collider.half.y) {
            //    continue;
            //}
            final Sweep sweep = collider.sweepAABB(this, delta);
            if (sweep.time < nearest.time) {
                nearest = sweep;
            }
        }
        return nearest;
    }
}
