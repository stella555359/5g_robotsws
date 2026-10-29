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


*** Keywords ***
TC__FM__RAT_reset_actForceAutoReset_false_degraded_cell
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-16944
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 30.03.2020 - https://jira3.int.net.nokia.com/browse/TAT-16944 - Create TC
    ...  - 19.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19746 - Move keywords to resource file
    ...  - 05.04.2020 - https://jira3.ext.net.nokia.com/browse/TAT-21132 - Remove import for ta_real_radio library
    ...  - 24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 09.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22596 - RF module alarm cancel fault 1907 fails due to missing CONF_REF-1
    ...  - 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24051 - Optimization of KW usage for FM
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 12.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25140 - Test fail since test does not wait enough for fault to occur
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27704 - Add option to skip RMOD power check
    ...  - 29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  - 08.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29531 - Test fails when connecting to SMOD ip
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-bogdan.boldurean@nokia.com  MAINTAINER-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS20  FEATURE-RP001534

    Step 0: TC Specific Preconditions
    Step 1: Send Fault To RMOD
    Step 2: Verify Alarms And Cells States
    Step 3: Trigged WCDMA DSP Crash
    Step 4: Recovery Action


Step 0: TC Specific Preconditions
    [Timeout]  20min

    Log  \nStep 0: TC Specific Preconditions  console=true
    ${is_rmod_defined}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${RMOD_SN}
    ${tested_rmod}  Run Keyword If  ${is_rmod_defined}
    ...  Get Chosen RMOD Object
    ...  ELSE
    ...  Get Default RMOD Object
    Set Test Variable  ${TESTED_RMOD}
    Validate Fault Id  ${FAULT_ID}
    Validate Antenna Line  ${ANTL}
    Set Test Variable  ${RMOD_SN}  ${TESTED_RMOD.serialNumber}
    Log  RMOD SN is ${RMOD_SN}  console=ture
    Set Test Variable  ${RMOD_DN}  ${TESTED_RMOD.dist_name}
    Log  RMOD distName is: ${RMOD_DN}  console=true
    Set Test Variable  ${RMOD_IP}  ${TESTED_RMOD.ipAddress}
    Log  RMOD IP is: ${RMOD_IP}  console=true
    ${cells}  Get Cells  ${RMOD_DN}
    Log  Cells on RMOD ANTL:\n ${cells}  console=true

    ${active_tx_number}  Check Working Cells Count
    Should Not Be Equal As Integers  ${active_tx_number}  0  msg=No active TXs on RMOD

    Set Test Variable  ${CELLS}
    Set Test Variable  ${ACTIVE_TX_NUMBER}
    Set Test Variable  ${TESTED_RMOD}
    ${initial_value}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    Set Test Variable  ${INITIAL_VALUE}
    Log  Value actForceAutoReset is ${INITIAL_VALUE}  console=true
    ${status}  Run Keyword And Return Status
    ...  Change Parameter ActForce(Unit)AutoReset  false  actForceAutoReset
    ${parameter_after_change}  Get ActForce(Unit)AutoReset Value From Infomodel  actForceAutoReset
    Run Keyword If  ${status}
    ...  Should Be Equal  ${parameter_after_change}  false
    create data.Dat And Put 0xffff

    ${fault_parameters}  Catenate  SEPARATOR=${SPACE}  faultId=regex"6707|6708|6709",  alarmId=7116,  alarmName="BASE STATION SERVICE PROBLEM"
    Set Test Variable  ${FAULT_PARAMETERS}


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

    Log  SN is not provided tested RM will be randomly choosen  console=TRUE
    ${filtered_rmo_ds}  Create List
    ${rmod_r}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmod_r}
        Run Keyword If  '${rmod.l3Protocol}' != 'CPRI_RP1'
        ...  Append To List  ${filtered_rmo_ds}  ${rmod}
    END

    ${lenght}  Get Length  ${filtered_rmo_ds}
    Log  There are ${lenght} suitable RMs. One of them will be randomly choosen  console=TRUE

    ${selected_position_of_r_min_array}  Evaluate  random.randint(0,${lenght}-1)  random
    ${selected_rmod}  Get From List  ${filtered_rmo_ds}  ${selected_position_of_r_min_array}

    Log  Selected RMOD: ${selected_rmod.productName} with SN: ${selected_rmod.serialNumber}  console=true

    Set Test Variable  ${TESTED_RMOD_SN}  ${selected_rmod.serialNumber}

    ${rmod_r}  Get Infomodel Object  //RMOD_R-* is [serialNumber=${selected_rmod.serialNumber}]
    Set Test Variable  ${RMOD_R}  ${rmod_r}
    ${rmod_ref}  Query Infomodel  get object ${RMOD_R.dist_name}/REF-*
    ${rmod}  Query Infomodel  get object ${rmod_ref.distName}

    [Return]  ${rmod}


