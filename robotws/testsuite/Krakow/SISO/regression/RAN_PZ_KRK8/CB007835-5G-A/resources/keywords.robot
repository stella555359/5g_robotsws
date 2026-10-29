*** Settings ***
Documentation
...   Keywords for CB007835-5G-A - Key customer scenario testing - 5G21C-TMO TDD mmWave KRK
...   author: Mateusz Iwankiewicz
...   contact: mateusz.iwankiewicz@nokia.com

Library      String
Library      Process
Library      DateTime
Library      OperatingSystem
Library      taf.rfrl.bts.commissioning     WITH NAME    commissioning
Library      testsuite/Krakow/resources/UUF/upgrade_and_commission_bts.py
Library      taf.rfrl.bts.devices.du.cell_operations.GnbCellOperations
...          WITH NAME    gnbcell
Library      taf.rfrl.bts.devices.ru.ru_operations.GnbRuOperations
...          WITH NAME    gnbru
Library      testsuite.Krakow.SISO.regression.RAN_PZ_KRK8.CB007835-5G-A.resources.resources.CB007835AResources
...          WITH NAME    local_resources
Library      taf.rfrl.bts.devices.ru.ru_serial_logs_collector.GnbRuSerialLogsCollector
...          WITH NAME    gnb_ru_lmi
Library      ../../../../regression/RAN_PZ_KRK1/CB007835/resources/resources.py
...          WITH NAME    imported_resources
Library      ute_ue    WITH NAME    local_ue_library
Library      taf.ue    WITH NAME    ue
Resource     taf/rfrl/bts/robot/common/gnb_log.robot
Resource     taf/rfrl/ue/robot/REAL_UE.robot

*** Variables ***
${REGEX}                  SBTS00_ENB_9999_[0-9]{6}_[0-9]{6}
${FILES_BASE}             http://files.ute.nsn-rdnet.net/builds/enb/base/
${buffer_client_dl}       8M
${buffer_server_dl}       8M
${buffer_client_ul}       2M
${buffer_server_ul}       2M

*** Keywords ***
Test Suite Setup
    Set Global Variable    ${TARGET_SW}    ${ENB_BUILD}
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ***** Source Software Set to: ${SOURCE_SW} *****
    Log to console    ***** Target Software Set to: ${TARGET_SW} *****
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- Preparing TestLine for testing ----
    Run    mkdir /home/ute/Downloads
    Pubs Mount
    Download Source Build
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- Upgrading BTS to ${SOURCE_SW} ----\n
    Upgrade and Commission Gnb    builds_dir=${TARGET_DIR}  sw_build=${SOURCE_SW}  prefix_tag=${SCF_PREFIX}
    Wait until keyword succeeds    1200 sec    30 sec    gnbcell.Verify All Cells Are Onair
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- Uploading SWconfig on gNB ----\n
    commissioning.Upload Swconfig On Classical Gnb
    ...    sw_config_path=${SW_CONFIG_PATH}
    ...    reboot_after_upload=${True}
    Wait For RMOD Offline On GNB
    Wait until keyword succeeds    1200 sec    30 sec    gnbcell.Verify All Cells Are Onair
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- SWconfig has been uploaded ----\n
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- Collecting snapshot to remove Diagnostic Files Collected alarm ----\n
    Collect Snapshot From gNB    log_dir=${OUTPUT_DIR}/${SUITE_NAME}
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- Snapshot has been collected ----\n
    Run     rm ${TARGET_DIR}/${SOURCE_SW}_release_BTSSM_downloadable_A54.zip
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- Source software has been deleted from ${TARGET_DIR} ----\n
    Common Suite Setup
    gnb_ru_lmi.Setup Hosts For All RU Console Collection
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- TestLine has been prepared for testing ----\n

Download Source Build
    [Arguments]    ${timeout}=600
    Log to console    ---- Downloading ${SOURCE_SW} ----
    ${first_part}=    Fetch From Left    ${SOURCE_SW}    _
    Set Suite Variable    ${SOURCE_BRANCH}    ${first_part}
    Start Process    cp    /home/ute/pubs/LOADS/${SOURCE_BRANCH}/${SOURCE_SW}_release_BTSSM_downloadable_A54.zip    ${TARGET_DIR}    alias=file_copy
    ${result}=    Wait For Process    file_copy    timeout=${timeout}
    Should Be Equal As Integers    ${result.rc}    0    Copy failed: ${result.stderr}
    File Should Exist    ${TARGET_DIR}/${SOURCE_SW}_release_BTSSM_downloadable_A54.zip
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- Software downloaded ----

Pubs Mount
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- Mounting PUBS ----
    Run    sudo su -c 'mkdir /mnt/pubs'
    ${terminator}=    Catenate    SEPARATOR=${SPACE}
    ...    sudo su -c 'echo "//10.83.200.250/project/pubs /mnt/pubs cifs
    ...    user,username=pubs,vers=3.0,password=pubs123,domain=KRK-NAS,uid=ute,gid=ute 0 0"  >> /etc/fstab'
    Run    ${terminator}
    Run    sudo su -c 'mount /mnt/pubs'
    Run    sudo su -c 'ln -s /mnt/pubs/ /home/ute/pubs'
    File Should Exist    /home/ute/pubs/pubs
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    ---- PUBS mounted successfully ----

Wait For RMOD Offline On GNB
    [Arguments]    ${id}=${1}
    Wait Until Keyword Succeeds  10min  20s  gnbru.verify_radio_unit_statuses  ru_id=${id}  availability_status=offline

