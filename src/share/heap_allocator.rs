use crate::share::config::*;
use buddy_system_allocator::LockedHeap;
use core::{alloc::Layout, ptr::addr_of_mut};
extern crate alloc;

#[global_allocator]
static HEAP_ALLOCATOR : LockedHeap<USER_HEAP_SIZE_BITS_WIDTH> = LockedHeap::empty();

#[alloc_error_handler]
pub fn handle_alloc_error(layout : Layout) -> ! {
    panic!("Heap allocation error, layout = {:?}",
           layout);
}

static mut HEAP_SPACE : [u8; USER_HEAP_SIZE] = [0; USER_HEAP_SIZE];

pub fn init_heap() {
    unsafe {
        HEAP_ALLOCATOR.lock()
                      .init(addr_of_mut!(HEAP_SPACE) as usize,
                            USER_HEAP_SIZE);
    }
}

#[allow(unused)]
pub fn heap_test() {
    use alloc::boxed::Box;
    use alloc::vec::Vec;
    unsafe extern "C" {
        fn bss_start();
        fn bss_end();
    }
    let bss_range = bss_start as usize..bss_end as usize;
    let a = Box::new(5);
    assert_eq!(*a, 5);
    assert!(bss_range.contains(&(a.as_ref() as *const _ as usize)));
    drop(a);
    let mut v : Vec<usize> = Vec::new();
    for i in 0..500 {
        v.push(i);
    }
    for (i, val) in v.iter()
                     .take(500)
                     .enumerate()
    {
        assert_eq!(*val, i);
    }
    assert!(bss_range.contains(&(v.as_ptr() as usize)));
    drop(v);
    use crate::println;
    println!("heap_test passed!");
}
