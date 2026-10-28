#import <UIKit/UIKit.h>
#import <MetalKit/MetalKit.h>

@class mi;
class ModuleControl;

@interface OverlayView : MTKView <MTKViewDelegate>

@property (nonatomic, assign) ModuleControl* moduleControl;
@property (nonatomic, strong) mi* mi;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) MTKTextureLoader *loader;

- (instancetype)initWithFrame:(CGRect)frame :(ModuleControl*)control :(mi*)menu;

@end
