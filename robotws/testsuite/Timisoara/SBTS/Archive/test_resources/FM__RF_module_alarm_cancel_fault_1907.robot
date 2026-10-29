*** Settings ***
Resource    ../../common_resources/ca_FM_general.robot

*** Variables ***
${RMOD_SN}=          # [OPTIONAL] RF module serial number (for example F7160910586)
${FAULT_ID}=  1907   # [OPTIONAL] Fault to be provoked on RF module (at this moment only 1907 fault is supported)
${ANTL}=         1   # [OPTIONAL] Fault will be send on this Antenna line. (for example 1, 2, 3)

*** Keywords ***
TC__FM__RF_module_alarm_cancel_fault_1907
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-5524
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Sending FaultID to given antenna line and RMOD.
    ...  Then lock/unlock RMOD and verify alarms.
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 13.04.2017 - https://jira3.int.net.nokia.com/browse/TAT-5524 - Create TC
    ...  - 28.04.2017 - https://jira3.int.net.nokia.com/browse/TAT-6383 - Change TC name
    ...  - 30.05.2017 - https://jira3.int.net.nokia.com/browse/TAT-6586 - Enhancements
    ...  - 30.05.2017 - https://jira3.int.net.nokia.com/browse/TAT-6662 - Ignore 4003 alarm after block
    ...  - 14.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-9909 - [FM__RF_module_alarm_cancel_fault_1907] command send fault doesn't work
    ...  - 02.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15079 - Trigger fault 1907 on RMs connected with more than one optical link
    ...  - 18.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15307 - Allign all FM TCs with RobotFramework version 3.1.0
    ...  - 26.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-16635 - RMOD REF-* recollection added after radio unblock
    ...  - 22.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18854 - Modify Get SM Variant function name in FM test cases
    ...  - 13.04.2020 - https://jira3.int.net.nokia.com/browse/TAT-19372 - Cannot block RMOD or block takes more than 1 minute
    ...  - 19.06.2020 - https://jira3.int.net.nokia.com/browse/TAT-19746 - Move keywords to resource file
    ...  - 06.01.2021 - https://jira3.ext.net.nokia.com/browse/TAT-20402 - Cannot unblock RMOD AdminApiProcedure Rejected
    ...  - 05.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21132 - Remove import for ta_real_radio library
    ...  - 28.05.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21412 - TC fails due to multiple GetAlarms keyword imported
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 09.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22596 - RF module alarm cancel fault 1907 fails due to missing CONF_REF-1
    ...  - 22.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22845 - TC fails because cells state was read too early
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  *******************

    Set Tags    CA-FM    OWNER-laura.craciunel@nokia.com    AUTHOR-rafal.ozga@nokia.com    MAINTAINER-laura.craciunel@nokia.com
    ...    GROUP_IN_CHARGE-TIM_4_Vrf    PHASE-CRT    SW-SBTS17    SW-SBTS18    FEATURE-RP001534

    Step 0: TC specific preconditions
    Step 1: Send fault to RMOD
    Step 2: Verify alarms and cells states
    Step 3: Lock RMOD
    Step 4: Verify alarms after lock
    Step 5: Unlock RMOD
    Step 6: Verify states after unlock
    Step 7: Return actForce(Unit)AutoReset to initial value


