//
//  EuexArcMenuItem.m
//  AppCanPlugin
//
//  Created by Frank on 14/12/25.
//  Copyright (c) 2014年 zywx. All rights reserved.
//

#import "EuexArcMenuItem.h"
//#import "UIView+Helpers.h"
static inline CGRect ScaleRect(CGRect rect, float n) {return CGRectMake((rect.size.width - rect.size.width * n)/ 2, (rect.size.height - rect.size.height * n) / 2, rect.size.width * n, rect.size.height * n);}

@implementation EuexArcMenuItem
- (id)initWithBackgroundImage:(UIImage *)bgImage highlightedBackgroundImage:(UIImage *)hBgImage ContentImage:(UIImage *)cImage highlightedContentImage:(UIImage *)hcimage{
    if (self = [self init]) {
        self.image = bgImage;
        self.highlightedImage = hBgImage;
        self.userInteractionEnabled = YES;
        self.contentImgView = [[UIImageView alloc] initWithImage:cImage];
        self.contentImgView.highlightedImage = hcimage;
        [self addSubview:_contentImgView];
    }
    return self;
}
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.bounds = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    
    float width = _contentImgView.image.size.width;
    float height = _contentImgView.image.size.height;
    _contentImgView.frame = CGRectMake(self.frame.size.width/2 - width/2, self.frame.size.height/2 - height/2, width, height);
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = YES;
    if ([_itemDelegate respondsToSelector:@selector(arcMenuItemTouchesBegan:)])
    {
        [_itemDelegate arcMenuItemTouchesBegan:self];
    }
    
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    // if move out of 2x rect, cancel highlighted.
    CGPoint location = [[touches anyObject] locationInView:self];
    if (!CGRectContainsPoint(ScaleRect(self.bounds, 2.0f), location))
    {
        self.highlighted = NO;
    }
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
    // if stop in the area of 2x rect, response to the touches event.
    CGPoint location = [[touches anyObject] locationInView:self];
    if (CGRectContainsPoint(ScaleRect(self.bounds, 2.0f), location))
    {
        if ([_itemDelegate respondsToSelector:@selector(arcMenuItemTouchesEnd:)])
        {
            [_itemDelegate arcMenuItemTouchesEnd:self];
        }
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
}

#pragma mark - instant methods
- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    [_contentImgView setHighlighted:highlighted];
}

@end
