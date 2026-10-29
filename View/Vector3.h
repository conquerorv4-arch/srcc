#pragma once

#include <cmath>

struct Vector3 {
    float X;
    float Y;
    float Z;

    Vector3() : X(0.f), Y(0.f), Z(0.f) {}
    Vector3(float x, float y, float z) : X(x), Y(y), Z(z) {}

    float Length() const {
        return sqrt(X * X + Y * Y + Z * Z);
    }

    Vector3 operator+(const Vector3& other) const {
        return Vector3(X + other.X, Y + other.Y, Z + other.Z);
    }

    Vector3 operator-(const Vector3& other) const {
        return Vector3(X - other.X, Y - other.Y, Z - other.Z);
    }

    Vector3 operator*(float scalar) const {
        return Vector3(X * scalar, Y * scalar, Z * scalar);
    }
};

// Unreal Engine üçün FVector uyğunluğu
typedef Vector3 FVector;
