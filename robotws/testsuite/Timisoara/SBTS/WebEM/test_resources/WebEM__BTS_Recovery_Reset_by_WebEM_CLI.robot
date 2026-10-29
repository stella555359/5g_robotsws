*** Settings ***
Documentation
    ...  This test case verify if BTS will execute the recovery resets requested by action command or CLI command.
    ...  actCli parameter is changed to be true.
    ...  Connect on RF and send fault
    ...  RMOD TYPE should be given in variables section, by default is AHLOA.
    ...  Wait until fault is visible on SBTS.
    ...  Trigger "recoveryReset" request send via Admin CLI command.
    ...  Verify if request status is completed, error code is 0 and request message contains Radio recovery reset on the specific RMOD.
    ...  Verify if fault was cleared.
    ...  Connect on RF and send fault again.
    ...  Wait until fault is visible on SBTS.
    ...  After FID appear on RF Activate maintenance window by setting maintenanceWindow daysofWeek on 127, gracefulCellShutdown on yes,
    ...  inUse on true, startTime after 5 minutes and windowDuration on 30 minutes.
    ...  Validate and activate the plan.
    ...  Wait 5 minutes for maintenance to start.
    ...  After 5 minutes, the triggered fault should be cleared.
    ...  SBTS should be onAir.
    ...  Verify if maintenanceWindowResult contains Radio recovery reset on the specific RMOD.
    ...  Delete maintenanceWindow parameter and perform site reset.
    ...  Wait until SBTS is onAir.
    ...  actCli parameter is changed to be false.


Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  600  #Timeout for SBTS to recover.
${RMOD_TYPE}  AHLOA  #RMOD type to be tested. By default is AHLOA


*** Keywords ***
TC__WebEM__BTS_Recovery_Reset_by_WebEM_CLI
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29335
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 18.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29335 - Initial TAT creation
    ...  - 21.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29738 - Add 5 minutes after SBTS is onAir and sending the fault again

    Set Tags  CA-WebEM  OWNER-marius.stanescu@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-SBTS25R3  FEATURE-CB008708


    Step0: TC Preconditions
    Step1: Change ActCli Parameter To Be true
    Step2: Connect On RF And Send Fault
    Step3: Trigger "recoveryReset" Request Send Via Admin CLI Command
    Step4: Check If Fault Id Was Clear After Command Was Send
    Step5: Connect On RF And Send Fault
    Step6: Activate Maintenance Window By Setting maintenanceWindow daysofWeek And startTime
    Step7: Check If Maintenance Window Result Is Sent
    Step8: Delete maintenanceWindow And Perform Site Reset
    Step9: Change ActCli Parameter To Be false


Step0: TC Preconditions
    ${RMOD_ID}  ${RMOD_SN}  Get RMOD ID And SN  ${RMOD_TYPE}
    Set Test Variable  ${RMOD_ID}
    Set Test Variable  ${RMOD_SN}
    ${SMOD_SIDE}  ${RMOD_IP}  ${stored_role}  Find RMOD Ip By Serial Number  ${RMOD_SN}
    Set Test Variable  ${SMOD_SIDE}
    Set Test Variable  ${RMOD_IP}


Step${id}: Change ActCli Parameter To Be ${value}
    Log  Step${id}: Change actCli parameter to be ${value}  console=true
    Change ActCli Parameter  ${value}


Step${index}: Connect On RF And Send Fault
    Log  \nStep${index}: Connect On RF And Send Fault  console=true
    Open Connection To Primary Core
    IF  ${SMOD_SIDE} == 2  Open Connection To Secondary Core
    SSHLibrary.Write  lxc-attach -n 0x${SMOD_SIDE}018
    ${lxc_attach_output}  SSHLibrary.Read Until Prompt
    Should Contain  ${lxc_attach_output}  FHNET  msg=lxc-attach command not working
    SSHLibrary.Write  rm /user/toor4nsn/.ssh/known_hosts
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  rm /root/.ssh/known_hosts
    SSHLibrary.Read Until Prompt
    Log  Verify RMOD is initialized before sending the commands.  console=true
    Assert  RMOD  ${RMOD_ID}  operationalState=${ENABLED}  timeout=120s
    SSHLibrary.Write  ssh ${RMOD_IP}
    SSHLibrary.Set Client Configuration  prompt=(yes/no/[fingerprint])?
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  yes
    SSHLibrary.Set Client Configuration  prompt=REGEXP:(~#|\\$|\\n\\$|~ >)
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  dapd -gt 2 -40
    SSHLibrary.Read Until Prompt
    Log  Fault was sent on RMOD with IP ${RMOD_IP}.  console=true
    ${fault_1907_params}  Get String With Alarm Parameters  ${FAULT_1907_TX_OUT_OF_ORDER_MAJOR}
    ${status}  Run Keyword And Return Status  Assert Alarm Active  parameters=${fault_1907_params}  timeout=300
    IF  ${status}
        Log  Fault "${FAULT_1907_TX_OUT_OF_ORDER_MAJOR}[fault_name]" appeared.  console=true
        Set Test Variable  ${TRIGGERED_FAULT_INFO}  ${FAULT_1907_TX_OUT_OF_ORDER_MAJOR}
    ELSE
        ${fault_1908_params}  Get String With Alarm Parameters  ${FAULT_1908}
        ${status}  Run Keyword And Return Status  Assert Alarm Active  parameters=${fault_1908_params}  timeout=120
        IF  ${status}
            Log  Fault "${FAULT_1908}[fault_name]" appeared.  console=true
            Set Test Variable  ${TRIGGERED_FAULT_INFO}  ${FAULT_1908}
        ELSE
           Fail  Fault is not visible on SBTS![NOK]  console=true
        END
     END

    [Teardown]  SSHLibrary.Close Connection


Step3: Trigger "recoveryReset" Request Send Via Admin CLI Command
    Log  \nStep3: Trigger "recoveryReset" request send via Admin CLI command  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}
    Log  \nSending command via Admin CLI for recoveryReset...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request
    ...  {"requestId":100,"requestType":"procedure","parameters":{"name":"recoveryReset","parameters":{"gracefulCellShutdown":"yes"}}}
    IF  '${request_status}' == 'completed' and ${error_code} == 0
        Log  Command sent with status: ${request_status} and error code: ${error_code}![OK]  console=true
    ELSE
        Fail  Command sent with status: ${request_status} and error code: ${error_code}![NOK]
    END
    ${partial_dn}  Fetch From Right  ${RMOD_ID}  MRBTS_R-1/
    Should Be Equal As Strings  ${request_message}  Radio recovery reset:MRBTS-${BTS_ID}/${partial_dn}
    Log  Command sent with request message: ${request_message}![OK]  console=true


