*** Settings ***
Documentation
...   author: Boguslaw Trojnar
...   contact: boguslaw.trojnar@nokia.com
...   Test suite for basic UUF OAM Tests in loop:

Library    Collections
Library    taf/rfrl/csv4all/CSV4AllTestCases.py
Library    taf/rfrl/csv4all/resources/utilities/utilities.py
Resource   taf/rfrl/uuf4all/uuf4all_keywords.robot

*** Variables ***

${RP_CA}                        VRF_SiSo
${RP_LOCATION}                  VRF_WRO3
${RP_ORGANIZATION}              VRF_WRO3_T07
${QC_DOMAIN}=                   MN_RAN
${QC_PROJECT}=                  RAN_VRF
${EMAIL_RECIPIENTS}=            boguslaw.trojnar@nokia.com
@{CUSTOMERS}=                   RJio
${REPORT}                       False

${INITIAL_SW}                   ${EMPTY}
${TARGET_SW}                    ${EMPTY}

@{CUSTOM_ALARMS}=               @{7300,6327,7319,7107,61675,6327,4720}
@{CRITICAL_FAULTS}=             @{EMPTY}

${UPDATE_TEST_ITERATION}        1
${SITE_RESET_TEST_ITERATION}    1
${ACTIVATION_RESET_TEST_ITERATION}    1

${TESTLINE_NAME}=               1017

&{NODE1}                        #node_alias=ASIM
...                             testline_object=${tl.enbs[0]}
...                             source_sw=${INITIAL_SW}
...                             target_sw=${TARGET_SW}
...                             custom_allowed_alarms=${CUSTOM_ALARMS}
...                             temporary_allowed_alarms=${EMPTY}
...                             testline_scout_name=10_16_UTESRANSISO137_1
${BTS_info}                     taf_admin.Get Bts Info          timeout=30

#&{NODE2}                        node_alias=ASOE_2_secondary
#...                             testline_object=${tl.gnbs[0]}
#...                             source_sw=${INITIAL_SW}
#...                             target_sw=${TARGET_SW}
#...                             custom_allowed_alarms=${CUSTOM_ALARMS}
#...                             temporary_allowed_alarms=${EMPTY}
#...                             testline_scout_name=10_16_MRBTS1134

@{NODES}                        ${NODE1}

*** Test Cases ***
[1][1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]   24h
    Set Initial And Candidate
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODES}  ${UPDATE_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     restore_to_target_sw=${True}
    ...     qc_id=${66021}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}

[1][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI    ${NODES}  ${NODES}  ${SITE_RESET_TEST_ITERATION}
    ...    customers_list=${CUSTOMERS}
    ...    report=${REPORT}
    ...    qc_id=${1094333333307}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}

[1][1.0] E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL ACTIVATION RESET TEST    ${NODES}  ${NODES}  ${ACTIVATION_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${55555}

[1][1.0] E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL SITE RESET WITH OAM KPI         ${NODES}  ${NODES}
    ...    customers_list=${CUSTOMERS}
    ...    iterations_per_node=1
    ...    report=${REPORT}
    ...    qc_id=${178125}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}

[1][1.0] E2E_TL_Power_Site_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL POWER SITE RESET WITH OAM KPI      ${NODES}  ${NODES}
    ...    customers_list=${CUSTOMERS}
    ...    iterations_per_node=1
    ...    report=${REPORT}
    ...    qc_id=${178155444423}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}

[1][1.0] E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]   24h
    E2E TL CELL BLOCK UNBLOCK NR WITH OAM KPI           ${NODES}  ${NODES}
    ...    customers_list=${CUSTOMERS}
    ...    iterations_per_node=1     #1 iteration = block/unblock only one cell, 12 rep= 4x bl/unbl each cells
    ...    report=${REPORT}
    ...    qc_id=${172508}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}

[1][1.0] E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Timeout]   24h
    E2E TL CELL BLOCK UNBLOCK LTE WITH OAM KPI          ${NODES}  ${NODES}
    ...    customers_list=${CUSTOMERS}
    ...    iterations_per_node=1      #1 iteration = block/unblock only one cell, 45 rep= 3x bl/unbl each cells
    ...    report=${REPORT}
    ...    qc_id=${17662507}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}

[1][1.0] E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL RU RESET WITH OAM KPI          ${NODES}  ${NODES}
    ...    customers_list=${CUSTOMERS}
    ...    iterations_per_node=1
    ...    report=${REPORT}
    ...    qc_id=${17254446}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}

*** Keywords ***
Set Initial And Candidate
    ${initial_sw}=    run keyword if  '${INITIAL_SW}'=='${EMPTY}'  Get Source SW
    ...   ELSE  set variable  ${INITIAL_SW}
    ${candidate_sw}=    run keyword if  '${TARGET_SW}'=='${EMPTY}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    Set to dictionary    ${NODE1}    source_sw=${initial_sw}    target_sw=${candidate_sw}
    Set to dictionary    ${NODE2}    source_sw=${initial_sw}    target_sw=${candidate_sw}
