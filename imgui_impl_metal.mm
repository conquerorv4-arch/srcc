#import "imgui_impl_metal.h"
#import "imgui.h"

bool ImGui_ImplMetal_Init(id<MTLDevice> device) {
    return true;
}

void ImGui_ImplMetal_Shutdown() {}

void ImGui_ImplMetal_NewFrame(MTLRenderPassDescriptor* renderPassDescriptor) {}

void ImGui_ImplMetal_RenderDrawData(ImDrawData* draw_data, id<MTLCommandBuffer> commandBuffer, id<MTLRenderCommandEncoder> commandEncoder) {}
