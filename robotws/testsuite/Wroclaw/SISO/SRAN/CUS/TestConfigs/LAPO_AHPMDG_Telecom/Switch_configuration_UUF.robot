*** Settings ***
Documentation    responsible tester: katarzyna.zacharuk@nokia.com
...	         Telekom Deutche: LAPO: ffb6c134f94b3c9f

Library    Collections
Library     taf/rfrl/csv4all/CSV4AllTestCases.py
Library     taf/rfrl/csv4all/resources/utilities/utilities.py
Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ../../resources/test_cases_loop.robot
Resource    ./variables.robot

Force Tags      CA_VRF_SiSo

Suite Setup       CUS Setup Test Set    ${SCFC_REFERENCE_FILE_PATH}
Suite Teardown    CUS Teardown Test Set

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=            ${CURDIR}/config/SCFC_SBTS00_CUS.xml
${CUSINI_FILE_PATH}=                    ${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                    ${CURDIR}/config/epc.lua
${CONFIGURATION_NAME}=                  IN_DOC
${CA_SUPPORTED_BANDS}

#UUF_varriables
${UPDATE_TEST_ITERATION}        10
${ACTIVATION_RESET_TEST_ITERATION}    10

${RP_CA}                        VRF_SiSo
${RP_LOCATION}                  VRF_WRO3
${RP_ORGANIZATION}              VRF_WRO3_T07
${QC_DOMAIN}=                   MN_RAN
${QC_PROJECT}=                  RAN_VRF
${EMAIL_RECIPIENTS}             katarzyna.zacharuk@nokia.com
@{CUSTOMERS}                    Generic

${INITIAL_SW}=                  ${EMPTY}
${TARGET_SW}=                   ${EMPTY}
${REPORT}=                      ${True}
@{CUSTOM_ALARMS}                @{EMPTY}      # Allowed alarms can be passed as e.g 1234  2345
&{NODE1}                        node_vm=${tl.test_pcs[0].default_ssh_connection_details.addr}
...                             source_sw=${INITIAL_SW}
...                             target_sw=${TARGET_SW}
...                             custom_allowed_alarms=${CUSTOM_ALARMS}
...                             check_mplane=${False}
@{NODES}                        ${NODE1}

*** Test Cases ***
[Telekom_1][1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Setup]  CUS Setup UUF
    [Timeout]   24h
    Set Initial And Candidate
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE1}  ${UPDATE_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${223795}
    [Teardown]  CUS Teardown UUF

[Telekom_1][1.0] E2E_TL_Activation_Reset_with_OAM_KPI
    [Setup]  CUS Setup UUF
    [Timeout]   24h
    E2E TL ACTIVATION RESET TEST    ${NODES}  ${NODES}  ${ACTIVATION_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${223796}
    [Teardown]  CUS Teardown UUF

*** Keywords ***
Set Initial And Candidate
    ${initial_sw}=    run keyword if  '${INITIAL_SW}'=='${EMPTY}'  Get Source SW
    ...   ELSE  set variable  ${INITIAL_SW}
    ${candidate_sw}=    run keyword if  '${TARGET_SW}'=='${EMPTY}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    Set to dictionary    ${NODE1}    source_sw=${initial_sw}    target_sw=${candidate_sw}
