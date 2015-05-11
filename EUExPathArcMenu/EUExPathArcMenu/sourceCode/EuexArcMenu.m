//
//  EuexArcMenu.m
//  AppCanPlugin
//
//  Created by Frank on 14/12/25.
//  Copyright (c) 2014年 zywx. All rights reserved.
//

#import "EuexArcMenu.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const kMenuDefaultNearRadius = 130.0f;
static CGFloat const kMenuDefaultEndRadius = 140.0f;
static CGFloat const kMenuDefaultFarRadius = 150.0f;
static CGFloat const kMenuDefaultStartPointX = 160.0;
static CGFloat const kMenuDefaultStartPointY = 240.0;
static CGFloat const kMenuDefaultTimeOffset = 0.036f;
static CGFloat const kMenuDefaultRotateAngle = 0.0;
//static CGFloat const kMenuDefaultRotateAngle = -M_PI*0.25;

static CGFloat const kMenuDefaultMenuWholeAngle = M_PI_2;
static CGFloat const kMenuDefaultExpandRotation = M_PI;
static CGFloat const kMenuDefaultCloseRotation = M_PI * 2;
static CGFloat const kMenuDefaultAnimationDuration = 0.5f;
static CGFloat const kMenuStartMenuDefaultAnimationDuration = 0.3f;

static CGPoint RotateCGPointAroundCenter(CGPoint point, CGPoint center, float angle)
{
    CGAffineTransform translation = CGAffineTransformMakeTranslation(center.x, center.y);
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    CGAffineTransform transformGroup = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformInvert(translation), rotation), translation);
    return CGPointApplyAffineTransform(point, transformGroup);
}


@interface EuexArcMenu () <EuexArcMenuItemDelegate>

@property (nonatomic, strong) NSArray *menusArray;
@property (nonatomic, getter = isExpanding) BOOL expanding;
@property (nonatomic, assign) CGFloat nearRadius;
@property (nonatomic, assign) CGFloat endRadius;
@property (nonatomic, assign) CGFloat farRadius;
@property (nonatomic, assign) CGFloat timeOffset;
@property (nonatomic, assign) CGFloat rotateAngle;
@property (nonatomic, assign) CGFloat menuWholeAngle;
@property (nonatomic, assign) CGFloat expandRotation;
@property (nonatomic, assign) CGFloat closeRotation;
@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) BOOL    rotateAddButton;

@property (nonatomic, assign) NSUInteger flag;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) EuexArcMenuItem *startButton;

@property (nonatomic, assign)BOOL isAnimating;

@property (nonatomic,assign)ArcMenuStyle mStyle;

- (void)_expand;
- (void)_close;
- (void)_setMenu;
- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p;
- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p;

@end

@implementation EuexArcMenu
@synthesize expanding = _expanding;

- (id)initWithFrame:(CGRect)frame startItem:(EuexArcMenuItem*)startItem optionMenus:(NSArray *)menusArray style:(ArcMenuStyle)style
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.nearRadius = kMenuDefaultNearRadius;
        self.endRadius = kMenuDefaultEndRadius;
        self.farRadius = kMenuDefaultFarRadius;
        self.timeOffset = kMenuDefaultTimeOffset;
        self.rotateAngle = kMenuDefaultRotateAngle;
        self.menuWholeAngle = kMenuDefaultMenuWholeAngle;
        self.startPoint = CGPointMake(kMenuDefaultStartPointX, kMenuDefaultStartPointY);
        self.expandRotation = kMenuDefaultExpandRotation;
        self.closeRotation = kMenuDefaultCloseRotation;
        self.animationDuration = kMenuDefaultAnimationDuration;
        self.rotateAddButton = YES;
        [self setMenuStyle:style];
        self.menusArray = menusArray;
        _startButton = startItem;
        _startButton.itemDelegate = self;
        _startButton.center = self.startPoint;
        [self addSubview:_startButton];
    }
    return self;
}
#pragma mark - Getters & Setters

- (void)setStartPoint:(CGPoint)aPoint
{
    _startPoint = aPoint;
    _startButton.center = aPoint;
}
-(void)setMenuStyle:(ArcMenuStyle)style{
    self.mStyle = style;
    switch (style) {
        case ArcMenuStyleTop:
            self.rotateAngle = -M_PI_4;
            break;
        case ArcMenuStyleRight:
            self.rotateAngle = 0.0;
            break;
        case ArcMenuStyleLeft:
            self.rotateAngle = -M_PI_2;
            break;
        default:
            self.rotateAngle = -M_PI_4;

            break;
    }
}
-(void)updateMenuWithStyle:(ArcMenuStyle)style{
    [self setMenuStyle:style];
    [self _setMenu];
    
}

