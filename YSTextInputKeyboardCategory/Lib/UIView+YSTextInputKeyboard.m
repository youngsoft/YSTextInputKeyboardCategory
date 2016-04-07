//
//  UIView+YSTextInputKeyboard.m
//  YSTextInputKeyboardCategory
//
//  Created by apple on 15/5/12.
//  Copyright (c) 2015年 youngsoft. All rights reserved.
//

#import "UIView+YSTextInputKeyboard.h"
#import <objc/runtime.h>


const char * const ASSOCIATEDOBJECT_KEY_YSTEXTINPUTKEYBOARD_MOVING = "ASSOCIATEDOBJECT_KEY_YSTEXTINPUTKEYBOARD_MOVING";


typedef BOOL (*GYS_LPFNFirstResponder)(id,SEL);
typedef void (*GYS_LPFNDidMoveToSuperview)(id,SEL);


GYS_LPFNFirstResponder GYS_defaultTextFieldBecomeFirstResponder = NULL;
GYS_LPFNFirstResponder GYS_defaultTextFieldResignFirstResponder = NULL;

GYS_LPFNFirstResponder GYS_defaultTextViewBecomeFirstResponder = NULL;
GYS_LPFNFirstResponder GYS_defaultTextViewResignFirstResponder = NULL;

GYS_LPFNFirstResponder GYS_defaultSearchBarBecomeFirstResponder = NULL;
GYS_LPFNFirstResponder GYS_defaultSearchBarResignFirstResponder = NULL;

GYS_LPFNDidMoveToSuperview GYS_defaultViewDidMoveToSuperview = NULL;


BOOL YSTextFieldBecomeFirstResponder(UIView *self, SEL _cmd)
{
    BOOL ok = (BOOL)GYS_defaultTextFieldBecomeFirstResponder(self, _cmd);
    if (ok)
        [self.kbMoving addObserverAndGesture];
    
    return ok;
    
}

BOOL YSTextFieldResignFirstResponder(UIView *self, SEL _cmd)
{
    BOOL ok = (BOOL)GYS_defaultTextFieldResignFirstResponder(self, _cmd);
    if (ok)
        [self.kbMoving removeObserverAndGesture];
    return ok;
}


BOOL YSTextViewBecomeFirstResponder(UIView *self, SEL _cmd)
{
    BOOL ok = (BOOL)GYS_defaultTextViewBecomeFirstResponder(self, _cmd);
    if (ok)
        [self.kbMoving addObserverAndGesture];
    
    return ok;
    
}

BOOL YSTextViewResignFirstResponder(UIView *self, SEL _cmd)
{
    BOOL ok = (BOOL)GYS_defaultTextViewResignFirstResponder(self, _cmd);
    if (ok)
        [self.kbMoving removeObserverAndGesture];
    return ok;
}



BOOL YSSearchBarBecomeFirstResponder(UIView *self, SEL _cmd)
{
    BOOL ok = (BOOL)GYS_defaultSearchBarBecomeFirstResponder(self, _cmd);
    if (ok)
        [self.kbMoving addObserverAndGesture];
    
    return ok;
    
}

BOOL YSSearchBarResignFirstResponder(UIView *self, SEL _cmd)
{
    BOOL ok = (BOOL)GYS_defaultSearchBarResignFirstResponder(self, _cmd);
    if (ok)
        [self.kbMoving removeObserverAndGesture];
    return ok;
}


void YSViewDidMoveToSuperview(UIView *self, SEL _cmd)
{
    GYS_defaultViewDidMoveToSuperview(self, _cmd);
    
    if (([self isKindOfClass:[UITextField class]] ||
         [self isKindOfClass:[UITextView class]] ||
         [self methodForSelector:@selector(setInputView:)] != nil) && self.kbMoving.kbMovingView == nil)
    {
        if (![self isKindOfClass:NSClassFromString(@"UISearchBarTextField")])
            self.kbMoving.kbMovingView = self.superview;
    }
}



@interface YSKeyboardMovingProxy : NSProxy

@property(nonatomic) NSMutableArray *invocations;

-(id)init;

