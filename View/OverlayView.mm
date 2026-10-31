#include "SDK/SHANKS_PUBGM_Basic.hpp"
#define IMGUI_DEFINE_MATH_OPERATORS
#define LocalPlayer g_LocalPlayer
#import <UIKit/UIKit.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <mach-o/dyld.h>
#import <sys/utsname.h>
#include "imgui.h"
#include "imgui_impl_metal.h"
#include "xor.h"
#include <cmath>
#include <vector>
#include <string>
#include <map>
#include "Tools.h"
#include "Vector3.h"
#include "Vector2.h"
#include "monoString.h"
// ============================================================
// UNREAL ENGINE SDK - QƏTİ DÜZGÜN SIRALAMA (1. COREUOBJECT, 2. BASIC)
// ============================================================
#include "SDK/SHANKS_PUBGM_CoreUObject_structs.hpp"
#include "SDK/SHANKS_PUBGM_CoreUObject_classes.hpp"
#include "SDK/SHANKS_PUBGM_Basic_structs.hpp"
#include "SDK/SHANKS_PUBGM_Basic_classes.hpp"
#include "SDK/SHANKS_PUBGM_Engine_structs.hpp"
#include "SDK/SHANKS_PUBGM_Engine_classes.hpp"
#include "SDK/SHANKS_PUBGM_GameplayAbilities_structs.hpp"
#include "SDK/SHANKS_PUBGM_GameplayAbilities_classes.hpp"
#include "SDK/SHANKS_PUBGM_GameplayTags_structs.hpp"
#include "SDK/SHANKS_PUBGM_GameplayTags_classes.hpp"
#include "SDK/SHANKS_PUBGM_GameplayTasks_structs.hpp"
#include "SDK/SHANKS_PUBGM_GameplayTasks_classes.hpp"
#include "SDK/SHANKS_PUBGM_Gameplay_structs.hpp"
#include "SDK/SHANKS_PUBGM_Gameplay_classes.hpp"
#include "SDK/SHANKS_PUBGM_UMG_structs.hpp"
#include "SDK/SHANKS_PUBGM_UMG_classes.hpp"
#include "SDK/SHANKS_PUBGM_ShadowTrackerExtra_structs.hpp"
#include "SDK/SHANKS_PUBGM_ShadowTrackerExtra_classes.hpp"
using namespace SDK;
@interface ImGuiDrawView : UIViewController <MTKViewDelegate> {
MTKView *mtkView;
}
@property (nonatomic, strong) MTKView *mtkView;
@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
￼ (void)showChange:(BOOL)arg1;
￼ (BOOL)isChange;
@end
@implementation ImGuiDrawView
@synthesize mtkView;
￼ (void)viewDidLoad {
[super viewDidLoad];
self.device = MTLCreateSystemDefaultDevice();
if (!self.device) return;
self.commandQueue = [self.device newCommandQueue];
mtkView = [[MTKView alloc] initWithFrame:self.view.bounds device:self.device];
mtkView.delegate = self;
mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
mtkView.backgroundColor = [UIColor clearColor];
mtkView.userInteractionEnabled = YES;
[self.view addSubview:mtkView];
IMGUI_CHECKVERSION();
ImGui::CreateContext();
ImGuiIO& io = ImGui::GetIO(); (void)io;
ImGui::StyleColorsDark();
ImGui_ImplMetal_Init(self.device);
}
￼ (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size {
}
￼ (void)drawInMTKView:(MTKView *)view {
ImGui_ImplMetal_NewFrame(view.currentRenderPassDescriptor);
ImGui::NewFrame();
extern void DrawWatermark();
extern void RenderMenu();
DrawWatermark();
RenderMenu();
ImGui::Render();
MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
if (renderPassDescriptor != nil) {
id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
id<MTLRenderCommandEncoder> encoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
ImGui_ImplMetal_RenderDrawData(ImGui::GetDrawData(), commandBuffer, encoder);
[encoder endEncoding];
[commandBuffer presentDrawable:view.currentDrawable];
[commandBuffer commit];
}
}
￼ (void)showChange:(BOOL)arg1 {
}
￼ (BOOL)isChange {
return YES;
}
@end
