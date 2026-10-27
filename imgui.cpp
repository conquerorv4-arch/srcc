#include "imgui.h"

static ImGuiIO g_IO;
static ImGuiStyle g_Style;

namespace ImGui {
    bool CheckVersion(const char* version, size_t sz_io, size_t sz_style, size_t sz_vec2, size_t sz_vec4, size_t sz_vert, size_t sz_idx) {
        return true;
    }
    void CreateContext() {}
    ImGuiIO& GetIO() { return g_IO; }
    ImGuiStyle& GetStyle() { return g_Style; }
    void NewFrame() {}
    void Render() {}
    struct ImDrawData* GetDrawData() { return nullptr; }
    bool Begin(const char* name, bool* p_open, int flags) { return true; }
    void End() {}
    void Text(const char* fmt, ...) {}
    bool Button(const char* label, const ImVec2& size) { return false; }
    void Separator() {}
    double GetTime() { return 0.0; }
}
