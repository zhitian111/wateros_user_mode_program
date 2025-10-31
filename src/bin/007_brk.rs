#![no_std]
#![no_main]

use wateros_user_lib::brk;
use wateros_user_lib::println;
fn test_brk() {
    let cur_pos : isize = brk(0);
    println!("Before alloc,heap pos:{}", cur_pos);
    brk(usize::try_from(cur_pos + 64).unwrap());
    let alloced_pos : isize = brk(0);
    println!("After alloc 64 bytes,heap pos:{}",
             alloced_pos);
    brk(usize::try_from(alloced_pos + 64).unwrap());
    let alloced_pos_1 : isize = brk(0);
    println!("Alloc again,heap pos:{}", alloced_pos_1);
}
#[unsafe(no_mangle)]
fn main() -> i32 {
    test_brk();
    0
}
