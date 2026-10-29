*** Settings ***
Documentation    responsible tester: katarzyna.zacharuk@nokia.com
...              User Scenario CB010448-BA #2: NR FDD ABIP BB Cell Set type CB010448-BA2 for supporting 8 cells 40 MHz on half ABIP

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ../../resources/test_cases_loop.robot
Resource    ./variables.robot

#Force Tags        CLOUD_R4MP12_4CUS  CA_GVe   SBTS00    RAN_4G    RAN_4G_FDD    CRT

Suite Setup       CUS Setup Test Set   ${SCFC_REFERENCE_FILE_PATH}
Suite Teardown    CUS Teardown Test Set

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=        	${CURDIR}/config/SCFC_SBT24R3_CUS.xml
${CUSINI_FILE_PATH}=                	${CURDIR}/config/cus_MP12_2CUS.ini
${EPCSIM_FILE_PATH}=                	${CURDIR}/config/epc.lua
${CONFIGURATION_NAME}=                  any
@{LCR_ID_CELL_BLOCK_LIST}=              ALL
${BASIC_CALL}=                          True
${POWER_RESET_COUNT}=               	5
${collect_single_loop_logs}=            True
${SKIP_TRUCK_ROLL}

*** Test Cases ***
[4][1.0] Automated_SiSo_CM_CUS_Template_Commissioning
    CUS Template Commissioning
    ...    scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...    list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...    hw_configuration=${CONFIGURATION_NAME}
    ...    allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    [Teardown]    CUS Teardown Test Case
    ...    logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...    teardown_allowed_alarms=${ALLOWED_ALARMS}

[4][1.0] Automated_SiSo_STARTUP_CUS_Power_Reset_BTS
    [Setup]  CUS Check And Perform Template Commissioning If Needed
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    CUS BTS Power Reset Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  run_count=${POWER_RESET_COUNT}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}

