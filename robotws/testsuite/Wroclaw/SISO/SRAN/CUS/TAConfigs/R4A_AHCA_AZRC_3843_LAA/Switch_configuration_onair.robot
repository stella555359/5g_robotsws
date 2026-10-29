*** Settings ***
Documentation    responsible tester: slawomir.jastrzebski@nokia.com

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ./variables.robot

#Force Tags        CLOUD_R4A_CUS   CA_GVe    SBTS00   CRT   RAN_4G    RAN_4G_FDD

Suite Setup       CUS Setup Test Set Without Reset Configuration  ${SCFC_REFERENCE_FILE_PATH}
Suite Teardown    CUS Teardown Test Set

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=            ${CURDIR}/config/SCFC_SBTS00_CUS.xml
${CUSINI_FILE_PATH}=                    ${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                    ${CURDIR}/config/epc.lua
${CONFIGURATION_NAME}=              	1.1.1.1_AHCA_(2x10)L_M_1.1.1.2_AZRC_(3x20)L_Itx;
@{LCR_ID_CELL_BLOCK_LIST}=              ALL
${BASIC_CALL}=                          True
${CA_SUPPORTED_BANDS}=              	5:a:a+46::a|5:a:a+46::d
${SUPPORTED_BANDS}= 			        5:false,46:false

*** Test Cases ***
Automated_SiSo_STARTUP_CUS_BTS_Reach_Onair_After_Commissioning
    [Setup]  CUS Setup Test Case
    CUS BTS Reach Onair After Commissioning  ${SCFC_REFERENCE_FILE_PATH}  ${ALLOWED_ALARMS_ONAIR}
    [Teardown]  CUS Teardown Test Case  ${SUITE_LOGS_DIR_PATH}  ${ALLOWED_ALARMS}

Automated_SiSo_CALL_LTE_CUS_Basic_Call
    CUS Basic Call When Onair Reached  ${SCFC_REFERENCE_FILE_PATH}  ${CONFIGURATION_NAME}
    ...  ${ALLOWED_ALARMS_ONAIR}
    [Teardown]  CUS Teardown Test Case  ${SUITE_LOGS_DIR_PATH}  ${ALLOWED_ALARMS_ONAIR}

Automated_SiSo_CALL_LTE_CUS_Cells_Block_and_Unblock_with_Basic_Call
    CUS Cell Block Unblock And Call  ${SCFC_REFERENCE_FILE_PATH}  ${LCR_ID_CELL_BLOCK_LIST}  ${BASIC_CALL}
    ...  ${CONFIGURATION_NAME}  ${ALLOWED_ALARMS_ONAIR}
    [Teardown]  CUS Teardown Test Case  ${SUITE_LOGS_DIR_PATH}  ${ALLOWED_ALARMS_BLOCK_UNBLOCK}