Step 0: TC Specific Preconditions
    [Timeout]  20min
    Log  \nStep 0: TC Specific Preconditions  console=${TRUE}
    ${is_rmod_defined} =  Run Keyword And Return Status  Should Not Be Empty  ${RMOD_SN}
    ${TESTED_RMOD} =  Run Keyword If  ${is_rmod_defined}  Get Chosen RMOD Object  ELSE  Get Default RMOD Object
    Set Test Variable  ${TESTED_RMOD}
    Validate Fault Id  ${FAULT_ID}
    Validate Antenna Line  ${ANTL}
    Set Test Variable  ${RMOD_SN}  ${TESTED_RMOD.serialNumber}
    Log  RMOD SN is ${RMOD_SN}  console=ture
    Set Test Variable  ${RMOD_DN}  ${TESTED_RMOD.dist_name}
    Log  RMOD distName is: ${RMOD_DN}  console=true
    Set Test Variable  ${RMOD_IP}  ${TESTED_RMOD.ipAddress}
    Log  RMOD IP is: ${RMOD_IP}  console=true
    ${CELLS}=  Get Cells  ${RMOD_DN}
    Log  Cells on RMOD ANTL:\n ${CELLS}  console=${True}

    ${ACTIVE_TX_NUMBER}=  Check Working Cells Count
    Should Not Be Equal As Integers  ${ACTIVE_TX_NUMBER}  0  msg=No active TXs on RMOD

    Set Test Variable  ${CELLS}
    Set Test Variable  ${ACTIVE_TX_NUMBER}
    Set Test Variable  ${TESTED_RMOD}
    ${initial_value}=    Get actForce(Unit)AutoReset value from infomodel   actForceUnitAutoReset
    Set Test Variable  ${initial_value}
    Log  Value actForceUnitAutoReset is ${initial_value}  console=yes
    ${status}=   run keyword and return status   Change parameter actForce(Unit)AutoReset  false  actForceUnitAutoReset
    ${parameter_after_change}=   Get actForce(Unit)AutoReset value from infomodel   actForceUnitAutoReset
    Run Keyword if   ${status}
    ...   should be equal  ${parameter_after_change}   false

    ${rm}=  Query infomodel  get object //EQM_R-*//RMOD_R-* is [serialNumber="${RMOD_SN}"]
    Set Test Variable  ${RM}  ${rm.dist_name}
    Log  RMOD distName is : ${RM}

Validate Fault Id
    [Arguments]  ${fault_id}
    @{valid_faults_ids}=  Create List  1907  1910  1911
    List Should Contain Value  ${valid_faults_ids}  ${fault_id}  msg=This FaultId is not supported

Validate Antenna Line
    [Arguments]  ${antl}
    @{valid_antenna_lines}=  Create List  1  2  3  4  5  6
    List Should Contain Value  ${valid_antenna_lines}  ${antl}  msg=This antenna line is not supported


Get Default RMOD Object
    [Documentation]  This KW was created to randomly choose tested RM. 5.1 radio modules are filtered out as the is no testing method

    Log  SN is not provided tested RM will be randomly choosen  console=TRUE
    ${filteredRMODs}=  create list
    ${rmod_r} =  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmod_r}
        run keyword if  '${rmod.l3Protocol}' != 'CPRI_RP1'
        ...  append to list  ${filteredRMODs}  ${rmod}
    END

    ${lenght}=  get length  ${filteredRMODs}
    Log  There are ${lenght} suitable RMs. One of them will be randomly choosen  console=TRUE

    ${selectedPositionOfRMinArray}=  evaluate  random.randint(0,${lenght}-1)   random
    ${selectedRMOD}=  get from list  ${filteredRMODs}  ${selectedPositionOfRMinArray}

    Log  Selected RMOD: ${selectedRMOD.productName} with SN: ${selectedRMOD.serialNumber}  console=true

    Set Test Variable  ${TESTED_RMOD_SN}  ${selectedRMOD.serialNumber}

    ${rmod_r} =  Get Infomodel Object  //RMOD_R-* is [serialNumber=${selectedRMOD.serialNumber}]
    Set Test Variable  ${RMOD_R}  ${rmod_r}
    ${rmod_ref}=  Query Infomodel  get object ${RMOD_R.dist_name}/REF-*
    ${rmod}=  Query Infomodel  get object ${rmod_ref.distName}

    [Return]  ${rmod}

Get Chosen RMOD Object
    ${rmod_r} =  Get Infomodel Object  //RMOD_R-* is [serialNumber=${RMOD_SN}]
    Set Test Variable  ${RMOD_R}  ${rmod_r}
    ${rmod_ref}=  Query Infomodel  get object ${RMOD_R.dist_name}/REF-*
    ${rmod}=  Query Infomodel  get object ${rmod_ref.distName}
    [Return]  ${rmod}


