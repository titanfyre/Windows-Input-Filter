use std::{env, fs, path::PathBuf};
fn main() {
    let dir = env::var_os("WINDOWS_INPUT_FILTER_SDK_LIB_DIR")
        .map(PathBuf::from)
        .unwrap_or_else(|| {
            PathBuf::from(env::var_os("CARGO_MANIFEST_DIR").unwrap()).join("native")
        });
    println!("cargo:rustc-link-search=native={}", dir.display());
    println!("cargo:rustc-link-lib=dylib=WindowsInputFilterBridge");
    println!("cargo:rerun-if-env-changed=WINDOWS_INPUT_FILTER_SDK_LIB_DIR");
    println!(
        "cargo:rerun-if-changed={}",
        dir.join("WindowsInputFilterBridge.dll").display()
    );
    let out = PathBuf::from(env::var_os("OUT_DIR").unwrap());
    let profile = out.ancestors().nth(3).unwrap();
    for target in [profile.to_path_buf(), profile.join("deps")] {
        fs::create_dir_all(&target).unwrap();
        fs::copy(
            dir.join("WindowsInputFilterBridge.dll"),
            target.join("WindowsInputFilterBridge.dll"),
        )
        .expect("Download the complete release or build WindowsInputFilterBridge first");
    }
}
