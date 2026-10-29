*** Settings ***
Documentation
    ...  Trigger 2412: EFaultId_OmuSignalingFailureAl fault on SBTS and verify correlation alarm.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  600  # Timeout for SBTS to recover after site reset


*** Keywords ***
TC__FM__GSM_faults_handling_fault_2412_startup
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-6319
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - xx.xx.2017 - https://jira3.int.net.nokia.com/browse/TAT-6319 - Initial creation
    ...  - 15.01.2018 - https://jira3.int.net.nokia.com/browse/TAT-8793 - Adjust timer between link restoriation and TXs state check
    ...  - 01.03.2018 - https://jira3.int.net.nokia.com/browse/TAT-9236 - deleyed BSC link restore
    ...  - 23.01.2019 - https://jira3.int.net.nokia.com/browse/TAT-12089 - Change KW to work with RMs connected with more than one fiber
    ...  - 02.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15076 - BCF statuses check should be adjusted for 4+3 configs
    ...  - 14.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15267 - Removed additional space
    ...  - 18.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15307 - Allign all FM TCs with RobotFramework version 3.1.0
    ...  - 29.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15557 - bbCalcState parameter verification removal
    ...  - 05.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21132 - Remove import for ta_real_radio library
    ...  - 06.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21067 - Test fails due infomodel routingstate change
    ...  - 12.05.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21331 - Test fails due to 'deploymentCalcState' : 'NotCalculated'
    ...  - 09.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22134 - Change BSC connection from telnet to ssh
    ...  - 24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 21.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24339 - Test fails due since execute too quickly the ZOYS:IUA:O1348:ACT; command
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 05.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27067 - Testcase fail on DHARANI BSC
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 19.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27381 - Update check query infomodel
    ...  - 26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27704 - Add option to skip RMOD power check
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-rafal.ozga@nokia.com  MAINTAINER-bogdan.boldurean@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS17A  FEATURE-RP001534

    Step 0: TC Specific Preconditions
    Step 1: Trigger 2412 Fault
    Step 2: Fault And Alarm Validation After SBTS Startup
    Step 3: Restore OMUSIG Link
    Step 4: Check Alarms And States After Link Restore
    Step 5: Alarm History Check


Set Own Test Variable
    Set Test Variable  ${UPLANE_CARRIERS_DN}  //BCF_L-1//UPLANE_CARRIER_L-*
    Set Test Variable  ${RMODS_DN}  //RMOD_R-*


Step 0: TC Specific Preconditions
    Log  \nStep 0: TC Specific Preconditions  console=true

    ${all_rmo_ds_power_before_fault2412}  Create Dictionary
    Set Test Variable  ${ALL_RMO_DS_POWER_BEFORE_FAULT2412}
    ${all_rmo_ds_power_after_fault2412}  Create Dictionary
    Set Test Variable  ${ALL_RMO_DS_POWER_AFTER_FAULT2412}

    Connect To BSC Setup
    Set Own Test Variable
    ${bcf_id}  Infomodel Get BcfId
    Run Keyword If  '${bcf_id}'=='None'
    ...  Fail  Cannot continue test: bcfId == None
    Set Test Variable  ${BCF_ID}
    ${om_link_state}  Get OM Link State  ${BCF_ID}
    Run Keyword IF  '${om_link_state}' == 'WO'
    ...  Log  O&M Link State is OK.  console=true
    ...  ELSE IF  '${om_link_state}' != 'WO'
    ...  Run Keywords
    ...  Log  O&M Link state is incorrect.  level=ERROR
    ...  AND
    ...  Fail  O&M Link state is incorrect ${om_link_state}!=WO
    ${om_name}  Get OM Link Name  ${BCF_ID}
    ${bcf_name}  Set Variable  BCF${BCF_ID}OMU
    ${om_association}  Run Keyword And Return Status
    ...  Read_output_from_mml_command  ZOYV:IUA:NAME=${om_name}:A:;  MAX.
    ${bcf_association}  Run Keyword And Return Status
    ...  Read_output_from_mml_command  ZOYV:IUA:NAME=${bcf_name}:A:;  MAX.
    Run Keyword If  ${om_association}
    ...  Set Test Variable  ${SCTP_NAME}  ${om_name}
    ...  ELSE IF  ${bcf_association}
    ...  Set Test Variable  ${SCTP_NAME}  ${bcf_name}
    ...  ELSE
    ...  Fail  msg=SCTP association does not exist.

    ${cells_state}  Run Keyword And Return Status
    ...  Check All Cells
    ${carriers_state}  Run Keyword And Return Status
    ...  Check Iplane Carriers State
    Get All Tx Power From All RMs  ${ALL_RMO_DS_POWER_BEFORE_FAULT2412}
    Run Keyword If  ${cells_state} == ${FALSE} and ${carriers_state} == ${FALSE}
    ...  Fail  Specific preconditions haven't met
    hran_bsc.Close Connection


