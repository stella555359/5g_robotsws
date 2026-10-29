*** Settings ***
Documentation  Test for CB009514
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/ping_utils.robot
Library     String
Library     OperatingSystem
Library     DateTime
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     taf.ul.verify_snapshot   WITH NAME  snapshot


*** Variables ***
${SNAPSHOT_TIMEOUT}    1800
${TOLERANCE}           60    # the allowed time (seconds) difference between the reset command send time and time in BBOX5
${JENKINS_URL}         ${BUILD_PATH}
@{ALL_REL7.1}          AVQL    AVQE    AVQQA    AVHA    AVQC    AVNB

*** Keywords ***
TC__LOGS__CB009514_KA_parity_legacy_black_box_5_function_of_CB006622
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27698
    ...  ******************
    ...  Author: Andrei Maria
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 29.10.2024 - initial TC creation
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  Purpose of this test case is to verify BBOX5 file content from Snapshot (has to be the same as BBOX5 file taken directly from RMOD via ssh)
    ...  Also the timestamps from BBOX5 files are checked
    ...  *******************

    Set Tags   LOGS   AUTHOR-andrei.maria@nokia.com    MAINTAINER-andrei.maria@nokia.com    GROUP_IN_CHARGE-TSR1_7_Vrf    PHASE-CRT    SW-SBTS25R2

    Step 1: Preparation
    Step 2: Extract BBOX5 from RMOD
    Step 3: Collect Snapshot
    Step 4: Extract BBOX5 from Snapshot
    Step 5: Check If BBOX5 Contents from Snapshot and RMOD Are Same

Step 1: Preparation
    [Documentation]    In this step release 7.1 radios are checked and one is selected at random. SSH connection is made to SMOD.

    Log  \nStep 1: Preparation  console=${True}
    ${btsInfo}=  coam.Get Bts Info
    Set Test Variable  ${BTS_ID}  ${btsInfo['mrbtsID']}
    Set Test Variable    ${BTS_SW_CHANGED}    ${FALSE}
    ${selected_radio}    Get Rel7.1 RMODs List
    Set Test Variable    ${selected_radio}
    SSHLibrary.Open Connection    ${SMOD1['IP']}
    SSHLibrary.Login        ${SMOD1['USERNAME']}    ${SMOD1['PASSWORD']}
    SSHLibrary.Read

    ${serial_number}    Get From Dictionary    ${selected_radio}[0]    serial_number
    Set Test Variable    ${serial_number}
    ${product_name}    Get From Dictionary    ${selected_radio}[0]    product_name
    Set Test Variable    ${product_name}
    ${rmod_id}    Get From Dictionary   ${selected_radio}[0]    rmod_id
    Set Test Variable    ${rmod_id}
    ${rmod_IP}    Get From Dictionary   ${selected_radio}[0]    ip_address
    Set Test Variable    ${rmod_IP}

    Log    BBOX5 from RMOD ${product_name} with SN ${serial_number} will be checked   console=${TRUE}
    Wait Until Keyword Succeeds    30 min  10 s  pm_logs_general.Check RMOD States  ${rmod_id}  (?i)Unlocked  (?i)Enabled

Step 3: Collect Snapshot
    [Documentation]    In this step the snapshot is collected, and the path to this downloaded snapshot is stored in a variable.
    Log    \nStep 3: Collect Snapshot    console=${TRUE}
    ${path_to_snap_1}    Collect Snapshot
    Set Test Variable    ${path_to_snap_1}

Step 4: Extract BBOX5 from Snapshot
    [Documentation]    In this step the BBOX5 file is found and extracted from the snapshot, next this file is analyzed and the
    ...    initial (current) values for the reset counter, radio SW, NvmResetTrigger and previous radio SW
    ...    are found and stored in variables.

    Log    \nStep 4: Extract BBOX5 from Snapshot    console=${TRUE}
    Locate BBOX5 File In Snapshot And Extract It    ${path_to_snap_1}

