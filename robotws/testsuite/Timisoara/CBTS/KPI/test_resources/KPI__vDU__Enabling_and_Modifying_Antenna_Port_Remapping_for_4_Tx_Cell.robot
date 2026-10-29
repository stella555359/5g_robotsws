*** Settings ***
Documentation
    ...  This TC is created for enabling and modifying antenna port remapping for 4 Tx cell.
    ...  ${CELL_ID} and @{CHANNEL_ID_LIST} should not be empty!
    ...  actAntportMap is changed to true.
    ...  fault4592CancellationTimer is changed to 90 seconds.
    ...  Set unique iqStreamId for all 4 TX channels from specific cell id.
    ...  Values for iqStreamId are 0, 1, 2, 3.
    ...  Activate delta plan.
    ...  Verify fault 4592 to be visible.
    ...  Verify if the affected cell is offline and disabled.
    ...  Verify is the affected cell is onAir.
    ...  Verify if fault 4592 was active for 90 seconds.
    ...  Verify fault signature and additional information for fault 4592.
    ...  Collect snapshot after enabling the iqStreamId parameter.
    ...  fault4592CancellationTimer is changed to 60 seconds.
    ...  Modify iqStreamId for all 4 TX with values 3, 2, 1, 0.
    ...  Activate delta plan.
    ...  Verify fault 4592 to be visible.
    ...  Verify if the affected cell is offline and disabled.
    ...  Verify is the affected cell is onAir.
    ...  Verify if fault 4592 was active for 90 seconds.
    ...  Verify fault signature and additional information for fault 4592.
    ...  Collect snapshot after modifying the iqStreamId parameter.
    ...  actAntportMap is changed to false.
    ...  fault4592CancellationTimer is changed to 30 seconds.
    ...  Remove iqStreamId parameters created.
    ...  Activate delta plan.
    ...  Verify fault 4592 to be visible.
    ...  Wait until all cells are onAir.
    ...  Verify if fault 4592 was active for 90 seconds.
    ...  Verify fault signature and additional information for fault 4592.

Resource  ../../common_resources/vdu_frame.robot


*** Variables ***
${CELL_ID}  ${EMPTY}  # Mandatory! Id from tested cell (Eg. 34)
@{CHANNEL_ID_LIST}  @{EMPTY}  # Mandatory! 4 cell channel ids with TX (Eg. 1  2  3  4)
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to recover


*** Keywords ***
TC__KPI__vDU__Enabling_and_Modifying_Antenna_Port_Remapping_for_4_Tx_Cell
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26927
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  21.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26927 - Initial TAT creation
    ...  25.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-27633 - Cover with updates for CB07964
    ...  ******************

    Set Tags  CA-KPI  OWNER-oana.badea@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_1_Vrf
    ...  PHASE-CRT  FEATURE-CB010916  FEATURE-CB07964

    Step1: Change ActAntportMap, Fault4592CancellationTimer And Set Unique IqStreamId For All 4 TX
    Step2: Verify If The Affected Cell Is Down And Up And Fault 4592 Is Visible For 90 Seconds
    Step3: Collect Snapshot After Enabling The IqStreamId Parameter
    Step4: Modify Fault4592CancellationTimer And IqStreamId For All 4 TX
    Step5: Verify If The Affected Cell Is Down And Up And Fault 4592 Is Visible For 60 Seconds
    Step6: Collect Snapshot After Modifying The IqStreamId Parameter
    Step7: Reconfigures I/Q Data Stream, Fault4592CancellationTimer And Antenna Line Mapping
    Step8: Verify If The Affected Cell Is Down And Up And Fault 4592 Is Visible For 30 Seconds


