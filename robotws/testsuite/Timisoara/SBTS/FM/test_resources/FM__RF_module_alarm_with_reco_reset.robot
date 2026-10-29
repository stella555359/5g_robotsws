*** Settings ***
Documentation
    ...   *NOTE*
    ...  TC does not support RM 5.1 due to lack of implementation for sending fault
    ...  Purpose of TC is verification of radio module reset as recovery action.
    ...  Recovery action should be triggered after generating fault with id: 1900
    ...  !!! Test case supports only single radio module cell configurations (e.g. configuration A, B) !!!
    ...  !!! Support for other configurations will be added after delivery CNI-30603 and CNI-31530     !!!

Library  DateTime
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RMOD_SERIAL_NUMBER}  ${EMPTY}  # [OPTIONAL] RF module serial number (for example F7160910586)
${CARRIERS_RESTORE_TIMEOUT}  180  # [OPTIONAL]  Tiemout for carriers restore in seconds, set to 180 seconds by default
${ACTIVE_CARRIERS_BEFORE}  0
${ACTIVE_CARRIERS_AFTER}  0


*** Keywords ***
TC__FM__RF_module_alarm_with_reco_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-4064
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 18.11.2016 - https://jira3.int.net.nokia.com/browse/TAT-4064 - Initial creation
    ...  - 26.01.2017 - https://jira3.int.net.nokia.com/browse/TAT-5377 - fixed log level and instructions after AND
    ...  - 02.02.2017 - https://jira3.int.net.nokia.com/browse/TAT-5432 - added proper flowchart link
    ...  - 07.02.2017 - https://jira3.int.net.nokia.com/browse/TAT-5488 - Raw Alarm History Config moved to hran_frame_sbts
    ...  - 05.04.2017 - https://jira3.int.net.nokia.com/browse/TAT-6085 - Cells Verification Step2 and Step3 Added
    ...  - 24.04.2017 - https://jira3.int.net.nokia.com/browse/TAT-6078 - General TC refactor
    ...  - 02.05.2017 - https://jira3.int.net.nokia.com/browse/TAT-6412 - Get Active Carriers Keyword returns None bug fixed
    ...  - 12.06.2017 - https://jira3.int.net.nokia.com/browse/TAT-6705 - Check additional rmod statuses after reset
    ...  - 23.08.2017 - https://jira3.int.net.nokia.com/browse/TAT-7346 - Replace deprecated keywords from ute-admin
    ...  - 19.09.2017 - https://jira3.int.net.nokia.com/browse/TAT-7677 - Cell reco timeout extended. Await alarm 7101
    ...  - 04.10.2017 - https://jira3.int.net.nokia.com/browse/TAT-7797 - Added support for rel 4
    ...  - 07.11.2017 - https://jira3.int.net.nokia.com/browse/TAT-7677 - Carrier reco timeout extended +1 minute
    ...  - 23.01.2018 - https://jira3.int.net.nokia.com/browse/TAT-7677 - Carrier reco timeout moved to variables section
    ...  - 08.03.2018 - https://jira3.int.net.nokia.com/browse/TAT-9212 - Support 2xFSMF
    ...  - 22.03.2018 - https://jira3.int.net.nokia.com/browse/TAT-9466 - increase timeout for getting alarm 7101 from 30 to 90 seconds
    ...  - 26.03.2018 - https://jira3.int.net.nokia.com/browse/TAT-9509 - increase timeout for rmod ping restor in step3 from 60s to 120s
    ...  - 16.04.2018 - https://jira3.int.net.nokia.com/browse/TAT-9435 - Change supported faults
    ...  - 27.04.2018 - https://jira3.int.net.nokia.com/browse/TAT-9945 - Send fault to whole unit, remove support for sending fault on every tx
    ...  - 06.06.2108 - https://jira3.int.net.nokia.com/browse/TAT-10331 -
    ...  - 21.09.2018 - https://jira3.int.net.nokia.com/browse/TAT-12291 - Enable snapshot collection
    ...  - 09.10.2018 - https://jira3.int.net.nokia.com/browse/TAT-12377 - Compare count of active TXs
    ...  - 04.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-15614 - Add support for RMs connected with more than one optical link
    ...  - 09.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-16492 - Solution to avoid mandatory parameters;removed faults other than 1900
    ...  - 29.08.2019 - https://jira3.int.net.nokia.com/browse/TAT-17278 - CPRI_ALU RF units filtered out from testing RF selection
    ...  - 17.12.2019 - https://jira3.int.net.nokia.com/browse/TAT-18561 - remove test restriction in case TxPower is within tolerance
    ...  - 22.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18228 - Ping Rmod kw change for FM__RF_module_alarm_with_reco_reset
    ...  - 04.02.2020 - https://jira3.int.net.nokia.com/browse/TAT-18561 - add carrier verification per RAT by reading from IM
    ...  - 06.02.2020 - https://jira3.int.net.nokia.com/browse/TAT-18971 - Check RAT availability before reading cell info from IM
    ...  - 16.07.2020 - https://jira3.int.net.nokia.com/browse/TAT-19891 - Remove duplicate rm_cells_list for FM__RF_module_alarm_with_reco_reset
    ...  - 05.04.2020 - https://jira3.ext.net.nokia.com/browse/TAT-21132 - Remove import for ta_real_radio library
    ...  - 25.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22105 - CARRIERS_RESTORE_TIMEOUT variable not used in TC
    ...  - 02.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 16.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26671 - Fix connection to secondary core
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 09.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27313 - Fix variable type
    ...  *******************

    Set Tags  OWNER-laura.craciunel@nokia.com  AUTHOR-milosz.nowak@nokia.com  MAINTAINER-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  CA-FM
    ...  PHASE-CIT  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001534

    Step 0: Suite Specific Preconditions
    Step 1: Provoke Rmod Reset By Generating Fault On Chosen Unit
    Step 2: Verification Of Cell And Radio Statuses During Recovery Action
    Step 3: Verification Of Cell States After Recovery Action
    Step 4: Verification Of Cell Carriers Setup
    Step 5: RawAlarmHistory Verification  ${FAULT_1900_RADIO_AUTO_RST}[fault_id]