Check Iplane Carriers State
    [Tags]  Helper

    ${carriers}  Query Infomodel  get list ${UPLANE_CARRIERS_DN}
    FOR  ${carrier}  IN  @{carriers}
        Should Be Equal  ${carrier.stateInfo['availabilityStatus']}  Online  msg=Wrong availabilityStatus in ${carrier.dist_name}
        Should Be Equal  ${carrier.stateInfo['operationalState']}  Enabled  msg=Wrong operationalState in ${carrier.dist_name}
        Should Be Equal  ${carrier.stateInfo['usageState']}  Active  msg=Wrong usageState in ${carrier.dist_name}
    END

    Log  All uplane carriers have proper states.  console=true


Step 1: Trigger 2412 Fault
    Log  \nStep 1: Trigger 2412 fault.  console=true
    Connect To BSC Setup
    ${command_output}  Read_output_from_mml_command  ZOYS:IUA:${SCTP_NAME}:DOWN;  HANDLING COMMAND
    ${om_link_state}  Get OM Link State  ${BCF_ID}
    Run Keyword IF  '${om_link_state}' == 'BL'
    ...  Log  O&M Link State is expected.  console=true
    ...  ELSE IF  '${om_link_state}' != 'BL'
    ...  Run Keywords
    ...  Log  O&M Link state NOT as expected.  level=ERROR
    ...  AND
    ...  Fail  O&M Link state is incorrect '${om_link_state}'!='BL'
    hran_bsc.Close Connection
    ${succeeded}  Run Keyword And Return Status
    ...  coam.Reset Site  600
    Run Keyword If  ${succeeded} == ${FALSE}
    ...  Reboot SBTS


Reboot SBTS
    [Tags]  Helper
    [Arguments]  ${timeout}=600

    Log  Reboot SBTS  console=true
    ssh.Connect To  ${SMOD1['IP']}  username=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}
    ssh.Execute  reboot
    Sleep  ${timeout}s


Step 2: Fault And Alarm Validation After SBTS Startup
    Log  \nStep 2: Alarm validation.  console=true
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}s  10s
    ...  Check If Remaining Cells Are OnAir
    ${bcf_status}  Run Keyword And Return Status
    ...  Check BCF Status
    ${alarm_status}  Run Keyword And Return Status
    ...  Check Alarm
    Run Keyword If  ${bcf_status} and ${alarm_status}
    ...  Run Keywords
    ...  Log  All states are expected.  console=true
    ...  AND
    ...  Return From Keyword


Check If Remaining Cells Are OnAir
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  coam.Assert Every  WNCEL  usageState=${ACTIVE}, operationalState=${ENABLED}  timeout=60
    Run Keyword If  ${SCF_COUNT_LTE}
    ...  coam.Assert Every  LNCEL  proceduralState=${ON_AIR_DONE}, operationalState=${ENABLED}  timeout=60
    Run Keyword If  ${SCF_COUNT_NR}
    ...  coam.Assert Every  NRCEL  operationalState=${ENABLED}  timeout=60


Get Number Of Configured Cells
    [Documentation]  KW is intedned to count number of configured LTE and WCDMA cells

    ${wcdma_cell_couter}  Get Ids For All  WNCEL
    ${lte_cell_counter}  Get Ids For All  LNCEL
    ${number_of_configured_lte_wcdma_cells}  Evaluate  len(${wcdma_cell_couter}+${lte_cell_counter})

    [Return]  ${number_of_configured_lte_wcdma_cells}


Check BCF Status
    [Tags]  Helper

    ${bcf_object}  Query Infomodel  get object //BCF_L-1
    Run Keyword If  ${bcf_object.stateInfo['reasoningStatus']} == ['OmuSignalingFailureDuringStartup']
    ...  Log  BCF reasoningStatus is OK  console=true
    ...  ELSE
    ...  Run Keywords
    ...  Log  Wrong BCF reasoningStatus ${bcf_object.stateInfo['reasoningStatus']}!=['OmuSignalingFailureDuringStartup']  level=WARN
    ...  AND
    ...  FAIL


