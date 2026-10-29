*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${RMOD_SN}          # [OPTIONAL] RF module serial number (for example F7160910586)
${FAULT_ID}  1907   # [OPTIONAL] Fault to be provoked on RF module (at this moment only 1907 fault is supported)
${RMOD_FAULT_ID}  1900
${ANTL}  1           # [OPTIONAL] Fault will be send on this Antenna line. (for example 1, 2, 3)


*** Keywords ***
TC__WebEM__RF_successful_start_up_notification_in_Web_Element_Manager
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21411
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case is created to check that only RMOD and RMOD subunit alarms can be seen on the page reached by clicking the alarm bell
    ...  on the BTS Startup-View page.
    ...  Verify the state of all configured and unconfigured RMODs and print their state.
    ...  Send fault 1900 to the chosen RMOD.
    ...  Check that only RMOD and RMOD subunit related alarms are seen after clicking the alarm bell icon in BTS Startup-View.
    ...  Trigger site reset and wait for site to recover.
    ...  Send fault 1907 on the chosend antenna line.
    ...  Check that only RMOD and RMOD subunit related alarms are seen after clicking the alarm bell icon in BTS Startup-View.
    ...  Trigger site reset and wait for site to recover.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 21.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21411 - Initial TAT creation
    ...  - 26.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22106 - Fix for RMOD error
    ...  - 20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22067 - Adapt WebEM TCs for CNI-61110
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24315 - Wrong catenate for some elements
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  - 19.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24331 - Replace hran_ssh with taf.transport.ssh
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring

    Set Tags    CA-WebEM    OWNER-nicolae-marcel.caragel@nokia.com    AUTHOR-victor.banicioiu@nokia.com
    ...    MAINTAINER-victor.banicioiu@nokia.com   GROUP_IN_CHARGE-TIM_3_Vrf    PHASE-CRT    SW-SBTS21B

    Step 0: TC specific preconditions
    Step 1: Provoke rmod reset by generating fault on chosen unit
    Step 2: Check only radio alarms are listed on active alarms page
    Step 3: Execute site reset
    Step 4: Check SBTS is recovered
    Step 5: Send fault 1907 to RMOD
    Step 6: Check only radio alarms are listed on active alarms page
    Step 7: Execute site reset
    Step 8: Check SBTS is recovered


Step 0: TC Specific Preconditions
    [Timeout]  20min
    Log  \nStep 0: TC Specific Preconditions  console=${TRUE}
    ${is_rmod_defined}  Run Keyword And Return Status  Should Not Be Empty  ${RMOD_SN}
    ${TESTED_RMOD}  Run Keyword If  ${is_rmod_defined}  Get Chosen RMOD Object  ELSE  Get Default RMOD Object
    Set Test Variable  ${TESTED_RMOD}
    Validate Fault Id  ${FAULT_ID}
    Validate Antenna Line  ${ANTL}
    Set Test Variable  ${RMOD_SN}  ${TESTED_RMOD.serialNumber}
    Log  RMOD SN is ${RMOD_SN}  console=ture
    Set Test Variable  ${RMOD_DN}  ${TESTED_RMOD.dist_name}
    Log  RMOD distName is: ${RMOD_DN}  console=true
    Set Test Variable  ${RMOD_IP}  ${TESTED_RMOD.ipAddress}
    Log  RMOD IP is: ${RMOD_IP}  console=true
    ${smod}  Query Infomodel  get object ${TESTED_RMOD.masterAgentDN}
    Set Test Variable  ${SMOD_IP}  ${smod.ipAddress}
    Log  SMOD IP is: ${SMOD_IP}  console=true
    ${ACTIVE_TX_NUMBER}  Check Working Cells Count
    Should Not Be Equal As Integers  ${ACTIVE_TX_NUMBER}  0  msg=No active TXs on RMOD
    Set Test Variable  ${ACTIVE_TX_NUMBER}
    Set Test Variable  ${TESTED_RMOD}
    ${initial_value}  Get actForce(Unit)AutoReset value  actForceUnitAutoReset
    Set Test Variable  ${initial_value}
    Log  Value actForceUnitAutoReset is ${initial_value}  console=true