Step1: Change ActAntportMap, Fault4592CancellationTimer And Set Unique IqStreamId For All 4 TX
    Log  \nStep1: Change actAntportMap, fault4592CancellationTimer and set unique iqStreamId for all 4 TX  console=true
    Should Not Be Empty  ${CELL_ID}  Cell ID must be specified, please provide it and retest.
    Should Not Be Empty  ${CHANNEL_ID_LIST}  Channel ids with TX for specific cell id must be specified, please provide it and retest.
    ${actAntPortMap_parameter}  Create Dictionary  parameterName=actAntPortMap  value=true  operation=update
    ${actAntPortMap_parameter_change_list}  Create List  ${actAntPortMap_parameter}
    ${actAntPortMap_changed_parameter}  Create Dictionary  distName=MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${CELL_ID}  operation=update
    ...  parameters=${actAntPortMap_parameter_change_list}
    ${fault4592CancellationTimer_parameter}  Create Dictionary  parameterName=fault4592CancellationTimer  value=90  operation=update
    ${fault4592CancellationTimer_parameter_change_list}  Create List  ${fault4592CancellationTimer_parameter}
    ${fault4592CancellationTimer_changed_parameter}  Create Dictionary  distName=MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1  operation=update
    ...  parameters=${fault4592CancellationTimer_parameter_change_list}
    ${changed_parameters_list}  Create List  ${actAntPortMap_changed_parameter}  ${fault4592CancellationTimer_changed_parameter}
    FOR  ${id}  IN RANGE  0  4
        ${dist_name}  Catenate  SEPARATOR=  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CELL_ID}/CHANNELGROUP-1/
        ...  CHANNEL-${CHANNEL_ID_LIST}[${id}]
        ${string_id}  Convert To String  ${id}
        ${iqStreamId_parameter}  Create Dictionary  parameterName=iqStreamId  value=${string_id}  operation=create
        ${iqStreamId_parameter_change_list}  Create List  ${iqStreamId_parameter}
        ${iqStreamId_changed_parameter}  Create Dictionary  distName=${dist_name}  operation=update  parameters=${iqStreamId_parameter_change_list}
        Append To List  ${changed_parameters_list}  ${iqStreamId_changed_parameter}
    END
    ${changed_parameters_string}  Evaluate  json.dumps(${changed_parameters_list})  json
    Log  Parameter actAntPortMap was changed to true![OK]  console=true
    Log  Parameter fault4592CancellationTimer was changed to 90s![OK]  console=true
    Log  Parameter iqStreamId for cell ${CELL_ID} was added![OK]  console=true
    vdu.Perform Delta Recommissioning  ${changed_parameters_string}


Step${index}: Verify If The Affected Cell Is Down And Up And Fault 4592 Is Visible For ${alarm_time} Seconds
    Log  \nStep${index}: Verify if the affected cell is down and up and fault 4592 is visible for ${alarm_time} seconds  console=true
    Run Keyword If  ${alarm_time} == 30
    ...  Wait Until Keyword Succeeds  400s  10s
    ...  Check If Fault Is Visible In VDU WebEM  7115  BASE STATION INFORMATION  4592  BTS Reset Cause  regex:Warning|warning
    ...  ELSE
    ...  Wait Until Keyword Succeeds  400s  10s
    ...  Check If Fault Is Visible In VDU WebEM  7115  BASE STATION INFORMATION  4592  BTS Reset Cause  regex:Minor|minor
    Wait Until Keyword Succeeds  400s  10s
    ...  Check The Specific Cell From VDU  ${CELL_ID}  availability_status=${OFFLINE}  operational_state=${DISABLED}
    Log  Cell ${CELL_ID} is Offline and Disabled![OK]  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10s
    ...  Check All Cells From VDU  administrative_state=${UNLOCKED}
    ...  operational_state=${ENABLED}
    ...  blocking_state=${UNBLOCKED}
    ...  availability_status=${ONLINE}
    Log  All cells are Online and Enabled![OK]  console=true
    Wait Until Keyword Succeeds  60s  10s
    ...  Check If Fault Is Cleared From VDU WebEM  7115  4592
    Check Active Time For A Specific Alarm On VDU  4592  ${alarm_time}
    Check Fault Signature And Additional Info Of 4592 Fault Id In WebEM


Step${index}: Collect Snapshot After ${action} The IqStreamId Parameter
    Log  \nStep${index}: Collect snapshot after ${action} the iqStreamId parameter  console=true
    Collect VDU Snapshot  directory_name=Snapshot_after_${action}
    Log  Snapshot was saved in ${TEST_RESULTS_DIR}/Snapshot_after_${action} directory![OK]  console=true


Step4: Modify Fault4592CancellationTimer And IqStreamId For All 4 TX
    Log  \nStep4: Modify fault4592CancellationTimer and iqStreamId for all 4 TX  console=true
    ${value_list}  Create List  3  2  1  0
    ${fault4592CancellationTimer_parameter}  Create Dictionary  parameterName=fault4592CancellationTimer  value=60  operation=update
    ${fault4592CancellationTimer_parameter_change_list}  Create List  ${fault4592CancellationTimer_parameter}
    ${fault4592CancellationTimer_changed_parameter}  Create Dictionary  distName=MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1  operation=update
    ...  parameters=${fault4592CancellationTimer_parameter_change_list}
    ${changed_parameters_list}  Create List  ${fault4592CancellationTimer_changed_parameter}
    FOR  ${id}  IN RANGE  0  4
        ${dist_name}  Catenate  SEPARATOR=  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CELL_ID}/CHANNELGROUP-1/
        ...  CHANNEL-${CHANNEL_ID_LIST}[${id}]
        ${iqStreamId_parameter}  Create Dictionary  parameterName=iqStreamId  value=${value_list}[${id}]  operation=update
        ${iqStreamId_parameter_change_list}  Create List  ${iqStreamId_parameter}
        ${iqStreamId_changed_parameter}  Create Dictionary  distName=${dist_name}  operation=update  parameters=${iqStreamId_parameter_change_list}
        Append To List  ${changed_parameters_list}  ${iqStreamId_changed_parameter}
    END
    ${changed_parameters_string}  Evaluate  json.dumps(${changed_parameters_list})  json
    Log  Parameter fault4592CancellationTimer was changed to 60s![OK]  console=true
    Log  Parameter iqStreamId for cell ${CELL_ID} was changed![OK]  console=true
    vdu.Perform Delta Recommissioning  ${changed_parameters_string}


