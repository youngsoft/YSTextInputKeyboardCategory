//
//  UIView+YSTextInputKeyboard.h
//  YSTextInputKeyboardCategory
//
//  Created by apple on 15/5/12.
//  Copyright (c) 2015年 youngsoft. All rights reserved.
//

#import <UIKit/UIKit.h>


/*
 键盘弹出取消自动移动类。
    本扩展默认实现了UITextField,UITextView,UISearchBar的键盘弹出机制,要想访问这个类的实例则可以使用UIView的分类中定义的扩展属性：kbMoving。
 一般情况下用户不需要任何编码就可以实现键盘的自动弹出。
 */
@interface YSKeyboardMoving : NSObject<UIAppearance>


//指定键盘弹出时往上移动的视图,如果不指定默认设定为父视图,如果视图的父视图的区域也很小则可以自己指定要往上移动的父视图。
//如果设置了kbMovingView则只要用户在kbMovingView中执行tap手势以及向下swipe手势时键盘会自动收回。
@property(nonatomic, weak) UIView *kbMovingView;

//键盘弹出时kbMovingView视图的附加偏移量，默认是50。如果想让父视图的偏移量增加则请手动设置这个值,需要注意的是这个值的设置只有在键盘会挡住视图时才有效。
//注意这里的UI_APPEARANCE_SELECTOR功能，可以统一设置默认值。
@property(nonatomic,assign) CGFloat offset UI_APPEARANCE_SELECTOR;



/*如果自定义控件实现了inputView并要实现键盘的自动弹出和移动时则只需要重载控件的

 - (BOOL)becomeFirstResponder
 {
 BOOL ok = [super becomeFirstResponder];
 if (ok)
 [self.kbMoving addObserverAndGesture];
 
 return ok;
 }
 
 - (BOOL)resignFirstResponder
 {
 BOOL ok = [super resignFirstResponder];
 if (ok)
 [self.kbMoving removeObserverAndGesture];
 
 return ok;
 }
 
的两个方法即可
 */
- (void)addObserverAndGesture;
- (void)removeObserverAndGesture;


@end



/**
 用于实现具有输入焦点的控件的键盘的弹出和自动隐藏以及控件的自动移动机制
 注意在模拟器中测试可能会出现移动的问题，真机则不会！！！！！
 **/
@interface UIView(YSTextInputKeyboard)

//当具有输入焦点的控件在获取输入焦点弹出键盘以及失去焦点隐藏键盘时可以通过这个扩展属性来指定要往上偏移的视图以及偏移量
@property(nonatomic, strong, readonly) YSKeyboardMoving *kbMoving;

@end
