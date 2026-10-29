*** Settings ***
Documentation
    ...  Make cells degraded by sending FaultID to given antenna line and RMOD. Then send crash to WCDMA DSP from master
    ...  (ex: id 12..).  Verify alarms, RAT should not reset. If alarm "RAT autonomous reset as recovery action" is present in
    ...  alarm history, test is failed.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RMOD_SN}  ${EMPTY}  # [OPTIONAL] RF module serial number (for example F7160910586)
${FAULT_ID}  1907  # [OPTIONAL] Fault to be provoked on RF module (at this moment only 1907 fault is supported)
${ANTL}  1  # [OPTIONAL] Fault will be send on this Antenna line. (for example 1, 2, 3)
${ALARM_TIMEOUT}  660  # Timeout for alarm reporting in WebEM
${STARTUP_TIMEOUT}  900  # Timeout for site to recover


*** Keywords ***
TC__FM__RAT_reset_actForceAutoReset_true_degraded_cell
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-16942
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  30.03.2020 - https://jira3.int.net.nokia.com/browse/TAT-16942 - Create TC
    ...  19.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19746 - Move keywords to resource file
    ...  05.04.2020 - https://jira3.ext.net.nokia.com/browse/TAT-21132 - Remove import for ta_real_radio library
    ...  24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  09.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22596 - RF module alarm cancel fault 1907 fails due to missing CONF_REF-1
    ...  07.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24051 - Optimization of KW usage for FM
    ...  14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  14.02.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24115 - Test not able to send WCDMA DSP crash to the Slave Secondary Core
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  12.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25140 - Test fail since test does not wait enough for fault to occur
    ...  09.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25324 - Choose WCDMA cells from different cell group
    ...  15.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26675 - following tests fail when try to access/ping a RF from slave
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27704 - Add option to skip RMOD power check
    ...  27.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29372 - Enhancement for CB008708
    ...  13.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29635 - Added wait time for correct infomodel response
    ...  16.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30319 - Added maintenance window cleanup in case the test failed
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-bogdan.boldurean@nokia.com  MAINTAINER-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS20  FEATURE-RP001534

    Step 0: TC Specific Preconditions
    Step 1: Send Fault To RMOD
    Step 2: Verify Alarms And Cells States
    Step 3: Trigger WCDMA DSP Crash
    Step 4: Activate Maintenance Window
    Step 5: Deactivate Maintenance Window
    Step 6: Recovery Action


Step 0: TC Specific Preconditions
    [Timeout]  20min

    Log  \nStep 0: TC Specific Preconditions.  console=true
    ${is_rmod_defined}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${RMOD_SN}
    IF  ${is_rmod_defined}
        ${tested_rmod}  Get Chosen RMOD Object
    ELSE
        ${tested_rmod}  Get Default RMOD Object
    END
    Set Test Variable  ${TESTED_RMOD}
    Validate Fault Id  ${FAULT_ID}
    Validate Antenna Line  ${ANTL}
    Set Test Variable  ${RMOD_SN}  ${TESTED_RMOD}[serialNumber]
    Log  RMOD SN is ${RMOD_SN}  console=true
    Set Test Variable  ${RMOD_L_DN}  ${TESTED_RMOD}[dist_name]
    Log  RMOD distName is: ${RMOD_L_DN}  console=true
    Set Test Variable  ${RMOD_IP}  ${TESTED_RMOD}[ipAddress]
    Log  RMOD IP is: ${RMOD_IP}  console=true
    ${scf_cells}  Get Cells
    Log  Cells on RMOD ANTL:\n ${scf_cells}  console=true
    ${rmod_r_dn}  Set Variable  ${RMOD_R}[dist_name]
    Set Test Variable  ${RMOD_R_DN}
    ${rmod_cells}  Get Cell Mapping By Module Id  ${RMOD_R_DN}
    Set Test Variable  ${RMOD_CELLS}

    ${active_tx_number}  Check Working Cells Count
    Should Not Be Equal As Integers  ${active_tx_number}  0  msg=No active TXs on RMOD

    Set Test Variable  ${SCF_CELLS}
    Set Test Variable  ${ACTIVE_TX_NUMBER}
    Set Test Variable  ${TESTED_RMOD}
    ${initial_value}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    Set Test Variable  ${INITIAL_VALUE}
    Log  Value actForceAutoReset is ${INITIAL_VALUE}  console=true
    ${status}  Run Keyword And Return Status
    ...  Change Parameter ActForce(Unit)AutoReset  true  actForceAutoReset
    ${parameter_after_change}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    IF  ${status}  Should Be Equal  ${parameter_after_change}  true
    create data.Dat And Put 0xffff


