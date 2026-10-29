*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Krzysztof Brykman
...                 Contact: krzysztof.brykman@nokia.com

Library             Collections
Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Resource            taf/rfrl/uuf4all/uuf4all_keywords.robot

*** Variables ***
${RP_CA}                    VRF_SiSo
${RP_LOCATION}              VRF_WRO3
${RP_ORGANIZATION}          VRF_WRO3_T01
${QC_DOMAIN}=               MN_RAN
${QC_PROJECT}=              RAN_VRF
${EMAIL_RECIPIENTS}         krzysztof.brykman@nokia.com
@{CUSTOMERS}                TMO US

${UPDATE_TEST_ITERATION}        10
${ACTIVATION_RESET_TEST_ITERATION}    20
${REPORT}                   ${True}

${INITIAL_SW}               ${EMPTY}
${TARGET_SW}                ${EMPTY}

@{CUSTOM_ALARMS}            4589  181  4367  7525  7532  7535   # Allowed alarms can be passed as e.g 1234  2345

&{NODE1}                    node_vm=10.42.184.7
...                         secondary_vm=10.42.184.8
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
...                         testline_scout_name=10_16_UTESRANSISO134_1

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
    ...     qc_id=${177973}

[1][1.0] E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL ACTIVATION RESET TEST    ${NODES}  ${NODES}  ${ACTIVATION_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${184217}

*** Keywords ***
Set Initial And Candidate
    ${initial_sw}=    run keyword if  '${INITIAL_SW}'=='${EMPTY}'  Get Source SW
    ...   ELSE  set variable  ${INITIAL_SW}
    ${candidate_sw}=    run keyword if  '${TARGET_SW}'=='${EMPTY}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    Set to dictionary    ${NODE1}    source_sw=${initial_sw}    target_sw=${candidate_sw}
