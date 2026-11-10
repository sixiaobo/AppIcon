//
//  ContentView.swift
//  AppIcon
//
//  Created by BoBoBook on 2025/2/11.
//

import SwiftUI

struct ContentView: View {
    private static let exportQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        return queue
    }()
    private let iconExporter = IconExporter(
        documentsDirectory: URL(filePath: "/Users/bobobook/Documents", directoryHint: .isDirectory)
    )

    @State var image:UIImage?
    @State var text:String = "生成APP图标"
    @State private var selectedDrawingStyle: IconDrawingStyle = .rectangleHand
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
            drawingStyleCollection
            Spacer(minLength: 0)

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
                compressIcon()
            }) {
                VStack {
                    Text(compressText)
                        .tint(hasCompress ? .green : .black)
                        .font(.system(size: 20, weight: .medium))
                }
            }
            Spacer(minLength: 0)
        }.onAppear {
            print("apper")
        }
    }

    private var drawingStyleCollection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 10) {
                ForEach(IconDrawingStyle.allCases) { style in
                    Button {
                        selectedDrawingStyle = style
                        drawIcon(style: style)
                    } label: {
                        Text(style.name)
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 9)
                            .background(
                                Capsule()
                                    .fill(Color(uiColor: .tertiarySystemBackground))
                            )
                            .overlay {
                                Capsule()
                                    .strokeBorder(
                                        selectedDrawingStyle == style ? Color.accentColor : .clear,
                                        lineWidth: 2
                                    )
                            }
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)
        }
        .fixedSize(horizontal: false, vertical: true)
        .padding(.top, 12)
    }
    
    private func compressIcon() {
        Self.exportQueue.addOperation {
            do {
                try iconExporter.compress()
                OperationQueue.main.addOperation {
                    self.hasCompress = true
                }
            } catch {
                print(error.localizedDescription)
            }
        }
    }

    func drawIcon() {
        drawIcon(style: selectedDrawingStyle)
    }

    private func drawIcon(style drawingStyle: IconDrawingStyle) {
        Self.exportQueue.addOperation {
            let image = IconRenderer().generateIcon(for: drawingStyle)
            do {
                try iconExporter.save(image)
                OperationQueue.main.addOperation {
                    self.image = image
                    self.text = "刷新APP图标"
                }
            } catch {
                print(error.localizedDescription)
            }
        }
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
//
//#Preview {
//    ContentView()
//}
