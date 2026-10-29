*** Settings ***
Documentation
...               Backup Files Management

Resource                            Tools.robot
Resource                            Connect.robot
Resource                            Setup.robot
Library                             ../python/OsTool.py
Library                             ../python/StringTool.py

*** Variables ***
#${DBG_BACKUP}                       ${True}
${DBG_BACKUP}                       ${False}
${ORI_EXT}                          .ori
${TYPE_FILE}                        ${1}
${TYPE_LINK}                        ${2}
${TL_CORE_PATH_PATTERN}             TL_CORE_PATH_PATTERN
${TL_CORE_FILE_PATTERN}             TL_CORE_FILE_PATTERN

&{FD_GNB_SWCONFIG}                  name=GNB_SWCONFIG                       host=${AIRSCALE_GNB.sys[0].M}
...                                 path=/ffs/run                           fileName=swconfig.txt
...                                 method=${EMPTY}                         type=${TYPE_FILE}

&{FD_AP_SWCONFIG}                   name=AP_SWCONFIG                        host=${AIRSCALE_AP.sys[0].M}
...                                 path=/ffs/run                           fileName=swconfig.txt
...                                 method=${EMPTY}                         type=${TYPE_FILE}

&{FD_WTS_CFG}                       name=WTS_CFG                            host=${HOST_EPCSIM}
...                                 path=${TL_CORE_PATH_PATTERN}            fileName=${TL_CORE_FILE_PATTERN}
#...                                 path=${tl.core.dir_path}                fileName=${tl.core.cfg_filename}
...                                 method=${EMPTY}                         type=${TYPE_FILE}

&{FD_WTS_XML}                       name=WTS_XML                            host=${HOST_EPCSIM}
...                                 path=${TL_CORE_PATH_PATTERN}            fileName=${TL_CORE_FILE_PATTERN}
#...                                 path=${tl.core.dir_path}                fileName=
...                                 method=Get XML AirPhoneConfig Path      type=${TYPE_FILE}

&{FD_AP_PHY_XML}                    name=AP_PHY_XML                         host=${AIRSCALE_AP.sys[0].M}
...                                 path=/rom/simmode                       fileName=iphy.xml
...                                 method=${EMPTY}                         type=${TYPE_LINK}

@{FD_ALL}                           ${FD_GNB_SWCONFIG}                      ${FD_AP_SWCONFIG}
...                                 ${FD_WTS_CFG}                           ${FD_WTS_XML}
...                                 ${FD_AP_PHY_XML}

*** Keywords ***
Init Backup Files desc
    [Documentation]                 Update fileName for all file description in a list
    ...                             if method is not empty, apply it to retrieve real name of file to backup
    [Arguments]                     ${listFileDesc}=${FD_ALL}
    FOR    ${fd}   IN              @{listFileDesc}
    #       If method is not empty, update fiel name with result of method execution
            ${res}                  run keyword if                          '${fd.method}'!='${EMPTY}'
            ...                     ${fd.method}
            ${fd.fileName}          set variable if                         '${fd.method}'!='${EMPTY}'
            ...                     ${res}                                  ${fd.fileName}
    #       If host is EPCSIM, re force host with new HOST_EPCSIM (updated by suite setup due to UTE env setup)
            ${fd.host}              set variable if                         '${fd.host.alias}'=='EPCSIM'
            ...                     ${HOST_EPCSIM}                          ${fd.host}
    #       Replace static pattern by real valuers for tl.core variables
            ${fd.path}              set variable if                         '${fd.path}'=='${TL_CORE_PATH_PATTERN}'
            ...                     ${tl.core.dir_path}                     ${fd.path}
            ${fd.fileName}          set variable if                         '${fd.fileName}'=='${TL_CORE_FILE_PATTERN}'
            ...                     ${tl.core.cfg_filename}                 ${fd.fileName}

    END
