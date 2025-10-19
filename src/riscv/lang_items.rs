use crate::println;
use core::panic::PanicInfo;

#[panic_handler]
fn panic_handler(panic_info : &PanicInfo) -> ! {
    let err = panic_info.message();
    if let Some(location) = panic_info.location() {
        println!("Panicked at {}:{}, {}",
                 location.file(),
                 location.line(),
                 err);
    } else {
        println!("Panciked: {}", err);
    }
    unreachable!()
}
