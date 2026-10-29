*** Settings ***
Documentation  To be done
...  Author: wojciech.bodzek@nokia.com
...  Maintainer: wojciech.bodzek@nokia.com

Library    BuiltIn

Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../resources/Robot/aic_test_cases.robot
Resource    ../../resources/Robot/aic_test_cases_loop.robot
#Resource    ../../TestCases/LOGS/Cloud_LOGS_BlackBox_enhancements_testing.robot
#Resource    ../../TestCases/LOGS/Cloud_LOGS_BlackBox_enhancements_testing_resets_faults_and_clear.robot
#Resource    ../../TestCases/LOGS/Cloud_LOGS_BlackBox_enhancement_of_radio_SW_version_and_firmware_version.robot
Resource    ../../TestCases/TEST/Cloud_TEST_Online_RF_Scanning.robot
Resource    ../../TestCases/PM/Cloud_PM_MicroDTX_Activation_Verification.robot

Suite Setup       AiC Suite Setup
Suite Teardown    AiC Suite Teardown    get_logs=False

*** Variables ***
${VCU_SCF_PATH}     ${CURDIR}/SCF/vCU/25R2_scfc_cu.xml
${VDU_SCF_PATH}     ${CURDIR}/SCF/vDU/25R2_scfc_du.xml
${FHGW_IP}=          10.42.185.164
${FHGW_USERNAME}=    toor4nsn
${FHGW_PASSWORD}=    Fhgw@nokia1243
${FHGW_PORT}=        22
${TEST_RUN_COUNT}=      1
${TEST_RUN_COUNT_2}=      1
#${vDU_OAM_password}  Nokia@123
#${VDU_URL}           https://10.42.126.118/
${CELLS_YAML_PATH}  ${CURDIR}/cells.yaml
@{RMOD_SN_LIST}=    AS210713338

*** Test Cases ***

[AHPMDG][1.0] Automated_AIC_online_RF_Scanning
    [Setup]  AiC Test Setup
    TC__Cloud_TEST_Online_RF_Scanning   scfc_file_path=${VDU_SCF_PATH}    rmod_sn=BL2331C62X6
    [Teardown]   AiC Test Teardown

[CB010648][1.0] Automated_AIC_RF_Power_Reset
    [Setup]   AiC Test Setup
    RMODs Power Reset Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}

[CB010648][1.0] Automated_AIC_RF_Module_lock_unlock
    [Setup]  AiC Test Setup
    RMOD Lock Unlock And Check Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}

[CB010648][1.0] Automated_AIC_vDU_reset
    [Setup]   AiC Test Setup
    vDU Reset Operation Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}



