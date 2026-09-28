<!-- markdownlint-disable MD013 MD033 MD060 -->

# flutter_adaptive_sidebar

![Package][pubdev-package]
![Likes][pubdev-likes]
![Points][pubdev-points]

EN / [中文](README_zh.md)

Material and Cupertino sidebars driven by a shared controller.

The package handles sidebar presentation and state, while your app controls the
responsive layout. You decide when to show the sidebar and when to display the
content on its own.

## Features

- Material and Cupertino sidebar styles
- Shared selection, expansion, and width state
- Built-in primary and auxiliary navigation lists
- Custom content, item styles, tooltips, and action labels
- Resizable sidebars and an optional Cupertino collapsed bar
- Window-control obstruction insets and RTL support

## See it in action

| Material                                                                    | Cupertino                                                                                                                                                                                                                         |
| --------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| ![Material sidebar expanding and collapsing](screenshots/material-sidebar.webp) | **Standard**<br>![Cupertino sidebar expanding and collapsing](screenshots/cupertino-sidebar.webp)<br><br><details><summary><strong>Edge · light</strong></summary><br><img src="screenshots/cupertino-edge-light.webp" alt="Cupertino edge sidebar expanding from its default collapsed state"></details> |

## Getting started

Add the package:

```shell
flutter pub add flutter_adaptive_sidebar
```

Use the same controller with either sidebar. The `content` parameter accepts any
widget. For a ready-made navigation list, use `MaterialSidebarNavigation` or
`CupertinoSidebarNavigation`; both support destinations pinned to the bottom.
Their row widgets are `MaterialWideNavigationRailButton` and
`CupertinoSidebarDestination`, respectively.

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

Use the controller to select a destination or toggle the sidebar:

```dart
controller.select(const SidebarPrimarySelection(0));
controller.toggleExpanded();
```

Dispose the controller when it is no longer needed. For responsive layouts and
additional configuration, see the [example app](example/lib/main.dart).

`CupertinoSidebar.edge` uses a neutral light/dark fill tuned to the iPadOS 27
sidebar. Pass `backgroundColor` to override the surface with either a regular
`Color` or a `CupertinoDynamicColor`; transparent colors retain backdrop blur.

## More examples

<details>
<summary><strong>Explore the example app</strong></summary>

```shell
cd example
fvm flutter run
```

The example covers responsive layouts, Material and Cupertino styles, custom
navigation content, collapsed bars, and window-control obstruction insets.

</details>

## Development

<details>
<summary><strong>Local checks</strong></summary>

```shell
# Format, analyze, and test the package and example application.
make check
```

</details>

## Donate

[!["Buy Me A Coffee"][buymeacoffee-badge]](https://www.buymeacoffee.com/d49cb87qgww)
[![Alipay][alipay-badge]][alipay-addr]
[![WechatPay][wechat-badge]][wechat-addr]

[![ETH][eth-badge]][eth-addr]
[![BTC][btc-badge]][btc-addr]

## License

This project is licensed under the MIT License.
See [LICENSE](LICENSE) for the full license text.

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
