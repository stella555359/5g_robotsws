*** Settings ***
Documentation
    ...  Step0: Testcase preconditions
    ...  Step 1: Power off radio module and check whether expected alarms appear.
    ...  Step 2: Power on radio module and check whether is reacheable and cells status are properly updated.

Library  taf.hw.switch  WITH NAME  switch
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RU_SWITCH_IP}  ${EMPTY}  # Mandatory. Radio unit serving switch IP.
${RU_SWITCH_USER}  ${EMPTY}  # Mandatory. Radio unit serving log in credentials.
${RU_SWITCH_PASSWORD}  ${EMPTY}  # Mandatory. Radio unit serving log in credentials.
${RU_SWITCH_INTERFACE}  ${EMPTY}  # Mandatory. Radio unit serving switch interface.
${RU_SWITCH_SHELF}  ${EMPTY}  # Mandatory. Radio unit serving switch shelf id.
${RU_SWITCH_SLOT}  ${EMPTY}  # Mandatory. Radio unit serving switch slot id.
${RU_SWITCH_PORT}  ${EMPTY}  # Mandatory. Radio unit serving switch port id.
${RMOD_SN}  ${EMPTY}  # Mandatory. Radio module serial number to be disconnected.
${PING_RMOD_TIMEOUT}  300  # Timeout to restore ping to rmod, default 180s.
${CELLS_ONLINE_TIMEOUT}  300  # Timeout for cell to go online before fail.
${RMOD_INSERT_TIMEOUT}  300  # Timeout for radio module to become online.
${ALARM_TIMEOUT}  300  # Timeout for alarm to be reported.
${CHECK_NA_ALARM}  True  # False or True. The value is used to check alarm presence in NetAct.


*** Keywords ***
TC__FM__RF_hot_remove_hot_insert_via_SWN_RU
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26620
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 19.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26620 - Initial TAT creation
    ...  - 02.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27274 - Add faults for watchdog monitoring
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  - 05.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28353 - Test fails due to removing severity from FAULT_10_CRITICAL dictionary
    ...  *******************

    Set Tags  CA-FM  OWNER-simona.marcu@nokia.com  AUTHOR-laura.craciunel@nokia.com  MAINTAINER-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS23  FEATURE-RP001534

    Step0: Testcase Preconditions
    Step1: Radio Module Hot Remove
    Step2: Radio Module Hot Insert


Step0: Testcase Preconditions
    Log  Step0: Testcase preconditions.  console=true
    Check If Parameters Values Are Given

    ${fault_10_dictionary}  Copy Dictionary  ${FAULT_10_CRITICAL}
    Remove From Dictionary  ${fault_10_dictionary}  severity
    ${parameters}  Get String With Alarm Parameters  ${fault_10_dictionary}
    ${parameters}  Catenate  ${parameters},  severity=regex"${FAULT_10_CRITICAL}[severity]|${FAULT_10_MAJOR}[severity]"

    ${parameters_with_suppl_alarm_info}  Catenate  ${parameters},  supplAlarmInfo="RU connection was lost in runtime"
    ${software}  Get Software Info
    ${active_sw}  Get From Dictionary  ${software}  Active SW version
    ${sw_variant}  Fetch From Left  ${active_sw}  _
    ${alarm_parameters}  Set Variable If  '${sw_variant}' < 'SBTS24R2'  ${parameters}  ${parameters_with_suppl_alarm_info}
    Set Test Variable  ${ALARM_PARAMETERS}
    Set Test Variable  ${SW_VARIANT}

    ${rmod}  _Get Rmod Object By Serial Number  ${RMOD_SN}
    ${rmod_cells}  Infomodel Get Cells Deployed On Module  ${rmod}
    ${left_over_cells}  Query Infomodel  get list //CELL_M-*
    Remove Values From List  ${left_over_cells}  @{rmod_cells}
    Set Test Variable  ${RMOD_CELLS}
    Set Test Variable  ${LEFT_OVER_CELLS}
    ${product_name}  Get From Dictionary  ${rmod}  productName
    Set Test Variable  ${UNIT_NAME}  ${product_name}

    ${conf_obj}  Get ConfigObjectName Value
    Set Test Variable  ${CONF_OBJ}


