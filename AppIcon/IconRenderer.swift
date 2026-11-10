import UIKit

enum IconDrawingStyle: String, CaseIterable, Identifiable {
    case starTap
    case rectangleHand
    case handTap
    case rectangleGroup

    var id: Self { self }

    var name: String {
        switch self {
        case .starTap:
            "蓝绿星形点按"
        case .rectangleHand:
            "靛蓝矩形手势"
        case .handTap:
            "靛蓝轻触手势"
        case .rectangleGroup:
            "靛蓝矩形组"
        }
    }
}

struct IconRenderer {
    private static let bottomDashedLineYRatio: CGFloat = 0.80

    func generateIcon(for style: IconDrawingStyle, size: CGSize = CGSize(width: 1024, height: 1024)) -> UIImage {
        switch style {
        case .starTap:
            generateGradientSquareImage(size: size)
        case .rectangleHand:
            generateIndigoRectangleHandIcon(size: size)
        case .handTap:
            generateIndigoHandTapIcon(size: size)
        case .rectangleGroup:
            generateIndigoIcon(
                size: size,
                symbolName: "rectangle.3.group.fill",
                maximumSizeRatio: CGSize(width: 0.50, height: 0.50),
                verticalOffsetRatio: Self.bottomDashedLineYRatio / 2 - 0.5,
                showsBottomLines: true
            )
        }
    }

    private func generateGradientSquareImage(size: CGSize) -> UIImage {
        // 创建一个 UIGraphicsImageRenderer 对象来绘制图像
        let fm = UIGraphicsImageRendererFormat.init()
        fm.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: fm)

        // 使用 CGContext 绘制图像
        let image = renderer.image { context in
            // 获取当前绘图上下文
            let context = context.cgContext

            // 创建渐变
            let colors = [UIColor.systemTeal.cgColor, UIColor.systemBlue.cgColor]
            let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: colors as CFArray, locations: [0, 1])!

            // 定义渐变的开始点和结束点
            let startPoint = CGPoint(x: 0, y: 0)
            let endPoint = CGPoint(x: size.width, y: size.height)

