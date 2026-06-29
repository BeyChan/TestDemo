//
//  SplashView.swift
//  PokemonQuizDemo
//
//  Created by MarvinCheng on 2026/6/26.
//  首次启动欢迎页，需求说纯文本也行，但加个倒计时比较友好
//

import SwiftUI

struct SplashView: View {
    @Environment(\.l10n) private var S
    var onEnter: () -> Void

    @State private var countdown = 10
    @State private var hasEntered = false

    var body: some View {

        ZStack {
            Color.random
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Text(S.splashTitle)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(S.splashTagline)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.85))
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.2)
                    .padding(.top, 8)

                Spacer()

                Button {
                    enter()
                } label: {
                    Text("\(S.splashWelcome) (\(countdown)s)")
                        .font(.system(size: 18, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 36)
                        .padding(.vertical, 14)
                        .background(
                            Capsule()
                                .fill(Color.white.opacity(0.2))
                                .overlay(Capsule().stroke(Color.white.opacity(0.5), lineWidth: 1.5))
                        )
                }
                .padding(.bottom, 60)
            }
        }
        .task {
            while countdown > 0 {
                try? await Task.sleep(for: .seconds(1))
                countdown -= 1
            }
            enter()
        }
    }

    private func enter() {
        guard !hasEntered else { return }
        hasEntered = true
        print("[Splash] enter app")
        onEnter()
    }
}
