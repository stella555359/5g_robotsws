*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Mateusz Chryplewicz
...                 Contact: mateusz.chryplewicz@nokia.com
...                 Description of particular variables You can find on Confluence:
...  https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1926949248#UUFCSV4ALLHowtouseinVRF_WRO4-Testsuite(onenode)forTLwithoutinit.py

Library             Collections
Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Library             taf/rfrl/csv4all/resources/utilities/utilities.py
Resource           ../../../Resources/SiSo_L3_call.robot


*** Variables ***
${UPDATE_TEST_ITERATION}        25
${SITE_RESET_TEST_ITERATION}    15
${ACTIVATION_RESET_TEST_ITERATION}    20

${RP_CA}                    VRF_SiSo
${RP_LOCATION}              VRF_WRO4
${RP_ORGANIZATION}          VRF_WRO4_T01
${QC_DOMAIN}=               MN_RAN
${QC_PROJECT}=              RAN_VRF
${EMAIL_RECIPIENTS}         mateusz.chryplewicz@nokia.com
@{CUSTOMERS}                Indosat Indonesia
${LOGS_DIR}=                /home/ute/L3call
${CELLS_YAML_PATH}=         /home/ute/testline_configuration/10_16_UTESRANSISO808INDOSAT/ue_config.yaml
${REPORT}                   ${True}

${INITIAL_SW}               ${EMPTY}
${TARGET_SW}                ${EMPTY}
@{CUSTOM_ALARMS}            @{6327,7300,6322,4681,1838,4723,4003,2412}

&{NODE1}                    testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
...                         testline_scout_name=10_16_UTESRANSISO808INDOSAT

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
    ...     qc_id=${216131}

[1][1.0] E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL ACTIVATION RESET TEST    ${NODES}  ${NODES}  ${ACTIVATION_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${216127}

[1][1.0] E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL RU RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${SITE_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${216130}

[1][1.0] E2E_TL_Capacity_Module_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL CAPACITY MODULE RESET WITH OAM KPI    ${NODES}  ${NODE1}  ${SITE_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${216129}

*** Keywords ***
Set Initial And Candidate
    ${initial_sw}=    run keyword if  '${INITIAL_SW}'=='${EMPTY}'  Get Source SW
    ...   ELSE  set variable  ${INITIAL_SW}
    ${candidate_sw}=    run keyword if  '${TARGET_SW}'=='${EMPTY}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    Set to dictionary    ${NODE1}    source_sw=${initial_sw}    target_sw=${candidate_sw}
