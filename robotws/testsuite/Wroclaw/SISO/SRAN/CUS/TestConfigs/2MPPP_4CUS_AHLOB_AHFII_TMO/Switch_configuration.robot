*** Settings ***
Documentation    responsible tester: katarzyna.zacharuk@nokia.com
...              TMO 32cc2a52ae99a13a (7747a2026cdf3da4) 2xASIM+4xABIP

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ../../resources/test_cases_loop.robot
Resource    ./variables.robot

##Force Tags        CLOUD_2MPPP_4CUS  CA_GVe   SBTS00    RAN_4G    RAN_4G_FDD    CRT

Suite Setup       CUS Setup Test Set   ${SCFC_REFERENCE_FILE_PATH}
#Suite Setup       CUS Setup Test Set Without Reset Configuration   ${SCFC_REFERENCE_FILE_PATH}    log_steps=True
Suite Teardown    CUS Teardown Test Set

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=            ${CURDIR}/config/SCFC.xml
${BIG_CONFIG_PATH}=			CUS/2MPPP_4CUS_AHLOB_AHFII_TMO/SCFC_SBTS00_60_20W.xml
${CUSINI_FILE_PATH}=                	${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                	${CURDIR}/config/epc.lua
${CONFIGURATION_NAME}=                  TMO_US
@{LCR_ID_CELL_BLOCK_LIST}=              ALL
${BASIC_CALL}=                          True
${POWER_RESET_COUNT}=               	15
${SITE_RUN_COUNT}=                      15
${RAT_RESET_COUNT}=                     15
${CA_SUPPORTED_BANDS}=			2:a:a+4::a+12::a|4:a:a+2::a+12::a|12:a:a+2::a+4::a
${SUPPORTED_BANDS}=			2:false,4:false,12:false
${RAT_TYPE_1}=                          LTE
${RAT_RESET_TIMEOUT}=                   900
${VERIFY_CHANGES}=                      False
${collect_single_loop_logs}=            True
${get_kpi}=                             True
@{SWCONFIG_FLAGS}=                      0x360000=3 #enables FDSW/SWIM debug logs
                                        ...  0x5801cb = 0 #disable fake UE reading
${SKIP_TRUCK_ROLL}

*** Test Cases ***
[TMO_2MPP][1.0] Automated_SiSo_CM_CUS_Template_Commissioning
    CUS Template Commissioning
    ...    scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...    list_of_cus_ips=${LIST_OF_IPHY_IPS}
    ...    hw_configuration=${CONFIGURATION_NAME}
    ...    allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    [Teardown]    CUS Teardown Test Case
    ...    logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...    teardown_allowed_alarms=${ALLOWED_ALARMS}

[TMO_2MPP][1.0] Automated_SiSo_STARTUP_CUS_Power_Reset_BTS
    [Setup]  CUS Check And Perform Template Commissioning If Needed
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    CUS BTS Power Reset Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  get_kpi=${GET_KPI}
    ...  run_count=${POWER_RESET_COUNT}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}

[TMO_2MPP][1.0] Automated_SiSo_CM_CUS_BTS_Rat_Reset
    [Setup]  CUS Check And Perform Template Commissioning If Needed
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    CUS BTS Rat Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  rat_type=${RAT_TYPE_1}
    ...  rat_reset_timeout=${RAT_RESET_TIMEOUT}
    ...  verify_changes=${VERIFY_CHANGES}
    ...  run_count=${RAT_RESET_COUNT}
    ...  get_kpi=${GET_KPI}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    ...  logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...  teardown_allowed_alarms=${ALLOWED_ALARMS_NSA_RAT}

[TMO_2MPP][1.0] Automated_SiSo_CALL_LTE_CUS_Cells_Block_and_Unblock_with_Basic_Call
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
