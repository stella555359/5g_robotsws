*** Settings ***
Documentation    Testsuite
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock.robot
Resource    ../../../test_resources/RRM__RFS__Data_Transfer_Taf_Ue.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.robot
Resource    ../../../test_resources/UUF_SW_UPGRADE_ROLLBACK.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.robot
Resource    ../../../test_resources/UUF_SITE_RESET_WITHOUT_HWF.robot

Library    taf.sbts.oam.coam.admin  WITH NAME  coam

Library    Collections
Library    taf/rfrl/csv4all/CSV4AllTestCases.py
Resource   taf/rfrl/uuf4all/uuf4all_keywords.robot

#UUF4ALL scope
Force Tags      CA_VRF_TSR2

#UUF4ALL scope
Suite Setup                     Set Initial And Candidate

*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${POWER_ON_FLAG}    ${True}

# UUF4ALL Section
#Helper variable do teremine status of ST4.7 upgrade

${UPDATE_TEST_FAILED}          ${False}

@{CUSTOMERS}=                   Generic
${INITIAL}=                     ${None}
${CANDIDATE}=                   ${None}
${UPGRADE_ITERATION}=           1
${TEMP_ALLOWED_FAULTS}=         ${None}

# CNI 103974: 4773
# PPS reference missing, severity: Major, alarm_id: 7108, fault_id: 1898
# LTE DSS: 6134  6132  6129
# NR DSS: 7513  7511  7509
# cellX2 links and/or NG links and/or E1 link unavailability: 7107

@{CUSTOM_ALLOWED_ALARMS}        4773  1898  1815  6826  7114  4452  6825  6833


&{node1}                        node_alias=NR_BTS1
...                             testline_object=${tl.gnbs[0]}
...                             source_sw=${INITIAL}
...                             target_sw=${CANDIDATE}
...                             temporary_allowed_alarms=${TEMP_ALLOWED_FAULTS}
...                             custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}

&{node2}                        node_alias=LTE_BTS2
...                             testline_object=${tl.enbs[0]}
...                             source_sw=${INITIAL}
...                             target_sw=${CANDIDATE}
...                             temporary_allowed_alarms=${TEMP_ALLOWED_FAULTS}
...                             custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}

@{nodes}                        ${node1}  ${node2}


*** Test Cases ***
#UUF4ALL Upgrade Test-Case
[1]UUF_SW_UPGRADE_ROLLBACK
    [Timeout]    32400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.gnbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS3_testline_object}
    ...    AND    Set Test Variable    ${BTS4_testline_object}
    ...    AND    Set Test Variable    ${BTS1_source_sw}
    ...    AND    Set Test Variable    ${BTS2_source_sw}
    ...    AND    Set Test Variable    ${BTS3_source_sw}
    ...    AND    Set Test Variable    ${BTS4_source_sw}
    ...    AND    Set Test Variable    ${BTS1_target_sw}
    ...    AND    Set Test Variable    ${BTS2_target_sw}
    ...    AND    Set Test Variable    ${BTS3_target_sw}
    ...    AND    Set Test Variable    ${BTS4_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    4773,1898,1815,6826,7114,4452,6825,6833
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}    4773,1898,1815,6826,7114,4452,6825,6833
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${SYNCHRONIZE_SW_ON_PASSIVE}    True
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    BTS1,BTS2
    ...    AND    Set Test Variable    ${RESTORE_TO_TARGET_SW}    True
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    3
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    Generic
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    True
    ...    AND    Set Test Variable    ${USE_DCAP}    False
    ...    AND    Set Test Variable    ${REPORT}    True
    ...    AND    Set Test Variable    ${TAGS}    CA_VRF_TSR2
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T03

    ...    AND    UUF_SW_UPGRADE_ROLLBACK.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE_ROLLBACK
    ...    AND    Set Library Search Order    UUF_SW_UPGRADE_ROLLBACK
    TC__UUF_SW_UPGRADE_ROLLBACK
    [Teardown]    Run Keywords    UUF_SW_UPGRADE_ROLLBACK.TC Teardown
    ...    AND    Restore Resource Search Order

