// Use `wee_alloc` as the global allocator.
extern crate wee_alloc;
#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;

use icns::{IconFamily, IconType, Image};

pub fn convert_icon (reader: Read) -> Read
let mut icon_family = IconFamily::read(reader).unwrap();