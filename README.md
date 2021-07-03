# CJSkin 

### 使用说明

```objc
pod  'CJSkin'  #pod导入

//导入头文件即可
#import "CJSkin.h"
```

#### 静态换肤

```objc
UIButton *button = [UIButton new];
button.backgroundColor = SkinColor(@"背景色");
[button setImage:SkinImage(@"按钮") forState:UIControlStateNormal];
button.titleLabel.font = SkinFont(@"标题");
```

#### 动态换肤

- 方法转发

  ```objc
  UIButton *button = [UIButton new];
      [button CJSkinInvokeMethodForSelector:@selector(setBackgroundColor:) withArguments:@[SkinColorTool(@"背景色")]];
      [button CJSkinInvokeMethodForSelector:@selector(setImage:forState:) withArguments:@[SkinImageTool(@"按钮"),@(UIControlStateNormal)]];
      [button.titleLabel CJSkinInvokeMethodForSelector:@selector(setFont:) withArguments:@[SkinFontTool(@"标题")]];
  ```

- 换肤block

  ```objc
  //换肤设置示例
  UIButton *button = [UIButton new];
  button.skinChangeBlock = ^(UIButton *weakSelf) {
      weakSelf.backgroundColor = SkinColor(@"背景色");
      [weakSelf setImage:SkinImage(@"按钮") forState:UIControlStateNormal];
      [weakSelf setImage:SkinImage(@"按钮高亮") forState:UIControlStateHighlighted];
  };
  ```

### 组件模块说明

- **CJSkin** 皮肤包信息管理类，可获取当前皮肤包信息、更换皮肤包、删除指定皮肤包、下载并更新皮肤包（下载的json数据结构参照 CJSkin.plist 文件说明）等功能

- **CJSkinTool** 获取皮肤资源工具类，换肤所需的颜色、图片、字体等只能通过该类转换获取，其中提供了丰富的便捷获取资源方法

- **NSObject+CJSkin** 换肤组件核心类，调用`-CJSkinInvokeMethodForSelector: withArguments:` 实现动态换肤

- **UIKit+CJSkin** 常用UIKit 控件便捷设置换肤方法，若该分类下的方法不能满足，请使用`- CJSkinInvokeMethodForSelector: withArguments:`的方式设置属性

  

###CJSkin概述

CJSkin换肤组件包含UI元素样式的颜色、图片、字体切换。支持动态换肤（换肤后即刻生效），以及静态换肤（需页面重载、APP重启）。

* 换肤流程

  ![换肤流程](https://lele8446infoq.oss-cn-shenzhen.aliyuncs.com/cjskin/%E6%8D%A2%E8%82%A4%E6%B5%81%E7%A8%8B1.jpg)

* 资源管理

  资源管理采用plist文件来记录所有换肤资源的配置信息，plist文件其实就是一个字典文件，该文件的数据结构分为三级，最外层**字典1**的`key`为皮肤包名，值为`NSDictionary`类型的**皮肤包字典2**；**皮肤包字典2**内包含三个固定key：`Color`、`Image`、`Font`，分别对应颜色图片字体三种皮肤资源，它们的值同样是字典称它为**元素字典3**；不同皮肤包下**元素字典3**的key值保持相同，只是对应值不同，以颜色为例：不同皮肤包的颜色分类下都含有**`导航背景色`**，并对应各自不同的颜色色值。详情见下图：

  ![CJSkin.plist](https://lele8446infoq.oss-cn-shenzhen.aliyuncs.com/cjskin/CJSkin.png)

  ![换肤资源管理](https://lele8446infoq.oss-cn-shenzhen.aliyuncs.com/cjskin/%E6%8D%A2%E8%82%A4%E8%B5%84%E6%BA%90%E7%AE%A1%E7%90%862.jpg)