Step 1: Provoke rmod reset by generating fault on chosen unit
    [Tags]  Step
    Log  \nStep 1: Provoke rmod reset by generating fault on chosen unit  console=true
    Send Fault  ${RMOD_FAULT_ID}  ${RMOD_IP}

Step ${id}: Check only radio alarms are listed on active alarms page
	Log  Step ${id}: Check only radio alarms are listed on active alarms page    console=true
	Go To StartUp View
    FOR  ${index}  IN RANGE  7  ${configuredRMOD_nr} + ${unconfiguredRMOD_nr} + 7
        ${text}  Catenate  SEPARATOR=  xpath=/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[2]
        ...  /div/ui-body/div/div[3]/div/div[2]/div[${index}]/label/span[2]
        Wait Until Element Is Visible  ${text}  timeout=120  error=RMOD name tag is not visible
        ${name}  Catenate  SEPARATOR=  xpath=/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[2]/div/
        ...  ui-body/div/div[3]/div/div[2]/div[${index}]/label/span[2]
        ${RMOD_name}  Get Text  ${name}
        ${name}  Fetch From Right  ${RMOD_name}  /
        ${name}  Remove String  ${name}  )
        ${alarm}  Catenate  SEPARATOR=  xpath=/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div
        ...  /div[2]/div/ui-body/div/div[3]/div/div[2]/div[${index}]/span/alarm-bell-icon
        ${RMOD_state}  run keyword and return status  wait until keyword succeeds  10  1  Element Should Be Visible  ${alarm}
        Run Keyword If  ${RMOD_state}  Append To List  ${failed_RMODs}  ${name}
        Run Keyword If  ${RMOD_state}  Click Element  ${alarm}
        Exit For Loop If  ${RMOD_state}
    END
	${element}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/div/div
	...  /div/div[1]/div/alarms-display/ui-table/div/ng-transclude/table/tbody/tr
	${alarm_nr}  Selenium2Library.Get Element Count  ${element}
    FOR	 ${index}  IN RANGE  1  ${alarm_nr}+1
        ${command_text}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/div/div/div/
        ...  div[1]/div/alarms-display/ui-table/div/ng-transclude/table/tbody/tr[${index}]/td[7]
        ${alarm_text}  Get Text  ${command_text}
        ${command_id}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/ng-view/wf-panel/wf-panel-section/div/div/div/div/div/div[1]
        ...  /div/alarms-display/ui-table/div/ng-transclude/table/tbody/tr[${index}]/td[3]
        ${alarm_id}  Get Text  ${command_id}
        ${only_RMOD_alarms}  run keyword and return status  Should Contain Any  ${alarm_text}  @{failed_RMODs}
        ...  msg=This error is not on any faulty RMOD detected    values=true
        Run Keyword Unless  ${only_RMOD_alarms}  Log  Alarm ${alarm_id} is not reported on any of the RMODs or their subunits  level=ERROR
        ...  console=true
    END
    Run Keyword If  ${alarm_nr}==0  Set Test Failed  Test failed because expected alarm was not raised or caught
	Click Element  xpath=//*[@id="main-view"]/div/div[1]/app-header/div[2]/shortcuts-menu/ul/li[1]/nav-link/a/i
	Run Keyword Unless  ${only_RMOD_alarms}  Set Test Failed  Test failed due to a number of errors that are not RMOD specific that appeared

Step ${id}: Execute site reset
    Log  Step ${id}: Execute site reset  console=true
    Reset site

Step ${id}: Check SBTS is recovered
    Log  Step ${id}: Check SBTS is recovered  console=true
    ${status}  run keyword and return status  Wait Until Keyword Succeeds  600  10  Check All Cells  ${OnAirDone_}  ${Enabled_}  ${Active_}
    Run Keyword Unless  ${status}  set test failed
    Click Button  xpath=/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button/button

