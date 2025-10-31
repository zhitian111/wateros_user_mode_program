#![no_std]
#![no_main]
#![feature(linkage)]

mod riscv;
mod share;
pub use share::console::print;
use share::syscall;
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
    syscall::sys_write(fd, buf)
}

pub fn exit(exit_code : i32) -> isize {
    syscall::sys_exit(exit_code)
}
pub fn yield_() -> isize {
    syscall::sys_yield()
}
pub fn get_time() -> isize {
    syscall::sys_get_time()
}
pub fn brk(addr : usize) -> isize {
    syscall::sys_brk(addr)
}
