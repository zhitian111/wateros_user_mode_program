OUTPUT_ARCH(riscv)
ENTRY(_start)

QEMU_ENTRY_ADDRESS = 0x80200000; /* 8020_0000 */
USER_START_OFFSET = 0x200000;

SECTIONS{
  . = QEMU_ENTRY_ADDRESS + USER_START_OFFSET;
  /* text 段 */
  text_start = .;
  .text : {
    *(.text.entry)
    *(.text)
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

  /* bss 段 */
  .bss : {
    /* 栈段 */
    *(.bss.stack)
    /* 堆段 */
    bss_start = .;
    *(.bss .bss.*)
  }
  bss_end = .;
}
