#!/bin/bash

#
# Copyright (C) 2017-2021 The LineageOS Project
#
# SPDX-License-Identifier: MIT
#
# Copyright (C) 2021 XenonTheInertG

echo "
    _           _         _    _     ___                                  _      _   _           
   /_\  _ _  __| |_ _ ___(_)__| |___| _ \___ __ _____ _____ _ _ _  _ ___ /_\  __| |_(_)___ _ _   
  / _ \| ' \/ _` | '_/ _ \ / _` |___|   / -_) _/ _ \ V / -_) '_| || |___/ _ \/ _|  _| / _ \ ' \  
 /_/ \_\_||_\__,_|_| \___/_\__,_|   |_|_\___\__\___/\_/\___|_|  \_, |  /_/ \_\__|\__|_\___/_||_| 
                                                                |__/                            
 By XenonTheInertG
"
# Echo Loop
while ((${SECONDS_LEFT:=10} > 0)); do
    printf "Please wait %.fs ...\n" "${SECONDS_LEFT}"
    sleep 1
    SECONDS_LEFT=$((SECONDS_LEFT - 1))
done
unset SECONDS_LEFT

echo "::group::Load variables & configuration"
if [[ -z ${MANIFEST} ]]; then
    printf "Please Provide A Manifest URL with/without Branch\n"
    exit 1
fi
if [[ -z ${VENDOR} || -z ${CODENAME} ]]; then
    # Assume the workflow runs in the device tree repo
    # And the naming is exactly like android_device_vendor_codename(_split_codename)(-pbrp)
    # Optimized for PBRP Device Trees
	VenCode=$(echo ${GITHUB_REPOSITORY#*/} | sed 's/android_device_//;s/-pbrp//;')
    export VENDOR=$(echo ${VenCode} | cut -d'_' -f1)
    export CODENAME=$(echo ${VenCode} | cut -d'_' -f2-)
	unset VenCode
fi
if [[ -z ${DT_LINK} ]]; then
    # Assume the workflow runs in the device tree with the current checked-out branch
    DT_BR=${GITHUB_REF##*/}
    export DT_LINK="https://github.com/${GITHUB_REPOSITORY} -b ${DT_BR}"
	unset DT_BR
fi
# Default TARGET will be recoveryimage if not provided
export TARGET=${TARGET:-recoveryimage}
# Default FLAVOR will be eng if not provided
export FLAVOR=${FLAVOR:-eng}
# Default TZ (Timezone) will be set as UTC if not provided
export TZ=${TZ:-UTC}
if [[ ! ${TZ} == "UTC" ]]; then
    sudo timedatectl set-timezone ${TZ}
fi
echo "::endgroup::"

printf "Building ${FLAVOR}-flavored ${TARGET} for ${CODENAME} from the manufacturer ${VENDOR}\n"

# cd To An Absolute Path
mkdir -p /home/runner/output &>/dev/null
cd /home/runner/output || exit 1

echo "::group::Source Repo Sync"
printf "Initializing Repo\n"
printf "We will be using %s for Manifest source\n" "${MANIFEST}"
repo init -q -u ${MANIFEST} --depth=1 --groups=all,-notdefault,-device,-darwin,-x86,-mips || { printf "Repo Initialization Failed.\n"; exit 1; }
repo sync -c -q --force-sync --no-clone-bundle --no-tags -j6 || { printf "Git-Repo Sync Failed.\n"; exit 1; }
echo "::endgroup::"

echo "::group::Cloning Device tree & kernel"
printf "Cloning Device Tree\n"
git clone ${DT_LINK} --depth=1 device/${VENDOR}/${CODENAME}
# omni.dependencies file is a must inside DT, otherwise lunch fails
[[ ! -f device/${VENDOR}/${CODENAME}/omni.dependencies ]] && printf "[\n]\n" > device/${VENDOR}/${CODENAME}/omni.dependencies
if [[ ! -z "${KERNEL_LINK}" ]]; then
    printf "Using Manual Kernel Compilation\n"
    git clone ${KERNEL_LINK} --depth=1 kernel/${VENDOR}/${CODENAME}
else
    printf "Using Prebuilt Kernel For The Build.\n"
fi
echo "::endgroup::"

echo "::group::Extra Commands"
if [[ ! -z "$EXTRA_CMD" ]]; then
    printf "Executing Extra Commands\n"
    eval "${EXTRA_CMD}"
    cd /home/runner/output || exit
fi
echo "::endgroup::"

echo "::group::Starting Compilation"
printf "Compiling Recovery...\n"
export ALLOW_MISSING_DEPENDENCIES=true

# Only for (Unofficial) TWRP Building...
# If lunch throws error for roomservice, saying like `device tree not found` or `fetching device already present`,
# replace the `roomservice.py` with appropriate one according to platform version from here
# >> https://gist.github.com/rokibhasansagar/247ddd4ef00dcc9d3340397322051e6a/
# and then `source` and `lunch` again

source build/envsetup.sh
lunch omni_${CODENAME}-${FLAVOR}
echo "::endgroup::"

echo "::group::Building Started"
mka ${TARGET} || { printf "Building failed.\n"; exit 1; }
echo "::endgroup::"

# Export VENDOR, CODENAME and BuildPath for next steps
echo "VENDOR=${VENDOR}" >> ${GITHUB_ENV}
echo "CODENAME=${CODENAME}" >> ${GITHUB_ENV}
echo "result=/home/runner/output" >> ${GITHUB_ENV}

cd home/runner/output/${DEVICE}

# Set FILENAME var
FILENAME=$(echo $OUTPUT)

# Upload to oshi.at
if [ -z "$TIMEOUT" ];then
    TIMEOUT=20160
fi

# Upload to WeTransfer
transfer wet $FILENAME > link.txt || { echo "ERROR: Failed to Upload the Build!" && exit 1; }

# Mirror to oshi.at
curl -T $FILENAME https://oshi.at/${FILENAME}/${OUTPUT} > mirror.txt || { echo "WARNING: Failed to Mirror the Build!"; }

DL_LINK=$(cat link.txt | grep Download | cut -d\  -f3)
MIRROR_LINK=$(cat mirror.txt | grep Download | cut -d\  -f1)

# Show the Download Link
echo "=============================================="
echo "Download Link: ${DL_LINK}" || { echo "ERROR: Failed to Upload the Build!"; }
echo "Mirror: ${MIRROR_LINK}" || { echo "WARNING: Failed to Mirror the Build!"; }
echo "=============================================="