Step 0: Suite Specific Preconditions
    [Tags]  Helper

    Log  Step 0: Suite Specific Preconditions  console=true
    ${is_rmod_defined}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${RMOD_SERIAL_NUMBER}
    ${tested_rmod}  Run Keyword If  ${is_rmod_defined}
    ...  Get Chosen RMOD Object
    ...  ELSE
    ...  Get Default RMOD Object
    ${all_rmo_ds_power_before_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMO_DS_POWER_BEFORE_RESET}
    ${all_rmo_ds_power_aftere_reset}  Create Dictionary
    Set Test Variable  ${ALL_RMO_DS_POWER_AFTERE_RESET}

    ${status_gsm}  Run Keyword And Return Status
    ...  Should Not Be Equal  '${SCF_COUNT_GSM}'  '0'
    ${gsm_crr}  Run Keyword If  ${status_gsm}
    ...  Gsm Active Carriers
    ${gsm_crr}  Set Variable If  '${gsm_crr}' == 'None'  0  ${gsm_crr}

    ${status_lte}  Run Keyword And Return Status
    ...  Should Not Be Equal  '${SCF_COUNT_LTE}'  '0'
    ${lte_crr}  Run Keyword If  ${status_lte}
    ...  Lte Active Carriers
    ${lte_crr}  Set Variable If  '${lte_crr}' == 'None'  0  ${lte_crr}

    ${status_wcdma}  Run Keyword And Return Status
    ...  Should Not Be Equal  '${SCF_COUNT_WCDMA}'  '0'
    ${3g_crr}  Run Keyword If  ${status_wcdma}
    ...  Wcdma Active Carriers
    ${3g_crr}  Set Variable If  '${3g_crr}' == 'None'  0  ${3g_crr}

    ${nbr_carriers_before}  Evaluate  ${gsm_crr} + ${3g_crr} + ${lte_crr}
    Set Test Variable  ${NBR_CARRIERS_BEFORE}
    Log  Total number of active carriers as in IM is ${NBR_CARRIERS_BEFORE}

    # ${allRMODsLTEPowerAfterLinkBreak}  create list
    # set test variable  ${allRMODsLTEPowerAfterLinkBreak}
    Set Test Variable  ${TESTED_RMOD}
    Set Test Variable  ${RMOD_DISTNAME}  ${TESTED_RMOD.dist_name}
    Log  RMOD distName is: ${RMOD_DISTNAME}  console=true
    Set Test Variable  ${RMOD_IP}  ${TESTED_RMOD.ipAddress}
    Log  RMOD IP is: ${RMOD_IP}  console=true
    ${smod}  Query Infomodel  get object ${TESTED_RMOD.masterAgentDN}
    ${rmod_cells}  Infomodel Get Cells Deployed On RMOD  ${TESTED_RMOD}
    Set Test Variable  ${SMOD_IP}  ${smod.ipAddress}
    Set Test Variable  ${RMOD_CELLS}
    Set Test Variable  ${RMOD_TYPE}  ${TESTED_RMOD.productName}
    # ${CARRIERS_ON_START}  Get Active Carriers  ${TESTED_RMOD}
    # Should Not Be Empty  ${CARRIERS_ON_START}  msg=No active carriers found
    # Set Test Variable  ${CARRIERS_ON_START}
    Set Test Variable  ${SN}  ${TESTED_RMOD.serialNumber}
    Log  RMOD serial number is: ${SN}  console=true

    Get All Tx Power From All RMs  ${ALL_RMO_DS_POWER_BEFORE_RESET}

    ${connection}  Run Keyword If  ("192.168.255.7" or "192.168.255.119") in "${smod.ipAddress}"
    ...  Set Variable  fct-4a
    ...  ELSE IF  "FSMF" in "${smod.productName}"
    ...  Set Variable  fct
    ...  ELSE
    ...  Set Variable  ${smod.ipAddress}
    Connect Sendfault Diagnostic  radio_ip=${RMOD_IP}  module_ip=${connection}
    ${current_date_time}  Get current date  result_format=%Y-%b-%d %H:%M:%S
    Set Test Variable  ${CURRENT_DATE_TIME}


