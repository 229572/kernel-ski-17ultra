# ski-17ultra

**GKI 6.12 + KernelSU-Next + Droidspaces** 内核，专为 **小米 17 Ultra（popsicle / SM8850）** 构建。

## 设备信息

| 项目 | 值 |
|------|-----|
| 机型 | Xiaomi 17 Ultra (popsicle) |
| SoC | Snapdragon 8 Elite Gen 5 (SM8850) |
| Android | 16 / HyperOS |
| 内核基线 | GKI 6.12 (AOSP) |
| KernelSU | [KernelSU-Next](https://github.com/KernelSU-Next/KernelSU-Next) |
| 容器支持 | [Droidspaces-OSS](https://github.com/ravindu644/Droidspaces-OSS) |

## 功能

- ✅ KernelSU-Next root 管理
- ✅ Droidspaces Linux 容器支持（sysvipc kABI 修复）
- ✅ HMBird 框架绕过（保留完整 CPU/GPU 性能）
- 🔲 SUSFS（预留，首阶段禁用，避免与 Droidspaces 挂载冲突）

## 构建

在 **Actions** 页面手动触发 `🏗️ 内核构建` 工作流，参数说明：

| 参数 | 说明 | 默认 |
|------|------|------|
| `ksu_variant` | KernelSU 变体 | Next |
| `enable_droidspaces` | 启用容器支持 | true |
| `enable_susfs` | 启用 SUSFS | false |
| `sub_level` | 单版本调试（空=全矩阵） | 空 |

## 参考来源

- [ravindu644/Droidspaces-OSS](https://github.com/ravindu644/Droidspaces-OSS) — sysvipc kABI 修复补丁
- [WildKernels/kernel_patches](https://github.com/WildKernels/kernel_patches) — 通用优化补丁
- [Goldzxcbug/Droidspaces_Kernel_patch](https://github.com/Goldzxcbug/Droidspaces_Kernel_patch) — Droidspaces 参考实现