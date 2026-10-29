*** Settings ***
Documentation    responsible tester: slawomir.jastrzebski@nokia.com
...              5G+4G CB008510 A9 and B1
...              2x[1.1.1_1.3.1_AHFII]_(2x10+2x20+1x30+1x40)L_N;1.2.1_AHEGC_(1x20+1x30)L_A;
...              1.2.2_AHEGC_(1x15+1x40)L_A;1.2.3_AHEGC_(1x10+1x30)L_A;

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ./variables.robot

#Force Tags        CLOUD_R4BANO_CUS    RAN_4G    RAN_4G_FDD    SBTS00    CRT

Suite Setup       CUS Setup Test Set    ${SCFC_REFERENCE_FILE_PATH}
Suite Teardown    CUS Teardown Test Set

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=        	${CURDIR}/config/SCFC_SBTS00_CUS.xml
${CUSINI_FILE_PATH}=                	${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                	${CURDIR}/config/epc.lua
${SWCONFIG_FILE_PATH}=                  ${CURDIR}/config/swconfig
${CONFIGURATION_NAME}=                  2x[1.1.1_1.3.1_AHFII]_(2x10+2x20+1x30+1x40)L_N
@{LCR_ID_CELL_BLOCK_LIST}=              ALL
${BASIC_CALL}=                          True
${POWER_RESET_COUNT}=               	3
${collect_single_loop_logs}=            True

*** Test Cases ***
[12][1.0] Automated_SiSo_CM_CUS_Template_Commissioning
    CUS Template Commissioning  ${SCFC_REFERENCE_FILE_PATH}  ${LIST_OF_CUS_IPS}
    ...  ${CONFIGURATION_NAME}  ${ALLOWED_ALARMS_ONAIR}
    [Teardown]  CUS Teardown Test Case  ${SUITE_LOGS_DIR_PATH}  ${ALLOWED_ALARMS}

[11][1.0] Automated_SiSo_CALL_LTE_CUS_Cells_Block_and_Unblock_with_Basic_Call
    [Setup]  CUS Check And Perform Template Commissioning If Needed  ${SCFC_REFERENCE_FILE_PATH}
    ...  ${LIST_OF_CUS_IPS}
    CUS Cell Block Unblock And Call  ${SCFC_REFERENCE_FILE_PATH}  ${LCR_ID_CELL_BLOCK_LIST}  ${BASIC_CALL}
    ...  ${CONFIGURATION_NAME}  ${ALLOWED_ALARMS_ONAIR}
    [Teardown]  CUS Teardown Test Case  ${SUITE_LOGS_DIR_PATH}  ${ALLOWED_ALARMS_BLOCK_UNBLOCK}