Step1: Radio Module Hot Remove
    Log  Step1: Radio module hot remove.  console=true
    Store Radio Module IP Adress  ${RMOD_SN}
    Connect To Radio Module Serving Switch And Perform Action  ${RU_SWITCH_IP}  ${RU_SWITCH_USER}  ${RU_SWITCH_PASSWORD}  ${RU_SWITCH_INTERFACE}
    ...  ${RU_SWITCH_SHELF}  ${RU_SWITCH_SLOT}  ${RU_SWITCH_PORT}  down

    Wait Until Keyword Succeeds  30s  5s
    ...  Ping Radio Module  expected_rc=1
    ${alarms}  Assert Alarm Active  parameters=${ALARM_PARAMETERS}  timeout=${ALARM_TIMEOUT}
    ${alarm}  Evaluate  next((alarm for alarm in ${alarms} if (u'faultId', 10) in alarm.items()))
    Log  Impacted cells list from alarm:\n ${alarm['impactedCells']}  console=true

    Log  configObjectName in alarm is: ${alarm['configObjectName']}  console=true
    ${config_object_check}  Run Keyword And Return Status
    ...  Should Be Equal  ${alarm['configObjectName']}  ${CONF_OBJ}
    Run Keyword If  ${config_object_check}
    ...  Log  Configuration alarming object in alarm is field correctlly.  console=true
    ...  ELSE
    ...  Set Test Restriction  Configuration alarming object in alarm is incorrect. [NOK]

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
    Run Keyword If  ${CHECK_NA_ALARM}
    ...  Check Alarm Presence In Netact


