*** Settings ***
Documentation
...  Author: slawomir.jastrzebski@nokia.com
...  Maintainer: slawomir.jastrzebski@nokia.com

Library    BuiltIn

Resource    ../../resources/Robot/setup_teardown.robot
Resource    ../../TestCases/SM/Cloud_SM_Cell_Block_Unblock.robot
Resource    ../../TestCases/SM/Cloud_SM_Radio_Modules_Lock_Unlock.robot
Resource    ../../TestCases/SM/Cloud_SM_RF_Reset_From_GUI.robot
Resource    ../../TestCases/SM/Cloud_SM_Radio_Modules_Reset.robot
Resource    ../../TestCases/REC/Cloud_REC_Radio_Modules_Hot_Remove_Hot_Insert.robot
Resource    ../../TestCases/STARTUP/Cloud_STARTUP_Radio_Modules_Power_Reset.robot
Resource    ../../TestCases/STARTUP/Cloud_STARTUP_Rannic_Reset.robot
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
Resource    ../../TestCases/PM/Cloud_PM_Enable_Disable_Energy_Optimized_Mode.robot
Resource    ../../TestCases/PM/Cloud_PM_Load_Based_Cell_Switch_Off_Energy_Efficiency.robot
Resource    ../../TestCases/PM/Cloud_PM_Power_Meter_RU_Side_Energy_Efficiency.robot
Resource    ../../TestCases/REC/Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Power_Reset_Recovery_Action.robot
Resource    ../../TestCases/REC/Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Returning_By_One_Cell_Unblock.robot
Resource    ../../TestCases/REC/Cloud_REC_Sync_Source_Switch_Over_From_Primary_To_Secondary.robot
Resource    ../../TestCases/TEST/Cloud_TEST_Online_RF_Scanning.robot
Resource    ../../TestCases/TEST/Cloud_TEST_TDS_RF_Scanning.robot
Resource    ../../TestCases/TEST/Cloud_TEST_Start_Stop_NR_TestModels.robot

Suite Setup       AiC Suite Setup
Suite Teardown    AiC Suite Teardown

*** Variables ***
# EXAMPLE VARIABLES USED IN TEST CASES.
# REMEMBER TO ALWAYS DECLARE ONLY THOSE VARIABLES THAT YOU USE IN TEST CASES.

# Configuration files
${VDU_SCF_PATH}=             ${CURDIR}/SCF/SCFC_vDU.xml
${VCU_SCF_PATH}=             ${CURDIR}/SCF/SCFC_vCU.xml

# Used with "TC__Cloud_vDU_Delta_Recommissioning"
${VDU_DELTA_FILE_PATH}=      ${CURDIR}/SCF/SCFC_vDU_delta.json

# Radio modules serial numbers list
# Used with, for example:
@{RMOD_SN_LIST}=  K9181046216  K9175116255

# Radio module serial number
# Used with, for example:
# - TC__Cloud_PM_PIMC_Counters
# - TC__Cloud_TEST_Online_RF_Scanning
${RMOD_SN}=  K9181046216

# Optical switch settings
# Used with "TC__Cloud_REC_Radio_Modules_Hot_Remove_Hot_Insert"
@{K9181046216_OFF}=      1  1  4  1  1  1
@{K9181046216_ON}=       1  1  1  1  1  1
&{SWITCH_OFF_ALL_DICT}=  K9181046216=@{K9181046216_OFF}
&{SWITCH_ON_ALL_DICT}=   K9181046216=@{K9181046216_ON}

# Cells parameters to call test case
# Used with "TC__Cloud_CALL_NR_Data_Transfer"
${CELLS_YAML_PATH}=  ${CURDIR}/cells.yaml
@{CELL_IDENTITY_LIST}=  139034627  139034629
# Used with "TC__Cloud_PM_Load_Based_Cell_Switch_Off_Energy_Efficiency"
@{CELL_ID_LIST}=  3  5

