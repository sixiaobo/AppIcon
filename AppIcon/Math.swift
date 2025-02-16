//
//  Math.swift
//  FlowChart
//
//  Created by sixiaobo on 2019/3/18.
//  Copyright © 2019年 sixiaobo. All rights reserved.
//

import Foundation
#if !targetEnvironment(macCatalyst)
import GLKit
#endif

class Math {
    /**
     * 直线与直线的交点
     */
    class func line_linePoints(line0:[CGPoint], line1:[CGPoint]) -> CGPoint? {
        let boola = line0[0].x - line0[1].x == 0
        let boolb = line1[0].x - line1[1].x == 0
        if boola && boolb {  //y轴平行
            return nil
        }
        
        if line0[0].y - line0[1].y == 0 {  //x轴平行
            if line1[0].y - line1[1].y == 0 {
                return nil
            }
        }
        
        var (a0, a1, c0, c1):(CGFloat, CGFloat, CGFloat, CGFloat) = (0, 0, 0, 0)
        
        if !boola {
            a0 = (line0[1].y - line0[0].y)/(line0[1].x - line0[0].x)
            c0 = line0[0].y - a0 * line0[0].x
        }
        
        if !boolb {
            a1 = (line1[1].y - line1[0].y)/(line1[1].x - line1[0].x)
            c1 = line1[0].y - a1 * line1[0].x
        }
        
        if boola {
            let x = line0[0].x
            let y = a1 * x + c1
            return CGPoint.init(x: x, y: y)
        }
        
        if boolb {
            let x = line1[0].x
            let y = a0 * x + c0
            return CGPoint.init(x: x, y: y)
        }
        
        if a0 == a1 {  //斜率相等平行
            return nil
        }
        
        let x = (c1 - c0)/(a0 - a1)
        let y = a0 * x + c0
        return CGPoint.init(x: x, y: y)
    }
    
    
    /**
     * 直线与线段的交点
     */
    class func line_limitLinePoints(line:[CGPoint], limLine:[CGPoint]) -> CGPoint? {
        if let p = line_linePoints(line0: line, line1: limLine) {
            if p.x < limLine[0].x && p.x < limLine[1].x {
                return nil
            }
            if p.x > limLine[0].x && p.x > limLine[1].x {
                return nil
            }
            if p.y < limLine[0].y && p.y < limLine[1].y {
                return nil
            }
            if p.y > limLine[0].y && p.y > limLine[1].y {
                return nil
            }
            return p
        }
        return nil
    }
    
    
    /**
     * 点与直线的垂心
     */
    class func chuiXing(point:CGPoint, line:(CGPoint, CGPoint)) -> CGPoint {
        var a0:CGFloat!
        var c0:CGFloat!
        
        var a1:CGFloat!
        var c1:CGFloat!
        
        if line.0.x != line.1.x {
            a0 = (line.0.y - line.1.y)/(line.0.x - line.1.x)
            if a0 != 0 {
                a1 = -1/a0
            }
        } else {
            if line.0.y != line.1.y {
                a1 = (line.0.x - line.1.x)/(line.0.y - line.1.y)
            }
        }
        
        if let a0 = a0 {
            c0 = line.0.y - a0 * line.0.x
        } else {
            //直线方程为 y = line.0.x = line.1.x
            return CGPoint.init(x: line.0.x, y: point.y)
        }
        if let a1 = a1 {
            c1 = point.y - a1 * point.x
        } else {
            return CGPoint.init(x: point.x, y: line.0.y)
        }
        let x = (c1 - c0)/(a0 - a1)
        let y = a0 * x + c0
        return CGPoint.init(x: x, y: y)
    }
    
    /**
     * 点与线段最近距离, 垂心
     * 需考虑垂心在线段之外的情况
     */
    class func minDistance(point:CGPoint, line:(CGPoint, CGPoint)) -> (CGFloat, CGPoint) {
        let p = chuiXing(point: point, line: line)
        var dist:CGFloat = 30000
        if (p.x > line.0.x && p.x < line.1.x) || (p.x < line.0.x && p.x > line.1.x) {
            dist = p.dist(point)
        } else {
            if p.x < line.0.x && p.x < line.1.x  {
                if line.0.x < line.1.x {
                    dist = point.dist(line.0)
                } else {
                    dist = point.dist(line.1)
                }
            } else if p.x > line.0.x && p.x > line.1.x {
                if line.0.x < line.1.x {
                    dist = point.dist(line.1)
                } else {
                    dist = point.dist(line.0)
                }
            }
        }
        if line.0.x == line.1.x {
            if (p.y >= line.0.y && p.y <= line.1.y) || (p.y >= line.1.y && p.y <= line.0.y) {
                dist = point.dist(p)
            }
        }
        return (dist, p)
    }
    
    /**
     * 动态箭头
     * 计算两点确定的线段 在第一个点 off 处为垂心，经过的垂线左右off 处两点
     */
    class func chuiPoints(points:(CGPoint, CGPoint), off:CGFloat) -> (CGPoint, CGPoint) {
        let scale = off/points.0.dist(points.1)
        let p = CGPoint.init(x: points.0.x + (points.1.x - points.0.x) * scale,
                             y: points.0.y + (points.1.y - points.0.y) * scale)
        let vec = CGPoint(x:points.0.x - p.x, y:points.0.y - p.y)
        var Tx:CGFloat!
        var Ty:CGFloat!
        
