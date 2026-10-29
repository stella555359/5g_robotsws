*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.robot
Resource    ../../../test_resources/UUF_SITE_RESET_WITHOUT_HWF.robot


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${CNI_127210_ENABLED}  ${True}
&{ADD_NR_IGNORED_ALARM1}    alarmId=7107    faultId=7308
&{ADD_NR_IGNORED_ALARM2}    alarmId=7107    faultId=7319


*** Test Cases ***
[1]UUF_SITE_RESET_WITHOUT_HWF
    [Timeout]    43200
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.gnbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.gnbs[1]}
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
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    4773,7107,4385,1815,7300,7319,4452,1898,7308
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}    4773,7107,4385,1815,7300,7319,4452,1898,7308
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    15
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
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T05

    ...    AND    UUF_SITE_RESET_WITHOUT_HWF.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SITE_RESET_WITHOUT_HWF
    ...    AND    Set Library Search Order    UUF_SITE_RESET_WITHOUT_HWF
    TC__UUF_SITE_RESET_WITHOUT_HWF
    [Teardown]    Run Keywords    UUF_SITE_RESET_WITHOUT_HWF.TC Teardown
    ...    AND    Restore Resource Search Order

[1]NR_NR__STATE__NR_RM_Reset_from_WEBEM
    [Timeout]    43200
    [Setup]    Run Keywords
    ...    Import Variables    ${ALM_PTH}/sbts_sbts_sbts_sbts__state__rm_reset_from_webem_alarms_definitions.py
    ...    AND    Set Test Variable    ${REPEAT_COUNTER}    15
    ...    AND    Set Test Variable    ${RM_CONFIGURED_INFO}    ALL
    ...    AND    Set Test Variable    ${RM_SERIAL_NUMBER_LIST}    ALL
    ...    AND    Set Test Variable    ${RM_RESET_MAX_WAIT_TIME}    900
    ...    AND    Set Test Variable    ${RM_RESET_TIME_INTERVAL}    480
    ...    AND    Set Test Variable    ${RM_RESET_WRN_THR}    300
    ...    AND    Set Test Variable    ${CNI_103974}    True
    ...    AND    Set Test Variable    ${GRACEFUL_CELL_SHUTDOWN}    True
    ...    AND    Set Test Variable    ${LTE_IOT_check}    True
    ...    AND    Append To List  ${MASTER_IGNORED_ALARMS_CNI_127210}  ${ADD_NR_IGNORED_ALARM1}  ${ADD_NR_IGNORED_ALARM2}
    ...    AND    Append To List  ${SLAVE_IGNORED_ALARMS_CNI_127210}  ${ADD_NR_IGNORED_ALARM1}  ${ADD_NR_IGNORED_ALARM2}
    ...    AND    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Setup
    ...    AND    Modify Resource Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    ...    AND    Set Library Search Order    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    TC__SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem
    [Teardown]    Run Keywords    SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.TC Teardown
    ...    AND    Restore Resource Search Order
