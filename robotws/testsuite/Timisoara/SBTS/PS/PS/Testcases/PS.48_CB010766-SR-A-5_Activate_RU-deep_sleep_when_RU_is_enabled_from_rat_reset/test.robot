*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/netact.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset
...  AUTHORS:       mateusz.gumieniak@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  This scenario describes that the BTS should activate the deep sleep mode for RU when it is enabled from RU reset,
...  provided that this feature function is also enabled.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  13.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-429 - TC creation
...  07.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-523 - added FID 7107,7300 and 7319 to allowed during LTE RAT reset
...  05.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29187 - Included functionality to skip RMODs that have
...               IoT cells under them and updated TC to RF 5.0 standards
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset

    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test_Step:0 Test Preparation
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test_Step:1 Setup energy saving for legacy Deep Sleep
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test_Step:Wait for Energy Saving
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test_Step:Check RU state
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test_Step:4 Enable feature CB10766
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test_Step:Check RU state
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test_Step:6 Perform RAT reset
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test_Step:Wait for Energy Saving
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test_Step:Check RU state
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test_Step:9 Check states after RU awake and L3 call
    PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test_Step:10 Final Recovery and Checkpoint


PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test_Step:0 Test Preparation
    Log to console  \n========================================
    Log  Step: 0 Test Preparation  console=true
    Log to console  ========================================
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    ${rmod_r_a_list}  Mapping RMOD_R To RMOD_A
    ${rmod_r_objects}  admin.Get Managed Objects  RMOD_R
    ${rmod_r_model}  Create Dictionary
    FOR  ${item}  IN  @{rmod_r_objects}
        Set To Dictionary  ${rmod_r_model}  ${item['distName']}  ${item['parameters']['productName']}
    END
    ${5_1_rf_r}  Create List
    FOR  ${item}  IN  @{rmod_r_model.keys()}
        ${rmod}  Get From Dictionary  ${rmod_r_model}  ${item}
        IF  $rmod[0:2]=='AH' or $rmod[0:2]=='AV'  Append To List  ${5_1_rf_r}  ${item}
    END
    ${SELECTED_RMOD}  Evaluate  random.choice(${5_1_rf_r})  random
    ${contains_iot_cells}  Check If LNCEL IoT Cells Exist Under RMOD  ${SELECTED_RMOD}
    WHILE  ${contains_iot_cells}
        Remove Values From List  ${5_1_rf_r}  ${SELECTED_RMOD}
        ${SELECTED_RMOD}  Evaluate  random.choice(${5_1_rf_r})  random
        ${contains_iot_cells}  Check If LNCEL IoT Cells Exist Under RMOD  ${SELECTED_RMOD}
    END
    ${SELECTED_RMOD_A}  Get From Dictionary  ${rmod_r_a_list}  ${SELECTED_RMOD}
    ${ignore}  ${SELECTED_RMOD_A}  Split String From Right  ${SELECTED_RMOD_A}  separator=SCF-1/
    ${SELECTED_RMOD_A}  Replace String  ${SELECTED_RMOD_A}  search_for=_A  replace_with=
    Log To Console  Selected RMOD: ${SELECTED_RMOD}
    ${rmod_index}  Split String From Right  ${SELECTED_RMOD_A}  separator=-
    ${SELECTED_RMOD_2}  Set Variable  RMOD-${rmod_index}[-1]
    Set Test variable  ${SELECTED_RMOD_2}
    Set Test Variable  ${SELECTED_RMOD}
    Set Test Variable  ${SELECTED_RMOD_A}
    ${randomrmod_id}  Set Variable  ${SELECTED_RMOD_2}
    ${channels}  admin.Get Managed Objects  CHANNEL_A
    ${WNCELS_A}  admin.Get Managed Objects  WNCEL_A
    Set Test variable  ${WNCELS_A}
    ${wncel_a_to_lcelw_a}  Mapping WNCEL_A ID From LCELW_A
    Log to console  \n========================================
    Log  Checking which cells are affected by RMOD reset  console=true
    Log to console  ========================================
    ${SELECTED_ALIAS_CELLS}  Create List
    Set Test variable  ${SELECTED_ALIAS_CELLS}
    ${GRACEFUL_CELLS}  Create List
    Set Test variable  ${GRACEFUL_CELLS}
    FOR  ${channel}  IN  @{channels}
         ${CHANNEL_NAME}  Get From Dictionary  ${channel}  distName
         Set Test Variable  ${CHANNEL_NAME}
         ${antl}  Get From Dictionary  ${channel['parameters']}  antlDN
         ${resourceDN}  Get From Dictionary  ${channel['parameters']}  resourceDN
         ${rmod_data}=  IF  '${antl}'!='None'  Set Variable  ${antl}  ELSE  Set Variable  ${resourceDN}
         ${rmod_id}  Get Regexp Matches  ${rmod_data}  RMOD_A-\\d+
         ${rmod_id_without_A}  Remove String  '${rmod_id[0]}'  _A
         IF  '${randomrmod_id}' == ${rmod_id_without_A}  Get Cells From CHANNEL_A
    END
    ${SELECTED_ALIAS_CELLS}  Remove Duplicates  ${SELECTED_ALIAS_CELLS}
    Set Test variable  ${SELECTED_ALIAS_CELLS}
    Log  Cells affected by RMOD reset: ${SELECTED_ALIAS_CELLS}  console=true
    Create And Activate RMOD deepSleepTimeSchedule  ${SELECTED_RMOD_2}  5  55
    Log  Selected RMOD_A: ${rmod_r_a_list}  console=true
    ${now}  Get Current Date
    ${DEEPSLEEP_TIME_SCHEDULE_END_TIME}  Add Time To Date  ${now}  60min
    Set Test Variable  ${DEEPSLEEP_TIME_SCHEDULE_END_TIME}


PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test_Step:1 Setup energy saving for legacy Deep Sleep
    Log to console  \n========================================
    Log  Step: 1 Setup energy saving for legacy Deep Sleep  console=true
    Log to console  ========================================
    ${SELECTED_ALIAS_LTE_CELLS}  Create List
    ${SELECTED_ALIAS_NR_CELLS}  Create List
    ${SELECTED_ALIAS_WCDMA_CELLS}  Create List
    ${SELECTED_ALIAS_GSM_CELLS}  Create List
    FOR  ${item}  IN  @{SELECTED_ALIAS_CELLS}
        ${lte}  Run Keyword And Return Status  Should Contain  ${item}  LNCEL
        ${nr}  Run Keyword And Return Status  Should Contain  ${item}  NRCEL
        ${wcdma}  Run Keyword And Return Status  Should Contain  ${item}  WNCEL
        ${gsm}  Run Keyword And Return Status  Should Contain  ${item}  GNCEL
        IF  ${lte}  Append To List  ${SELECTED_ALIAS_LTE_CELLS}  ${item}
        IF  ${nr}  Append To List  ${SELECTED_ALIAS_NR_CELLS}  ${item}
        IF  ${wcdma}  Append To List  ${SELECTED_ALIAS_WCDMA_CELLS}  ${item}
        IF  ${gsm}  Append To List  ${SELECTED_ALIAS_GSM_CELLS}  ${item}
    END
    Set Test Variable  ${SELECTED_ALIAS_LTE_CELLS}
    Set Test Variable  ${SELECTED_ALIAS_NR_CELLS}
    Set Test Variable  ${SELECTED_ALIAS_GSM_CELLS}
    Set Test Variable  ${SELECTED_ALIAS_WCDMA_CELLS}
    ${LTE_CHOSEN}  Run Keyword And Return Status  Should Not Be Empty  ${SELECTED_ALIAS_LTE_CELLS}
    ${NR_CHOSEN}  Run Keyword And Return Status  Should Not Be Empty  ${SELECTED_ALIAS_NR_CELLS}
    Set Test Variable  ${LTE_CHOSEN}
    Set Test Variable  ${NR_CHOSEN}
    IF  ${LTE_CHOSEN}  Create Dynamic 1103 PSGRP  ${SELECTED_ALIAS_LTE_CELLS}
    IF  ${NR_CHOSEN}  Create Dynamic 1103 NRPGRP  ${SELECTED_ALIAS_NR_CELLS}
    IF  ${LTE_CHOSEN}
        Set Feature Under Given Object  ${LNBTS_DistName}  actLBPowerSaving  true
        Set Feature Under Given Object  ${LNBTS_DistName}  actLBRTXPowerSaving  false
    END
    IF  ${NR_CHOSEN}  Set Feature Under Given Object  ${NRBTS_DistName}  actNrLBPowerSaving  true
    Sleep  210


PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test_Step:Wait for Energy Saving
    Log to console  \n========================================
    Log  Step: Wait for Energy Saving  console=true
    Log to console  ========================================
    FOR  ${item}  IN  @{SELECTED_ALIAS_GSM_CELLS}
        Log to console  Locking ${item}
        admin.Block Cell  ${item}  timeout=120
    END
    FOR  ${item}  IN  @{SELECTED_ALIAS_WCDMA_CELLS}
        Log to console  Locking ${item}
        admin.Block Cell  ${item}  timeout=120
    END
    FOR  ${item}  IN  @{SELECTED_ALIAS_LTE_CELLS}
        ${split_cell}  Split String  ${item}  -
        Log to console  Wait for Energysaving on ${item}
        Wait Until Keyword Succeeds  10min  15sec  Check Power Saving  ${split_cell[-1]}  DISABLED  ENERGYSAVING
    END
    FOR  ${item}  IN  @{SELECTED_ALIAS_NR_CELLS}
        ${split_cell}  Split String  ${item}  -
        Log to console  Wait for Energysaving on ${item}
        Wait Until Keyword Succeeds  10min  15sec  Check Power Saving NR  ${split_cell[-1]}  DISABLED  ENERGYSAVING
    END


PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test_Step:Check RU state
    Log to console  \n========================================
    Log  Step: Check RU state  console=true
    Log to console  ========================================
    Log To Console  Waiting for deep sleep
    Wait Until Keyword Succeeds  17min  15s  Check RU state for DEEPSLEEP  ${SELECTED_RMOD_A}  SLEEP


PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test_Step:4 Enable feature CB10766
    Log to console  \n========================================
    Log  Step: 4 Enable CB10766  console=true
    Log to console  ========================================
    Set Feature Under FEATCADM Via NA  actRadioDeepSleepTimeSchedule  true


PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test_Step:6 Perform RAT reset
    Log to console  \n========================================
    Log  Step: 6 Perform RAT reset  console=true
    Log to console  ========================================
    IF  ${NR_CHOSEN}
        Allow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
        Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
        Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    END
    IF  ${LTE_CHOSEN}
        Allow Fault In Watchdog  faultID=7107  #fault_name: Problem due to associated X2 links unavailability
        Allow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
        Allow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    END
    IF  ${LTE_CHOSEN}  admin.Rat Reset  LTE  300
    IF  ${NR_CHOSEN}  admin.Rat Reset  NR  500
    FOR  ${item}  IN  @{SELECTED_ALIAS_GSM_CELLS}
        Log to console  Unblocking ${item}
        admin.Unblock Cell  ${item}  timeout=120
    END
    FOR  ${item}  IN  @{SELECTED_ALIAS_WCDMA_CELLS}
        Log to console  Unblocking ${item}
        admin.Unblock Cell  ${item}  timeout=120
    END
    Log To Console  Wait for ON AIR all cells  console=true
    Check If NLWG Cells Are OnAir

	IF  ${NR_CHOSEN}
        Disallow Fault In Watchdog  faultID=6327  #fault_name: Setup of X2 connectivity to gNB failed
        Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
        Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    END
    IF  ${LTE_CHOSEN}
        Disallow Fault In Watchdog  faultID=7107  #fault_name: Problem due to associated X2 links unavailability
        Disallow Fault In Watchdog  faultID=7300  #fault_name: No X2 link available
        Disallow Fault In Watchdog  faultID=7319  #fault_name: No X2 link available for a specific LTEENB
    END


PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test_Step:9 Check states after RU awake and L3 call
    Log to console  \n========================================
    Log  Step: 9 Check states after RU awake and L3 call  console=true
    Log to console  ========================================
    Log To Console  Waiting for deep sleep end
    Wait for date  ${DEEPSLEEP_TIME_SCHEDULE_END_TIME}  60
    Wait Until Keyword Succeeds  12min  15s  Check RU state for DEEPSLEEP  ${SELECTED_RMOD_A}  AWAKE
    FOR  ${item}  IN  @{SELECTED_ALIAS_GSM_CELLS}
        Log to console  Unblocking ${item}
        admin.Unblock Cell  ${item}  timeout=120
    END
    FOR  ${item}  IN  @{SELECTED_ALIAS_WCDMA_CELLS}
        Log to console  Unblocking ${item}
        admin.Unblock Cell  ${item}  timeout=120
    END
    Check If NLWG Cells Are OnAir


PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test_Step:10 Final Recovery and Checkpoint
    Log to console  \n========================================
    Log  Step: 10 Final Recovery and Checkpoint  console=true
    Log to console  ========================================
    Log  feature deactivation  console=true
    Set Feature Under FEATCADM Via NA  actRadioDeepSleepTimeSchedule  false
    Log  deepSleepTimeSchedule will be removed  console=true
    IF  ${LTE_CHOSEN}  Set Feature Under Given Object  ${LNBTS_DistName}  actLBRTXPowerSaving  true
    Remove RMOD deepSleepTimeSchedule  ${SELECTED_RMOD_2}
    Change Energy Saving Mode Back To Normal  ${SELECTED_RMOD_2}
    Remove PSGRP/NRPGRP Objects If Exist  PSGRP
    Remove PSGRP/NRPGRP Objects If Exist  NRPGRP
    IF  ${LTE_CHOSEN}  Set Feature Under Given Object  ${LNBTS_DistName}  actLBPowerSaving  false
    IF  ${NR_CHOSEN}  Set Feature Under Given Object  ${NRBTS_DistName}  actNrLBPowerSaving  false


PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test Specific Teardown
    [Documentation]  Test Specific Teardown.

    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    Change Energy Saving Mode Back To Normal  ${SELECTED_RMOD_2}
    admin.Setup Admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Log  \nRestoring original configuration settings  console=true
    admin.Perform Commissioning  ${MRBTS_ID}  ${RESULTS}/SCF_BACKUP.xml  ${SKIP_PARAMETER_RELATION_ERRORS}  ${SHOULD_ACTIVATE}  timeout=600
    admin.Teardown Admin  alias=${ute_admin_alias}
    FOR  ${item}  IN  @{SELECTED_ALIAS_GSM_CELLS}
        Log to console  Unblocking ${item}
        admin.Unblock Cell  ${item}  timeout=120
    END
    FOR  ${item}  IN  @{SELECTED_ALIAS_WCDMA_CELLS}
        Log to console  Unblocking ${item}
        admin.Unblock Cell  ${item}  timeout=120
    END
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n


PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test Case Teardown
    Run Keywords  common.Common Test Teardown  AND  Teardown TAF Netact
    Run Keyword If Test Failed  PS.48_CB010766-SR-A-5_Activate_RU-deep_sleep_when_RU_is_enabled_from_rat_reset.Test Specific Teardown