#IN THE EXAMPLE TEST SUITE IN THE TEST CASES THE MOST FREQUENTLY USED ARGUMENTS WERE SHOWN.
#IF YOU WANT TO CHECK WHAT ARGUMENTS CAN BE USED, ALWAYS CHECK THE TEST CASE DOCUMENTATION SECTION
*** Test Cases ***
# Example without logs collection when test case PASSED
[1][1.0] Automated_AIC_Cell_Block_Unblock
    [Setup]  AiC Test Setup
    TC__Cloud_SM_Cell_Block_Unblock
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  get_kpi=${True}
    [Teardown]  AiC Test Teardown
    ...  get_logs=False

# Example with always logs collection
[1][1.0] Automated_AIC_RF_Module_Lock_Unlock
    [Setup]  AiC Test Setup
    TC__Cloud_SM_Radio_Modules_Lock_Unlock
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  cbts_rmods_sn=${RMOD_SN_LIST}
    [Teardown]  AiC Test Teardown
    ...  get_logs=True

[1][1.0] Automated_AIC_RF_Reset_From_GUI
    [Setup]  AiC Test Setup
    TC__Cloud_SM_Radio_Modules_Reset_Via_GUI
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  reset_timeout=400
    ...  jwt_expiration_time=125
    [Teardown]  AiC Test Teardown

[1][1.0] General_SiSo_Auto_Cloud_Radio_Modules_Reset
    [Setup]  AiC Test Setup
    TC__Cloud_SM_Radio_Modules_Reset
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  cbts_rmod_sn_list=${RMOD_SN_LIST}
    ...  get_kpi=${True}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    [Teardown]  AiC Test Teardown
    ...  get_logs=${False}

[1][1.0] Automated_AIC_RF_Hot_Remove_Insert
    [Setup]   AiC Test Setup
    TC__Cloud_REC_Radio_Modules_Hot_Remove_Hot_Insert
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  switch_settings_off=${SWITCH_OFF_ALL_DICT}
    ...  switch_settings_on=${SWITCH_ON_ALL_DICT}
    [Teardown]  AiC Test Teardown

[1][1.0] Automated_AIC_RF_Power_Reset
    [Setup]  AiC Test Setup
    TC__Cloud_STARTUP_Radio_Modules_Power_Reset
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  rmod_sn_list=${RMOD_SN_LIST}
    [Teardown]  AiC Test Teardown

[1][1.0] General_SiSo_Auto_Cloud_Rannic_Reset
    [Setup]  AiC Test Setup
    TC__Cloud_STARTUP_Rannic_Reset
    ...  scfc_file_path=${VDU_SCF_PATH}
    [Teardown]  AiC Test Teardown

[1][1.0] Automated_AIC_vDU_Reset
    [Setup]  AiC Test Setup
    TC__Cloud_STARTUP_vDU_Reset
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    [Teardown]  AiC Test Teardown

[1][1.0] Automated_AIC_vCU_Reset
    [Setup]  AiC Test Setup
    TC__Cloud_STARTUP_vCU_Reset
    ...  vcu_scfc_file_path=${VCU_SCF_PATH}
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    ...  vcu_connection=${VCU_CONNECTION_DEFAULT}
    [Teardown]  AiC Test Teardown

[1][1.0] Automated_AIC_vDU_commissioning
    [Setup]  AiC Test Setup
    TC__Cloud_CM_vDU_Commissioning
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    [Teardown]  AiC Test Teardown

[1][1.0] Automated_AIC_vDU_Delta_Recommissioning
    [Setup]  AiC Test Setup
    TC__Cloud_vDU_Delta_Recommissioning
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  delta_file_path=${VDU_DELTA_FILE_PATH}
    [Teardown]  AiC Test Teardown

[1][1.0] Automated_AiC_CALL_NR_Data_Transfer
    [Setup]   AiC Test Setup
    TC__Cloud_CALL_NR_Data_Transfer
    ...    scfc_file_path=${VDU_SCF_PATH}
    ...    cells_yaml_path=${CELLS_YAML_PATH}
    ...    cell_ids=@{CELL_IDENTITY_LIST}
    [Teardown]  AiC Test Teardown

