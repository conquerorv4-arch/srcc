#pragma once
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

#ifdef __cplusplus
extern "C" {
#endif

bool ImGui_ImplMetal_Init(id<MTLDevice> device);
void ImGui_ImplMetal_Shutdown();
void ImGui_ImplMetal_NewFrame(MTLRenderPassDescriptor* renderPassDescriptor);
void ImGui_ImplMetal_RenderDrawData(struct ImDrawData* draw_data, id<MTLCommandBuffer> commandBuffer, id<MTLRenderCommandEncoder> commandEncoder);

#ifdef __cplusplus
}
#endif
