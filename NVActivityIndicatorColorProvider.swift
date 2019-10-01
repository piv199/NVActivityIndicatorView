//
//  NVActivityIndicatorColorProvider.swift
//  NVActivityIndicatorView
//
//  Created by Oleksii Pyvovarov on 10/1/19.
//

import Foundation

public protocol NVActivityIndicatorColorProvider {
    func activityIndicatorColor(type: NVActivityIndicatorType, size: CGSize, padding: CGFloat) -> UIColor
}

struct UIColorProvider: NVActivityIndicatorColorProvider {
    let color: UIColor
    init(_ color: UIColor) { self.color = color }
    
    func activityIndicatorColor(type: NVActivityIndicatorType, size: CGSize, padding: CGFloat) -> UIColor {
        return color
    }
}

public struct GradientColorProvider: NVActivityIndicatorColorProvider {
    public enum Variant {
        case linear(start: CGPoint, end: CGPoint)
        case radial
    }
    
    public let anchors: [(color: UIColor, location: CGFloat)]
    public let variant: Variant
    public let options: CGGradientDrawingOptions
    
    public init(anchors: [(color: UIColor, location: CGFloat)],
                variant: Variant = .linear(start: .zero, end: .init(x: 1, y: 1)),
                options: CGGradientDrawingOptions = []) {
        self.anchors = anchors
        self.variant = variant
        self.options = options
    }
    
    public func activityIndicatorColor(type: NVActivityIndicatorType, size: CGSize, padding: CGFloat) -> UIColor {
        let indicatorEdge = min(size.width, size.height) - 2 * padding
        
        let colors = anchors.map({$0.0.cgColor}) as CFArray
        let locations = anchors.map({$0.1})
        guard let gradient = CGGradient(colorsSpace: nil, colors: colors, locations: locations) else {
            return .clear
        }
        UIGraphicsBeginImageContext(size)
        defer { UIGraphicsEndImageContext() }
        guard let context = UIGraphicsGetCurrentContext() else {
            return .clear
        }
        switch variant {
        case let .linear(start, end):
            let startPoint = CGPoint(x: start.x * size.width, y: start.y * size.height)
            let endPoint = CGPoint(x: end.x * size.width, y: end.y * size.height)
            context.drawLinearGradient(gradient, start: startPoint, end: endPoint, options: options)
        case .radial:
            let center = CGPoint(x: 0.5, y: 0.5)
            context.drawRadialGradient(gradient, startCenter: center, startRadius: 0, endCenter: center, endRadius: indicatorEdge / 2, options: [])
        }
        guard let pattern = UIGraphicsGetImageFromCurrentImageContext() else {
            return .clear
        }
        return UIColor(patternImage: pattern)
    }
}