[1][1.0] Automated_AIC_Activation_Deactivation_of_Energy_Consumption_Measurement
    [Setup]  AiC Test Setup
    TC__Cloud_PM_Activation_Deactivation_Of_Energy_Consumption_Measurement
    ...  rmod_sn_list=${RMOD_SN_LIST}
    ...  scfc_file_path=${VDU_SCF_PATH}
    [Teardown]  AiC Test Teardown

[1][1.0] General_SiSo_Auto_Cloud_Cell_Availability_Monitoring_With_Energy_Efficiency_Enhancement
    [Setup]  AiC Test Setup
    TC__Cloud_PM_Cell_Availability_Monitoring_With_Energy_Efficiency_Enhancement
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  rmod_sn_list=${RMOD_SN_LIST}
   [Teardown]  AiC Test Teardown

[1][1.0] General_SiSo_Auto_Cloud_MicroDTX_Activation_Verification
    [Setup]  AiC Test Setup
    TC__Cloud_PM_MicroDTX_Activation_Verification
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  rmod_sn_list=${RMOD_SN_LIST}
   [Teardown]  AiC Test Teardown

[1][1.0] Automated_AIC_PIM_Alarms_Triggering
    [Setup]  AiC Test Setup
    TC__Cloud_PM_PIM_Alarms_Triggering
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  rmod_sn_list=${RMOD_SN_LIST}
   [Teardown]  AiC Test Teardown

[1][1.0]Automated_AIC_Automated_SiSo_PM_PIMC_Counters
    [Setup]  AiC Test Setup
    TC__Cloud_PM_PIMC_Counters
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  rmod_sn=${RMOD_SN}
    [Teardown]  AiC Test Teardown

[1][1.0] General_SiSo_Auto_Cloud_Radio_Module_Fan_Speed_Counters_Monitoring
    [Setup]  AiC Test Setup
    TC__Cloud_PM_Radio_Module_Fan_Speed_Counters_Monitoring
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  rmod_sn_list=${RMOD_SN_LIST}
    [Teardown]  AiC Test Teardown

[1][1.0] General_SiSo_Auto_Cloud_Radio_Module_Thermal_Counters_Monitoring
    [Setup]  AiC Test Setup
    TC__Cloud_PM_Radio_Module_Thermal_Counters_Monitoring
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  rmod_sn_list=${RMOD_SN_LIST}
    [Teardown]  AiC Test Teardown

[1][1.0] General_SiSo_Auto_Cloud_PM_Radio_Module_Thermal_Counters_Monitoring_And_Alarm_Triggering
    [Setup]  AiC Test Setup
    TC__Cloud_PM_Radio_Module_Thermal_Counters_Monitoring_And_Alarm_Triggering
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  rmod_sn_list=${RMOD_SN_LIST}
    [Teardown]  AiC Test Teardown

[1][1.0] Automated_AiC_RU_Entering_Deep_Sleep_Mode_And_Power_Reset_Recovery_Action
    [Setup]  AiC Test Setup
    TC__Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Power_Reset_Recovery_Action
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  rmod_sn_list=${RMOD_SN_LIST}
    [Teardown]  AiC Test Teardown

[1][1.0] Automated_AiC_Entering_Deep_Sleep_Mode_And_Returning_By_One_Cell_Unblock
    [Setup]  AiC Test Setup
    TC__Cloud_REC_RU_Entering_Deep_Sleep_Mode_And_Returning_By_One_Cell_Unblock
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  rmod_sn_list=${RMOD_SN_LIST}
    [Teardown]  AiC Test Teardown

[1][1] Automated_AIC_Sync_Source_Switch_Over_From_Primary_To_Secondary
    [Setup]  AiC Test Setup
    TC__Cloud_REC_Sync_Source_Switch_Over_From_Primary_To_Secondary
    ...  scfc_file_path=${VDU_SCF_PATH}
    [Teardown]  AiC Test Teardown

[1][1.0] Automated_AIC_Online_RF_Scanning
    [Setup]  AiC Test Setup
    TC__Cloud_TEST_Online_RF_Scanning
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  rmod_sn=${RMOD_SN}
    [Teardown]  AiC Test Teardown

