*** Settings ***
Documentation    responsible tester: slawomir.jastrzebski@nokia.com

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ./variables.robot

#Force Tags        CLOUD_R4BN9_CUS     CA_GVe   SBTS00     CRT   RAN_4G    RAN_4G_FDD

Suite Setup       CUS Setup Test Set Without Reset Configuration    ${SCFC_REFERENCE_FILE_PATH}
Suite Teardown    CUS Teardown Test Set

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
${RMOD_LIST}=                       RANDOM  2

*** Test Cases ***
Automated_SiSo_STARTUP_CUS_BTS_Reach_Onair_After_Commissioning
    CUS BTS Reach Onair After Commissioning
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    [Teardown]  CUS Teardown Test Case
    ...  logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...  teardown_allowed_alarms=${ALLOWED_ALARMS}

#Automated_SiSo_CM_CUS_Delta_Commissioning
#    CUS Delta Recommissioning
#    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
#    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
#    ...  json_delta_file=${JSON_DELTA_FILE}
#    ...  hw_configuration=${CONFIGURATION_NAME}
#    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
#    [Teardown]  CUS Teardown Test Case
#    ...  logs_dir_path=${SUITE_LOGS_DIR_PATH}
#    ...  teardown_allowed_alarms=${ALLOWED_ALARMS}

#Automated_SiSo_CALL_LTE_CUS_Basic_Call
#    CUS Basic Call When Onair Reached
#    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
#    ...  hw_configuration=${CONFIGURATION_NAME}
#    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
#    [Teardown]  CUS Teardown Test Case
#    ...  logs_dir_path=${SUITE_LOGS_DIR_PATH}
#    ...  teardown_allowed_alarms=${ALLOWED_ALARMS_ONAIR}

#Automated_SiSo_CALL_LTE_CUS_Cells_Block_and_Unblock_with_Basic_Call
#    CUS Cell Block Unblock And Call
#    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
#    ...  lcr_id_block_list=${LCR_ID_CELL_BLOCK_LIST}
#    ...  basic_call=${BASIC_CALL}
#    ...  hw_configuration=${CONFIGURATION_NAME}
#    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
#    [Teardown]  CUS Teardown Test Case
#    ...  logs_dir_path=${SUITE_LOGS_DIR_PATH}
#    ...  teardown_allowed_alarms=${ALLOWED_ALARMS_BLOCK_UNBLOCK}

Automated_SiSo_STARTUP_CUS_Power_Reset_BTS
    CUS BTS Power Reset
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  get_kpi=${True}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    [Teardown]  CUS Teardown Test Case
    ...  logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...  teardown_allowed_alarms=${ALLOWED_ALARMS_ONAIR}

#Automated_SiSo_STARTUP_CUS_Radio_Module_Reset
#    CUS Radio Module Reset
#    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
#    ...  rmod_sn_list=${RMOD_LIST}
#    ...  get_kpi=${GET_KPI}
#    ...  hw_configuration=${CONFIGURATION_NAME}
#    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
#    [Teardown]  CUS Teardown Test Case
#    ...  logs_dir_path=${SUITE_LOGS_DIR_PATH}
#    ...  teardown_allowed_alarms=${ALLOWED_ALARMS_ONAIR}

#Automated_SiSo_STARTUP_CUS_Site_Reset_BTS
#    CUS Reset Site
#    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
#    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
#    ...  get_kpi=${GET_KPI}
#    ...  hw_configuration=${CONFIGURATION_NAME}
#    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
#    [Teardown]  CUS Teardown Test Case
#    ...  logs_dir_path=${SUITE_LOGS_DIR_PATH}
#    ...  teardown_allowed_alarms=${ALLOWED_ALARMS}

#Automated_SiSo_STARTUP_CUS_Baseband_Module_Reset
#    CUS Baseband Module Reset
#    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
#    ...  bbmod_sn_list=${BBMOD_SN}
#    ...  get_kpi=${GET_KPI}
#    ...  hw_configuration=${CONFIGURATION_NAME}
#    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
#    [Teardown]  CUS Teardown Test Case
#    ...  logs_dir_path=${SUITE_LOGS_DIR_PATH}
#    ...  teardown_allowed_alarms=${ALLOWED_ALARMS}

#Automated_SiSo_STARTUP_CUS_BTS_Lte_Rat_Reset
#    CUS BTS Rat Reset
#    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
#    ...  rat_type=LTE
#    ...  rat_reset_timeout=600
#    ...  get_kpi=${GET_KPI}
#    ...  hw_configuration=${CONFIGURATION_NAME}
#    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
#    [Teardown]  CUS Teardown Test Case
#    ...  logs_dir_path=${SUITE_LOGS_DIR_PATH}
#    ...  teardown_allowed_alarms=${ALLOWED_ALARMS}
