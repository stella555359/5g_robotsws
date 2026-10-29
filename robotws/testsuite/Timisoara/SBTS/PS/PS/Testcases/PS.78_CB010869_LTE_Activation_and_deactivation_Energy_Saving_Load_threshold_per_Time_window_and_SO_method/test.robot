*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.78_CB010869_LTE_Activation_and_deactivation_Energy_Saving_Load_threshold_per_Time_window_and_SO_method
...  AUTHORS:       andreea.burtic@nokia.com
...  MAINTAINER:    TIM_5_Vrf  andreea.burtic@nokia.com
...  FEATURE:       CB010869
...  *****************
...  Basic information
...  *****************
...  Purpose of this test case is to verify the activation and deactivation of the
...  'CB010869 Energy Saving Load Threshold per Time Window and Switch OFF Method' feature.
...  *****************
...  Pre-conditions
...  *****************
...  All RAT are onAir and no active alarms are visible
...  ******************
...  History of changes
...  ******************
...  17.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30170 - TC creation
...  *******************


*** Keywords ***
PS.78_CB010869_LTE_Activation_and_deactivation_Energy_Saving_Load_threshold_per_Time_window_and_SO_method
    PS_LTE_Activation_and_deactivation_Energy_Saving_Load_threshold_per_Time_window_and_SO_method.Step:0 Test Preparation
    PS_LTE_Activation_and_deactivation_Energy_Saving_Load_threshold_per_Time_window_and_SO_method.Step:1 Set Feature And Configure Power Saving PSGRPs
    PS_LTE_Activation_and_deactivation_Energy_Saving_Load_threshold_per_Time_window_and_SO_method.Step:2 Check if cells reach desired states
    PS_LTE_Activation_and_deactivation_Energy_Saving_Load_threshold_per_Time_window_and_SO_method.Step:3 Enable CB010869
    PS_LTE_Activation_and_deactivation_Energy_Saving_Load_threshold_per_Time_window_and_SO_method.Step:4 Reconfigure PSGRPs For CB010869


PS_LTE_Activation_and_deactivation_Energy_Saving_Load_threshold_per_Time_window_and_SO_method.Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    Set Test Variable  ${LNBTS_DISTNAME}  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP/NRPGRP
    Select Six Random LTE Cells
    Log  Selected 1st LNCEL DN: ${1st_LNCEL_DN}  console=${True}
    Log  Selected 2nd LNCEL DN: ${2nd_LNCEL_DN}  console=${True}
    Log  Selected 3rd LNCEL DN: ${3rd_LNCEL_DN}  console=${True}
    Log  Selected 4th LNCEL DN: ${4th_LNCEL_DN}  console=${True}
    Log  Selected 5th LNCEL DN: ${5th_LNCEL_DN}  console=${True}
    Log  Selected 6th LNCEL DN: ${6th_LNCEL_DN}  console=${True}
    ${ALL_CELLS_IDS}  Create List  ${1st_LNCEL_ID}  ${2nd_LNCEL_ID}  ${3rd_LNCEL_ID}  ${4th_LNCEL_ID}  ${5th_LNCEL_ID}  ${6th_LNCEL_ID}
    Set Test Variable  ${ALL_CELLS_IDS}
    ${NR_OF_IMPACTED_CELLS}  Get Length  ${ALL_CELLS_IDS}
    Set Test Variable  ${NR_OF_IMPACTED_CELLS}
    FOR  ${index}  IN RANGE  ${NR_OF_IMPACTED_CELLS}
        Check Power Saving  ${ALL_CELLS_IDS}[${index}]  ENABLED  NOTENERGYSAVING
    END


PS_LTE_Activation_and_deactivation_Energy_Saving_Load_threshold_per_Time_window_and_SO_method.Step:1 Set Feature And Configure Power Saving PSGRPs
    Log to console    \n========================================
    Log  Step: 1 Set Feature And Configure Power Saving PSGRPs  console=${True}
    Log to console    ========================================
    ${features}  Create Dictionary  actLBPowerSaving=true  actLBRTXPowerSaving=true  actOnlineTXSwitch=true  actMixedSOMethod=true  shutdownWindow=60
    Set Parameters From Dictionary Under Given Object  ${LNBTS_DISTNAME}  ${features}
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    Create And Activate PSGRPs For CB010869  PSGRP-1  PSGRP-2  70
    Check If Unexpected Alarms Are Raised  ${skip_fault}


