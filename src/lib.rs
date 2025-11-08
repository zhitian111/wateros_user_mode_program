#![no_std]
#![no_main]
#![feature(linkage)]
#![feature(alloc_error_handler)]

mod riscv;
pub mod share;
use crate::riscv::syscall::sys_waitpid;
pub use share::console::print;
use share::syscall;
#[alloc_error_handler]
pub fn handle_alloc_error(layout : core::alloc::Layout) -> ! {
    panic!("Heap allocation error, layout = {:?}",
           layout);
}

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
pub fn uname(addr : usize) -> isize {
    syscall::sys_uname(addr)
}
pub fn wait(exit_code : &mut i32) -> isize {
    loop {
        match sys_waitpid(-1, exit_code as *mut i32) {
            -2 => {
                yield_();
            }
            exit_pid => return exit_pid,
        }
    }
}
pub fn waitpid(pid : usize, exit_code : &mut i32) -> isize {
    loop {
        match sys_waitpid(pid as isize, exit_code as *mut i32) {
            -2 => {
                yield_();
            }
            exit_pid => return exit_pid,
        }
    }
}
pub fn fork() -> isize {
    syscall::sys_fork()
}
pub fn exec(path : &str) -> isize {
    syscall::sys_exec(path)
}
pub fn read(fd : usize, buffer : &mut [u8]) -> isize {
    syscall::sys_read(fd, buffer)
}
