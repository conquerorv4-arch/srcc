#pragma once

struct Vector2 {
    float X;
    float Y;

    Vector2() : X(0.f), Y(0.f) {}
    Vector2(float x, float y) : X(x), Y(y) {}

    bool IsValid() const {
        return X != 0.f && Y != 0.f;
    }
};
