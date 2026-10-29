*** Settings ***
Documentation
...   author:
...    - Bartłomiej Bieńko (bartlomiej.bienko@nokia.com)
...    - Jakub Kowalczyk (jakub.kowalczyk@nokia.com)
...   maintainers:
...    - Jakub Kowalczyk
...   contact:
...    - Jakub Kowalczyk
...    - Bartłomiej Dubiel (bartlomiej.dubiel@nokia.com)
...    - Justyna Michalik (justyna.michalik@nokia.com)
...
...   feature: CB012194 - FDD configurations with CPRI and OBSAI radio for ABIP/ABIQ #2
...
...   Introduction: This feature extends support for FDD configurations with CPRI and OBSAI radio modules with ABIP/Q BB cards and enables more
...   flexible use of these cards for Multi-RAT deployments (Part Two). CB012194 introduces support for the following:
...       • SDL Nokia CPRI radio modules with ABIP/Q configuration blocks for NR or LTE or NR+LTE deployments.
...       • Nokia CPRI RF fiber split and classic RF sharing with ABIP/Q configuration blocks for Multi-RAT deployments.
...       • OBSAI radio modules triple carrier configuration blocks with ABIP/Q for NR+LTE deployments.
...       • Concurrent operation of radio resiliency functionality with Nokia CPRI radio modules and SBTS-SBTS RF sharing.
...
...   Testing Scope: D5 - 6T6R and 3T6R OBSAI radio modules support for triple carriers in "K" or "N" sector type configuration with ABIP/Q

Resource    resources/keywords.robot
Library     taf.rfrl.csv4all.CSV4AllTestCases


Suite Setup    Common Suite Setup With OnAir Test Line Preparation  should_LTE_neighbour_be_changed=${False}
...                                                                 should_5G_neighbour_be_changed=${False}
...                                                                 increase_time_for_checking_bbmod=600
...                                                                 increase_timeout_for_update_sw=1800
...                                                                 increase_time_for_checking_radios=2100
...                                                                 increase_time_for_checking_cells=700
...                                                                 swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt

Suite Teardown    Common Suite Teardown


*** Variables ***
${5G_SOURCE_SW}        SBTS00_ENB_9999_240603_000005
${5G_TARGET_SW}        SBTS00_ENB_9999_240610_000010

@{CUSTOM_ALLOWED_ALARMS}=       61648    7115    4420    4123    4125    8150    4459    8000
@{CRITICAL_FAULTS}              10  1806  16  4341  4383  4352  1868  69
${REMOTE_VM_IP}=                ${tl.test_pcs[0].default_ssh_connection_details.addr}
${REMOTE_MPLANE}=               ${tl.gnbs[0].oam_ip.v4.split('/')[0]}
${HOSTNAME}=                    7_7_UTE5GCLOUDT166
${TARGET_DIR}                   /home/ute/UUF_SW/
${SHOULD_BE_REPORTED}=          ${False}
${USE_REMOTE_NODE}=             ${False}
@{EMPTY}=

${UE_TYPE}                           quectel
${UE_CAPABILITIES}                   QUECTEL_UE
${UE_DEFAULT_ALIAS_NAME}             UE
${DEFAULT_PACKET_SIZE_DL}            1416
${DEFAULT_PACKET_SIZE_UL}            1416
${DEFAULT_PACKET_SIZE}               1416
${DEFAULT_SEGMENT_SIZE_NR}           ${DEFAULT_PACKET_SIZE}
${DEFAULT_PROTOCOL}                  tcp
${DEFAULT_DEVIATION}                 20%
${DEFAULT_TPUT_UL_NR}                100Mbits/sec
${DEFAULT_TPUT_DL_NR}                330Mbits/sec
${DEFAULT_TPUT_UL_LTE}               45Mbits/sec
${DEFAULT_TPUT_DL_LTE}               170Mbits/sec
${DATA_TRANSFER_DURATION}            100s
${DATA_TRANSFER_DEFAULT_DURATION}    100s

