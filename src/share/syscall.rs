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
pub fn sys_brk(addr : usize) -> isize {
    syscall::sys_brk(addr)
}
pub fn sys_uname(addr : usize) -> isize {
    syscall::sys_uname(addr)
}
pub fn sys_fork() -> isize {
    syscall::sys_fork()
}
pub fn sys_waitpid(pid : isize, exit_code : *mut i32) -> isize {
    syscall::sys_waitpid(pid, exit_code)
}
pub fn sys_exec(path : &str) -> isize {
    syscall::sys_exec(path)
}
pub fn sys_read(fd : usize, buffer : &mut [u8]) -> isize {
    syscall::sys_read(fd, buffer)
}
