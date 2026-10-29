*** Settings ***
Documentation    Suite documentation
...  Author: marek.oleksiewicz@nokia.com
...  Maintainer: marek.oleksiewicz@nokia.com

Library    BuiltIn

Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../resources/Robot/aic_test_cases.robot
Resource    ../../resources/Robot/aic_test_cases_loop.robot
Resource    ../../TestCases/PM/Cloud_PM_Activation_Deactivation_Of_Energy_Consumption_Measurement.robot
Resource    ../../TestCases/REC/Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Power_Reset_Recovery_Action.robot

Suite Setup       AiC Suite Setup
Suite Teardown    AiC Suite Teardown  get_logs=True

*** Variables ***
${VCU_SCF_PATH}     ${CURDIR}/SCF/vCU/25R3/vCU_25R3.xml
${VDU_SCF_PATH}     ${CURDIR}/SCF/vDU/25R3/vDU_25R3.xml
${VDU_DELTA_FILE_PATH}  ${CURDIR}/SCF/delta_1.json


${VDU_URL}    https://10.44.192.241/
${vDU_OAM_password}  Nokia@123
${TEST_RUN_COUNT}=      1
@{RMOD_SN_LIST}=  DH243126323  DH243126322  DH243126335  1M201202406  L1223508298  L1223508299  L1242806533
                ...    L1242806531    L1242806539

*** Test Cases ***
[CB013232][1.0] Automated_AIC_vDU_reset
    [Setup]   AiC Test Setup
    vDU Reset Operation Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}
    [Teardown]   AiC Test Teardown

[CB013232[1.0] Automated_AIC_RF_Power_Reset
    [Setup]   AiC Test Setup
    RMODs Power Reset Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT}

[CB007065][1.0] Automated_AiC_RU_Entering_Deep_Sleep_Mode_And_Power_Reset_Recovery_Action
    [Setup]  AiC Test Setup
    TC__Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Power_Reset_Recovery_Action
    ...    scfc_file_path=${VDU_SCF_PATH}  rmod_sn_list=${RMOD_SN_LIST}
    [Teardown]   AiC Test Teardown

[CB007065][1.0] TC_Activation_Deactivation_Of_Energy_Consumption_Measurement
    [Setup]  AiC Test Setup
    TC__Cloud_PM_Activation_Deactivation_Of_Energy_Consumption_Measurement
    ...  rmod_sn_list=${RMOD_SN_LIST}
    ...  scfc_file_path=${VDU_SCF_PATH}
    [Teardown]   AiC Test Teardown

[CB013232][1.0] Automated_AIC_vDU_delta_recommissioning
   [Setup]  AiC Test Setup
    TC__Cloud_vDU_Delta_Recommissioning
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  delta_file_path=${VDU_DELTA_FILE_PATH}
    [Teardown]  AiC Test Teardown

