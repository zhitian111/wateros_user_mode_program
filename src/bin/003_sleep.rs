#![no_std]
#![no_main]

use wateros_user_lib::{get_time, println, yield_};

#[unsafe(no_mangle)]
fn main() -> i32 {
    let current_time = get_time();
    let wait_for = current_time + 3000;
    while get_time() < wait_for {
        yield_();
    }
    println!("Test sleep OK!");
    0
}
