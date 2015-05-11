//
//  EUExPathArcMenu.m
//  EUExPathArcMenu
//
//  Created by Frank on 14/12/23.
//  Copyright (c) 2014年 zywx. All rights reserved.
//

#import "EUExPathArcMenu.h"
#import "EUtility.h"
#import "EuexArcMenu.h"
#import "EuexArcMenuItem.h"



@interface EUExPathArcMenu() <ArcMenuDelegate>
@property (nonatomic,retain) EuexArcMenu *menu;
@end
@implementation EUExPathArcMenu
-(id)initWithBrwView:(EBrowserView *)eInBrwView{
    self = [super initWithBrwView:eInBrwView];
    if (self) {
    }
    return self;
}
-(void)open:(NSMutableArray *)array{
    if ([array isKindOfClass:[NSMutableArray class]] && [array count]>0) {
        CGFloat x = [[array objectAtIndex:0] floatValue];
        CGFloat y = [[array objectAtIndex:1] floatValue];
        if (!self.menu) {
            NSString *pluginName = @"uexPathArcMenu";
            UIImage *itemOpImage = [[self class] loadLocalImgWithPluginName:pluginName fileName:@"plugin_uexPathArcMenu_option@2x"];
            UIImage *item1Image = [[self class] loadLocalImgWithPluginName:pluginName fileName:@"plugin_uexPathArcMenu_item1@2x"];
            UIImage *item2Image = [[self class] loadLocalImgWithPluginName:pluginName fileName:@"plugin_uexPathArcMenu_item2@2x"];
            
            UIImage *item3Image = [[self class] loadLocalImgWithPluginName:pluginName fileName:@"plugin_uexPathArcMenu_item3@2x"];
            
            UIImage *item4Image = [[self class] loadLocalImgWithPluginName:pluginName fileName:@"plugin_uexPathArcMenu_item4@2x"];
            UIImage *item5Image = [[self class] loadLocalImgWithPluginName:pluginName fileName:@"plugin_uexPathArcMenu_item5@2x"];
            
            UIImage *bgImage = [[self class] loadLocalImgWithPluginName:pluginName fileName:@"plugin_uexPathArcMenu_Bg@2x"];
            
            EuexArcMenuItem *item1 = [[EuexArcMenuItem alloc] initWithBackgroundImage:bgImage highlightedBackgroundImage:nil ContentImage:item1Image highlightedContentImage:nil];
            EuexArcMenuItem *item2 = [[EuexArcMenuItem alloc] initWithBackgroundImage:bgImage highlightedBackgroundImage:nil ContentImage:item2Image highlightedContentImage:nil];
            
            EuexArcMenuItem *item3 = [[EuexArcMenuItem alloc] initWithBackgroundImage:bgImage highlightedBackgroundImage:nil ContentImage:item3Image highlightedContentImage:nil];
            EuexArcMenuItem *item4 = [[EuexArcMenuItem alloc] initWithBackgroundImage:bgImage highlightedBackgroundImage:nil ContentImage:item4Image highlightedContentImage:nil];
            EuexArcMenuItem *item5 = [[EuexArcMenuItem alloc] initWithBackgroundImage:bgImage highlightedBackgroundImage:nil ContentImage:item5Image highlightedContentImage:nil];
            
            EuexArcMenuItem *opItem = [[EuexArcMenuItem alloc] initWithBackgroundImage:bgImage highlightedBackgroundImage:nil ContentImage:itemOpImage highlightedContentImage:nil];
            NSArray *items = @[item1,item2,item3,item4,item5];
            [item1 release];
            [item2 release];
            [item3 release];
            [item4 release];
            [item5 release];
            EuexArcMenu *menu = [[EuexArcMenu alloc] initWithFrame:CGRectMake(0, 0, [EUtility screenWidth], [EUtility screenHeight]) startItem:opItem optionMenus:items style:ArcMenuStyleTop];
            menu.menuDelegate = self;
            menu.startPoint = CGPointMake(x, y);
            [EUtility brwView:meBrwView addSubview:menu];
            self.menu = menu;
            [opItem release];
            [menu release];
        }

    }
}
-(void)setStyle:(NSMutableArray *)array{
    if ([array isKindOfClass:[NSMutableArray class]] && [array count]>0) {
        int styleType = [[array firstObject] intValue];
        if (self.menu) {
            [self.menu updateMenuWithStyle:styleType];
        }
    }

}
- (void)arcMenu:(EuexArcMenu *)menu didSelectIndex:(NSInteger)idx{
    [self.meBrwView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"uexPathArcMenu.onItemClick(%d);",idx]];
 
}

-(void)close:(NSMutableArray *)array{
    if (self.menu) {
        [self.menu removeFromSuperview];
         self.menu = nil;
    }
}

//当前窗口调用uexWindow.close()接口的时候 插件的clean方法会被调用
-(void)clean{
    
}
+(UIImage *)loadLocalImgWithPluginName:(NSString *)plgName fileName:(NSString *)fName{
    NSString *bPath = [plgName stringByAppendingPathComponent:fName];
    NSString *path = [[NSBundle mainBundle] pathForResource:bPath ofType:@"png"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return image;
}
@end
