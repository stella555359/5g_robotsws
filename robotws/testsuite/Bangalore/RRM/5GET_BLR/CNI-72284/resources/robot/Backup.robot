*** Settings ***
Documentation
...             == Purpose ==
...             Library to manage Backup/restore of key config files on a TL
...
...             == Description ==
...             *Concepts:*
...
...             Most of those keywords are manipulating some "FileDesc", meaning File Description.
...             A File description is a python class (see Backup.py for implementation).
...             which attributes are :
...              - name     : string to identify the file description
...              - host     : reference to host on which we can find this file
...              - path     : Path to the concerned file on TL
...              - fileName : name of the file
...              - method   : method to compute file name if its name is dynamic/contextual
...              - type     : toggle to indicate if it's a full file or a link
...
...             *Mecanism:*
...
...              - concerned files are backuped directly on TL (not saved on VM)
...              - file is changed into a link that will point on a particular version
...              - at backup step, original will be backuped into a .ori file if not existing
...              - then, a copy into a <FileName>.<TestName> is also done.
...              - And original file will then point on it
...              - at restore step, file will point again on .ori file
...              - in case of crash or manual stop of the test, next backup will detect .ori exists and will be able to retrieve it
...
...             See Backup.py for list of files currently candidate for backup/restore.
...             This list can be extended if required
...
...             *Scope:*
...
...             Files currently concerned by this mechanism are as follows:
...             | NAME         | HOST       | PATH              | FILE NAME             | METHOD                      | TYPE |
...             | GNB_SWCONFIG | GNB Master | /ffs/run/         | swconfig.txt          | None                        | file |
...             | AP_SWCONFIG  | AP Master  | /ffs/run/         | swconfig.txt          | None                        | file |
...             | WTS_CFG      | EPCSIM     | tl.core.dir_path  | tl.core.cfg_filename  | None                        | file |
...             | WTS_XML      | EPCSIM     | tl.core.dir_path  |                       | Get XML AirPhoneConfig Path | file |
...             | AP_PHY_XML   | AP Master  | /rom/simmode      | iphy.xml              | None                        | LINK |
...
...             *Debug:*
...
...             In case an issue is detected, requiring some debug for investigations,
...             just set the ${DBG_BACKUP} to ${True}, then it will trace in console full detail of linux commands
...             launched on TL.
...
...            *Note:*
...
...             SCF file is NOT backuped thru this mechanism, since SCF file is natively available as an explicit regular file.
...             SCF file must be previously generated then transferred locally (thru "OAM Get SCF File" KW from Oam.robot).
...

Resource                            Setup.robot
Variables                           ../../../resources/NPS/SWENG/python/Backup.py
Library                             ../../../resources/NPS/SWENG/python/OsTool.py

*** Variables ***
# ${DBG_BACKUP}                       ${True}
${DBG_BACKUP}                       ${False}
${ORI_EXT}                          .ori
@{SUITE_BACKUP_FILES}

*** Keywords ***
Suite Backup Files
    [Documentation]                 Backup all files included in a list of files description.
    ...                             If this list is empty, nothing is done.
    ...                             The name of the list of saved to be reused for restore action.
    [Arguments]                     ${listBackupFiles}=${FD_ALL}
    Set Suite Variable              ${SUITE_BACKUP_FILES}                   ${listBackupFiles}
    ${len}                          Get length                              ${listBackupFiles}
    Run keyword if                  ${len}!=0
    ...                             Backup Files                            ${listBackupFiles}

Suite Restore Files
    [Documentation]                 Restore all files included in the SUITE_BACKUP_FILES list.
    ...                             If this list is empty, nothing is done.
    ...                             The list should have been previously defined (by "Suite Backup Files" keyword).
    ${len}                          Get length                              ${SUITE_BACKUP_FILES}
    Run keyword if                  ${len}!=0
    ...                             Restore Files                           ${SUITE_BACKUP_FILES}

Backup Files
    [Documentation]                 Backup all configuration files (as described in listFileDesc)
    [Arguments]                     ${listFileDesc}=${FD_ALL}
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
    [Documentation]                 Backup a file (type is a file) into an <name>.ori one and create a link on a <name>.<testSuite>
    ...                             which is a copy of <name>.ori
    [Arguments]                     ${fileDesc}
    ${alias}                        SSH Wait For Connect                    ${fileDesc.host}
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
    ${alias}                        SSH Wait For Connect                    ${fileDesc.host}
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
    [Documentation]                 Backup a file (type is a link) into an .ori one and create a link
    ...                             on a file which ends with the Test Suite (<name>.<TestSuite>) which is a copy of .ori.
    ...                             For instance, for iphy.xml, iphy.xml will then be a link on iphy.xml.<testName>
    ...                             and iphy.xml.ori contains original version.
    [Arguments]                     ${fileDesc}
    ${alias}                        SSH Wait For Connect                    ${fileDesc.host}
    ${status}                       File Status
    ...                                 host=${fileDesc.host}
    ...                                 path=${fileDesc.path}/${fileDesc.fileName}
    run keyword if                  '${status.type}'!='LINK'
    ...                             Fail    Backup ERROR on ${fileDesc.name}:${fileDesc.fileName} is not a link (${status.type})
    ${filePath}                     getDirFromPath                          ${status.linked}
    ${filePath}                     Set Variable if                         '${filePath}'=='${EMPTY}'
    ...                             ${fileDesc.path}                        ${filePath}
    ${fileName}                     getFileNameFromPath                     ${status.linked}
    ${fileDescForFile}              copyInstance                            ${fileDesc}
    ${fileDescForFile.name}         set variable                            ${fileDesc.name}_FILE
    ${fileDescForFile.path}         set variable                            ${filePath}
    ${fileDescForFile.fileName}     set variable                            ${fileName}
    ${fileDescForFile.type}         set variable                            ${TYPE_FILE}
    Backup Type File                ${fileDescForFile}