Get Chosen RMOD Object
    ${rmod_r}  Get Infomodel Object  //RMOD_R-* is [serialNumber=${RMOD_SN}]
    Set Test Variable  ${RMOD_R}  ${rmod_r}
    ${rmod_ref}  Query Infomodel  get object ${RMOD_R.dist_name}/REF-*
    ${rmod}  Query Infomodel  get object ${rmod_ref.distName}

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
    [Arguments]  ${rmod_dn}

    ${cells}  Infomodel Get Scf Cells Deployed On RMOD  ${rmod_dn}
    ${cells2}  Create List

    ${rmod_list}  Query Infomodel  get list //RUNTIME_VIEW-*//RMOD_R-*
    FOR  ${rmod}  IN  @{rmod_list}
        ${rmod_a}  Query Infomodel  get object ${rmod.configDN}
        Run Keyword If  "${rmod.serialNumber}" == "${RMOD_SN}"
        ...  Run Keywords
        ...  Set Test Variable  ${rmod_a}
        ...  AND
        ...  Exit For Loop
    END

    FOR  ${cell}  IN  @{cells}
        Remove From Dictionary  ${cell}  distName  intShutdownTimeout
        ${re}  Set Variable  regex"${rmod_a}/ANTL_A-${ANTL}"
        ${status}  ${txs}  Run Keyword And Ignore Error
        ...  Query Infomodel  get list ${cell.dist_name}/CHANNELGROUP_A-*/CHANNEL_A-* is [direction=RX, antlDN=${re}]  timeout=30
        Continue For Loop If  '${status}' == 'FAIL'
        TX On Other Antenna Exists  ${rmod_a}  ${ANTL}
        ${tx_number}  Get Cell TX Number  ${cell}
        Set To Dictionary  ${cell}  tx  ${txs}  tx_number  ${tx_number}
        Append To List  ${cells2}  ${cell}
    END

    [Return]  ${cells2}


Get Cell TX Number
    [Arguments]  ${cell}

    ${txs}  Query Infomodel  get list ${cell.dist_name}/CHANNELGROUP_A-*/CHANNEL_A-* is [direction=RX]  timeout=30
    ${tx_number}  Get Length  ${txs}

    [Return]  ${tx_number}


TX On Other Antenna Exists
    [Arguments]  ${rmod}  ${antl}

    ${antl}  Convert To Integer  ${antl}
    ${re}  Set Variable  regex"${rmod.distName}./*"
    ${txs}  Query Infomodel  get list //CELLMAPPING_A-1//CHANNELGROUP_A-*/CHANNEL_A-* is [direction=RX, antlDN=${re}]  timeout=30
    FOR  ${tx}  IN  @{txs}
        ${antenna}  Set Variable  ${tx.antlDN[-1]}
        ${antenna}  Convert To Integer  ${antenna}
        ${antenna}  Run Keyword If  ${antenna} > 6
        ...  Evaluate  ${antenna} % 6
        ...  ELSE
        ...  Set Variable  ${antenna}
        Run Keyword If  ${antenna} != ${antl}
        ...  Run Keywords
        ...  Log  At least one TX on other antl exists
        ...  AND
        ...  Return From Keyword  ${TRUE}
    END
    Fail  There is no TX on other ANTL on this RMOD.


