*** Settings ***
Documentation    responsible tester: katarzyna.zacharuk@nokia.com
...              Emirates 6c6816ff82cdade1 ABIA+ABIP (master)

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ../../resources/test_cases_loop.robot
Resource    ./variables.robot

##Force Tags        CLOUD_MAPO_BQQA_RH_4CUS  CA_GVe   SBTS00    RAN_4G    RAN_4G_FDD    CRT

Suite Setup       CUS Setup Test Set   ${SCFC_REFERENCE_FILE_PATH}
#Suite Setup       CUS Setup Test Set Without Reset Configuration   ${SCFC_REFERENCE_FILE_PATH}    log_steps=True
Suite Teardown    CUS Teardown Test Set

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=        	${CURDIR}/config/SCFC.xml
${BIG_CONFIG_PATH}=			CUS/MAPO_BQQA_RH_4CUS_Emirates_3G/SCFC_emi.xml
${CUSINI_FILE_PATH}=                	${CURDIR}/config/cus_emi.ini
${EPCSIM_FILE_PATH}=                	${CURDIR}/../../resources/config/epc.lua
${CONFIGURATION_NAME}=                  Emirates
@{LCR_ID_CELL_BLOCK_LIST}=		7  8  13  14  16  17  18  19  20  21  22  23  24  25  26  27  28  29
${BASIC_CALL}=                          True
${POWER_RESET_COUNT}=               	10
${SITE_RUN_COUNT}=                      10
${RAT_RESET_COUNT}=                     10
${CA_SUPPORTED_BANDS_1}= 		1:a:a+3:a:a+3::a|3:a:a+1:a:a+3::a|3:a:a+3:a:a+1::a|
${CA_SUPPORTED_BANDS_2}= 		3:a:a+1:a:a|1:a:a+3:a:a|3:a:a+3:a:a
${CA_SUPPORTED_BANDS}= 			${CA_SUPPORTED_BANDS_1}${CA_SUPPORTED_BANDS_2}
${SUPPORTED_BANDS}=			1:false,3:false
${RAT_TYPE_1}=                          LTE
${RAT_RESET_TIMEOUT}=                   600
${VERIFY_CHANGES}=                      False
${collect_single_loop_logs}=            True
${get_kpi}=                             True
${SKIP_TRUCK_ROLL}

*** Test Cases ***
[EMI_HYBRID][1.0] Automated_SiSo_CM_CUS_Template_Commissioning
    CUS Template Commissioning
    ...    scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...    list_of_cus_ips=${LIST_OF_IPHY_IPS}
    ...    hw_configuration=${CONFIGURATION_NAME}
    ...    allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    [Teardown]    CUS Teardown Test Case
    ...    logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...    teardown_allowed_alarms=${ALLOWED_ALARMS}

[EMI_HYBRID][1.0] Automated_SiSo_STARTUP_CUS_Power_Reset_BTS
    [Setup]  CUS Check And Perform Template Commissioning If Needed
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    CUS BTS Power Reset Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  get_kpi=${GET_KPI}
    ...  run_count=${POWER_RESET_COUNT}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}

[EMI_HYBRID][1.0] Automated_SiSo_CM_CUS_BTS_Rat_Reset
    [Setup]  CUS Check And Perform Template Commissioning If Needed
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    CUS BTS Rat Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  rat_type=${RAT_TYPE_1}
    ...  rat_reset_timeout=${RAT_RESET_TIMEOUT}
    ...  verify_changes=${VERIFY_CHANGES}
    ...  run_count=${RAT_RESET_COUNT}
    ...  get_kpi=${GET_KPI}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    ...  logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...  teardown_allowed_alarms=${ALLOWED_ALARMS}

[EMI_HYBRID][1.0] Automated_SiSo_CALL_LTE_CUS_Cells_Block_and_Unblock_with_Basic_Call
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

[EMI_HYBRID][1.0] Automated_SiSo_STARTUP_CUS_Site_Reset_BTS
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