*** Settings ***
Documentation    responsible tester: slawomir.jastrzebski@nokia.com

Library     Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases_loop.robot
Resource    ../../resources/test_cases.robot
Resource    ./variables.robot

#Force Tags        CLOUD_R4A_CUS   CA_GVe    SBTS00   CRT   RAN_4G    RAN_4G_FDD

Suite Setup       CUS Setup Test Set Without Reset Configuration
                  ...  scfc_default_file_path=${SCFC_REFERENCE_FILE_PATH}
Suite Teardown    CUS Teardown Test Set
                  ...  collect_test_suite_syslog=${True}

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=        ${CURDIR}/config/SCFC.xml
${CUSINI_FILE_PATH}=                ${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                ${CURDIR}/config/epc.lua
${CONFIGURATION_NAME}=              CLOUD_R4BO9_CUS
@{LCR_ID_CELL_BLOCK_LIST}=          ALL
${BASIC_CALL}=                      True
${CA_SUPPORTED_BANDS}=              1:a:a+3:a:a|3:a:a+1:a:a
${SUPPORTED_BANDS}=                 1:false,3:false
${JSON_DELTA_FILE}                  ${CURDIR}/config/delta_file.json
${POWER_RESET_COUNT}=               3
${GET_KPI}=                         True
${BBMOD_SN}=                        ALL
${RAT_IMPACT}=                      NONE
${TEST_RUN_COUNT}=                  3


*** Test Cases ***
[1][1.0] Automated_SiSo_STARTUP_CUS_BTS_Reach_Onair_After_Commissioning
    CUS BTS Reach Onair After Commissioning
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    [Teardown]  CUS Teardown Test Case
    ...  logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...  teardown_allowed_alarms=${ALLOWED_ALARMS}

[1][1.0] Automated_SiSo_STARTUP_CUS_Site_Reset_BTS
    CUS Reset Site Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  get_kpi=${GET_KPI}
    ...  run_count=${TEST_RUN_COUNT}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    ...  collect_test_case_syslog=${True}

#[1][1.0] Automated_SiSo_STARTUP_CUS_BTS_Power_Reset
#    CUS BTS Power Reset Loop Execution
#    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
#    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
#    ...  get_kpi=${GET_KPI}
#    ...  run_count=${TEST_RUN_COUNT}
#    ...  hw_configuration=${CONFIGURATION_NAME}
#    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
#    ...  collect_test_case_syslog=False

#[1][1.0] Automated_SiSo_STARTUP_CUS_Radio_Module_Reset
#    CUS Radio Module Reset Loop Execution
#    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
#    ...  rmod_sn_list=${RMOD_LIST}
#    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
#    ...  get_kpi=${GET_KPI}
#    ...  run_count=${TEST_RUN_COUNT}
#    ...  hw_configuration=${CONFIGURATION_NAME}
#    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
#    ...  collect_test_case_syslog=True

#[1][1.0] Automated_SiSo_STARTUP_CUS_Baseband_Module_Reset
#    CUS Baseband Module Reset Loop Execution
#    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
#    ...  bbmod_sn_list=${BBMOD_SN}
#    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
#    ...  get_kpi=${GET_KPI}
#    ...  run_count=${TEST_RUN_COUNT}
#    ...  hw_configuration=${CONFIGURATION_NAME}
#    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
#    ...  collect_test_case_syslog=True

#[1][1.0] Automated_SiSo_STARTUP_CUS BTS Rat Reset
#    CUS BTS Rat Loop Execution
#    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
#    ...  rat_type=LTE
#    ...  rat_reset_timeout=600
#    ...  get_kpi=${GET_KPI}
#    ...  verify_changes=True
#    ...  run_count=${TEST_RUN_COUNT}
#    ...  hw_configuration=${CONFIGURATION_NAME}
#    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
#    ...  collect_test_case_syslog=True
