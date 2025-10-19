use core::iter::Iterator;
pub mod lang_items;
pub mod syscall;
pub fn clear_bss() {
    // 从连接器给出的符号表获取bss段范围
    unsafe extern "C" {
        fn bss_start();
        fn bss_end();
    }
    (bss_start as usize..bss_end as usize).for_each(|a| unsafe {
                                              (a as *mut u8).write_volatile(0);
                                          });
}