[1][1.0] Automated_AiC_Start_Stop_NR_Downlink_TestModel
    [Setup]  AiC Test Setup
    TC__TEST_Cloud_TEST_Start_Stop_NR_TestModels
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  test_model=nr_downlink
    ...  downlink_test_model=NR-FR1-TM3.1
    ...  nrcell_id=3
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    [Teardown]  AiC Test Teardown

[1][1.0] Automated_AiC_Start_Stop_NR_Uplink_TestModel
    [Setup]  AiC Test Setup
    TC__TEST_Cloud_TEST_Start_Stop_NR_TestModels
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  test_model=nr_uplink
    ...  uplink_frc_index=G-FR1-A1-5
    ...  nrcell_id=3
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    [Teardown]  AiC Test Teardown

[1][1.0] Automated_AiC_Start_Stop_NR_Performance_PUSCH_TestModel
    [Setup]  AiC Test Setup
    TC__TEST_Cloud_TEST_Start_Stop_NR_TestModels
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  test_model=nr_performance_pusch
    ...  pusch_frc_index=G-FR1-A4-10
    ...  nrcell_id=3
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    [Teardown]  AiC Test Teardown

[1][1.0] Automated_AiC_Start_Stop_NR_Performance_PUCCH_TestModel
    [Setup]  AiC Test Setup
    TC__TEST_Cloud_TEST_Start_Stop_NR_TestModels
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  test_model=nr_performance_pucch
    ...  nrcell_id=3
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    [Teardown]  AiC Test Teardown

[1][1.0] Automated_AiC_Start_Stop_NR_Performance_PRACH_TestModel
    [Setup]  AiC Test Setup
    TC__TEST_Cloud_TEST_Start_Stop_NR_TestModels
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  test_model=nr_performance_prach
    ...  nrcell_id=3
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    [Teardown]  AiC Test Teardown

[1][1.0] Automated_AIC_TDS_RF_Scanning
    [Setup]  AiC Test Setup
    TC__Cloud_TEST_TDS_RF_Scanning
    ...  scfc_file_path=${VDU_SCF_PATH}
    ...  rmod_sn=${RMOD_SN}
    [Teardown]  AiC Test Teardown

[1][1.0] General_SiSo_Auto_Cloud_Enable_Disable_Energy_Optimized_Mode
    [Setup]  AiC Test Setup
    TC__Cloud_PM_Enable_Disable_Energy_Optimized_Mode
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  cbts_rmod_sn_list=${RMOD_SN_LIST}
    ...  verify_power=${True}
    [Teardown]  AiC Test Teardown

[1][1.0] General_SiSo_Auto_Cloud_Load_Based_Cell_Switch_Off_Energy_Efficiency_Example_1
    [Setup]  AiC Test Setup
    TC__Cloud_PM_Load_Based_Cell_Switch_Off_Energy_Efficiency
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  cbts_cells_id_list=${CELL_ID_LIST}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    [Teardown]  AiC Test Teardown
    ...  get_logs=${False}

[1][1.0] General_SiSo_Auto_Cloud_Load_Based_Cell_Switch_Off_Energy_Efficiency_Example_2
    [Setup]  AiC Test Setup
    TC__Cloud_PM_Load_Based_Cell_Switch_Off_Energy_Efficiency
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    [Teardown]  AiC Test Teardown
    ...  get_logs=${True}

[1][1.0] General_SiSo_Auto_Cloud_Power_Meter_Energy_Efficiency_Example_1
    [Setup]  AiC Test Setup
    TC__Cloud_PM_Power_Meter_RU_Side_Energy_Efficiency
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  cbts_rmod_sn_list=@{RMOD_SN_LIST}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    [Teardown]  AiC Test Teardown
    ...  get_logs=${False}

[1][1.0] General_SiSo_Auto_Cloud_Power_Meter_Energy_Efficiency_Example_2
    [Setup]  AiC Test Setup
    TC__Cloud_PM_Power_Meter_RU_Side_Energy_Efficiency
    ...  vdu_scfc_file_path=${VDU_SCF_PATH}
    ...  vdu_connection=${VDU_CONNECTION_DEFAULT}
    [Teardown]  AiC Test Teardown
    ...  get_logs=${True}
