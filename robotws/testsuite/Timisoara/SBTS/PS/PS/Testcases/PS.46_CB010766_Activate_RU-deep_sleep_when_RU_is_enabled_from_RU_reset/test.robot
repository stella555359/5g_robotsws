*** Settings ***
Resource    ../../../resources/common.robot
Resource    ../../../resources/alarms.robot
Resource    ../../../resources/ald.robot
Resource    ../../../resources/netact.robot
Resource    ../../../resources/power_saving.robot
Resource    ../../../resources/L3_call.robot


Documentation
...  TEST NAME:     PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset
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
...  21.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-428 - TC creation
...  13.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-430 - TC adaptation to other tests from feature
...  05.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29187 - Included functionality to skip RMODs that have
...               IoT cells under them and updated TC to RF 5.0 standards
...  *******************
...  RAN PZ3 WRO1 TEMPLATE


*** Variables ***
${TESTED_RMOD_SN}  #Radio modul serial number to be used for testing the feature.


*** Keywords ***
PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset

    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test_Step:0 Test Preparation
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test_Step:1 Enable feature CB10766
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test_Step:2 Reset RU
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test_Step:3 Cells block
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test_Step:4 Check RU state
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test_Step:5 Check states after RU awake and L3 call
    PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test_Step:6 Final Recovery and Checkpoint


PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test_Step:0 Test Preparation
    Log to console  \n========================================
    Log  Step: 0 Test Preparation  console=true
    Log to console  ========================================
    netact.Upload Configuration  dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}
    ${rmod_r_a_list}  Mapping RMOD_R To RMOD_A
    ${rmod_r_objects}  admin.Get Managed Objects  RMOD_R
    ${rmod_r_model}  Create Dictionary
    ${lncells}  admin.Get Managed Objects  LNCEL_A
    ${nrcells}  admin.Get Managed Objects  NRCELL_A
    ${wncells}  admin.Get Managed Objects  WNCEL_A
    ${gncells}  admin.Get Managed Objects  GNCEL_A
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
    IF  '${TESTED_RMOD_SN}'!='${EMPTY}'
        FOR  ${radio}  IN  @{rmod_r_objects}
            IF  '${radio}[parameters][serialNumber]' == '${TESTED_RMOD_SN}'  BREAK
        END
        ${SELECTED_RMOD}  Set Variable  ${radio}[distName]
    ELSE
        ${SELECTED_RMOD}  Evaluate  random.choice(${5_1_rf_r})  random
    END
    ${contains_iot_cells}  Check If LNCEL IoT Cells Exist Under RMOD  ${SELECTED_RMOD}
    WHILE  ${contains_iot_cells}
        Remove Values From List  ${5_1_rf_r}  ${SELECTED_RMOD}
        ${SELECTED_RMOD}  Evaluate  random.choice(${5_1_rf_r})  random
        ${contains_iot_cells}  Check If LNCEL IoT Cells Exist Under RMOD  ${SELECTED_RMOD}
    END
    Log To Console  Selected RMOD: ${SELECTED_RMOD}
    Set Test Variable  ${SELECTED_RMOD}
    ${selected_RMOD_A}  Get From Dictionary  ${rmod_r_a_list}  ${SELECTED_RMOD}
    ${ignore}  ${selected_RMOD_A}  Split String From Right  ${selected_RMOD_A}  separator=SCF-1/
    ${SELECTED_RMOD_A}  Replace String  ${selected_RMOD_A}  search_for=_A  replace_with=
    Log To Console  Selected RMOD: ${SELECTED_RMOD}
    ${rmod_index}  Split String From Right  ${SELECTED_RMOD_A}  separator=-
    ${SELECTED_RMOD_2}  Set Variable  RMOD-${rmod_index}[-1]
    Set Test Variable  ${SELECTED_RMOD}
    Set Test Variable  ${SELECTED_RMOD_A}
    Set Test variable  ${SELECTED_RMOD_2}
    ${randomrmod_id}  Set Variable  ${SELECTED_RMOD_2}
    ${channels}  admin.Get Managed Objects  CHANNEL_A
    ${WNCELS_A}  admin.Get Managed Objects  WNCEL_A
    Set Test variable  ${WNCELS_A}
    ${wncel_a_to_lcelw_a}  Mapping WNCEL_A ID From LCELW_A
    Log to console  \n========================================
    Log  Checking which cells are affected by RMOD reset  console=true
    Log to console  ========================================
    ${selected_ants}  Create List
    ${SELECTED_ALIAS_CELLS}  Create List
    Set Test variable  ${SELECTED_ALIAS_CELLS}
    ${GRACEFUL_CELLS}  Create List
    Set Test variable  ${GRACEFUL_CELLS}
#    FOR  ${channel}  IN  @{channels}
#         ${CHANNEL_NAME}  Get From Dictionary  ${channel}  distName
#         Set Test Variable  ${CHANNEL_NAME}
#         ${antl}  Get From Dictionary  ${channel['parameters']}  antlDN
#         ${resourceDN}  Get From Dictionary  ${channel['parameters']}  resourceDN
#         ${rmod_data}=  IF  '${antl}'!='None'  Set Variable  ${antl}  ELSE  Set Variable  ${resourceDN}
#         ${rmod_id}  Get Regexp Matches  ${rmod_data}  RMOD_A-\\d+
#         ${rmod_id_without_A}  Remove String  '${rmod_id[0]}'  _A
#         IF  '${randomrmod_id}' == ${rmod_id_without_A}  Get Cells From CHANNEL_A
#    END
#    ${SELECTED_ALIAS_CELLS}  Remove Duplicates  ${SELECTED_ALIAS_CELLS}
    ${SELECTED_ALIAS_CELLS}  get cell mapping by module id    ${SELECTED_RMOD}
    Set Test variable  ${SELECTED_ALIAS_CELLS}
    Log  Cells affected by RMOD reset: ${SELECTED_ALIAS_CELLS}  console=true
    Create And Activate RMOD deepSleepTimeSchedule  ${SELECTED_RMOD_2}  10  40
    Log  Selected RMOD_A: ${rmod_r_a_list}  console=true


PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test_Step:1 Enable feature CB10766
    Log  Enabling feature flag via NA  console=true
    Set Feature Under FEATCADM Via NA  actRadioDeepSleepTimeSchedule  true


PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test_Step:2 Reset RU
    Log  Step: 2 Perform RMOD Reset  console=true
    admin.Reset Unit  ${SELECTED_RMOD}  timeout=700
    Log To Console  Checking if selected RMOD has reached the expected state: operationalState=Disabled, the rest of the RMODs should remain Enabled
    ${bts_info}  admin.Get Bts Info
    FOR  ${rmod}  IN  @{bts_info['radioModules']['rmod']}
        ${rmod_states}  Get From Dictionary  ${rmod}  status
        ${operational_state}  Get From Dictionary  ${rmod_states}  operationalState
        IF  '${rmod['id']['configuration']}'=='${SELECTED_RMOD}'
            Run Keyword And Ignore Error   Should Be Equal As Strings  ${operational_state}  disabled  ignore_case=True
        ELSE
            Run Keyword And Ignore Error  Should Be Equal As Strings  ${operational_state}  enabled   ignore_case=True
        END
        ${administrative_state}  Get From Dictionary  ${rmod_states}  administrativeState
        Should Be Equal As Strings  ${administrative_state}  Unlocked  ignore_case=True
        Log To Console  State of ${rmod['id']['configuration']} is correct
    END
    ${RMOD_R}  admin.Get Managed Objects  RMOD_A


PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test_Step:3 Cells block
    Allow Fault In Watchdog  faultID=49  #fault_name: Cell blocked
    ${cells_info}    get_cell_mapping_by_module_id    ${SELECTED_RMOD}
    FOR  ${cell}  IN  @{SELECTED_ALIAS_CELLS}
        ${cell}  Get Substring  ${cell}  1
        Log To Console  Blocking: ${cell}
        admin.Block Cell  ${cell}  timeout=180
        FOR    ${cell_info}    IN    @{cells_info}
            IF  '${cell_info}' == '${cell}'  BREAK
        END
        Wait For Active Fault  faultID=49  timeout=30 sec
    END


PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test_Step:4 Check RU state
    Log To Console  Waiting 22 min for deep sleep
    Wait Until Keyword Succeeds  22min  30s  Check RU state for DEEPSLEEP  ${SELECTED_RMOD_A}  SLEEP


PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test_Step:5 Check states after RU awake and L3 call
    Log To Console  Waiting 30 min for deep sleep end
    Wait Until Keyword Succeeds  30min  30s  Check RU state for DEEPSLEEP  ${SELECTED_RMOD_A}  AWAKE
    ${cells_info}    get_cell_mapping_by_module_id    ${SELECTED_RMOD}
    FOR  ${item}  IN  @{SELECTED_ALIAS_CELLS}
        ${item_2}  Get Substring  ${item}  1
        Log To Console  Unblocking: ${item_2}
        FOR    ${cell_info}    IN    @{cells_info}
            IF  '${cell_info}'=='${item_2}'  BREAK
        END
        admin.Unblock Cell  ${item_2}  timeout=180
    END
    Wait For Inactive Fault  faultID=49  timeout=30 sec
    Disallow Fault In Watchdog  faultID=49  #fault_name: Cell blocked
    Check If NLWG Cells Are OnAir


PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test_Step:6 Final Recovery and Checkpoint
    Log to console  \n========================================
    Log  Step: 3 Final Recovery and Checkpoint  console=true
    Log to console  ========================================
    Log  feature deactivation  console=true
    Set Feature Under FEATCADM Via NA  actRadioDeepSleepTimeSchedule  false
    Log  deepSleepTimeSchedule will be removed  console=true
    Remove RMOD deepSleepTimeSchedule  ${SELECTED_RMOD_2}
    Change Energy Saving Mode Back To Normal  ${SELECTED_RMOD_2}


PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test Specific Teardown
    [Documentation]  Test Specific Teardown.

    Log To Console  \n============ SPECIFIC TEST TEARDOWN =============
    Change Energy Saving Mode Back To Normal  ${SELECTED_RMOD_2}
    admin.Setup Admin  admin_api_log_dir=${RESULTS}/admin_api/  alias=${ute_admin_alias}
    Log  \nRestoring original configuration settings  console=true
    admin.Perform Commissioning  ${MRBTS_ID}  ${RESULTS}/SCF_BACKUP.xml  ${SKIP_PARAMETER_RELATION_ERRORS}  ${SHOULD_ACTIVATE}  timeout=600
    admin.Teardown Admin  alias=${ute_admin_alias}
    Log To Console  ========== SPECIFIC TEST TEARDOWN DONE ==========\n


PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test Case Teardown
    Run Keywords  common.Common Test Teardown  AND  Teardown TAF Netact
    Run Keyword If Test Failed  PS.46_CB010766_Activate_RU-deep_sleep_when_RU_is_enabled_from_RU_reset.Test Specific Teardown
