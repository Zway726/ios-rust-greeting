mod my;
use my::MyResponse;
use protobuf::Message;
use std::ffi::{CStr, CString};
use std::os::raw::{c_char, c_int, c_uchar, c_void};
use url::Url;

use crate::my::MyRequest;

#[no_mangle]
pub extern "C" fn rust_greeting(to: *const c_char) -> *mut c_char {
    let c_str = unsafe { CStr::from_ptr(to) };
    let recipient = match c_str.to_str() {
        Err(_) => "there",
        Ok(string) => string,
    };

    CString::new("Hello ".to_owned() + recipient)
        .unwrap()
        .into_raw()
}

#[no_mangle]
pub extern "C" fn rust_greeting_free(s: *mut c_char) {
    unsafe {
        if s.is_null() {
            return;
        }
        CString::from_raw(s)
    };
}

#[no_mangle]
pub extern "C" fn process_raw_data(from: *const c_uchar) -> *const c_uchar {
    let c_str = unsafe { CStr::from_ptr(from as *const i8) };
    CString::new(c_str.to_bytes()).unwrap().into_raw() as *const u8
}

#[no_mangle]
pub extern "C" fn process_raw_data_with_len(from: *const c_uchar, len: c_int) -> *const c_uchar {
    let buf: &[u8] = unsafe { std::slice::from_raw_parts(from, len as usize) };

    unsafe { CString::from_vec_unchecked(buf.to_vec()).into_raw() as *const u8 }
}

#[no_mangle]
pub extern "C" fn async_callback(
    context: *mut c_void,
    callback: extern "C" fn(context: *mut c_void, arg1: c_int, arg2: c_int),
) {
    println!("async_callback called");
    callback(context, 2, 3);
}

#[no_mangle]
#[tokio::main]
pub async extern "C" fn my_request(
    context: *mut c_void,
    req_bytes: *const c_uchar,
    bytes_length: c_int,
    callback: extern "C" fn(context: *mut c_void, res_bytes: *const c_uchar),
) {
    println!("my_request called");
    let buf: &[u8] = unsafe { std::slice::from_raw_parts(req_bytes, bytes_length as usize) };
    let my_req: MyRequest = Message::parse_from_bytes(buf).unwrap();

    let res = make_request(&my_req).await.expect("request failed");
    let raw_data = res.write_to_bytes().unwrap();

    let res_bytes = CString::new(raw_data).unwrap().into_raw() as *const u8;
    callback(context, res_bytes);
}

async fn make_request(
    _: &MyRequest,
) -> Result<MyResponse, Box<dyn std::error::Error>> {
    let mut url = Url::parse("https://example.com")?;
    // add query params
    url.query_pairs_mut().append_pair("", "");

    let client = reqwest::Client::new();
    let res = client
        .get(url.as_str())
        .header("Authorization", "")
        .send()
        .await?
        .json::<MyResponse>()
        .await?;
    Ok(res)
}
