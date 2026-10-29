*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/power_saving.robot

Documentation
...  TEST NAME:     PS.56_LTE1203_Reduced_Power_Saving_Activation_For_Cell_Level_PSGRPs_Via_Admin
...  AUTHORS:       victor.banicioiu@nokia.com
...  MAINTAINER:    TIM_5_Vrf    victor.banicioiu@nokia.com
...  FEATURE:       CNI122964
...  *****************
...  Basic information
...  *****************
...  Test checks activation and deactivation of energy saving with Tx path switching off for more than 18 PSGRPs.
...  *****************
...  Pre-conditions
...  *****************
...  eNB is onAir and no active alarms are visible
...  ******************
...  History of changes
...  ******************
...  31.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27866 - TC creation
...  *******************


*** Keywords ***
PS.56_LTE1203_Reduced_Power_Saving_Activation_For_Cell_Level_PSGRPs_Via_Admin
    PS.56_LTE1203_Reduced_Power_Saving_Activation_For_Cell_Level_PSGRPs_Via_Admin.Test_Step:0 Test Preparation
    PS.56_LTE1203_Reduced_Power_Saving_Activation_For_Cell_Level_PSGRPs_Via_Admin.Test_Step:1 Configure Load Based Power Saving PSGRPs
    PS.56_LTE1203_Reduced_Power_Saving_Activation_For_Cell_Level_PSGRPs_Via_Admin.Test_Step:2 Check if cells reach desired states


PS.56_LTE1203_Reduced_Power_Saving_Activation_For_Cell_Level_PSGRPs_Via_Admin.Test_Step:0 Test Preparation
    Log  \n========================================  console=true
    Log  Step: 0 Test Preparation  console=true
    Log  ========================================  console=true
    @{FEATURE_FLAGS}  Create List  actLBRTXPowerSaving  actLBPowerSaving
    Set Test Variable  ${FEATURE_FLAGS}
    Select Random LTE Cell
    ${cell_list}  Get LNCEL List Without SingleTX And mMIMO
    @{LNCEL_IDS}  Select 19 LTE Cells For ReducedEnergySaving  ${cell_list}
    Set Test Variable  ${LNCEL_IDS}
    ${nr_of_ids}  Get Length  ${LNCEL_IDS}
    FOR  ${index}  IN RANGE  ${nr_of_ids}
        Check Power Saving  ${LNCEL_IDS}[${index}]  ENABLED  NOTENERGYSAVING
    END


PS.56_LTE1203_Reduced_Power_Saving_Activation_For_Cell_Level_PSGRPs_Via_Admin.Test_Step:1 Configure Load Based Power Saving PSGRPs
    Log  \n========================================  console=true
    Log  Step:1 Configure Load Based Power Saving PSGRPs  console=true
    Log  ========================================  console=true
    Set Feature Under Given Object  ${LNBTS_DistName}  ${FEATURE_FLAGS}  true
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    ${IF_ACTEXTCELLSOMETHOD}  ${value_actExtCellSOMethod}  Run Keyword And Ignore Error  Get Parameter Value Under LNBTS  actExtCellSOMethod
    Set Test Variable  ${IF_ACTEXTCELLSOMETHOD}
    ${IF_ACTCO4G5G}  ${value_actCo4g5g}  Run Keyword And Ignore Error  Get Parameter Value Under LNBTS  actCoordinated4g5gPowerSaving
    Set Test Variable  ${IF_ACTCO4G5G}
    Create And Activate PSGRPs  19  ${LNCEL_IDS}  20
    Check If Unexpected Alarms Are Raised  ${skip_fault}


PS.56_LTE1203_Reduced_Power_Saving_Activation_For_Cell_Level_PSGRPs_Via_Admin.Test_Step:2 Check if cells reach desired states
    Log  \n========================================  console=true
    Log  Step:2 Check if cells reach desired states  console=true
    Log  ========================================  console=true
    ${nr_of_ids}  Get Length  ${LNCEL_IDS}
    FOR  ${index}  IN RANGE  ${nr_of_ids}
        Wait Until Keyword Succeeds  10min  30sec  Check Power Saving  ${LNCEL_IDS}[${index}]  ENABLED  REDUCEDENERGYSAVING
        Log  LNCEL_R-${LNCEL_IDS}[${index}] is ENABLED / REDUCEDENERGYSAVING\n  console=true
    END
    Log  Waiting for the REDUCED ENERGY SAVING period to end\n  console=true
    FOR  ${index}  IN RANGE  ${nr_of_ids}
        Wait Until Keyword Succeeds  13min  30sec  Check Power Saving  ${LNCEL_IDS}[${index}]  ENABLED  NOTENERGYSAVING
        Log  LNCEL_R-${LNCEL_IDS}[${index}] is ENABLED / NOTENERGYSAVING\n  console=true
    END


PS.56_LTE1203_Reduced_Power_Saving_Activation_For_Cell_Level_PSGRPs_Via_Admin.Test Specific Teardown
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Run Keyword And Ignore Error  Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${LNBTS_DistName}  ${FEATURE_FLAGS}  false
    admin.teardown admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n


PS.56_LTE1203_Reduced_Power_Saving_Activation_For_Cell_Level_PSGRPs_Via_Admin.Test Case Teardown
    Common Test Teardown
    PS.56_LTE1203_Reduced_Power_Saving_Activation_For_Cell_Level_PSGRPs_Via_Admin.Test Specific Teardown