Validate Fault Id
    [Arguments]  ${fault_id}

    @{valid_faults_ids}  Create List  1907  1910  1911
    List Should Contain Value  ${valid_faults_ids}  ${fault_id}  msg=This FaultId is not supported


Validate Antenna Line
    [Arguments]  ${antl}

    @{valid_antenna_lines}  Create List  1  2  3  4  5  6
    List Should Contain Value  ${valid_antenna_lines}  ${antl}  msg=This antenna line is not supported


Get Default RMOD Object
    [Documentation]  This KW was created to randomly choose tested RM. 5.1 radio modules are filtered out as the is no testing method

    Log  SN is not provided tested RM will be randomly choosen  console=true
    ${filtered_rmods}  Create List
    ${rmod_r}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmod_r}
        ${rmod_cells}  Get Cell Mapping By Module Id  ${rmod}[id]
        ${cells_status}  Run Keyword And Return Status
        ...  Should Contain  '${rmod_cells}'  WNCEL
        IF  '${rmod}[l3Protocol]' != 'CPRI_RP1' and ${cells_status}  Append To List  ${filtered_rmods}  ${rmod}
    END

    ${lenght}  Get Length  ${filtered_rmods}
    Log  There are ${lenght} suitable RMs. One of them will be randomly choosen  console=true

    ${selected_position_of_r_min_array}  Evaluate  random.randint(0,${lenght}-1)  random
    ${selected_rmod}  Get From List  ${filtered_rmods}  ${selected_position_of_r_min_array}

    Log  Selected RMOD: ${selected_rmod}[productName] with SN: ${selected_rmod}[serialNumber]  console=true

    Set Test Variable  ${TESTED_RMOD_SN}  ${selected_rmod}[serialNumber]

    ${rmod_r}  Get Infomodel Object  //RMOD_R-* is [serialNumber=${TESTED_RMOD_SN}]
    Set Test Variable  ${RMOD_R}  ${rmod_r}
    ${rmod_ref}  Query Infomodel  get object ${RMOD_R}[dist_name]/REF-*
    ${rmod}  Query Infomodel  get object ${rmod_ref}[distName]

    [Return]  ${rmod}


Get Chosen RMOD Object
    ${rmod_r}  Get Infomodel Object  //RMOD_R-* is [serialNumber=${RMOD_SN}]
    Set Test Variable  ${RMOD_R}  ${rmod_r}
    ${rmod_ref}  Query Infomodel  get object ${RMOD_R}[dist_name]/REF-*
    ${rmod}  Query Infomodel  get object ${rmod_ref}[distName]
    [Return]  ${rmod}


Get Chosen Rmod Distname
    [Arguments]  ${rmod_serial_number}

    ${rmods_distnames}  Infomodel Get All Radio Modules Distname
    ${rmods_serial_numbers}  Get Radio Modules Serial Numbers  ${rmods_distnames}
    Validate Rmod Id  ${rmod_serial_number}  ${rmods_serial_numbers}
    ${selected_rmod_distname}  Get From Dictionary  ${rmods_serial_numbers}  ${rmod_serial_number}
    [Return]  ${selected_rmod_distname}


Validate Rmod Id
    [Arguments]  ${rmod_serial_number}  ${rmods_serial_numbers}

    Dictionary Should Contain Key  ${rmods_serial_numbers}  ${rmod_serial_number}  msg=There is no RMOD with given Serial Number


Get Radio Modules Serial Numbers
    [Arguments]  ${rmods_distnames}

    ${rmods_serial_numbers}  Create Dictionary
    FOR  ${rmod_single_distname}  IN  @{rmods_distnames}
        ${rmod_obj}  Query Infomodel  get object ${rmod_single_distname}
        Set To Dictionary  ${rmods_serial_numbers}  ${rmod_obj['serialNumber']}=${rmod_single_distname}
    END

    [Return]  ${rmods_serial_numbers}


Get Chosen Rmod Ip
    [Arguments]  ${rmod_serial_number}

    ${rmod}  Infomodel Get RMOD By Serial Number  ${rmod_serial_number}

    [Return]  ${rmod.ipAddress}