-(void)loadInvocations:(YSKeyboardMoving*)kbMoving;

@end

@implementation YSKeyboardMovingProxy

-(id)init
{
    _invocations = [[NSMutableArray alloc] init];
    return self;
}

//这里的从定向就是增加对方法调用的持有，因此没有真正实现从定向。
-(void)forwardInvocation:(NSInvocation *)anInvocation;
{
    // tell the invocation to retain arguments
    
    [anInvocation retainArguments];
    
    // add the invocation to the array
    [self.invocations addObject:anInvocation];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [YSKeyboardMoving instanceMethodSignatureForSelector:aSelector];
}

-(void)loadInvocations:(YSKeyboardMoving*)kbMoving
{
    for (NSInvocation *invocation in self.invocations) {
        [invocation setTarget:kbMoving];
        [invocation invoke];
    }
}

@end






@interface YSKeyboardMoving()

-(id)initWithOwner:(UIView*)txtView;

-(void)movingView;

@property(nonatomic) UITapGestureRecognizer *tapGesture;
@property(nonatomic) UISwipeGestureRecognizer *swipeGesture;

@property(nonatomic, assign) UIView *txtView;


@end


@implementation YSKeyboardMoving


-(id)initWithOwner:(UIView*)txtView
{
    self = [self init];
    if (self != nil)
    {
        _txtView = txtView;
        _offset = 50;
        
        [((YSKeyboardMovingProxy*)[YSKeyboardMoving appearance]) loadInvocations:self];

    }
    
    return self;
}


-(void)setKbMovingView:(UIView *)kbMovingView
{
    [self removeObserverAndGesture];
    _kbMovingView = kbMovingView;
}


#pragma mark -- Event Handle

-(void)handleKeyboardWillShow:(NSNotification*)noti
{
    if (self.kbMovingView != nil && [self.txtView isFirstResponder])
    {
        NSDictionary *userInfo = [noti userInfo];
        NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGFloat keyboardHeight = [aValue CGRectValue].size.height;
        
        [self movingView:keyboardHeight];
    }
    
    
}

-(void)handleKeyboardWillHide:(NSNotification*)noti
{
    if (self.kbMovingView != nil && [self.txtView isFirstResponder])
    {
        if (!CGAffineTransformIsIdentity(self.kbMovingView.transform))
        {
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3];
            self.kbMovingView.transform =CGAffineTransformIdentity;
            [UIView commitAnimations];
        }
    }
}

-(void)handleKeyboardWillChange:(NSNotification*)noti
{
    [self handleKeyboardWillShow:noti];
}

-(void)handleGesture:(UIGestureRecognizer*)gesture
{
    if (self.kbMovingView != nil)
    {
        [self.txtView resignFirstResponder];
    }
}


- (void)addObserverAndGesture
{
    if (self.kbMovingView != nil)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleKeyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
        
        if (self.tapGesture == nil)
        {
            self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
        }
        
        if (self.swipeGesture == nil)
        {
            self.swipeGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
            self.swipeGesture.direction = UISwipeGestureRecognizerDirectionDown;
        }
        
        
        [self.kbMovingView addGestureRecognizer:self.tapGesture];
        [self.kbMovingView addGestureRecognizer:self.swipeGesture];
        
    }
    
    //如果当前已经显示键盘则直接调整位置。。
    [self movingView];
    
}

- (void)removeObserverAndGesture
{
    if (self.kbMovingView != nil)
    {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
        
        if (self.tapGesture != nil &&  self.swipeGesture != nil)
        {
            [self.kbMovingView removeGestureRecognizer:self.tapGesture];
            [self.kbMovingView removeGestureRecognizer:self.swipeGesture];
        }
    }
}


-(void)movingView
{
    if (self.kbMovingView != nil)
    {
        UIWindow *windowTemp = nil;
        for (UIWindow *w in [[UIApplication sharedApplication] windows]) {
            if ([NSStringFromClass([w class]) isEqualToString:@"UITextEffectsWindow"]) {
                windowTemp = w;
                break;
            }
        }
        
        if (windowTemp != nil && !windowTemp.isHidden)
        {
            
            //总是按252的高度来算。
            if (windowTemp.subviews.count > 0)
            {
                [self movingView:252];
            }
        }
    }
    
}

