*** Settings ***
Documentation    responsible tester: katarzyna.zacharuk@nokia.com
...	         192+192

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases_loop.robot
Resource    ../../resources/test_cases.robot
Resource    ../../resources/test_cases_loop.robot
Resource    ./variables.robot

Suite Setup       CUS Setup Test Set   ${SCFC_REFERENCE_FILE_PATH}  ${SWCONFIG_FILE_PATH}  ${REMOVE_RADIO_DHCPD}
Suite Teardown    CUS Teardown Test Set

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=            ${CURDIR}/config/SCFC.xml
${BIG_CONFIG_PATH}=			CUS/2MPPP_4CUS_AHEGHA_192_192/SCFC_ASIM_ASIM_192RU_192LTE_ABIP_CPRI7_ALL.xml
${CUSINI_FILE_PATH}=                    ${CURDIR}/config/cus_ABIP.ini
${EPCSIM_FILE_PATH}=                    ${CURDIR}/../../resources/config/epc.lua
${CONF_ENV_DETECTION}=			False
${CONFIGURATION_NAME}=                  max_cells
${REMOVE_RADIO_DHCPD}=                  True
${SITE_RUN_COUNT}=                      10
${GET_KPI}=                             True
${SKIP_TRUCK_ROLL}

*** Test Cases ***
[BIGGEST_LTE][1.0] Automated_SiSo_CM_CUS_Template_Commissioning
    CUS Template Commissioning
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    ...  conf_env_detection=${CONF_ENV_DETECTION}
    [Teardown]    CUS Teardown Test Case
    ...    logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...    teardown_allowed_alarms=${ALLOWED_ALARMS}

[BIGGEST_LTE][1.0] Automated_SiSo_STARTUP_CUS_Site_Reset_BTS
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
