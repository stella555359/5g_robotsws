*** Settings ***
Documentation
    ...  Step 1: Power off radio module and check whether expected alarms appear.
    ...  Step 2: Power on radio module and check whether is reacheable and cells' statuses are properly updated
    ...  Starting release 26R1 test will also verify feature CB012530-SR-A in case of eCPRI radio modules.
    ...  CB012530-SR-A scope is to enrich Fault 10 with Supplementary alarm information tab,
    ...  and to inform operator about the possible failure reasons of an eCPRI radio unit.

Library  SSHLibrary
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RMOD_SN}  ${EMPTY}  # [Optional] Radio module serial number to be disconnected.
${ALARM_TIMEOUT}  600  # [in seconds] Timeout for alarm to appear in WebEM.
${NETACT_TIMEOUT}  240  # [in seconds] Timeout for alarm to appear in Netact.
${PING_RMOD_TIMEOUT}  300  # [in seconds] Timeout to restore ping to radio module.
${RMOD_INSERT_TIMEOUT}  300  # [in seconds] Timeout for radio module to become online.
${CELLS_ONLINE_TIMEOUT}  300  # [in seconds] Timeout for cell to go online after radio module power on.
${CHECK_NA_ALARM}  True  # False or True. The value is used to check alarm presence in NetAct.


