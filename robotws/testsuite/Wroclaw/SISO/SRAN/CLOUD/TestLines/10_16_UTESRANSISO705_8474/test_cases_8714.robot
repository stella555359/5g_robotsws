*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn

Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../TestCases/SM/Cloud_SM_Cell_Block_Unblock.robot
Resource    ../../TestCases/SM/Cloud_SM_Radio_Modules_Lock_Unlock.robot
Resource    ../../TestCases/SM/Cloud_SM_RF_Reset_From_GUI.robot
Resource    ../../TestCases/REC/Cloud_REC_Radio_Modules_Hot_Remove_Hot_Insert.robot
Resource    ../../TestCases/STARTUP/Cloud_STARTUP_Radio_Modules_Power_Reset.robot
Resource    ../../TestCases/STARTUP/Cloud_STARTUP_vDU_Reset.robot
Resource    ../../TestCases/STARTUP/Cloud_STARTUP_vCU_Reset.robot
Resource    ../../TestCases/CM/Cloud_CM_vDU_Commissioning.robot
Resource    ../../TestCases/CM/Cloud_CM_vDU_Delta_Recommissioning.robot
Resource    ../../TestCases/CALL/Cloud_CALL_NR_Data_Transfer.robot
Resource     ../../TestCases/PM/Cloud_PM_Activation_Deactivation_Of_Energy_Consumption_Measurement.robot
Resource     ../../TestCases/PM/Cloud_PM_Cell_Availability_Monitoring_With_Energy_Efficiency_Enhancement.robot
Resource    ../../TestCases/PM/Cloud_PM_MicroDTX_Activation_Verification.robot
Resource    ../../TestCases/PM/Cloud_PM_PIM_Alarms_Triggering.robot
Resource    ../../TestCases/PM/Cloud_PM_PIMC_Counters.robot
Resource    ../../TestCases/PM/Cloud_PM_Radio_Module_Fan_Speed_Counters_Monitoring.robot
Resource    ../../TestCases/PM/Cloud_PM_Radio_Module_Thermal_Counters_Monitoring.robot
Resource    ../../TestCases/PM/Cloud_PM_Radio_Module_Thermal_Counters_Monitoring_And_Alarm_Triggering.robot
Resource    ../../TestCases/REC/Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Power_Reset_Recovery_Action.robot
Resource    ../../TestCases/REC/Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Returning_By_One_Cell_Unblock.robot
Resource    ../../TestCases/REC/Cloud_REC_Sync_Source_Switch_Over_From_Primary_To_Secondary.robot
Resource    ../../TestCases/TEST/Cloud_TEST_Online_RF_Scanning.robot
Resource    ../../TestCases/TEST/Cloud_TEST_TDS_RF_Scanning.robot
Resource    ../../TestCases/TEST/Cloud_TEST_Start_Stop_NR_TestModels.robot
Resource    ../../TestCases/STARTUP/Cloud_STARTUP_LTE_vDU_Reset.robot
Resource    ../../TestCases/CM/Cloud_CM_LTE_vDU_Commissioning.robot

Suite Setup       AiC Suite Setup
Suite Teardown    AiC Suite Teardown  get_logs=False

*** Variables ***
${VDU_SCF_PATH}=             ${CURDIR}/SCF_8714/SCFC_vDU.xml
${VCU_SCF_PATH}=             ${CURDIR}/SCF_8714/SCFC_vCU.xml
#${VDU_DELTA_SCF_PATH}=       ${CURDIR}/SCF/Delta_SCFC_vDU_8474.xml
${DELTA_FILE_PATH}=          ${CURDIR}/SCF/SCFC_vDU_delta.json

#${RMOD_SN}=        K9181046216
@{RMOD_SN_LIST}=  K9181046216

*** Test Cases ***
[1][1.0] Automated_AIC_Cell_Block_Unblock
    [Setup]  AiC Test Setup
    TC__Cloud_SM_Cell_Block_Unblock
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  cbts_cells_id_list=${CBTS_CELL_LIST}
    [Teardown]  AiC Test Teardown
    ...  get_logs=${True}

#[1][1.0] Automated_Cell_Block_Unblock
#    TC__SBTS_SM_Cell_Block_Unblock
#    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
#    [Teardown]  SBTS Test Teardown

#[1][1.0] Automated_AIC_RF_Module_Lock_Unlock
#    [Setup]  AiC Test Setup
#    TC__Cloud_SM_Radio_Modules_Lock_Unlock
#    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
#    ...  cbts_rmods_sn=${RMOD_SN_LIST}
#    [Teardown]  AiC Test Teardown
#    ...  get_logs=${True}

#[1][1.0] Automated_RF_Module_Lock_Unlock
#    TC__SBTS_SM_Radio_Modules_Lock_Unlock
#    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
##    [Teardown]  SBTS Teardown Test Case

#[1][1.0] Automated_AIC_Radio_Modules_Reset
#    [Setup]  AiC Test Setup
#    TC__Cloud_STARTUP_Radio_Modules_Reset
#    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
#    ...  cbts_rmod_sn_list=${RMOD_SN_LIST}
#    [Teardown]  AiC Test Teardown
#    ...  get_logs=False

#[1][1.0] Automated_Radio_Modules_Reset
#    TC__SBTS_STARTUP_Radio_Modules_Reset
#    ...  sbts_scfc_file_path=${SBTS_SCF_PATH}
#    ...  sbts_rmod_sn_list=${RMOD_SN_LIST}
#    ...  get_kpi=${True}
#    [Teardown]  SBTS Teardown Test Case