PS_LTE_Activation_and_deactivation_Energy_Saving_Load_threshold_per_Time_window_and_SO_method.Step:2 Check if cells reach desired states
    Log to console    \n========================================
    Log  Step: 2 Check if cells reach desired states  console=${True}
    Log to console    ========================================
    Log To Console  Waiting for ENERGYSAVING...
    Wait Until Keyword Succeeds  25min  30sec  Check Power Saving  ${1st_LNCEL_ID}  ENABLED  REDUCEDENERGYSAVING
    Log  LNCEL_R-${1st_LNCEL_ID} is ENABLED / REDUCEDENERGYSAVING\n  console=true
    Wait Until Keyword Succeeds  25min  30sec  Check Power Saving  ${2nd_LNCEL_ID}  ENABLED  REDUCEDENERGYSAVING
    Log  LNCEL_R-${2nd_LNCEL_ID} is ENABLED / REDUCEDENERGYSAVING\n  console=true
    Wait Until Keyword Succeeds  25min  30sec  Check Power Saving  ${3rd_LNCEL_ID}  ENABLED  REDUCEDENERGYSAVING
    Log  LNCEL_R-${3rd_LNCEL_ID} is ENABLED / REDUCEDENERGYSAVING\n  console=true
    Wait Until Keyword Succeeds  25min  30sec  Check Power Saving  ${4th_LNCEL_ID}  DISABLED  ENERGYSAVING
    Log  LNCEL_R-${4th_LNCEL_ID} is DISABLED / ENERGYSAVING\n  console=true
    Wait Until Keyword Succeeds  25min  30sec  Check Power Saving  ${5th_LNCEL_ID}  DISABLED  ENERGYSAVING
    Log  LNCEL_R-${5th_LNCEL_ID} is DISABLED / ENERGYSAVING\n  console=true
    Wait Until Keyword Succeeds  25min  30sec  Check Power Saving  ${6th_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Log  LNCEL_R-${6th_LNCEL_ID} is ENABLED / NOTENERGYSAVING\n  console=true
    Check If Unexpected Alarms Are Raised  ${skip_fault}


PS_LTE_Activation_and_deactivation_Energy_Saving_Load_threshold_per_Time_window_and_SO_method.Step:3 Enable CB010869
    Log to console    \n========================================
    Log  Step: 3 Enable CB010869  console=${True}
    Log to console    ========================================
    Wait Until Time Plus Minutes  ${T2_TIME}  1
    Set Feature Under Given Object  ${LNBTS_DISTNAME}  actLbpsThresPerTimeWindow  true
    Check Power Saving  ${1st_LNCEL_ID}  ENABLED  REDUCEDENERGYSAVING
    Log  LNCEL_R-${1st_LNCEL_ID} is ENABLED / REDUCEDENERGYSAVING\n  console=true
    Check Power Saving  ${2nd_LNCEL_ID}  ENABLED  REDUCEDENERGYSAVING
    Log  LNCEL_R-${2nd_LNCEL_ID} is ENABLED / REDUCEDENERGYSAVING\n  console=true
    Check Power Saving  ${3rd_LNCEL_ID}  ENABLED  REDUCEDENERGYSAVING
    Log  LNCEL_R-${3rd_LNCEL_ID} is ENABLED / REDUCEDENERGYSAVING\n  console=true
    Check Power Saving  ${4th_LNCEL_ID}  DISABLED  ENERGYSAVING
    Log  LNCEL_R-${4th_LNCEL_ID} is DISABLED / ENERGYSAVING\n  console=true
    Check Power Saving  ${5th_LNCEL_ID}  DISABLED  ENERGYSAVING
    Log  LNCEL_R-${5th_LNCEL_ID} is DISABLED / ENERGYSAVING\n  console=true
    Check Power Saving  ${6th_LNCEL_ID}  ENABLED  NOTENERGYSAVING
    Log  LNCEL_R-${6th_LNCEL_ID} is ENABLED / NOTENERGYSAVING\n  console=true
    Check If Unexpected Alarms Are Raised  ${skip_fault}


PS_LTE_Activation_and_deactivation_Energy_Saving_Load_threshold_per_Time_window_and_SO_method.Step:4 Reconfigure PSGRPs For CB010869
    Log to console    \n========================================
    Log  Step: 4 Reconfigure PSGRPs For CB010869  console=${True}
    Log to console    ========================================
    Wait Until Time Plus Minutes  ${T3_TIME}  1
    Change Parameters Under PSGRP for CB010869  1  2
    FOR  ${index}  IN RANGE  ${NR_OF_IMPACTED_CELLS}
        Wait Until Keyword Succeeds  10min  30sec  Check Power Saving  ${ALL_CELLS_IDS}[${index}]  ENABLED  NOTENERGYSAVING
        Log  LNCEL_R-${ALL_CELLS_IDS}[${index}] is ENABLED / NOTENERGYSAVING\n  console=true
    END
    Log  Waiting for the ENERGY SAVING period \n  console=true
    FOR  ${index}  IN RANGE  ${NR_OF_IMPACTED_CELLS}
        Wait Until Keyword Succeeds  30min  30sec  Check Power Saving  ${ALL_CELLS_IDS}[${index}]  DISABLED  ENERGYSAVING
        Log  LNCEL_R-${ALL_CELLS_IDS}[${index}] is DISABLED / ENERGYSAVING\n  console=true
    END
    Log  Waiting for the ENERGY SAVING period to end \n  console=true
    FOR  ${index}  IN RANGE  ${NR_OF_IMPACTED_CELLS}
        Wait Until Keyword Succeeds  30min  30sec  Check Power Saving  ${ALL_CELLS_IDS}[${index}]  ENABLED  NOTENERGYSAVING
        Log  LNCEL_R-${ALL_CELLS_IDS}[${index}] is ENABLED / NOTENERGYSAVING\n  console=true
    END
    Check If Unexpected Alarms Are Raised  ${skip_fault}


PS_LTE_Activation_and_deactivation_Energy_Saving_Load_threshold_per_Time_window_and_SO_method.Test Specific Teardown
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    admin.Setup Admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Run Keyword And Ignore Error  Remove PSGRP/NRPGRP Objects If Exist  PSGRP/NRPGRP
    ${features}  Create Dictionary  actLBPowerSaving=false  actLBRTXPowerSaving=false  actOnlineTXSwitch=false  actMixedSOMethod=false
    ...  actLbpsThresPerTimeWindow=false
    Set Parameters From Dictionary Under Given Object  ${LNBTS_DISTNAME}  ${features}
    Check If Unexpected Alarms Are Raised  ${skip_fault}
    admin.Teardown Admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n


PS.78_CB010869_LTE_Activation_and_deactivation_Energy_Saving_Load_threshold_per_Time_window_and_SO_method.Test Case Teardown
    common.Common Test Teardown
    PS_LTE_Activation_and_deactivation_Energy_Saving_Load_threshold_per_Time_window_and_SO_method.Test Specific Teardown
