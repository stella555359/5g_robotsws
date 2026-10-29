*** Settings ***
Documentation
...    Test for CNI104334
Library     OperatingSystem
Library     taf.ul.verify_snapshot  WITH NAME  snapshot
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Resource    ../resources/bts_states.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/unpacking.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Library     ../../resources/python_resources/admin_cli.py  WITH NAME  hran_admin_cli
Library     Collections

*** Variables ***
${STARTUP_TIMEOUT}        20
${SNAPSHOT_TIMEOUT}       1200
${BASE_PATH}      /home/ute/btsauto
${PREFIX}         SBTS

*** Keywords ***
TC__LOGS__CNI-104334_2xpower-reset_snapshoot
    [Documentation]
    ...  [CASE LINK]:
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case created to verify mechanism of creating and moving postmortem files after reset.
    ...  According to CNI-104334, mechanism of collecting logs in snapshot after 2x coldresets.
    ...  After two coldresets, BTSxxxx_1011_ffs_coldreset_ps_syslog.zip file will be created in snapshot.
    ...  After two coldresets, in file BTSxxxx_1011_ffs_coldreset_ps_syslog.zip in 1011 folder will be 1011_yyy.xz and pm1_1011_yyy.xz.


    Set Tags    CA-LOGS    AUTHOR-cristinel.sava@nokia.com    MAINTAINER-cristinel.sava@nokia.com
    ...   GROUP_IN_CHARGE-TIM1 7_Vrf    PHASE-CRT    SW-SBTS25R1    FEATURE-CNI-104334

    Step 0: Preconditions
    Step 1: Perform 2 ColdResets, Collect Snapshot


Step 0: Preconditions
    [Documentation]
    ...  In this step BTS ID from current BTS is set to variable.

    Log  \nStep 0: Preconditions  console=${True}
    ${bts_id}=  bts_states.Get BTS ID
    bts_states.Check If Admin CLI Feature Check Is Enabled
    ${active SW version}=  coam.Get Sw Version
    log to console    SW build=${active SW version}
    ${Mplane_IP}  bts_states.Get BTS Mplane
    log to console    mplane=${Mplane_IP}
    ${btsid}   bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}    ${btsid}
    Wait Until Keyword Succeeds  5x  15s  Setup Admin CLI  ${active SW version}  ${Mplane_IP}  admin_dir=/home/ute/btsauto
#Rename folder start with "STBS"
    ${folders}=    OperatingSystem.List Directories In Directory    ${BASE_PATH}
    log to console    Folders found: ${folders}
    ${target_folder}=    Get Folder Starting With    ${folders}    SBTS
    ${old_folder_path}=    Set Variable    ${BASE_PATH}/${target_folder}
    ${new_folder_path}=    Set Variable    ${BASE_PATH}/${active SW version}_ADMIN_CLI
    run keyword if  '${old_folder_path}'!='${new_folder_path}'  run keywords
        ...  Move Directory    ${old_folder_path}    ${new_folder_path}
        ...  AND  log to console    Folder ${target_folder} was renamed ${active SW version}_ADMIN_CLI
    log to console    Folder ${target_folder} have same name with ${active SW version}_ADMIN_CLI
    sleep    5s

Step 1: Perform 2 ColdResets, Collect Snapshot
    [Documentation]
    ...  site coldreset is done twice and snapshot is collected.

    log to console    \nTwo site coldresets will be performed now  console=${True}
    log to console    new_folder_path=${active SW version}_ADMIN_CLI
    ${request1}    catenate    --bts-username=Nemuadmin --bts-password=nemuuser --bts-host=${Mplane_IP} --bts-port=443
    ...    --format=human --data='{"requestId":123456,"parameters":{"name":"powerReset"}}'
    log to console    request=${request1}
    Run     /home/ute/btsauto/${active SW version}_ADMIN_CLI/admin-cli.sh ${request1}
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  30s  Verify all BTS states
    Run     /home/ute/btsauto/${active SW version}_ADMIN_CLI/admin-cli.sh ${request1}
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  30s  Verify all BTS states
    log to console    Step 1: Collect snapshot   console=${True}
    ${path_to_snapshot}    Collect Snapshot
    Check Content Of Package    ${path_to_snapshot}
    Wait Until Keyword Succeeds    120min    60s    coam.Assert alarm inactive    faultId=1898, severity=Minor
    Wait Until Keyword Succeeds    5min    10s    coam.Assert alarm inactive    faultId=4124, severity=Minor
    Wait Until Keyword Succeeds    5min    10s    coam.Assert alarm inactive    faultId=4123, severity=Minor