${TPUT_DL_NR_4x4_20MHz}              380Mbits/sec
${TPUT_DL_NR_2x2_20MHz}              200Mbits/sec
${TPUT_UL_NR_20MHz}                  105Mbits/sec
${TPUT_DL_LTE_4x4_10MHz}             185Mbits/sec
${TPUT_DL_LTE_2x2_10MHz}             92Mbits/sec
${TPUT_UL_LTE_10MHz}                 45Mbits/sec
${TPUT_DL_LTE_4x4_5MHz}              86Mbits/sec
${TPUT_UL_LTE_5MHz}                  17Mbits/sec
${NR_DEVIATION}                      65%
${LTE_DEVIATION}                     20%
${DEFAULT_BAND}                      3

@{TPUT_NR_4x4_20MHz}=                ${TPUT_DL_NR_4x4_20MHz}   ${TPUT_UL_NR_20MHz}
@{TPUT_NR_2x2_20MHz}=                ${TPUT_DL_NR_2x2_20MHz}   ${TPUT_UL_NR_20MHz}
@{TPUT_LTE_4x4_10MHz}=               ${TPUT_DL_LTE_4x4_10MHz}  ${TPUT_UL_LTE_10MHz}
@{TPUT_LTE_2x2_10MHz}=               ${TPUT_DL_LTE_2x2_10MHz}  ${TPUT_UL_LTE_10MHz}
@{TPUT_LTE_4x4_5MHz}=                ${TPUT_DL_LTE_4x4_5MHz}   ${TPUT_UL_LTE_5MHz}

&{TPUT_NR_CELL_MAPPING}=             2=@{TPUT_NR_4x4_20MHz}    3=@{TPUT_NR_2x2_20MHz}    6=@{TPUT_NR_4x4_20MHz}
...                                  1=@{TPUT_NR_4x4_20MHz}    5=@{TPUT_NR_2x2_20MHz}
&{TPUT_LTE_CELL_MAPPING}=            11=@{TPUT_LTE_4x4_10MHz}  12=@{TPUT_LTE_4x4_10MHz}
...                                  13=@{TPUT_LTE_2x2_10MHz}  14=@{TPUT_LTE_2x2_10MHz}
...                                  19=@{TPUT_LTE_4x4_10MHz}  20=@{TPUT_LTE_4x4_5MHz}
...                                  17=@{TPUT_LTE_2x2_10MHz}  18=@{TPUT_LTE_2x2_10MHz}

&{ARFCN_NR_MAPPING}=                 2=362670    3=363150    6=370850
...                                  5=362910
&{ARFCN_LTE_MAPPING}=                11=1450  12=1550  13=1650  14=1750  19=1850  20=1925
...                                  17=1650  18=1750

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}

@{NODES}                            ${NODE1}