#pragma mark - images

- (void)setImage:(UIImage *)image {
    _startButton.image = image;
}

- (UIImage*)image {
    return _startButton.image;
}

- (void)setHighlightedImage:(UIImage *)highlightedImage {
    _startButton.highlightedImage = highlightedImage;
}

- (UIImage*)highlightedImage {
    return _startButton.highlightedImage;
}


- (void)setContentImage:(UIImage *)contentImage {
    _startButton.contentImgView.image = contentImage;
}

- (UIImage*)contentImage {
    return _startButton.contentImgView.image;
}

- (void)setHighlightedContentImage:(UIImage *)highlightedContentImage {
    _startButton.contentImgView.highlightedImage = highlightedContentImage;
}

- (UIImage*)highlightedContentImage {
    return _startButton.contentImgView.highlightedImage;
}



#pragma mark - UIView's methods
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    // if the menu is animating, prevent touches
    if (_isAnimating)
    {
        return NO;
    }
    // if the menu state is expanding, everywhere can be touch
    // otherwise, only the add button are can be touch
    if (YES == _expanding)
    {
        return YES;
    }
    else
    {
        return CGRectContainsPoint(_startButton.frame, point);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.expanding = !self.isExpanding;
}

#pragma mark - AwesomeMenuItem delegates
- (void)arcMenuItemTouchesBegan:(EuexArcMenuItem *)item
{
    if (item == _startButton)
    {
        self.expanding = !self.isExpanding;
    }
}

- (void)arcMenuItemTouchesEnd:(EuexArcMenuItem *)item
{
    // exclude the "add" button
    if (item == _startButton)
    {
        return;
    }
    // blowup the selected menu button
    CAAnimationGroup *blowup = [self _blowupAnimationAtPoint:item.center];
    [item.layer addAnimation:blowup forKey:@"blowup"];
    item.center = item.startPoint;
    
    // shrink other menu buttons
    for (int i = 0; i < [_menusArray count]; i ++)
    {
        EuexArcMenuItem *otherItem = [_menusArray objectAtIndex:i];
        CAAnimationGroup *shrink = [self _shrinkAnimationAtPoint:otherItem.center];
        if (otherItem.tag == item.tag) {
            continue;
        }
        [otherItem.layer addAnimation:shrink forKey:@"shrink"];
        
        otherItem.center = otherItem.startPoint;
    }
    _expanding = NO;
    
    // rotate start button
    float angle = self.isExpanding ? -M_PI_4 : 0.0f;
    [UIView animateWithDuration:_animationDuration animations:^{
        _startButton.transform = CGAffineTransformMakeRotation(angle);
    }];
    
    if ([_menuDelegate respondsToSelector:@selector(arcMenu:didSelectIndex:)])
    {
        [_menuDelegate arcMenu:self didSelectIndex:item.tag - 1000];
    }
}

#pragma mark - Instant methods
- (void)setMenusArray:(NSArray *)aMenusArray
{
    if (aMenusArray == _menusArray)
    {
        return;
    }
    _menusArray = [aMenusArray copy];
    
    
    // clean subviews
    for (UIView *v in self.subviews)
    {
        if (v.tag >= 1000)
        {
            [v removeFromSuperview];
        }
    }
}


- (void)_setMenu {
    NSUInteger count = [_menusArray count];
    for (int i = 0; i < count; i ++)
    {
        EuexArcMenuItem *item = [_menusArray objectAtIndex:i];
        item.tag = 1000 + i;
        item.startPoint = _startPoint;
        
        // avoid overlap
        if (_menuWholeAngle >= M_PI * 2) {
            _menuWholeAngle = _menuWholeAngle - _menuWholeAngle / count;
        }
        CGPoint endPoint = CGPointMake(_startPoint.x + _endRadius * sinf(i * _menuWholeAngle / (count - 1)), _startPoint.y - _endRadius * cosf(i * _menuWholeAngle / (count - 1)));
        item.endPoint = RotateCGPointAroundCenter(endPoint, _startPoint, _rotateAngle);
        CGPoint nearPoint = CGPointMake(_startPoint.x + _nearRadius * sinf(i * _menuWholeAngle / (count - 1)), _startPoint.y - _nearRadius * cosf(i * _menuWholeAngle / (count - 1)));
        item.nearPoint = RotateCGPointAroundCenter(nearPoint, _startPoint, _rotateAngle);
        CGPoint farPoint = CGPointMake(_startPoint.x + _farRadius * sinf(i * _menuWholeAngle / (count - 1)), _startPoint.y - _farRadius * cosf(i * _menuWholeAngle / (count - 1)));
        item.farPoint = RotateCGPointAroundCenter(farPoint, _startPoint, _rotateAngle);
        item.center = item.startPoint;
        item.itemDelegate = self;
        [self insertSubview:item belowSubview:_startButton];
    }
}

