*** Settings ***
Documentation    responsible tester: daniel.grzebelec@nokia.com
...	         AQQT_KT on ASIM

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
${BIG_CONFIG_PATH}=			CUS/2MPPP_LOOO_AQQT_CNI_133234_A/SCFC_SBTS00_CUS.xml
${CUSINI_FILE_PATH}=                    ${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                    ${CURDIR}/config/epc.lua
${SKIP_TRUCK_ROLL}=			True
${CONF_ENV_DETECTION}=			False
${CONFIGURATION_NAME}=                  KT;
${GET_KPI}=                             True
${RAT_TYPE}=				NR
${VERIFY_CHANGES}=			False
${RUN_COUNT}=				5
${BBMOD_RUN_COUNT}=         2
@{BBMOD_SN_LIST}=           RANDOM  3


*** Test Cases ***
[133234_A][1.0] Automated_SiSo_CM_CUS_Template_Commissioning
    CUS Template Commissioning
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    ...  conf_env_detection=${CONF_ENV_DETECTION}
    [Teardown]    CUS Teardown Test Case    ${SUITE_LOGS_DIR_PATH}    ${ALLOWED_ALARMS}

[1133234_A][1.0] Automated_SiSo_STARTUP_CUS_Site_Reset_BTS
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

[133234_A][1.0] Automated_SiSo_CM_CUS_BTS_Rat_Reset
    CUS BTS Rat Reset
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  rat_type=${RAT_TYPE}
    ...  get_kpi=${GET_KPI}
    ...  verify_changes=${VERIFY_CHANGES}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    [Teardown]    CUS Teardown Test Case    ${SUITE_LOGS_DIR_PATH}    ${ALLOWED_ALARMS}

[133234_A][1.0] Automated_SiSo_STARTUP_CUS_Baseband_Module_Reset
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