*** Test Cases ***
CB012194_01_Manual_SiSo_CM_Recommissioning
    [Tags]    01    CRT
    [Setup]    Run Keywords
    ...    Log To Console    Test Setup...    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    BTS Reset Cause    AND
    ...    Common Preconditions With Watching Alarms    collect_syslog=${False}

    Log To Console    01
    ${MRBTS_ID}=    sg7keywords.get_mrbts_id
    Set Test Variable    ${MRBTS_ID}     ${MRBTS_ID}


    Log To Console    Preconditions: Change initial params..    no_newline=True
    ${delta}=  prepare_parameters_delta    distname=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2
    ...  parameter=enDcSyncStatus  value=asynchronous
    Perform Delta Commissioning On gNB    delta=${delta}
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    Log To Console    . Done


    Log To Console    Step 1 - parameter change require NR Rat reset
    Set parameter [enDcSyncStatus] from object [MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-2] to value [synchronous] and expect nr rat reset
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    L3 Call on NR Cells    2    cell_select_by=arfcn    arfcn=&{ARFCN_NR_MAPPING}

    Log To Console    Step 2 - parameter change require LTE Rat reset
    Set parameter [actExtN77Support] from object [MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}] to value [true] and expect lte rat reset
    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    L3 Call on LTE Cells    11    cell_select_by=arfcn    arfcn=&{ARFCN_LTE_MAPPING}

    Log To Console    Step 3 - parameter change require Site reset
    Set parameter [holdOverModeUsed] from object [MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1] to value [true] and expect bts reset
    Sleep    1 min
    Wait For Site To Be Onair    timeout=300
    gnbcell.Wait For All Cells To Be OnAir    timeout=300


    Log To Console    Step 4 - online parameter change
    Set parameter [inactivityTimer] from object [MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-11] to value [31] and expect online modification
    Verify On-Air
    Log To Console    Step 5 - wrong parameter value
    ${msg}=    Run Keyword And Expect Error    STARTS: AdminApiProcedureFailureException
    ...        Perform Configuration Parameter Recommissioning On gNB    dist_name=MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-8/LNCEL_FDD-0
    ...                                                                  param_name=prachFreqOff
    ...                                                                  operation=update
    ...                                                                  param_value=-1
    Set Test Variable    ${search}    VALUE_IS_TOO_SMALL
    Should Contain    ${msg}    ${search}

    L3 Call on NR Cells    5    cell_select_by=none    ue_alias=UE2    capabilities=QUECTEL_UE2
    L3 Call on LTE Cells    17    cell_select_by=arfcn    arfcn=&{ARFCN_LTE_MAPPING}    ue_alias=UE2    capabilities=QUECTEL_UE2

    [Teardown]    Run Keywords
    ...    Cleanup After TC01
    ...    Test Teardown
    ...    Common Postconditions With Watching Alarms


CB012194_06_General_SiSo_NR_Cell_block_and_unblock
    [Tags]    06    CRT
    [Setup]    Run Keywords
    ...    Log To Console    Test Setup...    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Cell blocked    AND
    ...    Common Preconditions With Watching Alarms    collect_syslog=${False}

    sg7keywords.Block cells    [0,1,2,3,4,5,6]
    Verify Alarm is Active on gNB    fault_name=Cell blocked
    Sleep    60
    sg7keywords.Unblock cells        [0,1,2,3,4,5,6]
    gnbcell.Wait For All Cells To Be OnAir    timeout=600
    Verify Alarm is not Active on gNB    fault_name=Cell blocked

    L3 Call on NR Cells    2  6    cell_select_by=arfcn    arfcn=&{ARFCN_NR_MAPPING}
    L3 Call on NR Cells    5    cell_select_by=none    ue_alias=UE2    capabilities=QUECTEL_UE2

    [Teardown]    Run Keywords
    ...    Run Keyword If Test Failed    sg7keywords.Unblock cells        [0,1,2,3,4,5,6]    ignore_error=${True}    AND
    ...    Test Teardown    AND
    ...    Common Postconditions With Watching Alarms


CB012194_07_Manual_SiSo_SM_BTS_Site_Reset
    [Tags]    07    CRT
    [Setup]    Run Keywords
    ...    Log To Console    Test Setup...    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    BTS Reset Cause    AND
    ...    Common Preconditions With Watching Alarms    collect_syslog=${False}

    Reset gNB
    Wait For Site To Be Onair  timeout=600
    gnbcell.Wait For All Cells To Be OnAir    timeout=300

    L3 Call on NR Cells    2    cell_select_by=arfcn    arfcn=&{ARFCN_NR_MAPPING}
    L3 Call on LTE Cells    12    cell_select_by=arfcn    arfcn=&{ARFCN_LTE_MAPPING}

    [Teardown]    Run Keywords
    ...    Test Teardown
    ...    Common Postconditions With Watching Alarms


