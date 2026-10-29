*** Settings ***
Documentation
...   author: Bartosz Busz
...   contact: bartosz.busz@nokia.com
...   Test suite for basic UUF OAM Tests in loop:

Library    Collections
Library    taf/rfrl/csv4all/CSV4AllTestCases.py
Library   taf/rfrl/csv4all/resources/utilities/utilities.py

*** Variables ***

${RP_CA}                        VRF_SiSo
${RP_LOCATION}                  VRF_WRO4
${RP_ORGANIZATION}              VRF_WRO4_T03
${QC_DOMAIN}=                   MN_RAN
${QC_PROJECT}=                  RAN_VRF
${EMAIL_RECIPIENTS}=            bartosz.busz@nokia.com
@{CUSTOMERS}=                   Generic
${REPORT}                       True

${INITIAL_SW}                   ${EMPTY}
${TARGET_SW}                    ${EMPTY}

@{CUSTOM_ALARMS}                4110    4652
@{CRITICAL_FAULTS}=             @{EMPTY}

${UPDATE_TEST_ITERATION}        10
${SITE_RESET_TEST_ITERATION}    10

${TESTLINE_NAME}=               10_16_UTESRANSISO001

&{NODE1}                        testline_object=${tl.enbs[0]}
...                             source_sw=${INITIAL_SW}
...                             target_sw=${TARGET_SW}
...                             custom_allowed_alarms=${CUSTOM_ALARMS}
...                             temporary_allowed_alarms=${EMPTY}
...                             testline_scout_name=10_16_UTESRANSISO001_1

@{NODES}                        ${NODE1}

*** Test Cases ***
[1][1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Timeout]   24h
    Set Initial And Candidate
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE1}  ${UPDATE_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     restore_to_target_sw=${True}
    ...     qc_id=${110004}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}

[1][1.0] E2E_TL_Site_reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    E2E TL SITE RESET WITHOUT HWF WITH OAM KPI    ${NODES}  ${NODE1}  ${SITE_RESET_TEST_ITERATION}
    ...    customers_list=${CUSTOMERS}
    ...    report=${REPORT}
    ...    qc_id=${110003}
    ...    qc_domain=${QC_DOMAIN}
    ...    qc_project=${QC_PROJECT}

*** Keywords ***
Set Initial And Candidate
    ${initial_sw}=    run keyword if  '${INITIAL_SW}'=='${EMPTY}'  Get Source SW
    ...   ELSE  set variable  ${INITIAL_SW}
    ${candidate_sw}=    run keyword if  '${TARGET_SW}'=='${EMPTY}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    Set to dictionary    ${NODE1}    source_sw=${initial_sw}    target_sw=${candidate_sw}
