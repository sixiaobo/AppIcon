//
//  ContentView.swift
//  AppIcon
//
//  Created by BoBoBook on 2025/2/11.
//

import SwiftUI

struct ContentView: View {
    @State var image:UIImage?
    @State var text:String = "生成APP图标"
    @State var hasCompress:Bool = false {
        didSet {
            if hasCompress {
                compressText = "已压缩"
            }
        }
    }
    @State var compressText:String = "压缩图标"
    var body: some View {
        VStack {
            if let image = image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 260, height: 260)
                    .cornerRadius(30)
            }
            Button(action: {
                drawIcon()
            }) {
                VStack {
                    Image(systemName: "airplane")
                        .imageScale(.large)
                        .font(.system(size: 30, weight: .regular))
                        .tint(Color.black)
                        .foregroundStyle(.tint)
                        .padding(10)
                    Text(text)
                        .tint(.black)
                        .font(.system(size: 20, weight: .medium))
                }
            }.padding(30)
            Button(action: {
                compressIcon(path: "/Users/bobobook/Documents/512x512@2x.png", newSizes: [
                    .init(width: 60, height: 60),
                    .init(width: 120, height: 120),
                    .init(width: 180, height: 180)
                    
                ])
                
            }) {
                VStack {
                    Text(compressText)
                        .tint(hasCompress ? .green : .black)
                        .font(.system(size: 20, weight: .medium))
                }
            }
        }.onAppear {
            print("apper")
        }
    }
    
    func compressIcon(path:String, newSizes:[CGSize]) {
        do {
            let url = URL.init(filePath: path)
            let data = try Data.init(contentsOf: url)
            guard let image = UIImage.init(data: data) else {
                return
            }
            for (index, newSize) in newSizes.enumerated() {
                UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
                image.draw(in: CGRect(origin: .zero, size: newSize))
                let compressedImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                let turl = URL.init(filePath: "/Users/bobobook/Documents/app_@\(index + 1)x.jpeg")
                if let data = compressedImage?.jpegData(compressionQuality: 1) {
                    try data.write(to: turl)
                }
            }
            hasCompress = true
        } catch {
            
        }
    }
    
    func drawIcon() {
        OperationQueue.init().addOperation {
            let image = generateGradientSquareImage(size: .init(width: 1024, height: 1024))
            do {
                guard let data = image.jpegData(compressionQuality: 1) else {
                    return
                }
                let fm = FileManager.default
                let url = URL.init(filePath: "/Users/bobobook/Documents/Icon")
                try fm.createDirectory(at: url, withIntermediateDirectories: true)
                try data.write(to: url.appendingPathComponent("app.jpeg"))
                OperationQueue.main.addOperation {
                    self.image = image
                    self.text = "刷新APP图标"
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
    }

    func generateGradientSquareImage(size: CGSize) -> UIImage {
        // 创建一个 UIGraphicsImageRenderer 对象来绘制图像
        let fm = UIGraphicsImageRendererFormat.init()
        fm.scale = 1
        let renderer = UIGraphicsImageRenderer(size: size, format: fm)
        
        // 使用 CGContext 绘制图像
        let image = renderer.image { context in
            // 获取当前绘图上下文
            let context = context.cgContext
            
            // 创建渐变
            let colors = [UIColor.gray.cgColor, UIColor.black.cgColor]
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
            
            drawXVision(ctx: context, size: size)
            
        }
        return image
    }
    
    func drawXVision(ctx:CGContext, size:CGSize) {
        let sp:CGFloat = size.width * 1/15
        let c = CGPoint.init(x: size.width/2, y: size.height/2)
        UIColor.white.setFill()
        UIColor.white.setStroke()
        ctx.fillEllipse(in: .init(x: c.x - sp/2, y: c.y - sp/2, width: sp, height: sp))
        ctx.setLineWidth(size.width * 1/200)
        var angle:CGFloat = 0
        while angle <= .pi * 2 {
            let point = Math.arcCoord(cent: c, r: size.width/2 * 1.1/2, angle: angle)
            ctx.move(to: c)
            ctx.addLine(to: point)
            ctx.strokePath()
            
            ctx.fillEllipse(in: .init(x: point.x - sp/2, y: point.y - sp/2, width: sp, height: sp))
            angle += 2 * .pi/8
            
        }
    }
}

#Preview {
    ContentView()
}