- (BOOL)isExpanding
{
    return _expanding;
}
- (void)setExpanding:(BOOL)expanding
{
    if (expanding) {
        [self _setMenu];
        if(self.menuDelegate && [self.menuDelegate respondsToSelector:@selector(arcMenuWillAnimateOpen:)]){
            [self.menuDelegate arcMenuWillAnimateOpen:self];
        }
    }
    
    _expanding = expanding;
    if(self.menuDelegate && [self.menuDelegate respondsToSelector:@selector(arcMenuWillAnimateClose:)]){
        [self.menuDelegate arcMenuWillAnimateClose:self];
    }
    
    // rotate add button
    if (self.rotateAddButton) {
        float angle = self.isExpanding ? -M_PI_4 : 0.0f;
        [UIView animateWithDuration:kMenuStartMenuDefaultAnimationDuration animations:^{
            _startButton.transform = CGAffineTransformMakeRotation(angle);
        }];
    }
    
    // expand or close animation
    if (!_timer)
    {
        _flag = self.isExpanding ? 0 : ([_menusArray count] - 1);
        SEL selector = self.isExpanding ? @selector(_expand) : @selector(_close);
        
        // Adding timer to runloop to make sure UI event won't block the timer from firing
        _timer = [NSTimer timerWithTimeInterval:_timeOffset target:self selector:selector userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
        _isAnimating = YES;
    }
}
#pragma mark - Private methods
- (void)_expand
{
    
    if (_flag == [_menusArray count])
    {
        _isAnimating = NO;
        [_timer invalidate];
        _timer = nil;
        return;
    }
    
    NSUInteger tag = 1000 + _flag;
    EuexArcMenuItem *item = (EuexArcMenuItem *)[self viewWithTag:tag];
    
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:_expandRotation],[NSNumber numberWithFloat:0.0f], nil];
    rotateAnimation.duration = _animationDuration;
    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:.3],
                                [NSNumber numberWithFloat:.4], nil];
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = _animationDuration;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.startPoint.x, item.startPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.nearPoint.x, item.nearPoint.y);
    CGPathAddLineToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, nil];
    animationgroup.duration = _animationDuration;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animationgroup.delegate = self;
    if(_flag == [_menusArray count] - 1){
        [animationgroup setValue:@"firstAnimation" forKey:@"id"];
    }
    
    [item.layer addAnimation:animationgroup forKey:@"Expand"];
    item.center = item.endPoint;
    
    _flag ++;
    
}

- (void)_close
{
    if (_flag == -1)
    {
        _isAnimating = NO;
        [_timer invalidate];
        _timer = nil;
        return;
    }
    
    NSUInteger tag = 1000 + _flag;
    EuexArcMenuItem *item = (EuexArcMenuItem *)[self viewWithTag:tag];
    
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:_closeRotation],[NSNumber numberWithFloat:0.0f], nil];
    rotateAnimation.duration = _animationDuration;
    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:.0],
                                [NSNumber numberWithFloat:.4],
                                [NSNumber numberWithFloat:.5], nil];
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.duration = _animationDuration;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.startPoint.x, item.startPoint.y);
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, nil];
    animationgroup.duration = _animationDuration;
    animationgroup.fillMode = kCAFillModeForwards;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animationgroup.delegate = self;
    if(_flag == 0){
        [animationgroup setValue:@"lastAnimation" forKey:@"id"];
    }
    
    [item.layer addAnimation:animationgroup forKey:@"Close"];
    item.center = item.startPoint;
    
    _flag --;
}
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if([[anim valueForKey:@"id"] isEqual:@"lastAnimation"]) {
        if(self.menuDelegate && [self.menuDelegate respondsToSelector:@selector(arcMenuDidFinishAnimationClose:)]){
            [self.menuDelegate arcMenuDidFinishAnimationClose:self];
        }
    }
    if([[anim valueForKey:@"id"] isEqual:@"firstAnimation"]) {
        if(self.menuDelegate && [self.menuDelegate respondsToSelector:@selector(arcMenuDidFinishAnimationOpen:)]){
            [self.menuDelegate arcMenuDidFinishAnimationOpen:self];
        }
    }
}
- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p
{
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(3, 3, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
    animationgroup.duration = _animationDuration;
    animationgroup.fillMode = kCAFillModeForwards;
    
    return animationgroup;
}

- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p
{
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil];
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(.01, .01, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
    animationgroup.duration = _animationDuration;
    animationgroup.fillMode = kCAFillModeForwards;
    
    return animationgroup;
}

@end
