#! /bin/sh

echo "Setting up the rust environment..."
rustup target add aarch64-apple-ios aarch64-apple-ios-sim x86_64-apple-ios x86_64-apple-darwin aarch64-apple-darwin
cargo install cbindgen

echo "Building..."

echo "cargo build --release --target x86_64-apple-darwin"
cargo build --release --target x86_64-apple-darwin

echo "cargo build --release --target aarch64-apple-darwin"
cargo build --release --target aarch64-apple-darwin

echo "cargo build --release --target aarch64-apple-ios"
cargo build --release --target aarch64-apple-ios --features mimalloc

echo "cargo build --release --target x86_64-apple-ios"
cargo build --release --target x86_64-apple-ios

echo "cargo build --release --target x86_64-apple-ios-sim"
cargo build --release --target aarch64-apple-ios-sim

echo "Generating includes..."
mkdir -p target/include/
rm -rf target/include/*
cbindgen --config cbindgen.toml -o target/include/tun2proxy.h

echo "lipo..."

echo "Simulator"
lipo -create \
    target/aarch64-apple-ios-sim/release/libtun2proxy.a \
    target/x86_64-apple-ios/release/libtun2proxy.a \
    -output ./target/libtun2proxy-ios-sim.a

echo "MacOS"
lipo -create \
    target/aarch64-apple-darwin/release/libtun2proxy.a \
    target/x86_64-apple-darwin/release/libtun2proxy.a \
    -output ./target/libtun2proxy-macos.a

create_framework() {
    local LIB_PATH=$1
    local FRAMEWORK_NAME=$2
    local OUTPUT_DIR=$3

    FRAMEWORK_DIR="$OUTPUT_DIR/$FRAMEWORK_NAME.framework"
    mkdir -p "$FRAMEWORK_DIR/Headers"
    cp "$LIB_PATH" "$FRAMEWORK_DIR/$FRAMEWORK_NAME"
    cp target/include/tun2proxy.h "$FRAMEWORK_DIR/Headers/"

    mkdir -p "$FRAMEWORK_DIR/Modules"
    cat > "$FRAMEWORK_DIR/Modules/module.modulemap" <<EOF
framework module $FRAMEWORK_NAME {
    umbrella header "tun2proxy.h"
    export *
    module * { export * }
}
EOF
}

# iOS device
create_framework target/aarch64-apple-ios/release/libtun2proxy.a tun2proxy ios-arm64
# iOS simulator
create_framework target/libtun2proxy-ios-sim.a tun2proxy ios-arm64_x86_64-simulator
# MacOS
create_framework target/libtun2proxy-macos.a tun2proxy macos-arm64_x86_64

echo "Creating XCFramework"
rm -rf ./tun2proxy.xcframework
xcodebuild -create-xcframework \
    -framework ios-arm64/tun2proxy.framework \
    -framework ios-arm64_x86_64-simulator/tun2proxy.framework \
    -framework macos-arm64_x86_64/tun2proxy.framework \
    -output ./tun2proxy.xcframework
