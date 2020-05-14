use wasmtime::*;
use std::time::Instant;

fn main() {
    let store = Store::default();
    let mut linker = Linker::new(&store);

    let mut maybe_main = None;

    let args: Vec<_> = std::env::args().collect();
    for arg in &args[1..] {
        let mut arg_s = arg.split(":");
        let name = arg_s.next().unwrap();
        let path = arg_s.next().unwrap();
        let module = Module::from_file(&store, path).unwrap();
        let instance = linker.instantiate(&module).unwrap();
        linker.instance(name, &instance).unwrap();
        if name == "main" {
            maybe_main = Some(instance)
        }
    }

    let main = maybe_main.unwrap();
    let start = main.get_export("_start").unwrap().func().unwrap().get0::<()>().unwrap();
    println!("warming jit...");
    start().unwrap(); // warm up JIT
    start().unwrap(); // warm up JIT
    let time_start = Instant::now();
    start().unwrap();
    println!("run time: {}ms", time_start.elapsed().as_millis());
}
