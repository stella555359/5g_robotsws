*** Settings ***
Documentation    responsible tester: jakub.pachana@nokia.com
...	             5210_CL_1a1_AHLBBA

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ./variables.robot

#Force Tags      CLOUD_R4A_CUS   CA_GVe   SBTS00   RAN_4G    RAN_4G_FDD     CRT

Suite Setup       CUS Setup Test Set    ${SCFC_REFERENCE_FILE_PATH}    log_steps=True
Suite Teardown    CUS Teardown Test Set    log_steps=True

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=        ${CURDIR}/config/SCFC_SBTS00.xml
${CUSINI_FILE_PATH}=                ${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                ${CONFIG_DIR}/epc.lua
${CONFIGURATION_NAME}=              CLOUD_R4A_CUS

*** Test Cases ***
Automated__SiSo__I-PHY_Template_Commissioning
    CUS Template Commissioning  ${SCFC_REFERENCE_FILE_PATH}    ${LIST_OF_IPHY_IPS}
    ...    ${CONFIGURATION_NAME}    ${ALLOWED_ALARMS_ONAIR}    log_steps=True
#    Verify ULCoMP Configuration
    [Teardown]    CUS Teardown Test Case    ${SUITE_LOGS_DIR_PATH}    ${ALLOWED_ALARMS}    log_steps=True

#*** Keywords ***
#Verify ULCoMP Configuration
#    BTS Should Be OnAir
#    ${ulcompcell_lncel_list}=    Evaluate Xpath    ${SCFC_REFERENCE_FILE_PATH}
#    ...    .//managedObject[contains(@class, "NOKLTE:ULCOMP") and contains(@distName,"ULCOMP-0")]/list[@name="ulCoMpCellList"]/p/text()
#    :FOR    ${cell}    IN   @{ulcompcell_lncel_list}
#    \    Run Keyword And Continue On Failure    ute_syslog.Message Should Exist In Syslog File     regexp=lnCelId:${cell}.*hasCompInfo:1.*


