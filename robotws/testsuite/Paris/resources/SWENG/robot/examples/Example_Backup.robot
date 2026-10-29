*** Settings ***
Documentation
...          Just an exemple about how to use the backup tool

Resource                            ../Tools.robot
Resource                            ../Connect.robot
Resource                            ../WtsCfgConfig.robot
Resource                            ../Backup.robot
Library                             ../../python/StringTool.py
Library                             ../../python/OsTool.py

Suite Setup                         Suite Setup
# Suite Teardown                      Suite Teardown

*** Variables ***
${TMP_DIR}                          /tmp/TEST_FILE
${TARGET_HOST}                      ${GNB_DU.sys[0].M}

${CONTENT}                          Content
${MODIF}                            Modif
${LINKED_FILE}                      AEQA_iphy.xml

&{FD_TEST_FILE}                     name=GNB_SWCONFIG                       host=${TARGET_HOST}
...                                 path=${TMP_DIR}                         fileName=swconfig.txt
...                                 method=${EMPTY}                         type=${TYPE_FILE}

&{FD_TEST_LINK}                     name=AP_IPHY_XML                        host=${TARGET_HOST}
...                                 path=${TMP_DIR}                         fileName=iphy.xml
...                                 method=${EMPTY}                         type=${TYPE_LINK}


*** Test Cases ***
Test bidon
    Dated log                       Hello


Test Suite Backup
    Suite Setup                     listBackupFiles=${FD_ALL}
    Dated log                       Test
    Suite Teardown

Test Basic
    [setup]
    Dated log                       Hello
    FOR    ${fd}   IN              @{FD_ALL}
            Print Desc File         ${fd}
    END
    Backup files                    ${FD_ALL}


Backup File no file no Ori
    Reset Context
    ${status}                       Run keyword and return status
    ...                             Backup File                             fileDesc=${FD_TEST_FILE}
    Dated log                       BACKUP:Status=${status}
    Should not be True              ${status}

Backup File one real file
    # Preparation ------------------
    Reset Context
    ${fullPath}                     set variable                            ${FD_TEST_FILE.path}/${FD_TEST_FILE.fileName}
    Add real file                   fullPath=${fullPath}
    ...                             content=${CONTENT}
    # Backup -----------------------
    Dated log                       Start BACKUP
    Backup File                     fileDesc=${FD_TEST_FILE}
    # Modif ------------------------
    Dated log                       Start MODIF
    Backup CMD                      echo "${MODIF}" >> ${fullPath}          alias=${FD_TEST_FILE.host.alias}
    # Checks ------------------------
    Dated log                       Start CHECK
    Check Backup                    fileDesc=${FD_TEST_FILE}

Backup File one real file and one Ori
    # Preparation ------------------
    Reset Context
    ${fullPath}                     set variable                            ${FD_TEST_FILE.path}/${FD_TEST_FILE.fileName}
    Add real file                   fullPath=${fullPath}
    ...                             content=${CONTENT}
    Add real file                   fullPath=${fullPath}${ORI_EXT}
    ...                             content=${CONTENT}_ORI
    # Backup -----------------------
    Dated log                       Start BACKUP
    Backup File                     fileDesc=${FD_TEST_FILE}
    # Modif ------------------------
    Dated log                       Start MODIF
    Backup CMD                      echo "${MODIF}" >> ${fullPath}          alias=${FD_TEST_FILE.host.alias}
    # Checks ------------------------
    Dated log                       Start CHECK
    Check Backup                    fileDesc=${FD_TEST_FILE}
    # Check <F>.ori no more contain _ORI
    Dated log                       \tCheck <F>.ori does not contain _ORI anymore
    ${diffStr}                      Backup CMD                              alias=${TARGET_HOST.alias}
    ...                             command=grep "_ORI" ${fullPath}${ORI_EXT} | wc -l
    ${diffStr}                      getStringFromCmdReturn                  ${diffStr}
    Should be equal                 ${diffStr}                              0

Backup File one link on Ori and one Ori
    # Preparation ------------------
    Reset Context
    ${fullPath}                     set variable                            ${FD_TEST_FILE.path}/${FD_TEST_FILE.fileName}
    Add real file                   fullPath=${fullPath}${ORI_EXT}
    ...                             content=${CONTENT}_ORI
    Add link file                   fileDesc=${FD_TEST_FILE}                targetPath=${fullPath}${ORI_EXT}
    # Backup -----------------------
    Dated log                       Start BACKUP
    Backup File                     fileDesc=${FD_TEST_FILE}
    # Modif ------------------------
    Dated log                       Start MODIF
    Backup CMD                      echo "${MODIF}" >> ${fullPath}          alias=${FD_TEST_FILE.host.alias}
    # Checks ------------------------
    Dated log                       Start CHECK
    Check Backup                    fileDesc=${FD_TEST_FILE}
    # Check <F>.ori no more contain _ORI
    Dated log                       \tCheck <F>.ori still contain _ORI
    ${diffStr}                      Backup CMD                              alias=${TARGET_HOST.alias}
    ...                             command=grep "_ORI" ${fullPath}${ORI_EXT} | wc -l
    ${diffStr}                      getStringFromCmdReturn                  ${diffStr}
    Should be equal                 ${diffStr}                              1

Backup File one link on Other and one Ori
    # Preparation ------------------
    Reset Context
    ${fullPath}                     set variable                            ${FD_TEST_FILE.path}/${FD_TEST_FILE.fileName}
    Add real file                   fullPath=${fullPath}${ORI_EXT}
    ...                             content=${CONTENT}_ORI
    Add link file                   fileDesc=${FD_TEST_FILE}                targetPath=${fullPath}.Other
    # Backup -----------------------
    Dated log                       Start BACKUP
    Backup File                     fileDesc=${FD_TEST_FILE}
    # Modif ------------------------
    Dated log                       Start MODIF
    Backup CMD                      echo "${MODIF}" >> ${fullPath}          alias=${FD_TEST_FILE.host.alias}
    # Checks ------------------------
    Dated log                       Start CHECK
    Check Backup                    fileDesc=${FD_TEST_FILE}
    # Check <F>.ori no more contain _ORI
    Dated log                       \tCheck <F>.ori still contain _ORI
    ${diffStr}                      Backup CMD                              alias=${TARGET_HOST.alias}
    ...                             command=grep "_ORI" ${fullPath}${ORI_EXT} | wc -l
    ${diffStr}                      getStringFromCmdReturn                  ${diffStr}
    Should be equal                 ${diffStr}                              1

Backup File one link on ts and one Ori
    # Preparation ------------------
    Reset Context
    ${fullPath}                     set variable                            ${FD_TEST_FILE.path}/${FD_TEST_FILE.fileName}
    Add real file                   fullPath=${fullPath}${ORI_EXT}
    ...                             content=${CONTENT}_ORI
    ${tsName}                       getFormattedTestName
    Add link file                   fileDesc=${FD_TEST_FILE}                targetPath=${fullPath}.${tsName}
    # Backup -----------------------
    Dated log                       Start BACKUP
    Backup File                     fileDesc=${FD_TEST_FILE}
    # Modif ------------------------
    Dated log                       Start MODIF
    Backup CMD                      echo "${MODIF}" >> ${fullPath}          alias=${FD_TEST_FILE.host.alias}
    # Checks ------------------------
    Dated log                       Start CHECK
    Check Backup                    fileDesc=${FD_TEST_FILE}
    # Check <F>.ori no more contain _ORI
    Dated log                       \tCheck <F>.ori still contain _ORI
    ${diffStr}                      Backup CMD                              alias=${TARGET_HOST.alias}
    ...                             command=grep "_ORI" ${fullPath}${ORI_EXT} | wc -l
    ${diffStr}                      getStringFromCmdReturn                  ${diffStr}
    Should be equal                 ${diffStr}                              1

Restore File one file and one Ori
    # Preparation ------------------
    Reset Context
    ${fullPath}                     set variable                            ${FD_TEST_FILE.path}/${FD_TEST_FILE.fileName}
    Add real file                   fullPath=${fullPath}
    ...                             content=${CONTENT}
    Add real file                   fullPath=${fullPath}${ORI_EXT}
    ...                             content=${CONTENT}_ORI
    # Restore ----------------------
    Dated log                       Start RESTORE
    Restore File                    fileDesc=${FD_TEST_FILE}

Restore File one link on Ori and one Ori
    # Preparation ------------------
    Reset Context
    ${fullPath}                     set variable                            ${FD_TEST_FILE.path}/${FD_TEST_FILE.fileName}
    Add link file                   fileDesc=${FD_TEST_FILE}                targetPath=${fullPath}${ORI_EXT}
    Add real file                   fullPath=${fullPath}${ORI_EXT}
    ...                             content=${CONTENT}_ORI
    # Restore ----------------------
    Dated log                       Start RESTORE
    Restore File                    fileDesc=${FD_TEST_FILE}
    # Check ------------------------
    Check Restore                   fileDesc=${FD_TEST_FILE}

Restore File one link on ts and one Ori
    # Preparation ------------------
    Reset Context
    ${fullPath}                     set variable                            ${FD_TEST_FILE.path}/${FD_TEST_FILE.fileName}
    ${tsName}                       getFormattedTestName
    Add link file                   fileDesc=${FD_TEST_FILE}                targetPath=${fullPath}.${tsName}
    Add real file                   fullPath=${fullPath}.${tsName}
    ...                             content=${CONTENT}_TS
    Add real file                   fullPath=${fullPath}${ORI_EXT}
    ...                             content=${CONTENT}_ORI
    # Restore ----------------------
    Dated log                       Start RESTORE
    Restore File                    fileDesc=${FD_TEST_FILE}
    # Check ------------------------
    Check Restore                   fileDesc=${FD_TEST_FILE}

Restore File one link on ts but no Ori
    # Preparation ------------------
    Reset Context
    ${fullPath}                     set variable                            ${FD_TEST_FILE.path}/${FD_TEST_FILE.fileName}
    ${tsName}                       getFormattedTestName
    Add link file                   fileDesc=${FD_TEST_FILE}                targetPath=${fullPath}.${tsName}
    Add real file                   fullPath=${fullPath}.${tsName}
    ...                             content=${CONTENT}_TS
    # Restore ----------------------
    Dated log                       Start RESTORE
    ${status}                       Run keyword and return status
    ...                             Restore File                            fileDesc=${FD_TEST_FILE}
    Should not be True              ${status}


Backup Link L is a file
    # Preparation ------------------
    Reset Context
    ${fullPath}                     set variable                            ${FD_TEST_LINK.path}/${FD_TEST_LINK.fileName}
    ${linkedPath}                   set variable                            ${FD_TEST_LINK.path}/${LINKED_FILE}
    Add real file                   fullPath=${linkedPath}
    ...                             content=${CONTENT}
    Add link file                   fileDesc=${FD_TEST_LINK}                targetPath=${linkedPath}
    # Backup -----------------------
    Dated log                       Start BACKUP
    Backup File                     fileDesc=${FD_TEST_LINK}
    # Modif ------------------------
    Dated log                       Start MODIF
    Backup CMD                      echo "${MODIF}" >> ${fullPath}          alias=${FD_TEST_FILE.host.alias}
    # Checks ------------------------
    Dated log                       Start CHECK
    Check Backup Link               fileDesc=${FD_TEST_LINK}

Backup Link L is a link on ori and ori
    # Preparation ------------------
    Reset Context
    ${fullPath}                     set variable                            ${FD_TEST_LINK.path}/${FD_TEST_LINK.fileName}
    ${linkedPath}                   set variable                            ${FD_TEST_LINK.path}/${LINKED_FILE}
    Add real file                   fullPath=${linkedPath}${ORI_EXT}
    ...                             content=${CONTENT}_ORI
    Add link file                   fileDesc=${FD_TEST_LINK}                targetPath=${linkedPath}
    Add link file from Path         path=${FD_TEST_LINK.path}/${LINKED_FILE}
    ...                             targetPath=${linkedPath}${ORI_EXT}
    # Backup -----------------------
    Dated log                       Start BACKUP
    Backup File                     fileDesc=${FD_TEST_LINK}
    # Modif ------------------------
    Dated log                       Start MODIF
    Backup CMD                      echo "${MODIF}" >> ${fullPath}          alias=${FD_TEST_FILE.host.alias}
    # Checks ------------------------
    Dated log                       Start CHECK
    Check Backup Link               fileDesc=${FD_TEST_LINK}

Backup Link L is a link on ts and ori
    # Preparation ------------------
    Reset Context
    ${tsName}                       getFormattedTestName
    ${fullPath}                     set variable                            ${FD_TEST_LINK.path}/${FD_TEST_LINK.fileName}
    ${linkedPath}                   set variable                            ${FD_TEST_LINK.path}/${LINKED_FILE}
    Add real file                   fullPath=${linkedPath}${ORI_EXT}
    ...                             content=${CONTENT}_ORI
    Add real file                   fullPath=${linkedPath}.${tsName}
    ...                             content=${CONTENT}_TS
    Add link file                   fileDesc=${FD_TEST_LINK}                targetPath=${linkedPath}
    Add link file from Path         path=${FD_TEST_LINK.path}/${LINKED_FILE}
    ...                             targetPath=${linkedPath}.${tsName}
    # Backup -----------------------
    Dated log                       Start BACKUP
    Backup File                     fileDesc=${FD_TEST_LINK}
    # Modif ------------------------
    Dated log                       Start MODIF
    Backup CMD                      echo "${MODIF}" >> ${fullPath}          alias=${FD_TEST_FILE.host.alias}
    # Checks ------------------------
    Dated log                       Start CHECK
    Check Backup Link               fileDesc=${FD_TEST_LINK}

