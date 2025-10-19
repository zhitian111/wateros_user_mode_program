use crate::write;
use core::fmt;
use fmt::Write;
pub struct Stdout;
const STDOUT : usize = 1;

impl Write for Stdout {
    fn write_str(&mut self, s : &str) -> fmt::Result {
        write(STDOUT, s.as_bytes());
        Ok(())
    }
}
pub fn print(args : fmt::Arguments) {
    Stdout.write_fmt(args)
          .unwrap()
}

pub fn prints(str : &str) {
    Stdout.write_str(str)
          .unwrap();
}

#[macro_export]
macro_rules! print {
    ($fmt: literal $(, $($arg: tt)+)?) => {
        $crate::share::console::print(format_args!($fmt $(,$($arg)+)?));
    }
}

#[macro_export]
macro_rules! println {
    ($fmt: literal $(, $($arg: tt)+)?) => {
        $crate::share::console::print(format_args!(concat!($fmt, "\n") $(,$($arg)+)?));
    }
}
