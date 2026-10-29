*** Settings ***
Documentation    responsible tester: jakub.pachana@nokia.com
...	         EDA04710215

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ../../resources/test_cases_loop.robot
Resource    ./variables.robot

Suite Setup       CUS Setup Test Set    ${SCFC_REFERENCE_FILE_PATH}
Suite Teardown    CUS Teardown Test Set

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=            ${CURDIR}/config/SCFC_SBTS00_CUS.xml
${BIG_CONFIG_PATH}=			CUS/BAAO_AHPMDB_AHHB_AHEGB_EDA04710215/SCFC_SBTS00_CUS.xml
${CUSINI_FILE_PATH}=                    ${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                    ${CURDIR}/config/epc.lua
${CONFIGURATION_NAME}=                  AHSA
${POWER_RESET_COUNT}=               	5
${SITE_RESET_COUNT}=		        	10
${RAT_RESET_COUNT}=			            5
${BBMOD_RUN_COUNT}=                     2
@{BBMOD_SN_LIST}=                       ALL
${collect_single_loop_logs}=            True
@{LCR_ID_CELL_BLOCK_LIST}=              ALL
${BASIC_CALL}=                          True
${CA_SUPPORTED_BANDS}=                  3:a:a+32::a|3:a:a+32::c|7:a:a+32::a|7:a:a+32::c|1:a:a+32::a|1:a:a+32::c
${SUPPORTED_BANDS}=                     3:false,32:false,7:false,1:false
${GET_KPI}=				                False
${RAT_TYPE}=			            	LTE
${VERIFY_CHANGES}=		            	False



*** Test Cases ***
[EDA04710215][1.0] Automated_SiSo_CM_CUS_Template_Commissioning
    CUS Template Commissioning
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    [Teardown]    CUS Teardown Test Case    ${SUITE_LOGS_DIR_PATH}    ${ALLOWED_ALARMS}

[EDA04710215][1.0] Automated_SiSo_STARTUP_CUS_Power_Reset_BTS
    [Setup]  CUS Check And Perform Template Commissioning If Needed
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    CUS BTS Power Reset Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  run_count=${POWER_RESET_COUNT}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}

[EDA04710215][1.0] Automated_SiSo_STARTUP_CUS_Site_Reset_BTS
    [Setup]  CUS Check And Perform Template Commissioning If Needed
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    CUS Reset Site Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  get_kpi=${GET_KPI}
    ...  run_count=${SITE_RESET_COUNT}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}

[EDA04710215][1.0] Automated_SiSo_CM_CUS_BTS_Rat_Reset
    [Setup]  CUS Check And Perform Template Commissioning If Needed
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    CUS BTS Rat Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  rat_type=${RAT_TYPE}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  get_kpi=${GET_KPI}
    ...  verify_changes=${VERIFY_CHANGES}
    ...  run_count=${RAT_RESET_COUNT}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_RAT_RESET}

[EDA04710215][1.0] Automated_SiSo_STARTUP_CUS_Baseband_Module_Reset
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
