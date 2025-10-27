#[cfg(target_arch = "riscv64")]
use crate::riscv::syscall;

pub fn sys_write(fd : usize, buffer : &[u8]) -> isize {
    syscall::sys_write(fd, buffer)
}

pub fn sys_exit(xstate : i32) -> isize {
    syscall::sys_exit(xstate)
}

pub fn sys_yield() -> isize {
    syscall::sys_yield()
}

pub fn sys_get_time() -> isize {
    syscall::sys_get_time()
}
