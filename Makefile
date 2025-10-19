SHELL := /bin/bash
.PHONY: clean check
.PHONY: rv_hello_world

COLOR_ANSI_RED := \033[31m
COLOR_ANSI_GREEN := \033[32m
COLOR_ANSI_YELLOW := \033[33m
COLOR_ANSI_BLUE := \033[34m
COLOR_ANSI_PURPLE := \033[35m
COLOR_ANSI_CYAN := \033[36m
COLOR_ANSI_WHITE := \033[37m

COLOR_ANSI_CLEAR := \033[0m

common_dependencies := ./src/share/**

riscv_dependencies := $(common_dependencies) \
					  ./src/riscv/** \
					  ./src/lib.rs

riscv_flags := --release --target riscv64gc-unknown-none-elf

riscv_build_artifact_path := ./target/riscv64gc-unknown-none-elf/release

riscv_bin_path := ./bin/riscv

bin_path := ./bin

rust_objcopy_flag := --strip-all -O binary --gap-fill=0x00

define TRACE
	@echo -e "$(COLOR_ANSI_PURPLE)[MAKEFILE]$(COLOR_ANSI_CLEAR)$(COLOR_ANSI_BLUE)\t[TRACE]\t$(1)$(COLOR_ANSI_CLEAR)"
endef
define INFO
	@echo -e "$(COLOR_ANSI_PURPLE)[MAKEFILE]$(COLOR_ANSI_CLEAR)$(COLOR_ANSI_GREEN)\t[INFO]\t$(1)$(COLOR_ANSI_CLEAR)"
endef
define WARNING
	@echo -e "$(COLOR_ANSI_PURPLE)[MAKEFILE]$(COLOR_ANSI_CLEAR)$(COLOR_ANSI_YELLOW)\t[WARNING]\t$(1)$(COLOR_ANSI_CLEAR)"
endef
define ERROR
	@echo -e "$(COLOR_ANSI_PURPLE)[MAKEFILE]$(COLOR_ANSI_CLEAR)$(COLOR_ANSI_RED)\t[ERROR]\t$(1)	错误代码:$(2)$(COLOR_ANSI_CLEAR)"
	@exit $$2
endef

check:
	$(call INFO, "开始 cargo check ...")
	@cargo check $(riscv_flags)
	$(call INFO, "cargo check 完成！")

clean:
	$(call INFO, "开始清理构建产物...")
	@cargo clean
	@rm -rf ./bin
	$(call INFO, "清理完成！")
$(riscv_build_artifact_path)/hello_world: ./src/bin/hello_world.rs $(riscv_dependencies)
	$(call INFO, "开始构建 riscv 平台的 hello_world...")
	@cargo build $(riscv_flags)
	$(call INFO, "riscv 平台的 hello_world 构架完成！")

$(riscv_bin_path)/hello_world.bin: $(riscv_build_artifact_path)/hello_world
	$(call INFO, "清除 hello_world 二进制文件元数据...");
	@-mkdir  $(bin_path) >/dev/null 2>/dev/null
	@-mkdir  $(riscv_bin_path) >/dev/null 2>/dev/null
	@rm -f $(riscv_bin_path)/hello_world.bin
	@rust-objcopy $(rust_objcopy_flag) $(riscv_build_artifact_path)/hello_world $(riscv_bin_path)/hello_world.bin
	$(call INFO, "清除完成！请见 $(riscv_bin_path)/hello_world.bin")

rv_hello_world: $(riscv_bin_path)/hello_world.bin
