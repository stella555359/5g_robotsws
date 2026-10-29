*** Settings ***
Documentation
    ...  This TC is created to trigger DFE crash on AEHC Radio Module.
    ...  First, AEHC RMOD is chosen, and all necessary variables are set.
    ...  Connection to RMOD is opened and DFE 4 and DFE 2 are shut down.
    ...  Test waits at least 20 minutes for faults 1911 and 1907 with severity Major to appear.
    ...  In the supplementary alarms info it should be mentioned that 16 pipes are affected and that DFE 2 and DFE 4 are affected.
    ...  Maintenance Window is activated, and RMOD recovery should be performed.
    ...  All node_failures files MUST be deleted after RMOD recovery.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RMOD_TYPE}  AEHC  # Type of RMOD that will be used to perform .
${ALARM_TIMEOUT}  600s  # [in seconds] Timeout for alarm to be reported in WebEM and Mantaray


*** Keywords ***
TC__FM__AEHC_noncritical_DFE_runtime_crash
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-30137
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  03.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30137 - Initial TAT creation
    ...  *******************

    Set Tags  CA-FM  OWNER-delia.nacov@nokia.com  AUTHOR-anna.beke@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  FEATURE-CB014972

    Step 0: TC Preconditions
    Step 1: Crash DFE2 and DFE4
    Step 2: Activate Maintenance Window And Verify RMOD Recovery
    Step 3: Check Maintenance Report


Step 0: TC Preconditions
    Log  \nStep 0: TC Preconditions...  console=true

    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Change Parameter ActForce(Unit)AutoReset  false  actForceUnitAutoReset
    ${rmod_sn}  Get Random RMOD Serial Number By Given RMOD Type  ${RMOD_TYPE}
    ${rmods_info}  Get Frm
    FOR  ${rmod}  IN  @{rmods_info}
        ${status}  Run Keyword And Return Status  Should Be Equal As Strings  ${rmod}[serialNumber]  ${rmod_sn}
        IF  not ${status}  CONTINUE
        ${rmod_cells}  Get Cell Mapping By Module Id  ${rmod}[id][internal]
        Set Test Variable  ${RMOD_DN}  ${rmod}[id][internal]
        Set Test Variable  ${RMOD_CELLS}
        BREAK
    END
    ${smod_side}  ${rmod_ip}  ${stored_role}  Find RMOD Ip By Serial Number  ${rmod_sn}
    ${sw_line}  Get SW Line For Specific RMOD  ${RMOD_DN}
    ${rmod_user}  ${rmod_password}  Get User And Password For RMOD  ${sw_line}  ${RMOD_TYPE}
    Set Test Variable  ${RMOD_IP}
    Set Test Variable  ${SMOD_SIDE}
    Set Test Variable  ${STORED_ROLE}
    Set Test Variable  ${RMOD_USER}
    Set Test Variable  ${RMOD_PASSWORD}
    Set Test Variable  ${START_TIME}


Step 1: Crash DFE2 and DFE4
    Log  \nStep 1: Crash DFE2 and DFE4...  console=true

    Open Connection To Radio Module  ${SMOD_SIDE}  ${STORED_ROLE}  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASSWORD}
    SSHLibrary.Write  dfe-shutdown.sh 4
    SSHLibrary.Read Until Prompt
    Sleep  45s  Wait 45s to send next command.
    SSHLibrary.Write  dfe-shutdown.sh 2
    SSHLibrary.Read Until Prompt

    ${time}  Get Current Date  time_zone=UTC  result_format=datetime
    Log  Will wait at least 20 minutes for faults to appear from: ${time}  console=true
    Sleep  22 minutes  Wait for at least 20 minutes for faults to appear.

    Log  Verify fault 1911 Major - presence.  console=true
    ${fid_1911_params}  Get String With Alarm Parameters  ${FAULT_1911}
    ${fid_1911_w_suppl_info}  Catenate  ${fid_1911_params},  supplAlarmInfo=regex".*16 RX faulty.*(DFE:R2,R4|DFE:R4,R2).*"
    Assert Alarm Active  parameters=${fid_1911_w_suppl_info}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_1911} is active in WebEM with correct supplementary alarm information.  console=true
    Log  Verify fault 1907 Major - presence.  console=true
    ${fid_1907_params}  Get String With Alarm Parameters  ${FAULT_1907_TX_OUT_OF_ORDER_MAJOR}
    ${fid_1907_w_suppl_info}  Catenate  ${fid_1907_params},  supplAlarmInfo=regex".*16 TX faulty.*(DFE:R2,R4|DFE:R4,R2).*"
    Assert Alarm Active  parameters=${fid_1907_w_suppl_info}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_1907_TX_OUT_OF_ORDER_MAJOR} is active in WebEM with correct supplementary alarm information.  console=true

    [Teardown]  SSHLibrary.Close All Connections