        let pOff = off * 0.6
        if vec.y != 0 {
            let n = 1 + (vec.x * vec.x) / (vec.y * vec.y)
            Tx = pOff/(pow(n, 0.5))
            Ty = Tx * (vec.x / vec.y)
        } else if vec.x != 0 {
            let n = 1 + vec.y * vec.y / (vec.x * vec.x)
            Ty = pOff/(pow(n, 0.5))
            Tx = Ty * (vec.y / vec.x)
        }
        let x = Tx + p.x
        let y = -Ty + p.y
        
        let x1 = -Tx + p.x
        let y1 = Ty + p.y
        
        return (CGPoint.init(x: x, y: y),
                CGPoint.init(x: x1, y: y1))
    }
    
    /**
     * 点关于直线的对称点
     */
    @objc class func symPoint(point:CGPoint, line:[CGPoint]) -> CGPoint {
        let xin = chuiXing(point: point, line: (line[0], line[1]))
        return CGPoint.init(x: 2 * xin.x - point.x, y: 2 * xin.y - point.y)
    }
    
    /**
     * 线段的比例点
     */
    class func scalePoint(scale:CGFloat, start:CGPoint, end:CGPoint) -> CGPoint {
        let xsp = end.x - start.x
        let ysp = end.y - start.y
        return CGPoint.init(x: start.x + xsp * scale, y: start.y + ysp * scale)
    }
}

extension Math {
    /**
     *  根据偏转角求出圆环上的坐标, 以顶竖直为基准
     */
    class func arcCoord(cent:CGPoint, r:CGFloat, angle:CGFloat) -> CGPoint {
        let y = cent.y - r * cos(angle)
        let x = cent.x + r * sin(angle)
        return CGPoint(x: x, y: y)
    }
    
    /**
     * 根据圆心以外的坐标求出偏转角，以顶竖直为基准
     */
    class func arcAngle(cood:CGPoint, cent:CGPoint, r:CGFloat) -> CGFloat {
        var p = cent
        p.y -= r
        var angle = cood.angle(p, cent: cent)
        if cood.x - cent.x < 0 {
            angle = .pi * 2 - angle
        }
        return angle
    }
    
}



extension CGPoint {
    func dist(_ another:CGPoint) -> CGFloat {
        return pow(pow(x - another.x, 2.0) + pow(y - another.y, 2.0), 0.5)
    }
    
    func rota(angle:Float, radians:Float, cent:CGPoint) -> CGPoint {
        #if !targetEnvironment(macCatalyst)
        var mat = GLKMatrix4MakeTranslation(Float(-cent.x), Float(-cent.y), 0)
        mat = GLKMatrix4Multiply(GLKMatrix4MakeRotation(radians, 0, 0, 1), mat)
        mat = GLKMatrix4Multiply(GLKMatrix4MakeTranslation(Float(cent.x), Float(cent.y), 0), mat)
        let vec = GLKVector3.init(v: (Float(x), Float(y), 0))
        let v = GLKMatrix4MultiplyVector3WithTranslation(mat, vec)
        return CGPoint.init(x: CGFloat(v.x), y: CGFloat(v.y))
        #else
        return CGPoint.zero
        #endif
    }
    
    /**
     * 环形辐射
     */
    func radiate(num:Int, cent:CGPoint) -> [CGPoint] {
        let step = Float.pi/Float(num)
        let rad = Float(self.dist(cent))
        var points:[CGPoint] = []
        for i in 0...num - 1 {
            points.append(rota(angle: Float(i) * step, radians: rad, cent: cent))
        }
        return points
    }
}

extension CGPoint {
    func angle(_ another:CGPoint, cent:CGPoint) -> CGFloat {
        let p0 = another.trs(loc: cent)
        let p1 = trs(loc: cent)
        let dot = p0.x * p1.x + p0.y * p1.y
        let value = dot/(p0.dist(CGPoint.zero) * p1.dist(CGPoint.zero))
        return acos(value)
    }
    
    func absoluteAngle(another:CGPoint) -> CGFloat {
        let p0 = another
        let p1 = self
        let dist1 = p0.dist(CGPoint.zero)
        let dist2 = p1.dist(CGPoint.zero)
        if dist1 == 0 || dist2 == 0 {
            return 0
        }
        let dot = p0.x * p1.x + p0.y * p1.y
        let value = dot/(dist1 * dist2)
        if value >= 0 && value <= 1 {
            return acos(value)
        }
        return 0
    }
    
    /**
     * 两个二维平面向量的旋转角，依据行列式算出向量积，即得旋转轴
     */
    func trsAngle(v:CGPoint) -> CGFloat {
        #if !targetEnvironment(macCatalyst)
        let axle = GLKVector3CrossProduct(.init(v: (Float(x), Float(y), 0)), .init(v: (Float(v.x), Float(v.y), 0)))
        if axle.z == 0 {
            return 0
        }
        let angle = self.absoluteAngle(another: v)
        if axle.z < 0 {
            return -angle
        }
        return angle
        #endif
        
        //return .zero
    }
    
    //两点间trs
    func trs(loc:CGPoint) -> CGPoint {
        return CGPoint.init(x: self.x - loc.x, y: self.y - loc.y)
    }
    
}




/*
 
 let t0 = preLoc.trs(loc: cent)
 let t1 = loc.trs(loc: cent)
 let step = t0.absoluteAngle(another: t1)
 let axle = GLKVector3CrossProduct(.init(v: (Float(t0.x), Float(t0.y), 0)), .init(v: (Float(t1.x), Float(t1.y), 0)))
 if axle.z == 0 {
     preLoc = nil
     return
 }
 switch loopType {
 case .none:
     if axle.z > 0 {
         trsAngle += step
     } else {
         trsAngle -= step
     }
 
 
 */
