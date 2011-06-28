@class SBOrientationLockManager;

@protocol ScreenLockerWeeAppPrivate
- (void)setAutoresizingMaskForView:(UIView *)view;
- (CGRect)viewFrame;
- (void)setupGui;
- (NSString *)lockButtonImagePath;
- (SBOrientationLockManager *)lockManager;
- (void)lockUnlockRotation;
@end

#import <UIKit/UIKit.h>
#import <UIKit/UIView.h>

#import "BBWeeAppController-Protocol.h"

#define LANDSCAPE_WIDTH 476.0f
#define PORTRAIT_WIDTH  316.0f

#define BACKGROUND_VIEW_TAG 333

#define RELEASE_SAFELY(__POINTER) { \
 if (__POINTER)                     \
 {                                  \
  [__POINTER release];              \
  __POINTER = nil;                  \
 }                                  \
}

#define STRETCHABLE_BACKGROUND_IMAGE \
@"/System/Library/WeeAppPlugins/ScreenLockerWeeApp.bundle/ScreenLockerWeeAppBackground.png"

#define LOCK_BUTTON_IMAGE \
@"/System/Library/WeeAppPlugins/ScreenLockerWeeApp.bundle/RotationLockButton@2x.png"

#define UNLOCK_BUTTON_IMAGE \
@"/System/Library/WeeAppPlugins/ScreenLockerWeeApp.bundle/RotationUnlockButton@2x.png"


@interface SBOrientationLockManager /* Avoid compiler warnings */
+(id)sharedInstance;
-(BOOL)isLocked;
-(void)lock;
-(void)unlock;
@end

@interface ScreenLockerWeeApp : NSObject
<
ScreenLockerWeeAppPrivate,
BBWeeAppController
>
{
    UIView   *_widgetView;
    UIButton *_lockButton;
}
- (UIView *)view;

@end

@implementation ScreenLockerWeeApp

- (void)dealloc
{
    RELEASE_SAFELY(_widgetView);
    [super dealloc];
}

- (UIView *)view
{
    BOOL wasInitialized = (nil != _widgetView);
    if (wasInitialized)
    {
        goto wasInitialized;
    }
    [self setupGui];
wasInitialized:
    return _widgetView;
}

- (float)viewHeight
{
    return 71.0f;
}

- (id)launchURLForTapLocation:(CGPoint)point
{	
    // Dirty hack to fix the "TouchHandler" bug.
    UIButton *button
    = (UIButton *)
    [[self view].window
     hitTest:
     [[self view].window
      convertPoint:point
      fromView:[self view]]
     withEvent:nil];
    
    SEL selector = @selector(sendActionsForControlEvents:);
    BOOL canHandleSelector = [button respondsToSelector:selector];
    if(canHandleSelector)
    {
        [button sendActionsForControlEvents:
         UIControlEventTouchUpInside];
    }
    return nil;
}

- (void)willAnimateRotationToInterfaceOrientation:(int)arg1
{
    UIImageView *bgImageView
    = (UIImageView *)[[self view] viewWithTag:BACKGROUND_VIEW_TAG];
    
    if (UIInterfaceOrientationIsLandscape(arg1))
    {
        CGRect rect = [self view].frame;
        rect.size.width = LANDSCAPE_WIDTH;
        [self view].frame = rect;
        rect = bgImageView.frame;
        rect.size.width = LANDSCAPE_WIDTH;
        bgImageView.frame = rect;
    }
    else
    {
        CGRect rect = [self view].frame;
        rect.size.width = PORTRAIT_WIDTH;
        [self view].frame = rect;
        rect = bgImageView.frame;
        rect.size.width = PORTRAIT_WIDTH;
        bgImageView.frame = rect;
    }   
}

- (void)setupWidgetView
{    
    CGRect frame
    = [self viewFrame];
    
    _widgetView
    = [[UIView alloc] initWithFrame:frame];
    [self setAutoresizingMaskForView:_widgetView];
}

- (void)setupBackgroundImage
{
    UIImage *image
    = [[UIImage imageWithContentsOfFile:STRETCHABLE_BACKGROUND_IMAGE]
       stretchableImageWithLeftCapWidth:5 topCapHeight:71];
    
    UIImageView *imageView
    = [[UIImageView alloc] initWithImage:image];
    imageView.frame
    = (CGRect){(CGPoint){.0f, .0f},(CGSize){316.0f, 71.0f}};
    imageView.tag = BACKGROUND_VIEW_TAG;
    [_widgetView addSubview:imageView];
    [imageView release];
}

- (void)setupLockButton
{
    UIButton *lockButton
    = [UIButton buttonWithType:UIButtonTypeCustom];
    
    UIImage *image
    = [UIImage imageWithContentsOfFile:[self lockButtonImagePath]];
    
    CGRect frame
    = [self viewFrame];
    frame.size = image.size;
    lockButton.frame = frame;
    lockButton.center = _widgetView.center;
    
    lockButton.autoresizingMask
    =
    UIViewAutoresizingFlexibleRightMargin
    |
    UIViewAutoresizingFlexibleLeftMargin
    ;
    
    [lockButton
     setImage:image
     forState:UIControlStateNormal];
    
    [lockButton
     addTarget:self
     action:@selector(lockButtonAction:)
     forControlEvents:UIControlEventTouchUpInside];
    
    [_widgetView addSubview:lockButton];
}

- (void)setupGui
{
    [self setupWidgetView];
    [self setupBackgroundImage];
    [self setupLockButton];
}

- (void)lockButtonAction:(id)sender
{
    [self lockUnlockRotation];
    
    UIImage *image
    = [UIImage imageWithContentsOfFile:[self lockButtonImagePath]];
    
    [(UIButton *)sender
     setImage:image
     forState:UIControlStateNormal];
}

- (void)setAutoresizingMaskForView:(UIView *)view
{    
    view.autoresizingMask
    =
    UIViewAutoresizingFlexibleHeight
    |
    UIViewAutoresizingFlexibleWidth
    ;
}

- (CGRect)viewFrame
{
    return
    (CGRect){(CGPoint){2.0f, .0f},(CGSize){316.0f, 71.0f}};
}

- (NSString *)lockButtonImagePath
{
    NSString *returnImagePath = nil;
    
    SBOrientationLockManager *lockManager
    = [self lockManager];
    
    BOOL isLocked
    = [lockManager isLocked];
    if (isLocked)
    {
        returnImagePath = UNLOCK_BUTTON_IMAGE;
    }
    else
    {
        returnImagePath = LOCK_BUTTON_IMAGE;
    }
    return returnImagePath;
}

- (void)lockUnlockRotation
{
    SBOrientationLockManager *lockManager
    = [self lockManager];
    
    BOOL isLocked
    = [lockManager isLocked];
    if (isLocked)
    {
        [lockManager unlock];
    }
    else
    {
        [lockManager lock];
    }
}

- (SBOrientationLockManager *)lockManager
{
    Class $SBOrientationLockManager
    = objc_getClass("SBOrientationLockManager");
    SBOrientationLockManager *lockManager
    = [$SBOrientationLockManager sharedInstance];
    
    return lockManager;
}

@end