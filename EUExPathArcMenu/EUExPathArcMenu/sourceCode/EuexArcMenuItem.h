//
//  EuexArcMenuItem.h
//  AppCanPlugin
//
//  Created by Frank on 14/12/25.
//  Copyright (c) 2014年 zywx. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol EuexArcMenuItemDelegate;
@interface EuexArcMenuItem : UIImageView
@property(nonatomic,weak)id<EuexArcMenuItemDelegate> itemDelegate;

@property (nonatomic,assign) CGPoint startPoint;
@property (nonatomic,assign) CGPoint endPoint;
@property (nonatomic,assign) CGPoint nearPoint;
@property (nonatomic,assign) CGPoint farPoint;

@property(nonatomic,strong)UIImageView *contentImgView;
/**
 *  初始化方法
 *
 *  @param bgImage  背景图片
 *  @param hBgImage 背景高亮图片
 *  @param cImage   内容图片
 *  @param hcimage  内容高亮图片
 *
 *  @return menu item
 */
- (id)initWithBackgroundImage:(UIImage *)bgImage highlightedBackgroundImage:(UIImage *)hBgImage ContentImage:(UIImage *)cImage highlightedContentImage:(UIImage *)hcimage;
@end
@protocol EuexArcMenuItemDelegate <NSObject>
/**
 *  代理方法，item按下调用
 *
 *  @param item
 */
- (void)arcMenuItemTouchesBegan:(EuexArcMenuItem *)item;
/**
 *  代理方法，item收起调用
 *
 *  @param item 
 */
- (void)arcMenuItemTouchesEnd:(EuexArcMenuItem *)item;
@end