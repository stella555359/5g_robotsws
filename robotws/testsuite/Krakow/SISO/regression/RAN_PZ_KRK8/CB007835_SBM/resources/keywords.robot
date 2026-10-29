*** Settings ***
Documentation
...   Keywords for CB007835 SBM - Key customer scenario testing
...   author: Bartosz Odziomek
...   contact: bartosz.odziomek@nokia.com

Library    testsuite.Krakow.SISO.regression.RAN_PZ_KRK8.CB007835_SBM.resources.resources.CB007835SBM
...  WITH NAME    local_resources
Library    ../../../../regression/RAN_PZ_KRK1/CB007835/resources/resources.py  WITH NAME    imported_resources
Library    ute_ue    WITH NAME    local_ue_library
Library    taf.ue    WITH NAME    ue
Library      String
Library      taf.rfrl.csv4all.CSV4AllTestCases
Library      taf.rfrl.utilities.cloud_manager.artifacts
Library      testsuite/Krakow/resources/UUF/get_uuf_builds.py
Library      taf.rfrl.ue.logs.qxdm_logs.WindowsUePcUtil
Resource     taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables    taf/rfrl/procedures/resources/python/common_allowed_alarms.py

*** Variables ***
${REGEX}                  SBTS00_ENB_9999_[0-9]{6}_[0-9]{6}
${FILES_BASE}             http://files.ute.nsn-rdnet.net/builds/enb/base/
${buffer_client_dl}       8M
${buffer_server_dl}       8M
${buffer_client_ul}       2M
${buffer_server_ul}       2M

*** Keywords ***
QC Set Project
    Set Suite Variable     ${RAN_VRF}      SBTS00
    Run Keyword If    '${RAN_VRF}' in '${ENB_BUILD}'    Set Suite Variable      ${QC_PROJECT}   RAN_VRF

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
    [Arguments]    ${ue_alias}
    Execute ue pc cmd    ue_id=${0}    cmd=cmd.exe /c "adb reconnect offline"
    Sleep    10s
    Run Keyword And Ignore Error    local_ue_library.Require Ue    ue_alias=UE    capabilities=REAL_UE_1
    Run Keyword And Ignore Error    local_ue_library.Detach Ue    ${ue_alias}
    Sleep    1s
    local_ue_library.Attach Ue    ${ue_alias}     timeout=40
    Sleep    3s
    Check Signal Strength For Ue    ${ue_alias}
    local_ue_library.Log Ue Info    ${ue_alias}    ALL

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
    [Arguments]    ${release}
    ${target_build}=    Check Latest Candidate Build    ${release}
    local_resources.update_gnb_to_build_via_gui    ${target_build}

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

Run throughput and verify gNB State
    [Arguments]     ${run_tpt}=${True}
    Verify All Radio Module Status
    Verify Setup Of All Cells
    Verify gNB is onAir
    Verify Allowed Alarms on gNB    allowed_alarms=@{allowed_alarms}
    Start watching alarms    allowed_alarms=${allowed_alarms}
    keywords.Prepare Ue    UE
    Watch Active Alarms and Collect Logs on Unexpected Alarm
    Run Keyword If    ${run_tpt}
    ...    imported_resources.Perform Bidirectional Throughput Test For Single Ue    ue_alias=UE    duration=1min
    ...         protocol=tcp    tput_dl=${single_ue_tput_dl}    tput_min_dl=${min_single_ue_tput_dl}
    ...         parallel_streams_dl=8    tput_ul=${single_ue_tput_ul}    tput_min_ul=${min_single_ue_tput_ul}
    ...         linux_congestion=reno    max_segment_size=1300    apn=5gbothkrk

Check Signal Strength For Ue
    [Arguments]    ${ue}
    ${result}    ue.Get ue info    ${ue}    SIGNAL_STRENGTH
    Run Keyword If    ${result} < -94
    ...    Log    RSRP value for the UE is too low.    WARN

Simple L3 call keyword
    [Arguments]     ${cell_used_in_test}
    Log to console    Cell used in test ${cell_used_in_test}
    Set Suite Variable    ${ue_pc_address}     PLKR-UE-PC01.intra.noklab.net
    Set Suite Variable    ${ue_pc_login}       pzkrk
    Set Suite Variable    ${ue_pc_password}    NokiaBts2003
#    Restart UE Proxy On UE PC
#    local_ue_library.Require Ue    ue_alias=UE   capabilities=REAL_UE_1
    Run Keyword And Ignore Error    keywords.Prepare Ue    UE
    Run Keyword And Ignore Error    ute_ue.Detach Ue    UE

Custom Suite Setup
    Common Suite Setup With OnAir Test Line Preparation
    ...                         increase_timeout_for_update_sw=${1800}
    ...                         list_of_additional_allowed_alarms=${CUSTOM_ALLOWED_ALARMS_DURING_TL_PREPARATION}
    ...                         swconfig_from_path=${SWCONFIG_PATH}

    ${SOURCE_SW} =          IF    '${SOURCE_SW}'=='${None}'   Get CM Source Build    ELSE    Set Variable  ${SOURCE_SW}
    ${TARGET_SW} =          IF    '${TARGET_SW}'=='${None}'   Get Target Build       ELSE    Set Variable  ${TARGET_SW}


    Set Global Variable  ${SOURCE_SW}
    Set Global Variable  ${TARGET_SW}

Custom Test Setup
    common_setups_and_teardowns.Common Preconditions
    ...    collect_syslog=${False}
    ...    collect_ru_console_log=${False}
    Run Keyword And Ignore Error    Remove Directory         path=/home/ute/.ute-ca/cache/bts/    recursive=${True}

Custom Test Teardown
    gnbbbu.connect    force=${True}
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed
    ...    collect_snapshot_from_ru=${False}

Custom Test Teardown for tput test
    Run Keyword And Ignore Error    ute_ue.Detach Ue    UE
    Run Keyword And Ignore Error    ute_ue.Release Ue    UE
    gnb_alarm.Stop watching alarms
    Custom Test Teardown