Step 2: Extract BBOX5 from RMOD
    [Documentation]    In this step the BBOX5 file is found and extracted from the snapshot, next this file is analyzed and the
    ...    updated (current) values for the reset counter, radio SW, NvmResetTrigger and previous radio SW
    ...    are found and stored in variables.

    Log    \nStep 2: Extract BBOX5 from RMOD    console=${TRUE}
    Log  Select RMOD  console=true

    ${cat_command}    Set Variable    cat /mnt/runtime/BBOX5
    SSHLibrary.Open Connection    192.168.255.129
    SSHLibrary.Login        toor4nsn    oZPS0POrRieRtu
    SSHLibrary.Read
    Sleep    3s
    SSHLibrary.Write    lxc-attach -n 0x1018
    Sleep    3s
    SSHLibrary.Write    scp serviceuser@${rmod_IP}:/mnt/runtime/BBOX5 /ffs/run
    Sleep    3s
    ${connection_status}    SSHLibrary.Read
    ${fingerprint}    Get Count    ${connection_status}    (yes/no/[fingerprint])?
    Sleep    1s
    Run Keyword If    ${fingerprint}==1    SSHLibrary.Write    yes
    Sleep    1s
    SSHLibrary.Write    kQ2QZWY22987AsO4QaK/Yzj/gh3yksrLESosPRHF6Og=
    Sleep    1s
    SSHLibrary.Write    exit
    Sleep    1s
    SSHLibrary.Write    exit
    Run    mkdir ${BTS_Files}/BBOX5
    Run    mkdir ${BTS_Files}/BBOX5/BBOX5_extracted_from_RMOD
    Run    sshpass -p 'oZPS0POrRieRtu' scp toor4nsn@192.168.255.129:/ffs/run/BBOX5 ${BTS_Files}/BBOX5/BBOX5_extracted_from_RMOD
    Set Test Variable  ${path_to_BBOX_file_from_RMOD}  ${BTS_Files}/BBOX5/BBOX5_extracted_from_RMOD/BBOX5
    SSHLibrary.Close All Connections

Step 5: Check If BBOX5 Contents from Snapshot and RMOD Are Same
    [Documentation]    In this step, BBOX5 files from Snapshot and RMOD are compared to check if they are the same as expected.
    ...    Checks include also the timestamps verification.
    Log    \nStep 5: Check If BBOX5 Contents from Snapshot and RMOD Are Same    console=${TRUE}
    Log to console    \n********* check BBOX5 items info *********
    ${bbox5_content}    Run    command=cat ${path_to_BBOX_file_from_Snapshot}
    ${bbox5_content_ru}    Run    command=cat ${path_to_BBOX_file_from_RMOD}
    Should Be Equal As Strings   ${bbox5_content}    ${bbox5_content_ru}
    ${pattern}    Set Variable    Last write: ([^T]*)T
    ${last_write_time}    Get Regexp Matches    ${bbox5_content}    ${pattern}    1
    ${today}    DateTime.Get Current Date    result_format=%Y-%m-%d
    ${yesterday}    DateTime.Subtract Time From Date    ${today}    1 day    result_format=%Y-%m-%d
    ${latest_date}    Evaluate    max(${last_write_time})
    Should Contain Any    ${latest_date}    ${today}    ${yesterday}

Locate BBOX5 File In Snapshot And Extract It
   [Documentation]    Find the BBOX5 in snapshot for desired radio and extracts it. Takes the path to snapshot as argument and returns
   ...    the path to the extracted BBOX5 file.

   [Arguments]    ${snapshot_path}
   Log  Looking for BBOX5 for desired radio in snapshot  console=${True}
   ${snapshot_dict}   snapshot.Get Data From Snapshot  ${snapshot_path}

   FOR    ${key}    IN    @{snapshot_dict.keys()}
       ${blackbox_file}    get regexp matches    ${snapshot_dict["${key}"][0]}    \.+BTS${BTS_ID}_${serial_number}_RMOD_\\w_\\d_BBOX5_all\.zip
       Exit For Loop If    ${blackbox_file}
   END

   Run Keyword If    ${blackbox_file}    Extract log file    ${snapshot_path}    ${blackbox_file[0]}
   ...    ELSE    Fail    BBOX5_all.zip file not found for ${product_name} with SN ${serial_number}

