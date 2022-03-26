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
#!/usr/bin/env bash

if [[ $OSTYPE != "linux-gnu" ]]; then
  printf "This Cleanup Script Should Be Run On Ubuntu Runner.\n"
  exit 1
fi

# Slimhub_action script from Rokib Hasan Sagar

# Make Sure The Environment Is Non-Interactive
export DEBIAN_FRONTEND=noninteractive

# Prepare: Just To Populate Workflow Output Window
until [[ "${SECONDS_LEFT:=10}" = 0 ]]; do
  printf "Please wait %ss ...\n" "${SECONDS_LEFT}"
  sleep 0.5
  SECONDS_LEFT=$(echo "${SECONDS_LEFT} - 0.5" | bc)
done
unset SECONDS_LEFT

echo "::group::Disk Space Before Cleanup"
df -hlT /
echo "::endgroup::"

echo "::group::Clearing Docker Image Caches"
docker rmi -f $(docker images -q) &>/dev/null
echo "::endgroup::"

echo "::group::Uninstalling Unnecessary Applications"
sudo -EH apt-fast -qq -y update &>/dev/null
printf "This process will consume most of the cleanup time as APT Package Manager cleans Applications with Single Process.\nParallelism is Not Possible Here, So You Have To Wait For Some Time...\n"
REL=$(grep "UBUNTU_CODENAME" /etc/os-release | cut -d'=' -f2)
if [[ ${REL} == "focal" ]]; then
  APT_Pac4Purge="alsa-topology-conf alsa-ucm-conf python2-dev python2-minimal libpython-dev libllvm-* llvm-12-linker-tools"
elif [[ ${REL} == "bionic" ]]; then
  APT_Pac4Purge="python-dev libllvm6.0"
fi
sudo -EH apt-fast -qq -y purge \
  ${APT_Pac4Purge} \
  clang-* clang-format-* libclang-common-*-dev libclang-cpp* libclang1-* \
  liblldb-* lld-* lldb-* llvm-*-dev llvm-*-runtime llvm-*-tools llvm-* \
  adoptopenjdk-* openjdk* ant* \
  *-icon-theme plymouth *-theme* fonts-* gsfonts gtk-update-icon-cache \
  google-cloud-sdk \
  apache2* nginx msodbcsql* mssql-tools mysql* libmysqlclient* unixodbc-dev postgresql* libpq-dev odbcinst* mongodb-* sphinxsearch \
  apport* popularity-contest \
  aspnetcore-* dotnet* \
  azure-cli session-manager-plugin \
  brltty byobu htop \
  buildah hhvm kubectl packagekit* podman podman-plugins skopeo \
  chromium-browser firebird* firefox google-chrome* xvfb \
  esl-erlang ghc-* groff-base rake r-base* r-cran-* r-doc-* r-recommended ruby* swig* \
  gfortran* \
  gh subversion mercurial mercurial-common \
  info install-info landscape-common \
  libpython2* imagemagick* libmagic* vim vim-* \
  man-db manpages \
  mono-* mono* libmono-* \
  nuget packages-microsoft-prod snapd yarn \
  php-* php5* php7* php8* snmp \
  &>/dev/null
sudo -EH apt-fast -qq -y autoremove &>/dev/null
{
  sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100
  sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 90
  sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 100
  sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 90
  sudo update-alternatives --install /usr/bin/cpp cpp /usr/bin/cpp-10 100
  sudo update-alternatives --install /usr/bin/cpp cpp /usr/bin/cpp-9 90
  sudo update-alternatives --install /usr/bin/gcov gcov /usr/bin/gcov-10 100
  sudo update-alternatives --install /usr/bin/gcov gcov /usr/bin/gcov-9 90
  sudo update-alternatives --install /usr/bin/gcov-dump gcov-dump /usr/bin/gcov-dump-10 100
  sudo update-alternatives --install /usr/bin/gcov-dump gcov-dump /usr/bin/gcov-dump-9 90
  sudo update-alternatives --install /usr/bin/gcov-tool gcov-tool /usr/bin/gcov-tool-10 100
  sudo update-alternatives --install /usr/bin/gcov-tool gcov-tool /usr/bin/gcov-tool-9 90
  sudo update-alternatives --install /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-10 100
  sudo update-alternatives --install /usr/bin/gcc-ar gcc-ar /usr/bin/gcc-ar-9 90
  sudo update-alternatives --install /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-10 100
  sudo update-alternatives --install /usr/bin/gcc-nm gcc-nm /usr/bin/gcc-nm-9 90
  sudo update-alternatives --install /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-10 100
  sudo update-alternatives --install /usr/bin/gcc-ranlib gcc-ranlib /usr/bin/gcc-ranlib-9 90
} &>/dev/null
echo "::endgroup::"

{
  echo "will cite" | parallel --citation
} &>/dev/null

echo "::group::Removing Homebrew Completely"
curl -sL https://raw.githubusercontent.com/Homebrew/install/master/uninstall.sh -o uninstall-brew.sh && chmod a+x uninstall-brew.sh
./uninstall-brew.sh -f -q &>/dev/null
sudo rm -rf -- ./uninstall-brew.sh /home/linuxbrew &>/dev/null
echo "::endgroup::"

