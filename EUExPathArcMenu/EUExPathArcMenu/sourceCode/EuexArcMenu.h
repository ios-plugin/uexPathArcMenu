//
//  EuexArcMenu.h
//  AppCanPlugin
//
//  Created by Frank on 14/12/25.
//  Copyright (c) 2014年 zywx. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EuexArcMenuItem.h"

typedef enum {
    ArcMenuStyleTop,
    ArcMenuStyleRight,
    ArcMenuStyleLeft
    
}ArcMenuStyle;


@protocol ArcMenuDelegate;

@interface EuexArcMenu : UIView
@property (nonatomic, weak) id<ArcMenuDelegate> menuDelegate;
@property (nonatomic, assign) CGPoint startPoint;
/**
 *  初始化方法
 *
 *  @param frame       初始化rect
 *  @param startItem   开始按钮
 *  @param aMenusArray 其他按钮
 *  @param style       风格，定义见 ArcMenuStyle
 *
 *  @return 实例
 */
- (id)initWithFrame:(CGRect)frame startItem:(EuexArcMenuItem*)startItem optionMenus:(NSArray *)menusArray style:(ArcMenuStyle)style;
-(void)updateMenuWithStyle:(ArcMenuStyle)style;
@end
@protocol ArcMenuDelegate <NSObject>
- (void)arcMenu:(EuexArcMenu *)menu didSelectIndex:(NSInteger)idx;
@optional
- (void)arcMenuDidFinishAnimationClose:(EuexArcMenu *)menu;
- (void)arcMenuDidFinishAnimationOpen:(EuexArcMenu *)menu;
- (void)arcMenuWillAnimateOpen:(EuexArcMenu *)menu;
- (void)arcMenuWillAnimateClose:(EuexArcMenu *)menu;
@end