SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/source/console.bash"

warning "请注意，该脚本中部分与挂载相关的命令需要 root 权限！"
# read -p "请输入y/n" answer
# if [[ "$answer" != "y" ]]; then
#   info "用户取消操作，退出。"
#   exit 1
# fi

# 生成全 0 文件
dd if=/dev/zero of=rv_disk.img bs=1M count=32
# 将该文件格式化为 ext4 文件系统
mkfs.ext4 rv_disk.img
# 创建临时挂载点
mkdir -p ./target/tem/rv_mnt
# 挂载磁盘映像
sudo mount -o loop ./rv_disk.img ./target/tem/rv_mnt
# 将 elf 文件放入磁盘
sudo cp -r ./elf/riscv/. ./target/tem/rv_mnt
# 卸载
sudo umount ./target/tem/rv_mnt
