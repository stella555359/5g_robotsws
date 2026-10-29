*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/netact.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot

Documentation
...  TEST NAME:     PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window
...  AUTHORS:       damian.sliwinski@nokia.com
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
...  13.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-430 - TC creation
...  05.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29187 - Included functionality to skip RMODs that have
...               IoT cells under them and updated TC to RF 5.0 standards
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Keywords ***
PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window

    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test_Step:0 Test Preparation
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test_Step:1 Enable feature CB10766
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test_Step:2 Cells block
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test_Step:3 Check RU state
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test_Step:4 Lock RU
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test_Step:5 Check RU state
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test_Step:6 Unlock RU
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test_Step:7 Check RU state
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test_Step:8 Cells unblock
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test_Step:9 Check states after RU awake and L3 call
    PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test_Step:10 Final Recovery and Checkpoint


PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test_Step:0 Test Preparation
    Log to console  \n========================================
    Log  Step: 0 Test Preparation  console=true
    Log to console  ========================================
    netact.Upload Configuration  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}
    ${rmod_r_a_list}  Mapping RMOD_R To RMOD_A
    ${rmod_r_objects}  admin.Get Managed Objects  RMOD_R
    ${rmod_r_model}  Create Dictionary
    ${BTS_NAME}  Get BTS Name
    Set Test Variable  ${BTS_NAME}
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
    Set Test variable  ${channels}
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
         ${rmod_data}  IF  '${antl}'!='None'  Set Variable  ${antl}  ELSE  Set Variable  ${resourceDN}
         ${rmod_id}  Get Regexp Matches  ${rmod_data}  RMOD_A-\\d+
         ${rmod_id_without_a}  Remove String  '${rmod_id[0]}'  _A
         Set Test Variable  ${rmod_id_without_a}
         IF  '${randomrmod_id}' == ${rmod_id_without_a}  Get Cells From CHANNEL_A
    END
    ${SELECTED_ALIAS_CELLS}  Remove Duplicates  ${SELECTED_ALIAS_CELLS}
    Set Test variable  ${SELECTED_ALIAS_CELLS}
    Log  Cells affected by RMOD reset: ${SELECTED_ALIAS_CELLS}  console=true
    Create And Activate RMOD deepSleepTimeSchedule  ${SELECTED_RMOD_2}  5  40  #01.08.25 50min before PR840306
    Log  Selected RMOD_A: ${rmod_r_a_list}  console=true


PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test_Step:1 Enable feature CB10766
    Log  Enabling feature flag via NA  console=true
    Set Feature Under FEATCADM Via NA  actRadioDeepSleepTimeSchedule  true


PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test_Step:2 Cells block
    Allow Fault In Watchdog  faultID=49  #fault_name: Cell blocked
    FOR  ${cell}  IN  @{SELECTED_ALIAS_CELLS}
        ${cell}  Get Substring  ${cell}  1
        Log To Console  Blocking: ${cell}
        admin.Block Cell  ${cell}  timeout=180
        Sleep    10s    _reason=Wait for alarms
        Wait For Active Fault  faultID=49  unit_path=[${BTS_NAME}] ${cell}  timeout=30 sec
    END


PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test_Step:3 Check RU state
    Log To Console  Waiting 22 min for deep sleep
    Wait Until Keyword Succeeds  22min  30s  Check RU state for DEEPSLEEP  ${SELECTED_RMOD_A}  SLEEP


PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test_Step:4 Lock RU
    Log to console  \n========================================
    Log  Step: 2 Perform RMOD Lock  console=true
    Log to console  ========================================
    Log To Console  Lock RMOD: ${SELECTED_RMOD}
    ${status}  Run Keyword And Return Status  admin.Lock  ${SELECTED_RMOD}  timeout=180
    IF  not ${status}  admin.Lock  ${SELECTED_RMOD}  timeout=180
    Log To Console  Checking if selected RMOD has reached the expected state: administrativeState=Locked, the rest of the RMODs should be Unlocked
    ${bts_info}  admin.Get Bts Info
    FOR  ${rmod}  IN  @{bts_info['radioModules']['rmod']}
        ${rmod_states}  Get From Dictionary  ${rmod}  status
        ${administrative_state}  Get From Dictionary  ${rmod_states}  administrativeState
        IF  '${rmod['id']['configuration']}'=='${SELECTED_RMOD}'
            Should Be Equal As Strings  ${administrative_state}  Locked  ignore_case=True
        ELSE
            Should Be Equal As Strings   ${administrative_state}  Unlocked   ignore_case=True
        END
        Log To Console  State of ${rmod['id']['configuration']} is correct
    END


PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test_Step:5 Check RU state
    Log To Console  Waiting for AWAKE state for RF
    Wait Until Keyword Succeeds  15min  30s  Check RU state for DEEPSLEEP  ${SELECTED_RMOD_A}  AWAKE
#RU not expected to enter DSM after PR840306
#    Log To Console  Waiting 22 min for deep sleep
#    Wait Until Keyword Succeeds  22min  30s  Check RU state for DEEPSLEEP  ${SELECTED_RMOD_A}  SLEEP


PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test_Step:6 Unlock RU
    Log to console  \n========================================
    Log  Step: 3 Perform RMOD Unlock  console=true
    Log to console  ========================================
    Log To Console  Unlock RMOD: ${SELECTED_RMOD}
    ${status}  Run Keyword And Return Status  admin.Unlock  ${SELECTED_RMOD}  timeout=180
    IF  not ${status}  admin.Unlock  ${SELECTED_RMOD}  timeout=180
    Log To Console  Unlock RMOD is done


PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test_Step:7 Check RU state
    Log To Console  Waiting for AWAKE state for RF
    Wait Until Keyword Succeeds  9min  30s  Check RU state for DEEPSLEEP  ${SELECTED_RMOD_A}  AWAKE
    Log To Console  Waiting 22min for deep sleep
    Wait Until Keyword Succeeds  22min  30s  Check RU state for DEEPSLEEP  ${SELECTED_RMOD_A}  SLEEP
    Log To Console  Waiting 30 min for deep sleep end
    Wait Until Keyword Succeeds  30min  60s  Check RU state for DEEPSLEEP  ${SELECTED_RMOD_A}  AWAKE


PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test_Step:8 Cells unblock
    Sleep  30s
    FOR  ${item}  IN  @{SELECTED_ALIAS_CELLS}
        ${item_2}  Get Substring  ${item}  1
        Log To Console  Unblocking: ${item_2}
        admin.Unblock Cell  ${item_2}  timeout=180
        Wait For Inactive Fault  faultID=49  unit_path=[${BTS_NAME}] ${item_2}  timeout=30 sec
    END
    Disallow Fault In Watchdog  faultID=49  #fault_name: Cell blocked


PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test_Step:9 Check states after RU awake and L3 call
    Check If NLWG Cells Are OnAir


PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test_Step:10 Final Recovery and Checkpoint
    Log to console  \n========================================
    Log  Step: 10 Final Recovery and Checkpoint  console=true
    Log to console  ========================================
    Log  feature deactivation  console=true
    Set Feature Under FEATCADM Via NA  actRadioDeepSleepTimeSchedule  false
    Log  deepSleepTimeSchedule will be removed  console=true
    Remove RMOD deepSleepTimeSchedule  ${SELECTED_RMOD_2}
    Change Energy Saving Mode Back To Normal  ${SELECTED_RMOD_2}


PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test Specific Teardown
    [Documentation]  Test Specific Teardown.

    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    Change Energy Saving Mode Back To Normal  ${SELECTED_RMOD_2}
    admin.Setup Admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Log  \nRestoring original configuration settings  console=true
    admin.Perform Commissioning  ${MRBTS_ID}  ${RESULTS}/SCF_BACKUP.xml  ${SKIP_PARAMETER_RELATION_ERRORS}  ${SHOULD_ACTIVATE}  timeout=600
    admin.Teardown Admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n


PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test Case Teardown
    Run Keywords  common.Common Test Teardown  AND  Teardown TAF Netact
    Run Keyword If Test Failed  PS.47_CB010766_Lock_unlock_RU_when_RU_is_in_deep_sleep_mode_during_the_time_window.Test Specific Teardown
