#!/usr/bin/env bash
# scripts/repo_sync_fallback.sh
#
# 在 GitHub Actions 中 repo sync 超时或失败时，
# 回退到清华大学 AOSP 镜像（Tsinghua TUNA AOSP Mirror）直接 git clone。
#
# 用法（在 build.yml 的 "拉取内核源码" 步骤中调用）：
#   source scripts/repo_sync_fallback.sh
#   sync_kernel_source "$KERNEL_ROOT" "${{ inputs.kernel_version }}" "${{ inputs.os_patch_level }}"
#
# 依赖：git, repo（已安装）

set -euo pipefail

# ── 清华 AOSP 镜像 base URL ──────────────────────────────────────────────────
TUNA_BASE="https://mirrors.tuna.tsinghua.edu.cn/git/AOSP"

# ── repo sync（优先）──────────────────────────────────────────────────────────
try_repo_sync() {
  local root="$1"
  local kver="$2"      # e.g. 6.12
  local ospatch="$3"   # e.g. 2026-03

  cd "$root"
  echo ">>> repo init: android${kver}-${ospatch}"
  repo init --depth=1 \
    -u https://android.googlesource.com/kernel/manifest \
    -b "common-android${kver}-${ospatch}" \
    --repo-rev=main

  echo ">>> repo sync..."
  repo sync -c -j$(nproc --all) \
    --no-clone-bundle --no-tags \
    --optimized-fetch --prune
}

# ── git clone 镜像回退 ────────────────────────────────────────────────────────
fallback_clone() {
  local root="$1"
  local kver="$2"
  local ospatch="$3"

  echo "::warning::repo sync 失败，回退到 Tsinghua AOSP 镜像（git clone）"

  # 内核 common 仓库
  COMMON_URL="${TUNA_BASE}/kernel/common"
  echo ">>> git clone common: ${COMMON_URL}"
  git clone --depth=1 \
    --branch "android${kver}-${ospatch}" \
    "$COMMON_URL" \
    "${root}/common" || {
      # 如果精确分支不存在，退而求其次 clone 默认分支
      echo "::warning::分支 android${kver}-${ospatch} 不存在，使用默认分支"
      git clone --depth=1 "$COMMON_URL" "${root}/common"
    }

  # tools/bazel（编译系统依赖）
  echo ">>> git clone bazel tools..."
  git clone --depth=1 \
    "${TUNA_BASE}/kernel/build" \
    "${root}/build" || echo "::warning::build 仓库 clone 失败，继续"

  # prebuilts（编译器预编译工具链）
  echo ">>> git clone prebuilts/clang..."
  git clone --depth=1 \
    "${TUNA_BASE}/platform/prebuilts/clang/host/linux-x86" \
    "${root}/prebuilts/clang/host/linux-x86" || echo "::warning::clang prebuilts clone 失败，将使用系统 clang"
}

# ── 主入口 ─────────────────────────────────────────────────────────────────────
sync_kernel_source() {
  local root="${1:?需要 KERNEL_ROOT 参数}"
  local kver="${2:?需要 kernel_version 参数}"
  local ospatch="${3:?需要 os_patch_level 参数}"

  mkdir -p "$root"

  if try_repo_sync "$root" "$kver" "$ospatch"; then
    echo "repo sync 成功"
    return 0
  fi

  echo "::warning::repo sync 失败，尝试镜像回退..."
  fallback_clone "$root" "$kver" "$ospatch"
  echo "回退完成，请检查 $root/common 是否存在 Makefile"
  ls "${root}/common/Makefile" || {
    echo "::error::内核源码拉取失败，中止构建"
    exit 1
  }
}
