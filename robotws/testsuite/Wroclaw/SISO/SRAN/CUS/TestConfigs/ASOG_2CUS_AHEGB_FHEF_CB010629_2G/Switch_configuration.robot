*** Settings ***
Documentation    responsible tester: katarzyna.zacharuk@nokia.com
...		         ASOG CB010629 B3
...              CB010629-SR-B Enhanced IQ routing configurations
...              https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-42720
...              Reset configuration not yet supported. LE:22.10.2024

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ../../resources/test_cases_loop.robot
Resource    ./variables.robot

#Force Tags        CLOUD_ASOG_2CUS   CA_GVe   SBTS00   RAN_4G    RAN_4G_FDD    CRT

Suite Setup       CUS Setup Test Set Without Reset Configuration    ${SCFC_REFERENCE_FILE_PATH}
Suite Teardown    CUS Teardown Test Set

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=            ${CURDIR}/config/SCFC_SBTS00_CUS.xml
${CUSINI_FILE_PATH}=                	${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                	${CURDIR}/config/epc.lua
${CONFIGURATION_NAME}=              	ASOG_MIX_2G_3G
@{LCR_ID_CELL_BLOCK_LIST}=              ALL
${BASIC_CALL}=                          True
${SITE_RUN_COUNT}=                      1
${IQR_Run_Count}=                       6
${collect_single_loop_logs}=            True
${get_kpi}=                             False
${SKIP_TRUCK_ROLL}
@{SWCONFIG_FLAGS}=                      0x360000=3 #enables FDSW/SWIM debug logs
                                        ...  0x980007=1 #ASOG and ASOH ver. 101 Wi-Fi feature disable

*** Test Cases ***
[CB010629][1.0] Automated_SiSo_CM_CUS_Template_Commissioning
    CUS Template Commissioning
    ...    scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...    list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...    hw_configuration=${CONFIGURATION_NAME}
    ...    allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    [Teardown]    CUS Teardown Test Case
    ...    logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...    teardown_allowed_alarms=${ALLOWED_ALARMS}

[CB010629][2.0] Automated_SiSo_CM_CUS_BTS_IQRouting_Runtime_Change
    [Setup]  CUS Check And Perform Template Commissioning If Needed
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    CUS BTS IQRouting Runtime Change Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  run_count=${IQR_Run_Count}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_IQR}

[CB010629][1.0] Automated_SiSo_STARTUP_CUS_Site_Reset_BTS
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

[CB010629][1.0] Automated_SiSo_CALL_LTE_CUS_Cells_Block_and_Unblock_with_Basic_Call
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
