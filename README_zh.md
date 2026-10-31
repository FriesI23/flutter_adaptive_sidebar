<!-- markdownlint-disable MD013 MD033 MD060 -->

# flutter_adaptive_sidebar

![Package][pubdev-package]
![Likes][pubdev-likes]
![Points][pubdev-points]

[EN](README.md) / 中文

由同一个控制器驱动的 Material 与 Cupertino 侧边栏。

本包负责侧边栏的呈现与状态管理，响应式布局则交给应用控制。你可以自行决定何时显示
侧边栏，以及窗口在什么尺寸下只显示内容区。

## 功能特点

- Material 与 Cupertino 两种侧边栏样式
- 共享选中项、展开状态和宽度状态
- 内置主导航与辅助导航列表
- 支持自定义内容、导航项样式、提示和操作文案
- 支持拖拽调整宽度和可选的 Cupertino 折叠栏
- 支持窗口控件避让和从右到左布局

## 效果展示

| Material                                                        | Cupertino                                                                                                                                                                                         |
| --------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ![Material 侧边栏展开与折叠动画](screenshots/material-sidebar.webp) | **标准样式**<br>![Cupertino 侧边栏展开与折叠动画](screenshots/cupertino-sidebar.webp)<br><br><details><summary><strong>Edge 样式 · 亮色</strong></summary><br><img src="screenshots/cupertino-edge-light.webp" alt="Cupertino Edge 侧边栏从默认折叠态展开的动画"></details> |

## 开始使用

添加依赖：

```shell
flutter pub add flutter_adaptive_sidebar
```

两种侧边栏可以共用同一个控制器，`content` 参数可接收任意组件。如果需要现成的
导航列表，可以使用 `MaterialSidebarNavigation` 或
`CupertinoSidebarNavigation`；两者都支持固定在底部的导航项。它们对应的行组件
分别是 `MaterialWideNavigationRailButton` 和 `CupertinoSidebarDestination`。

Material Rail 选中后仍显示悬停、焦点和按下反馈。反馈颜色遵循
`NavigationBarThemeData.overlayColor`，默认使用 Material 主题的状态颜色。

```dart
final Widget page = AnimatedBuilder(
  animation: controller,
  builder: (context, _) => useMaterial
      ? Row(
          children: [
            MaterialSidebar(
              controller: controller,
              content: MaterialSidebarNavigation(
                destinations: destinations,
                selection: controller.selection,
                onSelectionChanged: controller.select,
              ),
            ),
            Expanded(child: body),
          ],
        )
      : CupertinoSidebar(
          controller: controller,
          content: CupertinoSidebarNavigation(
            destinations: destinations,
            selection: controller.selection,
            onSelectionChanged: controller.select,
          ),
          child: body,
        ),
);
```

通过控制器选择导航项或切换侧边栏：

```dart
controller.select(const SidebarPrimarySelection(0));
controller.toggleExpanded();
```

不再使用控制器时，请调用 `dispose()`。响应式布局和其他配置可参考
[示例应用](example/lib/main.dart)。

## Cupertino 外观

`CupertinoSidebar.edge` 默认提供贴近 iPadOS 27 Sidebar 的中性亮色与暗色表面。
Edge、Liquid 及折叠栏中的导航项强调色都会跟随
`CupertinoTheme.primaryColor`。

如需统一调整应用内的 Edge 表面，可在 `ThemeData.extensions` 中配置
`CupertinoSidebarThemeData.edgeBackgroundColor`；只调整单个 Sidebar 时，则传入
`backgroundColor`。两种方式都支持动态颜色，透明颜色仍会保留背景模糊效果。
如需按交互状态定制导航项颜色，可使用 `CupertinoSidebarItemStyle`。

## Cupertino 工具栏区域

应用能独立声明顶部安全操作行时，可传入 `CupertinoSidebar.toolbarRegion`：

```dart
toolbarRegion: CupertinoSidebarToolbarRegion(
  bounds: availableToolbarBounds,
  minimumExtent: protectedContentTop,
  maxCollapsedBarWidth: capsuleWidthBudget,
),
```

