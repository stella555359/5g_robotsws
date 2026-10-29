*** Settings ***
Documentation
    ...  This TC is created to trigger fault 1907 on given RMOD.
    ...  First, actForceUnitAutoReset is set to true.
    ...  RMOD id is chosen by RMOD serial number.
    ...  Fault is triggered two times, and each time recovery reset is performed.
    ...  Fault 1907 is checked every time.

Resource  ../../common_resources/vdu_frame.robot
Resource  ../../common_resources/vdu_general.robot


*** Variables ***
${RMOD_TYPE}  ${EMPTY}  #RMOD product name
${DC}  ${TRUE}  #Configuration type
${ALARM_TIMEOUT}  300s     # Timeout for alarm to appear in WebEM
${RECOVERY_TIMEOUT}  900s  # Timeout for CBTS to be onAir


*** Keywords ***
TC__FM__vDU__B5_Tx_Rx_Failure_detection_after_RF_recovery_reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29519
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  04.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29519 - Initial TAT creation
    ...  09.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29831 - Change method of connecting to RMOD and retrieving pod and container name
    ...  09.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30597 - Access files with sudo in resource

    Set Tags  CA-FM  OWNER-vicentiu.nacov@nokia.com  AUTHOR-anna.beke@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  FEATURE-CB009504-CR-BA


    Step0: TC Preconditions
    Step1: Trigger fault 1907 on RMOD
    Step2: Trigger fault 1907 on RMOD


Step0: TC Preconditions
    Log  Step0: TC Preconditions.  console=true

    Should Not Be Empty  ${RMOD_TYPE}  msg=Please provide RMOD_TYPE(e.g. AHFII)
    Perform vDU Reset
    Change Specific Parameter For VDU  actForceUnitAutoReset  true  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
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
    ${FAULT_1907_RADIO_AUTO_RST}  Create Dictionary  fault_id=1907
    ...                                              fault_name=Radio autonomous reset as recovery action
    ...                                              alarm_id=7101
    ...                                              alarm_name=BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION
    ...                                              severity=regex"Warning|warning"
    Set Test Variable  ${FAULT_1907_RADIO_AUTO_RST}


Step${index}: Trigger fault 1907 on RMOD
    Log  \nStep${index}: Trigger fault 1907 on RMOD.  console=true

    IF  ${index} ==1
        Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  5s  Check All Cells From VDU  operational_state=${ENABLED}
        ...                                                                             availability_status=${ONLINE}
        ...                                                                             administrative_state=${UNLOCKED}
        Sleep  3 minutes  Wait 3 minutes so that the RMOD re-enters runtime.
    END
    Open SSH Connection To Specific RMOD  ${RMOD}[ip]  ${RMOD}[user]  ${RMOD}[password]  ${RMOD}[serial_number]  dc=${DC}
    SSHLibrary.Write  sudo devmem 0xFC9003A4 32 0x0
    SSHLibrary.Read Until Prompt

    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  5s
    ...  Check If Fault Is Visible In VDU WebEM  ${FAULT_1907_RADIO_AUTO_RST}[alarm_id]
    ...                                          ${FAULT_1907_RADIO_AUTO_RST}[alarm_name]
    ...                                          ${FAULT_1907_RADIO_AUTO_RST}[fault_id]
    ...                                          ${FAULT_1907_RADIO_AUTO_RST}[fault_name]
    ...                                          ${FAULT_1907_RADIO_AUTO_RST}[severity]
    Log  Fault ${FAULT_1907_RADIO_AUTO_RST} is active in WebEM.[OK]  console=true

    Log  Checking RMOD and cells to be on air.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  5s  Verify RMOD Parameter By RMOD Id  ${RMOD}[id]  availability_status  ${ONLINE}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  5s  Check All Cells From VDU  operational_state=${ENABLED}
    ...                                                                             availability_status=${ONLINE}
    ...                                                                             administrative_state=${UNLOCKED}
    Log  All services are operational after fault triggering and RMOD reset.[OK]  console=true

    IF  ${index} ==1  Sleep  3 minutes  Wait 3 minutes so that the RMOD re-enters runtime.

    [Teardown]  SSHLibrary.Close Connection


TC Setup
    Common VDU Setup
    Modify Resource Search Order  FM__vDU__B5_Tx_Rx_Failure_detection_after_RF_recovery_reset


TC Teardown
    Common VDU Teardown
