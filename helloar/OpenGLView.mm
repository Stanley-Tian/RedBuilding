/**
 * Copyright (c) 2015-2016 VisionStar Information Technology (Shanghai) Co., Ltd. All Rights Reserved.
 * EasyAR is the registered trademark or trademark of VisionStar Information Technology (Shanghai) Co., Ltd in China
 * and other countries for the augmented reality technology developed by VisionStar Information Technology (Shanghai) Co., Ltd.
 */

#import "OpenGLView.h"
#import "AppDelegate.h"

#include <iostream>
#include "ar.hpp"
#include "renderer.hpp"

/*
 * Steps to create the key for this sample:
 *  1. login www.easyar.com
 *  2. create app with
 *      Name: HelloAR
 *      Bundle ID: cn.easyar.samples.helloar
 *  3. find the created item in the list and show key
 *  4. set key string bellow
 */
NSString* key = @"mt3AUTxXDPAQwXvvd1DeCjDeE9A10nN8zO4l9HijCb1HSugNpu5PXy68PMTsXBbaMBHEfxlkmZl3RSaKi2gh1KC7Eb8UluyhPZ3284cfc47e37852e25eaf95ac744ff8fc2F7hQE9j3sIHpwmTJc5C6sAx2V9Wi81GE3kJSZFQibfiZeANUIjNb7qCV5PM9aOt0MPpd";

namespace EasyAR{
    namespace samples{
        
        class HelloAR : public AR
        {
        public:
            HelloAR();
            virtual void initGL();
            virtual void resizeGL(int width, int height);
            virtual void render();
            std::string foundTargetName;
        private:
            Vec2I view_size;
            Renderer renderer;
        };
        
        HelloAR::HelloAR()
        {
            view_size[0] = -1;
        }
        
        void HelloAR::initGL()
        {
            renderer.init();
            augmenter_ = Augmenter();
        }
        
        void HelloAR::resizeGL(int width, int height)
        {
            view_size = Vec2I(width, height);
        }
        
        void HelloAR::render()
        {
            glClearColor(0.f, 0.f, 0.f, 1.f);
            glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
            
            Frame frame = augmenter_.newFrame();
            if(view_size[0] > 0){
                int width = view_size[0];
                int height = view_size[1];
                Vec2I size = Vec2I(1, 1);
                if (camera_ && camera_.isOpened())
                    size = camera_.size();
                if(portrait_)
                    std::swap(size[0], size[1]);
                float scaleRatio = std::max((float)width / (float)size[0], (float)height / (float)size[1]);
                Vec2I viewport_size = Vec2I((int)(size[0] * scaleRatio), (int)(size[1] * scaleRatio));
                if(portrait_)
                    viewport_ = Vec4I(0, height - viewport_size[1], viewport_size[0], viewport_size[1]);
                else
                    viewport_ = Vec4I(0, width - height, viewport_size[0], viewport_size[1]);
                if(camera_ && camera_.isOpened())
                    view_size[0] = -1;
            }
            augmenter_.setViewPort(viewport_);
            augmenter_.drawVideoBackground();
            glViewport(viewport_[0], viewport_[1], viewport_[2], viewport_[3]);
            
            for (int i = 0; i < frame.targets().size(); ++i) {
                AugmentedTarget::Status status = frame.targets()[i].status();
                if(status == AugmentedTarget::kTargetStatusTracked){
                    std::cout<<"Object "<<i<<" Found";
                    //std::cout<<frame.targets()[i];
                    Matrix44F projectionMatrix = getProjectionGL(camera_.cameraCalibration(), 0.2f, 500.f);
                    Matrix44F cameraview = getPoseGL(frame.targets()[i].pose());
                    ImageTarget target = frame.targets()[i].target().cast_dynamic<ImageTarget>();
                    //std::cout<<target.name();
                    std::string targetName(target.name());
                    std::cout << targetName << std::endl;
                    foundTargetName = targetName;
                    
                    return;
                    //renderer.render(projectionMatrix, cameraview, target.size());
                }
            }
        }
        
    }
}

// 一个C++的类的实例
EasyAR::samples::HelloAR ar;
// 一个OC类的声明
@interface OpenGLView ()
{
    //@public
    //NSString* tttName;
}
//@property(nonatomic, strong) NSString * targetName;

@property(nonatomic, strong) CADisplayLink * displayLink;


- (void)displayLinkCallback:(CADisplayLink*)displayLink;
//- (NSString*)getTargetName;
@end
// 实现
@implementation OpenGLView

