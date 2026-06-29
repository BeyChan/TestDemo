//
//  ColorExtension.swift
//  PokemonQuizDemo
//
//  Created by MarvinCheng on 2026/6/26.
//  颜色扩展，宝可梦颜色映射 + 项目里用到的一些主题色
//

import SwiftUI

extension Color {

    static func pokemon(_ name: String?) -> Color {
        switch name?.lowercased() {
        case "black":   return Color(red: 0.2, green: 0.2, blue: 0.2)
        case "blue":    return Color(red: 0.53, green: 0.71, blue: 0.9)
        case "brown":   return Color(red: 0.72, green: 0.53, blue: 0.35)
        case "gray":    return Color(red: 0.75, green: 0.75, blue: 0.75)
        case "green":   return Color(red: 0.56, green: 0.80, blue: 0.56)
        case "pink":    return Color(red: 1.0, green: 0.71, blue: 0.76)
        case "purple":  return Color(red: 0.78, green: 0.63, blue: 0.90)
        case "red":     return Color(red: 0.95, green: 0.55, blue: 0.55)
        case "white":   return Color(red: 0.95, green: 0.95, blue: 0.95)
        case "yellow":  return Color(red: 1.0, green: 0.90, blue: 0.45)
        default:        return Color(red: 0.88, green: 0.88, blue: 0.88)
        }
    }

    static let primaryText = Color(UIColor.label)

    static let secondaryText = Color(UIColor.secondaryLabel)

    static let subtleBg = Color(UIColor.tertiarySystemFill)

    static let accent = Color(red: 0.95, green: 0.22, blue: 0.22)

    static let accentSubtle = Color(UIColor { tc in
        let alpha: CGFloat = tc.userInterfaceStyle == .dark ? 0.20 : 0.12
        return UIColor(red: 0.95, green: 0.22, blue: 0.22, alpha: alpha)
    })

    static let accentBorder = Color(UIColor { tc in
        let alpha: CGFloat = tc.userInterfaceStyle == .dark ? 0.40 : 0.30
        return UIColor(red: 0.95, green: 0.22, blue: 0.22, alpha: alpha)
    })

    static let pillBg = Color(UIColor { tc in
        tc.userInterfaceStyle == .dark
            ? UIColor(white: 1.0, alpha: 0.15)
            : UIColor(white: 1.0, alpha: 0.6)
    })

    static let pillText = Color(UIColor.label)

    static let badgeBg = Color(UIColor { tc in
        let alpha: CGFloat = tc.userInterfaceStyle == .dark ? 0.25 : 0.12
        return UIColor(white: 0, alpha: alpha)
    })

    static var random: Color {
        Color(
            red: Double.random(in: 0...1),
            green: Double.random(in: 0...1),
            blue: Double.random(in: 0...1)
        )
    }
}
