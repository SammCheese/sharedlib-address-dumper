use std::{time::SystemTime, ffi::{ CStr }};
use libc::{Dl_info, dladdr, dl_iterate_phdr, dl_phdr_info, c_void};

mod logger;

#[allow(dead_code)]
#[link_section = ".ctors"]
#[used]
#[cfg(target_os = "linux")]
pub static ENTRY_POINT: extern "C" fn() = lib_init;

#[allow(dead_code)]
#[link_section = ".dtors"]
#[used]
#[cfg(target_os = "linux")]
pub static DESTRUCTOR:  extern "C" fn() = lib_evaporate;

#[no_mangle]
pub extern "C" fn lib_init() {
    let start_time = SystemTime::now();

    unsafe {
        dl_iterate_phdr(Some(callback), std::ptr::null_mut());
    }

    logger::log(&format!("Finished in {:?}", SystemTime::now().duration_since(start_time)))
}

extern "C" fn callback(info: *mut dl_phdr_info, _size: usize, _data: *mut c_void) -> libc::c_int {
    let mut dl_info = Dl_info {
        dli_fname: std::ptr::null(),
        dli_fbase: std::ptr::null_mut(),
        dli_sname: std::ptr::null(),
        dli_saddr: std::ptr::null_mut(),
    };

    unsafe {
        if dladdr(info.offset(0).as_ref().unwrap().dlpi_addr as *mut c_void, &mut dl_info as *mut Dl_info) != 0 {
            let filename = CStr::from_ptr(dl_info.dli_fname).to_string_lossy().into_owned();
            let base_addr = dl_info.dli_fbase as *mut c_void;
            logger::log(&format!("Found: {} at {:?}!", filename, base_addr));
        }
    }
    0
}

#[no_mangle]
extern "C" fn lib_evaporate() {
    // Some Time maybe
}