*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/oam_kpi.robot

Documentation
...  TEST NAME:     SM.04_Cell_Block_Unblock
...  AUTHORS:       aleksandra.trojak@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to perform cell block and unblock operation for random cell for selected RAT on a given TL
...  and then check eNB status after operation is finished.
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  09.11.2021 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - Test creation
...  05.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-444 - robotws migration and small hotfixes
...  27.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-480 - fix unit_path check for cells with cellName parameter defined
...  08.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-567 - add energysaving states to be considered in Step 1 during cell states check
...  and add KWs "First Preparation", "Map IoT To Host Cells" and "Check If Host Cell Is Energysaving" for IoT cells check.
...  23.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-591 - change KW "First Preparation" to a more telling name:
...  "Prepare For IoT Cells And LTE Reduced Energy Saving" and ensure it is ran only when LTE is present
...  11.09.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-26903 - Check only blocking state if cell is switchingOff
...  26.11.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-22855 - Adapt code to use suite variable ${BTS_NAME}
...  *******************
...  RAN PZ3 WRO1 TEMPLATE




*** Keywords ***
SM.04_Cell_Block_Unblock

    SM.04_Cell_Block_Unblock.Test_Step:0 Test Preparation
    SM.04_Cell_Block_Unblock.Test_Step:1 Perform Cell Block
    SM.04_Cell_Block_Unblock.Test_Step:2 Perform Cell Unblock
    SM.04_Cell_Block_Unblock.Test_Step:3 KPI Time Measurement

