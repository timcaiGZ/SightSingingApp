# SightSingingApp 前端交互原型

基于 **v0_design_v2** 的 Next.js 可点击原型，用于验证 UI 与交互，再映射到 iOS SwiftUI。

## 运行

```bash
cd prototype
pnpm install   # 或 npm install
pnpm dev
```

浏览器打开 http://localhost:3000（建议用 Chrome 设备模拟 iPhone 竖屏）。

## 结构

| Tab | 说明 |
|-----|------|
| 练习 | 5 大模块卡片 + Progress Ring，进入统一练习容器 |
| 乐理 | 6 类手风琴 + 知识点详情（含七和弦、五度圈） |
| 测试 | 统计 + 测试列表 + 测试会话 |
| 我的 | 统计、谱式选择、深色模式 |

## 练习交互

- **选择题**：AudioPromptCard → 选项锁定 → 绿/红反馈 →「下一题」
- **键盘输入**（单音辨认）：三列键盘 + 谱面实时渲染
- **视唱**（`*-sing`）：PitchMeter + 按住演唱 + 评分页
- **完成弹层**：10 题后显示正确率、「再来一轮」「返回」

## 规格对照

实现以 [docs/spec-v2.2.md](../docs/spec-v2.2.md) 为准；视觉风格对齐 v0 原型（iOS 蓝 + 卡片布局）。

## 技术栈

Next.js 16 · React 19 · Tailwind CSS 4 · shadcn/ui · Lucide