echo "::group::Removing NodeJS, NPM & NPX"
{
  sudo npm list -g --depth=0. 2>/dev/null | awk -F ' ' '{print $2}' | awk -F '@[0-9]' '{print $1}' | grep -v "^n$" | sudo xargs npm remove -g
  yes | sudo n uninstall
  parallel --use-cpus-instead-of-cores sudo rm -rf {} 2>/dev/null ::: /usr/local/lib/node_modules ::: /usr/local/n ::: /usr/local/bin/n /usr/local/bin/vercel /usr/local/bin/now
} &>/dev/null
echo "::endgroup::"

echo "::group::Purging PIPX & PIP packages"
{
  pipx uninstall-all && sudo pip3 uninstall -q -y pipx
  find /usr/share /usr/lib ~/.local/lib -depth -type d -name __pycache__ \
    -exec rm -rf '{}' + 2>/dev/null;
} &>/dev/null
echo "::endgroup::"

echo "::group::Removing Lots of Cached Programs & Unneeded Folders"
printf "Removing Runner Tool Cache, Android SDK, NDK, Platform Tools, Gradle, Maven...\n"
parallel --use-cpus-instead-of-cores sudo rm -rf -- {} 2>/dev/null ::: /opt/hostedtoolcache ::: /usr/local/lib/android ::: /usr/share/gradle* /usr/bin/gradle /usr/share/apache-maven* /usr/bin/mvn
printf "Removing Microsoft vcpkg, Miniconda, Leiningen, Pulumi...\n"
parallel --use-cpus-instead-of-cores sudo rm -rf -- {} 2>/dev/null ::: /usr/local/share/vcpkg /usr/local/bin/vcpkg ::: /usr/share/miniconda ::: /usr/bin/conda /usr/local/lib/lein /usr/local/bin/lein /usr/local/bin/pulumi*
printf "Removing Browser-based Webdrivers, PHP, Composer, Database Management Program Remains...\n"
parallel --use-cpus-instead-of-cores sudo rm -rf -- {} 2>/dev/null ::: /usr/share/java/selenium-server-standalone.jar /usr/local/share/phantomjs* /usr/local/bin/phantomjs /usr/local/share/chrome_driver /usr/bin/chromedriver /usr/local/share/gecko_driver /usr/bin/geckodriver ::: /etc/php /usr/bin/composer /usr/local/bin/phpunit ::: /var/lib/mysql /etc/mysql /usr/local/bin/sqlcmd /usr/local/bin/bcp /usr/local/bin/session-manager-plugin
printf "Removing Julia, Rust, Cargo, Rubygems, Rake, Swift, Haskell, Erlang...\n"
parallel --use-cpus-instead-of-cores sudo rm -rf -- {} 2>/dev/null ::: /usr/local/julia* /usr/bin/julia ::: /usr/share/rust /home/runner/.cargo /home/runner/.rustup /home/runner/.ghcup ::: /usr/local/bin/rake /usr/local/bin/rdoc /usr/local/bin/ri /usr/local/bin/racc /usr/local/bin/rougify ::: /usr/local/bin/bundle /usr/local/bin/bundler /var/lib/gems ::: /usr/share/swift /usr/local/bin/swift /usr/local/bin/swiftc /usr/bin/ghc /usr/local/.ghcup /usr/local/bin/stack /usr/local/bin/rebar3 /usr/share/sbt /usr/bin/sbt /usr/bin/go /usr/bin/gofmt
printf "Removing Various Cloud CLI Tools, Different Kubernetes & Container Management Programs...\n"
parallel --use-cpus-instead-of-cores sudo rm -rf -- {} 2>/dev/null ::: /usr/local/bin/aws /usr/local/bin/aws_completer /usr/local/aws-cli /usr/local/aws /usr/local/bin/aliyun /usr/share/az_* /opt/az /usr/bin/az /usr/local/bin/azcopy* /usr/bin/azcopy /usr/lib/azcopy /usr/local/bin/oc /usr/local/bin/oras ::: /usr/local/bin/packer /usr/local/bin/terraform /usr/local/bin/helm /usr/local/bin/kubectl /usr/local/bin/kind /usr/local/bin/kustomize /usr/local/bin/minikube /usr/libexec/catatonit/catatonit
printf "Removing Microsoft dotnet Application Remains, Java GraalVM, Manpages, Remains of Apt Package Caches...\n"
parallel --use-cpus-instead-of-cores sudo rm -rf -- {} 2>/dev/null ::: /usr/share/dotnet ::: /usr/local/graalvm ::: /usr/share/man ::: /var/lib/apt/lists/* /var/cache/apt/archives/*
echo "::endgroup::"

echo "::group::Clearing Unwanted Environment Variables"
printf "This However is Not Retained after the Step is finished. So this part might be removed in the future.\n"
{
  sudo sed -i -e '/^PATH=/d;/hostedtoolcache/d;/^AZURE/d;/^SWIFT/d;/^DOTNET/d;/DRIVER/d;/^CHROME/d;/HASKELL/d;/^JAVA/d;/^SELENIUM/d;/^GRAALVM/d;/^ANT/d;/^GRADLE/d;/^LEIN/d;/^CONDA/d;/^VCPKG/d;/^ANDROID/d;/^PIPX/d;/^HOMEBREW/d;' /etc/environment
  sudo sed -i '1i PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin' /etc/environment
  sed -i '/HOME\/\.local\/bin/d' /home/runner/.bashrc
  source /home/runner/.bashrc
} &>/dev/null
echo "::endgroup::"

echo "::group::Disk Space After Cleanup"
df -hlT /
echo "::endgroup::"

printf "\nIf this action really helped you,\n Go to https://github.com/marketplace/actions/github-actions-cleaner\n And show your love by giving a star.\n\n"

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