Get Chosen Rmod Distname
    [Arguments]  ${rmod_serial_number}
    ${rmods_distnames}=  Infomodel Get All Radio Modules Distname
    ${rmods_serial_numbers}=  Get Radio Modules Serial Numbers  ${rmods_distnames}
    Validate Rmod Id  ${rmod_serial_number}  ${rmods_serial_numbers}
    ${selected_rmod_distname}=  Get From Dictionary  ${rmods_serial_numbers}  ${rmod_serial_number}
    [Return]  ${selected_rmod_distname}

Validate Rmod Id
    [Arguments]  ${rmod_serial_number}  ${rmods_serial_numbers}
    Dictionary Should Contain Key  ${rmods_serial_numbers}  ${rmod_serial_number}  msg=There is no RMOD with given Serial Number

Get Radio Modules Serial Numbers
    [Arguments]  ${rmods_distnames}
    ${rmods_serial_numbers}=  Create Dictionary
    FOR  ${rmod_single_distname}  IN  @{rmods_distnames}
      ${rmod_obj}=  Query Infomodel  get object ${rmod_single_distname}
      set to dictionary  ${rmods_serial_numbers}  ${rmod_obj['serialNumber']}=${rmod_single_distname}
    END
    [Return]  ${rmods_serial_numbers}

Get Chosen Rmod Ip
    [Arguments]  ${rmod_serial_number}
    ${rmod}=  Infomodel Get RMOD By Serial Number  ${rmod_serial_number}
    [Return]  ${rmod.ipAddress}

Get Cells
    [Arguments]  ${rmod_dn}
    ${cells}=  Infomodel Get Scf Cells Deployed On RMOD  ${rmod_dn}
    ${cells2}  Create List

    ${rmod_list}=  Query Infomodel  get list //RUNTIME_VIEW-*//RMOD_R-*
    FOR  ${rmod}  IN  @{rmod_list}
      ${rmod_a}=  Query Infomodel  get object ${rmod.configDN}
      run keyword if  "${rmod.serialNumber}" == "${RMOD_SN}"
      ...  Run keywords  Set Test Variable  ${rmod_a}  AND  exit for loop
    END

    FOR  ${cell}  IN  @{cells}
      Remove From Dictionary  ${cell}  distName  intShutdownTimeout
      ${re} =   Set Variable  regex"${rmod_a}/ANTL_A-${ANTL}"
      ${status}  ${txs} =  Run Keyword And Ignore Error
      ...  Query Infomodel  get list ${cell.dist_name}/CHANNELGROUP_A-*/CHANNEL_A-* is [direction=TX, antlDN=${re}]  timeout=30
      Continue For Loop If  '${status}' == 'FAIL'
      TX On Other Antenna Exists  ${rmod_a}  ${ANTL}
      ${tx_number}=  Get Cell TX Number  ${cell}  ${ANTL}
      Set To Dictionary  ${cell}  tx  ${txs}  tx_number  ${tx_number}
      Append To List  ${cells2}  ${cell}
    END
    [Return]  ${cells2}


Get Cell TX Number
    [Arguments]  ${cell}  ${antl}
    ${txs} =  Query Infomodel  get list ${cell.dist_name}/CHANNELGROUP_A-*/CHANNEL_A-* is [direction=TX]  timeout=30
    ${tx_number}  Get Length  ${txs}
    [Return]  ${tx_number}