Create Dynamic 1103 PSGRP
    [Documentation]
    ...  **Example of simple usage:**
    ...  Create Dynamic 1103 PSGRP  ${SELECTED_ALIAS_LTE_CELLS}  766  55
    [Arguments]  ${SELECTED_ALIAS_LTE_CELLS}  ${PSGRP-ID}=766  ${lbpsDuration}=55

    ${selected_LTE_cells}  Create List
    FOR  ${item}  IN  @{SELECTED_ALIAS_LTE_CELLS}
        ${split_cell}  Split String  ${item}  -
        Append To List  ${selected_LTE_cells}  ${split_cell[-1]}
    END
    ${delta_create_psgrp}  Set Variable  psgrp_create
    ${PSGRP_DN}  Set Variable  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${PSGRP-ID}
    admin.Create Delta  ${delta_create_psgrp}
    admin.Append Managed Object To Delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${PSGRP-ID}  create  ${delta_create_psgrp}
    admin.Append Parameter Update To Delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${PSGRP-ID}  lbpsCSONCtlEnabled  false  ${delta_create_psgrp}
    admin.Append Parameter Update To Delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${PSGRP-ID}  lbpsLastCellMinLoad  0  ${delta_create_psgrp}
    admin.Append Parameter Update To Delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${PSGRP-ID}  lbpsLastCellRTXMinLoad  0  ${delta_create_psgrp}
    admin.Append Parameter Update To Delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${PSGRP-ID}  lbpsLastCellSOEnabled  true  ${delta_create_psgrp}
    admin.Append Parameter Update To Delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${PSGRP-ID}  lbpsMaxLoad  100  ${delta_create_psgrp}
    admin.Append Parameter Update To Delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${PSGRP-ID}  lbpsMinLoad  0  ${delta_create_psgrp}
    admin.Append Parameter Update To Delta  MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${PSGRP-ID}  lbpsPdcchLoadOffset  4  ${delta_create_psgrp}
    ${sw_splited}  Split String  ${active_sw_version}  _
    ${sw_prefix}  Get From List  ${sw_splited}  0
    Run Keywords  admin.Append Parameter Update To Delta  ${PSGRP_DN}  lbpsGuardTimerNrAct  20  ${delta_create_psgrp}
    ...  AND  admin.Append Parameter Update To Delta  ${PSGRP_DN}  lbpsMaxLoadNrAct  40  ${delta_create_psgrp}
    ...  AND  admin.Append Parameter Update To Delta  ${PSGRP_DN}  lbpsMinNumEndcCapUeNrAct  0  ${delta_create_psgrp}
    ...  AND  admin.Append Parameter Update To Delta  ${PSGRP_DN}  lbpsMonWinNrAct  5  ${delta_create_psgrp}
    ...  AND  admin.Append Parameter Update To Delta  ${PSGRP_DN}  lbpsRetryTimerNrAct  5  ${delta_create_psgrp}
    ${actMixedSOMethod_state}  Check parameter availability under LNBTS  actMixedSOMethod
    IF  '${actMixedSOMethod_state}'=='PASS'
    ...  admin.Append Parameter Update To Delta  ${PSGRP_DN}  lbpsSOMethod  Cell Switch Off  ${delta_create_psgrp}
    ${lbpsCellList}  Create Dictionary
    FOR  ${i}  ${cell}  IN ENUMERATE  @{selected_LTE_cells}
        Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
        ${order}  Evaluate  ${i} + 1
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${order}
        Set To Dictionary  ${lbpsCellList}  lnCelId=${cell}
        admin.Append Complex Item To Delta  ${PSGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_psgrp}
    END
    Get Time And Date With Minute Offset  3minutes
    ${lbpsPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    ${lbpsDuration}  Get Regexp Matches  ${lbpsDuration}  \\d+
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${lbpsDuration[0]}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
    admin.Append Complex Item To Delta  ${PSGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_psgrp}
    admin.Get Delta  ${delta_create_psgrp}
    admin.Save Delta  ${RESULTS}/delta_create_psgrp_PSGRP-${PSGRP-ID}_LTE1103.json  ${delta_create_psgrp}
    Log  Activate Power Saving Group under MRBTS-${MRBTS_ID}/LNBTS-${MRBTS_ID}/PSGRP-${PSGRP-ID}  console=true
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_create_psgrp_PSGRP-${PSGRP-ID}_LTE1103.json  ${delta_create_psgrp}
    ${end_time}  Add Time To Date  ${time_with_offset}  ${lbpsDuration[0]} minutes
    ${end_hour}  Convert Date  ${end_time}  result_format=%H
    ${end_minutes}  Convert Date  ${end_time}  result_format=%M
    Log  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${lbpsDuration[0]} minutes)  console=true
    Log  Affected cells in PSGRP-${PSGRP-ID}: ${SELECTED_ALIAS_LTE_CELLS}  console=true


