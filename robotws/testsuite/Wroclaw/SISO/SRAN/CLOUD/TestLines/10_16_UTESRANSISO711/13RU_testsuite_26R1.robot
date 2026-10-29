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
Resource    ../../TestCases/REC/Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Returning_By_One_Cell_Unblock.robot
Resource    ../../TestCases/PM/Cloud_PM_Enable_Disable_Energy_Optimized_Mode.robot

Suite Setup       AiC Suite Setup
Suite Teardown    AiC Suite Teardown  get_logs=True

*** Variables ***
${VCU_SCF_PATH}     ${CURDIR}/SCF/vCU/26R1/vCU_26R1.xml
${VDU_SCF_PATH}     ${CURDIR}/SCF/vDU/26R1/vDU_26R1.xml

${VDU_URL}    https://10.44.192.241/
${vDU_OAM_password}  Nokia@123
${TEST_RUN_COUNT}=      1
${TEST_RUN_COUNT_2}=    1
@{RMOD_SN_LIST}=  DH243126323  DH243126322  DH243126335  1M201202406  L1223508298  L1223508299  L1242806533
                ...    L1242806531    L1242806539

@{RMOD_SN_LIST_O}=  K9242639679

*** Test Cases ***
[CB013232][1.0] Automated_AIC_vDU_reset
    [Setup]   AiC Test Setup
    vDU Reset Operation Loop Execution
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  run_count=${TEST_RUN_COUNT_2}
    [Teardown]   AiC Test Teardown

[CB007065][1.0] TC Entering Deep Sleep Mode And Returning By One Cell Unblock
    [Setup]  AiC Test Setup
    TC__Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Returning_By_One_Cell_Unblock
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  rmod_sn_list=${RMOD_SN_LIST}
    [Teardown]   AiC Test Teardown

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

[CB014375][1.0] General_SiSo_Auto_Cloud_Enable_Disable_Energy_Optimized_Mode
    [Setup]  AiC Test Setup
    TC__Cloud_PM_Enable_Disable_Energy_Optimized_Mode
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  cbts_rmod_sn_list=${RMOD_SN_LIST_O}
    ...  verify_power=${False}
    [Teardown]  AiC Test Teardown