Step 2: Activate Maintenance Window And Verify RMOD Recovery
    Log  \nStep 2: Activate Maintenance Window And Verify RMOD Recovery...  console=true

    ${time}  Get BTS Time In UTC Format  %H:%M:%S
    ${duration}  Add Time To Time  ${time}  5 minutes  result_format=timer  exclude_millis=yes
    ${hour_min}  Get Substring  ${duration}  0  5
    ${new_values}  Create Dictionary  daysOfWeek=127  gracefulCellShutdown=yes  inUse=true  startTime=${hour_min}  windowDuration=30
    ${list_values}  Create List  ${new_values}
    coam.Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    ...                                     maintenanceWindow
    ...                                     update
    ...                                     ${list_values}
    ...                                     skip_parameter_relation_errors=True
    ...                                     should_activate=True
    ...                                     timeout=300
    Log  maintenanceWindow was changed to ${new_values}.  console=true

    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1911}
    ...                                                                               suppl_info=.*16 RX faulty.*(DFE:R2,R4|DFE:R4,R2).*
    ...                                                                               time_from=${START_TIME}
    Log  Fault ${FAULT_1911} was active & cleared from Mantaray with correct supplementary alarm information.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_1907_TX_OUT_OF_ORDER_MAJOR}
    ...                                                                               suppl_info=.*16 TX faulty.*(DFE:R2,R4|DFE:R4,R2).*
    ...                                                                               time_from=${START_TIME}
    Log  Fault ${FAULT_1907_TX_OUT_OF_ORDER_MAJOR} was active & cleared from Mantaray with correct supplementary alarm information.  console=true
    Assert  RMOD  ${RMOD_DN}  operationalState=${ENABLED}  timeout=600s
    Wait Until Keyword Succeeds  300s  10s  Check Parameters Status For Cells  ${RMOD_CELLS}  operationalState=${ENABLED}
    Log  RMOD and cells mapped on it, reached on air status. [OK]  console=true


Step 3: Check Maintenance Report
    Log  \nStep 3: Check Maintenance Report...  console=true
    ${list}  Create List  maintenanceWindowResult
    ${parameter}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1/FMCADM_R-1  ${list}
    ${partial_dn}  Fetch From Right  ${RMOD_DN}  MRBTS_R-1/
    Should Be Equal As Strings  ${parameter}[0][parameters][maintenanceWindowResult]  Radio recovery reset:MRBTS-${BTS_ID}/${partial_dn}
    Log  maintenanceWindowResult value is: ${parameter}[0][parameters][maintenanceWindowResult] [OK]  console=true


Perform Recovery Action
    Open Connection To Radio Module  ${SMOD_SIDE}  ${STORED_ROLE}  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASSWORD}
    SSHLibrary.Write  cd /mnt/runtime
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  sudo su rfsw
    ${output}  SSHLibrary.Read Until Prompt
    Should Contain  ${output}  rfsw  msg=Could not connect to rfsw user.
    SSHLibrary.Write  rm -rf node_failures*
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ls
    ${ls_output}  SSHLibrary.Read Until Prompt
    ${lines}  Get Lines Containing String  ${ls_output}  node_failures
    Should Be Empty  ${lines}  msg=node_failures files were not deleted from RMOD. [NOK]
    Log  All node_failures files were successfully deleted. [OK]  console=true
    SSHLibrary.Close All Connections

    ${new_values}  Create Dictionary  daysOfWeek=127
    ${list_values}  Create List  ${new_values}
    coam.Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    ...                                     maintenanceWindow
    ...                                     delete
    ...                                     ${list_values}
    ...                                     skip_parameter_relation_errors=True
    ...                                     should_activate=True
    ...                                     timeout=300
    Log  maintenanceWindow was deleted!  console=true
    Perform Site Reset


TC Setup
    Common Test Setup  tc_name=FM__AEHC_noncritical_DFE_runtime_crash
    Setup NetAct


TC Teardown
    Perform Recovery Action
    Teardown NetAct
    Common Test Teardown