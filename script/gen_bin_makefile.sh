#!/usr/bin/env bash
# 自动从 Cargo.toml 生成 ./src/bin/Makefile.generated
# 运行： ./gen_bin_makefile.sh
# 依赖: ./source/console.bash

set -e

# 加载颜色与日志函数
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/source/console.bash"

CARGO_TOML="Cargo.toml"
OUTPUT="./src/bin/Makefile.generated"

# mkdir -p ./src/bin
rm -rf ${OUTPUT}
info "开始从 ${CARGO_TOML} 解析 [[bin]] 条目..."

# 提取所有 [[bin]] 名称
BIN_NAMES=$(grep -E '^\[\[bin\]\]' -A 2 "$CARGO_TOML" | grep -E '^name\s*=' | sed -E 's/.*=\s*"([^"]+)".*/\1/')

if [ -z "$BIN_NAMES" ]; then
  warning "未在 Cargo.toml 中找到任何 [[bin]]，跳过生成。"
  exit 0
fi

info "检测到以下可执行 crate:"
for bin in $BIN_NAMES; do
  trace "发现 [[bin]]：${bin}"
done

trace "生成目标 Makefile 路径: ${OUTPUT}"
echo "" > "$OUTPUT"

cat > "$OUTPUT" <<'HEADER'
# 这是自动生成的 riscv 平台 bin 构建规则
# ⚠️ 请勿手动修改！运行 ./gen_bin_makefile.sh 来更新。

.PHONY: rv_all_bin
.PHONY: rv_all_elf
HEADER

# 标记伪目标
echo ".PHONY: \\" >> "$OUTPUT"
for bin in $BIN_NAMES; do
    echo -e "\t rv_${bin} \\" >> "$OUTPUT"
done
echo -e "\n\n" >> "$OUTPUT"

# 生成 all 规则
echo "rv_all_bin: \\" >> "$OUTPUT"
for bin in $BIN_NAMES; do
    echo -e "\t\$(riscv_bin_path)/${bin}.bin \\" >> "$OUTPUT"
done
echo -e "\n\n" >> "$OUTPUT"

echo "rv_all_elf: \\" >> "$OUTPUT"
for bin in $BIN_NAMES; do
    echo -e "\trv_${bin} \\" >> "$OUTPUT"
done
echo -e "\n\n" >> "$OUTPUT"

# 每个 bin 的规则
for bin in $BIN_NAMES; do
cat >> "$OUTPUT" <<RULE
# ------------------------------
# ${bin}
# ------------------------------
\$(riscv_build_artifact_path)/${bin}: ./src/bin/${bin}.rs
	\$(call INFO, "开始构建 riscv 平台的 ${bin}...")
	@\$(CARGO) build \$(riscv_flags) --bin ${bin}
	\$(call INFO, "riscv 平台的 ${bin} 构建完成！请见 \$(riscv_build_artifact_path)/${bin}")

\$(riscv_bin_path)/${bin}.bin: \$(riscv_build_artifact_path)/${bin}
	\$(call INFO, "清除 riscv 平台的 ${bin} 二进制文件元数据以生成 bin 文件...");
	@-mkdir -p  \$(bin_path) >/dev/null 2>/dev/null
	@-mkdir -p  \$(riscv_bin_path) >/dev/null 2>/dev/null
	@rust-objcopy \$(rust_objcopy_bin_flag) \$(riscv_build_artifact_path)/${bin} \$(riscv_bin_path)/${bin}.bin
	\$(call INFO, "清除完成！请见 \$(riscv_bin_path)/${bin}.bin")

\$(riscv_elf_path)/${bin}.elf: \$(riscv_build_artifact_path)/${bin}
	\$(call INFO, "清除 riscv 平台的 ${bin} 二进制文件符号表以生成 elf 文件...");
	@-mkdir -p  \$(elf_path) >/dev/null 2>/dev/null
	@-mkdir -p  \$(riscv_elf_path) >/dev/null 2>/dev/null
	@rust-objcopy \$(rust_objcopy_elf_flag) \$(riscv_build_artifact_path)/${bin} \$(riscv_elf_path)/${bin}.elf
	\$(call INFO, "清除完成！请见 \$(riscv_bin_path)/${bin}.bin")

rv_${bin}: \$(riscv_bin_path)/${bin}.bin \$(riscv_elf_path)/${bin}.elf

RULE
done

info "共生成 $(echo "$BIN_NAMES" | wc -w) 个 [[bin]] 构建规则。"
info "输出文件: ${OUTPUT}"
info "完成生成 Makefile.generated"
