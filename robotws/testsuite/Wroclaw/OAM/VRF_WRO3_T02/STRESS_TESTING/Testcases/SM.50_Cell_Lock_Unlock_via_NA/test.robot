*** Settings ***
Resource    ../../../resources_mem/common.robot
Resource    ../../../resources_mem/alarms.robot
Resource    ../../../resources_mem/power_saving.robot
Resource    ../../../resources_mem/oam_kpi.robot

Documentation
...  TEST NAME:     SM.50_Cell_Lock_Unlock_via_NA
...  AUTHORS:       sebastian.suwada@nokia.com
...  MAINTAINER:    VRF_WRO3_T02
...  *****************
...  Basic information
...  *****************
...  The purpose of this test case is to perform cell lock and unlock operation for random LTE
...  cell for selected RAT on a given TL and then check eNB status after operation is finished.
...  EDA Action For 04757534 - https://jiradc.ext.net.nokia.com/browse/RDI-27100
...  *****************
...  Pre-conditions
...  *****************
...  N/A
...  ******************
...  History of changes
...  ******************
...  24.09.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-26904 - Test creation
...  *******************
...  VRF_WRO3_T02 TEMPLATE

*** Variables ***
${is_locked}    False

*** Keywords ***
SM.50_Cell_Lock_Unlock_via_NA
    SM.50_Cell_Lock_Unlock_via_NA.Test_Step:0 Test Preparation
    SM.50_Cell_Lock_Unlock_via_NA.Test_Step:1 Perform Cell lock
    SM.50_Cell_Lock_Unlock_via_NA.Test_Step:2 Perform Cell Unlock

SM.50_Cell_Lock_Unlock_via_NA.Test_Step:0 Test Preparation
    Log to console    \n========================================
    Log  Step: 0 Test Preparation    console=${True}
    Log to console    ========================================
    Resolve Blocked Cells
    Check If NLWG Cells Are OnAir
    Run Keyword If  ${INTEGRATED_TO_NETACT}  Wait Until Keyword Succeeds  2x  10s  Check Cells State In Netact
    SCF Backup
    Select Cell to be locked and setup variables

SM.50_Cell_Lock_Unlock_via_NA.Test_Step:1 Perform Cell lock
    Log to console    \n========================================
    Log  Step: 1 Lock random LTE cell    console=${True}
    Log to console    ========================================
    Change parameter via Netact    administrativeState     3    ${selected_cell}[0]    ${cell_version}    ${cell_class}
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    common.Check BTS State  ${BTS_expected_states}
    Check cells when selected cell is locked

SM.50_Cell_Lock_Unlock_via_NA.Test_Step:2 Perform Cell Unlock
    Log to console    \n========================================
    Log  Step: 2 Unlock selected LTE cell    console=${True}
    Log to console    ========================================
    Change parameter via Netact    administrativeState     1    ${selected_cell}[0]    ${cell_version}    ${cell_class}
    Check SMODs State  ${SMOD_expected_states}
    Check RMODs State  ${RMOD_expected_states}
    Check If ALDs Are Connected And Achieved Expected State
    common.Check BTS State  ${BTS_expected_states}
    Check If NLWG Cells Are OnAir

SM.50_Cell_Lock_Unlock_via_NA.Test Case Teardown
    Run Keyword If    '${is_locked}'=='True'    Change parameter via Netact
    ...    administrativeState     1    ${selected_cell}[0]    ${cell_version}    ${cell_class}

Change parameter via Netact
    [Documentation]  Keyword setting indicated valuse for chosen feature under LNBTS/NRBTS objects Via NA
    ...  Example of usage:
    ...  Change parameter via Netact  administrativeState   3  ${selected_cell}[0]  ${cell_version}  ${cell_class}
    [Arguments]  ${parameter}  ${value}  ${distName}  ${meta_ver}  ${meta_class}
    ${current_date}=  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${SCF_PATH}=  Set Variable  ${RESULTS}/SCF_BACKUP.xml
    &{parameters_dict} =  Create Dictionary    ${parameter}=${value}
    Set Test Variable  ${delta}  MRBTS-${MRBTS_ID}-PLAN-${parameter}
    Run Keyword And Ignore Error  netact.delete plan  ${delta}
    ${plan}=  netact.create plan configuration  name=${delta}  description=WRO1 AUTOMATION ${delta}
    ${managed_objects}=  netact.create managed object  plan=${plan}  meta_class=${meta_class}
    ...  meta_version=${meta_ver}  mo_id=PLMN-PLMN/${distName}    &{parameters_dict}
    Log To Console  Plan provisioning via NetAct ${parameter} changing to ${value}
    ${status_edit}=    Run Keyword And Return Status    netact.edit_managed_object    ${managed_objects}
    ...    operation=UPDATE    &{parameters_dict}
    Run Keyword If    ${status_edit}    Run Keyword    Log To Console  Edit of managed object succeeded!
    ...    ELSE    Run Keyword    Log    Edit of managed object failed!    level=ERROR
    ${status_provision}=    Run Keyword And Return Status    netact.provision plan  ${delta}
    ...    dist_names=PLMN-PLMN/MRBTS-${MRBTS_ID}  create_backup_plan=true
    ...    backup_plan_name=${MRBTS_ID}_${current_date}_backup    provisioning_operation=activate
    Run Keyword If    ${status_provision}    Run Keyword    Log To Console  Provisioning succeeded!
    ...    ELSE    Run Keyword    Log    MO Provisioning failed!    level=ERROR
    Log To Console    Deleting managed object and plan configuration
    netact.delete_managed_object    ${managed_objects}
    netact.delete_plan_configuration    ${plan}
    Log To Console    Provisioning should be done!