Step 5: Send fault 1907 to RMOD
    Log  Step 5: Send fault 1907 to RMOD    console=true
    ${SM_varian}  Get SM Variant for connected RMOD  ${TESTED_RMOD}
    Set Test Variable  ${SM_varian}
    Log  RM is connected to: ${SM_varian}  console=TRUE
    Run Keyword If  '${SM_varian}'=='AirScale'   Run Keyword
    ...  Send Fault 1907 To Single TX on AirScale  ${RMOD_IP}  ${ANTL}
    Run Keyword If  '${SM_varian}'=='FSMr3'  Run Keyword
    ...  Send Fault 1907 To Single TX on Rel3  ${RMOD_IP}  ${ANTL}

Get actForce(Unit)AutoReset value
    [Documentation]
    ...  This KW is created to check what value has parameter actForceUnitAutoReset or actForceAutoReset.
    [Arguments]   ${im_parameter}
    ${parametr_name}  Convert To String  ${im_parameter}
    ${parameter_object}  query infomodel  get object /MRBTS-1/RAT-1//MNL_A-1/MNLENT_A-1/FMCADM_A-1
    ${parameter_object_value_string}  Convert To String  ${parameter_object.${parametr_name}}
    ${parameter_object_lower}  Convert To Lowercase  ${parameter_object_value_string}
    [Return]  ${parameter_object_lower}
    ${rm}  Query infomodel  get object //EQM_R-*//RMOD_R-* is [serialNumber="${RMOD_SN}"]
    Set Test Variable  ${RM}  ${rm.dist_name}
    Log  RMOD distName is : ${RM}
    Connect Sendfault Diagnostic  radio_ip=${RMOD_IP}  module_ip=${SMOD_IP}
    Check the status of configured RMODs
    Check the status of unconfigured RMODs

Check the status of configured RMODs
    Log  Check the status of configured RMODs  console=true
	${failed_RMODs}  Create List
	Set Suite Variable  ${failed_RMODs}  ${failed_RMODs}
	Go To StartUp View
	${configuredRMOD}  Get Text
	...  xpath=/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[2]/div/ui-body/div/div[3]/div/div[2]/div[3]/span
	${configuredRMOD_nr}  Convert To Integer  ${configuredRMOD}
	Set Suite Variable  ${configuredRMOD_nr}  ${configuredRMOD_nr}
    FOR  ${index}  IN RANGE  7  ${configuredRMOD_nr}+7
        ${name}  Catenate  SEPARATOR=  xpath=/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[2]/
        ...  div/ui-body/div/div[3]/div/div[2]/div[${index}]/label/span[2]
        ${RMOD_name}  Get Text  ${name}
        ${alarm}  Catenate  SEPARATOR=  xpath=/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[2]/div/ui-body
        ...  /div/div[3]/div/div[2]/div[${index}]/span/alarm-bell-icon
        ${RMOD_state}  Selenium2Library.Get Element Count  ${alarm}
        Run Keyword If  ${RMOD_state}==1  Log  ${RMOD_name} is UNSUCCESSFUL  console=true
        ...  ELSE  Log  ${RMOD_name} is SUCCESSFUL  console=true
        Run Keyword If  ${RMOD_state}==1  Append To List  ${failed_RMODs}  ${RMOD_name}
    END

