*** Settings ***
Documentation
    ...  Test case to verify alarm synchronization after reconnecting to NetAct.
    ...  Test will randomly select two cells to be blocked. After the first cell is blocked, alarm will be verifyed on SBTS and NetAct,
    ...  if alarm is not repored on either of them TC will pe stopped.
    ...  After first cell is blocked, M-plane IP adress will pe changed and conection to NetAct will be disonnected.
    ...  First cell is unblocked and second cell is blocked.
    ...  NetAct is reconnected by changing back the M-plane IP adress.
    ...  After reconnection the alarms on NetAct should match with SBTS alarms.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${NETACT_ALARM_TIMEOUT}  900  # Timeout for alarm to appear on Netact
${ALARM_TIMEOUT}  600  # Timeout for alarm to apper on WebEM
${RECOVERY_TIMEOUT}  1200  # Timeout for SBTS to recover
${UNBLOCK_TIMEOUT}  300  # Timeout for cell to became blocked


*** Keywords ***
TC__FM__Alarm_synchronization_after_reconnecting_to_NetAct
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21643
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  13.08.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21643 - Initial TAT creation
    ...  12.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21912 - Change TC to block only LTE cells
    ...  10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  16.12.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22358 - Cell distname parameter for block KW
    ...  01.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22577 - ta_netact_* libary replacement with taf.nms.netact
    ...  10.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22603 - Test FM__Alarm_synchronization_after_reconnecting_to_NetAct failed
    ...  17.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22804 - Test Alarm synchronization after reconnecting to NetAct is failed.
    ...  24.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23932 - Change KW called for setting IPIF interface variables
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  16.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26829 - Implement new test steps
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  24.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27400 - Fix invalid syntax
    ...  09.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28210 - Fix SC verification
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  12.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29192 - Add verification for fault 4352
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  03.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29774 - Fix variable declaration
    ...  19.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30343 - Removed unused variables
    ...  05.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30454 - Add verification for fault 4297 and 4401
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-bogdan.boldurean@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS21

    Step1: Check ENB State
    Step2: Block Cell 1 And Check NA Alarms
    Step3: Disconnect ENB From Netact By Changing MPlane IP Address
    Step4: Unblock Cell 1 And Block Cell 2
    Step5: Reconnect To Netact And Check Alarms Synchronization Unblock Cell 2
    Step6: Check ENB State
    Step7: Disconnect ENB From Netact By Changing MPlane IP Address
    Step8: Power Off/on Secondary Core
    Step9: Reconnect To Netact And Check Alarms Synchronization
    Step10: Check If All Modules And Cells Are On Air


Step1: Check ENB State
    Log  \nStep1: Check eNB state.  console=true
    ${lnce_lids}  Get Ids For All  LNCEL
    ${cells_nr}  Get Length  ${lnce_lids}
    Get Random Cells To Block  ${lnce_lids}  ${cells_nr}
    Log  First cell to be blocked is: ${FIRST_CELL}.  console=true
    Log  Second cell to be blocked is: ${SECOND_CELL}.  console=true
    Set IPIF Interface
    ${list_of_smods}  Get Fsm Info
    FOR  ${smod}  IN  @{list_of_smods}
        ${smod_r_dist_name}  Set Variable If  '${smod}[activeRole]'=='Secondary'  ${smod}[id][internal]
        IF  '${smod}[activeRole]'=='Secondary'  BREAK
    END
    ${smod_parameters}  Get Parameters For  SMOD  ${smod_r_dist_name}
    Set Test Variable  ${SERIAL_NUMBER}  ${smod_parameters}[serialNumber]
    Set Test Variable  ${PRODUCT_NAME}  ${smod_parameters}[productName]
    Set Variables For Fault Signature
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${start_time}
    Set NTP Ip Adresses


Step2: Block Cell 1 And Check NA Alarms
    Log  \nStep2: Block cell 1 and check Netact alarms.  console=true
    coam.Block Cell  dist_name=${FIRST_CELL}  timeout=300
    ${fault_49_params}  Get String With Alarm Parameters  ${FAULT_49}
    ${status_webem}  Run Keyword And Return Status
    ...  Assert Alarm Active  parameters=${fault_49_params}  timeout=60
    IF  ${status_webem}
        Log  Fault 49 is visible in WebEM.  console=true
    ELSE
        coam.Unblock Cell  dist_name=${FIRST_CELL}  timeout=${UNBLOCK_TIMEOUT}
        Fail  Fault 49 is not visible on SBTS. Test will not continue.
    END

    ${status_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_ALARM_TIMEOUT}  10
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_49}  additional_fault_id=${FAULT_49}[fault_id]
    IF  ${status_netact}
        Log  Fault 49 is visible on NetAct.  console=true
    ELSE
        coam.Unblock Cell  dist_name=${FIRST_CELL}  timeout=${UNBLOCK_TIMEOUT}
        Fail  Fault 49 is not visible on NetAct. Test will not continue.
    END

    Wait Until Keyword Succeeds  60  10
    ...  Check Block Cell Id In AdditionalText3 Of Alarm  ${FIRST_CELL}