Get Default RMOD Object
    [Documentation]  This KW was created to randomly choose tested RM. 5.1 radio modules are filtered out as the is no testing method

    Log  SN is not provided tested RM will be randomly choosen  console=TRUE
    ${filtered_rmo_ds}  Create List
    ${rmod_r}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{rmod_r}
        ${status_rmod}  Run Keyword And Return Status
        ...  Should Not Contain  ${rmod.l3Protocol}  CPRI
        Run Keyword If  ${status_rmod}
        ...  Append To List  ${filtered_rmo_ds}  ${rmod}
    END

    ${lenght}  Get Length  ${filtered_rmo_ds}
    Log  There are ${lenght} suitable RMs. One of them will be randomly choosen  console=TRUE

    ${selected_position_of_r_min_array}  Evaluate  random.randint(0,${lenght}-1)  random
    ${selected_rmod}  Get From List  ${filtered_rmo_ds}  ${selected_position_of_r_min_array}

    Log  Selected RMOD: ${selected_rmod.productName} with SN: ${selected_rmod.serialNumber}  console=true

    Set Test Variable  ${RMOD_SERIAL_NUMBER}  ${selected_rmod.serialNumber}

    ${rmod_r}  Get Infomodel Object  //RMOD_R-* is [serialNumber=${selected_rmod.serialNumber}]
    ${rmod_ref}  Query Infomodel  get object ${rmod_r.dist_name}/REF-*
    ${rmod}  Query Infomodel  get object ${rmod_ref.distName}

    [Return]  ${rmod}


Get Chosen RMOD Object
    ${rmod_r}  Get Infomodel Object  //RMOD_R-* is [serialNumber=${RMOD_SERIAL_NUMBER}]
    ${rmod_ref}  Query Infomodel  get object ${rmod_r.dist_name}/REF-*
    ${rmod}  Query Infomodel  get object ${rmod_ref.distName}

    [Return]  ${rmod}


Step 1: Provoke Rmod Reset By Generating Fault On Chosen Unit
    [Tags]  Step

    Log  \nStep 1: Provoke rmod reset by generating fault on chosen unit  console=true
    Send Fault 1122  ${RMOD_IP}
    Log  Wait for alarms visible  console=true
    ${fault_1900_params}  Get String With Alarm Parameters  ${FAULT_1900_RADIO_AUTO_RST}
    Assert Alarm Active  parameters=${fault_1900_params}  timeout=180s
    RMOD Recovery Reset Should Start  60


Send Fault 1122
    [Tags]  Trigger
    [Arguments]  ${rmod_ip}

    ${date_start}  Get Current Date
    Log  sending fault 1122 to radio module unit with ip address ${rmod_ip} time: ${date_start}  console=true
    Run Keyword And Ignore Error
    ...  Send Fault With Timeout  1122


Send Fault With Timeout
    [Arguments]  ${send_fault_id}
    [Timeout]  15s

    hran_radio.Send Fault  ${send_fault_id}  0


RMOD Recovery Reset Should Start
    [Tags]  Assert
    [Arguments]  ${timeout}

    Log  Wait for target to be not reachable ${RMOD_IP}, timeout: ${timeout} sec  console=true
    Wait Until Keyword Succeeds  ${timeout} sec  5s
    ...  Ping Rmod  ${SN}  expected_rc=1
    Log  Recovery reset has started.  console=true


Make Command For AirScale
    [Arguments]  ${command}  ${smod_r}

    Return From Keyword  lxc-attach -n 0x${smod_r.horizontalPosition}018 -- ${command}

    [Return]  ${command}


Ping Rmod
    [Arguments]  ${sn}  ${expected_rc}=0

    ${rmod}  _Get Rmod Object By Serial Number  ${sn}
    ${smod_l}  Query Infomodel  get object ${rmod.masterAgentDN}
    ${smod_r}  Query Infomodel  get object //CABINET_R-*/SMOD_R-* is [serialNumber=${smod_l.serialNumber}]
    Wait Until Keyword Succeeds  90s  10s
    ...  Should Be True  '${rmod.ipAddress}' != '0.0.0.0'
    ${is_airscale}  Run Keyword And Return Status
    ...  Should Contain  ${smod_r.productName}  AirScale
    ${command}  Run Keyword If  ${is_airscale}
    ...  Make Command For AirScale  ping -c1 ${rmod.ipAddress}  ${smod_r}
    ...  ELSE
    ...  Set Variable  ping -c1 ${rmod.ipAddress}
    Connect To SMOD  ${smod_l.ipAddress}
    ssh.Execute  ${command}
    ssh.Assert Exit Status  ${expected_rc}


Make Command
    [Arguments]  ${command}  ${smod}

    ${smod}  Query Infomodel  get object //CABINET_R-*/SMOD_R-* is [serialNumber=${smod.serialNumber}]
    Return From Keyword If  '${SMOD1['HW_TYPE']}'=='ASIA'  lxc-attach -n 0x${smod.horizontalPosition}018 -- ${command}

    [Return]  ${command}


Step 2: Verification Of Cell And Radio Statuses During Recovery Action
    [Tags]  Step

    Log  \nStep 2: Verification of cell and radio statuses during recovery action  console=true
    ${banned}  Create Dictionary  operationalState=Enabled  availabilityStatus=Online  proceduralState=OnAirDone
    ${all}  Get Parameters For All  RMOD
    ${current}  Evaluate  next((rmod for rmod in ${all} if (u'serialNumber', '${RMOD_SERIAL_NUMBER}') in rmod.items()))
    RMOD Should Not Take Banned Statuses  ${current}  ${banned}
    FOR  ${cell}  IN  @{RMOD_CELLS}
        ${has_operational_trx}  Infomodel Cell Has At Least One Operational RXTX Pair  ${cell}
        Run Keyword If  ${has_operational_trx}
        ...  Infomodel Cell Should Be Degraded  ${cell}
        ...  ELSE
        ...  Infomodel Cell Should Be Disabled  ${cell}
    END


RMOD Should Not Take Banned Statuses
    [Arguments]  ${current}  ${banned}

    FOR  ${status}  IN  @{banned.items()}
        ${contain}  Run Keyword And Return Status
        ...  Dictionary Should Contain Item  ${current}  @{status}
        Run Keyword If  ${contain}
        ...  Set Test Failed  RMOD has taken banned status: ${status}
    END


Step 3: Verification Of Cell States After Recovery Action
    [Tags]  Step

    Log  \nStep 3: Verification of cell states after recovery action  console=true
    RMOD Recovery Reset Should End  180
    Sleep  120s  msg=Wait for cells recovery.
    FOR  ${cell}  IN  @{RMOD_CELLS}
        Infomodel Cell Should Be Online  ${cell}
    END


RMOD Recovery Reset Should End
    [Tags]  Assert
    [Arguments]  ${timeout}

    Wait Until Keyword Succeeds  ${timeout} sec  5s
    ...  Ping Rmod  ${SN}
    Log  Recovery reset has stopped.  console=true