Check the status of unconfigured RMODs
	Log  Check the status of unconfigured RMODs  console=true
	${unconfiguredRMOD}  Get Text
	...  xpath=/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[2]/div/ui-body/div/div[3]/div/div[2]/div[5]/span
	${unconfiguredRMOD_nr}  Convert To Integer  ${unconfiguredRMOD}
	Set Suite Variable  ${unconfiguredRMOD_nr}  ${unconfiguredRMOD_nr}
    FOR  ${index}  IN RANGE  ${configuredRMOD_nr}+6  ${configuredRMOD_nr}+${unconfiguredRMOD_nr}+7
        ${name}  Catenate  SEPARATOR=  xpath=/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[2]
        ...  /div/ui-body/div/div[3]/div/div[2]/div[${index}]/label/span[2]
        ${RMOD_name}  Get Text  ${name}
        ${state}  Catenate  SEPARATOR=  xpath=/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[2]/div/ui-body
        ...  /div/div[3]/div/div[2]/div[${index}]/span/alarm-bell-icon
        ${RMOD_state}  Selenium2Library.Get Element Count  ${state}
        Run Keyword If  ${RMOD_state}==1  Log  ${RMOD_name} is UNSUCCESSFUL  console=true
        ...  ELSE  Log  ${RMOD_name} is SUCCESSFUL  console=true
        Run Keyword If  ${RMOD_state}==1  Append To List  ${failed_RMODs}  ${RMOD_name}
    END
	Click Button  xpath=/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button/button

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
    ${filteredRMODs}  create list
    ${rmod_r}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmod_r}
        run keyword if  '${rmod.l3Protocol}' != 'CPRI_RP1'
        ...  append to list  ${filteredRMODs}  ${rmod}
    END
    ${lenght}  get length  ${filteredRMODs}
    Log  There are ${lenght} suitable RMs. One of them will be randomly choosen  console=TRUE
    ${selectedPositionOfRMinArray}  evaluate  random.randint(0,${lenght}-1)   random
    ${selectedRMOD}  get from list  ${filteredRMODs}  ${selectedPositionOfRMinArray}
    Log  Selected RMOD: ${selectedRMOD.productName} with SN: ${selectedRMOD.serialNumber}  console=true
    Set Test Variable  ${TESTED_RMOD_SN}  ${selectedRMOD.serialNumber}
    ${rmod_r}  Get Infomodel Object  //RMOD_R-* is [serialNumber=${selectedRMOD.serialNumber}]
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
      set to dictionary  ${rmods_serial_numbers}  ${rmod_obj['serialNumber']}=${rmod_single_distname}
    END
    [Return]  ${rmods_serial_numbers}

Get Chosen Rmod Ip
    [Arguments]  ${rmod_serial_number}
    ${rmod}  Infomodel Get RMOD By Serial Number  ${rmod_serial_number}
    [Return]  ${rmod.ipAddress}

Get Cell TX Number
    [Arguments]  ${cell}  ${antl}
    ${txs}  Query Infomodel  get list ${cell.dist_name}/CHANNELGROUP_A-*/CHANNEL_A-* is [direction=TX]  timeout=30
    ${tx_number}  Get Length  ${txs}
    [Return]  ${tx_number}

TX On Other Antenna Exists
    [Arguments]  ${rmod}  ${antl}
    ${antl}  Convert To Integer  ${antl}
    ${re}  Set Variable  regex"${rmod.distName}./*"
    ${txs}  Query Infomodel  get list //CELLMAPPING_A-1//CHANNELGROUP_A-*/CHANNEL_A-* is [direction=TX, antlDN=${re}]  timeout=30
    FOR  ${tx}  IN  @{txs}
      ${antenna}  Set Variable  ${tx.antlDN[-1]}
      ${antenna}  Convert To Integer  ${antenna}
      ${antenna}  Run Keyword If  ${antenna} > 6  Evaluate  ${antenna} % 6
      ...   ELSE  Set Variable  ${antenna}
      Run Keyword If  ${antenna} != ${antl}  Run Keywords  Log  At least one TX on other antl exists  AND  Return From Keyword  ${TRUE}
    END
    Fail  There is no TX on other ANTL on this RMOD.

Check Working Cells Count
    ${im_module_object}  query infomodel  get object ${TESTED_RMOD.masterAgentDN}
    ${tx_power}  Get Tx Power  ${TESTED_RMOD.ipAddress}  ${im_module_object.ipAddress}  ${TESTED_RMOD.productName}
    ${tx_power_states}  Get Dictionary Values  ${tx_power}
    ${not_working_cells_count}  Count Values In List  ${tx_power_states}  OFF
    ${all_cells_count}  Get Length  ${tx_power_states}
    ${working_cells_count}  Evaluate  ${all_cells_count} - ${not_working_cells_count}
    [Return]  ${working_cells_count}

