*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Wojciech Korona
...                 Contact: Wojciech.Korona@nokia.com
...                 Responsible tester:  Wojciech.Korona@nokia.com

Library             Collections
Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Library             taf/rfrl/csv4all/resources/utilities/utilities.py
Resource            taf/rfrl/uuf4all/uuf4all_test_cases.robot

*** Variables ***
${UPDATE_TEST_ITERATION}    10
${ACTIVATION_RESET_TEST_ITERATION}    20
${RU_RESET_TEST_ITERATION}    10
${BBMOD_RESET_TEST_ITERATION}    10
${RP_CA}    VRF_SiSo
${RP_LOCATION}    VRF_WRO1
${RP_ORGANIZATION}    VRF_WRO1_T06
${QC_DOMAIN}=    MN_RAN
${QC_PROJECT}=    RAN_VRF
${EMAIL_RECIPIENTS}    Wojciech.Korona@nokia.com
@{CUSTOMERS}    Korean Telecom
${REPORT}    ${True}
${INITIAL_SW}    ${EMPTY}
${TARGET_SW}    ${EMPTY}
@{CUSTOM_ALARMS}            61524  61649  4654  4655  7300  6328  2403

&{NODE1}                    testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
...                         testline_scout_name=10_16_UTESRANSISO088

@{NODES}                    ${NODE1}

*** Test Cases ***
[1][1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]   24h
    Set Initial And Candidate
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE1}  ${UPDATE_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     restore_to_target_sw=${True}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${164998}

[1][1.0] E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL ACTIVATION RESET TEST    ${NODES}  ${NODES}  ${ACTIVATION_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${184428}

[1][1.0] E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL RU RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${RU_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${274705}

[1][1.0] E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL SITE RESET WITH OAM KPI         ${NODES}  ${NODES}
    ...    customers_list=${CUSTOMERS}
    ...    iterations_per_node=10
    ...    report=${REPORT}
    ...    qc_id=${274706}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}

[1][1.0] E2E_TL_Power_Site_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL POWER SITE RESET WITH OAM KPI      ${NODES}  ${NODES}
    ...    customers_list=${CUSTOMERS}
    ...    iterations_per_node=10
    ...    report=${REPORT}
    ...    qc_id=${274707}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}

[1][1.0] E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL CAPACITY MODULE RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${BBMOD_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...    qc_id=${274708}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}

*** Keywords ***
Set Initial And Candidate
    ${initial_sw}=    run keyword if  '${INITIAL_SW}'=='${EMPTY}'  Get Source SW
    ...   ELSE  set variable  ${INITIAL_SW}
    ${candidate_sw}=    run keyword if  '${TARGET_SW}'=='${EMPTY}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    Set to dictionary    ${NODE1}    source_sw=${initial_sw}    target_sw=${candidate_sw}