Step 4: Verification Of Cell Carriers Setup
    [Tags]  Step

    Log  \nStep 4: Verification of cell carriers setup  console=true

    Log  Wait for carriers restore. Timeout=${CARRIERS_RESTORE_TIMEOUT}.  console=true
    Sleep  ${CARRIERS_RESTORE_TIMEOUT}s

    ${status_gsm}  Run Keyword And Return Status
    ...  Should Not Be Equal  '${SCF_COUNT_GSM}'  '0'
    ${gsm_crr}  Run Keyword If  ${status_gsm}
    ...  Gsm Active Carriers
    ${gsm_crr}  Set Variable If  '${gsm_crr}' == 'None'  0  ${gsm_crr}

    ${status_lte}  Run Keyword And Return Status
    ...  Should Not Be Equal  '${SCF_COUNT_LTE}'  '0'
    ${lte_crr}  Run Keyword If  ${status_lte}
    ...  Lte Active Carriers
    ${lte_crr}  Set Variable If  '${lte_crr}' == 'None'  0  ${lte_crr}

    ${status_wcdma}  Run Keyword And Return Status
    ...  Should Not Be Equal  '${SCF_COUNT_WCDMA}'  '0'
    ${3g_crr}  Run Keyword If  ${status_wcdma}
    ...  Wcdma Active Carriers
    ${3g_crr}  Set Variable If  '${3g_crr}' == 'None'  0  ${3g_crr}

    ${nbr_carriers_after}  Evaluate  ${gsm_crr} + ${3g_crr} + ${lte_crr}
    Set Test Variable  ${NBR_CARRIERS_AFTER}
    Log  Total number of active carriers as in IM is ${NBR_CARRIERS_AFTER}

    Get All Tx Power From All RMs  ${ALL_RMO_DS_POWER_AFTERE_RESET}

    ${dictionarykeys}  Get Dictionary Keys  ${ALL_RMO_DS_POWER_AFTERE_RESET}

    FOR  ${element}  IN  @{dictionarykeys}
        Log  ${element}  console=true
        ${first_list}  Create List
        ${second_list}  Create List

        ${first_list2}  Create List
        ${first_list3}  Create List
        ${second_list2}  Create List
        ${second_list3}  Create List

        ${first_list}  Get From Dictionary  ${ALL_RMO_DS_POWER_BEFORE_RESET}  ${element}
        ${first_list2}  Filter_out_OFF_Carriers  ${first_list}
        ${first_list3}  Filter_out_negative_Carriers  ${first_list2}

        ${second_list}  Get From Dictionary  ${ALL_RMO_DS_POWER_AFTERE_RESET}  ${element}
        ${second_list2}  Filter_out_OFF_Carriers  ${second_list}
        ${second_list3}  Filter_out_negative_Carriers  ${second_list2}

        ${as_required}  Compare Tx Power  ${first_list}  ${second_list}  10.0
        ${first_list_lenght}  Get Length  ${first_list3}
        ${second_list_lenght}  Get Length  ${second_list3}

        ${active_carriers_before}  Evaluate  ${ACTIVE_CARRIERS_BEFORE}+${first_list_lenght}
        ${active_carriers_after}  Evaluate  ${ACTIVE_CARRIERS_AFTER}+${second_list_lenght}

        Run Keyword If  ${first_list_lenght} > ${second_list_lenght}
        ...  Log  This RMod ${element}, lost carriers. At precheck it had ${first_list_lenght} but now only ${second_list_lenght}  console=true
        Run Keyword If  ${first_list_lenght} < ${second_list_lenght}
        ...  Log  This RMod ${element}, gained carriers. At precheck it had ${first_list_lenght} but now has ${second_list_lenght}  console=true
        Run Keyword If  ${first_list_lenght} == ${second_list_lenght}
        ...  Log  This RMod ${element}, has same amount of ${second_list_lenght} active carriers.  console=true

        ${length_status}  Run Keyword And Return Status
        ...  Should Be Equal As Numbers  ${first_list_lenght}  ${second_list_lenght}
        Run Keyword If  ${as_required}
        ...  Log  TxPowers are not different with given dBm tolerance [OK]  console=true
        ...  ELSE
        ...  Log  TxPowers are different with given dBm tolerance [NOK]
        Run Keyword If  ${length_status}
        ...  Log  Amount of TXs is the same [OK]  console=true
        ...  ELSE
        ...  Log  Amount of TxPowers are different, investigation should be started [NOK]
    END

    Log  \n Total number of active Carriers before test is ${active_carriers_before} .  console=true
    Log  \n Total number of active Carriers after test is ${active_carriers_after} .  console=true

    Run Keyword If  ${NBR_CARRIERS_BEFORE} == ${NBR_CARRIERS_AFTER}
    ...  Log  Total number of active carriers (from IM) remains the same [OK]  console=true
    ...  ELSE
    ...  Fail  msg=Total number of active carriers changed, before were ${NBR_CARRIERS_BEFORE}, now there are ${NBR_CARRIERS_AFTER}.