TX On Other Antenna Exists
    [Arguments]  ${rmod}  ${antl}
    ${antl}  Convert To Integer  ${antl}
    ${re} =   Set Variable  regex"${rmod.distName}./*"
    ${txs} =  Query Infomodel  get list //CELLMAPPING_A-1//CHANNELGROUP_A-*/CHANNEL_A-* is [direction=TX, antlDN=${re}]  timeout=30
    FOR  ${tx}  IN  @{txs}
      ${antenna}  Set Variable  ${tx.antlDN[-1]}
      ${antenna}  Convert To Integer  ${antenna}
      ${antenna}  Run Keyword If  ${antenna} > 6  Evaluate  ${antenna} % 6
      ...   ELSE  Set Variable  ${antenna}
      Run Keyword If  ${antenna} != ${antl}  Run Keywords  Log  At least one TX on other antl exists  AND  Return From Keyword  ${TRUE}
    END
    Fail  There is no TX on other ANTL on this RMOD.

Check Working Cells Count
    ${im_module_object}=  query infomodel  get object ${TESTED_RMOD.masterAgentDN}
    ${tx_power}=  Get Tx Power  ${TESTED_RMOD.ipAddress}  ${im_module_object.ipAddress}  ${TESTED_RMOD.productName}
    ${tx_power_states}=  Get Dictionary Values  ${tx_power}
    ${not_working_cells_count}=  Count Values In List  ${tx_power_states}  OFF
    ${all_cells_count}=  Get Length   ${tx_power_states}
    ${working_cells_count}=  Evaluate  ${all_cells_count} - ${not_working_cells_count}
    [Return]  ${working_cells_count}

Step 1: Send fault to RMOD
    Log  \nStep 1: Check which SM variant will be used    console=yes
    ${SM_varian}=  Get SM Variant for RMOD  ${TESTED_RMOD}
    Set Test Variable  ${SM_varian}
    Log  RM is connected to: ${SM_varian}  console=TRUE
    Run Keyword If  '${SM_varian}'=='AirScale'   Run Keyword
    ...     Send Fault 1907 To Single TX on AirScale  ${RMOD_IP}  ${ANTL}
    Run Keyword If  '${SM_varian}'=='FSMr3'  Run Keyword
    ...     Send Fault 1907 To Single TX on Rel3  ${RMOD_IP}  ${ANTL}


Send Fault 1907 To Single TX on AirScale
    [Arguments]   ${rmod.ipAddress}  ${tx}
    Log   Sending Fault 1907 to tx ${tx} on ${rmod_ip} RMOD.  console=${TRUE}

    Get And Save SM position  ${TESTED_RMOD}

    ${smod} =  Query Infomodel  get object ${TESTED_RMOD.masterAgentDN}
    Connect to SMOD  ${smod.ipAddress}
    ssh.Execute  lxc-attach -n 0x${SMOD_position_integer}018 -- bash -c '{ echo "sendFault 1153 ${tx} 0 0 0 0"; sleep 1; } | telnet ${rmod_ip} 2323'

Get And Save SM position
    [Documentation]  KW returns SMOD Position in integer 1 or 2 for AriScale
    [Arguments]  ${rmod}

    ${smod}=  Query Infomodel  get object ${rmod.masterAgentDN}
    Log  Current SMOD to which tested radio module is connected has nodeId: ${smod.nodeIdOwn}  console=TRUE
    ${SMOD_position}=  run keyword and return status  Should Contain  '${smod.nodeIdOwn}'  4113

    ${SMOD_position_integer}=  Set Variable If
    ...     ${SMOD_position}==${TRUE}      1
    ...     ${SMOD_position}==${FALSE}     2
    Set Test variable  ${SMOD_position_integer}


Send Fault 1907 To Single TX on Rel3

    [Arguments]  ${rmod_ip}  ${tx}
    Log   Sending Fault 1907 to tx ${tx} on ${rmod_ip} RMOD.  console=${TRUE}

    ${smod} =  Query Infomodel  get object ${TESTED_RMOD.masterAgentDN}
    Connect to SMOD  ${smod.ipAddress}
    ssh.Execute  { echo "sendFault 1153 ${tx} 0 0 0 0"; sleep 1; } | telnet ${rmod_ip} 2323