Step4: Check If Fault Id Was Clear After Command Was Send
    Log  \nStep4: Check if fault id was clear after command was send  console=true
    Assert Alarm Inactive  faultId=${TRIGGERED_FAULT_INFO}[fault_id]  timeout=400
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State
    Sleep  300s  Time for fault to be cleared correctly


Step6: Activate Maintenance Window By Setting maintenanceWindow daysofWeek And startTime
    Log  \nStep6: Activate maintenance window by setting maintenanceWindow daysofWeek and startTime  console=true
    ${hour_min}  Get Date From SBTS And Add 5 Minutes To Complete startTime
    ${new_values}  Create Dictionary  daysOfWeek=127  gracefulCellShutdown=yes  inUse=true  startTime=${hour_min}  windowDuration=30
    ${list_values}  Create List  ${new_values}
    coam.Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1  maintenanceWindow  update  ${list_values}
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=300
    Log  maintenanceWindow was changed to ${new_values}.  console=true
    ${fault_params}  Get String With Alarm Parameters  ${TRIGGERED_FAULT_INFO}
    Assert Alarm Active  parameters=${fault_params}  timeout=120
    Log  Fault "${TRIGGERED_FAULT_INFO}[fault_name]" is still visible before maintenance start.  console=true
    Log  Wait 5 minutes for maintenance to start and recovery reset to be done automatically.  console=true
    Sleep  300s  Time for maintenance to start
    Assert Alarm Inactive  faultId=${TRIGGERED_FAULT_INFO}[fault_id]  timeout=400
    Log  Fault "${TRIGGERED_FAULT_INFO}[fault_name]" is not visible anymore after maintenance start.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State
    Log  All cells and modules are onAir!  console=true


Step7: Check If Maintenance Window Result Is Sent
    Log  \nStep7: Check If Maintenance Window Result Is Sent  console=true
    ${list}  Create List  maintenanceWindowResult
    ${parameter}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/FMCADM_R-1  ${list}
    ${partial_dn}  Fetch From Right  ${RMOD_ID}  MRBTS_R-1/
    Should Be Equal As Strings  ${parameter}[0][parameters][maintenanceWindowResult]  Radio recovery reset:MRBTS-${BTS_ID}/${partial_dn}
    Log  maintenanceWindowResult value is: ${parameter}[0][parameters][maintenanceWindowResult]! [OK]  console=true


Step8: Delete maintenanceWindow And Perform Site Reset
    Log  \nStep8: Delete maintenanceWindow And Perform Site Reset  console=true
    ${new_values}  Create Dictionary  daysOfWeek=127
    ${list_values}  Create List  ${new_values}
    coam.Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1  maintenanceWindow  delete  ${list_values}
    ...  skip_parameter_relation_errors=True  should_activate=True  timeout=300
    Log  maintenanceWindow was deleted!  console=true
    Perform Site Reset As Recovery Action


Perform Site Reset As Recovery Action
    Log  Site reset will be performed to clear recovery reset counters.  console=true
    coam.Reset Site  timeout=${RECOVERY_TIMEOUT}
    Log  Site reset has been performed.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State
    Log  All cells and modules are onAir!  console=true
    Admin Check Active Alarms Taf


Get RMOD ID And SN
    [Arguments]  ${rmod_type}

    ${rmods}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmods}
        IF  '${rmod_type}' not in '${rmod}[productName]'  CONTINUE
        RETURN  ${rmod}[id]  ${rmod}[serialNumber]
    END
    Fail  No RMODs with type ${rmod_type} found on SBTS.


Get Date From SBTS And Add 5 Minutes To Complete startTime
    ${time}  Get BTS Time In UTC Format  %H:%M:%S
    ${duration}  Add Time To Time  ${time}  5 minutes  result_format=timer  exclude_millis=yes
    ${hour_min}  Get Substring  ${duration}  0  5

    RETURN  ${hour_min}


TC Setup
    Common Test Setup  tc_name=WebEM__BTS_Recovery_Reset_by_WebEM_CLI


TC Teardown
    Run Keyword If Test Failed  Perform Site Reset As Recovery Action
    Common Test Teardown
