*** Settings ***
Documentation    Robot Test Suite
Resource    ../../../test_resources/UUF_SW_UPGRADE.robot
Resource    ../../../test_resources/UUF_SITE_RESET_WITHOUT_HWF.robot
Resource    ../../../test_resources/UUF_SW_UPGRADE_ROLLBACK.robot
Resource    ../../../test_resources/RRM__RFS__Simultaneous_Data_Transfer_Multiple_UEs_on_Multiple_SBTS_Taf_Ue.robot
Resource    ../../../test_resources/SBTS_SBTS_SBTS_SBTS__STATE__RM_Reset_from_Webem.robot



*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables
${USER_RTWP_CHECK}   ${False}
${CNI_127210_ENABLED}   ${True}

# LTE alarm that need to be ignored caused by CB009480 TMO feature activation
&{ADD_LTE_IGNORED_ALARM_CB009480}    alarmId=7115    faultId=4779



*** Test Cases ***










[1]UUF_SITE_RESET_WITHOUT_HWF
    [Timeout]    244400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.gnbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS3_testline_object}
    ...    AND    Set Test Variable    ${BTS4_testline_object}
    ...    AND    Set Test Variable    ${BTS1_source_sw}    SBTS25R1_ENB_0000_000509_000009
    ...    AND    Set Test Variable    ${BTS2_source_sw}    SBTS25R1_ENB_0000_000509_000009
    ...    AND    Set Test Variable    ${BTS3_source_sw}
    ...    AND    Set Test Variable    ${BTS4_source_sw}
    ...    AND    Set Test Variable    ${BTS1_target_sw}    SBTS25R1_ENB_0000_000509_000009
    ...    AND    Set Test Variable    ${BTS2_target_sw}    SBTS25R1_ENB_0000_000509_000009
    ...    AND    Set Test Variable    ${BTS3_target_sw}
    ...    AND    Set Test Variable    ${BTS4_target_sw}
    ...    AND    Set Test Variable    ${BTS1_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS2_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_temporary_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    4655,4654,61524,61652,61649,1815,1898,4779
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}    4655,4654,61524,61652,61649,1815,1898,4779
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    30
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    TMO US
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
