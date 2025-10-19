#![no_std]
#![no_main]
#![feature(linkage)]

pub mod share;

#[cfg(target_arch = "riscv64")]
pub mod riscv;

#[unsafe(no_mangle)]
#[unsafe(link_section = ".text.entry")]
pub extern "C" fn _start() {
    riscv::clear_bss();
    exit(main());
}

#[linkage = "weak"]
#[unsafe(no_mangle)]
pub fn main() -> i32 {
    panic!("Cannot find main!");
}

pub fn write(fd : usize, buf : &[u8]) -> isize {
    #[cfg(target_arch = "riscv64")]
    riscv::syscall::sys_write(fd, buf)
}

pub fn exit(exit_code : i32) -> isize {
    #[cfg(target_arch = "riscv64")]
    riscv::syscall::sys_exit(exit_code)
}