Step 2: Verify alarms and cells states
    Log  \nStep 2: Verify alarms and cells states after fault sending  console=${TRUE}
    Sleep  60
    ${active_alarms}=  coam.Get Alarms
    ${collect_snapshot}=  Set Variable  ${FALSE}
    ${critical}=  Set Variable  ${FALSE}
    FOR  ${cell}  IN  @{CELLS}
      ${status}=  run keyword and return status  should contain  ${cell.dist_name}  LCELC
      run keyword if  ${status}
      ...  continue for loop
      ${cell.tx_number}  Convert To Integer  ${cell.tx_number}
      ${critical}  Set Variable If  ${cell.tx_number} == ${1}  ${TRUE}
    END

    ${runtime_rmod}=  Query Infomodel  get object /MRBTS-1/RAT-1//RMOD_R-* is [serialNumber=${RMOD_SN}]
    ${expected_alarm}=  Run Keyword If  ${critical}  Create Dictionary  faultId=1907  severity=Critical
    ...                           ELSE IF   ${critical}  Create Dictionary  faultId=1907  severity=Major
    ${ignored_alarms}=     Create Dictionary  faultId=4003
    ${expected}=   Create List  ${expected_alarm}
    ${ignored}=    Create List  ${ignored_alarms}
    ${status}=  Run Keyword And Return Status  Admin Check Active Alarms TAF  expected_patterns=${expected}  ignored_patterns=${ignored}
    Run Keyword If  '${status}' == 'False'  Fail  Expected alarm missing or unexpected alarm is visible
    ...         ELSE  Log  Expected alarm is visible [OK]  console=TRUE
    ${collect_snapshot}=  Set Variable If  '${status}' == 'False'  ${TRUE}
    FOR  ${cell}  IN  @{CELLS}
      ${runtime_cell}=  Get Cell Object  ${cell}
      ${status}=  run keyword and return status  should not contain  ${cell.dist_name}  LCELC
      ${check_states_status}=  Run Keyword If  ${cell.tx_number} == ${1}  Run Keyword And Ignore Error  Run Keywords
      ...  Should be equal    ${runtime_cell.stateInfo.operationalState}  Disabled  msg=Wrong operationalState in ${runtime_cell.dist_name}  AND
      ...  Should be equal    ${runtime_cell.stateInfo.availabilityStatus}  Failed  msg=Wrong availabilityStatus in ${runtime_cell.dist_name}
      ...  ELSE IF  ${cell.tx_number} > ${1}  Run Keyword And Ignore Error
      ...  Should be equal    ${runtime_cell.stateInfo.availabilityStatus}  Degraded  msg=Wrong operationalState in ${runtime_cell.dist_name}
      Run Keyword If  '${check_states_status[0]}' == 'PASS'  Log  \nCell ${runtime_cell.dist_name} reached proper states  console=${TRUE}
      ...       ELSE  Log  \nCell ${runtime_cell.dist_name} didn't reach proper states  level=WARN  console=${TRUE}
      ${collect_snapshot}=  Set Variable If  '${check_states_status[0]}' != 'PASS'  ${TRUE}
    END
    Run Keyword If  ${collect_snapshot}  Collect Snapshots

Get Cell Object
    [Arguments]  ${scf_cell}

    ${appropriateCells}=  Query Infomodel  get list /MRBTS-1/RAT-1/MCTRL-1/BBTOP_M-1//CELL_M-*/CONF_REF-* is [distName=${scf_cell.dist_name}]
    Sort List  ${appropriateCells}
    ${status}  ${value}  Run Keyword And Ignore Error  get from list  ${appropriateCells}  0
    ${cell_dn}  ${conf}  Run Keyword If  '${status}' == 'PASS'  Split Path  ${value.dist_name}
    ...       ELSE  FAIL  Cannot get runtime cell object for ${scf_cell} from Infomodel
    ${cell}  Query Infomodel  get object ${cell_dn}
    [Return]  ${cell}