Print Desc File
    [Arguments]                     ${fileDesc}
    ${p1}                           Set variable                            HOST=${fileDesc.host.alias} Path=${fileDesc.path}
    ${p2}                           Set variable                            File=${fileDesc.fileName} Type=${fileDesc.type}
    ${p3}                           Set variable                            Method=${fileDesc.method}
    Dated log                       FILE_DESC: ${fileDesc.name} ${p1} ${p2} ${p3}

Backup Files
    [Documentation]                 Backup all configuration files (as described in listFileDesc)
    [Arguments]                     ${listFileDesc}=${FD_ALL}
    Init Backup Files desc          listFileDesc=${listFileDesc}
    FOR    ${fd}   IN              @{listFileDesc}
           Dated log                Backup:${fd.name} ${fd.host.alias}:${fd.path}/${fd.fileName}
           Backup File              fileDesc=${fd}

    END
Restore Files
    [Documentation]                 Restore all configuration files (as described in listFileDesc)
    [Arguments]                     ${listFileDesc}=${FD_ALL}
    FOR    ${fd}   IN              @{listFileDesc}
           Dated log                Restore:${fd.name} ${fd.host.alias}:${fd.path}/${fd.fileName}
           Restore File             fileDesc=${fd}

    END
Backup File
    [Documentation]                 Backup one configuration file
    [Arguments]                     ${fileDesc}
    Run keyword if                  '${fileDesc.type}'=='${TYPE_FILE}'
    ...                             Backup Type File                       fileDesc=${fileDesc}
    ...     ELSE                    Backup Type Link                       fileDesc=${fileDesc}

Restore File
    [Documentation]                 Restore one configuration file
    [Arguments]                     ${fileDesc}
    Run keyword if                  '${fileDesc.type}'=='${TYPE_FILE}'
    ...                             Restore Type File                       fileDesc=${fileDesc}
    ...     ELSE                    Restore Type Link                       fileDesc=${fileDesc}

Backup Type File
    [Documentation]                 Backup a file (type is a file) into an .ori one and create a link on a .<ts>
    ...                             which is a copy of .ori
    [Arguments]                     ${fileDesc}
    ${alias}                        SSH Connect                             ${fileDesc.host}
    ${backupPath}                   Get Backup Path                         ${fileDesc}
    ${status}                       File Status
    ...                                 host=${fileDesc.host}
    ...                                 path=${fileDesc.path}/${fileDesc.fileName}
    run keyword if                  '${status.type}'=='FILE'
    ...                             Transfer Real File
    ...                                 fileDesc=${fileDesc}                destPath=${backupPath}
    ...     ELSE                    Remove Link File
    ...                                 fileDesc=${fileDesc}                destPath=${backupPath}
    Link to file with TS name       fileDesc=${fileDesc}                    destPath=${backupPath}

Restore Type File
    [Documentation]                 Restore a file (type is a file) if original is found (otherwise error)
    [Arguments]                     ${fileDesc}
    ${alias}                        SSH Connect                             ${fileDesc.host}
    ${backupPath}                   Get Backup Path                         ${fileDesc}
    ${status}                       File Status
    ...                                 host=${fileDesc.host}
    ...                                 path=${fileDesc.path}/${fileDesc.fileName}
    run keyword if                  '${status.type}'=='FILE'
    ...                             Dated log
    ...                                 No backup done for ${fileDesc.name}, so no restore to do
    ...     ELSE                    Restore Original
    ...                                 fileDesc=${fileDesc}                destPath=${backupPath}