[1]RRM__RFS__Data_Transfer_Taf_Ue_1
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    300 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True

    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order

[1]UUF_SITE_RESET_WITHOUT_HWF
    [Timeout]    46800
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.gnbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS3_testline_object}
    ...    AND    Set Test Variable    ${BTS4_testline_object}
    ...    AND    Set Test Variable    ${BTS1_source_sw}
    ...    AND    Set Test Variable    ${BTS2_source_sw}
    ...    AND    Set Test Variable    ${BTS3_source_sw}
    ...    AND    Set Test Variable    ${BTS4_source_sw}
    ...    AND    Set Test Variable    ${BTS1_target_sw}
    ...    AND    Set Test Variable    ${BTS2_target_sw}
    ...    AND    Set Test Variable    ${BTS3_target_sw}
    ...    AND    Set Test Variable    ${BTS4_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    4773,1898,1815,6826,7114,4452,6825,6833
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}    4773,1898,1815,6826,7114,4452,6825,6833
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    10
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    Generic
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    True
    ...    AND    Set Test Variable    ${USE_DCAP}    False
    ...    AND    Set Test Variable    ${L3_CALL_METHOD}    None
    ...    AND    Set Test Variable    ${STOP_TEST_AFTER_FAIL}    False
    ...    AND    Set Test Variable    ${REPORT}    True
    ...    AND    Set Test Variable    ${QC_PROJECT}    None
    ...    AND    Set Test Variable    ${QC_DOMAIN}    None
    ...    AND    Set Test Variable    ${QC_ID}    None
    ...    AND    Set Test Variable    ${SW_BUILD}    None
    ...    AND    Set Test Variable    ${TOPOLOGY}    None
    ...    AND    Set Test Variable    ${TAGS}    CA_VRF_TSR2
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T03

    ...    AND    UUF_SITE_RESET_WITHOUT_HWF.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SITE_RESET_WITHOUT_HWF
    ...    AND    Set Library Search Order    UUF_SITE_RESET_WITHOUT_HWF
    TC__UUF_SITE_RESET_WITHOUT_HWF
    [Teardown]    Run Keywords    UUF_SITE_RESET_WITHOUT_HWF.TC Teardown
    ...    AND    Restore Resource Search Order

[1]RRM__RFS__Data_Transfer_Taf_Ue_2
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    300 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True

    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order

