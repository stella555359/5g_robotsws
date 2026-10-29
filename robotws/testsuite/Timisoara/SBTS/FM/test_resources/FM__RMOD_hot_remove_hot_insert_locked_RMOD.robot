*** Settings ***
Documentation
    ...  Test case will verify recovery functionalities related to RMOD fiber disconnection in runtime (RMOD hot remove - hot insert scenario).
    ...  If RMOD serial number is not provided tested RMOD will be randomly choosen.
    ...  Planned RMOD to be hot removed will be first locked. RMOD will be hot remove next by simulating optical fiber disconnection.
    ...  Services on unaffected resources are verified.
    ...  Hot insert RMOD and unlock RMOD.
    ...  Expected fault and alarm are verified.

Library  DateTime
Library  SSHLibrary
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RMOD_SN}  ${EMPTY}  # Radio Module serial number to be disconnected
${PING_RMOD_TIMEOUT}  300  # Timeout to restore ping to rmod, default 180s
${CELLS_ONLINE_TIMEOUT}  300  # Timeout for cell to go online before fail
${ALARM_TIMEOUT}  300


*** Keywords ***
TC__FM__RMOD_hot_remove_hot_insert_locked_RMOD
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-19427
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  -  22.4.2020 - https://jira3.int.net.nokia.com/browse/TAT-19427 - Initial TAT creation
    ...  -  06.01.2021 - https://jira3.ext.net.nokia.com/browse/TAT-20402 - Cannot unblock RMOD AdminApiProcedure Rejected
    ...  -  05.04.2020 - https://jira3.ext.net.nokia.com/browse/TAT-21132 - Remove import for ta_real_radio library
    ...  -  10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  -  28.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23842 - Remove Test Specific Teardown and Setup
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 01.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26055 - Add supplementary alarm info check
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  ******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-laura.craciunel@nokia.com  MAINTAINER-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS20  FEATURE-RP000920

    Step0: Suite Specific Preconditions
    Step1: Lock RMOD
    Step2: RMOD Hot Remove
    Step3: RMOD Hot Insert
    Step4: Unlock RMOD


Step0: Suite Specific Preconditions
    Log  Step0: Suite Specific Preconditions  console=true
    ${rmod}  Run Keyword If  '${RMOD_SN}' != ''
    ...  _Get Rmod Object By Serial Number  ${RMOD_SN}
    ...  ELSE
    ...  _Get Random Rmod Object
    Log  Selected RMOD: ${rmod.productName} with SN: ${rmod.serialNumber}  console=true
    ${rmod_cells}  Infomodel Get Cells Deployed On Module  ${rmod}
    ${left_over_cells}  Query Infomodel  get list //CELL_M-*
    Remove Values From List  ${left_over_cells}  @{rmod_cells}

    Set Test Variable  ${RMOD_IF}  RMOD_${RMOD_SN}
    Set Test Variable  ${RMOD_CELLS}
    Set Test Variable  ${LEFT_OVER_CELLS}

    ${rm}  Query Infomodel  get object //EQM_R-*//RMOD_R-* is [serialNumber="${RMOD_SN}"]
    Set Test Variable  ${RM}  ${rm.dist_name}


Step1: Lock RMOD
    Log  Step1: Lock chosen RMOD  console=true
    ${block_status}  Run Keyword And Return Status
    ...  Lock  ${RM}  timeout=300
    Run Keyword If  ${block_status}
    ...  Log  RMOD successfully locked [OK]  console=true
    ...  ELSE
    ...  Fail  msg=Cannot lock RMOD or lock takes more than 5 minutes [NOK]
    Sleep  30s
    Assert Any  RMOD  operationalState=${ENABLED}
    Assert Any  RMOD  administrativeState=${LOCKED}
    ${state}  Create Dictionary  availabilityStatus=Dependency  operationalState=Disabled
    FOR  ${im_cell}  IN  @{RMOD_CELLS}
        ${has_pair}  Infomodel Cell Has At Least One Operational RXTX Pair  ${im_cell}
        Run Keyword If  ${has_pair}
        ...  Infomodel Cell Should Be Degraded  ${im_cell}
        ...  ELSE
        ...  _Infomodel Cell Should Be  ${im_cell.dist_name}  ${state}  WARN
    END
    FOR  ${im_cell}  IN  @{LEFT_OVER_CELLS}
        Infomodel Cell Should Be Online  ${im_cell}
    END
    Admin Check Active Alarms TAF


