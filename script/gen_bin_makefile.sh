#!/usr/bin/env bash
# 自动从 Cargo.toml 生成 ./src/bin/Makefile.generated
# 运行： ./script/gen_bin_makefile.sh
# 依赖: ./source/console.bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/source/console.bash"

CARGO_TOML="Cargo.toml"
OUTPUT="./src/bin/Makefile.generated"

rm -rf ${OUTPUT}
info "开始从 ${CARGO_TOML} 解析 [[bin]] 条目..."

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
# ==============================================
# ⚙️ 自动生成的 riscv 平台 bin 构建规则
# ⚠️ 请勿手动修改！运行 ./script/gen_bin_makefile.sh 来更新。
# ==============================================

# 可调常量：单个程序的地址偏移步长
OFFSET_UNIT := 0x20000

.PHONY: rv_all_bin rv_all_elf
HEADER

# 标记伪目标
echo ".PHONY: \\" >> "$OUTPUT"
for bin in $BIN_NAMES; do
    echo -e "\trv_${bin} \\" >> "$OUTPUT"
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

# ------------------------------
# 为每个 bin 生成规则
# ------------------------------
for bin in $BIN_NAMES; do
cat >> "$OUTPUT" <<RULE
# ------------------------------
# ${bin}
# ------------------------------
\$(riscv_build_artifact_path)/${bin}: ./src/bin/${bin}.rs
	\$(call INFO, "更新 linker.ld 中的 START_OFFSET 对应 ${bin}...")
	@PREFIX_NUM=\$\$(echo "${bin}" | grep -oE '^[0-9]+'); \\
	if [ -z "\$\$PREFIX_NUM" ]; then PREFIX_NUM=0; fi; \\
	PREFIX_NUM=\$\$((10#\$\$PREFIX_NUM)); \\
	OFFSET_VAL=\$\$((\$(OFFSET_UNIT) * PREFIX_NUM)); \\
	OFFSET_HEX=\$\$(printf "0x%X" "\$\$OFFSET_VAL"); \\
	echo "[MAKEFILE] 更新 linker.ld: START_OFFSET = \$\$OFFSET_HEX (编号 \$\$PREFIX_NUM)"; \\
	if [ -f ./src/riscv/linker_script/linker.ld ]; then \\
		awk -v new_val="\$\$OFFSET_HEX" 'NR==3{sub(/=.*/, "= " new_val ";")} {print}' ./src/riscv/linker_script/linker.ld > ./src/riscv/linker_script/linker.ld.tmp && mv ./src/riscv/linker_script/linker.ld.tmp ./src/riscv/linker_script/linker.ld; \\
	else \\
		echo "[MAKEFILE] ⚠️ 未找到 linker.ld，跳过更新"; \\
	fi
	\$(call INFO, "开始构建 riscv 平台的 ${bin}...")
	@\$(CARGO) build \$(riscv_flags) --bin ${bin}
	\$(call INFO, "riscv 平台的 ${bin} 构建完成！请见 \$(riscv_build_artifact_path)/${bin}")

\$(riscv_bin_path)/${bin}.bin: \$(riscv_build_artifact_path)/${bin}
	\$(call INFO, "清除 riscv 平台的 ${bin} 二进制文件元数据以生成 bin 文件...")
	@-mkdir -p \$(riscv_bin_path) >/dev/null 2>/dev/null
	@rust-objcopy \$(rust_objcopy_bin_flag) \$(riscv_build_artifact_path)/${bin} \$(riscv_bin_path)/${bin}.bin
	\$(call INFO, "清除完成！请见 \$(riscv_bin_path)/${bin}.bin")

\$(riscv_elf_path)/${bin}.elf: \$(riscv_build_artifact_path)/${bin}
	\$(call INFO, "清除 riscv 平台的 ${bin} 二进制文件符号表以生成 elf 文件...")
	@-mkdir -p \$(riscv_elf_path) >/dev/null 2>/dev/null
	@rust-objcopy \$(rust_objcopy_elf_flag) \$(riscv_build_artifact_path)/${bin} \$(riscv_elf_path)/${bin}.elf
	\$(call INFO, "清除完成！请见 \$(riscv_elf_path)/${bin}.elf")

rv_${bin}: \$(riscv_bin_path)/${bin}.bin \$(riscv_elf_path)/${bin}.elf

RULE
done

info "共生成 $(echo "$BIN_NAMES" | wc -w) 个 [[bin]] 构建规则。"
info "输出文件: ${OUTPUT}"
info "✅ 完成生成 Makefile.generated"