Step${index}: Disconnect ENB From Netact By Changing MPlane IP Address
    Log  \nStep${index}: Disconnect eNB from Netact by changing mPlane IP address.  console=true
    Create IPADDRESSV4-2
    Change Mplane IP
    Log  Check 9047 on NetAct.  console=true
    ${sbts_link_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_ALARM_TIMEOUT}  10
    ...  Check 9047
    IF  ${sbts_link_status}==${FALSE}  Set Test Restriction  Alarm 9047 NE3SWS AGENT NOT RESPONDING TO REQUESTS is not seen on NetAct.
    Log  Check fault 4297 presence in WebEM.  console=true
    FOR  ${ntp_ip}  IN  @{NTP_SERVERS_IPS}
        ${fid_4297_params}  Get String With Alarm Parameters  ${FAULT_4297}
        ${fid_4297_params}  Catenate  SEPARATOR=,${SPACE}  ${fid_4297_params}  faultName="NTP Server ${ntp_ip} unavailable"
        ${check_fault_4297_webem}  Run Keyword And Return Status  Assert Alarm Active  parameters=${fid_4297_params}  timeout=${ALARM_TIMEOUT}
        Should Be True  ${check_fault_4297_webem}  Fault ${FAULT_4297} is not active in WebEM.
        Log  Fault ${FAULT_4297} is active in WebEM.  console=true
    END


Step4: Unblock Cell 1 And Block Cell 2
    Log  \nStep4: Unblock cell 1 and block cell 2.  console=true
    coam.Unblock Cell  dist_name=${FIRST_CELL}  timeout=300
    coam.Block Cell  dist_name=${SECOND_CELL}  timeout=300


Step5: Reconnect To Netact And Check Alarms Synchronization Unblock Cell 2
    Log  \nStep5: Reconnect to Netact and check alarms synchronization unblock cell 2.  console=true
    Restore Mplane
    Remove IPADDRESSV4-2
    Log  Check alarms are the same on NetAct and SBTS.  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_ALARM_TIMEOUT}  10
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_49}  additional_fault_id=${FAULT_49}[fault_id]
    IF  ${status}
        Log  Alarm is visible on NetAct.  console=true
    ELSE
        coam.Unblock Cell  dist_name=${SECOND_CELL}  timeout=300
        Fail  Alarm is not visible on NetAct. Test will not continue.
    END
    Wait Until Keyword Succeeds  60  10
    ...  Check Block Cell Id In AdditionalText3 Of Alarm  ${SECOND_CELL}
    Check If Alarms From WebEM And NetAct Are The Same
    coam.Unblock Cell  dist_name=${SECOND_CELL}  timeout=300


Step6: Check ENB State
    Log  \nStep6: Check eNB state.  console=true
    ${fault_49_params}  Get String With Alarm Parameters  ${FAULT_49}
    ${alarm_clear_status}  Run Keyword And Return Status
    ...  Assert Alarm Inactive  parameters=${fault_49_params}  timeout=10
    IF  ${alarm_clear_status}  Log  Block alarm cleard from SBTS.  console=true

    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  300s  10s
    ...  Check All Cells
    IF  ${status}
        Log  All cells are onAir.  console=true
    ELSE
        Fail  Not all cells are onAir.
    END


