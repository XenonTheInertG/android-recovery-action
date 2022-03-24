# android-recovery-action
A Github Action to build android recoveries in any workflow without any hassle of setting up environment & anything.

# Features:
- Easy to use & understand.
- Faster building.
- Supports all types of recoveries.

# Build Platform

Build either on `ubuntu-18.04` or `ubuntu-20.04` also Known As `ubuntu-latest` runner.

# Output

As the Working Directory where the repo-sync will occur is set in `/home/runner/builder/`, accessible from `${result}`.

So, Compiled Recovery will be found under `/home/runner/output/out/target/product/*/*{.img,.zip}`. Same can be accessed using `${result}/out/target/product/${CODENAME}/*{.img,.zip}`

# Notes for Orangefox

Only for Orangefox Android V10 dynamic devices, Use `orangefox10` as `MANIFEST`.
For Android 9 devices you can use Manifest URL.

# Usages

**Note:** If you want to minimize the input in the Workflow YAML File, Read below:
- Create an `YAML` file in device tree's repo(.github/workflows/*.yaml)
- Rename your Device Tree Repo in this format, `android_device_VENDOR_CODENAME`.
  If you do this, you won't need to add `VENDOR`, `CODENAME` and `DT_LINK` in the yaml `env` key.
  They will be fetched automatically from your Repo address.
- `KERNEL_LINK` is optional, use this only if you want to build kernel from source code.
- `TARGET` is set as `recoveryimage` by default.
  Unless you want to build `bootimage` or something, don't provide anything.
- `FLAVOR` is set as `eng` by default.
  Unless you want to build an `userdebug` build, don't provide anything.
- `EXTRA_CMD` key is added if you want to run some user-defined commands such as patchworks before compilation.
  Don't use it if you don't have anything to add.
- `TZ` (Timezone) is set as `UTC` by default.
  Unless you want to change the Timezone, ignore it.
If you followed these steps, you will need to provide only one `env` variable, `MANIFEST`. That's it.

If you still want to do things manual way, here is the full format -

--------------------------------------------------------------------------------------------------------------------------------

# Example & Usages:

```yaml
- name: Android Recovery Action
  uses: XenonTheInertG/android-recovery-action@main
  env:
    MANIFEST: "Recovery Manifest URL with -b branch" or "orangefox" for orangefox android v10
    DT_LINK: "Your Device Tree Link"
    VENDOR: "Your Device's Vendor name as in used inside DT. Example: xiaomi, samsung, asus, etc."
    CODENAME: "Your Device's Codename as in used inside DT. Example: nikel, phoenix, ginkgo, etc."
    KERNEL_LINK: "Kernel repo link with optional -b branch. If not filled it would be detected as prebuilt"
    TARGET: "Set as recoveryimage or bootimage if no recovery partition avaiable"
    FLAVOR: "eng or userdebug"
    EXTRA_CMD: "if you want to Execute any external Command Before building process starts"
    TZ: "Dhaka/Bangladesh" # Set Time-Zone According To Your Region
```