Filter_out_OFF_Carriers
    [Arguments]  @{first_list}

    FOR  ${x}  IN  @{first_list}
        Log  ${x}
    END
    ${filtered_list}  Create List
    ${dicktionarykeys}  Get Dictionary Keys  ${x}

    FOR  ${element}  IN  @{dicktionarykeys}
        ${carrier_power}  Get From Dictionary  ${x}  ${element}
        ${status_carrier}  Run Keyword And Return Status
        ...  Should Not Contain  ${carrier_power}  OFF
        Run Keyword If  ${status_carrier}
        ...  Append To List  ${filtered_list}  ${carrier_power}
    END

    [Return]  ${filtered_list}


Filter_out_negative_Carriers
    [Arguments]  ${first_list}

    ${filtered_list}  Create List

    FOR  ${element}  IN  @{first_list}
        # ${status_Carrier}  run keyword and return status  ${carrier_power}  OFF
        Run Keyword If  ${element} > 1
        ...  Append To List  ${filtered_list}  ${element}
    END
    [Return]  ${filtered_list}


_Start Validation
    [Arguments]  ${rmod}

    ${date_start}  Get Current Date
    Log  Check carriers started ${date_start}  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${CARRIERS_RESTORE_TIMEOUT}s  30s
    ...  Check Carriers  ${rmod}
    ${date_end}  Get Current Date
    Log  End check carriers ${date_end}, status: ${status}  console=true
    Run Keyword If  ${status} == ${FALSE}
    ...  Set Test Failed  Carriers not restored within timeout: ${CARRIERS_RESTORE_TIMEOUT}


Check Carriers
    [Arguments]  ${rmod}

    ${carriers}  Get Active Carriers  ${rmod}
    Carriers Should Be Restored  ${CARRIERS_ON_START}  ${carriers}


Get Active Carriers
    [Tags]  Helper
    [Arguments]  ${rmod}

    ${im_module_object}  Query Infomodel  get object ${rmod.masterAgentDN}
    ${carriers}  Get Tx Power  ${rmod.ipAddress}  ${im_module_object.ipAddress}  ${rmod.productName}
    FOR  ${carrier}  IN  @{carriers.keys()}
        Run Keyword If  '${carriers['${carrier}']}'=='OFF'
        ...  Remove From Dictionary  ${carriers}  ${carrier}
    END

    [Return]  ${carriers}


Carriers Should Be Restored
    [Tags]  Assert
    [Arguments]  ${carriers_before}  ${carriers_after}

    ${restored}  Evaluate  len(${carriers_before.keys()})==len(${carriers_after.keys()})
    Run Keyword If  ${restored}==False
    ...  Log  Compared carriers lists don't match.
    Run Keyword If  ${restored} == ${FALSE}
    ...  Fail  Carriers not restored


Step 5: RawAlarmHistory Verification
    [Tags]  Step
    [Arguments]  ${fault_id}

    Log  \nStep 5: RawAlarmHistory Verification  console=true
    ${fault_id}  Convert To String  ${fault_id}
    ${alarm_in_inactives}  Run Keyword And Return Status
    ...  Verify Alarm In RawAlarmHistory File  ${fault_id}  ${CURRENT_DATE_TIME}  ${None}  inactive
    ${alarm_in_actives}  Run Keyword And Return Status
    ...  Verify Alarm In RawAlarmHistory File  ${fault_id}  ${CURRENT_DATE_TIME}
    Run Keyword If  ${alarm_in_inactives}
    ...  Log  Fault reported in RawAlarmHistory  console=true
    ...  ELSE IF  ${alarm_in_actives}
    ...  Set Test Restriction  Fault not cancelled in RawAlarmHistory
    ...  ELSE
    ...  Set Test Failed  Fault not reported in RawAlarmHistory


TC Setup
    Common Test Setup  tc_name=FM__RF_module_alarm_with_reco_reset


TC Teardown
    Common Test Teardown