+ (Class)layerClass
{
    return [CAEAGLLayer class];
}
// 从viewController里面一开始初始化调用的就是这个函数
- (id)initWithFrame:(CGRect)frame
{
    frame.size.width = frame.size.height = MAX(frame.size.width, frame.size.height);
    self = [super initWithFrame:frame];
    if(self){
        [self setupGL];
        // EasyAR 初始化
        EasyAR::initialize([key UTF8String]);
        ar.initGL();
    }
    
    return self;
}

- (void)dealloc
{
    ar.clear();
}

- (void)setupGL
{
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
    
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context)
        NSLog(@"Failed to initialize OpenGLES 2.0 context");
    if (![EAGLContext setCurrentContext:_context])
        NSLog(@"Failed to set current OpenGL context");
    
    GLuint frameBuffer;
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    
    glGenRenderbuffers(1, &_colorRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer);
    
    int width, height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    
    GLuint depthRenderBuffer;
    glGenRenderbuffers(1, &depthRenderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthRenderBuffer);
    glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, width, height);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthRenderBuffer);
}
// 开始
- (void)start{
    // 调用其ar所继承的父类的方法，设置一下下
    
    ar.loadAllFromJsonFile("targets.json");
    ar.initCamera();
    ar.start();
    /* Create a new display link object for the main display. It will
     * invoke the method called 'sel' on 'target', the method has the
     * signature '(void)selector:(CADisplayLink *)sender'. */
    [self startDisplayLink];
}
- (void)startDisplayLink{
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkCallback:)];
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}
- (void)stopDisplayLink{
    [self.displayLink invalidate];
    self.displayLink = nil;
}
- (void)stop
{
    ar.clear();
}
-(id)findTopViewController:(id)inController
{
    /* if ur using any Customs classes, do like this.
     * Here SlideNavigationController is a subclass of UINavigationController.
     * And ensure you check the custom classes before native controllers , if u have any in your hierarchy.
     if ([inController isKindOfClass:[SlideNavigationController class]])
     {
     return [self findTopViewController:[inController visibleViewController]];
     }
     else */
    if ([inController isKindOfClass:[UITabBarController class]])
    {
        return [self findTopViewController:[inController selectedViewController]];
    }
    else if ([inController isKindOfClass:[UINavigationController class]])
    {
        return [self findTopViewController:[inController visibleViewController]];
    }
    else if ([inController isKindOfClass:[UIViewController class]])
    {
        return inController;
    }
    else
    {
        NSLog(@"Unhandled ViewController class : %@",inController);
        return nil;
    }
}
-(id)getCurrentViewController
{
    id WindowRootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    
    id currentViewController = [self findTopViewController:WindowRootVC];
    
    return currentViewController;
}
- (void)displayLinkCallback:(CADisplayLink*)displayLink
{
    if (!((AppDelegate*)[[UIApplication sharedApplication]delegate]).active)
        return;
    ar.render();
    if (ar.foundTargetName != ""){
        NSLog(@"Target Found!!! %s",ar.foundTargetName.c_str());
        
        self.targetName = [NSString stringWithFormat:@"%s", ar.foundTargetName.c_str()];

        ar.foundTargetName = "";
        [self stopDisplayLink];
        
        id currentVC = [self getCurrentViewController];
        //id currentVC = [self findTopViewController:self];
        if (currentVC)
        {
            NSLog(@"currentVC :%@",currentVC);
        }
        // 选择要跳转的segue
        [currentVC performSegueWithIdentifier:@"showH5DetailSegue" sender:self];
        
    }
    (void)displayLink;
    glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer);
    [_context presentRenderbuffer:GL_RENDERBUFFER];
}

- (void)resize:(CGRect)frame orientation:(UIInterfaceOrientation)orientation
{
    BOOL isPortrait = FALSE;
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            isPortrait = TRUE;
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            isPortrait = FALSE;
            break;
        default:
            break;
    }
    ar.setPortrait(isPortrait);
    ar.resizeGL(frame.size.width, frame.size.height);
}

- (void)setOrientation:(UIInterfaceOrientation)orientation
{
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
            EasyAR::setRotationIOS(270);
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            EasyAR::setRotationIOS(90);
            break;
        case UIInterfaceOrientationLandscapeLeft:
            EasyAR::setRotationIOS(180);
            break;
        case UIInterfaceOrientationLandscapeRight:
            EasyAR::setRotationIOS(0);
            break;
        default:
            break;
    }
}

@end
