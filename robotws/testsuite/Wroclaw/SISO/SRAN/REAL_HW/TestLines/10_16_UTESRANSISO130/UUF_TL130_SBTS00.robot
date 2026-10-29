*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: dominik jaseriew
...                 Contact: dominik.jaseriew@nokia.com
...                 Description of particular variables You can find on Confluence:
...  https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1926949248#UUFCSV4ALLHowtouseinVRF_WRO4-Testsuite(onenode)forTLwithinit.py

Library             Collections
Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Library             taf/rfrl/csv4all/resources/utilities/utilities.py

*** Variables ***
${UPDATE_TEST_ITERATION}        10
${ACTIVATION_RESET_TEST_ITERATION}    20

${RP_CA}                    VRF_SiSo
${RP_LOCATION}              VRF_WRO1
${RP_ORGANIZATION}          VRF_WRO1_T06
${QC_DOMAIN}=               MN_RAN
${QC_PROJECT}=              RAN_VRF
${EMAIL_RECIPIENTS}         dominik.jaseriew@nokia.com
@{CUSTOMERS}                Generic
${REPORT}                   ${True}

${INITIAL_SW}               ${EMPTY}
${TARGET_SW}                ${EMPTY}
@{CUSTOM_ALARMS}            61675
...                         2403    #(issue with uuftests...
...                         4602    # 5Cell config. mismatch

&{NODE1}                    testline_object=${tl.enbs[0]}
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         custom_allowed_alarms=${CUSTOM_ALARMS}
...                         testline_scout_name=10_16_UTESRANSISO130

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
    ...     qc_id=${120803}

[1][1.0] E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL ACTIVATION RESET TEST    ${NODES}  ${NODES}  ${ACTIVATION_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${185496}

*** Keywords ***
Set Initial And Candidate
    ${initial_sw}=    run keyword if  '${INITIAL_SW}'=='${EMPTY}'  Get Source SW
    ...   ELSE  set variable  ${INITIAL_SW}
    ${candidate_sw}=    run keyword if  '${TARGET_SW}'=='${EMPTY}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    Set to dictionary    ${NODE1}    source_sw=${initial_sw}    target_sw=${candidate_sw}