Step 3: Lock RMOD
    Log  \nStep 3: RMOD lock  console=${True}
    ${block_status}=  Run Keyword And Return Status  Lock  ${RM}  timeout=300
    Run Keyword If  ${block_status}  Log  RMOD successfully locked [OK]  console=${TRUE}
    ...     ELSE
    ...     Fail  msg=Cannot lock RMOD or lock takes more than 5 minutes [NOK]

Step 4: Verify alarms after lock
    Log  \nStep 4: Verify alarms after lock  console=${TRUE}
    Sleep  60
    ${active_alarms}=  coam.Get Alarms
    ${expected_alarm}=  Create Dictionary  faultId=1907
    ${ignored_alarms}=     Create Dictionary  faultId=4003
    ${expected}=  Create List  ${expected_alarm}
    ${ignored}=  Create List  ${ignored_alarms}
    ${status}=  Run Keyword And Return Status  Admin Check Active Alarms TAF  expected_patterns=${expected}  ignored_patterns=${ignored}
    Run Keyword If  '${status}' == 'False'  Run Keywords
    ...  Set Test Failed  Expected alarms not present or unexpected faults raised  AND
    ...  Collect Snapshots

Step 5: Unlock RMOD
    Log  \nStep 5: RMOD unlock  console=${TRUE}
    ${unblock_status}=  Run Keyword And Return Status  Unlock  ${RM}  timeout=300
    Run Keyword If  ${unblock_status}  Log  RMOD successfully unlocked [OK]  console=${TRUE}
    ...       ELSE
    ...       Fail  Cannot unlock RMOD or unlock takes more than 5 minute [NOK]

Step 6: Verify states after unlock
    Log  Step 6: Verify states after unlock  console=${TRUE}
    Sleep  300
    Log  Verify alarms after unlock  console=${TRUE}
    ${active_alarms}=  coam.Get Alarms
    ${critical_alarm1}=  Create Dictionary  faultId=1907
    ${critical}=   Create List  ${critical_alarm1}
    ${status}=  Run Keyword And Return Status  Admin Check Active Alarms TAF  critical_patterns=${critical}
    Run Keyword If  '${status}' == 'False'  Set Test Failed  FaultId 1907 is still after RMOD lock operation
    ${rmod_ref}=  Query Infomodel  get object ${rmod_r.dist_name}/REF-*
    ${TESTED_RMOD}=  Query Infomodel  get object ${rmod_ref.distName}
    Log  Checking working cells count  console=${TRUE}
    ${active_tx}=  Check Working Cells Count
    Run Keyword If  ${ACTIVE_TX_NUMBER} != ${active_tx}
    ...  Fail  Number of active txs: ${active_tx} dont match active tx before test: ${ACTIVE_TX_NUMBER}
    ...  ELSE  Log  Number of active TX is ok.  console=${TRUE}

Step 7: Return actForce(Unit)AutoReset to initial value

    ${im_bts_id}=   Admin Get BTS ID
    ${bts_dist_name}=    set variable  MRBTS-${im_bts_id}/MNL-1/MNLENT-1/FMCADM-1

    Run Keyword If  '${initial_value}'=='true'   Run Keywords
    ...  coam.Perform Parameter Recommissioning  ${bts_dist_name}
    ...                                          actForceUnitAutoReset
    ...                                          update
    ...                                          true
    ...                                          skip_parameter_relation_errors=True
    ...                                          should_activate=True
    ...  AND
    ...  Log  actForceUnitAutoReset will be changed to initial value (TRUE)   console=yes

Collect snapshots
    Log  \nCollecting Snapshots....  console=${True}
    Log  Collecting BTS Snapshot  console=${True}
    Admin get snapshot
    Log  Collecting IM Snapshot  console=${True}
    Admin collect IM snapshot
    Log  Snapshots Collected and can be found in ${BTSFiles}  console=${True}

Admin Collect IM Snapshot
    ${timestamp} =  Get Time
    ${timestamp} =  Replace String Using Regexp  ${timestamp}  (${SPACE}|:|-)  _
    coam.collect_im_snapshot    ${BTS Files}/${timestamp}_im_snapshot.zip


TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown


