fn main() {
    println!("cargo:rerun-if-changed=./src/riscv/linker_script/linker.ld");
}
