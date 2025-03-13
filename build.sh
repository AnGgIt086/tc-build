#!/bin/bash

set +e
source ${CONFIG}
timeStart
cd ${CIRRUS_WORKING_DIR}/OrangeFox/fox_${FOX_SYNC_BRANCH}
source build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
BUILDLOG="${CIRRUS_WORKING_DIR}/OrangeFox/fox_${FOX_SYNC_BRANCH}/build.log"
DEVICE=$(grep "PRODUCT_MODEL :=" ${CIRRUS_WORKING_DIR}/OrangeFox/fox_${FOX_SYNC_BRANCH}/${DEVICE_PATH}/twrp_*.mk -m 1 | cut -d = -f 2)
set -e
build_message "lunch twrp_${DEVICE_NAME}-eng"
lunch twrp_${DEVICE_NAME}-eng
sleep 5
build_message "Building... 🛠️"
mkfifo -m 644 reading
tee -a ${BUILDLOG} < reading & progress & mka adbd ${BUILD_TARGET}image -j$(nproc --all) > reading
retVal=$?
timeEnd
statusBuild
EV1=$(TZ=Asia/Jakarta date +%Y%m%d)
EV2=$(grep "PRODUCT_MODEL :=" ${CIRRUS_WORKING_DIR}/OrangeFox/fox_${FOX_SYNC_BRANCH}/${DEVICE_PATH}/twrp_*.mk -m 1 | cut -d = -f 2)
EV3=$(ls -lh ${CIRRUS_WORKING_DIR}/OrangeFox/fox_${FOX_SYNC_BRANCH}/out/target/product/${DEVICE_NAME}/OrangeFox*.zip | cut -d ' ' -f5)
EV4=$(md5sum ${CIRRUS_WORKING_DIR}/OrangeFox/fox_${FOX_SYNC_BRANCH}/out/target/product/${DEVICE_NAME}/OrangeFox*.zip | cut -d ' ' -f1)
EV5=$(sha1sum ${CIRRUS_WORKING_DIR}/OrangeFox/fox_${FOX_SYNC_BRANCH}/out/target/product/${DEVICE_NAME}/OrangeFox*.zip | cut -d ' ' -f1)
EV6=$(cd ${CIRRUS_WORKING_DIR}/OrangeFox/fox_${FOX_SYNC_BRANCH}/${DEVICE_PATH} && git log --pretty=format:'%s' -1)
EV10=$(grep "#### build completed successfully" ${CIRRUS_WORKING_DIR}/OrangeFox/fox_${FOX_SYNC_BRANCH}/build.log -m 1 | cut -d '(' -f 2)
export BUILD_DATE=${EV1}
export DEVICE=${EV2}
export ORF_SIZE=${EV3}
export ORF_MD5=${EV4}
export ORF_SHA1=${EV5}
export DT_COMMIT=${EV6}
export ORF_ACTOR=${CIRRUS_REPO_OWNER}
export ORF_REPONAME=${CIRRUS_REPO_NAME}
export ORF_ID=${CIRRUS_BUILD_ID}
export ORF_TIME=${EV10}
if [[ "${GH_RELEASE}" == true ]]; then
    cd ${CIRRUS_WORKING_DIR}
    source ${CONFIG}
    bash notes.sh
    gh release create ${ORF_ID} ${CIRRUS_WORKING_DIR}/OrangeFox/fox_${FOX_SYNC_BRANCH}/out/target/product/${DEVICE_NAME}/OrangeFox*.zip ${CIRRUS_WORKING_DIR}/OrangeFox/fox_${FOX_SYNC_BRANCH}/out/target/product/${DEVICE_NAME}/OrangeFox*.zip.md5 --title "🦊 OrangeFox Recovery for ${DEVICE} (${DEVICE_NAME}) // ${BUILD_DATE}" -F ${CIRRUS_WORKING_DIR}/release-notes.md -R ${CIRRUS_REPO_CLONE_URL}
    post_message
fi

exit 0
