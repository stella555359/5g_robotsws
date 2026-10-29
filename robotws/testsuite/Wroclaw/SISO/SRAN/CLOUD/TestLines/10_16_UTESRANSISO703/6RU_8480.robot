*** Settings ***
Documentation  To be done
...  Author: wojciech.bodzek@nokia.com
...  Maintainer: wojciech.bodzek@nokia.com

Library    BuiltIn

Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../resources/Robot/aic_test_cases.robot
Resource    ../../resources/Robot/aic_test_cases_loop.robot
Resource    ../../TestCases/TEST/Cloud_TEST_Online_RF_Scanning.robot
Resource    ../../TestCases/PM/Cloud_PM_MicroDTX_Activation_Verification.robot
Resource    ../../TestCases/STARTUP/Cloud_STARTUP_Rannic_Reset.robot
Resource    ../../TestCases/SWM/Cloud_SWM_vDU_Update.robot

Suite Setup       AiC Suite Setup
Suite Teardown    AiC Suite Teardown    get_logs=False

*** Variables ***
${VCU_SCF_PATH}     ${CURDIR}/SCF/vCU/6RU_vCU_8480.xml
${VDU_SCF_PATH}     ${CURDIR}/SCF/vDU/6RU_vDU_8480.xml
${FHGW_IP}=          10.42.185.164
${FHGW_USERNAME}=    toor4nsn
${FHGW_PASSWORD}=    Fhgw@nokia1243
${FHGW_PORT}=        22
${TEST_RUN_COUNT}=      3
#${vDU_OAM_password}  Nokia@123
#${VDU_URL}           https://10.42.126.118/
${CELLS_YAML_PATH}  ${CURDIR}/cells.yaml
@{RMOD_SN_LIST}=    AS210713338
${CCR_LOCATION}=    wl

@{VDU_POWER_RESET_ALLOWED_HIST_ALARMS}=  faultId=10, severity=critical
...                        faultId=4589, severity=warning
...                        faultId=4523, severity=warning
...                        faultId=1806, severity=warning

@{VDU_RANNIC_RESET_ALLOWED_HIST_ALARMS}=  faultId=4405, severity=minor
...                        faultId=4298, severity=major
...                        faultId=16, severity=critical
...                        faultId=4647, severity=minor
...                        faultId=61631, severity=minor

*** Test Cases ***


[CB010648][1.0] Automated_AIC_RF_Power_Reset
    [Setup]   AiC Test Setup
    RMODs Power Reset Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}

[CB010648][1.0] Automated_AIC_vDU_reset
    [Setup]   AiC Test Setup
    vDU Reset Operation Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}

[CB013260][1.0] General_SiSo_Auto_Cloud_ MicroDTX_Activation_Verification
    [Setup]  AiC Test Setup
    TC__Cloud_PM_MicroDTX_Activation_Verification  scfc_file_path=${VDU_SCF_PATH}    rmod_sn_list=${RMOD_SN_LIST}
    [Teardown]   AiC Test Teardown

[CB013134][1.0] General_SiSo_Auto_Cloud_Rannic_Reset
    [Setup]  AiC Test Setup
    TC__Cloud_STARTUP_Rannic_Reset
    ...  scfc_file_path=${VDU_SCF_PATH}
    [Teardown]  AiC Test Teardown

[CNI-129368][1.0] General_SiSo_Auto_Cloud_vDU_Update
    [Setup]  AiC Test Setup
    TC__Cloud_SWM_vDU_Update
    ...  scfc_file_path=${VDU_SCF_PATH}
    [Teardown]   AiC Test Teardown