Send Fault
    [Tags]  Trigger
    [Arguments]  ${fault_id}  ${rmod_ip}
    ${send_faults}  Create Dictionary  1900=1122
    ${send_fault_id}  Get From Dictionary  ${send_faults}  ${fault_id}
    ${date_start}  Get Current Date
    Log  sending fault ${send_fault_id} to radio module unit with ip address ${rmod_ip} time: ${date_start}  console=true
    Run Keyword And Ignore Error  Send fault with timeout  ${send_fault_id}

Send fault with timeout
    [Timeout]  15s
    [Arguments]  ${send_fault_id}
    hran_radio.Send fault  ${send_fault_id}  0

Go To StartUp View
    Wait Until Element Is Visible  xpath=//*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[1]/div/nav-menu-link/span  timeout=180
    ...  error=Site View menu button was not clickable
	Click Element  xpath=//*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[1]/div/nav-menu-link/span
	Click Element  xpath=//*[@id="main-view"]/div/div[1]/app-header/main-menu/nav-item[1]/div/ng-transclude/div/div[1]/nav-link/a

Get SM Variant for connected RMOD
    [Documentation]  KW returns variant of tested SM
    ...     Possible returns:
    ...     'AirScale'
    ...     'FSMr3'
    [Arguments]  ${rmod}
    ${smod}  Query Infomodel  get object ${rmod.masterAgentDN}
    ${is_FSMF}  run keyword and return status  Should Contain  ${smod.productName}  FSMF
    Return From Keyword If  ${is_FSMF}  FSMr3
    ${is_AirScale}  Run Keyword And Return Status  Should Contain  ${smod.productName}  AirScale
    Return From Keyword If   ${is_AirScale}   AirScale

Send Fault 1907 To Single TX on AirScale
    [Arguments]   ${rmod.ipAddress}  ${tx}
    Log   Sending Fault 1907 to tx ${tx} on ${rmod_ip} RMOD.  console=${TRUE}
    Get And Save SM position  ${TESTED_RMOD}
    ${smod}  Query Infomodel  get object ${TESTED_RMOD.masterAgentDN}
    Connect to SMOD  ${smod.ipAddress}
    ssh.Execute
    ...  lxc-attach -n 0x${SMOD_position_integer}018 -- bash -c '{ echo "sendFault 1153 ${tx} 0 0 0 0"; sleep 1; } | telnet ${rmod_ip} 2323'

Get And Save SM position
    [Documentation]  KW returns SMOD Position in integer 1 or 2 for AriScale
    [Arguments]  ${rmod}
    ${smod}  Query Infomodel  get object ${rmod.masterAgentDN}
    Log  Current SMOD to which tested radio module is connected has nodeId: ${smod.nodeIdOwn}  console=TRUE
    ${SMOD_position}  run keyword and return status  Should Contain  '${smod.nodeIdOwn}'  4113
    ${SMOD_position_integer}=  Set Variable If
    ...  ${SMOD_position}==${TRUE}  1
    ...  ${SMOD_position}==${FALSE}  2
    Set Test variable  ${SMOD_position_integer}

Send Fault 1907 To Single TX on Rel3
    [Arguments]  ${rmod_ip}  ${tx}
    Log   Sending Fault 1907 to tx ${tx} on ${rmod_ip} RMOD.  console=${TRUE}
    ${smod}  Query Infomodel  get object ${TESTED_RMOD.masterAgentDN}
    Connect to SMOD  ${smod.ipAddress}
    ssh.Execute  { echo "sendFault 1153 ${tx} 0 0 0 0"; sleep 1; } | telnet ${rmod_ip} 2323


TC Setup
    Common test setup  tc_name=WebEM__RF_successful_start_up_notification
    WebEM Setup

TC Teardown
    WebEM Teardown
    Common test teardown
