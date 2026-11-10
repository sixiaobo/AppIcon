# AppIcon

在 macOS 上安装 Xcode 后，可直接绘制并保存图标，无需启动应用或模拟器。

```sh
./Scripts/export-icon rectangleGroup
```

使用 `--help` 查看样式，或传入第二个参数指定其他输出目录。默认输出到 `~/Documents`，同名 JPEG 会被替换。

| 相对于输出目录的文件 | 像素尺寸 |
| --- | --- |
| `Icon/app.jpeg` | 1024 × 1024 |
| `Icon/app_60pt@1x.jpeg`、`Icon/app_60pt@2x.jpeg`、`Icon/app_60pt@3x.jpeg` | 60 × 60、120 × 120、180 × 180 |
| `app_@1x.jpeg`、`app_@2x.jpeg`、`app_@3x.jpeg` | 60 × 60、120 × 120、180 × 180 |

最后一组使用主 JPEG 作为缩放来源，与界面上的压缩按钮一致。所有文件都以 JPEG 最高质量编码。
