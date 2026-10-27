#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>
#import <Foundation/Foundation.h>
#import "MenuB.h"
#import "imgui.h"
#import "imgui_impl_metal.h"

extern bool MenDeal;

@interface CustomMTKView : MTKView
@end

@implementation CustomMTKView
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    // Əgər menyu bağlıdırsa, bütün toxunuşları birbaşa arxadakı oyuna ötürürük (heç nəyi bloklamır)
    if (!MenDeal) {
        return nil;
    }
    return [super hitTest:point withEvent:event];
}
@end

@interface ImGuiDrawView () <MTKViewDelegate>
@property (nonatomic, strong) id <MTLDevice> device;
@property (nonatomic, strong) id <MTLCommandQueue> commandQueue;
@property (nonatomic, strong) UIButton *menuButton;
@property (nonatomic, strong) CustomMTKView *customView;
@end

@implementation ImGuiDrawView

- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    _device = MTLCreateSystemDefaultDevice();
    _commandQueue = [_device newCommandQueue];

    if (!self.device) abort();

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
    return self;
}

- (void)loadView
{
    CGRect screenRect = [UIScreen mainScreen].bounds;
    self.customView = [[CustomMTKView alloc] initWithFrame:screenRect];
    self.view = self.customView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CustomMTKView *mtkView = (CustomMTKView *)self.view;
    mtkView.device = self.device;
    mtkView.delegate = self;
    mtkView.clearColor = MTLClearColorMake(0, 0, 0, 0);
    mtkView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    mtkView.clipsToBounds = YES;
    
    [mtkView setUserInteractionEnabled:YES];
    
    // Yuxarı sol küncdə menyunu açmaq üçün həmişə işləyən düymə
    self.menuButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.menuButton.frame = CGRectMake(20, 50, 55, 55);
    self.menuButton.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.9f];
    self.menuButton.layer.cornerRadius = 27.5f;
    self.menuButton.layer.borderWidth = 2.0f;
    self.menuButton.layer.borderColor = [UIColor greenColor].CGColor;
    [self.menuButton setTitle:@"MENU" forState:UIControlStateNormal];
    [self.menuButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.menuButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [self.menuButton addTarget:self action:@selector(toggleMenu) forControlEvents:UIControlEventTouchUpInside];
    
    // Düymənin həmişə toxunula bilməsi üçün ayrıca pəncərəyə və ya birbaşa görünüşə əlavə edirik
    [self.view addSubview:self.menuButton];
}

- (void)toggleMenu {
    MenDeal = !MenDeal;
    // Menyu açıldıqda toxunuşları aktivləşdiririk, bağlananda sərbəst buraxırıq
    self.customView.userInteractionEnabled = MenDeal;
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
                    self.customView.userInteractionEnabled = NO;
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
