#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MenuB.h"
#import "imgui.h"
#import "imgui_impl_metal.h"

extern bool MenDeal;

@interface CustomMTKView : MTKView
@end

@implementation CustomMTKView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!MenDeal) {
        return nil;
    }
    return [super hitTest:point withEvent:event];
}
@end

@interface ImGuiDrawViewController : UIViewController <MTKViewDelegate>
@property (nonatomic, strong) id <MTLDevice> device;
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;
@property (nonatomic, strong) CustomMTKView *customView;
@end

@implementation ImGuiDrawViewController

- (void)loadView
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self.customView = [[CustomMTKView alloc] initWithFrame:screenRect];
    self.view = self.customView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];
    if (!self.device) return;

    IMGUI_CHECKVERSION();
    ImGui::CreateContext();
    ImGuiIO& io = ImGui::GetIO(); (void)io;

    ImGuiStyle& style = ImGui::GetStyle();
    style.Colors[ImGuiCol_WindowBg] = ImVec4(0.06f, 0.06f, 0.06f, 0.95f);
    style.Colors[ImGuiCol_ChildBg] = ImVec4(0.08f, 0.08f, 0.08f, 1.0f);
    style.Colors[ImGuiCol_Border] = ImVec4(0.85f, 0.85f, 0.85f, 0.8f);
    style.Colors[ImGuiCol_FrameBg] = ImVec4(0.15f, 0.15f, 0.15f, 1.0f);
    style.Colors[ImGuiCol_Text] = ImVec4(1.0f, 1.0f, 1.0f, 1.0f);

    ImGui_ImplMetal_Init(_device);

    CustomMTKView *mtkView = (CustomMTKView *)self.view;
    mtkView.device = self.device;
    mtkView.delegate = self;
    mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    mtkView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    mtkView.clipsToBounds = YES;
    mtkView.userInteractionEnabled = YES;
}

- (void)updateIOWithTouchEvent:(UIEvent *)event
{
    UITouch *anyTouch = event.allTouches.anyObject;
    CGPoint touchLocation = [anyTouch locationInView:self.view];
    ImGuiIO &io = ImGui::GetIO();
    io.MousePos = ImVec2(touchLocation.x, touchLocation.y);

    BOOL hasActiveTouch = NO;
    for (UITouch *touch in event.allTouches)
    {
        if (touch.phase != UITouchPhaseEnded && touch.phase != UITouchPhaseCancelled)
        {
            hasActiveTouch = YES;
            break;
        }
    }
    io.MouseDown[0] = hasActiveTouch;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { if (MenDeal) [self updateIOWithTouchEvent:event]; }
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { if (MenDeal) [self updateIOWithTouchEvent:event]; }
- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { if (MenDeal) [self updateIOWithTouchEvent:event]; }
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event { if (MenDeal) [self updateIOWithTouchEvent:event]; }

- (void)drawInMTKView:(MTKView*)view
{
    ImGuiIO& io = ImGui::GetIO();
    io.DisplaySize.x = view.bounds.size.width;
    io.DisplaySize.y = view.bounds.size.height;
    
    CGFloat framebufferScale = view.window.screen.nativeScale ?: UIScreen.mainScreen.nativeScale;
    io.DisplayFramebufferScale = ImVec2(framebufferScale, framebufferScale);
    io.DeltaTime = 1 / float(view.preferredFramesPerSecond ?: 60);
    
    id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];

    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
    if (renderPassDescriptor != nil)
    {
        id <MTLRenderCommandEncoder> renderEncoder = [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        [renderEncoder pushDebugGroup:@"ImGui Jane"];

            ImGui_ImplMetal_NewFrame(renderPassDescriptor);
            ImGui::NewFrame();
            
            CGSize screenSize = [UIScreen mainScreen].bounds.size;
            
            // DARK IOS Menyu Pəncərəsi
            if (MenDeal == true)
            {            
                ImGui::SetNextWindowPos(ImVec2(screenSize.width * 0.5f, screenSize.height * 0.5f), ImGuiCond_FirstUseEver, ImVec2(0.5f, 0.5f));
                ImGui::SetNextWindowSize(ImVec2(500, 300), ImGuiCond_FirstUseEver);
                
                ImGui::Begin("DARK IOS", &MenDeal, ImGuiWindowFlags_NoCollapse | ImGuiWindowFlags_NoResize);
                ImGui::Text("PUBG Ultimate Menu - Active");
                ImGui::Separator();
                
                if (ImGui::Button("Close Menu", ImVec2(120, 30))) {
                    MenDeal = false;
                }
                
                ImGui::End();  
            }
        
        ImGui::Render();
        ImDrawData* draw_data = ImGui::GetDrawData();
        ImGui_ImplMetal_RenderDrawData(draw_data, commandBuffer, renderEncoder);
        
        [renderEncoder popDebugGroup];
        [renderEncoder endEncoding];
        
        [commandBuffer presentDrawable:view.currentDrawable];
    }
    [commandBuffer commit];
}

- (void)mtkView:(MTKView*)view drawableSizeWillChange:(CGSize)size {}

@end

static UIWindow *menuOverlayWindow = nil;

void ShowMenuOverlayWindow() {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!menuOverlayWindow) {
            menuOverlayWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
            menuOverlayWindow.rootViewController = [[ImGuiDrawViewController alloc] init];
            menuOverlayWindow.windowLevel = UIWindowLevelAlert + 500;
            menuOverlayWindow.hidden = NO;
            [menuOverlayWindow makeKeyAndVisible];
        }
    });
}