矩形使用相对于 Sidebar 布局框的物理逻辑像素，不随 RTL 镜像，也不跟随页面路由的绘制变换。
`toolbarGeometry` 继续控制实际操作行和胶囊高度。Toggle 和固定胶囊在该区域内布局；
胶囊保持**窗口居中**，根据区域和可选的宽度上限收窄。应用需在首帧预算中先保留页面
必需的操作按钮。占位立即使用最终接受的宽度上限，不依赖上一帧胶囊测量；导航项可滚动，
胶囊内的 toggle 保持固定。

Inset 样式的面板表面跟随操作行顶部，Edge 表面继续贴窗。面板内容起点不早于原有
Safe Area 保护与 `minimumExtent` 的较大值，并保留导航列表既有间距。页面 MediaQuery
的顶部 padding 和 viewPadding 保持原值，页面 AppBar 仍负责自己的内容保护。

该接口支持 `fixedToolbar` 和独立 toggle。未传入、非有限值、超出布局框、操作区／胶囊
空间不足或使用 `toolbarAnchor` 时，整组恢复原布局。完整展开的面板与操作行的交集也
必须容纳 44 像素 toggle，即使面板当前隐藏；这一判断不随展开动画进度变化。
`SidebarLeadingScope.toolbarRegion` 提供最终接受的区域及有效胶囊宽度上限，拒绝时为
null，方便页面 renderer 同步布局。本包不识别设备型号，也不测量系统遮挡。

## 更多示例

<details>
<summary><strong>运行示例应用</strong></summary>

```shell
cd example
fvm flutter run
```

Apple 平台示例最低支持 iOS 15 和 macOS 12，可使用 Xcode 27 构建。

示例应用包含默认及多种主题色切换、响应式布局、Material 与 Cupertino 样式、
自定义导航内容、折叠栏和窗口控件避让。

</details>

## 开发

<details>
<summary><strong>本地检查</strong></summary>

```shell
# Format, analyze, and test the package and example application.
make check
```

</details>

## 捐赠

[!["Buy Me A Coffee"][buymeacoffee-badge]](https://www.buymeacoffee.com/d49cb87qgww)
[![Alipay][alipay-badge]][alipay-addr]
[![WechatPay][wechat-badge]][wechat-addr]

[![ETH][eth-badge]][eth-addr]
[![BTC][btc-badge]][btc-addr]

## 许可证

本项目基于 MIT License 许可。
完整许可文本见 [LICENSE](LICENSE)。

```text
MIT License

Copyright (c) 2026 Fries_I23

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

[pubdev-package]: https://img.shields.io/pub/v/flutter_adaptive_sidebar.svg
[pubdev-likes]: https://img.shields.io/pub/likes/flutter_adaptive_sidebar?logo=dart
[pubdev-points]: https://img.shields.io/pub/points/flutter_adaptive_sidebar?logo=dart
[buymeacoffee-badge]: https://img.shields.io/badge/Buy_Me_A_Coffee-FFDD00?style=for-the-badge&logo=buy-me-a-coffee&logoColor=black
[alipay-badge]: https://img.shields.io/badge/alipay-00A1E9?style=for-the-badge&logo=alipay&logoColor=white
[alipay-addr]: https://raw.githubusercontent.com/FriesI23/mhabit/main/docs/README/images/donate-alipay.jpg
[wechat-badge]: https://img.shields.io/badge/WeChat-07C160?style=for-the-badge&logo=wechat&logoColor=white
[wechat-addr]: https://raw.githubusercontent.com/FriesI23/mhabit/main/docs/README/images/donate-wechatpay.png
[eth-badge]: https://img.shields.io/badge/Ethereum-3C3C3D?style=for-the-badge&logo=Ethereum&logoColor=white
[eth-addr]: https://etherscan.io/address/0x35FC877Ef0234FbeABc51ad7fC64D9c1bE161f8F
[btc-badge]: https://img.shields.io/badge/Bitcoin-000000?style=for-the-badge&logo=bitcoin&logoColor=white
[btc-addr]: https://blockchair.com/bitcoin/address/bc1qz2vjews2fcscmvmcm5ctv47mj6236x9p26zk49
