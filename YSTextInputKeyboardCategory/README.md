# YSTextInputKeyboardCategory

UITextField,UITextView keyboard auto hidden and view auto moving

## Overview
  众所周知，iOS的UITextField,UITextView这两个控件在获得焦点时键盘会弹出，并且当这两个控件在屏幕的下方时有可能键盘会遮挡住视图，因此我们要
  负责编码让控件失去焦点后键盘隐藏，以及让视图进行一定范围的移动。有了YSTextInputKeyboardCategory这个UIView的分类后，这两个控件的键盘
  隐藏和自动移动功能都不再需要编码了。！！！你唯一要做的就是把UIView+YSTextInputKeyboard.h和UIView+YSTextInputKeyboard.m这两个文件加入到你的
  工程中，什么也不要做。问题解决！！！
## Function
  这个分类默认扩展了UIView的一个只读属性kbMoving，这个属性可以可以设置键盘弹出并遮挡住视图时哪个视图会往上移动，并且移动多少值。系统默认设置
  为当视图遮挡时其父视图往上移动，并且默认的偏移量是50.
  您也可以实现自定义视图的键盘遮挡和移动机制，具体参考类定义头文件中的描述。
  
  
  
  
  
