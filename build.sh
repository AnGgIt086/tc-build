#!/bin/bash

set +e
source config.sh
timeStart
cd ${GITHUB_ACTION_PATH}/OrangeFox/fox_${{ inputs.FOX_SYNC_BRANCH }}
echo "##########################################"
echo "$(figlet "OrageFox")"
echo "##########################################"
source build/envsetup.sh
export ALLOW_MISSING_DEPENDENCIES=true
BUILDLOG="${GITHUB_ACTION_PATH}/OrangeFox/fox_${{ inputs.FOX_SYNC_BRANCH }}/build.log"
DEVICE=$(grep "PRODUCT_MODEL :=" ${GITHUB_ACTION_PATH}/OrangeFox/fox_${{ inputs.FOX_SYNC_BRANCH }}/${{ inputs.DEVICE_PATH }}/twrp_*.mk -m 1 | cut -d = -f 2)
set -e
build_message "lunch twrp_${{ inputs.DEVICE_NAME }}-eng"
lunch twrp_${{ inputs.DEVICE_NAME }}-eng
sleep 5
build_message "Building... 🛠️"
mkfifo -m 644 reading
tee -a ${BUILDLOG} < reading & progress & mka adbd ${{ inputs.BUILD_TARGET }}image -j$(nproc --all) > reading
retVal=$?
timeEnd
statusBuild
EV1=$(TZ=Asia/Jakarta date +%Y%m%d)
EV2=$(grep "PRODUCT_MODEL :=" ${GITHUB_ACTION_PATH}/OrangeFox/fox_${{ inputs.FOX_SYNC_BRANCH }}/${{ inputs.DEVICE_PATH }}/twrp_*.mk -m 1 | cut -d = -f 2)
EV3=$(ls -lh ${GITHUB_ACTION_PATH}/OrangeFox/fox_${{ inputs.FOX_SYNC_BRANCH }}/out/target/product/${{ inputs.DEVICE_NAME }}/OrangeFox*.zip | cut -d ' ' -f5)
EV4=$(md5sum ${GITHUB_ACTION_PATH}/OrangeFox/fox_${{ inputs.FOX_SYNC_BRANCH }}/out/target/product/${{ inputs.DEVICE_NAME }}/OrangeFox*.zip | cut -d ' ' -f1)
EV5=$(sha1sum ${GITHUB_ACTION_PATH}/OrangeFox/fox_${{ inputs.FOX_SYNC_BRANCH }}/out/target/product/${{ inputs.DEVICE_NAME }}/OrangeFox*.zip | cut -d ' ' -f1)
EV6=$(cd ${GITHUB_ACTION_PATH}/OrangeFox/fox_${{ inputs.FOX_SYNC_BRANCH }}/${{ inputs.DEVICE_PATH }} && git log --pretty=format:'%s' -1)
EV10=$(grep "#### build completed successfully" ${GITHUB_ACTION_PATH}/OrangeFox/fox_${{ inputs.FOX_SYNC_BRANCH }}/build.log -m 1 | cut -d '(' -f 2)
export BUILD_DATE=${EV1}
export DEVICE=${EV2}
export ORF_SIZE=${EV3}
export ORF_MD5=${EV4}
export ORF_SHA1=${EV5}
export DT_COMMIT=${EV6}
export ORF_ACTOR=${{ github.actor }}
export ORF_REPONAME=${{ github.event.repository.name }}
export ORF_ID=${{ github.run_id }}
export ORF_TIME=${EV10}
if [[ "${{ inputs.GH_RELEASE }}" == true ]]; then
    source config.sh
    bash notes.sh
    gh release create ${{ github.run_id }} ${GITHUB_ACTION_PATH}/OrangeFox/fox_${{ inputs.FOX_SYNC_BRANCH }}/out/target/product/${{ inputs.DEVICE_NAME }}/OrangeFox*.zip ${GITHUB_ACTION_PATH}/OrangeFox/fox_${{ inputs.FOX_SYNC_BRANCH }}/out/target/product/${{ inputs.DEVICE_NAME }}/OrangeFox*.zip.md5 --title "🦊 OrangeFox Recovery for ${DEVICE} (${CODENAME}) // ${BUILD_DATE}" -F ${GITHUB_ACTION_PATH}/release-notes.md -R "https://github.com/${{ github.repository }}"
    post_message
else
    echo -e ${cya} "##########################################"
    echo -e ${cya} "$(figlet "OrageFox")"
    echo -e ${cya} "##########################################"
fi


exit 0
