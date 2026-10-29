*** Settings ***
Documentation    responsible tester: katarzyna.zacharuk@nokia.com
...	         48+192

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ../../resources/test_cases_loop.robot
Resource    ./variables.robot

Suite Setup       CUS Setup Test Set   ${SCFC_REFERENCE_FILE_PATH}  ${SWCONFIG_FILE_PATH}  ${REMOVE_RADIO_DHCPD}
#Suite Setup       CUS Setup Test Set Without Reset Configuration   ${SCFC_REFERENCE_FILE_PATH}
Suite Teardown    CUS Teardown Test Set

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=            ${CURDIR}/config/SCFC.xml
${BIG_CONFIG_PATH}=			            CUS/2MPPP_4CUS_AHEGHA_48_192/SCFC_48RU_192LTE_ASIM.xml
${CUSINI_FILE_PATH}=                    ${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                    ${CURDIR}/../../resources/config/epc.lua
${CONF_ENV_DETECTION}=			        False
${CONFIGURATION_NAME}=                  max_cells
${REMOVE_RADIO_DHCPD}=                  True
${SITE_RUN_COUNT}=                      10
${BBMOD_RUN_COUNT}=                     5
${RAT_RESET_COUNT}=                     5
${RAT_TYPE}=			                LTE
${RAT_IMPACT}=			                LTE
${RAT_RESET_TIMEOUT}=                   1200
${VERIFY_CHANGES}=              	    False
@{bbmod_sn_list}=                       SELECT  L1234004905  L1233804727  L1234007309  L1234007304
${GET_KPI}=                             True
${SKIP_TRUCK_ROLL}

*** Test Cases ***
[BIG_LTE][1.0] Automated_SiSo_CM_CUS_Template_Commissioning
    CUS Template Commissioning
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    ...  conf_env_detection=${CONF_ENV_DETECTION}
    [Teardown]    CUS Teardown Test Case
    ...    logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...    teardown_allowed_alarms=${ALLOWED_ALARMS}

[BIG_LTE][1.0] Automated_SiSo_STARTUP_CUS_Site_Reset_BTS
    CUS Reset Site Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  get_kpi=${GET_KPI}
    ...  run_count=${SITE_RUN_COUNT}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}

[BIG_LTE][1.0] Automated_SiSo_STARTUP_CUS_Baseband_Module_Reset
    CUS Baseband Module Reset Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  bbmod_sn_list=${BBMOD_SN_LIST}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  get_kpi=${GET_KPI}
    ...  run_count=${BBMOD_RUN_COUNT}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    [Teardown]  CUS Teardown Test Case
    ...  logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...  teardown_allowed_alarms=${ALLOWED_ALARMS}

[BIG_LTE][1.0] Automated_SiSo_CM_CUS_BTS_Rat_Reset
    CUS BTS Rat Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  rat_type=${RAT_TYPE}
    ...  rat_reset_timeout=${RAT_RESET_TIMEOUT}
    ...  verify_changes=${VERIFY_CHANGES}
    ...  run_count=${RAT_RESET_COUNT}
    ...  get_kpi=${GET_KPI}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    ...  logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...  teardown_allowed_alarms=${ALLOWED_ALARMS}