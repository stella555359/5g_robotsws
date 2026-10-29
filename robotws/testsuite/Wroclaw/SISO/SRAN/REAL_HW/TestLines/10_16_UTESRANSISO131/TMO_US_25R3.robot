*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Mateusz Podgorski
...                 Contact: mateusz.podgorski@nokia.com
...                 Responsible tester:  mateusz.podgorski@nokia.com

Library             Collections
Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Library             taf/rfrl/csv4all/resources/utilities/utilities.py
Resource            taf/rfrl/uuf4all/uuf4all_test_cases.robot

*** Variables ***
${UPDATE_TEST_ITERATION}    10
${ACTIVATION_RESET_TEST_ITERATION}    20
${RU_RESET_TEST_ITERATION}    10
${BBMOD_RESET_TEST_ITERATION}    1
${LTECELL_LOCK_TEST_ITERATION}    1
${NRCELL_LOCK_TEST_ITERATION}    1
${LTECELL_BLOCK_TEST_ITERATION}    1
${NRCELL_BLOCK_TEST_ITERATION}    1
${DELTA_TEST_ITERATION}    1
${RP_CA}    VRF_SiSo
${RP_LOCATION}    VRF_WRO3
${RP_ORGANIZATION}    VRF_WRO3_T01
${QC_DOMAIN}=    MN_RAN
${QC_PROJECT}=    RAN_VRF
${EMAIL_RECIPIENTS}    mateusz.podgorski@nokia.com
@{CUSTOMERS}    TMO US
${REPORT}    ${True}
${INITIAL_SW}    ${EMPTY}
${TARGET_SW}    ${EMPTY}
${SITE_RESET_DELTA}=        testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestLines/10_16_UTESRANSISO131/DELTA/deltaSITE.json
${LTE_RESET_DELTA}=         testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestLines/10_16_UTESRANSISO131/DELTA/deltaLTE.json
${NR_RESET_DELTA}=          testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestLines/10_16_UTESRANSISO131/DELTA/deltaNR.json
${ONLINE_RESET_DELTA}=      testsuite/Wroclaw/SISO/SRAN/REAL_HW/TestLines/10_16_UTESRANSISO131/DELTA/deltaONLINE.json
@{CUSTOM_ALARMS}=           {4801,16,4247,4740}

&{NODE1}                    testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
...                         testline_scout_name=10_16_UTESRANSISO131_1

&{NODE2}
...                         testline_object=${tl.gnbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
...                         temporary_allowed_alarms=${EMPTY}
...                         testline_scout_name=10_16_UTESRANSISO131_3
@{NODES}                        ${NODE1}      ${NODE2}

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
    ...     qc_id=${216558}
[1][1.0] E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL ACTIVATION RESET TEST    ${NODES}  ${NODES}  ${ACTIVATION_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${216555}
[1][1.0] E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL RU RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${RU_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${216554}

*** Keywords ***
Set Initial And Candidate
    ${initial_sw}=    run keyword if  '${INITIAL_SW}'=='${EMPTY}'  Get Source SW
    ...   ELSE  set variable  ${INITIAL_SW}
    ${candidate_sw}=    run keyword if  '${TARGET_SW}'=='${EMPTY}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    Set to dictionary    ${NODE1}    source_sw=${initial_sw}    target_sw=${candidate_sw}
