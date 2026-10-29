*** Settings ***
Documentation
...  This resource is used for CBTS LOGS TCs that contain common KWs

*** Variables ***

${TEAM_PATH_TO_ROTTA}       VRF_TSR/VRF_TSR_T05/TT/CRT


*** Keywords ***

Get List Of Nr Cells Id
    [Documentation]
    ...  This keyword is used to get all nrcells id

    ${nr_cells_id_list}  Create List
    ${cells_statuses}  vdu.Get Vdu Cells Status
    FOR  ${cell}  IN  @{cells_statuses}
        Append To List  ${nr_cells_id_list}  ${cell}[id]
    END

    [Return]  ${nr_cells_id_list}

Logs To Rotta Copy
    [Documentation]
    ...  The keyword checks whether the Rotta is mapped; if not, it will be connected.
    ...  Subsequently, two paths are created for the trunk and branch, and the keyword checks software release.
    ...  Finally, logs are copied to the Rotta.
    ...  Updated for CR , add debug.log and output.xml to DIR- Dan Moldovan
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com
    ...  dan.moldovan@nokia.com

    ${rotta_available}    Run Keyword and Return Status    OperatingSystem.Directory Should Exist    /home/ute/Rotta
    ${rotta_directory_not_empty}    Run Keyword and Return Status    Directory Should Not Be Empty    /home/ute/Rotta

    Run Keyword If    ${rotta_available}==True and ${rotta_directory_not_empty}==True    Run Keyword
    ...    Log    rotta available
    ...    ELSE   Mount Rotta


    log to console    ${VDU_MRBTS_NAME}
    ${BTS_NAME}     Fetch From Left  ${VDU_MRBTS_NAME}  _
    log to console    sw is:${VDU_ACTIVE_SW_VERSION}
    ${software_version}  Fetch From Left  ${VDU_ACTIVE_SW_VERSION}  _
    log to console    sw version is: ${software_version}
    ${release}     Fetch From Right  ${software_version}  CNF

    ${BR_path}     Set Variable    /home/ute/Rotta/MN_RAN/RAN_VRF/${release}/Regression/${TEAM_PATH_TO_ROTTA}
    ${TR_path}     Set Variable   /home/ute/Rotta/MN_RAN/RAN_VRF/Trunk/${TEAM_PATH_TO_ROTTA}

    ${check_if_trunk}    Run Keyword And Return Status    Should contain      ${VDU_ACTIVE_SW_VERSION}     _0
    Run Keyword If    ${check_if_trunk}
    ...    Set Test Variable    ${path_copy_logs}    ${TR_path}
    ...    ELSE    Set Test Variable    ${path_copy_logs}    ${BR_path}
    log to console    path is: ${path_copy_logs}

    ${current_date}           DateTime.Get Current Date  time_zone=UTC  exclude_millis=True  result_format=%Y-%m-%d
    Run    mkdir -p ${path_copy_logs}/${BTS_NAME}/${current_date}

    Run    ls -l /home/ute/robotws/results
    Run    rsync -r --exclude='*/' ${OUTPUT_DIR}/debug.log ${Test Results Dir}
    Run    rsync -r --exclude='*/' ${OUTPUT_DIR}/output.xml ${Test Results Dir}

    Run    rsync -av --progress ${Test Results Dir} ${path_copy_logs}/${BTS_NAME}/${current_date}/


Copy file logs
    [Documentation]
    ...  Will copy only log.html an output.xml
    ...  *AUTHOR*
    ...  dan.moldovan@nokia.com
    log to console    TBC

Mount Rotta
    [Documentation]
    ...  KW Mount Rotta using technical pmlogs account
    ...
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com
    ...

    ${password}       Set Variable    Trbs07!@
    ${username}       Set Variable    tsr1logs
    ${global_p}       Set Variable    //nescrotta.nesc.nokia.net/rotta
    ${local_p}        Set Variable    /home/ute/Rotta
    ${domain}         Set Variable    NSN-INTRA

    Run    sudo mkdir -p /home/ute/Rotta
    Run  sudo mount -t cifs -o noperm,auto,rw,vers=3.0,username=${username},password=${password},domain=${domain},users,nounix ${global_p} ${local_p}