Step7: Reconfigures I/Q Data Stream, Fault4592CancellationTimer And Antenna Line Mapping
    Log  \nStep7: Reconfigures I/Q data stream, fault4592CancellationTimer and antenna line mapping  console=true
    ${actAntPortMap_parameter}  Create Dictionary  parameterName=actAntPortMap  value=false  operation=update
    ${actAntPortMap_parameter_change_list}  Create List  ${actAntPortMap_parameter}
    ${actAntPortMap_changed_parameter}  Create Dictionary  distName=MRBTS-${VDU_MRBTS_ID}/NRBTS-${VDU_NRBTS_ID}/NRCELL-${CELL_ID}  operation=update
    ...  parameters=${actAntPortMap_parameter_change_list}
    ${fault4592CancellationTimer_parameter}  Create Dictionary  parameterName=fault4592CancellationTimer  value=30  operation=update
    ${fault4592CancellationTimer_parameter_change_list}  Create List  ${fault4592CancellationTimer_parameter}
    ${fault4592CancellationTimer_changed_parameter}  Create Dictionary  distName=MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1  operation=update
    ...  parameters=${fault4592CancellationTimer_parameter_change_list}
    ${changed_parameters_list}  Create List  ${actAntPortMap_changed_parameter}  ${fault4592CancellationTimer_changed_parameter}
    FOR  ${id}  IN RANGE  0  4
        ${dist_name}  Catenate  SEPARATOR=  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-${CELL_ID}/CHANNELGROUP-1/
        ...  CHANNEL-${CHANNEL_ID_LIST}[${id}]
        ${string_id}  Convert To String  ${id}
        ${iqStreamId_parameter}  Create Dictionary  parameterName=iqStreamId  value=${string_id}  operation=delete
        ${iqStreamId_parameter_change_list}  Create List  ${iqStreamId_parameter}
        ${iqStreamId_changed_parameter}  Create Dictionary  distName=${dist_name}  operation=update  parameters=${iqStreamId_parameter_change_list}
        Append To List  ${changed_parameters_list}  ${iqStreamId_changed_parameter}
    END
    ${changed_parameters_string}  Evaluate  json.dumps(${changed_parameters_list})  json
    Log  Parameter actAntPortMap was changed to false![OK]  console=true
    Log  Parameter fault4592CancellationTimer was changed to 30s![OK]  console=true
    Log  Parameter iqStreamId for cell ${CELL_ID} was deleted![OK]  console=true
    vdu.Perform Delta Recommissioning  ${changed_parameters_string}


Check Fault Signature And Additional Info Of 4592 Fault Id In WebEM
    [Documentation]  This keyword verify fault signature fields and additional info for fault id 4592

    ${date}  Get Current Date  result_format=%Y-%m-%d
    ${historical_alarms}  vdu.Vdu Get Historical Alarms  sorted_by=appearTime  sort_order=desc  timeout=120s
    ${alarms}  Get From Dictionary  ${historical_alarms}  alarms
    FOR  ${alarm}  IN  @{alarms}
        Run Keyword If  ${alarm}[fault_id] == 4592
        ...  Run Keywords
        ...  Set Test Variable  ${alarm}  ${alarm}
        ...  AND
        ...  Exit For Loop
    END
    ${faultsig}  Get From Dictionary  ${alarm}  fault_signature
    Should Be Equal  ${faultsig}[category]  OAM_RESET  msg=Category did not matched
    Should Be Equal  ${faultsig}[scope]  vDU  msg=Scope did not matched
    Should Be Equal  ${faultsig}[load_name]  ${VDU_ACTIVE_SW_VERSION}  msg=Load name did not matched
    Should Contain  ${faultsig}[minor]  POD  msg=Minor did not matched
    Should Match Regexp  ${faultsig}[info]  /pods/(po|ute)-cran1-oamext-0 CM reboot request  msg=Info did not matched
    Should Match Regexp  ${faultsig}[extra_info]  affected_cells=NR:none;  msg=Extra info did not matched
    Should Match Regexp  ${faultsig}[date]  ${date}  msg=Date did not matched
    Log  Fault signature from WebEM is OK!  console=true
    Should Be Equal  ${alarm}[additional_info]
    ...  supplAlarmInfo=BTS booted at ${faultsig}[date] due to reconfiguration change affected_cells=NR:none;  msg=Additional info did not matched
    Log  Additional info from WebEM is OK!  console=true


TC Setup
    Common VDU Setup
    Modify Resource Search Order  KPI__vDU__Enabling_and_Modifying_Antenna_Port_Remapping_for_4_Tx_Cell


TC Teardown
    Common VDU Teardown