Step2: Radio Module Hot Insert
    Log  Step2: Radio module hot insert.  console=True
    Connect To Radio Module Serving Switch And Perform Action  ${RU_SWITCH_IP}  ${RU_SWITCH_USER}  ${RU_SWITCH_PASSWORD}  ${RU_SWITCH_INTERFACE}
    ...  ${RU_SWITCH_SHELF}  ${RU_SWITCH_SLOT}  ${RU_SWITCH_PORT}  up

    Sleep  60s  Wait for radio unit after power on.
    Wait Until Keyword Succeeds  ${RMOD_INSERT_TIMEOUT}s  10s
    ...  Store Radio Module IP Adress  ${RMOD_SN}
    Wait Until Keyword Succeeds  ${PING_RMOD_TIMEOUT}s  5s
    ...  Ping Radio Module
    ${alarm}  Assert Alarm Inactive  parameters=${ALARM_PARAMETERS}  timeout=${ALARM_TIMEOUT}
    ${cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${CELLS_ONLINE_TIMEOUT}s  10s
    ...  Check All Cells
    Run Keyword If  ${cells_status}
    ...  Log  All cells are up after hot insert.  console=true
    ...  ELSE
    ...  Fail  Cells didn't manage to recover after hot insert.
    Admin Check Active Alarms TAF


Check If Parameters Values Are Given
    Run Keyword If  '${RMOD_SN}' == ''
    ...  Fail  Please provide radio module serial number value for test: RMOD_SN.
    Run Keyword If  '${RU_SWITCH_IP}' == '' or '${RU_SWITCH_USER}' == '' or '${RU_SWITCH_PASSWORD}' == '' or '${RU_SWITCH_INTERFACE}' == ''
    ...  Fail  Please provide radio unit serving switch values for test: RU_SWITCH_IP, RU_SWITCH_USER, RU_SWITCH_PASSWORD, RU_SWITCH_INTERFACE.
    Run Keyword If  '${RU_SWITCH_SHELF}' == '' or '${RU_SWITCH_SLOT}' == '' or '${RU_SWITCH_PORT}' == ''
    ...  Fail  Please provide radio unit conection to serving switch values for test: RU_SWITCH_SHELF, RU_SWITCH_SLOT, RU_SWITCH_PORT.


Get ConfigObjectName Value
    ${bts_name}  Infomodel Get Objects Parameter  //MRBTS_A-*  btsName
    ${rmods}  coam.Get_frm
    FOR  ${rmod}  IN  @{rmods}
        ${rmod_id}  Set Variable If  '${rmod}[serialNumber]' == '${RMOD_SN}'  ${rmod}[id]
        Exit For Loop If  '${rmod}[serialNumber]' == '${RMOD_SN}'
    END
    ${configuration_object}  Set Variable  [${bts_name[0]}] ${rmod_id}[configuration]

    [Return]  ${configuration_object}


Connect To Radio Module Serving Switch And Perform Action
    [Arguments]  ${switch_ip_address}  ${switch_user}  ${switch_password}  ${interface}  ${shelf}  ${slot}  ${port}  ${action}

    ${status}  Check If Target Is Stable  ${switch_ip_address}  30  30  90
    Run Keyword If  ${status}
    ...  Log  Serving switch with IP address ${switch_ip_address} is reachable, test will be continue.  console=true
    ...  ELSE
    ...  Fail  Serving switch with IP address ${switch_ip_address} is not reachable, test will be set as failed.
    Log  Opening ssh connection to switch: ${switch_ip_address} and performing operation: config interface state ${action}.  console=true
    switch.Connect To  hostname=${switch_ip_address}  username=${switch_user}  password=${switch_password}  type=nokia1830tps
    Run Keyword If  '${action}' == 'down'
    ...  switch.Disable Interface  interface_id=${interface} ${shelf}/${slot}/${port}
    ...  ELSE IF  '${action}' == 'up'
    ...  switch.Enable Interface  interface_id=${interface} ${shelf}/${slot}/${port}
    ...  ELSE
    ...  Log  Please provide down OR up value for parameter.  console=true


Power On Target Radio Module
    Log  Affected radio module will be turned on.  console=True
    Connect To Radio Module Serving Switch And Perform Action  ${RU_SWITCH_IP}  ${RU_SWITCH_USER}  ${RU_SWITCH_PASSWORD}  ${RU_SWITCH_INTERFACE}
    ...  ${RU_SWITCH_SHELF}  ${RU_SWITCH_SLOT}  ${RU_SWITCH_PORT}  up
    ${alarm}  Assert Alarm Inactive  parameters=${ALARM_PARAMETERS}  timeout=${ALARM_TIMEOUT}


Store Radio Module IP Adress
    [Arguments]  ${sn}

    ${rmod}  _Get Rmod Object By Serial Number  ${sn}
    Should Be True  '${rmod.ipAddress}' != '0.0.0.0'
    Set Test Variable  ${RMOD_IP_ADDR}  ${rmod.ipAddress}


Ping Radio Module
    [Arguments]  ${expected_rc}=0

    Wait Until Keyword Succeeds  90s  10s
    ...  Should Be True  '${RMOD_IP_ADDR}' != '0.0.0.0'
    Connect To SMOD  192.168.255.129
    ${containers}  ssh.Execute  lxc-ls
    ${018_matches}  Get Regexp Matches  ${containers}  0x\\d018
    ${command}  Set Variable  lxc-attach -n ${018_matches}[0] -- ping -c1 ${RMOD_IP_ADDR}
    ssh.Execute  ${command}
    ssh.Assert Exit Status  ${expected_rc}


Check Alarm Presence In Netact
    ${alarm_na}  Run Keyword If  '${SW_VARIANT}' < 'SBTS24R2'
    ...  Run Keyword And Return Status
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_10_CRITICAL}  additional_severity=${FAULT_10_MAJOR}[severity]
    ...  additional_fault_id=${FAULT_10_CRITICAL}[fault_id]
    ...  ELSE
    ...  Run Keyword And Return Status
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_10_CRITICAL}  additional_severity=${FAULT_10_MAJOR}[severity]
    ...  additional_fault_id=${FAULT_10_CRITICAL}[fault_id]
    ...  suppl_info=RU connection was lost in runtime
    Run Keyword If  ${alarm_na}
    ...  Log  Alarm with faultId=10, faultName=${FAULT_10_CRITICAL}[fault_name] is present in NA.  console=true
    ...  ELSE
    ...  Fail  Alarm is not present in NA or alarm fields not correct. [NOK]
    ${check_unit_name}  Run Keyword And Return Status
    ...  Check Unit_Name In Alarm Additional Text  ${UNIT_NAME}  RMOD
    Run Keyword If  ${check_unit_name}
    ...  Log  Unit Name is correctlly displayed in additionalText3 in NA alarm.  console=true
    ...  ELSE
    ...  Fail  Unit Name is not correctlly displayed in NA alarm. [NOK]


TC Setup
    Common Test Setup  tc_name=FM__RF_hot_remove_hot_insert_via_SWN_RU
    Run Keyword If  ${CHECK_NA_ALARM}
    ...  Setup NetAct


TC Teardown
    Power On Target Radio Module
    Run Keyword If  ${CHECK_NA_ALARM}
    ...  Teardown NetAct
    Common Test Teardown
