*** Settings ***
Documentation
...  This TC is created to raise fault 1907 on vDU.
...  Connection to RMOD is opened and fault is sent on every made-node on RMOD.
...  RMOD reset is performed and fault 1907 "Radio autonomous reset as recovery action" is reported in WebEM.
...  This process is repeated 3 times.
...  The fourth time, RMOD reset is not performed and the fault remains critical.
...  At the end, vDU Reset is performed.


Resource  ../../common_resources/vdu_frame.robot
Resource  ../../common_resources/cbts_general.robot


*** Variables ***
${RMOD_TYPE}  ${EMPTY}  #RMOD product name
${DC}  ${TRUE}  #Configuration type
${ALARM_TIMEOUT}  300s     # Timeout for alarm to appear in WebEM
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__FM__vDU_Triggering_fault_1907
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28676
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  28.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28676 - Initial TAT creation
    ...  01.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29005 - Change from SWN to DC RMOD connection
    ...  09.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29831 - Change method of connecting to RMOD and retrieving pod and container name
    ...  ******************

    Set Tags  CA-FM  OWNER-mircea.novac@nokia.com  MAINTAINER-anna.beke@nokia.com  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CRT  FEATURE-CB006992C


    Step 0: TC Preconditions
    Step 1: Trigger Fault 1911 4 times


Step 0: TC Preconditions
    Log  \nStep0: TC Preconditions.  console=true

    Should Not Be Empty  ${RMOD_TYPE}  msg=Please provide RMOD_TYPE(e.g. AEQP)
    Perform vDU Reset
    Set Alarms Dictionaries
    ${rmods}  vdu.Get Rmods Status
    ${all_rmods_ips}  Get All RMODs IPs from vDU
    FOR  ${current_rmod}  IN  @{rmods}
         IF  '${current_rmod}[product_name]' == '${RMOD_TYPE}'
             ${active_sw_build}  Split String  ${current_rmod}[active_sw_build]  .
             ${rmod_user}  ${rmod_password}  Get User And Password For RMOD  ${active_sw_build}[1]  ${current_rmod}[product_name]
             ${rmod_ip}  Get Ip For RMOD  ${current_rmod}[serial_number]  ${rmod_user}  ${rmod_password}  ${all_rmods_ips}  dc=${DC}
             ${rmod}  Create Dictionary   serial_number=${current_rmod}[serial_number]
             ...                          id=${current_rmod}[id]
             ...                          ip=${rmod_ip}
             ...                          user=${rmod_user}
             ...                          password=${rmod_password}
             Set Test Variable  ${RMOD}
             BREAK
         END
    END
    Should Not Be Empty  ${RMOD}  msg=Could not retrieve information for RMOD - ${RMOD_TYPE}.
    Log  Chosen RMOD information: ${RMOD}


Step 1: Trigger Fault 1911 4 times
    Log  \nStep 1: Trigger fault 1911 4 times.  console=true

    Repeat Keyword  3 times  Trigger 1907 Fault And Verify Recovery
    Trigger 1907 Fault And Recover BTS


Trigger 1907 Fault And Verify Recovery
    Open SSH Connection To Specific RMOD  ${RMOD}[ip]  ${RMOD}[user]  ${RMOD}[password]  ${RMOD}[serial_number]  dc=${DC}
    Connect To Each Made Node And Send Devmem Command

    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  5s
    ...  Check If Fault Is Visible In VDU WebEM  ${FAULT_1907_RADIO_AUTO_RST}[alarm_id]
    ...                                          ${FAULT_1907_RADIO_AUTO_RST}[alarm_name]
    ...                                          ${FAULT_1907_RADIO_AUTO_RST}[fault_id]
    ...                                          ${FAULT_1907_RADIO_AUTO_RST}[fault_name]
    ...                                          ${FAULT_1907_RADIO_AUTO_RST}[severity]
    Log  Fault ${FAULT_1907_RADIO_AUTO_RST} is reported in WebEM.[OK]  console=true

    Log  Checking RMOD and cells to be on air.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  5s  Verify RMOD Parameter By RMOD Id  ${RMOD}[id]  availability_status  ${ONLINE}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  5s  Check All Cells From VDU  operational_state=${ENABLED}
    ...                                                                             availability_status=${ONLINE}
    ...                                                                             administrative_state=${UNLOCKED}
    Log  All services are operational after fault triggering and RMOD reset.[OK]  console=true


Trigger 1907 Fault And Recover BTS
    Open SSH Connection To Specific RMOD  ${RMOD}[ip]  ${RMOD}[user]  ${RMOD}[password]  ${RMOD}[serial_number]  dc=${DC}
    Connect To Each Made Node And Send Devmem Command

    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  5s
    ...  Check If Fault Is Visible In VDU WebEM  ${FAULT_1907_TX_OUT_OF_ORDER}[alarm_id]
    ...                                          ${FAULT_1907_TX_OUT_OF_ORDER}[alarm_name]
    ...                                          ${FAULT_1907_TX_OUT_OF_ORDER}[fault_id]
    ...                                          ${FAULT_1907_TX_OUT_OF_ORDER}[fault_name]
    ...                                          ${FAULT_1907_TX_OUT_OF_ORDER}[severity]
    Log  Fault ${FAULT_1907_TX_OUT_OF_ORDER} is reported in WebEM.  console=true

    Perform vDU Reset


Set Alarms Dictionaries
    ${FAULT_1907_RADIO_AUTO_RST}  Create Dictionary  fault_id=1907
    ...                                              fault_name=Radio autonomous reset as recovery action
    ...                                              alarm_id=7101
    ...                                              alarm_name=BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...                                              severity=regex"Warning|warning"
    ${FAULT_1907_TX_OUT_OF_ORDER}  Create Dictionary  fault_id=1907
    ...                                               fault_name=TX out of order
    ...                                               alarm_id=7116
    ...                                               alarm_name=BASE STATION SERVICE PROBLEM
    ...                                               severity=regex"Critical|critical"
    Set Test Variable  ${FAULT_1907_RADIO_AUTO_RST}
    Set Test Variable  ${FAULT_1907_TX_OUT_OF_ORDER}


Connect To Each Made Node And Send Devmem Command
    Log  \nSend fault on each Made Node on RMOD. [OK]  console=true
    FOR  ${number}  IN RANGE  2  10
        SSHLibrary.Set Client Configuration  prompt=REGEXP:(:~#|\\$)
        SSHLibrary.Write  ssh serviceuser@192.168.101.${number}
        ${made_node_connection}  SSHLibrary.Read Until Prompt
        Should Contain  ${made_node_connection}  Made  msg=Not able to connect on made-node with ip: 192.168.101.${number}.
        SSHLibrary.Write  sudo su
        ${made_node_connection}  SSHLibrary.Read Until Prompt
        Should Contain  ${made_node_connection}  root  msg=Not able to connect to root on made-node.
        SSHLibrary.Write  sudo devmem 0xFC9003A4 32 0x0 && exit
        SSHLibrary.Read Until Prompt
        SSHLibrary.Write  exit
        SSHLibrary.Read Until Prompt
        Sleep  5s  Wait 5 seconds to send next command.
    END

    [Teardown]  SSHLibrary.Close Connection


TC Setup
    Common VDU Setup
    Modify Resource Search Order  FM__vDU_Triggering_fault_1907_SWN


TC Teardown
    Common VDU Teardown
