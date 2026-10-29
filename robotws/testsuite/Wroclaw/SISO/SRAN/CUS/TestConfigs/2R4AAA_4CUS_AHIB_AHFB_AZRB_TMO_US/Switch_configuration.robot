*** Settings ***
Documentation    responsible tester: katarzyna.zacharuk@nokia.com
...              TMO US config
...              9xAHIB+9xAHFB+8xAZRB

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ../../resources/test_cases_loop.robot
Resource    ../../resources/test_cases_loop.robot
Resource    ./variables.robot

#Force Tags        CLOUD_2R4AAA_4CUS     CA_GVe   SBTS00     CRT   RAN_4G    RAN_4G_FDD

Suite Setup       CUS Setup Test Set    ${SCFC_REFERENCE_FILE_PATH}
Suite Teardown    CUS Teardown Test Set

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=        ${CURDIR}/config/SCFC.xml
${BIG_CONFIG_PATH}=			        CUS/2R4AAA_4CUS_AHIB_AHFB_AZRB_TMO_US/SCFC_SBTS00_TMO.xml
${CUSINI_FILE_PATH}=                ${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                ${CURDIR}/config/epc.lua
${CONFIGURATION_NAME}=              TMO_US
@{LCR_ID_CELL_BLOCK_LIST}=          ALL
${BASIC_CALL}=                      True
${SITE_RUN_COUNT}=                  5
${POWER_RESET_COUNT}=               5
${collect_single_loop_logs}=        True
${GET_KPI}=                         True
${RAT_TYPE}=            			LTE
${VERIFY_CHANGES}=              	False
${CA_SUPPORTED_BANDS}=              2:a:a+4::a|4:a:a+2::a|4:a:a+2::a+46::a|4:a:a+2::a+46::d|2:a:a+4::a+46::a|2:a:a+4::a+46::d
${SUPPORTED_BANDS}=                 2:false,4:false,46:false
${SKIP_TRUCK_ROLL}

*** Test Cases ***
[TMO_AZRB][1.0] Automated_SiSo_CM_CUS_Template_Commissioning
    CUS Template Commissioning
    ...    scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...    list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...    hw_configuration=${CONFIGURATION_NAME}
    ...    allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    [Teardown]    CUS Teardown Test Case
    ...    logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...    teardown_allowed_alarms=${ALLOWED_ALARMS}

[TMO_AZRB][1.0] Automated_SiSo_CM_CUS_BTS_Rat_Reset
    CUS BTS Rat Reset
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  rat_type=${RAT_TYPE}
    ...  get_kpi=${GET_KPI}
    ...  verify_changes=${VERIFY_CHANGES}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    [Teardown]    CUS Teardown Test Case
    ...    logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...    teardown_allowed_alarms=${ALLOWED_ALARMS}

[TMO_AZRB][1.0] Automated_SiSo_CALL_LTE_CUS_Cells_Block_and_Unblock_with_Basic_Call
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

[TMO_AZRB][1.0] Automated_SiSo_STARTUP_CUS_Site_Reset_BTS
    [Setup]  CUS Check And Perform Template Commissioning If Needed
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    CUS Reset Site Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  get_kpi=${GET_KPI}
    ...  run_count=${SITE_RUN_COUNT}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}

[TMO_AZRB][1.0] Automated_SiSo_STARTUP_CUS_Power_Reset_BTS
    [Setup]  CUS Check And Perform Template Commissioning If Needed
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    CUS BTS Power Reset Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  run_count=${POWER_RESET_COUNT}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
