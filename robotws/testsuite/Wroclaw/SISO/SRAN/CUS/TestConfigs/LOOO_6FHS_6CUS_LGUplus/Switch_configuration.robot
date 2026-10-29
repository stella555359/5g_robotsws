*** Settings ***
Documentation    responsible tester: rafal.rokitowski@nokia.com
...	         FHS with CUS LG_Uplus customer config: 1cde058a7d1c6bb5

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ../../resources/test_cases_loop.robot
Resource    ./variables.robot

Suite Setup       CUS Setup Test Set   ${SCFC_REFERENCE_FILE_PATH}
Suite Teardown    CUS Teardown Test Set

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=            ${CURDIR}/config/SCFC_SBTS00_CUS.xml
${BIG_CONFIG_PATH}=			CUS/LOOO_6FHS_6CUS_LGUplus/SCFC_SBTS00_CUS.xml
${CUSINI_FILE_PATH}=                	${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                	${CURDIR}/../../resources/config/epc.lua
${CONFIGURATION_NAME}=              	LG_Uplus
${collect_single_loop_logs}=            True
${get_kpi}=                             False
${SITE_RESET_COUNT}=				    5
${POWER_RESET_COUNT}=               	5
${CA_SUPPORTED_BANDS}=                  2:a:a+25:a:a
${SUPPORTED_BANDS}=                     2:false,25:false
${SKIP_TRUCK_ROLL}

*** Test Cases ***
[LG_Uplus][1.0] Automated_SiSo_CM_CUS_Template_Commissioning
    CUS Template Commissioning
    ...    scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...    list_of_cus_ips=${LIST_OF_IPHY_IPS}
    ...    hw_configuration=${CONFIGURATION_NAME}
    ...    allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    [Teardown]    CUS Teardown Test Case
    ...    logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...    teardown_allowed_alarms=${ALLOWED_ALARMS}

[LG_Uplus][1.0] Automated_SiSo_STARTUP_CUS_Site_Reset_BTS
    [Setup]    CUS Check And Perform Template Commissioning If Needed
    ...  ${SCFC_REFERENCE_FILE_PATH}
    ...  ${LIST_OF_CUS_IPS}
    CUS Reset Site Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  get_kpi=${GET_KPI}
    ...  run_count=${SITE_RESET_COUNT}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}

[LG_Uplus][1.0] Automated_SiSo_STARTUP_CUS_Power_Reset_BTS
    [Setup]    CUS Check And Perform Template Commissioning If Needed
    ...  ${SCFC_REFERENCE_FILE_PATH}
    ...  ${LIST_OF_CUS_IPS}
    CUS BTS Power Reset Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  run_count=${POWER_RESET_COUNT}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}