- (void)movingView:(CGFloat)keyboardHeight
{
    CGRect rect = [self.txtView convertRect:self.txtView.bounds toView:self.txtView.window];
    CGFloat h = rect.origin.y + rect.size.height - (self.txtView.window.bounds.size.height - keyboardHeight);
    if (h > 0)
    {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        CGAffineTransform at = CGAffineTransformMakeTranslation(0, -1 * (h + _offset - self.kbMovingView.transform.ty));
        
        self.kbMovingView.transform = at;
        [UIView commitAnimations];
    }
    else
    {
        //如果太高要往下移动。。。。
        if (!CGAffineTransformIsIdentity(self.kbMovingView.transform))
        {
            CGAffineTransform at = CGAffineTransformMakeTranslation(0, -1 * (h + _offset - self.kbMovingView.transform.ty));
            
            if (at.ty > 0)
                at = CGAffineTransformIdentity;
            
            [UIView beginAnimations:nil context:nil];
            [UIView setAnimationDuration:0.3];
            self.kbMovingView.transform = at;
            [UIView commitAnimations];
        }
        
    }
}

-(void)dealloc
{
    [self removeObserverAndGesture];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    
}

#pragma mark -- UIAppearance
+ (instancetype)appearance
{
    static YSKeyboardMovingProxy *proxy = nil;
    
    if (proxy == nil)
    {
        proxy = [[YSKeyboardMovingProxy alloc] init];
    }
    return (YSKeyboardMoving*)proxy;
}


+ (instancetype)appearanceWhenContainedIn:(Class <UIAppearanceContainer>)ContainerClass, ...
{
    return [self appearance];
}


@end


@implementation UIView(YSTextInputKeyboard)

+(void)load
{
    //替换掉原来的三个函数的默认实现。
    
    
    
    GYS_defaultTextFieldBecomeFirstResponder = (GYS_LPFNFirstResponder)class_replaceMethod([UITextField class], @selector(becomeFirstResponder), (IMP)&YSTextFieldBecomeFirstResponder, "@:");
    GYS_defaultTextFieldResignFirstResponder = (GYS_LPFNFirstResponder)class_replaceMethod([UITextField class], @selector(resignFirstResponder), (IMP)&YSTextFieldResignFirstResponder, "@:");
    
    GYS_defaultTextViewBecomeFirstResponder = (GYS_LPFNFirstResponder)class_replaceMethod([UITextView class], @selector(becomeFirstResponder), (IMP)&YSTextViewBecomeFirstResponder, "@:");
    GYS_defaultTextViewResignFirstResponder = (GYS_LPFNFirstResponder)class_replaceMethod([UITextView class], @selector(resignFirstResponder), (IMP)&YSTextViewResignFirstResponder, "@:");
    
    GYS_defaultViewDidMoveToSuperview = (GYS_LPFNDidMoveToSuperview)class_replaceMethod([UIView class], @selector(didMoveToSuperview), (IMP)&YSViewDidMoveToSuperview, "@:");
    
    
}


-(UITextField*)findSearchBarTextField
{
    if ([self isKindOfClass:[UITextField class]])
        return (UITextField*)self;
    
    for (UIView *sbv in self.subviews)
    {
        UITextField *retv = [sbv findSearchBarTextField];
        if (retv != nil)
            return retv;
    }
    
    return nil;
}


-(YSKeyboardMoving*)kbMoving
{
    YSKeyboardMoving *kbMoving = objc_getAssociatedObject(self, ASSOCIATEDOBJECT_KEY_YSTEXTINPUTKEYBOARD_MOVING);
    if (kbMoving == nil)
    {
        kbMoving = [[YSKeyboardMoving alloc] initWithOwner:self];
        objc_setAssociatedObject(self, ASSOCIATEDOBJECT_KEY_YSTEXTINPUTKEYBOARD_MOVING, kbMoving, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    return kbMoving;
}

@end