CB012194_08_Manual_SiSo_SM_LTE_Cell_block_unblock
    [Tags]    08    CRT
    [Setup]    Run Keywords
    ...    Log To Console    Test Setup...    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Cell blocked    AND
    ...    Common Preconditions With Watching Alarms    collect_syslog=${False}


    sg7keywords.Block cells    [7,8,9,10,11,12,13,14,15,16,17,18,19,20]
    Verify Alarm is Active on gNB    fault_name=Cell blocked
    Sleep    60
    sg7keywords.Unblock cells    [7,8,9,10,11,12,13,14,15,16,17,18,19,20]
    gnbcell.Wait For All Cells To Be OnAir    timeout=600
    Verify Alarm is not Active on gNB    fault_name=Cell blocked

    L3 Call on LTE Cells    11  12  19  20    cell_select_by=arfcn    arfcn=&{ARFCN_LTE_MAPPING}
    L3 Call on LTE Cells    17  18    cell_select_by=arfcn    arfcn=&{ARFCN_LTE_MAPPING}    ue_alias=UE2    capabilities=QUECTEL_UE2

    [Teardown]    Run Keywords
    ...    Run Keyword If Test Failed    sg7keywords.Unblock cells       [3,7,8,9,10,11,12,13,14,15,16,17,18,19,20]     ignore_error=${True}    AND
    ...    Test Teardown    AND
    ...    Common Postconditions With Watching Alarms


CB012194_09_General_SiSo_BB_sub-unit_reset_with_L3_call
    [Tags]    09    CRT
    [Setup]    Custom UUF Test Setup

    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=2
    ...          report=${False}
    ...          l3_call_method=L3 Call 09 LTE and NR Cell

    [Teardown]    Custom UUF Test Teardown

CB012194_10_General_SiSo_RU_module_reset_from_GUI
    [Tags]    10    CRT
    [Setup]    Run Keywords
    ...    Log To Console    Test Setup...    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Transmission path failure    AND
    ...    Common Preconditions With Watching Alarms    collect_syslog=${False}

    Reset gNB Radio Unit    radio_unit_id=2
    Log Alarms    also_console=${False}
    Wait For Site To Be Onair  timeout=180
    gnbcell.Wait For All Cells To Be OnAir    timeout=180

    L3 Call on LTE Cells    12    cell_select_by=arfcn    arfcn=&{ARFCN_LTE_MAPPING}
    L3 Call on NR Cells    2    cell_select_by=arfcn    arfcn=&{ARFCN_NR_MAPPING}

    [Teardown]    Run Keywords
    ...    Test Teardown
    ...    Common Postconditions With Watching Alarms


CB012194_11_Manual_SiSo_SM_NR_cell_lock_unlock_administrative_state_change_from_GUI
    [Tags]    11    CRT
    [Setup]    Run Keywords
    ...    Log To Console    Test Setup...    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    BTS Reset Cause    AND
    ...    Common Preconditions With Watching Alarms    collect_syslog=${False}


    Lock gNB Cells And Verify Results    2  5  6

    L3 Call on LTE Cells    11  19    cell_select_by=arfcn    arfcn=&{ARFCN_LTE_MAPPING}
    L3 Call on LTE Cells    18    cell_select_by=arfcn    arfcn=&{ARFCN_LTE_MAPPING}    ue_alias=UE2    capabilities=QUECTEL_UE2

    sg7keywords.Unlock gNB Cell    cell_id=5
    L3 Call on NR Cells    5    cell_select_by=none    ue_alias=UE2    capabilities=QUECTEL_UE2

    Log To Console    Reset BTS..    no_newline=True
    Reset gNB
    Log To Console    . Done

    Wait For Site To Be Onair     timeout=300
    Wait for cell to be locked    timeout=300    cell_id=2
    Wait for cell to be locked    timeout=300    cell_id=6


    L3 Call on NR Cells    5    cell_select_by=none    ue_alias=UE2    capabilities=QUECTEL_UE2

    sg7keywords.Unlock gNB Cell    cell_id=6
    L3 Call on NR Cells    6    cell_select_by=arfcn    arfcn=&{ARFCN_NR_MAPPING}

    sg7keywords.Unlock gNB Cell    cell_id=2
    L3 Call on NR Cells    2    cell_select_by=arfcn    arfcn=&{ARFCN_NR_MAPPING}
    L3 Call on LTE Cells    11  19    cell_select_by=arfcn    arfcn=&{ARFCN_LTE_MAPPING}
    L3 Call on LTE Cells    18    cell_select_by=arfcn    arfcn=&{ARFCN_LTE_MAPPING}    ue_alias=UE2    capabilities=QUECTEL_UE2

    [Teardown]    Run Keywords
    ...    Cleanup After TC11
    ...    Test Teardown
    ...    Common Postconditions With Watching Alarms


