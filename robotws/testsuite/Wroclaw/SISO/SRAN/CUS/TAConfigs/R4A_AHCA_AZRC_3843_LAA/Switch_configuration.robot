*** Settings ***
Documentation    responsible tester: slawomir.jastrzebski@nokia.com

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ./variables.robot

Suite Setup       CUS Setup Test Set    ${SCFC_REFERENCE_FILE_PATH}
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
Automated_SiSo_CM_CUS_Template_Commissioning
    CUS Template Commissioning  ${SCFC_REFERENCE_FILE_PATH}  ${LIST_OF_CUS_IPS}
    ...  ${CONFIGURATION_NAME}  ${ALLOWED_ALARMS_ONAIR}
    [Teardown]  CUS Teardown Test Case  ${SUITE_LOGS_DIR_PATH}  ${ALLOWED_ALARMS}

Automated_SiSo_CALL_LTE_CUS_Basic_Call
    [Setup]  CUS Check And Perform Template Commissioning If Needed  ${SCFC_REFERENCE_FILE_PATH}
    ...  ${LIST_OF_CUS_IPS}
    CUS Basic Call When Onair Reached  ${SCFC_REFERENCE_FILE_PATH}  ${CONFIGURATION_NAME}
    ...  ${ALLOWED_ALARMS_ONAIR}
    [Teardown]  CUS Teardown Test Case  ${SUITE_LOGS_DIR_PATH}  ${ALLOWED_ALARMS_ONAIR}

Automated_SiSo_CALL_LTE_CUS_Cells_Block_and_Unblock_with_Basic_Call
    [Setup]  CUS Check And Perform Template Commissioning If Needed  ${SCFC_REFERENCE_FILE_PATH}
    ...  ${LIST_OF_CUS_IPS}
    CUS Cell Block Unblock And Call  ${SCFC_REFERENCE_FILE_PATH}  ${LCR_ID_CELL_BLOCK_LIST}  ${BASIC_CALL}
    ...  ${CONFIGURATION_NAME}  ${ALLOWED_ALARMS_ONAIR}
    [Teardown]  CUS Teardown Test Case  ${SUITE_LOGS_DIR_PATH}  ${ALLOWED_ALARMS_BLOCK_UNBLOCK}