Backup Type Link
    [Documentation]                 Backup a file (type is a link) into an .ori one and create a link on a .<ts>
    ...                             which is a copy of .ori
    [Arguments]                     ${fileDesc}
    ${alias}                        SSH Connect                             ${fileDesc.host}
    ${status}                       File Status
    ...                                 host=${fileDesc.host}
    ...                                 path=${fileDesc.path}/${fileDesc.fileName}
    run keyword if                  '${status.type}'!='LINK'
    ...                             Fail    Backup ERROR on ${fileDesc.name}:${fileDesc.fileName} is not a link (${status.type})
    ${filePath}                     getDirFromPath                          ${status.linked}
    ${filePath}                     Set Variable if                         '${filePath}'=='${EMPTY}'
    ...                             ${fileDesc.path}                        ${filePath}
    ${fileName}                     getFileNameFromPath                     ${status.linked}
    ${fileDescForFile}              Dictionary Get                          ${fileDesc}
    ${fileDescForFile.name}         set variable                            ${fileDesc.name}_FILE
    ${fileDescForFile.path}         set variable                            ${filePath}
    ${fileDescForFile.fileName}     set variable                            ${fileName}
    ${fileDescForFile.type}         set variable                            ${TYPE_FILE}
    Backup Type File                ${fileDescForFile}

Restore Type Link
    [Documentation]                 Restore a file (type is a link) if original is found (otherwise error)
    [Arguments]                     ${fileDesc}
    ${alias}                        SSH Connect                             ${fileDesc.host}
    ${status}                       File Status
    ...                                 host=${fileDesc.host}
    ...                                 path=${fileDesc.path}/${fileDesc.fileName}
    run keyword if                  '${status.type}'!='LINK'
    ...                             Fail    Restore ERROR on ${fileDesc.name}:${fileDesc.fileName} is not a link (${status.type})
    ${filePath}                     getDirFromPath                          ${status.linked}
    ${filePath}                     Set Variable if                         '${filePath}'=='${EMPTY}'
    ...                             ${fileDesc.path}                        ${filePath}
    ${fileName}                     getFileNameFromPath                     ${status.linked}
    ${fileDescForFile}              Dictionary Get                          ${fileDesc}
    ${fileDescForFile.name}         set variable                            ${fileDesc.name}_FILE
    ${fileDescForFile.path}         set variable                            ${filePath}
    ${fileDescForFile.fileName}     set variable                            ${fileName}
    ${fileDescForFile.type}         set variable                            ${TYPE_FILE}
    Restore Type File               ${fileDescForFile}

Restore Original
    [Documentation]                 Restore link to an original file if exists
    ...                             if original does not exist, this is an error
    [Arguments]                     ${fileDesc}                             ${destPath}
    ${alias}                        SSH Connect                             ${fileDesc.host}
    ${isDestExist}                  csn.file_exists                         remote_path=${destPath}
    ...                             connection=${alias}
    ${fullPath}                     set variable                            ${fileDesc.path}/${fileDesc.fileName}
    Should be true                  ${isDestExist}
    ...                             No file ${fullPath} and no Backup ${destPath} found
    # As file is a link, and original exists, remove file
    Backup CMD                      command=rm -Rf ${fullPath}              alias=${alias}
    # ... and re create link on original file
    Backup CMD                      command=cd ${fileDesc.path};ln -s ${destPath} ${fileDesc.fileName}
    ...                             alias=${alias}

Remove Link File
    [Documentation]                 Remove if it exists a link (${fileDesc})
    ...                             but this is done ONLY if ${destPath} exists
    ...                             oherwise, this is an error
    [Arguments]                     ${fileDesc}                             ${destPath}
    ${alias}                        SSH Connect                             ${fileDesc.host}
    ${isDestExist}                  csn.file_exists                         remote_path=${destPath}
    ...                             connection=${alias}
    ${fullPath}                     set variable                            ${fileDesc.path}/${fileDesc.fileName}
    Should be true                  ${isDestExist}
    ...                             No file ${fullPath} and no Backup ${destPath} found
    Backup CMD                      command=rm -Rf ${fullPath}              alias=${alias}

