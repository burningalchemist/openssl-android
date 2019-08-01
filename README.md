# OpenSSL for Android (x32/x64)

These scripts do all for you from downloading and extracting OpenSSL to
generating static libraries for arm64-v8a and armeabi-v7a (optionally, other platforms)

Please check `build-all-arch.sh` and `setenv-android-mod.sh` for more details or adjustments.

---

By default, OpenSSL version is set to 1.0.2s, after which the API was significantly changed
and became incompatible with older projects.

Also, pay attention to the byte order flag (Big Endian/Little Endian). Here it is set to `-DL_ENDIAN`.
If misconfigured, might create issues, e.g. `error:04091068:rsa routines:INT_RSA_VERIFY:bad signature`
or worse. In my particular case, the flag was initially set to `-DB_ENDIAN`, so secure web requests
with `libcurl` were broken. It might be different in your situation.

With minor changes it's possible to produce shared libraries as well.

Given that, open terminal and run:

```sh
cd <path/to/this/repo>
chmod 755 ./build-all-arch.sh
chmod 755 ./setenv-android-mod.sh
export ANDROID_NDK_ROOT=/your/path/to/_android/android-ndk-r10e
./build-all-arch.sh
```