CB012194_12_Manual_SiSo_SM_BTS_Block_Site
    [Tags]    12    CRT
    [Setup]    Run Keywords
    ...    Log To Console    Test Setup...    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    BTS blocked    BTS Reset Cause    AND
    ...    Common Preconditions With Watching Alarms    collect_syslog=${False}


    Log To Console    Block Site..    no_newline=True
    gnbbbu.block_bts
    Log To Console    . Site blocked
    Log Alarms    also_console=${False}

    Sleep    60
    Log To Console    Unblock Site..    no_newline=True
    gnbbbu.unblock_bts    timeout=300
    Log To Console    . Site unblocked, ..
    Log Alarms    also_console=${False}
    Wait For Site To Be Onair  timeout=300
    gnbcell.Wait For All Cells To Be Onair    timeout=300
    Log To Console    . Cells OnAir    no_newline=True

    L3 Call on NR Cells    6    cell_select_by=arfcn    arfcn=&{ARFCN_NR_MAPPING}
    L3 Call on LTE Cells    19    cell_select_by=arfcn    arfcn=&{ARFCN_LTE_MAPPING}

    [Teardown]    Run Keywords
    ...    Test Teardown
    ...    Common Postconditions With Watching Alarms


CB012194_13_Manual_SiSo_SM_RU_Module_lock_unlock
    [Tags]    13    CRT
    [Setup]    Run Keywords
    ...    Log To Console    Test Setup...    AND
        ...    Common Preconditions With Watching Alarms    collect_syslog=${False}

    Lock Radio Unit on gNB    radio_unit_id=5
    Sleep    10
    Log Alarms    also_console=${False}
    Unlock Radio Unit on gNB    radio_unit_id=5
    Wait For Site To Be Onair  timeout=180
    gnbcell.Wait For All Cells To Be OnAir    timeout=180

    L3 Call on LTE Cells    19    cell_select_by=arfcn    arfcn=&{ARFCN_LTE_MAPPING}
    L3 Call on NR Cells    6    cell_select_by=arfcn    arfcn=&{ARFCN_NR_MAPPING}

    [Teardown]    Run Keywords
    ...    Test Teardown
    ...    Common Postconditions With Watching Alarms


CB012194_14_General_SiSo_stability_with_L3Call
    [Tags]    14    CRT
    [Setup]    Run Keywords
    ...    Log To Console    Test Setup...    AND
    ...    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Cell blocked    AND
    ...    Common Preconditions With Watching Alarms    collect_syslog=${False}

    Log To Console    SiSo_stability_with_L3Call

    L3 Call on NR Cells    2  6    duration=300s    deviation=5%    cell_select_by=arfcn    arfcn=&{ARFCN_NR_MAPPING}
    L3 Call on NR Cells    5    duration=300s    deviation=5%    cell_select_by=none    ue_alias=UE2    capabilities=QUECTEL_UE2
    L3 Call on LTE Cells    11  12  19  20    duration=300s    deviation=5%    cell_select_by=arfcn    arfcn=&{ARFCN_LTE_MAPPING}
    L3 Call on LTE Cells    17  18    duration=300s    deviation=5%    cell_select_by=arfcn    arfcn=&{ARFCN_LTE_MAPPING}
    ...                     ue_alias=UE2    capabilities=QUECTEL_UE2

    [Teardown]    Run Keywords
    ...    Test Teardown
    ...    Common Postconditions With Watching Alarms

*** Keywords ***
Custom UUF Test Setup
    Log To Console    Test Setup...
    common_setups_and_teardowns.Common Preconditions    collect_syslog=${False}

Custom UUF Test Teardown
    Log To Console    Test Teardown...
    Wait For Site To Be Onair  timeout=300
    Run Keyword If Test Passed    gnbcell.Wait For All Cells To Be OnAir    timeout=300
    common_setups_and_teardowns.Common Postconditions With Restore Configuration If Test Failed