Step8: Power Off/on Secondary Core
    Log  \nStep8: Power off/on secondary core.  console=true
    ${smod_if}  Set Variable  SMOD_${SERIAL_NUMBER}
    Log  Power off secondary core.  console=true
    Pdu BTS Interface Off  ${smod_if}
    ${ping_loss_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Not Reachable  hostname=192.168.255.119  timeout=300  remote_host=${PC_IP2}
    IF  ${ping_loss_status}==${FALSE}
        Log  Ping is not lost.  console=true
    ELSE
        Log  Ping to secondary core is lost.  console=true
    END
    Log  Wait for secondary core to be reachable.  console=true
    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=check_alarm
    ${fault_4590_params}  Get String With Alarm Parameters  ${FAULT_4590}
    ${alarm_webem}  Run Keyword In Background  Assert alarm active  parameters=${fault_4590_params}  timeout=${ALARM_TIMEOUT}  alias=check_alarm

    Log  Power on secondary core.  console=true
    Pdu BTS Interface On  ${smod_if}
    ${ping_up_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=192.168.255.119  timeout=300  remote_host=${PC_IP2}
    IF  ${ping_up_status}==${FALSE}
        Log  Ping on secondary core is not back.  console=true
    ELSE
        Log  Secondary core is back online.  console=true
    END
    ${check_alarm_webem}  Collect Keyword Result  ${alarm_webem}  timeout=${ALARM_TIMEOUT}
    Should Be True  ${check_alarm_webem}  Fault 4590 was not active in WebEm.
    Log  Fault 4590 was active in WebEm.  console=true
    ${fault_4352_params}  Get String With Alarm Parameters  ${FAULT_4352_CORES_NOT_CONN}
    Assert Alarm Active  parameters=${fault_4352_params}  timeout=60
    Log  Fault 4352 is active in WebEm.  console=true
    Log  Verifying modules and cells to be in the right state.  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  20
    ...  Check Modules And Cells
    IF  ${status}
        Log  All modules and cells are currently active and functioning properly.  console=true
    ELSE
        Fail  The modules and cells are not in the correct state.
    END
    Log  Check fault signature in WebEM.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_4590}[fault_id]  category=${CATEGORY}  info=${INFO}  load_name=${SW_VERSION}
    ...  reset_counter=${RESET_COUNTER}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Log  Check fault 4401 presence in WebEM.  console=true
    ${historical_alarms}  coam.Get Historic Alarms
    FOR  ${alarm}  IN  @{historical_alarms}
        ${status_fault_id}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[faultId]  ${FAULT_4401}[fault_id]
        IF  ${status_fault_id}  BREAK
    END
    Should Be True  ${status_fault_id}  Fault ${FAULT_4401} was not active in WebEM.
    Log  Fault ${FAULT_4401} was active in WebEM.  console=true


Step9: Reconnect To Netact And Check Alarms Synchronization
    Log  \nStep9: Reconnect to Netact and check alarms synchronization.  console=true
    Restore Mplane
    Remove IPADDRESSV4-2
    Wait Until Keyword Succeeds  ${NETACT_ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4590}  time_from=${START_TIME}
    ...  additional_fault_id=${FAULT_4590}[fault_id]
    Log  Fault 4590 is visible on NetAct.  console=true

    Wait Until Keyword Succeeds  ${NETACT_ALARM_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4352_CORES_NOT_CONN}  time_from=${START_TIME}
    ...  additional_fault_id=${FAULT_4352_CORES_NOT_CONN}[fault_id]
    Log  Fault 4352 is visible on NetAct.  console=true
    Log  Check alarms are the same on NetAct and SBTS.  console=true

    Check If Alarms From WebEM And NetAct Are The Same
    Log  Check fault signature in Netact.  console=true

    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_4590}[fault_id]  time_from=${START_TIME}  category=CATEGORY:${SPACE}${CATEGORY}
    ...  info=INFO:${SPACE}${INFO}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}
    ...  scope=SCOPE:${SPACE}${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  unit_position=${UNIT_POSITION}
    ...  core_unit_position=${CORE_UNIT_POSITION}


Step10: Check If All Modules And Cells Are On Air
    Log  \nStep10: Check if all modules and cells are on air.  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  20
    ...  Check Modules And Cells
    IF  ${status}
        Log  All modules and cells are currently active and functioning properly.  console=true
    ELSE
        Fail  The modules and cells are not in the correct state.
    END


Set Variables For Fault Signature
    ${module_r_dn}  Get Module Dist Name By Serial Number And Class  ${SERIAL_NUMBER}  SMOD
    Set Unit Position For Fault Signature  ${module_r_dn}
    Set Test Variable  ${MINOR}  UNKNOWN
    Set Test Variable  ${INFO}  (Autonomous reset triggered by unknown|Unknown power reset.*)
    Set Test Variable  ${SCOPE}  ESM
    Set Test Variable  ${CATEGORY}  (UNKNOWN|POWER_OFF)
    Set Test Variable  ${RESET_COUNTER}  [0-9]+


Get Random Cells To Block
    [Arguments]  ${lncel}  ${cells_nr}

    ${first}  Evaluate  random.randint(0, ${cells_nr}-1)  random
    ${second}  Evaluate  random.choice([i for i in range(0,${cells_nr}-1) if i not in [${first}]])  random
    Set Cells To Block  ${lncel}  ${first}  ${second}


Set Cells To Block
    [Arguments]  ${lnce_ls}  ${first_number}  ${second_number}

    Set Test Variable  ${FIRST_CELL}  ${lnce_ls}[${first_number}]
    Set Test Variable  ${SECOND_CELL}  ${lnce_ls}[${second_number}]


Check Block Cell Id In AdditionalText3 Of Alarm
    [Arguments]  ${cell}

    ${cell_id}  Fetch From Right  ${cell}  LNCEL_R-
    ${netact_alarms}  netact.Get Alarms  dist_name=${MRBTS_DN}
    FOR  ${na_alarm}  IN  @{netact_alarms}
        ${event_type}  Get From Dictionary  ${na_alarm}  eventType
        ${additional_text1}  Get From Dictionary  ${na_alarm}  additionalText1
        ${additional_text3}  Get From Dictionary  ${na_alarm}  additionalText3
        ${condition}  Catenate  SEPARATOR=${SPACE}or${SPACE}
        ...  '${event_type}' == 'PROCESSINGERROR'
        ...  """${additional_text1}""" == 'None'
        ...  '${additional_text3}' == 'None'
        IF   ${condition}  Remove Values From List  ${netact_alarms}  ${na_alarm}
    END
    FOR  ${na_alarm}  IN  @{netact_alarms}
        ${additional_text3}  Get From Dictionary  ${na_alarm}  additionalText3
        ${cell_id_in_fault}  Fetch From Right  ${additional_text3}  LNCEL-
        ${match}  Run Keyword And Return Status
        ...  Should Be Equal  ${cell_id_in_fault}  ${cell_id}
        IF  ${match} == True  BREAK
    END
    Should Be Equal As Strings  ${match}  True


Check 9047
    ${netact_alarms}  netact.Get Alarms  dist_name=${MRBTS_DN}
    FOR  ${na_alarm}  IN  @{netact_alarms}
        ${additional_text3}  Get From Dictionary  ${na_alarm}  specificProblem
        IF  ${additional_text3}==9047
            Log  Alarm ${additional_text3} with ${na_alarm.alarmText} is seen on NetAct.  console=true
            RETURN
        ELSE IF  ${additional_text3}==9255
            Log  Alarm ${additional_text3} with ${na_alarm.alarmText} is seen on NetAct.  console=true
        END
    END
    Fail


Unblock Cells
    Run Keyword And Ignore Error
    ...  coam.Unblock Cell  dist_name=${FIRST_CELL}  timeout=300
    Run Keyword And Ignore Error
    ...  coam.Unblock Cell  dist_name=${SECOND_CELL}  timeout=300


Recovery Action
    ${first_cell_parameters}  coam.Get Parameters  ${FIRST_CELL}
    ${status_first_cell}  Run Keyword And Return Status
    ...  Should Contain  ${BLOCKED}  ${first_cell_parameters}[blockingState]
    ${second_cell_parameters}  coam.Get Parameters  ${SECOND_CELL}
    ${status_second_cell}  Run Keyword And Return Status
    ...  Should Contain  ${BLOCKED}  ${second_cell_parameters}[blockingState]
    IF  ${status_first_cell} or ${status_second_cell}  Unblock Cells
    ${bts_obj}  Get Parameters For All  BTS
    ${mplane_ip_value}  Set Variable  ${bts_obj}[0][btsMplaneIp4V]
    IF  '${mplane_ip_value}'!='${MPLANE_IP}'
        Restore Mplane
        Remove IPADDRESSV4-2
        Step10: Check If All Modules And Cells Are On Air
    END


Set NTP Ip Adresses
    ${ntp_servers_ips}  Create List
    ${ntp_servers}  coam.Get Managed Objects  NTP_R
    FOR  ${server}  IN  @{ntp_servers}
         ${parameters}  Get From Dictionary  ${server}  parameters
         ${ntp_server_status_list}  Get From Dictionary  ${parameters}  ntpServerStatusList
         FOR  ${item}  IN  @{ntp_server_status_list}
             Append To List  ${ntp_servers_ips}  ${item}[ntpServerIpAddr]
         END
    END
    Should Not Be Empty  ${ntp_servers_ips}  msg=No NTP server IP address found in Infomodel.
    Set Test Variable  ${NTP_SERVERS_IPS}


TC Setup
    Common Test Setup  tc_name=FM__Alarm_synchronization_after_reconnecting_to_NetAct
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed
    ...  Recovery Action
    Teardown NetAct
    Common Test Teardown