Check Alarm
    [Tags]  Helper

    ${fault_2412_params}  Get String With Alarm Parameters  ${FAULT_2412_CRITICAL}
    Assert Alarm Active  parameters=${fault_2412_params}  timeout=120
    Log  Fault "${FAULT_2412_CRITICAL}[fault_name]" appeared.  console=True
    ${variable_to_check}  Catenate  SEPARATOR=  alarmName=regex"${FAULT_2412_CRITICAL}[alarm_name]",  alarmNumber=${FAULT_2412_CRITICAL}[alarm_id],
    ...  alarmSeverity=${FAULT_2412_CRITICAL}[severity],  faultId=${FAULT_2412_CRITICAL}[fault_id],  faultSeverity=${FAULT_2412_CRITICAL}[severity]
    ${object}  Query Infomodel  get object /MRBTS-1/RAT-1/FRI-1/ALARM-* is [${variable_to_check}]
    ${affected_resources}  Set Variable  ${object}[affectedResources][0]
    Run Keyword If  "${affected_resources}[reportingResourceDN]"=="/MRBTS-1/RAT-1/GTS-1/BCF_L-1"
    ...  Log  Fault ${FAULT_2412_CRITICAL}[fault_id] has reportingResourceDN : /MRBTS-1/RAT-1/GTS-1/BCF_L-1 .  console=True
    ...  ELSE
    ...  Set Test Restriction  For fault ${FAULT_2412_CRITICAL}[fault_id] reportingResourceDN is not ok.


Step 3: Restore OMUSIG Link
    Log  \nStep 3: Restore OMUSIG link.  console=true
    Connect To BSC Setup
    ${command_output}  Read_output_from_mml_command  ZOYS:IUA:${SCTP_NAME}:ACT;  HANDLING COMMAND
    Wait Until Keyword Succeeds  15min  1min
    ...  Check OM Link State After Restore


Check OM Link State After Restore
    ${om_link_state}  Get OM Link State  ${BCF_ID}
    Run Keyword If  '${om_link_state}' == 'WO'
    ...  Run Keywords
    ...  Log  O&M Link restored.  console=true
    ...  AND
    ...  Return From Keyword  ${True}
    ...  ELSE IF  '${om_link_state}' != 'WO'
    ...  Log  O&M Link not restored  console=true


Step 4: Check Alarms And States After Link Restore
    Sleep  180
    Log  \nStep 4: Check alarms and states after link restore.  console=true
    ${alarm_state}  Run Keyword And Return Status
    ...  Check Alarm Clear
    ${cells_state}  Run Keyword And Return Status
    ...  Check All Cells
    ${carriers_state}  Run Keyword And Return Status
    ...  Check Iplane Carriers State
    Get All Tx Power From All RMs  ${ALL_RMO_DS_POWER_AFTER_FAULT2412}
    Compare TXs  ${ALL_RMO_DS_POWER_BEFORE_FAULT2412}  ${ALL_RMO_DS_POWER_AFTER_FAULT2412}
    Run Keyword If  ${alarm_state} == ${FALSE} and ${cells_state} == ${FALSE} and ${carriers_state} == ${FALSE}
    ...  Fail  Incorrect alarm or states after restore.


Check Alarm Clear
    [Tags]  Helper

    ${fault_2412_params}  Get String With Alarm Parameters  ${FAULT_2412_CRITICAL}
    Assert Alarm Inactive  parameters=${fault_2412_params}  timeout=120
    Log  Fault "${FAULT_2412_CRITICAL}[fault_name]" cleared.  console=True


Step 5: Alarm History Check
    ${alarms}  Get Historic Alarms
    Log  Historical alarms:\n${alarms}  console=true


Admin Collect IM Snapshot
    ${timestamp}  Get Timestamp
    coam.Collect Im Snapshot  ${BTS_FILES}/${timestamp}_im_snapshot.zip


Get Timestamp
    ${timestamp}  Get Time
    ${timestamp}  Replace String Using Regexp  ${timestamp}  (${SPACE}|:|-)  _

    [Return]  ${timestamp}


TC Setup
    Common Test Setup  tc_name=FM__GSM_faults_handling_fault_2412_startup


TC Teardown
    Run Keyword If Test Failed
    ...  Step 3: Restore OMUSIG Link
    hran_bsc.Close Connection
    Common Test Teardown
