#import <UIKit/UIKit.h>
#import <MetalKit/MetalKit.h>

@interface OverlayView : MTKView <MTKViewDelegate>

@property (nonatomic, assign) void* moduleControl;
@property (nonatomic, strong) id mi;
@property (nonatomic, strong) id<MTLCommandQueue> commandQueue;
@property (nonatomic, strong) MTKTextureLoader *loader;

- (instancetype)initWithFrame:(CGRect)frame :(void*)control :(id)menu;

@end