Restore Type Link
    [Documentation]                 Restore a file (type is a link) if original is found (otherwise error)
    [Arguments]                     ${fileDesc}
    ${alias}                        SSH Wait For Connect                    ${fileDesc.host}
    ${status}                       File Status
    ...                                 host=${fileDesc.host}
    ...                                 path=${fileDesc.path}/${fileDesc.fileName}
    run keyword if                  '${status.type}'!='LINK'
    ...                             Fail    Restore ERROR on ${fileDesc.name}:${fileDesc.fileName} is not a link (${status.type})
    ${filePath}                     getDirFromPath                          ${status.linked}
    ${filePath}                     Set Variable if                         '${filePath}'=='${EMPTY}'
    ...                             ${fileDesc.path}                        ${filePath}
    ${fileName}                     getFileNameFromPath                     ${status.linked}
    ${fileDescForFile}              copyInstance                            ${fileDesc}
    ${fileDescForFile.name}         set variable                            ${fileDesc.name}_FILE
    ${fileDescForFile.path}         set variable                            ${filePath}
    ${fileDescForFile.fileName}     set variable                            ${fileName}
    ${fileDescForFile.type}         set variable                            ${TYPE_FILE}
    Restore Type File               ${fileDescForFile}

Restore Original
    [Documentation]                 Restore link to an original file if exists.
    ...                             if original does not exist, this is an error
    [Arguments]                     ${fileDesc}                             ${destPath}
    ${alias}                        SSH Wait For Connect                    ${fileDesc.host}
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
    [Documentation]                 Remove if it exists a link (${fileDesc}).
    ...                             but this is done ONLY if ${destPath} exists.
    ...                             otherwise, this is an error
    [Arguments]                     ${fileDesc}                             ${destPath}
    ${alias}                        SSH Wait For Connect                    ${fileDesc.host}
    ${isDestExist}                  csn.file_exists                         remote_path=${destPath}
    ...                             connection=${alias}
    ${fullPath}                     set variable                            ${fileDesc.path}/${fileDesc.fileName}
    Should be true                  ${isDestExist}
    ...                             No file ${fullPath} and no Backup ${destPath} found
    Backup CMD                      command=rm -Rf ${fullPath}              alias=${alias}

Transfer Real File
    [Documentation]                 Transfer a file found as a real file into a .ori one.
    ...                             ${fileDesc} is description of file to be backuped.
    ...                             ${destPath} is full path of backup file.
    ...                             In this KW, original file is only transferred to backup location.
    [Arguments]                     ${fileDesc}                             ${destPath}
    ${alias}                        SSH Wait For Connect                    ${fileDesc.host}
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
    ${alias}                        SSH Wait For Connect                    ${fileDesc.host}
    Backup CMD                      command=rm -Rf ${tsPath}                alias=${alias}
    # copy dest file to .<ts> file
    Backup CMD                      command=cp ${destPath} ${tsPath}        alias=${alias}
    # Create link on to .<ts> file
    Backup CMD                      command=cd ${fileDesc.path};ln -s ${tsPath} ${fileDesc.fileName}
    ...                             alias=${alias}

File Status
    [Documentation]                 Check if a file is a normal file or a link, and then indicate if the link is correct.
    ...                             If th file does not exist, status is NO_FILE.
    ...                             If it is pointing on an unexisting file, status is BAD_LINK.
    ...                             If this is a regular existing file, status is FILE.
    ...                             If this is a link to an existing file, status is LINK.
    ...                             it returns a status dictionary with :
    ...                             - type   : a type. Can be one of : FILE, LINK, BAD_LINK, NO_FILE.
    ...                             - linked : the linked file.
    [Arguments]                     ${host}                                 ${path}
    ${alias}                        SSH Wait For Connect                    host=${host}
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
    [Documentation]                 Return the linked file of a file knowing its path or EMPTY if file is not a link but a real file.
    ...                             For instance, for the link iphy.xml->/rom/simmode/ABC_IPhy.xml, it will return '/rom/simmode/ABC_IPhy.xml'.
    ...                             For the real file swconfig.txt, it will return ${EMPTY}
    [Arguments]                     ${path}                                 ${host}
    ${alias}                        SSH Wait For Connect                    ${host}
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
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${fileDesc}
    ${backupPath}                   set variable                            ${fileDesc.path}/${fileDesc.fileName}${ORI_EXT}
    [Return]                        ${backupPath}


Backup CMD
    [Documentation]                 INTERNAL USAGE
    [Arguments]                     ${command}                              ${alias}
    ${ret}                          SSH Exec                                command=${command}
    ...                             alias=${alias}                          debug=${DBG_BACKUP}
    [Return]                        ${ret}
