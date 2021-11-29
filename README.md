# android-recovery-action
A Github Action to build android recoveries in any workflow without any hassle of setting up environment & anything.

# Features:
- Easy to use & understand.
- Faster building.
- Supports all types of recoveries.

# Notes

There is Only Support For `ubuntu-20.04` also Known As `ubuntu-latest`

Path to Compiled Recovery is `/home/runner/work/out/target/product/*/*.img , *.zip`

For Orangefox android V10 Use `orangefox` in `MANIFEST` `/home/runner/work/out/target/product/*/*.img , *.zip` 
 
Caution :- `orangefox` term is Only For Android10 based devices aka dynamic devices & For Android 9 devices you can use Manifest

--------------------------------------------------------------------------------------------------------------------------------

# Example & Usages:

```yaml
- name: Android Recovery Action
  uses: XenonTheInertG/Android-Recovery-action@V1.2
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