Get Cells
    ${cells}  Infomodel Get Scf Cells Deployed On RMOD  ${RMOD_L_DN}
    ${cells2}  Create List

    ${rmod_list}  Query Infomodel  get list //RUNTIME_VIEW-*//RMOD_R-*
    FOR  ${rmod}  IN  @{rmod_list}
        ${rmod_a}  Query Infomodel  get object ${rmod}[configDN]
        IF  "${rmod}[serialNumber]" == "${RMOD_SN}"
            Set Test Variable  ${rmod_a}
            BREAK
        END
    END

    FOR  ${cell}  IN  @{cells}
        Remove From Dictionary  ${cell}  distName  intShutdownTimeout
        ${rmod_antl_dn}  Set Variable  ${rmod_a}[dist_name]/ANTL_A-${ANTL}
        ${status}  ${txs}  Run Keyword And Ignore Error
        ...  Query Infomodel  get list ${cell}[dist_name]/CHANNELGROUP_A-*/CHANNEL_A-* is [direction=RX, antlDN=${rmod_antl_dn}]  timeout=30
        Continue For Loop If  '${status}' == 'FAIL'
        TX On Other Antenna Exists  ${rmod_a}  ${ANTL}
        ${tx_number}  Get Cell TX Number  ${cell}
        Set To Dictionary  ${cell}  tx  ${txs}  tx_number  ${tx_number}
        Append To List  ${cells2}  ${cell}
    END

    [Return]  ${cells2}


Get Cell TX Number
    [Arguments]  ${cell}

    ${txs}  Query Infomodel  get list ${cell}[dist_name]/CHANNELGROUP_A-*/CHANNEL_A-* is [direction=RX]  timeout=30
    ${tx_number}  Get Length  ${txs}

    [Return]  ${tx_number}


TX On Other Antenna Exists
    [Arguments]  ${rmod}  ${antl}

    ${antl}  Convert To Integer  ${antl}
    ${txs}  Query Infomodel  get list //CELLMAPPING_A-1//CHANNELGROUP_A-*/CHANNEL_A-* is [direction=RX]  timeout=30
    FOR  ${tx}  IN  @{txs}
        ${status_rmod}  Run Keyword And Return Status
        ...  Should Contain  ${tx}[antlDN]  ${rmod}[dist_name]
        IF  ${status_rmod} == ${FALSE}  CONTINUE
        ${antenna}  Set Variable  ${tx.antlDN[-1]}
        ${antenna}  Convert To Integer  ${antenna}
        IF  ${antenna} > 6
            ${antenna}  Evaluate  ${antenna} % 6
        ELSE
            ${antenna}  Set Variable  ${antenna}
        END
        IF  ${antenna} != ${antl}
            Log  At least one TX on other antl exists.  console=true
            RETURN  ${TRUE}
        END
    END
    Fail  There is no TX on other ANTL on this RMOD.


Check Working Cells Count
    ${im_module_object}  Query Infomodel  get object ${TESTED_RMOD}[masterAgentDN]
    IF  ("192.168.255.7" or "192.168.255.119") in "${im_module_object}[ipAddress]"
        ${connection}  Set Variable  fct-4a
    ELSE IF  "FSMF" in "${im_module_object}[productName]"
        ${connection}  Set Variable  fct
    ELSE
        ${connection}  Set Variable  ${im_module_object}[ipAddress]
    END
    ${tx_power}  Get Tx Power  ${TESTED_RMOD}[ipAddress]  ${connection}  ${TESTED_RMOD}[productName]
    ${tx_power_states}  Get Dictionary Values  ${tx_power}
    ${not_working_cells_count}  Count Values In List  ${tx_power_states}  OFF
    ${all_cells_count}  Get Length  ${tx_power_states}
    ${working_cells_count}  Evaluate  ${all_cells_count} - ${not_working_cells_count}

    [Return]  ${working_cells_count}


Step 1: Send Fault To RMOD
    Log  \nStep 1: Send Fault To RMOD.  console=true
    Log  Check which SM variant will be used  console=true
    ${sm_varian}  Get SM Variant For RMOD  ${TESTED_RMOD}
    Set Test Variable  ${SM_VARIAN}
    Log  RM is connected to: ${SM_VARIAN}  console=true
    IF  '${SM_VARIAN}'=='AirScale'  Send Fault 1907 To Single RX On AirScale  ${ANTL}
    IF  '${SM_VARIAN}'=='FSMr3'  Send Fault 1907 To Single RX On Rel3  ${RMOD_IP}  ${ANTL}