*** Keywords ***
Reset Context
    ${alias}                        SSH Connect                             ${TARGET_HOST}
    Dated Log New Line              Reset contexte in ${FD_TEST_FILE.path}
    Backup CMD                      command=rm -Rf ${FD_TEST_FILE.path}/*   alias=${alias}

Add real file
    [Arguments]                     ${fullPath}                             ${content}
    ${alias}                        SSH Connect                             ${TARGET_HOST}
    ${path}                         getDirFromPath                          ${fullPath}
    ${file}                         getFileNameFromPath                     ${fullPath}
    ${cmd}                          set variable                            mkdir -p ${path};echo "${content}" >${fullPath}
    Backup CMD                      command=${cmd}                          alias=${alias}

Add link file
    [Arguments]                     ${fileDesc}                             ${targetPath}
    ${alias}                        SSH Connect                             ${TARGET_HOST}
    Backup CMD                      cd ${fileDesc.path};ln -s ${targetPath} ${fileDesc.fileName}
    ...                             alias=${alias}

Add link file From Path
    [Arguments]                     ${path}                                 ${targetPath}
    ${alias}                        SSH Connect                             ${TARGET_HOST}
    ${dirName}                      getDirFromPath                          ${path}
    ${fileName}                     getFileNameFromPath                     ${path}
    Backup CMD                      cd ${dirName};ln -s ${targetPath} ${fileName}
    ...                             alias=${alias}

Check Backup
    [Arguments]                     ${fileDesc}
    ${fullPath}                     Set Variable                            ${fileDesc.path}/${fileDesc.fileName}
    ${backupPath}                   Set Variable                            ${fileDesc.path}/${fileDesc.fileName}${ORI_EXT}
    ${tsName}                       getFormattedTestName
    ${tsPath}                       Set Variable                            ${fileDesc.path}/${fileDesc.fileName}.${tsName}
    # Check <F> is a link on .<ts>
    Dated log                       \tCheck:<F> is a link
    ${status}                       My File Status                          host=${TARGET_HOST}
    ...                             path=${fullPath}
    Should be equal                 ${status.type}                          LINK
    Should be equal                 ${status.linked}                        ${tsPath}
    # check <F>.ori is a file
    Dated log                       \tCheck:<F>.ori is a file
    ${status}                       My File Status                          host=${TARGET_HOST}
    ...                             path=${backupPath}
    Should be equal                 ${status.type}                          FILE
    # check <F>.ts is a file
    Dated log                       \tCheck:<F>.ts is a file
    ${status}                       My File Status                          host=${TARGET_HOST}
    ...                             path=${tsPath}
    Should be equal                 ${status.type}                          FILE
    # Check diff <F> <F>.ori is not null
    Dated log                       \tCheck diff <F> <F>.ori is not null
    ${diffStr}                      Backup CMD                              alias=${TARGET_HOST.alias}
    ...                             command=diff ${fullPath} ${backupPath} | grep "${MODIF}" | wc -l
    ${diffStr}                      getStringFromCmdReturn                  ${diffStr}
    Should be equal                 ${diffStr}                              1
    # Check diff <F> <F>.<TS> is null
    Dated log                       \tCheck diff <F> <F>.<TS> is null
    ${diffStr}                      Backup CMD                              alias=${TARGET_HOST.alias}
    ...                             command=diff ${fullPath} ${tsPath} | wc -l
    ${diffStr}                      getStringFromCmdReturn                  ${diffStr}
    Should be equal                 ${diffStr}                              0

Check Backup Link
    [Arguments]                     ${fileDesc}
    ${fullPath}                     Set Variable                            ${fileDesc.path}/${LINKED_FILE}
    ${backupPath}                   Set Variable                            ${fileDesc.path}/${LINKED_FILE}${ORI_EXT}
    ${tsName}                       getFormattedTestName
    ${tsPath}                       Set Variable                            ${fileDesc.path}/${LINKED_FILE}.${tsName}
    # Check <F> is a link on .<ts>
    Dated log                       \tCheck:<L> is a link
    ${status}                       My File Status                          host=${TARGET_HOST}
    ...                             path=${fullPath}
    Should be equal                 ${status.type}                          LINK
    Should be equal                 ${status.linked}                        ${tsPath}
    # check <L>.ori is a file
    Dated log                       \tCheck:<L>.ori is a file
    ${status}                       My File Status                          host=${TARGET_HOST}
    ...                             path=${backupPath}
    Should be equal                 ${status.type}                          FILE
    # check <L>.ts is a file
    Dated log                       \tCheck:<L>.ts is a file
    ${status}                       My File Status                          host=${TARGET_HOST}
    ...                             path=${tsPath}
    Should be equal                 ${status.type}                          FILE
    # Check diff <F> <F>.ori is not null
    Dated log                       \tCheck diff <L> <L>.ori is not null
    ${diffStr}                      Backup CMD                              alias=${TARGET_HOST.alias}
    ...                             command=diff ${fullPath} ${backupPath} | grep "${MODIF}" | wc -l
    ${diffStr}                      getStringFromCmdReturn                  ${diffStr}
    Should be equal                 ${diffStr}                              1
    # Check diff <L> <L>.<TS> is null
    Dated log                       \tCheck diff <L> <L>.<TS> is null
    ${diffStr}                      Backup CMD                              alias=${TARGET_HOST.alias}
    ...                             command=diff ${fullPath} ${tsPath} | wc -l
    ${diffStr}                      getStringFromCmdReturn                  ${diffStr}
    Should be equal                 ${diffStr}                              0

Check Restore
    [Arguments]                     ${fileDesc}
    ${fullPath}                     Set Variable                            ${fileDesc.path}/${fileDesc.fileName}
    ${backupPath}                   Set Variable                            ${fileDesc.path}/${fileDesc.fileName}${ORI_EXT}
    ${tsName}                       getFormattedTestName
    ${tsPath}                       Set Variable                            ${fileDesc.path}/${fileDesc.fileName}.${tsName}
    # Check <F> is a link on .ori
    Dated log                       \tCheck:<F> is a link
    ${status}                       My File Status                          host=${TARGET_HOST}
    ...                             path=${fullPath}
    Should be equal                 ${status.type}                          LINK
    Should be equal                 ${status.linked}                        ${backupPath}
    # check <F>.ori is a file
    Dated log                       \tCheck:<F>.ori is a file
    ${status}                       My File Status                          host=${TARGET_HOST}
    ...                             path=${backupPath}
    Should be equal                 ${status.type}                          FILE
    # Check diff <F> <F>.ori is null
    Dated log                       \tCheck diff <F> <F>.ori is null
    ${diffStr}                      Backup CMD                              alias=${TARGET_HOST.alias}
    ...                             command=diff ${fullPath} ${backupPath} | wc -l
    ${diffStr}                      getStringFromCmdReturn                  ${diffStr}
    Should be equal                 ${diffStr}                              0

My File Status
    [Arguments]                     ${host}                                 ${path}
    ${status}                       File status                             host=${host}
    ...                             path=${path}
    Dated log                       \t\tStatus[${path}]:Type=${status.type} Linked=${status.linked}
    [Return]                        ${status}
