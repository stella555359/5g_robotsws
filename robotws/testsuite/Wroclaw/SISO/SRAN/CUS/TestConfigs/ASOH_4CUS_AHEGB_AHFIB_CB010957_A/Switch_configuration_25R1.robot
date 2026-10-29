*** Settings ***
Documentation    responsible tester: katarzyna.zacharuk@nokia.com
...		 ASOG 24 LTE cells
...              CB010957-SR-A The BB cell set for LTE up to 24 cells 20 MHz CPRI
...              https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-43653
...              Reset configuration not yet supported. LE:22.10.2024

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ../../resources/test_cases_loop.robot
Resource    ../../resources/test_cases_loop.robot
Resource    ./variables.robot

#Force Tags        CLOUD_ASOG_4CUS   CA_GVe   SBTS00   RAN_4G    RAN_4G_FDD    CRT

Suite Setup       CUS Setup Test Set Without Reset Configuration    ${SCFC_REFERENCE_FILE_PATH}
Suite Teardown    CUS Teardown Test Set

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=            ${CURDIR}/config/SCFC_SBTS25R1_CUS.xml
${CUSINI_FILE_PATH}=                	${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                	${CURDIR}/../../resources/config/epc.lua
${CONFIGURATION_NAME}=              	ASOG_24cells
@{LCR_ID_CELL_BLOCK_LIST}=              ALL
${BASIC_CALL}=                          True
${POWER_RESET_COUNT}=               	10
${SITE_RUN_COUNT}=                      5
${collect_single_loop_logs}=            True
${get_kpi}=                             True
@{SWCONFIG_FLAGS}=                      0x360000=3 #enables FDSW/SWIM debug logs
                                        ...  0x980007=1 #ASOG and ASOH ver. 101 Wi-Fi feature disable

*** Test Cases ***
[CB010957_A][1.0] Automated_SiSo_CM_CUS_Template_Commissioning
    CUS Template Commissioning
    ...    scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...    list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...    hw_configuration=${CONFIGURATION_NAME}
    ...    allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    [Teardown]    CUS Teardown Test Case
    ...    logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...    teardown_allowed_alarms=${ALLOWED_ALARMS}