*** Keywords ***
TC__FM__RF_hot_remove_hot_insert
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-4040
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 30.09.2016 - https://jira3.int.net.nokia.com/browse/TAT-4040 - Initial creation
    ...  - 20.12.2016 - https://jira3.int.net.nokia.com/browse/TAT-4871 - RMOD POWER ON in Step1 teardown
    ...  - 22.12.2016 - https://jira3.int.net.nokia.com/browse/TAT-4903 - Snapshot alternative method via ssh
    ...  - 20.01.2017 - https://jira3.int.net.nokia.com/browse/TAT-4870 - Cells dist names changed
    ...  - 01.02.2017 - https://jira3.int.net.nokia.com/browse/TAT-5404 - Syntax error caused by invalid query fixed
    ...  - 06.02.2017 - https://jira3.int.net.nokia.com/browse/TAT-5404 - Fault 1851 will not be checked
    ...  - 14.02.2017 - https://jira3.int.net.nokia.com/browse/TAT-5534 - Test case name changed
    ...  - 17.02.2017 - https://jira3.int.net.nokia.com/browse/TAT-5565 - Alarm number changed
    ...  - 28.02.2017 - https://jira3.int.net.nokia.com/browse/TAT-5658 - Snapshot path changed to BTS Files
    ...  - 06.03.2017 - https://jira3.int.net.nokia.com/browse/TAT-5657 - Select RMOD by serial number
    ...  - 08.03.2017 - https://jira3.int.net.nokia.com/browse/TAT-5650 - Extended carriers recovery time
    ...  - 24.03.2017 - https://jira3.int.net.nokia.com/browse/TAT-6039 - Empty RMOD_SN error message update
    ...  - 20.04.2017 - https://jira3.int.net.nokia.com/browse/TAT-6230 - Limit Snapshot Collecting and utilize common keywords from hran_infomodel
    ...  - 18.05.2017 - https://jira3.int.net.nokia.com/browse/TAT-6445 - Get impacted cells from alarm 7116 and check their status
    ...  - 29.05.2017 - https://jira3.int.net.nokia.com/browse/TAT-6477 - Increase timeout for RMOD after insert
    ...  - 31.05.2017 - https://jira3.int.net.nokia.com/browse/TAT-6677 - Check impacted cells for each rat from admin alarm object
    ...  - 11.07.2017 - https://jira3.int.net.nokia.com/browse/TAT-7044 - Wait for alarm impacted cells property update
    ...  - 10.08.2017 - https://jira3.int.net.nokia.com/browse/TAT-7202 - Use proper method to ping rmod on rel4.
    ...  - 23.08.2017 - https://jira3.int.net.nokia.com/browse/TAT-7346 - Replace deprecated keywords from ute-admin.
    ...  - 28.02.2018 - https://jira3.int.net.nokia.com/browse/TAT-9086 - Adapted TC to run on 3+3 and 4+4
    ...  - 30.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-10343 - Increase timeout for alarm due to fault 10 to 140 s
    ...  - 04.06.2018 - https://jira3.int.net.nokia.com/browse/TAT-10331 - Fixed KW Ping Rmod
    ...  - 06.06.2018 - https://jira3.int.net.nokia.com/browse/TAT-10414 - Fixed KW Ping Rmod
    ...  - 23.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-10027 - Added 'Cells Status Check' keyword and 'CELLS_ONLINE_TIMEOUT' variable
    ...  - 23.05.2018 - https://jira3.int.net.nokia.com/browse/TAT-10031 - Removed ERROR variable from 'Infomodel Cell Carriers Should Be Restored'
    ...  - 24.10.2018 - https://jira3.int.net.nokia.com/browse/TAT-10737 - Added Admin Check Active Alarms in step 2
    ...  - 11.12.2018 - https://jira3.int.net.nokia.com/browse/TAT-13570 - Hot insert of RMOD v.5.1 AHEGB insufficient timeout period
    ...  - 15.05.2019 - https://jira3.int.net.nokia.com/browse/TAT-15877 - Added powering on affected radio module in case of test case failure
    ...  - 18.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-16493 - Random selection of RMOD object for test in case RMOD_SN is not provided
    ...  - 26.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-16635 - Collect selected RMOD REF- after radio unblock
    ...  - 20.08.2019 - https://jira3.int.net.nokia.com/browse/TAT-17220 - Ping command creation changed - fix for 4+3 config
    ...  - 07.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17245 - Make Command KW fixed for RMOD splitted between cores
    ...  - 13.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18740 - Use Set Test Variable instead of Set Suite Variable
    ...  - 18.02.2020 - https://jira3.int.net.nokia.com/browse/TAT-19039 - Set as Test Variable RMOD MasterAgentDN and IP
    ...  - 25.02.2020 - https://jira3.int.net.nokia.com/browse/TAT-19097 - Read again RMOD properties after PowerON
    ...  - 27.04.2020 - https://jira3.int.net.nokia.com/browse/TAT-19429 - Update test case for fault 1972 RRU power loss in case of 5.1 RMOD
    ...  - 05.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19501 - FM__RMOD_hot_remove_hot_insert update
    ...  - 07.09.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20162 - Remove or adapt check for fault 1972 because of CNI approval
    ...  - 05.05.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21291 - FM__RF_hot_remove_hot_insert fails due to CarrierState : unitialized
    ...  - 25.05.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21345 - TC fails because RF ip address changes after hot remove hot insert
    ...  - 10.06.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21417 - FastPass improvement - adapt RMOD_hot_remove_insert to add Netact checks
    ...  - 12.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21215 - Update FM testcases accordingly with CNI-64164
    ...  - 31.08.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21782 - Enhancement for test FM__RF_hot_remove_hot_insert
    ...  - 02.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 10.12.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22326 - RF_hot_remove_hot_insert fails at ping rmod due to masteragentdn not set
    ...  - 22.12.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22398 - RF_hot_remove_hot_insert fails at step0
    ...  - 26.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22553 - RF_hot_remove_hot_insert fails due to missing CONF_REF-1
    ...  - 01.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22576 - Added new check for cells after hot insert
    ...  - 07.03.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22766 - Adapting test for older sw versions(eg. 21B)
    ...  - 12.04.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22943 - Add support for multiple severity cases
    ...  - 11.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23846 - Increase Timeout for RMOD after hot insert
    ...  - 28.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23842 - Remove Test Specific Teardown and Setup
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 11.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24108 - Get container pid in a different way
    ...  - 01.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26055 - Add supplementary alarm info check
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 16.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26947 - Set alarm parameters by active software version
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 21.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26906 - Performing RU reset before RU power off
    ...  - 25.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27422 - Radio module power off is performed too late
    ...  - 15.05.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27498 - Alarm not found in Netact
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  - 05.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28353 - Test fails due to removing severity from FAULT_10_CRITICAL dictionary
    ...  - 05.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28828 - Change alarm info additional information
    ...  - 25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  - 25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  - 14.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30146 - Enhancement for CB012530-SR-A
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  MAINTAINER-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CIT  FEATURE-RP001534  FEATURE-CB012530-SR-A

    Step0: Suite Specific Preconditions
    Step1: RF Module Hot Remove
    Step2: RF Module Hot Insert


