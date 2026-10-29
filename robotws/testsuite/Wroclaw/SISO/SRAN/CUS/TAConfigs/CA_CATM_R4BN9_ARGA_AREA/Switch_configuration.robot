*** Settings ***
Documentation    responsible tester: slawomir.jastrzebski@nokia.com

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ./variables.robot

#Force Tags        CLOUD_R4BN9_CUS     CA_GVe   SBTS00     CRT   RAN_4G    RAN_4G_FDD

Suite Setup       CUS Setup Test Set    ${SCFC_REFERENCE_FILE_PATH}    log_steps=True
Suite Teardown    CUS Teardown Test Set    log_steps=True

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=        ${CURDIR}/config/SCFC.xml
${CUSINI_FILE_PATH}=                ${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                ${CURDIR}/config/epc.lua
${CONFIGURATION_NAME}=              CLOUD_R4BO9_CUS
@{LCR_ID_CELL_BLOCK_LIST}=          ALL
${BASIC_CALL}=                      True
${CA_SUPPORTED_BANDS}=              1:a:a+3:a:a|3:a:a+1:a:a
${SUPPORTED_BANDS}=                 1:false,3:false
${JSON_DELTA_FILE}                  ${CURDIR}/config/delta_file.json
${POWER_RESET_COUNT}=               3

*** Test Cases ***
Automated__SiSo__I-PHY__Template_Commissioning
    CUS Template Commissioning  ${SCFC_REFERENCE_FILE_PATH}    ${LIST_OF_CUS_IPS}
    ...    ${CONFIGURATION_NAME}    ${ALLOWED_ALARMS_ONAIR}    log_steps=True
    [Teardown]    CUS Teardown Test Case    ${SUITE_LOGS_DIR_PATH}    ${ALLOWED_ALARMS}    log_steps=True

Automated__SiSo__I-PHY_Configuration_Testing_Basic_Call
    [Setup]    CUS Check And Perform Template Commissioning If Needed   ${SCFC_REFERENCE_FILE_PATH}
    ...    ${LIST_OF_CUS_IPS}    log_steps=True
    CUS Basic Call When Onair Reached    ${SCFC_REFERENCE_FILE_PATH}    ${CONFIGURATION_NAME}
    ...    ${ALLOWED_ALARMS_ONAIR}    log_steps=True
    [Teardown]    CUS Teardown Test Case    ${SUITE_LOGS_DIR_PATH}    ${ALLOWED_ALARMS_ONAIR}    log_steps=True

Automated__SiSo__CUS_Cells_Block_and_Unblock_with_Basic_Call
    [Setup]    CUS Check And Perform Template Commissioning If Needed   ${SCFC_REFERENCE_FILE_PATH}
    ...    ${LIST_OF_CUS_IPS}    log_steps=True
    CUS Cell Block Unblock And Call    ${SCFC_REFERENCE_FILE_PATH}      ${LCR_ID_CELL_BLOCK_LIST}    ${BASIC_CALL}
    ...    ${CONFIGURATION_NAME}    ${ALLOWED_ALARMS_ONAIR}    log_steps=True
    [Teardown]    CUS Teardown Test Case    ${SUITE_LOGS_DIR_PATH}    ${ALLOWED_ALARMS_BLOCK_UNBLOCK}    log_steps=True