Check Working Cells Count
    ${im_module_object}  Query Infomodel  get object ${TESTED_RMOD.masterAgentDN}
    ${tx_power}  Get Tx Power  ${TESTED_RMOD.ipAddress}  ${im_module_object.ipAddress}  ${TESTED_RMOD.productName}
    ${tx_power_states}  Get Dictionary Values  ${tx_power}
    ${not_working_cells_count}  Count Values In List  ${tx_power_states}  OFF
    ${all_cells_count}  Get Length  ${tx_power_states}
    ${working_cells_count}  Evaluate  ${all_cells_count} - ${not_working_cells_count}

    [Return]  ${working_cells_count}


Step 1: Send Fault To RMOD
    Log  \n Check which SM variant will be used  console=true
    ${sm_varian}  Get SM Variant For RMOD  ${TESTED_RMOD}
    Set Test Variable  ${SM_VARIAN}
    Log  RM is connected to: ${SM_VARIAN}  console=TRUE
    Run Keyword If  '${SM_VARIAN}'=='AirScale'
    ...  Run Keyword
    ...  Send Fault 1907 To Single RX On AirScale  ${ANTL}
    Run Keyword If  '${SM_VARIAN}'=='FSMr3'
    ...  Run Keyword
    ...  Send Fault 1907 To Single RX On Rel3  ${RMOD_IP}  ${ANTL}


Send Fault 1907 To Single RX On AirScale
    [Arguments]  ${rx}

    Log  Sending Fault 1907 to rx ${rx} on ${RMOD_IP} RMOD.  console=true

    Get And Save SM Position  ${TESTED_RMOD}

    ${smod}  Query Infomodel  get object ${TESTED_RMOD.masterAgentDN}
    Connect To SMOD  ${smod.ipAddress}
    ssh.Execute  lxc-attach -n 0x${SMOD_POSITION_INTEGER}018 -- bash -c '{ echo "sendFault 1130 ${rx} 0 0 0 0"; sleep 1; } | telnet ${RMOD_IP} 2323'


Get And Save SM Position
    [Documentation]  KW returns SMOD Position in integer 1 or 2 for AriScale
    [Arguments]  ${rmod}

    ${smod}  Query Infomodel  get object ${rmod.masterAgentDN}
    Log  Current SMOD to which tested radio module is connected has nodeId: ${smod.nodeIdOwn}  console=TRUE
    ${smod_position}  Run Keyword And Return Status
    ...  Should Contain  '${smod.nodeIdOwn}'  4113

    ${smod_position_integer}  Set Variable If  ${smod_position}==${TRUE}  1  ${smod_position}==${FALSE}  2
    Set Test Variable  ${SMOD_POSITION_INTEGER}


Send Fault 1907 To Single RX On Rel3
    [Arguments]  ${rmod_ip}  ${rx}

    Log  Sending Fault 1907 to rx ${rx} on ${rmod_ip} RMOD.  console=true

    ${smod}  Query Infomodel  get object ${TESTED_RMOD.masterAgentDN}
    Connect To SMOD  ${smod.ipAddress}
    ${send_fault}  ssh.Execute  { echo "sendFault 1130 ${rx} 0 0 0 0"; sleep 1; } | telnet ${rmod_ip} 2323

    [Return]  ${send_fault}


Step 2: Verify Alarms And Cells States
    Log  \nVerify alarms and cells states after fault sending  console=true
    Sleep  60
    ${active_alarms}  coam.Get Active Alarms
    ${collect_snapshot}  Set Variable  ${FALSE}
    ${critical}  Set Variable  ${FALSE}
    FOR  ${cell}  IN  @{CELLS}
        ${status}  Run Keyword And Return Status
        ...  Should Contain  ${cell.dist_name}  LCELC
        Run Keyword If  ${status}
        ...  Continue For Loop
        ${cell.tx_number}  Convert To Integer  ${cell.tx_number}
        ${critical}  Set Variable If  ${cell.tx_number} == ${1}  ${TRUE}
    END

    ${runtime_rmod}  Query Infomodel  get object /MRBTS-1/RAT-1//RMOD_R-* is [serialNumber=${RMOD_SN}]
    ${expected_alarm}  Run Keyword If  ${critical}
    ...  Create Dictionary  faultId=1907  severity=Critical
    ...  ELSE IF  ${critical}
    ...  Create Dictionary  faultId=1907  severity=Major
    ${ignored_alarms}  Create Dictionary  faultId=4003
    ${expected}  Create List  ${expected_alarm}
    ${ignored}  Create List  ${ignored_alarms}
    ${status}  Run Keyword And Return Status
    ...  Admin Check Active Alarms TAF  expected_patterns=${expected}  ignored_patterns=${ignored}
    Run Keyword If  '${status}' == 'FAIL'
    ...  Log  Expected alarm missing or unexpected alarm is visible  level=ERROR
    ...  ELSE
    ...  Log  Expected alarm is visible [OK]  console=TRUE
    ${collect_snapshot}  Set Variable If  '${status}' == 'FAIL'  ${TRUE}