Step0: Suite Specific Preconditions
    Log  \nStep0: Suite specific preconditions.  console=true
    IF  '${RMOD_SN}' != ''
      ${rmod}  _Get Rmod Object By Serial Number  ${RMOD_SN}
    ELSE
      ${rmod}  _Get Random Rmod Object
    END
    Log  Selected RMOD: ${rmod.productName} with SN: ${rmod.serialNumber}.  console=true
    ${rmod_cells}  Infomodel Get Cells Deployed On Module  ${rmod}
    ${left_over_cells}  Query Infomodel  get list //CELL_M-*
    Remove Values From List  ${left_over_cells}  @{rmod_cells}

    Set Test Variable  ${RMOD_IF}  RMOD_${RMOD_SN}
    Set Test Variable  ${RMOD_CELLS}
    Set Test Variable  ${LEFT_OVER_CELLS}

    ${rmod_r}  Query Infomodel  get object //RMOD_R-* is [serialNumber=${RMOD_SN}]
    ${product_name}  Get From Dictionary  ${rmod_r}  productName
    ${status_ecpri}  Check l3Protocol For Given RMOD Type  ${product_name}  .*(ecpri|eCPRI|ECPRI).*
    ${transceiver_identifier}  IF  ${status_ecpri}  Get Sfp Transceiver Identifier For Radio Module  ${rmod_r}[dist_name]
    ${rmod_r_dn}  Get From Dictionary  ${rmod_r}  dist_name
    Set Test Variable  ${RMOD_R_DN}
    Set Test Variable  ${UNIT}  ${product_name}

    IF  '${rmod_r.radioModuleHwReleaseCode}' == 'RRH5.1'
      Set Test Variable  ${CHECK_ALARM_1972}  ${TRUE}
    ELSE
      Set Test Variable  ${CHECK_ALARM_1972}  ${FALSE}
    END

    ${bts_name}  Infomodel Get Objects Parameter  //MRBTS_A-*  btsName
    ${mrbts}  Infomodel Get Objects Parameter  /MRBTS-1/RAT-1/BTS_L-*  btsId
    ${rmod_r}  Query Infomodel  get object //RMOD_R-* is [serialNumber=${RMOD_SN}]  timeout=60
    ${software}  Get Software Info
    ${active_sw}  Get From Dictionary  ${software}  Active SW version
    ${sw_variant}  Fetch From Left  ${active_sw}  _
    IF  '${sw_variant}' < 'SBTS22R1'
      ${conf_a}  Get CONF_A Object For Older Sw  ${rmod_r}
    ELSE
      ${conf_a}  Query Infomodel  get object ${rmod_r.configDN}  timeout=60
    END
    ${conf_a_str}  Remove String  ${conf_a.dist_name}  _A
    ${string}  Fetch From Right  ${conf_a_str}  /MRBTS-${mrbts[0]}/
    Set Test Variable  ${CONF_OBJ}  [${bts_name[0]}] MRBTS-${mrbts[0]}/${string}

    ${fault_10_dictionary}  Copy Dictionary  ${FAULT_10_CRITICAL}
    Remove From Dictionary  ${fault_10_dictionary}  severity
    ${fid_10_params}  Get String With Alarm Parameters  ${fault_10_dictionary}
    ${supplAlarmInfo}  Set Variable If  "_FSM3_" in "${active_sw}"  additionalFaultReason  supplAlarmInfo
    ${suppl_alarm_info_text}  Set Variable If  ${status_ecpri} and '${ENB_BRANCH}'>='SBTS26R1'
    ...  RU not detected after reset.*Reset reason: user request.*SFP type is ${transceiver_identifier}.*Protocol is eCPRI.*
    ...  RU not detected after reset
    ${fid_10_with_suppl_alarm_info}  Catenate  ${fid_10_params},  ${supplAlarmInfo}=regex"${suppl_alarm_info_text}"
    ${alarm_parameters}  Set Variable If  '${sw_variant}' < 'SBTS24R2'  ${fid_10_params}  ${fid_10_with_suppl_alarm_info}
    Set Test Variable  ${ALARM_PARAMETERS}
    Set Test Variable  ${SUPPL_INFO_TEXT}  ${suppl_alarm_info_text}


