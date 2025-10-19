#![no_std]
#![no_main]

use wateros_user_lib::println;

#[unsafe(no_mangle)]
pub fn main() -> i32 {
    println!("Hello world from user mode program!");
    0
}
