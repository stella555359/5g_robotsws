*** Settings ***
Documentation    responsible tester: katarzyna.zacharuk@nokia.com
...              Emirates 6c6816ff82cdade1 ABIA+ABIP (master)
...		 Vodafone 4a5a7069090f5399 ABIO (master)
...              Telefonica 76bfd733592e0c68 ABIQ (slave)
...              Globe 700e5347c721e950 ABIA (slave)

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ../../resources/test_cases_loop.robot
Resource    ./variables.robot

##Force Tags        CLOUD_MAPO_BQQA_RH_4CUS  CA_GVe   SBTS00    RAN_4G    RAN_4G_FDD    CRT

Suite Setup       CUS Setup Test Set   ${SCFC_REFERENCE_FILE_PATH}
#Suite Setup       CUS Setup Test Set Without Reset Configuration   ${SCFC_REFERENCE_FILE_PATH}    log_steps=True
Suite Teardown    CUS Teardown Test Set

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=        	${CURDIR}/config/SCFC_COMBO_WO_Slim.xml
${BIG_CONFIG_PATH}=			CUS/MAPO_BQQA_RH_4CUS_Emirates_Vodafone_Globe_Telefonica/SCFC_COMBO_WO_Slim.xml
${CUSINI_FILE_PATH}=                	${CURDIR}/config/cus_COMBO.ini
${EPCSIM_FILE_PATH}=                	${CURDIR}/config/epc.lua
${CONFIGURATION_NAME}=                  4_customer_COMBO
@{LCR_ID_CELL_BLOCK_LIST_1}=		7  8  13  14  16  17  18  19  20  21  22  23  24  25  26  27  28  29  31  32  33  34  35
@{LCR_ID_CELL_BLOCK_LIST_2}=            36  37  38  39  40  41  50  133  143  221  222  223
@{LCR_ID_CELL_BLOCK_LIST}= 		@{LCR_ID_CELL_BLOCK_LIST_1}  @{LCR_ID_CELL_BLOCK_LIST_2}
${BASIC_CALL}=                          True
${POWER_RESET_COUNT}=               	10
${SITE_RUN_COUNT}=                      10
${RMOD_RESET_COUNT}=                    3
${RAT_RESET_COUNT}=                     10
@{RMOD_LIST}=                           SELECT  EA203457037  K9223911551  6Q190823734  6Q184708204
${RAT_TYPE_1}=                          LTE
${RAT_RESET_TIMEOUT}=                   600
${VERIFY_CHANGES}=                      False
${CA_SUPPORTED_BANDS_1}= 		1:a:a+3:a:a+3::a|3:a:a+1:a:a+3::a|3:a:a+3:a:a+1::a|1:a:a+3:a:a+41::a|1:a:a+3:a:a+41::c|
${CA_SUPPORTED_BANDS_2}= 		3:a:a+1:a:a+41::a|3:a:a+1:a:a+41::c|3:a:a+1:a:a|1:a:a+3:a:a|3:a:a+3:a:a|1:a:a+41:a:a|
${CA_SUPPORTED_BANDS_3}= 		3:a:a+41:a:a|3:a:a+41::c|41:a:a+41:a:a|40:a:a+40:a:a|3:a:a+20:a:a
${CA_SUPPORTED_BANDS}= 			${CA_SUPPORTED_BANDS_1}${CA_SUPPORTED_BANDS_2}${CA_SUPPORTED_BANDS_3}
${SUPPORTED_BANDS}=			1:false,3:false,8:false,20:false,40:false,41:false
${collect_single_loop_logs}=            True
${get_kpi}=                             True
${SKIP_TRUCK_ROLL}

*** Test Cases ***
[COMBO_HYBRID][1.0] Automated_SiSo_CM_CUS_Template_Commissioning
    CUS Template Commissioning
    ...    scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...    list_of_cus_ips=${LIST_OF_IPHY_IPS}
    ...    hw_configuration=${CONFIGURATION_NAME}
    ...    allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    [Teardown]    CUS Teardown Test Case
    ...    logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...    teardown_allowed_alarms=${ALLOWED_ALARMS}

[COMBO_HYBRID][1.0] Automated_SiSo_STARTUP_CUS_Power_Reset_BTS
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

[COMBO_HYBRID][1.0] Automated_SiSo_REC_RU_Reset
    [Setup]  CUS Check And Perform Template Commissioning If Needed
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    CUS Radio Module Reset Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  rmod_sn_list=${RMOD_LIST}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  get_kpi=${GET_KPI}
    ...  run_count=${RMOD_RESET_COUNT}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    ...  logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...  teardown_allowed_alarms=${ALLOWED_ALARMS}

[COMBO_HYBRID][1.0] Automated_SiSo_CM_CUS_BTS_Rat_Reset
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
    ...  teardown_allowed_alarms=${ALLOWED_ALARMS}

[COMBO_HYBRID][1.0] Automated_SiSo_CALL_LTE_CUS_Cells_Block_and_Unblock_with_Basic_Call
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

[COMBO_HYBRID][1.0] Automated_SiSo_STARTUP_CUS_Site_Reset_BTS
    [Setup]  CUS Check And Perform Template Commissioning If Needed
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_IPHY_IPS}
    CUS Reset Site Loop Execution
    ...  scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...  list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...  get_kpi=${GET_KPI}
    ...  run_count=${SITE_RUN_COUNT}
    ...  hw_configuration=${CONFIGURATION_NAME}
    ...  allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    [Timeout]    10h