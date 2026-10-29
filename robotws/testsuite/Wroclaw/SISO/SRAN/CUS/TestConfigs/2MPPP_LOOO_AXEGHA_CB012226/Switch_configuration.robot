*** Settings ***
Documentation    responsible tester: jakub.pachana@nokia.com
...	         AXEGHA  CB012226
...		 CNI-160897 will change output power limits on AXEGHA FID:4720 / PR864424
...		 Radio detection issue / PR865514
...		 FID:4673 Configuration mismatch with O-RU capabilities is a CUS issue

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ../../resources/test_cases_loop.robot
Resource    ../../resources/test_cases_loop.robot
Resource    ./variables.robot

Suite Setup       CUS Setup Test Set   ${SCFC_REFERENCE_FILE_PATH}
Suite Teardown    CUS Teardown Test Set

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=            ${CURDIR}/config/SCFC_SBTS00_CUS.xml
${CUSINI_FILE_PATH}=                    ${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                    ${CURDIR}/config/epc.lua
${SKIP_TRUCK_ROLL}=			True
${CONF_ENV_DETECTION}=			False
${CONFIGURATION_NAME}=                  AXEGHA;
${GET_KPI}=                             False
${RUN_COUNT}=				10
${POWER_RESET_COUNT}=			10
${BBMOD_RUN_COUNT}=         		10
@{BBMOD_SN_LIST}=           		SELECT  L1233701301
${RAT_TYPE_1}=				NR
${RAT_TYPE_2}=				LTE
${RAT_RESET_COUNT}=			5
${RAT_IMPACT}=				ALL


*** Test Cases ***
[AXEGHA][1.0] Automated_SiSo_CM_CUS_Template_Commissioning
    CUS Template Commissioning
    ...    scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...    list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...    hw_configuration=${CONFIGURATION_NAME}
    ...    allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    ...    conf_env_detection=${CONF_ENV_DETECTION}
    [Teardown]  CUS Teardown Test Case
    ...    logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...    teardown_allowed_alarms=${ALLOWED_ALARMS}

[AXEGHA][1.0] Automated_SiSo_STARTUP_CUS_Site_Reset_BTS
    [Setup]  CUS Check And Perform Template Commissioning If Needed
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    CUS Reset Site Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  get_kpi=${GET_KPI}
    ...  run_count=${RUN_COUNT}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}

[AXEGHA][1.0] Automated_SiSo_STARTUP_CUS_Power_Reset_BTS
    [Setup]  CUS Check And Perform Template Commissioning If Needed
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    CUS BTS Power Reset Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  run_count=${POWER_RESET_COUNT}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}

[AXEGHA][1.0] Automated_SiSo_STARTUP_CUS_Baseband_Module_Reset
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

[AXEGHA][1.0] Automated_SiSo_CM_CUS_BTS_Rat_Reset
    [Setup]  CUS Check And Perform Template Commissioning If Needed
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    CUS BTS Rat Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  rat_type=${RAT_TYPE_1}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    ...  run_count=${RAT_RESET_COUNT}

[AXEGHA_2][1.0] Automated_SiSo_CM_CUS_BTS_Rat_Reset
    [Setup]  CUS Check And Perform Template Commissioning If Needed
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    CUS BTS Rat Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  rat_type=${RAT_TYPE_2}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    ...  run_count=${RAT_RESET_COUNT}