Select Cell to be locked and setup variables
    ${bts_name}  Get BTS Name
    ${cells_list}  admin.get cell list
    ${cells_list['cells']['lte']}  Get Cells List Without IoT
    ${each_RAT_cell}  Create List
    ${filtered_rats}=    Set Variable    ${rats}
    Run Keyword If    'wcdma' in ${filtered_rats}    Remove Values From List    ${filtered_rats}    wcdma
    Run Keyword If    'gsm' in ${filtered_rats}    Remove Values From List    ${filtered_rats}    gsm
    Run Keyword If    'nr' in ${filtered_rats}    Remove Values From List    ${filtered_rats}    nr
    FOR  ${rat}  IN  @{rats}
        ${selected_dict}  Evaluate  random.choice(${cells_list['cells']['${rat}']})  random
        Append To List  ${each_RAT_cell}  ${selected_dict['id']['configuration']}
    END
    ${cell_choice}  Evaluate  random.choice(${each_RAT_cell})  random
#    ${selected_cell}  Set Variable    ${cell_choice}
    ${selected_cell}  Create List   ${cell_choice}
    ${cell_version}=  Get Meta Version Or Class From SCFC  ${RESULTS}/SCF_BACKUP.xml  ${selected_cell}[0]  version
    ${cell_class}=  Get Meta Version Or Class From SCFC  ${RESULTS}/SCF_BACKUP.xml  ${selected_cell}[0]  class
    Run Keyword If  'lte' in $rats  Set IoT cells variable
    ...     ELSE  Set Test Variable  ${iot_to_host_mapping}  []
    Set Test Variable  ${selected_cell}
    Set Test Variable   ${cell_version}
    Set Test Variable   ${cell_class}
    Set Test Variable  ${bts_name}
    Set Test Variable    ${is_locked}    False
    Log To Console  Selected cell: ${selected_cell}[0]
    Log To Console  Selected cell class: ${cell_class}
    Log To Console  Selected cell version: ${cell_version}

Set IoT cells variable
    ${iot_to_host_mapping}  Map IoT To Host Cells
    Set Test Variable  ${iot_to_host_mapping}

Check cells when selected cell is locked
    ${cells_list}  admin.get cell list
    ${cells}  Combine Lists    ${cells_list['cells']['lte']}
                      ...      ${cells_list['cells']['nr']}
    FOR  ${cell}  IN  @{cells}
        ${values}  Get Dictionary Values  ${cell}
        ${cell_states}        Get From Dictionary  ${cell}         status
        ${administrativeState}     Get From Dictionary  ${cell_states}  administrativeState
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
        Run Keyword If  ${cell_is_selected_cell} or ${selected_cell_is_host}  Run Keywords
        ...           Should Be Equal As Strings  ${administrativeState}      locked    ignore_case=True
        ...    AND    Should Be Equal As Strings  ${operational_state}        Disabled   ignore_case=True
        ...  ELSE IF  ${is_energysaving} or ${host_is_energysaving}           Run Keywords
        ...           Should Be Equal As Strings  ${administrativeState}      unlocked  ignore_case=True
        ...    AND    Should Be Equal As Strings  ${operational_state}        Disabled   ignore_case=True
        ...  ELSE  Run Keywords
        ...           Should Be Equal As Strings  ${administrativeState}      unlocked  ignore_case=True
        ...    AND    Should Be Equal As Strings  ${operational_state}        Enabled    ignore_case=True
        ${is_locked}=    Set Variable If    '${administrativeState}'=='locked'    True    False
        Set Test Variable    ${is_locked}
    END

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