Step1: RF Module Hot Remove
    Log  \nStep1: RF module hot remove.  console=true
    Store Rmod  ${RMOD_SN}
    Log  Radio module will reset.  console=True
    Run Keyword And Ignore Error  coam.Reset Unit  ${RMOD_R_DN}  timeout=30
    Wait Until Keyword Succeeds  30s  5s  Ping Rmod  expected_rc=1
    Log  Radio module will be powered off.  console=True
    Pdu Bts Interface Off  ${RMOD_IF}
    IF  ${CHECK_ALARM_1972}
      Check Warning 1972
    ELSE
      Log  RRH is not 5.1, alarm 1972 will not be checked.  console=true
    END
    ${alarms}  Assert Alarm Active  parameters=${ALARM_PARAMETERS}  timeout=${ALARM_TIMEOUT}
    ${alarm}  Evaluate  next((alarm for alarm in ${alarms} if (u'faultId', 10) in alarm.items()))
    Log  Impacted Cells list from faultId=${FAULT_10_CRITICAL}[fault_id]:\n ${alarm['impactedCells']}  console=true

    Log  configObjectName in alarm is: ${alarm['configObjectName']}.  console=true
    ${config_object_check}  Run Keyword And Return Status
    ...  Should Be Equal  ${alarm['configObjectName']}  ${CONF_OBJ}
    IF  ${config_object_check}
      Log  Configuration alarming object in alarm is field correctlly.  console=true
    ELSE
      Set Test Restriction  Configuration alarming object in alarm is incorrect. [NOK]
    END
    FOR  ${im_cell}  IN  @{RMOD_CELLS}
        ${has_pair}  Infomodel Cell Has At Least One Operational RXTX Pair  ${im_cell}
        IF  ${has_pair}
          Infomodel Cell Should Be Degraded  ${im_cell}
        ELSE
          Infomodel Cell Should Be Failed  ${im_cell}
        END
    END
    FOR  ${im_cell}  IN  @{LEFT_OVER_CELLS}
        Infomodel Cell Should Be Online  ${im_cell}
    END
    IF  ${CHECK_NA_ALARM}  Check Alarm Presence In Netact