Verify all BTS states
    ${BTS_state_is_correct}    Verify BTS proceduralState  OnAir
    ${system_modules_working}  Verify system modules states
    ${radio_modules_working}   Verify radio modules states
    ${cells_GSM_onair}         Verify GSM cells states
    ${cells_WCDMA_onair}       Verify WCDMA cells states
    ${cells_LTE_onair}         Verify LTE cells states
    ${cells_NR_onair}          Verify NR cells states
    ${BTS_modules_states}=  Set Variable If  ${BTS_state_is_correct} and ${system_modules_working} and ${radio_modules_working}
    ...  ${True}  ${False}
    ${Cells_states}=        Set Variable If  ${cells_GSM_onair} and ${cells_WCDMA_onair} and ${cells_LTE_onair} and ${cells_NR_onair}
    ...  ${True}  ${False}
    Run Keyword If  ${BTS_modules_states} and ${Cells_states}
    ...  Log  BTS verification status passed    console=${True}
    ...  ELSE  Fail  At least one module, cell or BTS proceduralState indicates a faulty state!

Get Folder Starting With
    [Arguments]    ${folders}    ${prefix}
    ${matching_folders}=    Evaluate    [folder for folder in ${folders} if folder.startswith('${prefix}')]
    Run Keyword Unless    ${matching_folders}    Fail    Nu s-a gãsit niciun folder care începe cu prefixul: ${prefix}
    ${first_match}=    Get From List    ${matching_folders}    0
    [Return]    ${first_match}


Check Content Of Package
    [Arguments]  ${path_to_snapshot}
    [Documentation]
    ...    In this step Snapshot content is validated- if all most important files from SMOD/BBMOD are present.
    Log    \n----- Step1: Check content of package-----    console=${True}

    @{mandatory_files}  Create List  pm1_1011_AaPostmortemBackupRegisteredPaths.log.xz  pm1_1011_FRI.tar.xz  pm1_1011_IMS.tar.xz
    ...  pm1_1011_UpColdResetBackupLogs.tar.xz  pm1_1011_coldResetBackupTmp.sh.xz  pm1_1011_ims.tar.xz
    ...  pm1_1011_tmp.tar.xz  1011_AaPostmortemBackupRegisteredPaths.log.xz    1011_FRI.tar.xz
    ...  1011_IMS.tar.xz  1011_UpColdResetBackupLogs.tar.xz    1011_coldResetBackupTmp.sh.xz
    ...  1011_ims.tar.xz    1011_tmp.tar.xz
    &{snapshot_dict}  Create Dictionary  mandatory_file=@{mandatory_files}  not_mandatory_file=${EMPTY}

    ${found_file_dict}  snapshot.Get Data From Snapshot  ${path_to_snapshot}
    snapshot.Validate Snapshot Using Custom Data  ${found_file_dict}  ${snapshot_dict}
    Log  CNI-104334 files found in snapshot.  console=${True}

Collect Snapshot
    [Documentation]
    ...  This keyword is used to collect snapshot
    @{time}=  Get Time  year month day hour min
    ${snapshot_status}=  Run Keyword And Return Status
    ...  coam.Collect Snapshot  ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If  ${snapshot_status}
    ...  Log  Collecting snapshot succeeded  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Collecting snapshot has failed  ${True}
    ${path_to_snapshot}=  Set Variable  ${BTS Files}/snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip
    [Return]  ${path_to_snapshot}



TC Setup
    Common Test Setup    alarms_check=${FALSE}  cells_check=${FALSE}  modules_check=${FALSE}

TC Teardown
    Run Keywords
    ...  interface.Common step trigger
    ...  AND  Setup Scout And Send Configuration
    ...  AND  Common Test Teardown
