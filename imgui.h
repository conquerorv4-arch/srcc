#pragma once
#define IMGUI_VERSION "1.89.9"

struct ImVec2 {
    float x, y;
    ImVec2() : x(0), y(0) {}
    ImVec2(float _x, float _y) : x(_x), y(_y) {}
};

struct ImVec4 {
    float x, y, z, w;
    ImVec4() : x(0), y(0), z(0), w(0) {}
    ImVec4(float _x, float _y, float _z, float _w) : x(_x), y(_y), z(_z), w(_w) {}
};

struct ImGuiIO {
    ImVec2 DisplaySize;
    ImVec2 DisplayFramebufferScale;
    float DeltaTime;
    ImVec2 MousePos;
    bool MouseDown[5];
};

struct ImGuiStyle {
    ImVec4 Colors[55];
};

struct ImDrawData {};
struct ImDrawVert {};
typedef unsigned short ImDrawIdx;

#define IMGUI_CHECKVERSION() ImGui::CheckVersion(IMGUI_VERSION, sizeof(ImGuiIO), sizeof(ImGuiStyle), sizeof(ImVec2), sizeof(ImVec4), sizeof(ImDrawVert), sizeof(ImDrawIdx))

namespace ImGui {
    inline bool CheckVersion(const char*, size_t, size_t, size_t, size_t, size_t, size_t) { return true; }
    inline void CreateContext() {}
    inline ImGuiIO& GetIO() { static ImGuiIO io; return io; }
    inline ImGuiStyle& GetStyle() { static ImGuiStyle style; return style; }
    inline void NewFrame() {}
    inline void Render() {}
    inline ImDrawData* GetDrawData() { static ImDrawData data; return &data; }
    inline bool Begin(const char*, bool* = nullptr, int = 0) { return true; }
    inline void End() {}
    inline void Text(const char*, ...) {}
    inline bool Button(const char*, const ImVec2& = ImVec2(0,0)) { return false; }
    inline void Separator() {}
    inline double GetTime() { return 0.0; }
    inline void SetNextWindowPos(const ImVec2&, int = 0, const ImVec2& = ImVec2(0,0)) {}
    inline void SetNextWindowSize(const ImVec2&, int = 0) {}
}

enum ImGuiCol_ {
    ImGuiCol_Text, ImGuiCol_WindowBg, ImGuiCol_ChildBg, ImGuiCol_Border, ImGuiCol_FrameBg
};

enum ImGuiWindowFlags_ {
    ImGuiWindowFlags_None = 0,
    ImGuiWindowFlags_NoCollapse = 1 << 5,
    ImGuiWindowFlags_NoResize = 1 << 6
};

#define ImGuiCond_FirstUseEver (1 << 3)