Collect Snapshot
    [Documentation]    Downloads full snapshot from BTS and returns the path of saved snapshot on VM.

    Log  Collecting snapshot...    console=${TRUE}
    ${timestamp}    Get time
    ${timestamp}    replace String Using Regexp    ${timestamp}    (${SPACE}|:|-)  _
    Set Test Variable  ${timestamp}
    ${log_status}  Run Keyword And Ignore Error  coam.Collect snapshot  ${BTS_Files}/snapshot_${timestamp}.zip  coverage=Minor
    ...    timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If    '${log_status[0]}'=='FAIL'
    ...    Fail    Collecting snapshot failed
    ...    ELSE    Log    Snapshot has been successfully downloaded    console=${TRUE}
    Set Test Variable    ${path_to_snapshot}    ${BTS_Files}/snapshot_${timestamp}.zip
    [Return]    ${path_to_Snapshot}

Extract log file
    [Documentation]    Extracts the desired file from snapshot and sets the variable path_to_log_file.

    [Arguments]    ${path_to_snapshot}    ${file_to_extract}
    unpacking.Unpack Archive Content To Directory    ${path_to_snapshot}    ${BTS_Files}/snapshot_${timestamp}
    ${zip_from_extract}    Get Regexp Matches    ${file_to_extract}    [\\w.]+
    ${log_to_extract}    Replace String Using Regexp    ${zip_from_extract[0]}    (.zip)    ${EMPTY}
    unpacking.Unpack Archive Content To Directory
    ...  ${BTS_Files}/snapshot_${timestamp}/${zip_from_extract[0]}    ${BTS_Files}/snapshot_${timestamp}${log_to_extract}
    unpacking.Unpack Archive Content To Directory
    ...  ${BTS_Files}/snapshot_${timestamp}${log_to_extract}/${zip_from_extract[1]}    ${BTS_Files}/BBOX5/${timestamp}

    Set Test Variable  ${path_to_BBOX_file_from_Snapshot}  ${BTS_Files}/BBOX5/${timestamp}/BBOX5

Extract DateTime From Last Save Line
    [Documentation]    Gets the datetime string of the last save from BBOX5.  Takes the argument of BBOX5 file
    ...    in the form of a list of lines.

    [Arguments]    ${line}
    ${datetime}=    Fetch From Right    ${line}    Last save:
    [Return]    ${datetime.strip()}

Get Rel7.1 RMODs List
    ${list_of_modules}    coam.Get Parameters For All    RMOD
    ${rel7.1_radios}    Create List
    ${BTS_parameters}    coam.Get Parameters For All    BTS
    FOR    ${module}  IN  @{BTS_parameters}
        ${bts_id}    Get From Dictionary    ${module}     btsId
    END
    FOR    ${module}  IN  @{list_of_modules}
        ${serial_number}    Get From Dictionary    ${module}    serialNumber
        ${product_name}    Get From Dictionary    ${module}    productName
        ${ip_address}    Get From Dictionary    ${module}    ipAddress
        ${rmod_id}    Get From Dictionary   ${module}    id
        ${dist_name}    Fetch From Right    ${rmod_id}    RUNTIME_VIEW-1/
        ${mrbts_r_id}    Fetch From left    ${dist_name}    /
        ${dist_name}    Remove String    ${dist_name}    ${mrbts_r_id}
        ${dist_name}    Set Variable    MRBTS-${bts_id}${dist_name}
        ${radio_module}    Create Dictionary  serial_number=${serial_number}   product_name=${product_name}    dist_name=${dist_name}
        ...    ip_address=${ip_address}    rmod_id=${rmod_id}
        ${found}=    Get Match Count    ${ALL_REL7.1}    ${product_name}
        Run Keyword If    '${found}'=='1'     Append To List    ${rel7.1_radios}    ${radio_module}
    END
    [Return]    ${rel7.1_radios}

TC Setup
    Common Test Setup

Custom TC Teardown
    Run Keyword If    ${BTS_SW_CHANGED} is ${TRUE}    Run Keywords    Log    Rolling back to initial SW    console=${TRUE}    AND
    ...    coam.Rollback Software    AND
    ...    Wait Until Keyword Succeeds    3m   5s    ping_utils.Check If Host Is Not Pingable    192.168.255.129    AND
    ...    Wait Until Keyword Succeeds  20m  30s  pm_logs_general.Check All Modules And All Cells Working States
    ...    ELSE    Log    Rollback not needed    console=${TRUE}
    Run    rm -rf ${BTS_Files}/snapshot*/

TC Teardown
    Custom TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown

