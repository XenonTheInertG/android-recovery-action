#Copyright(2021) XenonTheInertG

#!/usr/bin/env bash

printf "\e[1;32m \u2730 Recovery Compiler\e[0m\n\n"

mkdir -p work &>/dev/null
cd work &>/dev/null || exit 1

echo "::group::Syncing Manifest"
printf "Initializing Repo\n"
if [[ "$MANIFEST" == "orangefox" ]]; then
       printf "Cloning OFOX Manifest\n"
       git clone https://github.com/XenonTheInertG/ofox-sync.git
       cd ofox-sync
       bash ./get_fox_10.sh /home/runner/work
       cd /home/runner/work
else
       repo init -q -u $MANIFEST --depth=1 --groups=all,-notdefault,-device,-darwin,-x86,-mips
       repo sync -c -q --force-sync --no-clone-bundle --no-tags -j6 &>/dev/null
fi
echo "::endgroup::"

echo "::group::Cloning Device & Kernel Tree"
printf "Cloning Device Tree\n"
git clone $DT_LINK --depth=1 device/${VENDOR}/${CODENAME}
# omni.dependencies file is a must inside DT, otherwise lunch fails
[[ ! -f device/${VENDOR}/${CODENAME}/omni.dependencies ]] && printf "[\n]\n" > device/${VENDOR}/${CODENAME}/omni.dependencies

if [[ ! -z "$KERNEL_LINK" ]]; then
	printf "Using Kernel Compliation\n"
	git clone $KERNEL_LINK --depth=1 kernel/${VENDOR}/${CODENAME}
else
	printf "Using Prebuilt Kernel For The Build.\n"
fi
echo "::endgroup::"

echo "::group::Extra Commands"
if [[ ! -z "$EXTRA_CMD" ]]; then
	printf "Executing Extra Commands\n"
        eval $EXTRA_CMD
else
	printf "No extra commands mentioned.\n"
fi
echo "::endgroup::"

echo "::group::Pre-Compilation"
printf "Building  Recovery...\n"

export ALLOW_MISSING_DEPENDENCIES=true

# If lunch throws error for roomservice, saying `device tree not found` or `fetching device already present`,
# replace the `roomservice.py` with appropriate one from here
# >> https://gist.github.com/rokibhasansagar/247ddd4ef00dcc9d3340397322051e6a/
# and then `source` and `lunch` again

source build/envsetup.sh
lunch omni_${CODENAME}-$FLAVOR
echo "::endgroup::"

echo "::group::Compilation"
mka $TARGET
echo "::groupend::"
