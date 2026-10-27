#import <UIKit/UIKit.h>
#import <Metal/Metal.h>
#import <MetalKit/MetalKit.h>

@class Menu;
class ModuleControl;

@interface OverlayView : MTKView <MTKViewDelegate>

@property (nonatomic, strong) id<MTLDevice> device;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) MTKTextureLoader *loader;
@property (nonatomic, weak) Menu *mi;
@property (nonatomic, assign) ModuleControl *moduleControl;
@property (nonatomic, assign) BOOL isMenuOpen;

- (instancetype)initWithFrame:(CGRect)frame menu:(Menu *)menu control:(ModuleControl *)control;

@end
