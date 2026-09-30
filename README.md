For extended debugging add this feature to `uniffi` in `Cargo.toml`: `ffi-trace`:

```toml
uniffi = { version = "=0.31.0", features = ["bindgen", "build", "cli", "tokio", "ffi-trace"] }
```