Send Fault 1907 To Single RX On AirScale
    [Arguments]  ${rx}

    Log  Sending Fault 1907 to rx ${rx} on ${RMOD_IP} RMOD.  console=true

    Get And Save SM Position  ${TESTED_RMOD}

    ${smod}  Query Infomodel  get object ${TESTED_RMOD}[masterAgentDN]
    Connect To SMOD  ${smod}[ipAddress]
    ssh.Execute  lxc-attach -n 0x${SMOD_POSITION_INTEGER}018 -- bash -c '{ echo "sendFault 1130 ${rx} 0 0 0 0"; sleep 1; } | telnet ${RMOD_IP} 2323'


Get And Save SM Position
    [Documentation]  KW returns SMOD Position in integer 1 or 2 for AriScale
    [Arguments]  ${rmod}

    ${smod}  Query Infomodel  get object ${rmod}[masterAgentDN]
    Log  Current SMOD to which tested radio module is connected has nodeId: ${smod}[nodeIdOwn]  console=true
    ${smod_position}  Run Keyword And Return Status
    ...  Should Contain  '${smod}[nodeIdOwn]'  4113

    ${smod_position_integer}  Set Variable If  ${smod_position}==${TRUE}  1  ${smod_position}==${FALSE}  2
    Set Test Variable  ${SMOD_POSITION_INTEGER}


Send Fault 1907 To Single RX On Rel3
    [Arguments]  ${rmod_ip}  ${rx}

    Log  Sending Fault 1907 to rx ${rx} on ${rmod_ip} RMOD.  console=true

    ${smod}  Query Infomodel  get object ${TESTED_RMOD}[masterAgentDN]
    Connect To SMOD  ${smod}[ipAddress]
    ssh.Execute  { echo "sendFault 1130 ${rx} 0 0 0 0"; sleep 1; } | telnet ${rmod_ip} 2323


Step 2: Verify Alarms And Cells States
    Log  \nStep 2: Verify alarms and cells states after fault sending  console=true
    Sleep  60
    ${active_alarms}  coam.Get Active Alarms
    ${collect_snapshot}  Set Variable  ${FALSE}
    ${critical}  Set Variable  ${FALSE}
    FOR  ${cell}  IN  @{SCF_CELLS}
        ${status}  Run Keyword And Return Status
        ...  Should Contain  ${cell}[dist_name]  LCELC
        Continue For Loop If  ${status}
        ${cell_tx_number}  Convert To Integer  ${cell}[tx_number]
        ${critical}  Set Variable If  '${cell_tx_number}' == '${1}'  ${TRUE}
    END

    IF  ${critical}
        ${expected_alarm}  Create Dictionary  faultId=1911  severity=Critical
    ELSE
        ${expected_alarm}  Create Dictionary  faultId=1911  severity=Major
    END
    ${ignored_alarms}  Create Dictionary  faultId=4003
    ${expected}  Create List  ${expected_alarm}
    ${ignored}  Create List  ${ignored_alarms}
    ${status}  Run Keyword And Return Status
    ...  Admin Check Active Alarms TAF  expected_patterns=${expected}  ignored_patterns=${ignored}  timeout=180
    IF  '${status}' == 'False'
        Fail  Expected alarm missing or unexpected alarm is visible.
    ELSE
        Log  Expected alarm is visible [OK]  console=true
    END
    ${collect_snapshot}  Set Variable If  '${status}' == 'False'  ${TRUE}

    ${cells_status}  Run Keyword And Return Status
    ...  Assert Any  class_name=WNCEL  parameters=availabilityStatus=${DEGRADED}
    IF  ${cells_status}
        Log  At least one cell is degraded after sending fault on RMOD. [OK]  console=true
    ELSE
        Set Test Restriction  There are no degraded cells after sending fault on RMOD. [NOK]
    END


Get Cell Object
    [Arguments]  ${scf_cell}

    ${appropriate_cells}  Query Infomodel  get list /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1//CELL_M-*/CONF_REF-* is [distName=${scf_cell.dist_name}]
    Sort List  ${appropriate_cells}
    ${status}  ${value}  Run Keyword And Ignore Error
    ...  Get From List  ${appropriate_cells}  0
    IF  '${status}' == 'PASS'
        ${cell_dn}  ${conf}  Split Path  ${value.dist_name}
    ELSE
        Fail  Cannot get runtime cell object for ${scf_cell} from Infomodel.
    END
    ${cell}  Query Infomodel  get object ${cell_dn}

    [Return]  ${cell}


Step 3: Trigger WCDMA DSP Crash
    [Documentation]  In this step WCDMA DSP crash will be performed.

    Log  \nStep 3: Trigger WCDMA DSP Crash.  console=true

    ${all_rmods_power_before_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    ${all_rmods_power_after_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_AFTER_RECO_RESET}

    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}

    Check Links Status  Available
    ${affected_cell_dn}  Wait Until Keyword Succeeds  120  10
    ...  Get One Degraded Cell On Rmod
    ${cell_group}  Identify Cell Group And Choose Another Cell Group  ${affected_cell_dn}
    Choose DSP For Crash Test  ${cell_group}

    Log  DSPs stateInfo will be checked under specified pattern:  console=true
    ${dsp}  Query Infomodel  get list //DSP_L-1
    Verify Parameters  ${dsp}  .stateInfo  operationalState=Enabled  availabilityStatus=Online  proceduralState=RoutingLoaded

    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=cellsCheck

    ${fault_dsp_app_fatal_err}  Copy Dictionary  ${FAULT_6707_DSP_APP_FATAL_ERR}
    Set To Dictionary  ${fault_dsp_app_fatal_err}  fault_id=regex"6707|6708|6709"
    ${fault_dsp_app_fatal_err_params}  Get String With Alarm Parameters  ${fault_dsp_app_fatal_err}
    ${fault_status}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_dsp_app_fatal_err_params}  timeout=${ALARM_TIMEOUT}

    ${cells_status}  Run Keyword And Return Status
    ...  Assert Any  class_name=WNCEL  parameters=operationalState=${DISABLED}
    IF  ${cells_status}
        Set Test Restriction  WCDMA cells were failed before DSP crash. [NOK]
    ELSE
        Log  WCDMA cells were not failed before DSP crash. [OK]  console=true
    END

    DSP Crash  ${DSP_NODE_ID}

    ${status_fault}  Run Keyword And Return Status
    ...  Collect Keyword Result  ${fault_status}  timeout=${ALARM_TIMEOUT}
    IF  ${status_fault}
        Log  Fault 6707|6708|6709 "${FAULT_6707_DSP_APP_FATAL_ERR}[fault_name]" occured. [OK]  console=true
    ELSE
        Fail  Fault 6707/6708/6709 "${FAULT_6707_DSP_APP_FATAL_ERR}[fault_name]" didn't occur. [NOK]
    END
    ${cells_status}  Run Keyword And Return Status
    ...  Assert Any  class_name=WNCEL  parameters=operationalState=${DISABLED}
    IF  ${cells_status}
        Log  At least one cell is failed after DSP crash. [OK]  console=true
    ELSE
        Set Test Restriction  WCDMA cells were not failed after DSP crash. [NOK]
    END

    ${hist_alarms}  Get Historic Alarms
    Log  ${hist_alarms}  console=true
    FOR  ${alarm}  IN  @{hist_alarms}
        IF  '${alarm}[alarmDetail]' == 'RAT autonomous reset as recovery action'
            Fail  RAT autonomous reset as recovery action found in history alarms.
        END
    END


Step 4: Activate Maintenance Window
    Log  \nStep 4: Activate Maintenance Window.  console=true
    Create Maintenance Window
    ${status_wcdma_cells}  Run Keyword And Return Status  Assert Any  WNCEL  availabilityStatus=${DEGRADED}
    ${status_gsm_cells}  Run Keyword And Return Status  Assert Any  GNCEL  availabilityStatus=${DEGRADED}
    IF  ${status_wcdma_cells} or ${status_gsm_cells}
        ${forced_recovery_status}  Set Variable  NothingToDo
        ${recovery_execution_result}  Set Variable  No recovery reset needed
        Sleep  20s  Waiting for the Forced Recovery status to be correctly completed.
        ${parameter_object}  Query Infomodel  get list /MRBTS-1/RAT-1/FRI-*/FORCED_RECOVERY_INFO-*
        Verify Force Recovery Parameters  ${parameter_object}  ${FAULT_6707_DSP_APP_FATAL_ERR}
        ...  forced_recovery_status=${forced_recovery_status}  recovery_execution_result=${recovery_execution_result}
    ELSE
        Wait Until Keyword Succeeds  900s  10s
        ...  Check All Cells
        ${parameter_object}  Wait Until Keyword Succeeds  300  10  Get Forced Recovery Parameter When Is Completed
        Verify Force Recovery Parameters  ${parameter_object}  ${FAULT_6707_DSP_APP_FATAL_ERR}
    END