            // 在图形上下文中填充渐变
            context.saveGState()
            context.addRect(CGRect(origin: .zero, size: size))
            context.clip()
            context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: [])
            context.restoreGState()

            drawIcon(ctx: context, size: size)

        }
        return image
    }

    /// 绘制以 systemIndigo 为主色、带左右贝塞尔曲线的 APP 图标。
    private func generateIndigoRectangleHandIcon(size: CGSize) -> UIImage {
        generateIndigoIcon(
            size: size,
            symbolName: "rectangle.and.hand.point.up.left.fill",
            maximumSizeRatio: CGSize(width: 0.40, height: 0.35),
            verticalOffsetRatio: 0.04
        )
    }

    /// 使用相同背景样式绘制 hand.tap.fill 图标。
    private func generateIndigoHandTapIcon(size: CGSize) -> UIImage {
        generateIndigoIcon(
            size: size,
            symbolName: "hand.point.up.braille.fill",//"hand.tap.fill",
            maximumSizeRatio: CGSize(width: 0.5 * 0.46/0.50, height: 0.5),
            verticalOffsetRatio: 0
        )
    }

    private func generateIndigoIcon(
        size: CGSize,
        symbolName: String,
        maximumSizeRatio: CGSize,
        verticalOffsetRatio: CGFloat,
        showsBottomLines: Bool = false
    ) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: size, format: format)

        return renderer.image { rendererContext in
            let ctx = rendererContext.cgContext
            let colors = [
                UIColor(red: 0.53, green: 0.52, blue: 0.90, alpha: 1).cgColor,
                UIColor.systemIndigo.cgColor,
                UIColor(red: 0.20, green: 0.19, blue: 0.56, alpha: 1).cgColor
            ]
            let locations: [CGFloat] = [0, 0.52, 1]

            if let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: colors as CFArray,
                locations: locations
            ) {
                ctx.drawLinearGradient(
                    gradient,
                    start: .zero,
                    end: CGPoint(x: size.width, y: size.height),
                    options: []
                )
            }

            drawIndigoIcon(
                ctx: ctx,
                size: size,
                symbolName: symbolName,
                maximumSizeRatio: maximumSizeRatio,
                verticalOffsetRatio: verticalOffsetRatio,
                showsBottomLines: showsBottomLines
            )
        }
    }

    private func drawIndigoIcon(
        ctx: CGContext,
        size: CGSize,
        symbolName: String,
        maximumSizeRatio: CGSize,
        verticalOffsetRatio: CGFloat,
        showsBottomLines: Bool = false
    ) {
        let width = size.width
        let height = size.height
        let lineWidth = min(width, height) * 0.029

        ctx.saveGState()
        ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.88).cgColor)
        ctx.setLineWidth(lineWidth)

        if showsBottomLines {
            drawBottomLines(ctx: ctx, size: size, dashedLineWidth: lineWidth)
        } else {
            ctx.setLineCap(.round)

            // 左侧向内弯的三次贝塞尔曲线。
            addVerticallySymmetricBezierCurve(
                ctx: ctx,
                size: size,
                endX: -width * 0.03,
                controlX: width * 0.29
            )
            ctx.strokePath()

            // 右侧向内弯的三次贝塞尔曲线。
            addVerticallySymmetricBezierCurve(
                ctx: ctx,
                size: size,
                endX: width * 1.03,
                controlX: width * 0.72
            )
            ctx.strokePath()
        }
        ctx.restoreGState()

        let configuration = UIImage.SymbolConfiguration(
            pointSize: min(width, height) * 0.46,
            weight: .black
        )
        guard let symbol = UIImage(
            systemName: symbolName,
            withConfiguration: configuration
        )?.withTintColor(UIColor.white.withAlphaComponent(0.92), renderingMode: .alwaysOriginal) else {
            return
        }

        let maximumSize = CGSize(
            width: width * maximumSizeRatio.width,
            height: height * maximumSizeRatio.height
        )
        let scale = min(maximumSize.width / symbol.size.width, maximumSize.height / symbol.size.height)
        let symbolSize = CGSize(width: symbol.size.width * scale, height: symbol.size.height * scale)
        let symbolRect = CGRect(
            x: (width - symbolSize.width) / 2,
            y: (height - symbolSize.height) / 2 + height * verticalOffsetRatio,
            width: symbolSize.width,
            height: symbolSize.height
        )
        symbol.draw(in: symbolRect)
    }

    private func drawBottomLines(ctx: CGContext, size: CGSize, dashedLineWidth: CGFloat) {
        let dashCount: CGFloat = 5
        let gapRatio: CGFloat = 0.25
        let dashLength = size.width / (dashCount + (dashCount - 1) * gapRatio)
        let gapLength = dashLength * gapRatio
        let dashedLineY = size.height * Self.bottomDashedLineYRatio

        ctx.setLineCap(.butt)
        ctx.setLineDash(phase: 0, lengths: [dashLength, gapLength])
        ctx.move(to: CGPoint(x: 0, y: dashedLineY))
        ctx.addLine(to: CGPoint(x: size.width, y: dashedLineY))
        ctx.strokePath()

        let solidLineY = (dashedLineY + size.height) / 2
        ctx.setLineDash(phase: 0, lengths: [])
        ctx.setLineWidth(dashedLineWidth / 2)
        ctx.move(to: CGPoint(x: 0, y: solidLineY))
        ctx.addLine(to: CGPoint(x: size.width, y: solidLineY))
        ctx.strokePath()
    }

    private func addVerticallySymmetricBezierCurve(
        ctx: CGContext,
        size: CGSize,
        endX: CGFloat,
        controlX: CGFloat
    ) {
        let centerY = size.height / 2
        let endOffset = size.height * 0.58
        let controlOffset = size.height * 0.23

        ctx.move(to: CGPoint(x: endX, y: centerY - endOffset))
        ctx.addCurve(
            to: CGPoint(x: endX, y: centerY + endOffset),
            control1: CGPoint(x: controlX, y: centerY - controlOffset),
            control2: CGPoint(x: controlX, y: centerY + controlOffset)
        )
    }

    private func drawIcon(ctx:CGContext, size:CGSize) {
        let ps:CGFloat = size.width * 1/1.8
        let iconRect:CGRect = .init(x: size.width * 1/8, y: size.height * 1/8, width: ps, height: ps)
        let icon = UIImage.init(systemName: "star", withConfiguration: UIImage.SymbolConfiguration.init(pointSize: ps))?.withTintColor(UIColor.white, renderingMode: .alwaysOriginal)
        icon?.draw(in: iconRect)

        let hs:CGFloat = ps * 1/2
        let hrect:CGRect = .init(x: iconRect.maxX - size.width * 1/16, y: iconRect.maxY - size.width * 1/16, width: hs, height: hs)
        let hicon = UIImage.init(systemName: "hand.point.up.left.fill", withConfiguration: UIImage.SymbolConfiguration.init(pointSize: hs))?.withTintColor(UIColor.white.withAlphaComponent(0.9), renderingMode: .alwaysOriginal)
        hicon?.draw(in: hrect)

        //

    }
}
