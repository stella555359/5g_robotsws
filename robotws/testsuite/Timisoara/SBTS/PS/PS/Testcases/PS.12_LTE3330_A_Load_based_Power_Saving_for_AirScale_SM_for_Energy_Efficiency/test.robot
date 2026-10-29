*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.12_LTE3330_A_Load_based_Power_Saving_for_AirScale_SM_for_Energy_Efficiency
...  AUTHORS:       tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  LTE3330-A extends feature LTE1103 with possibility to power off one of two ABIA power groups.
...  Whenever all cells served by second power group (PG#2) have been switched off, the BTS powers off the PG#2.
...  With PG#2 switched off, ABIA power consumption can be reduced to 30%.
...  The power group is automatically switched on when cells need to be switched on to meet the need for additional capacity.
...  Feature benefits only the ABIA capacity when only LTE is deployed on ABIA-type Optional PowerGroup(PG#2)processing resources
...  = Description =
...  Check on which power groups are cells.
...  Provision plan via CM Operations Manager to create PSGRP with cells from #PG2 and activate features actLBPowerSaving and actLBBbPowerSaving.
...  When cells change state to EnergySaving check in infomodel if POWERGROUP_R-2?s operationalState changed to disabled.
...  After duration time of one PSGRP cells change operationalState to enabled and POWERGROUP_R-2?s operationalState changed to enabled.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  06.10.2021 - Legacy test
...  02.12.2021 - https://jiradc.ext.net.nokia.com/browse/FCA_SRAN_VER_OPER-28390 - Test refactor
...  10.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-88 - Adaptation to CNI-61110
...  15.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-116 - Uploading LTE only SCF
...  15.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-138 - Change logic in test and switch to TAF library
...  28.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-167 - TC adaptation to SBTS22R3 branch
...  01.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-190 - TC adaptation to MRAT
...  07.06.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-210 - Modification of keyword: Create PowerSaving Group due to CB008800
...  10.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAW-244 - Modification of keyword: Create PowerSaving Group due to new branch 22R4
...  24.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-471 - Added Teardown if call failed
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.12_LTE3330_A_Load_based_Power_Saving_for_AirScale_SM_for_Energy_Efficiency

    PS.12_LTE3330_A_Load_based_Power_Saving_for_AirScale_SM_for_Energy_Efficiency.Test_Step:0 Test Preparation
    PS.12_LTE3330_A_Load_based_Power_Saving_for_AirScale_SM_for_Energy_Efficiency.Test_Step:1 Get Cells List Deployed On Proper POWERGROUP
    PS.12_LTE3330_A_Load_based_Power_Saving_for_AirScale_SM_for_Energy_Efficiency.Test_Step:2 Feature Activation and PSGRP object commission
    PS.12_LTE3330_A_Load_based_Power_Saving_for_AirScale_SM_for_Energy_Efficiency.Test_Step:3 Check Power Saving state
    PS.12_LTE3330_A_Load_based_Power_Saving_for_AirScale_SM_for_Energy_Efficiency.Test_Step:4 Final Recovery and Checkpoint

PS.12_LTE3330_A_Load_based_Power_Saving_for_AirScale_SM_for_Energy_Efficiency.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step:0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
#    Set Test Variable  ${COUNTER_BEFORE_TEST}
    @{feature_flags}=  Create List  actLBPowerSaving  actCellTraceNB  actMDTSubscriberTrace  actSubscriberTrace
    Set Test Variable  ${feature_flags}
    netact.Upload Configuration  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}

PS.12_LTE3330_A_Load_based_Power_Saving_for_AirScale_SM_for_Energy_Efficiency.Test_Step:1 Get Cells List Deployed On Proper POWERGROUP
    Log to console    \n========================================
    Log  Step:1 Get Cells List Deployed On Proper POWERGROUP  console=${True}
    Log to console    ========================================
    ${BBPOOLs}=  Get BBPOOL List  bbPoolTech=LTE
    ${bbPoolCellsList}  ${BBPOOL_R}=  Get Cells Assigned To POWERGROUP_R-2  ${BBPOOLs}
    FOR  ${cell_id}  IN  @{bbPoolCellsList}
        Log To Console  LNCEL-${cell_id} will be added to PowerSaving group
    END
    Set Test Variable  ${bbPoolCellsList}
    ${LNCEL_A_to_LNCEL_R}=  Mapping LNCEL_A To LNCEL_R
    ${bbPoolCellsList_r}=  Create List
    FOR  ${id}  IN  @{bbPoolCellsList}
        ${LNCEL_A}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/LNCEL-4813${id}
        ${LNCEL_R}=  Get From Dictionary  ${LNCEL_A_to_LNCEL_R}  ${LNCEL_A}
        ${ID_R}=  Evaluate  re.search(r'LNCEL_R-(\\d+)','''${LNCEL_R}''').group(1)  re
        Append To List  ${bbPoolCellsList_r}  ${ID_R}
    END
    Set Test Variable  ${bbPoolCellsList_r}
    Set Test Variable  ${BBPOOL_R}

PS.12_LTE3330_A_Load_based_Power_Saving_for_AirScale_SM_for_Energy_Efficiency.Test_Step:2 Feature Activation and PSGRP object commission
    Log to console    \n========================================
    Log  Step:2 Feature Activation and PSGRP object commission   console=${True}
    Log to console    ========================================
    Set Feature Under LNBTS/NRBTS Via NA  actLBPowerSaving  true  LNBTS
    Set Feature Under LNBTS/NRBTS Via NA  actCellTraceNB  true  LNBTS
    Set Feature Under LNBTS/NRBTS Via NA  actSubscriberTrace  true  LNBTS
    Set Feature Under LNBTS/NRBTS Via NA  actMDTSubscriberTrace  true  LNBTS
    Set Feature Under FEATLADM Via NA  actLBBbPowerSaving  true
    ${if_actExtCellSOMethod}  ${value_actExtCellSOMethod}=  Run Keyword And Ignore Error  Get Parameter Value Under LNBTS  actExtCellSOMethod
    Set Test Variable  ${if_actExtCellSOMethod}
    ${if_actCo4g5g}  ${value_actCo4g5g}=  Run Keyword And Ignore Error  Get Parameter Value Under LNBTS  actCoordinated4g5gPowerSaving
    Set Test Variable  ${if_actCo4g5g}
    Create And Activate PSGRP For LTE3330  ${bbPoolCellsList_r}  PSGRP-330  15min

PS.12_LTE3330_A_Load_based_Power_Saving_for_AirScale_SM_for_Energy_Efficiency.Test_Step:3 Check Power Saving state
    Log to console    \n========================================
    Log  Test_Step:3 Check Power Saving state   console=${True}
    Log to console    ========================================
    FOR  ${cell_id}  IN  @{bbPoolCellsList_r}
        Log To Console  Waiting for ENERGYSAVING on LNCEL-${cell_id}...
        Wait Until Keyword Succeeds  10min  30sec  Check Power Saving  ${cell_id}  DISABLED  ENERGYSAVING
    END
    Wait Until Keyword Succeeds  1min  30sec  Check BBPOOL State  ${BBPOOL_R}  DISABLED
    FOR  ${cell_id}  IN  @{bbPoolCellsList_r}
        Log To Console  Waiting for NOTENERGYSAVING on LNCEL-${cell_id}...
        Wait Until Keyword Succeeds  15min  30sec  Check Power Saving  ${cell_id}  ENABLED  NOTENERGYSAVING
    END
    Wait Until Keyword Succeeds  1min  30sec  Check BBPOOL State  ${BBPOOL_R}  ENABLED
    ${PSGRP_DN}=  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-330
    Shift Time For PSGRP  duration=15  PSGRP_DN=${PSGRP_DN}
    FOR  ${cell_id}  IN  @{bbPoolCellsList_r}
        Log To Console  Waiting for ENERGYSAVING on LNCEL-${cell_id}...
        Wait Until Keyword Succeeds  10min  30sec  Check Power Saving  ${cell_id}  DISABLED  ENERGYSAVING
    END
    Wait Until Keyword Succeeds  1min  30sec  Check BBPOOL State  ${BBPOOL_R}  DISABLED
    Set Feature Under FEATLADM Via NA  actLBBbPowerSaving  false
    Set Feature Under LNBTS/NRBTS Via NA  actLBPowerSaving  false  LNBTS
    FOR  ${cell_id}  IN  @{bbPoolCellsList_r}
        Log To Console  Waiting for NOTENERGYSAVING on LNCEL-${cell_id}...
        Wait Until Keyword Succeeds  2min  10sec  Check Power Saving  ${cell_id}  ENABLED  NOTENERGYSAVING
    END
    Wait Until Keyword Succeeds  1min  30sec  Check BBPOOL State  ${BBPOOL_R}  ENABLED

PS.12_LTE3330_A_Load_based_Power_Saving_for_AirScale_SM_for_Energy_Efficiency.Test_Step:4 Final Recovery and Checkpoint
    Log to console    \n========================================
    Log  Step:4 Final Recovery and Checkpoint   console=${True}
    Log to console    ========================================
    Set Feature Under FEATLADM Via NA  actLBBbPowerSaving  false
    Set Feature Under LNBTS/NRBTS Via NA  actLBPowerSaving  false  LNBTS
    Set Feature Under LNBTS/NRBTS Via NA  actCellTraceNB  false  LNBTS
    Set Feature Under LNBTS/NRBTS Via NA  actMDTSubscriberTrace  false  LNBTS
    Set Feature Under LNBTS/NRBTS Via NA  actSubscriberTrace  false  LNBTS
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Check If NLWG Cells Are OnAir
    ${COUNTER_AFTER_TEST}=  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}
    ${status}  Run Keyword And Return Status  L3 Call
    IF  not ${status}  Teardown if call failed

PS.12_LTE3330_A_Load_based_Power_Saving_for_AirScale_SM_for_Energy_Efficiency.Test Specific Teardown
    [Documentation]  Test teardown which deactivate feature and delete PSGRP object.
    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    admin.setup admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Run Keyword And Ignore Error  Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${FEATLADM_DistName}  actLBBbPowerSaving  false
    Run Keyword And Ignore Error  Set Feature Under Given Object  ${LNBTS_DistName}  ${feature_flags}  false

    admin.teardown admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n

PS.12_LTE3330_A_Load_based_Power_Saving_for_AirScale_SM_for_Energy_Efficiency.Test Case Teardown
    Run Keywords  common.Common Test Teardown  AND  Teardown TAF Netact
    Run Keyword If Test Failed  PS.12_LTE3330_A_Load_based_Power_Saving_for_AirScale_SM_for_Energy_Efficiency.Test Specific Teardown
