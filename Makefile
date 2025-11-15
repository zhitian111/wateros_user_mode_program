SHELL := /bin/bash

.PHONY: version
VERSION_BASE := 0.1.0
STAGE := prototype
BUILD_NUM = $(shell git rev-list --count HEAD)
BRANCH=$(shell git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

export CARGO_TERM_COLOR=always
.PHONY: clean check all rv_all
.PHONY: rv_hello_world rv_store_fault rv_wateros_user_lib rv_disk_img
COLOR_ANSI_RED := \033[31m
COLOR_ANSI_GREEN := \033[32m
COLOR_ANSI_YELLOW := \033[33m
COLOR_ANSI_BLUE := \033[34m
COLOR_ANSI_PURPLE := \033[35m
COLOR_ANSI_CYAN := \033[36m
COLOR_ANSI_WHITE := \033[37m

COLOR_ANSI_CLEAR := \033[0m

VERSION := v$(COLOR_ANSI_GREEN)$(VERSION_BASE)$(COLOR_ANSI_CLEAR)-$(COLOR_ANSI_PURPLE)$(STAGE)$(COLOR_ANSI_CLEAR).$(BUILD_NUM)+$(COLOR_ANSI_YELLOW)$(BRANCH)$(COLOR_ANSI_CLEAR)

common_dependencies := ./src/share/**

CARGO = stdbuf -oL -eL cargo

riscv_dependencies := $(common_dependencies) \
					  ./src/riscv/** \
					  ./src/lib.rs

riscv_flags := --release --target riscv64gc-unknown-none-elf

riscv_build_artifact_path := ./target/riscv64gc-unknown-none-elf/release

riscv_bin_path := ./bin/riscv

riscv_elf_path := ./elf/riscv

rv_wateros_user_lib_stamp := $(riscv_build_artifact_path)/deps/libwateros_user_lib.stamp

bin_path := ./bin

elf_path := ./elf

rust_objcopy_bin_flag := --strip-all -O binary --gap-fill=0x00
rust_objcopy_elf_flag := --strip-all -O binary --gap-fill=0x00

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

-include ./src/bin/Makefile.generated

version:
	$(call INFO, "当前版本信息如下：")
	@echo -e "$(COLOR_ANSI_CYAN)WaterOS User-Mode Programs\t$(COLOR_ANSI_WHITE)--version\t$(VERSION)"

all_start_info:
	$(call INFO, "开始构建所有用户态程序...")

rv_all_start_info:
	$(call INFO, "开始为 riscv 平台构建所有用户态程序...")

rv_all: rv_all_start_info ./src/bin/Makefile.generated rv_all_bin rv_all_elf rv_disk_img
	$(call INFO, "所有 riscv 平台的用户态程序已构建完成！")

rv_disk_img:./rv_disk.img
	$(call INFO, "riscv 平台测试使用的 ext4 文件系统磁盘映像构建完成！")

./rv_disk.img: rv_all_elf
	$(call INFO, "开始构建 riscv 平台测试使用的 ext4 文件系统磁盘镜像...")
	@bash ./script/rv_gen_ext4_disk_img.sh

./src/bin/Makefile.generated: ./Cargo.toml ./script/gen_bin_makefile.sh
	$(call INFO, "开始生成构建用户态程序所需的 Makefile")
	@bash ./script/gen_bin_makefile.sh
	$(call INFO, "构建用户态程序所需的 Makefile 生成完成！")



all: all_start_info ./src/bin/Makefile.generated rv_all
	$(call INFO, "所有用户态程序已构建完成！")

rv_wateros_user_lib: $(rv_wateros_user_lib_stamp)

$(rv_wateros_user_lib_stamp): $(riscv_dependencies)
	$(call INFO, "开始构建为 riscv 平台构建 wateros_user_lib")
	@$(CARGO) build $(riscv_flags) --lib
	@touch $(rv_wateros_user_lib_stamp)
	$(call INFO, "riscv 平台的 wateros_user_lib 构建完成！")

check:
	$(call INFO, "开始 cargo check ...")
	@$(CARGO) check $(riscv_flags)
	$(call INFO, "cargo check 完成！")

clean:
	$(call INFO, "开始清理构建产物...")
	@$(CARGO) clean
	@rm -rf ./bin
	@rm -rf ./elf
	@rm -f rv_disk.img
	@rm -f la_disk.img
	$(call INFO, "清理完成！")
