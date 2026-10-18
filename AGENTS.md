# Project instructions

- For Android APK builds, use exactly `flutter build apk --release --target-platform android-arm64 --split-per-abi`.
- Do not substitute a debug or universal APK build unless the user explicitly asks for one.
- Use TDD for behavior changes: write tests that cover the requested behavior before changing implementation code, run them to confirm they fail for the expected reason, then implement the change and rerun the tests. Fix the implementation and rerun tests until they pass.
