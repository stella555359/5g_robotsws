*** Settings ***
Documentation
...  Author: marek.oleksiewicz@nokia.com
...  Maintainer: marek.oleksiewicz@nokia.com

Library    BuiltIn

Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../resources/Robot/aic_test_cases.robot
Resource    ../../resources/Robot/aic_test_cases_loop.robot
Resource    ../../TestCases/PM/Cloud_PM_Activation_Deactivation_Of_Energy_Consumption_Measurement.robot
Resource    ../../TestCases/REC/Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Power_Reset_Recovery_Action.robot
Resource    ../../TestCases/REC/Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Returning_By_One_Cell_Unblock.robot
Resource    ../../TestCases/REC/Cloud_REC_Sync_Source_Switch_Over_From_Primary_To_Secondary.robot


Suite Setup       AiC Suite Setup
Suite Teardown    AiC Suite Teardown  get_logs=True

*** Variables ***
${VCU_SCF_PATH}     ${CURDIR}/SCF/vCU/25R1/vCU_25R1.xml
${VDU_SCF_PATH}     ${CURDIR}/SCF/vDU/25R1/vDU_25R1.xml

${VDU_URL}    https://10.44.192.241/
${vDU_OAM_password}  Nokia@123
${TEST_RUN_COUNT}=      10
${TEST_RUN_COUNT_2}=    1
@{RMOD_SN_LIST}=  DH243126323  DH243126322  DH243126335  1M201202406  L1223508298  L1223508299  L1242806533
                ...    L1242806531    L1242806539

*** Test Cases ***
#[CB007065][1.0] TC Entering Deep Sleep Mode And Returning By One Cell Unblock DH243126323
#    [Setup]  AiC Test Setup
#    TC__Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Returning_By_One_Cell_Unblock
#    ...  rmod_sn=DH243126323
#    ...  scfc_file_path=${VDU_SCF_PATH}
#
#[CB007065][1.0] TC Entering Deep Sleep Mode And Returning By One Cell Unblock DH243126322
#    [Setup]  AiC Test Setup
#    TC__Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Returning_By_One_Cell_Unblock
#    ...  rmod_sn=DH243126322
#    ...  scfc_file_path=${VDU_SCF_PATH}
#
#[CB007065][1.0] TC Entering Deep Sleep Mode And Returning By One Cell Unblock DH243126335
#    [Setup]  AiC Test Setup
#    TC__Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Returning_By_One_Cell_Unblock
#    ...  rmod_sn=DH243126335
#    ...  scfc_file_path=${VDU_SCF_PATH}
#
#[CB007065][1.0] TC Entering Deep Sleep Mode And Returning By One Cell Unblock 1M201202406
#    [Setup]  AiC Test Setup
#    TC__Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Returning_By_One_Cell_Unblock
#    ...  rmod_sn=1M201202406
#    ...  scfc_file_path=${VDU_SCF_PATH}
#
#[CB007065][1.0] TC Entering Deep Sleep Mode And Returning By One Cell Unblock L1223508298
#    [Setup]  AiC Test Setup
#    TC__Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Returning_By_One_Cell_Unblock
#    ...  rmod_sn=L1223508298
#    ...  scfc_file_path=${VDU_SCF_PATH}
#
#[CB007065][1.0] TC Entering Deep Sleep Mode And Returning By One Cell Unblock L1223508299
#    [Setup]  AiC Test Setup
#    TC__Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Returning_By_One_Cell_Unblock
#    ...  rmod_sn=L1223508299
#    ...  scfc_file_path=${VDU_SCF_PATH}
#
#[CB007065][1.0] TC Entering Deep Sleep Mode And Returning By One Cell Unblock L1242806533
#    [Setup]  AiC Test Setup
#    TC__Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Returning_By_One_Cell_Unblock
#    ...  rmod_sn=L1242806533
#    ...  scfc_file_path=${VDU_SCF_PATH}
#
#[CB007065][1.0] TC Entering Deep Sleep Mode And Returning By One Cell Unblock L1242806531
#    [Setup]  AiC Test Setup
#    TC__Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Returning_By_One_Cell_Unblock
#    ...  rmod_sn=L1242806531
#    ...  scfc_file_path=${VDU_SCF_PATH}
#
#[CB007065][1.0] TC Entering Deep Sleep Mode And Returning By One Cell Unblock L1242806539
#    [Setup]  AiC Test Setup
#    TC__Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Returning_By_One_Cell_Unblock
#    ...  rmod_sn=L1242806539
#    ...  scfc_file_path=${VDU_SCF_PATH}

[CB007065][1.0] TC Entering Deep Sleep Mode And Returning By One Cell Unblock
    [Setup]  AiC Test Setup
    TC__Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Returning_By_One_Cell_Unblock
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  rmod_sn_list=${RMOD_SN_LIST}

[CB007065][1.0] Automated_AiC_RU_Entering_Deep_Sleep_Mode_And_Power_Reset_Recovery_Action
    [Setup]  AiC Test Setup
    TC__Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Power_Reset_Recovery_Action
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  rmod_sn_list=${RMOD_SN_LIST}

[CB007065][1.0] TC_Activation_Deactivation_Of_Energy_Consumption_Measurement
    [Setup]  AiC Test Setup
    TC__Cloud_PM_Activation_Deactivation_Of_Energy_Consumption_Measurement
    ...  rmod_sn_list=${RMOD_SN_LIST}
    ...  scfc_file_path=${VDU_SCF_PATH}


