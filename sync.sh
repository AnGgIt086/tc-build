#!/bin/bash

source "${CONFIG}"
mkdir -p "${CIRRUS_WORKING_DIR}"/Orangefox
git config --global user.name "${USER_NAME}"
git config --global user.email "${USER_EMAIL}"
echo "${GITHUB_TOKEN}" >> ikitoken.txt
unset GITHUB_TOKEN
gh auth login --with-token < ikitoken.txt
git clone --single-branch "${FOX_SYNC}" "${CIRRUS_WORKING_DIR}"/Orangefox/sync --depth=1
cd "${CIRRUS_WORKING_DIR}"/Orangefox/sync
./orangefox_sync.sh --branch "${FOX_SYNC_BRANCH}" --path "${CIRRUS_WORKING_DIR}"/Orangefox/fox_"${FOX_SYNC_BRANCH}"
if [[ ! -d ${CIRRUS_WORKING_DIR}"/Orangefox/fox_"${FOX_SYNC_BRANCH}/bootable/recovery/gui/theme ]]; then
    echo "Adding Theme..."
    git clone https://gitlab.com/OrangeFox/misc/theme.git ${CIRRUS_WORKING_DIR}"/Orangefox/fox_"${FOX_SYNC_BRANCH}/bootable/recovery/gui/theme
fi
if [[ ! -d ${CIRRUS_WORKING_DIR}"/Orangefox/fox_"${FOX_SYNC_BRANCH}/external/nano ]]; then
    echo "Adding Nano Library..."
    git clone https://github.com/LineageOS/android_external_nano -b lineage-19.1 ${CIRRUS_WORKING_DIR}"/Orangefox/fox_"${FOX_SYNC_BRANCH}/external/nano
fi
if [[ ! -d ${CIRRUS_WORKING_DIR}"/Orangefox/fox_"${FOX_SYNC_BRANCH}/external/libncurses ]]; then
    echo "Adding libncurses Library..."
    git clone https://github.com/LineageOS/android_external_libncurses -b lineage-19.1 ${CIRRUS_WORKING_DIR}"/Orangefox/fox_"${FOX_SYNC_BRANCH}/external/libncurses
fi
if [[ ! -d ${CIRRUS_WORKING_DIR}"/Orangefox/fox_"${FOX_SYNC_BRANCH}/external/bash ]]; then
    echo "Adding Bash Library..."
    git clone https://github.com/LineageOS/android_external_bash -b lineage-19.1 ${CIRRUS_WORKING_DIR}"/Orangefox/fox_"${FOX_SYNC_BRANCH}/external/bash
fi
if [[ ! -d ${CIRRUS_WORKING_DIR}"/Orangefox/fox_"${FOX_SYNC_BRANCH}/external/lptools ]]; then
    echo "Adding lptools Library..."
    git clone https://github.com/phhusson/vendor_lptools ${CIRRUS_WORKING_DIR}"/Orangefox/fox_"${FOX_SYNC_BRANCH}/external/lptools
fi
if [[ ! -z "${MAINTAINER_URL}" ]]; then
    echo "Change Maintainer Profile..."
    wget "${MAINTAINER_URL}" -O "${CIRRUS_WORKING_DIR}"/maintainer.png
    cp -r "${CIRRUS_WORKING_DIR}"/maintainer.png ${CIRRUS_WORKING_DIR}"/Orangefox/fox_"${FOX_SYNC_BRANCH}/bootable/recovery/gui/theme/portrait_hdpi/images/Default/About
fi
if [[ ! -z "${KERNEL_TREE}" ]]; then
    echo "Clonning Kernel Tree..."
    git clone "${KERNEL_TREE}" -b "${KERNEL_BRANCH}" "${CIRRUS_WORKING_DIR}"/Orangefox/fox_"${FOX_SYNC_BRANCH}/${KERNEL_PATH}"
fi
if [[ ! -z "${COMMON_TREE}" ]]; then
    echo "Clonning Common Tree..."
    git clone "${COMMON_TREE}" -b "${COMMON_BRANCH}" "${CIRRUS_WORKING_DIR}"/Orangefox/fox_"${FOX_SYNC_BRANCH}/${COMMON_PATH}"
fi
if [[ ! -z "${DEVICE_TREE}" ]]; then
    echo "Clonning Device Tree..."
    git clone "${DEVICE_TREE}" -b "${DEVICE_TREE_BRANCH}" "${CIRRUS_WORKING_DIR}"/Orangefox/fox_"${FOX_SYNC_BRANCH}/${DEVICE_PATH}"
fi

exit 0
