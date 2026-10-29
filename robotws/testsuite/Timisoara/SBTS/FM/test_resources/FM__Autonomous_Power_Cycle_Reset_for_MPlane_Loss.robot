*** Settings ***
Documentation
    ...  This TC is created to verify the Autonomous Power Cycle Reset triggered by M-Plane connection loss.
    ...  M-plane connection is lost by disabling switch ports for 50 minutes.
    ...  After reconnection, POOR Reset Counter must be incremented.
    ...  FID 10 is reported during the operation.
    ...  The list of operations must be correct: Reset Reason and Reset Cause fields values
    ...  must be "POR" and "UnitEscalated".

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RMOD_SN}  L1251805075  #RMOD serial number. Will be tested only on this RMOD(AVHA).
${ALARM_TIMEOUT}  300s  #Timeout for RMOD and cells to recover.
${SWITCH_IP_ADDRESS}  10.255.1.188  #Switch ip address.
${SWITCH_USER}  admin  #Switch user.
${SWITCH_PASSWORD}  Admin@88  #Switch password.


*** Keywords ***
TC__FM__Autonomous_Power_Cycle_Reset_for_MPlane_Loss
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29931
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  26.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-29931 - Initial TAT creation
    ...  *******************

    Set Tags  CA-FM  OWNER-denis.gruia@nokia.com  AUTHOR-anna.beke@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  FEATURE-CB013988-SR-A


    Step 0: TC Preconditions
    Step 1: Simulate M-plane connection loss


Step 0: TC Preconditions
    Log  \nStep 0: TC Preconditions  console=true

    Perform Site Reset
    ${rmods_info}  Get Frm
    FOR  ${rmod}  IN  @{rmods_info}
        ${status}  Run Keyword And Return Status  Should Be Equal As Strings  ${rmod}[serialNumber]  ${RMOD_SN}
        IF  not ${status}  CONTINUE
        Set Test Variable  ${RMOD_DN}  ${rmod}[id][internal]
        Set Test Variable  ${RMOD_TYPE}  ${rmod}[productName]
        BREAK
    END
    IF  $RMOD_DN is None  Fail  RMOD with serial number ${RMOD_SN} not found in configuration.
    ${sw_line}  Get SW Line For Specific RMOD  ${RMOD_DN}
    ${rmod_user}  ${rmod_password}  Get User And Password For RMOD  ${sw_line}  ${RMOD_TYPE}
    ${rmod_side}  ${rmod_ip}  ${stored_role}  Find RMOD Ip By Serial Number  ${RMOD_SN}
    ${rmod_cells}  Get Cell Mapping By Module Id  ${RMOD_DN}
    Set Test Variable  ${RMOD_IP}
    Set Test Variable  ${RMOD_SIDE}
    Set Test Variable  ${STORED_ROLE}
    Set Test Variable  ${RMOD_USER}
    Set Test Variable  ${RMOD_PASSWORD}
    Set Test Variable  ${RMOD_CELLS}

    Open Connection To Radio Module  ${RMOD_SIDE}  ${STORED_ROLE}  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASSWORD}
    SSHLibrary.Write  sudo su
    SSHLibrary.Read Until Prompt
    ${initial_counter_value}  Get POOR Reset Counter From RMOD /var/log/BBOX5 File  ${RMOD_SN}
    Set Test Variable  ${INITIAL_COUNTER_VALUE}
    Log  Initial POOR Reset Counter value: ${initial_counter_value}  console=true

    [Teardown]  SSHLibrary.Close All Connections


Step 1: Simulate M-plane connection loss
    Log  \nStep 1: Simulate M-plane connection loss  console=true

    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    ${switch_opts}  Create List  1  2  3  4  5  6
    Log  Opening ssh connection to switch: ${SWITCH_IP_ADDRESS}  console=true
    SSHLibrary.Open Connection  host=${SWITCH_IP_ADDRESS}  prompt=>  newline=\r\n
    SSHLibrary.Login  username=${SWITCH_USER}  password=${SWITCH_PASSWORD}
    Log  Disabling switch ports: ${switch_opts}  console=true
    FOR  ${switch_opt}  IN  @{switch_opts}
        SSHLibrary.Write  SW ${switch_opt} 0
        SSHLibrary.Read Until Prompt
    END
    SSHLibrary.Close Connection

    ${fid_10_params}  Get String With Alarm Parameters  ${FAULT_10_Critical}
    Assert Alarm Active  parameters=${fid_10_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_10_Critical} is active in WebEM. \nWill wait 50 minutes to reconnect to RMOD.  console=true
    Sleep  50 min  Wait for 50 minutes to reconnect to RMOD.

    Log  Opening ssh connection to switch: ${SWITCH_IP_ADDRESS}  console=true
    SSHLibrary.Open Connection  host=${SWITCH_IP_ADDRESS}  prompt=>  newline=\r\n
    SSHLibrary.Login  username=${SWITCH_USER}  password=${SWITCH_PASSWORD}
    Log  Enabling switch ports: ${switch_opts}  console=true
    FOR  ${switch_opt}  IN  @{switch_opts}
        SSHLibrary.Write  SW ${switch_opt} 1
        SSHLibrary.Read Until Prompt
    END
    SSHLibrary.Close Connection

    Assert  RMOD  ${RMOD_DN}  operationalState=${ENABLED}  timeout=600s
    Wait Until Keyword Succeeds  180s  10s  Check Parameters Status For Cells  ${RMOD_CELLS}  operationalState=${ENABLED}

    Open Connection To Radio Module  ${RMOD_SIDE}  ${STORED_ROLE}  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASSWORD}
    SSHLibrary.Write  sudo su
    SSHLibrary.Read Until Prompt
    ${poor_reset_counter}  Get POOR Reset Counter From RMOD /var/log/BBOX5 File  ${RMOD_SN}
    IF  '${poor_reset_counter}' <= '${INITIAL_COUNTER_VALUE}'  Fail  POOR Counter was not incremented.
    Log  POOR Counter correctly incremented: ${poor_reset_counter}. [OK]  console=true
    SSHLibrary.Close All Connections

    Open Connection To Radio Module  ${RMOD_SIDE}  ${STORED_ROLE}  ${RMOD_IP}  ${RMOD_USER}  ${RMOD_PASSWORD}
    SSHLibrary.Write  sudo su
    SSHLibrary.Read Until Prompt
    Verify The List Of Operations From RMOD /var/volatile/log/BBOX5 File  ${RMOD_SN}  POR  UnitEscalated

    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_10_Critical}  time_from=${start_time}
    Log  Fault ${FAULT_10_Critical} reported & cleared from Mantaray.  console=true

    [Teardown]  Run Keyword And Ignore Error  SSHLibrary.Close All Connections


TC Setup
    Common Test Setup  tc_name=FM__Autonomous_Power_Cycle_Reset_for_MPlane_Loss
    Setup NetAct


TC Teardown
    Teardown NetAct
    Common Test Teardown