[1]SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__cell_block_unblock_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${BTS_LIST}    ALL
    ...    AND    Set Test Variable    ${RAT_LIST}    ALL
    ...    AND    Set Test Variable    ${LTE_IOT_SA_action}    False
    ...    AND    Set Test Variable    ${LTE_IOT_check}    False
    ...    AND    Set Test Variable    ${NR_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${NR_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${LTE_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${LTE_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${WCDMA_CELL_BLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${WCDMA_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${GSM_CELL_BLOCK_WRN_THR}    130
    ...    AND    Set Test Variable    ${GSM_CELL_UNBLOCK_WRN_THR}    10
    ...    AND    Set Test Variable    ${CELL_BLOCK_MAX_WAIT_TIME}    200
    ...    AND    Set Test Variable    ${CELL_UNBLOCK_MAX_WAIT_TIME}    200

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    TC__SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__Cell_Block_Unblock_from_WEBEM.TC Teardown
    ...    AND    Restore Resource Search Order

[1]RRM__RFS__Data_Transfer_Taf_Ue_3
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    300 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True

    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order

[1]NRL__STATE__NR_RM_LockUnlock_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_lockunlock_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    3
    ...    AND    Set Test Variable    ${RMOD_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RMOD_SHARING_INFO}    ALL
    ...    AND    Set Test Variable    ${RMOD_LOCK_MAX_WAIT_TIME}    300
    ...    AND    Set Test Variable    ${RMOD_UNLOCK_MAX_WAIT_TIME}    300
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_LockUnlock.TC Teardown
    ...    AND    Restore Resource Search Order

[1]RRM__RFS__Data_Transfer_Taf_Ue_4
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    300 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True

    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order

[1]NRL__STATE__NR_RM_Reset_from_WEBEM
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    10
    ...    AND    Set Test Variable    ${RM_CONFIGURED_INFO}    ALL
    ...    AND    Set Test Variable    ${RM_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RM_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RM_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${RM_RESET_WRN_THR}    180
    ...    AND    Set Test Variable    ${CNI_103974}    True

    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Teardown
    ...    AND    Restore Resource Search Order

[1]RRM__RFS__Data_Transfer_Taf_Ue_5
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/RRM__RFS__Data_Transfer_Taf_Ue.py
    ...    AND    Set Test Variable    ${TECHNO}    NR
    ...    AND    Set Test Variable    ${CELLS_LIST}    DEFAULT
    ...    AND    Set Test Variable    ${USE_ATTENUATOR}    YES
    ...    AND    Set Test Variable    ${CALL_DIRECTION}    downlink
    ...    AND    Set Test Variable    ${CALL_DURATION}    10
    ...    AND    Set Test Variable    ${downlink_MAX_TPUT}    300 Mbits/sec
    ...    AND    Set Test Variable    ${downlink_MIN_TPUT}    145 Kbits/sec
    ...    AND    Set Test Variable    ${uplink_MAX_TPUT}    50 Mbits/sec
    ...    AND    Set Test Variable    ${uplink_MIN_TPUT}    78 Kbits/sec
    ...    AND    Set Test Variable    ${PROTOCOL}    udp
    ...    AND    Set Test Variable    ${BANDWIDTH}    60 Mbits/sec
    ...    AND    Set Test Variable    ${UE_CAPABILITIES}    REAL_ANDROID_UE_1
    ...    AND    Set Test Variable    ${MBN_PROFILE}    None
    ...    AND    Set Test Variable    ${DETACH_UE}    True
    ...    AND    Set Test Variable    ${CHECK_ATTACH_ONLY}    True

    ...    AND    RRM__RFS__Data_Transfer_Taf_Ue.TC Setup
    ...    AND    Modify Resource Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    ...    AND    Set Library Search Order    RRM__RFS__Data_Transfer_Taf_Ue
    TC__RRM__RFS__Data_Transfer_Taf_Ue
    [Teardown]    Run Keywords    RRM__RFS__Data_Transfer_Taf_Ue.TC Teardown
    ...    AND    Restore Resource Search Order

*** Keywords ***
#UUF4ALL Test Helper KW
Set Test Failed
    Set Suite Variable  ${UPDATE_TEST_FAILED}  ${True}

#UUF4ALL Test Helper KW
Check Update Status
    Run Keyword If      ${UPDATE_TEST_FAILED}  Fail

#UUF4ALL Test Helper KW
Simple admin connection
    ${setup_status}=  run keyword and return status  coam.setup admin
    ...  bts_host=192.168.255.1
    ...  bts_port=443
    ...  admin_api_log_dir=/home/ute/admin_logs/
    ...  name=alias
    Log                       Admin Setup Status: ${setup_status}
    run keyword unless        ${setup_status}  Fail  Setup Admin Failed
    &{bts_info}               coam.get_bts_info  connection=alias  timeout=60
    Log                       ${bts_info}
    [Teardown]  run keyword
    ...       coam.teardown_admin  connection=alias

#UUF4ALL Test Helper KW
Set Initial And Candidate
    ${initial_sw}             Get Source SW
    ${candidate_sw}           Get Target SW

    Set to dictionary         ${node1}
    ...                       source_sw=${initial_sw}
    ...                       target_sw=${candidate_sw}

    Set to dictionary         ${node2}
    ...                       source_sw=${initial_sw}
    ...                       target_sw=${candidate_sw}
