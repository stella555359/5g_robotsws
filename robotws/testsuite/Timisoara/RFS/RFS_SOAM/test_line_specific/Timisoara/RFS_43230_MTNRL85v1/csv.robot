*** Settings ***
Documentation  Test Suite
Resource    ../../../test_resources/UUF_SITE_RESET_WITHOUT_HWF.robot
Resource    ../../../test_resources/UUF_SW_UPGRADE.robot


Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Resource   taf/rfrl/uuf4all/uuf4all_keywords.robot

#UUF4ALL scope
Suite Setup                     Set Initial And Candidate


*** Variables ***
${SCF_ID}    01
${ALM_PTH}    ${CURDIR}/../../../test_resources/tc_variables

${RP_CA}   VRF_SiSo
${RP_LOCATION}    VRF_TSR2
${RP_ORGANIZATION}    VRF_TSR2_T05

${EMAIL_RECIPIENTS}         None

${UPDATE_TEST_FAILED}          ${False}

${INITIAL_SW}           ${None}
${TARGET_SW}          ${None}

${ITERATIONS}               4

@{CUSTOM_ALLOWED_ALARMS}    4773  7107  4385  1815  7300  7319  4452  1898  4700  6134  6132  6129  7513  7511  7509  4694  4530

@{CUSTOMERS}                      Generic
${ITERATION}                      4
${STOP_TEST_AFTER_FAIL}           ${False}
${DOWNLOAD_PATH}                  ${None}

${USE_TESTPACKAGE}                ${False}

${TEST_ON_NODE}                   ${None}      # Specify one of the nodes node1/node2 to test only the selected node
                                             # If ${TEST_ON_NODE} is None, the test will be executed on all nodes
                                             # in the order set in the variable ${TEST_NODES}

${REPORT}                         ${False}
${QC_REPORT}                      ${False}
${REPORT_COMMENT}                 ${None}

${QC_DOMAIN}                      MN_RAN
${TEST_QC_ID}                     ${None}
${QC_PROJECT}                     ${None}
${TESTER_NAME}                    ${None}

${HW_TO_ONAIR_TIME}               ${None}

&{node1}                    testline_object=${tl.gnbs[0]}
...                         node_alias=BTS1
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}


&{node2}                    testline_object=${tl.enbs[0]}
...                         node_alias=BTS2
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALLOWED_ALARMS}

@{NODES}                    ${node1}  ${node2}
@{NODES1}                   ${node1}
@{NODES2}                   ${node2}
@{UPGRADE_NODES}            ${node1}  ${node2}
@{TEST_NODES}               ${node1}  ${node2}


&{PDU_RMOD_1}    model=GUDE  host=10.255.5.29    port=1    version=8221-1

&{AVHQB}    1M243800023=${PDU_RMOD_1}


@{PDU_LIST}    ${AVHQB}


*** Test Cases ***
[1]UUF_SW_UPGRADE
    [Timeout]    14400
    [Setup]    Run Keywords
    ...    No Operation
    ...    AND    Set Test Variable    ${BTS1_testline_object}    ${tl.enbs[0]}
    ...    AND    Set Test Variable    ${BTS2_testline_object}
    ...    AND    Set Test Variable    ${BTS3_testline_object}
    ...    AND    Set Test Variable    ${BTS4_testline_object}
    ...    AND    Set Test Variable    ${BTS1_source_sw}    SBTS00_ENB_9999_250306_000011
    ...    AND    Set Test Variable    ${BTS2_source_sw}
    ...    AND    Set Test Variable    ${BTS3_source_sw}
    ...    AND    Set Test Variable    ${BTS4_source_sw}
    ...    AND    Set Test Variable    ${BTS1_target_sw}    SBTS00_ENB_9999_250307_000008
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
    ...    AND    Set Test Variable    ${SYNCHRONIZE_SW_ON_PASSIVE}    True
    ...    AND    Set Test Variable    ${TEST_NODES_DETAILS_LIST}    ALL
    ...    AND    Set Test Variable    ${ITERATIONS_PER_NODE}    1
    ...    AND    Set Test Variable    ${CUSTOMERS_LIST}    Generic
    ...    AND    Set Test Variable    ${CALCULATE_KPI}    True
    ...    AND    Set Test Variable    ${USE_DCAP}    False
    ...    AND    Set Test Variable    ${L3_CALL_METHOD}    None
    ...    AND    Set Test Variable    ${STOP_TEST_AFTER_FAIL}    False
    ...    AND    Set Test Variable    ${REPORT}    False
    ...    AND    Set Test Variable    ${QC_PROJECT}    None
    ...    AND    Set Test Variable    ${QC_DOMAIN}    None
    ...    AND    Set Test Variable    ${QC_ID}    None
    ...    AND    Set Test Variable    ${SW_BUILD}    None
    ...    AND    Set Test Variable    ${TOPOLOGY}    None
    ...    AND    Set Test Variable    ${RP_CA}    VRF_SiSo
    ...    AND    Set Test Variable    ${RP_LOCATION}    VRF_TSR2
    ...    AND    Set Test Variable    ${RP_ORGANIZATION}    VRF_TSR2_T05

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
    ...  iterations_per_node=2
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

    E2E TL RU RESET WITH OAM KPI
    ...  nodes_details=${NODES2}
    ...  test_nodes_details=${NODES2}
    ...  iterations_per_node=1
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


E2E_TL_RU_Lock_Unlock
    [Timeout]   24h
    E2E TL RU LOCK UNLOCK
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=2
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

E2E_TL_RU_Power_Reset
    [Timeout]   24h

    E2E TL RU POWER RESET
    ...  nodes_details=${NODES}
    ...  test_nodes_details=${NODES}
    ...  iterations_per_node=1
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
    ...  rmods_with_pdu_ports=${PDU_LIST}

Upgrade rollback test
    [Timeout]   100h
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...    ${NODES}
    ...    ${TEST_NODES}
    ...    ${ITERATION}
    ...    report=${REPORT}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    ...    restore_to_target_sw=${True}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}

Activation Site reset
    [Timeout]   100h
    e2e_tl_activation_reset_test
    ...    ${NODES}
    ...    ${TEST_NODES}
    ...    ${ITERATION}
    ...    report=${REPORT}
    ...    report_comment=${REPORT_COMMENT}
    ...    customers_list=${CUSTOMERS}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_id=${TEST_QC_ID}
    ...    qc_project=${QC_PROJECT}

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