Transfer Real File
    [Documentation]                 Transfer a file found as a real file into a .ori one
    ...                             ${fileDesc} is description of file to be backuped
    ...                             ${destPath} is full path of backup file
    ...                             In this KW, original file is only transferred to backup location
    [Arguments]                     ${fileDesc}                             ${destPath}
    ${alias}                        SSH Connect                             ${fileDesc.host}
    # remove destPath as <FileDesc> is a real file, so to be considered as the new reference
    Backup CMD                      command=rm -Rf ${destPath}              alias=${alias}
    # Backup reference to destPath
    Backup CMD                      command=mv ${fileDesc.path}/${fileDesc.fileName} ${destPath}
    ...                             alias=${alias}

Link to file with TS name
    [Documentation]                 Create a link to a file named with test name which is a copy
    ...                             of ${destPath}
    [Arguments]                     ${fileDesc}                             ${destPath}
    # Remove .<ts> file if exists
    ${ts}                           getFormattedName
    ${tsPath}                       set variable                            ${fileDesc.path}/${fileDesc.fileName}.${ts}
    ${alias}                        SSH Connect                             ${fileDesc.host}
    Backup CMD                      command=rm -Rf ${tsPath}                alias=${alias}
    # copy dest file to .<ts> file
    Backup CMD                      command=cp ${destPath} ${tsPath}        alias=${alias}
    # Create link on to .<ts> file
    Backup CMD                      command=cd ${fileDesc.path};ln -s ${tsPath} ${fileDesc.fileName}
    ...                             alias=${alias}

File Status
    [Documentation]                 Check if a file is a real file or not, or a link, and a correct link
    ...                             it returns a status dictionary with :
    ...                             - a type (FILE, LINK, BAD_LINK, NO_FILE)
    ...                             - the linked file (field 'linked')
    [Arguments]                     ${host}                                 ${path}
    ${alias}                        SSH Connect                             host=${host}
    ${isFileExist}                  csn.file_exists                         remote_path=${path}
    ...                                 connection=${alias}
    ${testLinkStr}                  Backup CMD                              command=test -h ${path} && echo "LINK"
    ...                             alias=${alias}
    ${testLinkStr}                  Set variable                            ${testLinkStr.replace("\n","").replace("\r","")}
    ${isLink}                       set variable if                         '${testLinkStr}'=='LINK'
    ...                             ${True}                                 ${False}
    ${linkedFile}                   Set Variable                            ${EMPTY}
    ${linkedFile}                   run Keyword if                          ${isLink}
    ...                             Get Linked File                         path=${path}
    ...                             host=${host}
    &{status}                       OsTool.buildStatusFromFileInfo
    ...                                 isFileExist=${isFileExist}
    ...                                 isLink=${isLink}
    ...                                 linkedFile=${linkedFile}
    [Return]                        ${status}

Get Linked File
    [Documentation]                 Return the linked file of a file knowing its path
    ...                             or EMPTY if file is not a link but a real file
    [Arguments]                     ${path}                                 ${host}
    ${alias}                        SSH Connect                             ${host}
    ${output}                       SSH Cmd                                 ls -al ${path}
    ...                             alias=${alias}
    ${nameList}                     Split String From Right                 ${output}       >
    ${link}                         Get Substring                           ${output}
    ...                             start=0                                 end=1
    ${name}                         set variable if                         '${link}'=='l'
    ...                             ${nameList[1]}                          ${EMPTY}
    ${name}                         getStringFromCmdReturn                  ${name}
    ${name}                         Set Variable                            ${name.replace(' ','')}
    [Return]                        ${name}

Get Backup Path
    [Arguments]                     ${fileDesc}
    ${backupPath}                   set variable                            ${fileDesc.path}/${fileDesc.fileName}${ORI_EXT}
    [Return]                        ${backupPath}


Backup CMD
    [Arguments]                     ${command}                              ${alias}
    ${ret}                          SSH Exec                                command=${command}
    ...                             alias=${alias}                          debug=${DBG_BACKUP}
    [Return]                        ${ret}
