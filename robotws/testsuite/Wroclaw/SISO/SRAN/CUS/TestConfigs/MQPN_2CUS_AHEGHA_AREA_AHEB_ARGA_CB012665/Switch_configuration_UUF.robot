*** Settings ***
Documentation    responsible tester: jakub.pachana@nokia.com
...              UUF
...              CB012665 DoD
...		 ABIQ - B2
...		 ABIP - A2 + B1
...		 ABIQ - B2
...              1.1.1_AREA_(3x20+3x10)L_I;1.2.1_AHEGHA_(2x20)_N_M_(1x10+1x20)L_M;
...              1.2.10_AHEB_(2x20+4x10)L_M;1.3.5_ARGA_(3x20+3x10)L_I
...              Added customer configuration Telecom Deutsch b5c0752e10f28577

Library    Collections
Library     taf/rfrl/csv4all/CSV4AllTestCases.py
Library     taf/rfrl/csv4all/resources/utilities/utilities.py
Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ../../resources/test_cases_loop.robot
Resource    ./variables.robot

Force Tags      CA_VRF_SiSo

Suite Setup       CUS Setup Test Set    ${SCFC_REFERENCE_FILE_PATH}
#Suite Setup       CUS Setup Test Set Without Reset Configuration   ${SCFC_REFERENCE_FILE_PATH}    log_steps=True
Suite Teardown    CUS Teardown Test Set

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=        	${CURDIR}/config/SCFC_BR_R3_CUS.xml
${CUSINI_FILE_PATH}=                	${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                	${CURDIR}/config/epc.lua
${CONFIGURATION_NAME}=                  IN_DOC
${CA_SUPPORTED_BANDS}=              	1:a:a+1:a:a|3:a:a+3:a:a|3:a:a+1:a:a|8:a:a+20:a:a|20:a:a+8:a:a|8:a:a+8:a:a
${SUPPORTED_BANDS}=                 	1:false,3:false,8:false,20:false
${SKIP_TRUCK_ROLL}=			True

#UUF_varriables
${UPDATE_TEST_ITERATION}        10
${ACTIVATION_RESET_TEST_ITERATION}    10

${RP_CA}                        VRF_SiSo
${RP_LOCATION}                  VRF_WRO3
${RP_ORGANIZATION}              VRF_WRO3_T06
${QC_DOMAIN}=                   MN_RAN
${QC_PROJECT}=                  RAN_VRF
${EMAIL_RECIPIENTS}             jakub.pachana@nokia.com
@{CUSTOMERS}                    Generic

${INITIAL_SW}=                  ${EMPTY}
${TARGET_SW}=                   ${EMPTY}
${REPORT}=                      ${True}
@{CUSTOM_ALARMS}                7319      # Allowed alarms can be passed as e.g 1234  2345
&{NODE1}                        node_vm=${tl.test_pcs[0].default_ssh_connection_details.addr}
...                             source_sw=${INITIAL_SW}
...                             target_sw=${TARGET_SW}
...                             custom_allowed_alarms=${CUSTOM_ALARMS}
...                             check_mplane=${False}
@{NODES}                        ${NODE1}

*** Test Cases ***
[CB012665][1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Setup]  CUS Setup UUF
    [Timeout]   24h
    Set Initial And Candidate
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE1}  ${UPDATE_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${69579}
    [Teardown]  CUS Teardown UUF

[CB012665][1.0] E2E_TL_Activation_Reset_with_OAM_KPI
    [Setup]  CUS Setup UUF
    [Timeout]   24h
    E2E TL ACTIVATION RESET TEST    ${NODES}  ${NODES}  ${ACTIVATION_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${182921}
    [Teardown]  CUS Teardown UUF

*** Keywords ***
Set Initial And Candidate
    ${initial_sw}=    run keyword if  '${INITIAL_SW}'=='${EMPTY}'  Get Source SW
    ...   ELSE  set variable  ${INITIAL_SW}
    ${candidate_sw}=    run keyword if  '${TARGET_SW}'=='${EMPTY}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    Set to dictionary    ${NODE1}    source_sw=${initial_sw}    target_sw=${candidate_sw}
