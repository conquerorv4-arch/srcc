#import <MetalKit/MetalKit.h>
#import "imgui.h"
#import "imgui_impl_metal.h"
#import "Settings.h"

// Menyunu göstərmək/gizlətmək üçün dəyişən
bool showMenu = true;

void RenderMenu() {
    if (!showMenu) return;

    ImGui::Begin("M7MD Menu", &showMenu, ImGuiWindowFlags_NoCollapse);
    
    // Nişanlar (Tabs) və ya bölmələr
    if (ImGui::BeginTabBar("MenuTabs")) {
        
        if (ImGui::BeginTabItem("ESP")) {
            ImGui::Checkbox("ESP Box", &Settings::ESP_Box);
            ImGui::Checkbox("ESP Line", &Settings::ESP_Line);
            ImGui::Checkbox("ESP Distance", &Settings::ESP_Distance);
            ImGui::SliderFloat("Max Distance", &Settings::ESP_MaxDistance, 50.0f, 500.0f);
            ImGui::EndTabItem();
        }
        
        if (ImGui::BeginTabItem("Aimbot")) {
            ImGui::Checkbox("Enable Aimbot", &Settings::Aimbot);
            ImGui::SliderFloat("Aimbot FOV", &Settings::AimbotFOV, 10.0f, 300.0f);
            ImGui::EndTabItem();
        }
        
        ImGui::EndTabBar();
    }
    
    ImGui::End();
}