SM.04_Cell_Block_Unblock.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation  console=${True}
    Log to console    ========================================
    ${COUNTER_BEFORE_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    Set Test Variable  ${COUNTER_BEFORE_TEST}
    Run Keyword If  ${ITERATION_INDEX}==1
    ...             Run Keyword If  'lte' in $rats  SM.04_Cell_Block_Unblock.Prepare For IoT Cells And LTE Reduced Energy Saving
    ...                       ELSE  Set Test Variable  ${iot_to_host_mapping}  []
    Resolve Blocked Cells
    Check If NLWG Cells Are OnAir
    SCF Backup
    ${cells_list}  admin.get cell list
    ${cells_list['cells']['lte']}  Get Cells List Without IoT
    ${each_RAT_cell}  Create List
    FOR  ${rat}  IN  @{rats}
        ${selected_dict}  Evaluate  random.choice(${cells_list['cells']['${rat}']})  random
        Append To List  ${each_RAT_cell}  ${selected_dict['id']['configuration']}
    END
    ${cell_choice}  Evaluate  random.choice(${each_RAT_cell})  random
    Log To Console  Selected cell: ${cell_choice}
    ${selected_cell}  Create List   ${cell_choice}
    Set Test Variable  ${selected_cell}

SM.04_Cell_Block_Unblock.Test_Step:1 Perform Cell Block
    Log to console    \n========================================
    Log  Step: 1 Perform Cell Block  console=${True}
    Log to console    ========================================
    Allow Fault In Watchdog  faultID=49  #fault_name: Cell blocked
    FOR  ${cell}  IN  @{selected_cell}
        ${4G_or_5G}  Run Keyword And Return Status  Evaluate  re.search(r'(LN|NR)CEL+', '${cell}').group(0)  re
        ${cellName}  Run Keyword If  ${4G_or_5G}  Get Representative CellName  ${cell}
        Log To Console  Blocking: ${cell}
        admin.block cell  ${cell}  timeout=180
        ${unit_path}  Set Variable If  ${4G_or_5G}  [${BTS_NAME}][${cellName}] ${cell}  [${BTS_NAME}] ${cell}
        ${unit_path}  Evaluate   re.sub('\\[--\\]','','''${unit_path}''')  re
        Wait For Active Fault  faultID=49  unit_path=${unit_path}  timeout=30 sec
    END
    ${cells_list}  admin.get cell list
    ${cells}  Combine Lists    ${cells_list['cells']['lte']}
                      ...      ${cells_list['cells']['wcdma']}
                      ...      ${cells_list['cells']['gsm']}
                      ...      ${cells_list['cells']['nr']}
    FOR  ${cell}  IN  @{cells}
        ${values}  Get Dictionary Values  ${cell}
        ${cell_states}        Get From Dictionary  ${cell}         status
        ${blocking_state}     Get From Dictionary  ${cell_states}  blockingState
        ${operational_state}  Get From Dictionary  ${cell_states}  operationalState
        ${status}  ${energysaving_state}  Run Keyword And Ignore Error  Get From Dictionary  ${cell}  energySavingState
        ${is_energysaving}  Run Keyword If  'PASS' in $status
        ...                                 Run Keyword And Return Status
        ...                                 Should Be Equal As Strings  ${energysaving_state}  EnergySaving  ignore_case=True
        ...                           ELSE  Set Variable  False
        ${cell_is_selected_cell}  Run Keyword And Return Status  List Should Contain Value  ${selected_cell}  ${cell['id']['configuration']}
        ${is_iot}  Run Keyword And Return Status  List Should Contain Value  ${iot_to_host_mapping}  ${cell['id']['configuration']}
        ${host_cell}              Run Keyword If  ${is_iot}  Get From Dictionary  ${iot_to_host_mapping}  ${cell['id']['configuration']}
        ${host_is_energysaving}   Run Keyword If  ${is_iot}  Check If Host Cell Is Energysaving  ${host_cell}  ${cells_list['cells']['lte']}
        ${selected_cell_is_host}  Run Keyword If  ${is_iot}  Run Keyword And Return Status
        ...                                       List Should Contain Value  ${selected_cell}  ${host_cell}
        ${is_switchingOff}  Run Keyword And Return Status  Should Match Regexp  ${energysaving_state}  SwitchingOff  flags=IGNORECASE
        Run Keyword If  ${cell_is_selected_cell} or ${selected_cell_is_host}  Run Keywords
        ...           Should Be Equal As Strings  ${blocking_state}     Blocked    ignore_case=True
        ...    AND    Should Be Equal As Strings  ${operational_state}  Disabled   ignore_case=True
        ...  ELSE IF  ${is_energysaving} or ${host_is_energysaving}  Run Keywords
        ...           Should Be Equal As Strings  ${blocking_state}     Unblocked  ignore_case=True
        ...    AND    Should Be Equal As Strings  ${operational_state}  Disabled   ignore_case=True
        ...  ELSE IF  ${is_switchingOff}
        ...           Should Be Equal As Strings  ${blocking_state}     Unblocked  ignore_case=True
        ...  ELSE  Run Keywords
        ...           Should Be Equal As Strings  ${blocking_state}     Unblocked  ignore_case=True
        ...    AND    Should Be Equal As Strings  ${operational_state}  Enabled    ignore_case=True
    END

SM.04_Cell_Block_Unblock.Test_Step:2 Perform Cell Unblock
    Log to console    \n========================================
    Log  Step: 2 Perform Cell Unblock  console=${True}
    Log to console    ========================================
    FOR  ${cell}  IN  @{selected_cell}
        ${4G_or_5G}  Run Keyword And Return Status  Evaluate  re.search(r'(LN|NR)CEL+', '${cell}').group(0)  re
        ${cellName}  Run Keyword If  ${4G_or_5G}  Get Representative CellName  ${cell}
        Log To Console  Unblocking: ${cell}
        admin.unblock cell  ${cell}  timeout=180
        ${unit_path}  Set Variable If  ${4G_or_5G}  [${BTS_NAME}][${cellName}] ${cell}  [${BTS_NAME}] ${cell}
        ${unit_path}  Evaluate   re.sub('\\[--\\]','','''${unit_path}''')  re
        Wait For Inactive Fault  faultID=49  unit_path=${unit_path}  timeout=30 sec
    END
    Disallow Fault In Watchdog  faultID=49  #fault_name: Cell blocked
    Check If NLWG Cells Are OnAir
    ${if_gsm_exist}  Run Keyword And Return Status  List Should Contain Value  ${rats}  gsm
    Run Keyword If  ${if_gsm_exist}  Wait Until Keyword Succeeds  3min  30s  Check State on GNCELs  availabilityStatus  None
    Sleep  5s
    ${COUNTER_AFTER_TEST}  Get Reset Counter From Blackbox  COLLECT_BLACKBOX_FILE=${True}  iteration=${ITERATION_INDEX}
    ${counter_diff}  Evaluate  abs(${COUNTER_AFTER_TEST} - ${COUNTER_BEFORE_TEST})
    Run Keyword If  ${counter_diff}!=${0}  Log  Reset Counter Incremented +${counter_diff}  WARN

SM.04_Cell_Block_Unblock.Test_Step:3 KPI Time Measurement
    Log to console    \n========================================
    Log  Step: 3 KPI Time Measurement  console=${True}
    Log to console    ========================================
    FOR  ${cell}  IN  @{selected_cell}
        ${ignore}  ${cell-id}  Split String From Right  ${cell}  separator=/  max_split=1
        Log To Console    KPIs for ${cell-id}:
        ${cell_dn_r}    Get Representative Cell _R    ${cell}
        Run Keyword And Ignore Error  Calculate KPI17a KPI17b  ${cell_dn_r}  ${ITERATION_INDEX}
    END

SM.04_Cell_Block_Unblock.Test Specific Teardown
    [Documentation]  Test teardown which unblock selected cells.
    admin.setup admin  admin_api_log_dir=${RESULTS}/specific_teardown/admin_api/  alias=${ute_admin_alias}
    FOR  ${cell}  IN  @{selected_cell}
        Log To Console With Time  Trying to unblock: ${cell}
        Run Keyword And Ignore Error  admin.unblock cell  ${cell}  timeout=180
        Sleep  60s
    END
    admin.teardown admin  alias=${ute_admin_alias}

SM.04_Cell_Block_Unblock.Test Case Teardown
    Run Keyword  common.Common Test Teardown - MEMORY
    Run Keyword If Test Failed  SM.04_Cell_Block_Unblock.Test Specific Teardown

SM.04_Cell_Block_Unblock.Prepare For IoT Cells And LTE Reduced Energy Saving
    ${lnbts_m}  Get Managed Objects  LNBTS_M
    FOR  ${object}  IN  @{lnbts_m}
        ${LNBTS_ID}  Set Variable  ${object['parameters']['lnbtsId']}
    END
    ${actLBRTXPowerSaving}  Check Feature Availability And Value  parameter=actLBRTXPowerSaving
    ...                                                           value_to_set=true
    ...                                                           feature_under=LNBTS
    ${actLBRTXPowerSaving_value}  Get From Dictionary  ${actLBRTXPowerSaving}  initial_value
    Run Keyword If  'true' in $actLBRTXPowerSaving_value
    ...             Set Parameter To Expected Value  dist_name=MRBTS-${MRBTS_ID}/LNBTS-${LNBTS_ID}
    ...                                              parameter=actOnlineTXSwitch
    ...                                              expected_value=true
    ${iot_to_host_mapping}  Map IoT To Host Cells
    Set Test Variable  ${iot_to_host_mapping}

Map IoT To Host Cells
    ${cells_list}  admin.get cell list
    ${lncel_l}  Get Managed Objects  LNCEL_L
    ${lte_configuration_ids}  Create Dictionary
    FOR  ${cell}  IN  @{cells_list['cells']['lte']}
        ${cell_id}  Fetch From Right  ${cell['id']['configuration']}  marker=-
        Set To Dictionary  ${lte_configuration_ids}  ${cell_id}  ${cell['id']['configuration']}
    END
    ${iot_cells}  Create Dictionary
    FOR  ${object}  IN  @{lncel_l}
        Continue For Loop If  '${object['parameters']['nbIoTMode']}'!='host'
        ${nbIotLinkedCellId}  Get From Dictionary  ${object['parameters']}  nbIotLinkedCellId
        ${host_id}  Fetch From Right  ${object['distName']}  marker=-
        Set To Dictionary  ${iot_cells}  ${nbIotLinkedCellId}  ${host_id}
    END
    ${iot_to_host_mapping}  Create Dictionary
    FOR  ${object}  IN  @{iot_cells}
        ${host_id}    Get From Dictionary  ${iot_cells}  ${object}
        ${host_cell}  Get From Dictionary  ${lte_configuration_ids}  ${host_id}
        ${iot_cell}   Set Variable  ${lte_configuration_ids['${object}']}
        Set To Dictionary  ${iot_to_host_mapping}  ${iot_cell}  ${host_cell}
    END
    [Return]  ${iot_to_host_mapping}

Check If Host Cell Is Energysaving
    [Documentation]  KW checks if given cell is in EnergySaving state and returns status.
    [Arguments]  ${host_cell}  ${lte_cells_list}
    FOR  ${cell}  IN  @{lte_cells_list}
        Continue For Loop If  '${cell['id']['configuration']}'!='${host_cell}'
        ${energysaving_state}  Get From Dictionary  ${cell}  energySavingState
        ${cell_energysaving_status}  Run Keyword And Return Status
        ...                          Should Be Equal As Strings  ${energysaving_state}  EnergySaving  ignore_case=True
        Exit For Loop
    END
    [Return]  ${cell_energysaving_status}
