#pragma once
#define IMGUI_VERSION "1.89.9"
#define IMGUI_CHECKVERSION() ImGui::CheckVersion(IMGUI_VERSION, sizeof(ImGuiIO), sizeof(ImGuiStyle), sizeof(ImVec2), sizeof(ImVec4), sizeof(ImDrawVert), sizeof(ImDrawIdx))

namespace ImGui {
    bool CheckVersion(const char* version, size_t sz_io, size_t sz_style, size_t sz_vec2, size_t sz_vec4, size_t sz_vert, size_t sz_idx);
    void CreateContext();
    struct ImGuiIO& GetIO();
    struct ImGuiStyle& GetStyle();
    void NewFrame();
    void Render();
    struct ImDrawData* GetDrawData();
    bool Begin(const char* name, bool* p_open = nullptr, int flags = 0);
    void End();
    void Text(const char* fmt, ...);
    bool Button(const char* label, const ImVec2& size = ImVec2(0,0));
    void Separator();
    double GetTime();
}

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

enum ImGuiCol_ {
    ImGuiCol_Text, ImGuiCol_WindowBg, ImGuiCol_ChildBg, ImGuiCol_Border, ImGuiCol_FrameBg
};

enum ImGuiWindowFlags_ {
    ImGuiWindowFlags_None = 0,
    ImGuiWindowFlags_NoCollapse = 1 << 5,
    ImGuiWindowFlags_NoResize = 1 << 6
};

#define ImGuiCond_FirstUseEver 1 << 3
