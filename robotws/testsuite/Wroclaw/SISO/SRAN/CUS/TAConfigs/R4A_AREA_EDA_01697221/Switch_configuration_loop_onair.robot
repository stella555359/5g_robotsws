*** Settings ***
Documentation    responsible tester: slawomir.jastrzebski@nokia.com

Library     Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases_loop.robot
Resource    ../../resources/test_cases.robot
Resource    ./variables.robot

#Force Tags        CLOUD_R4A_CUS   CA_GVe    SBTS00   CRT   RAN_4G    RAN_4G_FDD

Suite Setup       CUS Setup Test Set Without Reset Configuration  ${SCFC_REFERENCE_FILE_PATH}
Suite Teardown    CUS Teardown Test Set

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=            ${CURDIR}/config/SCFC_SBTS00_CUS_IQC_dual.xml
${SCFC_REFERENCE_FILE_PATH_2}=          ${CURDIR}/config/SCFC_SBTS00_CUS_IQC_single.xml
${SCFC_REFERENCE_FILE_PATH_3}=          ${CURDIR}/config/SCFC_SBTS00_CUS_IQC_none.xml
@{SCFC_FILE_PATH_LIST}=                 ${SCFC_REFERENCE_FILE_PATH}  ${SCFC_REFERENCE_FILE_PATH_2}  ${SCFC_REFERENCE_FILE_PATH_3}
${JSON_DELTA_FILE}                      ${CURDIR}/config/delta_file.json
${JSON_DELTA_FILE_1}=                   ${CURDIR}/config/IQC_none_to_dual.json
${JSON_DELTA_FILE_2}=                   ${CURDIR}/config/IQC_dual_to_single.json
${JSON_DELTA_FILE_3}=                   ${CURDIR}/config/IQC_single_to_none.json
@{JSON_DELTA_FILE_LIST}=                ${JSON_DELTA_FILE_2}  ${JSON_DELTA_FILE_3}  ${JSON_DELTA_FILE_1}
${CUSINI_FILE_PATH}=                    ${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                    ${CONFIG_DIR}/epc.lua
${CONFIGURATION_NAME}=                  CLOUD_R4A_CUS_EDA_01697221
${BASIC_CALL}=                          True
@{LCR_ID_CELL_BLOCK_LIST}=              ALL
#@{LCR_ID_CELL_BLOCK_LIST}=              2  3
#@{LCR_ID_CELL_BLOCK_LIST}=              RANDOM  3
${POWER_RESET_COUNT}=                   1
${GET_KPI}=                             True
#@{RMOD_LIST}=                           ALL
#@{RMOD_LIST}=                           RANDOM  1
@{RMOD_LIST}=                           SELECT  CUS001001C7
#${TARGET_SOFTWARE}=                     SBTS00_ENB_9999_231106_000009
#${TARGET_SOFTWARE}=                     SBTS00_ENB_9999_231105_000007
${TARGET_SOFTWARE}=                     SBTS00_ENB_9999_231109_000007
#${TARGET_SOFTWARE}=                      SBTS23R2_ENB_0000_001395_000000
#${SKIP_TRUCK_ROLL}
@{BBMOD_SN}=                             SELECT  L1170320033
${TEST_RUN_COUNT}=                       3


*** Test Cases ***
[1][1.0] Automated_SiSo_STARTUP_CUS_BTS_Reach_Onair_After_Commissioning
    CUS BTS Reach Onair After Commissioning
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    [Teardown]  CUS Teardown Test Case
    ...  logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...  teardown_allowed_alarms=${ALLOWED_ALARMS}

#[1][1.0] Automated_SiSo_STARTUP_CUS_Site_Reset_BTS
#    CUS Reset Site Loop Execution
#    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
#    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
#    ...  get_kpi=${GET_KPI}
#    ...  run_count=${TEST_RUN_COUNT}
#    ...  hw_configuration=${CONFIGURATION_NAME}
#    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
#    ...  collect_test_case_syslog=False

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
