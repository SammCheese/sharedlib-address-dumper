use lazy_static::lazy_static;

use std::fs::File;
use std::io::{Write};

use chrono::offset::local::Local;
use chrono::DateTime;

use std::sync::Mutex;

lazy_static! {
    static ref LOGGER: Mutex<Logger> = Mutex::new(Logger::new("deranged.log"));
}

struct Logger {
    file: File
}

impl Logger {
    fn new(filename: &str) -> Self {
        let file = File::create(filename).unwrap();
        Self { file }
    }

    fn log(&mut self, message: &str) -> () {
        let date: DateTime<Local> = Local::now();
        let formatted = format!("{} {}\n", date.format("[%d/%m/%Y][%T]"), message);
        self.file
            .write_all(formatted.as_bytes())
            .expect("Failed to write log");
    }
}

pub fn log(message: &str) {
    let mut logger = LOGGER.lock().unwrap();
    logger.log(message);
}
