*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/UUF_SW_UPGRADE.robot

Force Tags    QCD_MN_RAN    QCP_RAN_VRF    CLOUD_10_18_UTESRANRFSMTNRL208
...    SBTS00   STATE_SKIP_AGENT    CRT


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables

${RP_CA}   VRF_SiSo
${RP_LOCATION}    VRF_TSR2
${RP_ORGANIZATION}    VRF_TSR2_T05

${EMAIL_RECIPIENTS}         None

${INITIAL_SW}
${TARGET_SW}

${ITERATIONS}               1

@{CUSTOM_ALLOWED_ALARMS}    4773  7107  4385  1815  7300  7319  4452  1898  4700  6134  6132  6129  7513  7511  7509  4694  4530  4602

&{node1}                    testline_object=${tl.enbs[0]}
...                         node_alias=BTS1
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}

@{NODES}                    ${node1}
@{UPGRADE_NODES}            ${node1}



*** Test Cases ***
[1]UUF_SW_UPGRADE
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}
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
    ...    AND    Set Test Variable    ${BTS1_custom_allowed_alarms}    4773,7107,4385,1815,7300,7319,4452,1898
    ...    AND    Set Test Variable    ${BTS2_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS3_custom_allowed_alarms}
    ...    AND    Set Test Variable    ${BTS4_custom_allowed_alarms}
    ...    AND    Set Test Variable    &{BTS1_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS2_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS3_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    &{BTS4_node_parameters}    &{EMPTY}
    ...    AND    Set Test Variable    ${SYNCHRONIZE_SW_ON_PASSIVE}    True
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    1
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    Generic
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    True
    ...    AND    Set Test Variable    ${KPI_NAMES}    kpi2a,kpi2b,kpi2c,kpi2d
    ...    AND    Set Test Variable    ${KPI_THRESHOLDS}    897,897,897,897
    ...    AND    Set Test Variable    ${USE_DCAP}    False
    ...    AND    Set Test Variable    ${L3_CALL_METHOD}    None
    ...    AND    Set Test Variable    ${STOP_TEST_AFTER_FAIL}    False
    ...    AND    Set Test Variable    ${REPORT}    True
    ...    AND    Set Test Variable    ${QC_PROJECT}    ${None}
    ...    AND    Set Test Variable    ${QC_DOMAIN}    ${None}
    ...    AND    Set Test Variable    ${QC_ID}    ${None}
    ...    AND    Set Test Variable    ${SW_BUILD}    ${None}
    ...    AND    Set Test Variable    ${TOPOLOGY}    ${None}
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T05
    ...    AND    Set Test Variable    &{TEST_PARAMETERS}    &{EMPTY}

    ...    AND    UUF_SW_UPGRADE.TC Setup
    ...    AND    Modify Resource Search Order    UUF_SW_UPGRADE
    ...    AND    Set Library Search Order    UUF_SW_UPGRADE
    TC__UUF_SW_UPGRADE
    [Teardown]    Run Keywords    UUF_SW_UPGRADE.TC Teardown
    ...    AND    Restore Resource Search Order

E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h

    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=6
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report=${False}
    ...  calculate_kpi=${True}
    ...  use_dcap=${False}
    ...  stop_test_after_fail=${False}
    ...  qc_domain=None
    ...  qc_id=None
    ...  qc_project=None
    ...  topology=${None}
    ...  report_comment=${None}


E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h

    e2e_tl_ru_reset_with_oam_kpi
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=29
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report=${False}
    ...  calculate_kpi=${True}
    ...  use_dcap=${False}
    ...  stop_test_after_fail=${False}
    ...  qc_domain=None
    ...  qc_id=None
    ...  qc_project=None
    ...  topology=${None}
    ...  report_comment=${None}
    ...  sw_build=${None}
    ...  l3_call_method=${None}


E2E_TL_RU_Lock_Unlock
    [Timeout]   24h
    E2E TL RU LOCK UNLOCK
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=29
    ...  customers_list=${CUSTOMERS_LIST}
    ...  report=${False}
    ...  calculate_kpi=${True}
    ...  use_dcap=${False}
    ...  stop_test_after_fail=${False}
    ...  qc_domain=None
    ...  qc_id=None
    ...  qc_project=None
    ...  topology=${None}
    ...  report_comment=${None}
