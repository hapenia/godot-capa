# godot-capa

Godot 的基于 Capability 的 Gameplay 系统插件。提供基于 Capability 的调试和辅助工具。


# 什么是 Capability?

Capability 是 Hazelight 工作室在开发《双影奇境》时使用的一种 Gameplay 代码组织模式。

Capabilities可以被视为ECS中System的一个远房表亲，因为两者都负责行为，但Capabilities是用于GameObject-Component结构中的。

更多信息参考这篇 GDC 2025 的演讲：https://schedule.gdconf.com/session/capabilities-coding-all-the-gameplay-for-split-fiction/907193


# 本插件提供什么?

标记为[x]的项为已完成，标记为[ ]的项为计划中的事项。

- [x] Capability 系统在Godot中的基础实现
- [x] Capability 系统的运行时调试器
- [ ] Capability 用于网络游戏的实现和调试工具
