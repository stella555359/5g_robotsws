*** Settings ***
Documentation    responsible tester: slawomir.jastrzebski@nokia.com

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ./variables.robot

Suite Setup       CUS Setup Test Set    ${SCFC_REFERENCE_FILE_PATH}    log_steps=True
Suite Teardown    CUS Teardown Test Set    log_steps=True

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=            ${CURDIR}/config/SCFC.xml
${SCFC_FAIL_REFERENCE_FILE_PATH}=       ${CURDIR}/config/SCFC_INVALID.xml
${CUSINI_FILE_PATH}=                    ${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                    /home/ute/MN/UTE/robotlte/testsuite/WMP/GVe/Wroclaw/AiFSiteS/CUS/resources/config/epc.lua
${CONFIGURATION_NAME}=                  CLOUD_R4A
${BASIC_CALL}=                          True
@{LCR_ID_CELL_BLOCK_LIST}=              ALL
${INVALID_SCFC}=                        True

*** Test Cases ***
Automated__SiSo__I-PHY_Template_Commissioning
    CUS Template Commissioning  ${SCFC_REFERENCE_FILE_PATH}    ${LIST_OF_IPHY_IPS}
    ...    ${CONFIGURATION_NAME}    ${ALLOWED_ALARMS_ONAIR}    log_steps=True    invalid_scfc=${INVALID_SCFC}
    [Teardown]    CUS Teardown Test Case    ${SUITE_LOGS_DIR_PATH}    ${ALLOWED_ALARMS}    log_steps=True

Automated__SiSo__I-PHY_Cells_Block_and_Unblock_with_Basic_Call
    [Setup]    CUS Check And Perform Template Commissioning If Needed   ${SCFC_REFERENCE_FILE_PATH}    ${LIST_OF_IPHY_IPS}    log_steps=True
    CUS Cell Block Unblock And Call    ${SCFC_REFERENCE_FILE_PATH}      ${LCR_ID_CELL_BLOCK_LIST}    ${BASIC_CALL}
    ...    ${CONFIGURATION_NAME}    ${ALLOWED_ALARMS_ONAIR}    log_steps=True
    [Teardown]    CUS Teardown Test Case    ${SUITE_LOGS_DIR_PATH}    ${ALLOWED_ALARMS_BLOCK_UNBLOCK}    log_steps=True