Step 5: Deactivate Maintenance Window
    Log  \nStep 5: Deactivate Maintenance Window.  console=true
    Delete Maintenance Window


Get One Degraded Cell On Rmod
    FOR  ${cell}  IN  @{RMOD_CELLS}
        ${gncel_status}  Run Keyword And Return Status
        ...  Should Contain  ${cell}  GNCEL
        Continue For Loop If  ${gncel_status}
        ${cell_parameters}  coam.Get Parameters  ${cell}
        ${ref_parameters}  coam.Get Parameters  ${cell}/REF-100
        ${cell_m}  Set Variable  ${ref_parameters}[distName]
        ${status}  Run Keyword And Return Status
        ...  Should Contain  ${DEGRADED}  ${cell_parameters}[availabilityStatus]
        IF  ${status}  RETURN  ${cell_m}
    END
    Fail  There are no degraded cell after sending the fault on rmod.


Identify Cell Group And Choose Another Cell Group
    [Arguments]  ${cell_m}

    ${wcdma_cell_groups}  Query Infomodel  get list //WNBTS_M-*/CELL_GROUP-*
    FOR  ${group}  IN  @{wcdma_cell_groups}
        ${cells_list}  Set Variable  ${group}[cellDNs]
        ${status}  Run Keyword And Return Status
        ...  List Should Not Contain Value  ${cells_list}  ${cell_m}
        IF  ${status}  RETURN  ${group}[dist_name]
    END
    Fail  No different cell group found.


Choose DSP For Crash Test
    [Arguments]  ${cell_group}

    ${group_id}  Fetch From Right  ${cell_group}  -
    ${wcdma_parameters}  Query Infomodel  get list //WCDMA_PARAMETERS-* is [lcgId=${group_id}]
    ${selected_wcdma}  Evaluate  random.choice(${wcdma_parameters})  random
    ${selected_dsp}  Fetch From Left  ${selected_wcdma}[dist_name]  /WCDMA_
    ${dsp_cores}  Query Infomodel  get list ${selected_dsp}/CORE_L-*
    ${selected_core}  Evaluate  random.choice(${dsp_cores})  random
    ${node_id}  Set Variable  ${selected_core}[nodeId]
    ${node_id}  Convert To Hex  ${node_id}
    Log  NodeId which will be crashed is: ${node_id}  console=true
    Set Test Variable  ${DSP_NODE_ID}  ${node_id}


DSP Crash
    [Documentation]  This KW is created to crash selected DSP
    [Arguments]  ${node_id}

    Log  DSP of nodeID: ${node_id} is being crashed  console=true

    Connect To SMOD  192.168.255.129
    ssh.Execute  rioboot -c write -a 0x128FFFFF -f /tmp/data.dat 0x${node_id}


Collect Snapshots
    Log  \nCollecting Snapshots....  console=true
    Log  Collecting BTS Snapshot  console=true
    Admin Get Snapshot
    Log  Collecting IM Snapshot  console=true
    Admin Collect IM Snapshot
    Log  Snapshots Collected and can be found in ${BTS_FILES}  console=true


Admin Collect IM Snapshot
    ${timestamp}  Get Time
    ${timestamp}  Replace String Using Regexp  ${timestamp}  (${SPACE}|:|-)  _
    coam.Collect Im Snapshot  ${BTS_FILES}/${timestamp}_im_snapshot.zip


Step 6: Recovery Action
    Log  \nStep 6: Recovery action after WCDMA DSP crash.  console=true
    Change Parameter ActForce(Unit)AutoReset  false  actForceAutoReset
    Maintenance Window Cleanup
    Perform Site Reset


TC Setup
    Common Test Setup  tc_name=FM__RAT_reset_actForceAutoReset_true_degraded_cell


TC Teardown
    Run Keyword If Test Failed
    ...  Step 6: Recovery Action
    Common Test Teardown