Step2: RMOD Hot Remove
    Log  Step2: Hot remove blocked RMOD  console=true
    Store Rmod  ${RMOD_SN}
    Pdu Bts Interface Off  ${RMOD_IF}
    Wait Until Keyword Succeeds  30s  5s
    ...  Ping Rmod  expected_rc=1

    ${fault_10_params}  Get String With Alarm Parameters  ${FAULT_10_CRITICAL}
    ${fault_10_params}  Catenate  ${fault_10_params},  supplAlarmInfo="RU connection was lost in runtime"
    ${fault10_status}  Run Keyword And Return Status
    ...  Assert Alarm Active  parameters=${fault_10_params}  timeout=${ALARM_TIMEOUT}
    Run Keyword If  ${fault10_status}
    ...  Log  Fault 10 "${FAULT_10_CRITICAL}[fault_name]" was raised [OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Fault 10 "${FAULT_10_CRITICAL}[fault_name]" wasn't raised [NOK]

    ${alarms}  Assert Alarm Active  faultId=${FAULT_10_CRITICAL}[fault_id], alarmId=${FAULT_10_CRITICAL}[alarm_id]  timeout=100
    ${alarm}  Evaluate  next((alarm for alarm in ${alarms} if (u'faultId', 10) in alarm.items()))
    Log  Impacted cells after RMOD hot remove are :\n ${alarm['impactedCells']}\n  console=true
    FOR  ${im_cell}  IN  @{RMOD_CELLS}
        ${has_pair}  Infomodel Cell Has At Least One Operational RXTX Pair  ${im_cell}
        Run Keyword If  ${has_pair}
        ...  Infomodel Cell Should Be Degraded  ${im_cell}
        ...  ELSE
        ...  Infomodel Cell Should Be Failed  ${im_cell}
    END
    FOR  ${im_cell}  IN  @{LEFT_OVER_CELLS}
        Infomodel Cell Should Be Online  ${im_cell}
    END

    ${expected_alarm1}  Create Dictionary  faultId=10
    ${expected}  Create List  ${expected_alarm1}
    Admin Check Active Alarms TAF  expected_patterns=${expected}


Step3: RMOD Hot Insert
    Log  Step3: Hot insert blocked RMOD  console=true
    Pdu Bts Interface On  ${RMOD_IF}
    Sleep  60s
    Wait Until Keyword Succeeds  3m  10s
    ...  Store Rmod  ${RMOD_SN}
    Wait Until Keyword Succeeds  ${PING_RMOD_TIMEOUT}s  5s
    ...  Ping Rmod
    ${fault_10_params}  Get String With Alarm Parameters  ${FAULT_10_CRITICAL}
    ${fault_10_params}  Catenate  ${fault_10_params},  supplAlarmInfo="RU connection was lost in runtime"
    Assert Alarm Inactive  parameters=${fault_10_params}  timeout=${ALARM_TIMEOUT}


Step4: Unlock RMOD
    Log  Step4: Unlock chosen RMOD  console=true
    Sleep  60s
    ${unblock_status}  Run Keyword And Return Status
    ...  Unlock  ${RM}  timeout=300
    Run Keyword If  ${unblock_status}
    ...  Log  RMOD successfully unlocked [OK]  console=true
    ...  ELSE
    ...  Fail  Cannot unlock RMOD or unlock takes more than 5 minute [NOK]
    Sleep  60s
    Assert Any  RMOD  operationalState=${ENABLED}
    Assert Any  RMOD  administrativeState=${UNLOCKED}
    Admin Check Active Alarms TAF
    Check All Cells
    Check Links Status  Available


_Get Random Rmod Object
    [Documentation]  This KW is for random selection of the RMOD object from all available RMODs in SBTS config.

    Log  SN is not provided tested RM will be randomly choosen  console=true
    ${rmods_serial_numbers_list}  Infomodel Get All Radio Modules Serial Numbers
    ${list}  Remove Duplicates  ${rmods_serial_numbers_list}
    ${rmods_serial_numbers_list_lenght}  Get Length  ${list}
    Log  There are ${rmods_serial_numbers_list_lenght} suitable Radio Modules. One of them will be randomly choosen  console=true
    ${sn_random_position}  Evaluate  random.randint(0,${rmods_serial_numbers_list_lenght}-1)  random
    ${selected_serial_number}  Get From List  ${rmods_serial_numbers_list}  ${sn_random_position}
    ${rmod_l_obj}  _Get Rmod Object By Serial Number  ${selected_serial_number}
    Set Test Variable  ${RMOD_SN}  ${selected_serial_number}

    [Return]  ${rmod_l_obj}


Store Rmod
    [Documentation]  This KW stores the value of IP and MasterAgentDN
    [Arguments]  ${sn}

    ${rmod}  _Get Rmod Object By Serial Number  ${sn}
    ${smod_l}  Query Infomodel  get object ${rmod.masterAgentDN}
    ${smod_r}  Query Infomodel  get object //CABINET_R-*/SMOD_R-* is [serialNumber=${smod_l.serialNumber}]
    Wait Until Keyword Succeeds  90s  10s
    ...  Should Be True  '${rmod.ipAddress}' != '0.0.0.0'
    ${rmod_ip_addr}  Set Variable  ${rmod.ipAddress}
    Set Test Variable  ${SMOD_L}
    Set Test Variable  ${SMOD_R}
    Set Test Variable  ${RMOD_IP_ADDR}


Ping Rmod
    [Arguments]  ${expected_rc}=0

    Wait Until Keyword Succeeds  90s  10s
    ...  Should Be True  '${RMOD_IP_ADDR}' != '0.0.0.0'
    ${is_airscale}  Run Keyword And Return Status
    ...  Should Contain  ${SMOD_R.productName}  AirScale
    ${command}  Run Keyword If  ${is_airscale}
    ...  Make Command For AirScale  ping -c1 ${RMOD_IP_ADDR}  ${SMOD_R}
    ...  ELSE
    ...  Set Variable  ping -c1 ${RMOD_IP_ADDR}
    Connect To SMOD  ${SMOD_L.ipAddress}
    ssh.Execute  ${command}
    ssh.Assert Exit Status  ${expected_rc}


Make Command For AirScale
    [Arguments]  ${command}  ${smod_r}

    Return From Keyword  lxc-attach -n 0x${smod_r.horizontalPosition}018 -- ${command}

    [Return]  ${command}


TC Setup
    Common Test Setup  tc_name=FM__RMOD_hot_remove_hot_insert_locked_RMOD


TC Teardown
    Run Keyword And Ignore Error
    ...  Pdu Bts Interface On  RMOD_${RMOD_SN}
    Sleep  120s
    Run Keyword And Ignore Error
    ...  Unlock  ${RM}  timeout=120
    Common Test Teardown
