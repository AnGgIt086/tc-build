#!/usr/bin/env bash

echo "
## OrangeFox Recovery Build
🖥 OrangeFox Branch: ${FOX_BRANCH}
📱 Device: ${DEVICE}
📝 CodeName: ${CODENAME}
📂 Size: ${ORF_SIZE}
👩‍💻 Top Commit: ${DT_COMMIT}
📕 MD5: ${ORF_MD5}
📘 SHA1: ${ORF_SHA1}
" >> ${CIRRUS_WORKING_DIR}/release-notes.md