Custom Test Setup
    common_setups_and_teardowns.Common Preconditions
    ...    collect_syslog=${False}
    ...    collect_ru_console_log=${False}
    gnb_ru_lmi.Setup Serial Console Connection for All RUs
    ...    raise_exception=${True}
    Run Keyword And Ignore Error    Remove Directory         path=/home/ute/.ute-ca/cache/bts/    recursive=${True}ursive=${True}

Custom Test Teardown
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
    gnb_ru_lmi.Collect Snapshot From all Setup RUs
    gnb_ru_lmi.Collect Console Log From all Setup RUs
    gnb_ru_lmi.Teardown Serial Console Connection for All Setup RUs
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report

Test Suite Teardown
    ${CurrentDate}    Get Current Date    result_format=%H:%M:%S
    Log to console    \n${CurrentDate}
    Log to console    \n********************************************
    Log to console    \n---- Start Suite Teardown ----\n
    Common Suite Teardown
    Run Keyword and Ignore Error    gnb_ru_lmi.Teardown Hosts For All RU Console Collection
    Log to console    \n---- Suite Teardown DONE ----\n
    Log to console    \n********************************************

Set test parameters and verify attach is possible
    [Arguments]    ${parameter_set}    ${ue_alias}
    ${success}=  local_resources.Recommission test parameters    ${parameter_set}
    Should Be True    ${success}
    Wait Until Keyword Succeeds    400 sec    10 sec      Verify Setup Of All Cells
    Attach and detach    ${ue_alias}

Attach and detach
    [Arguments]    ${ue_alias}
    local_ue_library.Attach UE    ${ue_alias}
    Sleep    10s
    local_ue_library.Detach UE    ${ue_alias}

Prepare Ue
    [Arguments]    ${ue_alias}    ${capability}
    local_ue_library.Require Ue    ue_alias=${ue_alias}    capabilities=${capability}
    local_ue_library.Detach Ue    ${ue_alias}
    Sleep    1s
    local_ue_library.Attach Ue    ${ue_alias}
    Sleep    3s
    Check Signal Strength For Ue    ${ue_alias}

Simple L3 Call Test
    [Arguments]                             ${cell_used_in_test}
    Log                                     ${cell_used_in_test}
    Verify L3 Call One Way Data Transfer
    ...                                     direction=dl
    ...                                     duration=120s
    ...                                     tput=2400 Mbits/sec
    ...                                     protocol=tcp
    ...                                     deviation=40%

Downgrade to previous candidate build
    [Arguments]    ${downgrade_timeout}=1200
    ${target_build}=    Get Previous Candidate Build
    local_resources.update_gnb_to_build_via_oam    ${target_build}    ${downgrade_timeout}

Upgrade to target build
    [Arguments]    ${target_build_regex}
    Set Test Variable   ${curl_cmd}    curl -R ${FILES_BASE} | grep -o -E '${target_build_regex}' | head -1
    ${result}   Run Process    ${curl_cmd}  shell=True  alias=curl
    local_resources.update_gnb_to_build_via_gui    ${result.stdout}

Upgrade to latest candidate build
    [Arguments]    ${release}    ${upgrade_timeout}=1200
    ${target_build}=    Check Latest Candidate Build    ${release}
    local_resources.update_gnb_to_build_via_gui    ${target_build}    ${upgrade_timeout}

Check Latest Candidate Build
    [Arguments]     ${release}
    ${today}    Get Current Date   result_format=%d-%b-%Y
    ${build_regex}      Catenate  SEPARATOR=    >   ${release}  ${REGEX}
    Set Test Variable   ${curl_cmd}      curl -R ${FILES_BASE} | grep ${today} | grep -o -E '${build_regex}' | head -1
    ${result}   Run Process    ${curl_cmd}  shell=True  alias=curl
    [Return]    ${result.stdout[1:]}

Get Previous Candidate Build
    ${build_regex}=  local_resources.get_previous_sw_build_regex
    Set Test Variable   ${curl_cmd}    curl -R ${FILES_BASE} | grep -o -E '${build_regex}' | head -1
    ${result}   Run Process    ${curl_cmd}  shell=True  alias=curl
    # Log To Console    Build search result: ${result.stdout}
    [Return]    ${result.stdout}

Verify gNB State
    [Arguments]     ${run_tpt}=${True}
    Verify All Radio Module Status
    Verify Setup Of All Cells
    Verify gNB is onAir
    Verify Allowed Alarms on gNB    allowed_alarms=@{allowed_alarms}
    Start watching alarms    allowed_alarms=${allowed_alarms}
    Watch Active Alarms and Collect Logs on Unexpected Alarm
    Prepare Ue    UE_1    ${capabilities}
    Run Keyword If    ${run_tpt}
    ...    imported_resources.Perform Bidirectional Throughput Test For Single Ue    ue_alias=UE_1    duration=2min
    ...         protocol=tcp    tput_dl=${single_ue_tput_dl}    tput_min_dl=${min_single_ue_tput_dl}
    ...         parallel_streams_dl=3    tput_ul=${single_ue_tput_ul}    tput_min_ul=${min_single_ue_tput_ul}
    ...         linux_congestion=reno    max_segment_size=1300
    gnb_alarm.Stop watching alarms

Check Signal Strength For Ue
    [Arguments]    ${ue}
    ${result}    ue.Get ue info    ${ue}    SIGNAL_STRENGTH
    Run Keyword If    ${result} < -94
    ...    Log    RSRP value for the UE is too low.    WARN
