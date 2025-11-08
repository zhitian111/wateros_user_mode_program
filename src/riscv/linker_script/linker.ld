OUTPUT_ARCH(riscv)
ENTRY(_start)
START_OFFSET = 0xC0000;
QEMU_ENTRY_ADDRESS = 0x80200000; /* 8020_0000 */
USER_START_OFFSET = 0x200000;

SECTIONS{
  . = QEMU_ENTRY_ADDRESS;
  kernel_start = .;
  /* text 段 */
  text_start = .;
  .text : AT(QEMU_ENTRY_ADDRESS){
    *(.text.entry)
    . = ALIGN(4K);
    trampoline_start = .;
    *(.text.trampoline)
    . = ALIGN(4K);
    *(.text.*)
  }
  text_end = .;
  /* rodata 段 */
  . = ALIGN(4K);

  rodata_start = .;
  .rodata : {
    *(.rodata)
    *(.rodata.*)
    *(.rodata*)
  }
  rodata_end = .;
  
  data_start = .;
  .data : {
    *(.data .data.*)
  }
  data_end = .;
  /* bss 段 */
  bss_start_with_stack = .;
  .bss : {
    /* 栈段 */
    *(.bss.stack)
    /* 堆段 */
    bss_start = .;
    *(.bss .bss.*)
  }
  bss_end = .;
  kernel_end = .;

  /* 该段是用于存储堆栈展开的调试信息的 */
     /DISCARD/ : {
        *(.eh_frame)
        *(.debug*)
    } 
}