Step2: RF Module Hot Insert
    Log  \nStep2: RF module hot insert.  console=true
    Log  Radio module will be powered on.  console=True
    Pdu Bts Interface On  ${RMOD_IF}
    Sleep  60s
    Wait Until Keyword Succeeds  ${RMOD_INSERT_TIMEOUT}s  10s  Store Rmod  ${RMOD_SN}
    Wait Until Keyword Succeeds  ${PING_RMOD_TIMEOUT}s  5s  Ping Rmod
    ${alarms}  Assert Alarm Inactive  parameters=${ALARM_PARAMETERS}  timeout=${ALARM_TIMEOUT}
    ${cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${CELLS_ONLINE_TIMEOUT}s  10s
    ...  Check All Cells
    IF  ${cells_status}
      Log  All cells are up after hot insert.  console=true
    ELSE
      Fail  Cells didn't manage to recover after hot insert.
    END
    Admin Check Active Alarms TAF
    Check Fault Signature If Fault 4589 Was Raised At Power Off/On For Radio Module


_Get Random Rmod Object
    [Documentation]  This KW is for random selection of the RMOD object from all available RMODs in SBTS config.

    Log  SN is not provided tested RM will be randomly choosen.  console=true
    ${rmods_serial_numbers_list}  Infomodel Get All Radio Modules Serial Numbers
    ${list}  Remove Duplicates  ${rmods_serial_numbers_list}
    ${rmods_serial_numbers_list_lenght}  Get Length  ${list}
    Log  There are ${rmods_serial_numbers_list_lenght} suitable radio modules. One of them will be randomly choosen.  console=true
    ${sn_random_position}  Evaluate  random.randint(0,${rmods_serial_numbers_list_lenght}-1)  random
    ${selected_serial_number}  Get From List  ${rmods_serial_numbers_list}  ${sn_random_position}
    ${rmod_l_obj}  _Get Rmod Object By Serial Number  ${selected_serial_number}
    Set Test Variable  ${RMOD_SN}  ${selected_serial_number}

    RETURN  ${rmod_l_obj}


Get CONF_A Object For Older Sw
    [Arguments]  ${rmod_r}

    ${conf_ref}  Query Infomodel  get object ${rmod_r.dist_name}/CONF_REF-1  timeout=60
    ${conf_a}  Query Infomodel  get object ${conf_ref.distName}  timeout=60

    RETURN  ${conf_a}


Store Rmod
    [Documentation]  This KW stores the value of IP and MasterAgentDN.
    [Arguments]  ${sn}

    ${rmod}  _Get Rmod Object By Serial Number  ${sn}
    ${smod_l}  Query Infomodel  get object ${rmod.masterAgentDN}
    ${smod_r}  Query Infomodel  get object //CABINET_R-*/SMOD_R-* is [serialNumber=${smod_l.serialNumber}]
    Should Be True  '${rmod.ipAddress}' != '0.0.0.0'
    ${rmod_ip_addr}  Set Variable  ${rmod.ipAddress}
    Set Test Variable  ${SMOD_L}
    Set Test Variable  ${SMOD_R}
    Set Test Variable  ${RMOD_IP_ADDR}


Ping Rmod
    [Arguments]  ${expected_rc}=0

    Should Be True  '${RMOD_IP_ADDR}' != '0.0.0.0'
    Connect To SMOD  ${SMOD_L.ipAddress}
    ${containers}  ssh.Execute  lxc-ls
    ${018_matches}  Get Regexp Matches  ${containers}  0x\\d018
    ${is_airscale}  Run Keyword And Return Status  Should Contain  ${SMOD_R.productName}  AirScale
    ${command}  Set Variable If  ${is_airscale}  lxc-attach -n ${018_matches}[0] -- ping -c1 ${RMOD_IP_ADDR}  ping -c1 ${RMOD_IP_ADDR}
    ssh.Execute  ${command}
    ssh.Assert Exit Status  ${expected_rc}


Check Alarm Presence In Netact
    ${alarm_na}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_10_CRITICAL}  suppl_info=${SUPPL_INFO_TEXT}
    ...  severity=Critical  additional_severity=Major  additional_fault_id=${FAULT_10_CRITICAL}[fault_id]
    IF  ${alarm_na}
      Log  Present in NA: faultId=${FAULT_10_CRITICAL}[fault_id], faultName=${FAULT_10_CRITICAL}[fault_name].  console=true
    ELSE
      Fail  Alarm is not present in NA or alarm fields not correct. [NOK]
    END
    ${check_unit_name}  Run Keyword And Return Status
    ...  Check Unit_Name In Alarm Additional Text  ${UNIT}  RMOD
    IF  ${check_unit_name}
      Log  Unit Name is correctlly displayed in additionalText3 in NA alarm.  console=true
    ELSE
      Fail  Unit Name is not correctlly displayed in NA alarm. [NOK]
    END


Check Warning 1972
    Log  RRH is 5.1, warning 1972 should be present.  console=true
    ${fid_1972_params}  Get String With Alarm Parameters  ${FAULT_1972}
    ${alarm_1972_status}  Run Keyword And Return Status
    ...  Assert Alarm Active  parameters=${fid_1972_params}  timeout=30
    IF  ${alarm_1972_status}
      Log  Warning 1972 has appeared.[OK]  console=true
    ELSE
      Set Test Restriction  Warning 1972 did not appeared.[NOK]
    END


Power ON Target RM
    Log  Affected radio module will be turned on.  console=true
    Pdu Bts Interface On  RMOD_${RMOD_SN}
    ${alarms}  Assert Alarm Inactive  parameters=${ALARM_PARAMETERS}  timeout=${ALARM_TIMEOUT}


TC Setup
    Common Test Setup  tc_name=FM__RF_hot_remove_hot_insert
    IF  ${CHECK_NA_ALARM}  Setup NetAct


TC Teardown
    Power ON Target RM
    IF  ${CHECK_NA_ALARM}  Teardown NetAct
    Common Test Teardown
