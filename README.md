# CJSkin 

### 使用说明

```objc
pod  'CJSkin'  #pod导入

//导入头文件即可
#import "CJSkin.h"
```

#### 一、静态换肤

```objc
UIButton *button = [UIButton new];
button.backgroundColor = SkinColor(@"背景色");
[button setImage:SkinImage(@"按钮") forState:UIControlStateNormal];
button.titleLabel.font = SkinFont(@"标题");
```

#### 二、动态换肤

- 方法一：使用方法转发

  ```objc
  UIButton *button = [UIButton new];
  [button CJSkinInvokeMethodForSelector:@selector(setBackgroundColor:) withArguments:@[SkinColorTool(@"背景色")]];
  [button CJSkinInvokeMethodForSelector:@selector(setImage:forState:) withArguments:@[SkinImageTool(@"按钮"),@(UIControlStateNormal)]];
  [button.titleLabel CJSkinInvokeMethodForSelector:@selector(setFont:) withArguments:@[SkinFontTool(@"标题")]];
  ```

- 方法二：使用skinChangeBlock

  ```objc
  //换肤设置示例
  UIButton *button = [UIButton new];
  button.skinChangeBlock = ^(UIButton *weakSelf) {
      weakSelf.backgroundColor = SkinColor(@"背景色");
      [weakSelf setImage:SkinImage(@"按钮") forState:UIControlStateNormal];
      [weakSelf setImage:SkinImage(@"按钮高亮") forState:UIControlStateHighlighted];
  };
  ```

#### 三、皮肤资源说明

换肤资源使用 **CJSkin.plist** 文件（文件名固定）来配置管理换肤信息。如下图所示：当前项目的CJSkin.plist文件内记录了default、skin1、skin2三个皮肤包，每个皮肤包内固定包含`Color`、`Image`、`Font`（颜色、图片、字体）三类皮肤元素的信息。

不同皮肤包 **Color** 字典中的key相同值不同：比如default皮肤包中 `导航背景色` 值为0x996666，skin2皮肤包中 `导航背景色` 的值为0x454545。

**Image** 的说明同理，比如default和skin2皮肤包中都有 `顶部图片` ，但分别指向了不同的url；另外不同皮肤包的图片还可以放到各自的default.bundle、skin1.bundle文件夹内，同时在CJSkin.plist中声明图片别名，比如skin1.bundle中包含图片top.png，它在CJSkin.plist的配置为“ `顶部图片 : top.png` ”。

 **Font** 的配置说明也是一样，不同皮肤包的key相同，值为包含Name、Size两个固定key的字典，Name为空则使用系统默认字体，Size表示了字号大小。

![CJSkin.plist](https://lele8446infoq.oss-cn-shenzhen.aliyuncs.com/cjskin/CJSkin.png)

![换肤资源管理](https://lele8446infoq.oss-cn-shenzhen.aliyuncs.com/cjskin/%E6%8D%A2%E8%82%A4%E8%B5%84%E6%BA%90%E7%AE%A1%E7%90%862.jpg)



### 组件模块说明

- **CJSkin** 皮肤包信息管理类，可获取当前皮肤包信息、更换皮肤包、删除指定皮肤包、下载并更新皮肤包（下载的json数据结构参照 CJSkin.plist 文件说明）等功能

- **CJSkinTool** 获取皮肤资源工具类，换肤所需的颜色、图片、字体等只能通过该类转换获取，其中提供了丰富的便捷获取资源方法

- **NSObject+CJSkin** 换肤组件核心类，调用`-CJSkinInvokeMethodForSelector: withArguments:` 实现动态换肤

- **UIKit+CJSkin** 常用UIKit 控件便捷设置换肤方法，若该分类下的方法不能满足，请使用`- CJSkinInvokeMethodForSelector: withArguments:`的方式设置属性

  

### CJSkin换肤流程

![换肤流程](https://lele8446infoq.oss-cn-shenzhen.aliyuncs.com/cjskin/%E6%8D%A2%E8%82%A4%E6%B5%81%E7%A8%8B1.jpg)