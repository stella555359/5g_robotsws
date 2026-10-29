*** Settings ***
Documentation    responsible tester: artur.kaczybura@nokia.com
...              User scenario CB012322-B#2: FRGX 20MHz+10MHz 4Tx4Rx with NR+LTE operation option2

Library    Collections

Resource    ../../resources/setup_and_teardown.robot
Resource    ../../resources/test_cases.robot
Resource    ./variables.robot

##Force Tags        CLOUD_R4LAOO_2CUS  CA_GVe   SBTS00    RAN_4G    RAN_4G_FDD    CRT

Suite Setup       CUS Setup Test Set    ${SCFC_REFERENCE_FILE_PATH}
Suite Teardown    CUS Teardown Test Set

*** Variables ***
${SCFC_REFERENCE_FILE_PATH}=        	${CURDIR}/config/SCFC_SBTS24R3_CUS.xml
${CUSINI_FILE_PATH}=                	${CURDIR}/config/cus.ini
${EPCSIM_FILE_PATH}=                	${CURDIR}/config/epc.lua
${CONFIGURATION_NAME}=                  TBD
@{LCR_ID_CELL_BLOCK_LIST}=              ALL
${BASIC_CALL}=                          True
${POWER_RESET_COUNT}=               	10
${collect_single_loop_logs}=            True
${CA_SUPPORTED_BANDS}=              8:a:a+32::a
${SUPPORTED_BANDS}=                 8:false,32:false
${SKIP_TRUCK_ROLL}

*** Test Cases ***
[1][1.0] Automated_SiSo_CM_CUS_Template_Commissioning
    CUS Template Commissioning
    ...    scfc_file_path=${SCFC_REFERENCE_FILE_PATH}
    ...    list_of_cus_ips=${LIST_OF_CUS_IPS}
    ...    hw_configuration=${CONFIGURATION_NAME}
    ...    allowed_alarms=${ALLOWED_ALARMS_ONAIR}
    [Teardown]    CUS Teardown Test Case
    ...    logs_dir_path=${SUITE_LOGS_DIR_PATH}
    ...    teardown_allowed_alarms=${ALLOWED_ALARMS}

