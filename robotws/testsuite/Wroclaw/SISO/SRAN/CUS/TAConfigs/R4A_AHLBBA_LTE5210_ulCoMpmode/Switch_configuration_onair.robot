*** Settings ***
Documentation    responsible tester: slawomir.jastrzebski@nokia.com
...	             5210_CL_1a1_AHLBBA

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ./variables.robot

#Force Tags      CLOUD_R4A_CUS   CA_GVe   SBTS00   RAN_4G    RAN_4G_FDD     CRT

Suite Setup       CUS Setup Test Set Without Reset Configuration    ${SCFC_REFERENCE_FILE_PATH}    log_steps=True
Suite Teardown    CUS Teardown Test Set    log_steps=True

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=        ${CURDIR}/config/SCFC_SBTS00.xml
${CUSINI_FILE_PATH}=                ${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                ${CONFIG_DIR}/epc.lua
${CONFIGURATION_NAME}=              CLOUD_R4A_CUS

*** Test Cases ***
Automated__SiSo__CUS_BTS_Reach_Onair_After_Commissioning
    CUS BTS Reach Onair After Commissioning    ${SCFC_REFERENCE_FILE_PATH}    ${ALLOWED_ALARMS_ONAIR}    log_steps=True
    [Teardown]  CUS Teardown Test Case    ${SUITE_LOGS_DIR_PATH}    ${ALLOWED_ALARMS}    log_steps=True