Get Cell Object
    [Arguments]  ${scf_cell}

    ${appropriate_cells}  Query Infomodel  get list /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1//CELL_M-*/CONF_REF-* is [distName=${scf_cell.dist_name}]
    Sort List  ${appropriate_cells}
    ${status}  ${value}  Run Keyword And Ignore Error
    ...  Get From List  ${appropriate_cells}  0
    ${cell_dn}  ${conf}  Run Keyword If  '${status}' == 'PASS'
    ...  Split Path  ${value.dist_name}
    ...  ELSE
    ...  FAIL  Cannot get runtime cell object for ${scf_cell} from Infomodel
    ${cell}  Query Infomodel  get object ${cell_dn}

    [Return]  ${cell}


Step 3: Trigged WCDMA DSP Crash
    [Documentation]  In this step WCDMA DSP crash will be performed.

    Log  \nStep2: Trigger WCDMA DSP crash.  console=true

    ${all_rmods_power_before_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}
    ${all_rmods_power_after_reco_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMODS_POWER_AFTER_RECO_RESET}

    Get All Tx Power From All RMs  ${ALL_RMODS_POWER_BEFORE_RECO_RESET}

    Check Links Status  Available

    Choose DSP For Crash Test

    Log  DSPs stateInfo will be checked under specified pattern:  console=true
    ${dsp}  Query Infomodel  get list //DSP_L-1
    Verify Parameters  ${dsp}  .stateInfo  operationalState=Enabled  availabilityStatus=Online  proceduralState=RoutingLoaded

    Setup Admin  bts_host=192.168.255.129  bts_port=443  use_ssl=True  alias=cellsCheck

    ${fault_status}  Run Keyword In Background  Assert Alarm Active  parameters=${FAULT_PARAMETERS}  timeout=${ALARM_TIMEOUT}

    ${cells_status}  Run Keyword In Background  Assert Every  class_name=WNCEL  parameters=operationalState=${DISABLED}  timeout=660
    ...  alias=cellsCheck

    DSP Crash  ${NODE_ID}

    ${recovery_reset}  Run Keyword And Return Status
    ...  Query Infomodel  get list //RECOVERY_RESET_IND-*  timeout=240

    ${status_fault}  Run Keyword And Return Status
    ...  Collect Keyword Result  ${fault_status}  timeout=${ALARM_TIMEOUT}

    ${status_cells}  Run Keyword And Return Status
    ...  Collect Keyword Result  ${cells_status}  timeout=660
    Log  cell status ${status_cells}

    Run Keyword If  ${status_fault}
    ...  Log  Fault 6707|6708|6709 with alarm "7116 BASE STATION SERVICE PROBLEM" occured [OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Fault 6707/6708/6709 with alarm "7116 BASE STATION SERVICE PROBLEM didn't occur [NOK]

    Run Keyword If  ${status_cells}
    ...  Set Test Restriction  WCDMA cells were failed while fault 6707/6708/6790 occured [NOK]
    ...  ELSE
    ...  Log  WCDMA cells were not failed while fault 6707/6708/6790 occured [OK]

    ${alarm7116_recovery_status}  Run Keyword And Return Status
    ...  Assert Alarm Inactive  ${FAULT_PARAMETERS}
    Run Keyword If  ${alarm7116_recovery_status}
    ...  Log  Alarm "7116" is visible after recovery action [OK]  console=TRUE
    ...  ELSE
    ...  Log  Alarm "7116 RAT autonomous reset as recovery action" is visible after recovery action [NOK]  console=TRUE

    ${hist_alarms}  Get Historic Alarms
    Log  ${hist_alarms}  console=true
    FOR  ${alarm}  IN  @{hist_alarms}
        Run Keyword If  '${alarm.alarmDetail}' == 'RAT autonomous reset as recovery action'
        ...  Fail  msg=RAT autonomous reset as recovery action found in history alarms
    END


Choose DSP For Crash Test
    [Documentation]  This KW is created to draw a desired DSP which will be crashed during TC

    ${sm_varian}  Get SM Variant For RMOD  ${TESTED_RMOD}
    Set Test Variable  ${SM_VARIAN}
    Log  RM is connected to: ${SM_VARIAN}  console=TRUE
    Run Keyword If  '${SM_VARIAN}'=='AirScale'
    ...  Set Test Variable  ${CORES}  8
    Run Keyword If  '${SM_VARIAN}'=='FSMr3'
    ...  Set Test Variable  ${CORES}  6

    ${selected_core}  Evaluate  random.randint(1,${CORES})  random
    Log  Selected core which was choosen after draw: ${selected_core}  console=true
    ${wcdma_ds_ps}  Get List Of NodeID For Given Technology  WCDMA
    Log  List of all WCDMA DSPs: \n ${wcdma_ds_ps}  console=true
    ${list_lengt}  Get Length  ${wcdma_ds_ps}
    ${selected_position_of_ds_pin_array}  Evaluate  random.randint(1,${list_lengt}-1)  random
    ${selected_dsp}  Get From List  ${wcdma_ds_ps}  ${selected_position_of_ds_pin_array}
    Log  Selected DSP: \n ${selected_dsp}  console=true
    Set Test Variable  ${SELECTED_DSP}

    ${key}  Get Dictionary Keys  ${SELECTED_DSP}
    ${node_id}  Evaluate  ${SELECTED_DSP["${key[0]}"]}+${selected_core}
    Log  NodeId which will be crashed is: ${node_id}  console=true
    Set Test Variable  ${NODE_ID}


Get List Of NodeID For Given Technology
    [Documentation]
    ...  This KW is created to collect DSP info for choosen technology inline with nodeId
    ...  *AUTHOR* bogdan.boldurean@nokia.com
    [Arguments]  ${rat}

    ${dsp_list}  Create List

    ${dsp_l_list}  Query Infomodel  get list //DSP_L-1/SOFTWARE_ENTITY-* is [rat="${rat}"]
    FOR  ${entity}  IN  @{dsp_l_list}
        ${dsp_dict}  Create Dictionary
        ${dsp_object}  Query Infomodel  get object ${entity.deviceDN}
        ${node_id}  Convert To Hex  ${dsp_object.nodeId}
        ${reg_exp}  Run Keyword And Return Status
        ...  Should Match Regexp  ${node_id}  12..
        Run Keyword If  ${reg_exp}
        ...  Run Keywords
        ...  Set To Dictionary  ${dsp_dict}  ${entity.deviceDN}  ${node_id}
        ...  AND
        ...  Append To List  ${dsp_list}  ${dsp_dict}
    END

    [Return]  ${dsp_list}


DSP Crash
    [Documentation]  This KW is created to crash selected DSP
    [Arguments]  ${node_id}

    Log  DSP of nodeID: ${node_id} is being crashed  console=true

    Connect To SMOD  ${OAM_BTS_IP}
    ssh.Execute  rioboot -c write -a 0x128FFFFF -f /tmp/data.dat 0x${node_id}


Return ActForceAutoReset To Default Value
    Log  \nactForceAutoReset will be changed to default value (false)  console=true

    ${im_bts_id}  Admin Get BTS ID
    ${bts_dist_name}  Set Variable  MRBTS-${im_bts_id}/MNL-1/MNLENT-1/FMCADM-1

    coam.Perform Parameter Recommissioning  ${bts_dist_name}  actForceAutoReset  update  false  skip_parameter_relation_errors=True
    ...  should_activate=True


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


Step 4: Recovery Action
    [Documentation]  In this st ep recovery action will be performed

    Log  \nStep 4: Recovery action after WCDMA DSP crash.  console=true
    Return ActForceAutoReset To Default Value
    Perform Site Reset


TC Setup
    Common Test Setup


TC Teardown
    Run Keywords
    ...  Return ActForceAutoReset To Default Value
    ...  AND
    ...  Common Test Teardown
