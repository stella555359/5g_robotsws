*** Settings ***
Documentation    responsible tester: jakub.pachana@nokia.com
...	         AT&T_Mexico

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ../../resources/test_cases_loop.robot
Resource    ./variables.robot

Suite Setup       CUS Setup Test Set    ${SCFC_REFERENCE_FILE_PATH}
Suite Teardown    CUS Teardown Test Set

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=            /home/ute/testline_configuration/10_16_UTE4G154/SCFC_AT_T_SBTS00_CUS.xml
${CUSINI_FILE_PATH}=                    ${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                    ${CURDIR}/config/epc.lua
${CONFIGURATION_NAME}=                  AT&T_Mexico
${POWER_RESET_COUNT}=               	10
${RAT_RESET_COUNT}=                     5
${RAT_TYPE}=                            NR
${RAT_IMPACT}=				41,42,43,91,92,93
${BBMOD_RUN_COUNT}=                     3
@{BBMOD_SN_LIST}=                       ALL
${collect_single_loop_logs}=            True
@{LCR_ID_CELL_BLOCK_LIST}=              ALL
${BASIC_CALL}=                          True
${CA_SUPPORTED_BANDS}=                  4::a+4:a:a+7:a:a|7:a:a+4:a:a+4::a
${SUPPORTED_BANDS}=                     4:false,7:false



*** Test Cases ***
[AT_T][1.0] Automated_SiSo_CM_CUS_Template_Commissioning
    CUS Template Commissioning
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    [Teardown]    CUS Teardown Test Case    ${SUITE_LOGS_DIR_PATH}    ${ALLOWED_ALARMS}

[AT_T][1.0] Automated_SiSo_STARTUP_CUS_Power_Reset_BTS
    [Setup]  CUS Check And Perform Template Commissioning If Needed
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    CUS BTS Power Reset Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  run_count=${POWER_RESET_COUNT}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}

[AT_T][1.0] Automated_SiSo_CALL_LTE_CUS_Cells_Block_and_Unblock_with_Basic_Call
    [Setup]  CUS Check And Perform Template Commissioning If Needed
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    CUS Cell Block Unblock And Call
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  lcr_id_block_list=${LCR_ID_CELL_BLOCK_LIST}
    ...  basic_call=${BASIC_CALL}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    [Teardown]  CUS Teardown Test Case
    ...  logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...  teardown_allowed_alarms=${ALLOWED_ALARMS_BLOCK_UNBLOCK}

[AT_T][1.0] Automated_SiSo_STARTUP_CUS_Baseband_Module_Reset
    [Setup]  CUS Check And Perform Template Commissioning If Needed
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    CUS Baseband Module Reset Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  bbmod_sn_list=${BBMOD_SN_LIST}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  run_count=${BBMOD_RUN_COUNT}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}

[AT_T][1.0] Automated_SiSo_CM_CUS_BTS_Rat_Reset
    [Setup]  CUS Check And Perform Template Commissioning If Needed
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    CUS BTS Rat Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  rat_type=${RAT_TYPE}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    ...  run_count=${RAT_RESET_COUNT}
