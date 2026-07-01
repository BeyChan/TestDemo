# Pokedex - PokemonQuizDemo

<video src="https://github.com/user-attachments/assets/94004e18-9a10-4453-bdbf-2f08ec0b5e51" controls width="300"></video>

## 技术栈

- Swift 5 / SwiftUI / iOS 18.6+
- Xcode 26
- PokeAPI GraphQL (beta.pokeapi.co)
- Swift Testing (单元测试)

## 项目结构

```
PokemonQuizDemo/
├── PokemonQuizDemoApp.swift
└── PokemonQuiz/
    ├── Models/          # PokemonSpecies, Pokemon 等数据模型
    ├── Network/         # GraphQL 请求封装、查询语句、错误定义
    ├── ViewModels/      # SearchViewModel, DetailViewModel, ViewState
    ├── Views/           # SwiftUI 视图
    ├── L10N/            # 多语言 (中/英)
    └── Utils/           # 语言切换、主题、颜色扩展
```

## 构建运行

1. clone 后用 Xcode 26 打开 `PokemonQuizDemo.xcodeproj`
2. 选 iPhone 17 Pro 模拟器，Cmd+R 跑起来
3. 跑测试：Cmd+U 或 `xcodebuild -scheme PokemonQuizDemo -destination 'platform=iOS Simulator,name=iPhone 17 Pro' test`