Create Dynamic 1103 NRPGRP
    [Documentation]  Creates and activates NRPGRP.
    [Arguments]  ${SELECTED_ALIAS_NR_CELLS}  ${NRPGRP-ID}=766  ${lbpsDuration}=55

    ${selected_NR_cells}  Create List
    FOR  ${item}  IN  @{SELECTED_ALIAS_NR_CELLS}
        ${split_cell}  Split String  ${item}  -
        Append To List  ${selected_NR_cells}  ${split_cell[-1]}
    END
    ${delta_create_nrpgrp}  Set Variable  nrpgrp_create
    ${NRPGRP_DN}  Set Variable  MRBTS-${MRBTS_ID}/NRBTS-${NRBTS_ID}/NRPGRP-${NRPGRP-ID}
    admin.Create Delta  ${delta_create_nrpgrp}
    admin.Append Managed Object To Delta  ${NRPGRP_DN}  create  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsCSONCtlEnabled  false  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsLastCellMinLoad  2  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsLastCellSOEnabled  true  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsLoadCalcMethod  Max(G_N_combined, P)  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsMaxLoad  30  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsMinLoad  20  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsMonWinForCellSOff  60  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsMonWinForCellSOn  120  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsSOffTrRule  SlidingAverageMethod  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsPdcchLoadOffset  4  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsSOMethod  cell switch off  ${delta_create_nrpgrp}
    admin.Append Parameter Update To Delta  ${NRPGRP_DN}  lbpsSOnTrRule  SlidingAverageMethod  ${delta_create_nrpgrp}
    ${lbpsCellList}  Create Dictionary
    FOR  ${i}  ${cell}  IN ENUMERATE  @{selected_NR_cells}
        ${order}  Evaluate  ${i} + 1
        Set To Dictionary  ${lbpsCellList}  lbpsCellSOOrder=${order}
        Set To Dictionary  ${lbpsCellList}  nrCellId=${cell}
        Set To Dictionary  ${lbpsCellList}  lbpsUseExtConfig  false
        admin.Append Complex Item To Delta  ${NRPGRP_DN}  list_name=lbpsCellList  &{lbpsCellList}  delta_id=${delta_create_nrpgrp}
    END
    Get Time And Date With Minute Offset  4minutes  5minutes
    ${lbpsPeriodList}  Create Dictionary
    Set To Dictionary  ${lbpsPeriodList}  lbpsDayOfWeek=${day}
    ${lbpsDuration}  Get Regexp Matches  ${lbpsDuration}  \\d+
    Set To Dictionary  ${lbpsPeriodList}  lbpsDuration=${lbpsDuration[0]}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeHour=${start_hour}
    Set To Dictionary  ${lbpsPeriodList}  lbpsStartTimeMinute=${start_minutes}
    Set To Dictionary  ${lbpsPeriodList}  lbpsSuspended=notSuspended
    admin.Append Complex Item To Delta  ${NRPGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_nrpgrp}
    Log  Power Saving Group time frame: ${start_hour}:${start_minutes}-${end_hour}:${end_minutes} (+${lbpsDuration[0]} minutes)  console=true
    admin.Append Complex Item To Delta  ${NRPGRP_DN}  list_name=lbpsPeriodList  &{lbpsPeriodList}  delta_id=${delta_create_nrpgrp}
    admin.Get Delta  ${delta_create_nrpgrp}
    admin.Save Delta  ${RESULTS}/delta_create_nrpgrp_CB008745.json  ${delta_create_nrpgrp}
    Log  Activate Power Saving Group under ${NRPGRP_DN}  console=true
    admin.Perform Delta Recommissioning  ${RESULTS}/delta_create_nrpgrp_CB008745.json  ${delta_create_nrpgrp}
