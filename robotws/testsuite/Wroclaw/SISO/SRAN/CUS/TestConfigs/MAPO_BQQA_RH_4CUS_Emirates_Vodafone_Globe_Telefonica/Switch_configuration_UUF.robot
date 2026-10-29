*** Settings ***
Documentation    responsible tester: katarzyna.zacharuk@nokia.com
...              Emirates 6c6816ff82cdade1 ABIA+ABIP (master)
...		 Vodafone 4a5a7069090f5399 ABIO (master)
...              Telefonica 76bfd733592e0c68 ABIQ (slave)
...              Globe 700e5347c721e950 ABIA (slave)

Library    Collections

Library     taf/rfrl/csv4all/CSV4AllTestCases.py
Library     taf/rfrl/csv4all/resources/utilities/utilities.py
Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ../../resources/test_cases_loop.robot
Resource    ./variables.robot

Force Tags      CA_VRF_SiSo

Suite Setup       CUS Setup Test Set   ${SCFC_REFERENCE_FILE_PATH}
Suite Teardown    CUS Teardown Test Set

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=        	${CURDIR}/config/SCFC.xml
${BIG_CONFIG_PATH}=			CUS/MAPO_BQQA_RH_4CUS_Emirates_Vodafone_Globe_Telefonica/SCFC_COMBO_WO_Slim.xml
${CUSINI_FILE_PATH}=                	${CURDIR}/config/cus_COMBO.ini
${EPCSIM_FILE_PATH}=                	${CURDIR}/config/epc.lua
${CA_SUPPORTED_BANDS_1}= 		1:a:a+3:a:a+3::a|3:a:a+1:a:a+3::a|3:a:a+3:a:a+1::a|1:a:a+3:a:a+41::a|1:a:a+3:a:a+41::c|
${CA_SUPPORTED_BANDS_2}= 		3:a:a+1:a:a+41::a|3:a:a+1:a:a+41::c|3:a:a+1:a:a|1:a:a+3:a:a|3:a:a+3:a:a|1:a:a+41:a:a|
${CA_SUPPORTED_BANDS_3}= 		3:a:a+41:a:a|3:a:a+41::c|41:a:a+41:a:a|40:a:a+40:a:a|3:a:a+20:a:a
${CA_SUPPORTED_BANDS}= 			${CA_SUPPORTED_BANDS_1}${CA_SUPPORTED_BANDS_2}${CA_SUPPORTED_BANDS_3}
${SUPPORTED_BANDS}=			1:false,3:false,8:false,20:false,40:false,41:false
${SKIP_TRUCK_ROLL}=			True

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
&{NODE1}              		node_vm=${tl.test_pcs[0].default_ssh_connection_details.addr}
...                             secondary_vm=${tl.test_pcs[1].default_ssh_connection_details.addr}
...                             source_sw=${INITIAL_SW}
...                             target_sw=${TARGET_SW}
...                             custom_allowed_alarms=${CUSTOM_ALARMS}
@{NODES}                        ${NODE1}


*** Test Cases ***
[COMBO_HYBRID][1.0] E2E_TL_SW_upgrade_rollback_with_OAM_KPI
    [Setup]  CUS Setup UUF
    [Timeout]   24h
    Set Initial And Candidate
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODE1}  ${UPDATE_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${223792}
    [Teardown]  CUS Teardown UUF

[EMI_HYBRID][1.0] E2E_TL_Activation_Reset_with_OAM_KPI
    [Setup]  CUS Setup UUF
    [Timeout]   24h
    E2E TL ACTIVATION RESET TEST    ${NODES}  ${NODES}  ${ACTIVATION_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${223793}
    [Teardown]  CUS Teardown UUF

*** Keywords ***
Set Initial And Candidate
    ${initial_sw}=    run keyword if  '${INITIAL_SW}'=='${EMPTY}'  Get Source SW
    ...   ELSE  set variable  ${INITIAL_SW}
    ${candidate_sw}=    run keyword if  '${TARGET_SW}'=='${EMPTY}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    Set to dictionary    ${NODE1}    source_sw=${initial_sw}    target_sw=${candidate_sw}

