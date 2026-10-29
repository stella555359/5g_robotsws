*** Settings ***
Documentation
    ...  This test case was created to imitate RAT recovery reset counter exceeded scenario.
    ...  Test will execute 2 SW_NODE crashes of CentralCPlane for WCDMA resulting in RAT recovery reset.
    ...  Test will execute 2 DSP crashes for WCDMA resulting in RAT recovery reset.
    ...  First 3 crashes will raise warning fault 4383, respectively fault 6707/6708/6709 with fault name RAT autonomous reset as recovery action.
    ...  4th crash will will raise critical fault 6707/6708/6709 with fault name DSP application fatal error. Recovery action is not performed.
    ...  For releases equal or higher to SBTS24R3, parameter actAlarmOfRatOutage is set to true to verify fault 4753
    ...  with fault name RAT Service Outage.
    ...  For releases equal or higher to SBTS25R3, maintenance window will be created and recovery will be performed during maintenance window to
    ...  recover services.
    ...  At the end of the test site reset will be performed to clear recovery reset counters.

Library  ute_async
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RECOVERY_TIMEOUT}  360  # [in seconds] Timeout for SBTS to recover after RAT recovery reset.
${STARTUP_TIMEOUT}  660  # [in seconds] Timeout for SBTS to recover after startup.
${ALARM_TIMEOUT}  600  # [in seconds] Timeout for alarm to be active after crash.
${NETACT_TIMEOUT}  120  # [in seconds] Timeout for alarm reporting in Netact.


*** Keywords ***
TC__FM__RAT_reset_counter_exceeded_multi_RAT
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-10455
    ...
    ...  ******************
    ...  History of changes
    ...  13.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19471 - Aligment with taf.rnc.oms.nwi3 library for FM test cases that use nwi3
    ...  03.03.2021 - https://jira3.ext.net.nokia.com/browse/TAT-20883 - Reduce testcase execution time for RAT reset counter exceeded
    ...  17.08.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21635 - Implement new method for choosing DSP for crash based on DSPs
    ...  24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  28.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22722 - Increase alarm timeout
    ...  07.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24051 - Optimization of KW usage for FM
    ...  14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  01.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24843 - When testcase fails, it does not restore actForceAutoReset value to false
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  01.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27105 - Update alarm checking
    ...  26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27704 - Add option to skip RMOD power check
    ...  10.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27766 - Raise FID 4753 and check it's appearance.
    ...  13.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27947 - Check FID 4753 only for newer releases.
    ...  21.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27965 - Block cells that are on air.
    ...  29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  17.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29103 - Update testcases and resourses for CB011146
    ...  16.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28442 - Verification of fault signature scope field for FM test cases
    ...  19.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29381 - Changes to send crash on Flexi DSP
    ...  27.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29368 - Enhancement for CB008708
    ...  04.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29516 - Skip CB008708 for software versions below 25R3
    ...  19.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29766 - Added core variables for fault signature
    ...  16.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30319 - Added maintenance window cleanup in case the test failed
    ...  17.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30189 - Enhancement merge 2 testcases into one
    ...  22.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30358 - Correct DSP L object parameters verification
    ...  ******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-rafal.ozga@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS17A  FEATURE-RP001534

    Step0: Testcase Preconditions
    Step1: Trigged WCDMA DSP Crash
    Step2: Trigged Sw Node Crash
    Step3: Trigged Sw Node Crash
    Step4: Trigger 4th WCDMA DSP Crash
    Step5: Activate Maintenance Window
    Step6: Deactivate Maintenance Window
    Step7: Perform Site Reset


Step0: Testcase Preconditions
    Log  \nStep0: Testcase Preconditions.  console=true
    Log  Change actForceAutoReset value to true if needed.  console=true
    ${list}  Create List  actForceAutoReset
    ${object}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1  ${list}
    ${initial_value}  Set Variable  ${object}[0][parameters][actForceAutoReset]
    Set Test Variable  ${ACT_FORCE_AUTO_RESET_INI}  ${initial_value}
    Change FMCADM Parameter  actForceAutoReset  true
    Check Commissioned Technologies  WCDMA
    Check If 2RAT
    Choose DSP For Crash  WCDMA
    Choose Central CPlane Software Node
    Set Fault Signature Variables
    ${all_rnc_ids}  Get Ids For All  RNC
    ${rnc_parameters}  coam.Get Parameters  ${all_rnc_ids}[0]
    Set Test Variable  ${RNC_ID}  ${rnc_parameters}[rncId]
    Set Test Variable  ${WBTS_ID}  ${rnc_parameters}[wbtsId]
    IF  '${ENB_BRANCH}' < 'SBTS24R3'  RETURN
    Change FMCADM parameter  actAlarmOfRatOutage  true
    ${fault_service_out}  Copy Dictionary  ${FAULT_4753}
    ${4753_parameters}  Get String With Alarm Parameters  ${fault_service_out}
    Set Test Variable  ${4753_PARAMETERS}
    Perform Site Reset


Step1: Trigged WCDMA DSP Crash
    Log  \nStep1: Trigger WCDMA DSP crash.  console=true
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Log  DSPs stateInfo will be checked under specified pattern:  console=true
    ${dsp_parameters}  coam.Get Parameters  ${DSP_L_DN}
    Verify Parameters For DSP L Object  ${dsp_parameters}
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=cellsCheck
    ${cells_status}  Run Keyword In Background  Assert Every  class_name=WNCEL  parameters=operationalState=${DISABLED}  timeout=660
    ...  alias=cellsCheck
    Verify SMOD Type And Trigger DSP Crash
    ${fault_rat_auto_rst}  Copy Dictionary  ${FAULT_6707_RAT_AUTO_RST}
    Set To Dictionary  ${fault_rat_auto_rst}  fault_id=regex"6707|6708|6709"
    ${fault_parameters_dsp_crash}  Get String With Alarm Parameters  ${fault_rat_auto_rst}
    ${alarms}  Assert Alarm Active  parameters=${fault_parameters_dsp_crash}  timeout=${ALARM_TIMEOUT}
    ${alarm}  Evaluate  next((alarm for alarm in ${alarms} if (u'faultName', 'RAT autonomous reset as recovery action') in alarm.items()))
    ${fault_rat_reset_netact}  Set Variable  ${alarm}[faultId]
    Log  Fault ${fault_parameters_dsp_crash} is active in WebEM.  console=true

    ${recovery_reset}  Run Keyword And Return Status  Query Infomodel  get list //RECOVERY_RESET_IND-*  timeout=240
    ${status_cells}  Run Keyword And Return Status  Collect Keyword Result  ${cells_status}  timeout=660
    IF  ${status_cells}
        Log  WCDMA cells were failed while fault occured. [OK]  console=true
    ELSE
        Set Test Restriction  WCDMA cells were not failed while fault occured. [NOK]
    END
    IF  ${recovery_reset}
        Log  Recovery Reset Indication was visible under FRI. [OK]  console=true
    ELSE
        Set Test Restriction  Recovery Reset Indication was not visible under FRI. [NOK]
    END
    Log  Verify success of recovery action after WCDMA DSP crash.  console=true
    Assert Alarm Inactive  parameters=${fault_parameters_dsp_crash}
    Log  Fault ${fault_parameters_dsp_crash} is not visible after recovery action.  console=true
    Log  Testcase will now check if WCDMA cells are recovered.  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}s  30s  Check All Cells
    Log  DSPs stateInfo will be checked under specified pattern:  console=true
    ${dsp_parameters}  coam.Get Parameters  ${DSP_L_DN}
    Verify Parameters For DSP L Object  ${dsp_parameters}

    ${fault_dict_netact}  Copy Dictionary  ${FAULT_6707_RAT_AUTO_RST}
    Set To Dictionary  ${fault_dict_netact}  fault_id=${fault_rat_reset_netact}
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{fault_dict_netact}  time_from=${start_time}
    ...  additional_fault_id=${fault_dict_netact}[fault_id]
    Log  Fault ${fault_dict_netact} was reported and cleared in Netact.  console=true
    Log  Check fault signature.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${fault_dict_netact}[fault_id]  category=${CATEGORY}  extra_info=${EXTRA_INFO}
    ...  info=${INFO_DSP_CRASH}  load_name=${SW_VERSION}  minor=${MINOR_DSP_CRASH}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME_DSP_CRASH}
    ...  serial_number=${SERIAL_NUMBER_DSP_CRASH}  vendor_unit_number=${PRODUCT_CODE_DSP_CRASH}  unit_position=${UNIT_POSITION_DSP_CRASH}
    ...  core_unit_position=${CORE_UNIT_POSITION_DSP_CRASH}
    Check Fault Signature Of Alarm In Netact  fault_id=${fault_dict_netact}[fault_id]  time_from=${start_time}  category=CATEGORY:${SPACE}${CATEGORY}
    ...  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO_DSP_CRASH}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}
    ...  minor=MINOR:${SPACE}${MINOR_DSP_CRASH}  scope=SCOPE:${SPACE}${SCOPE}  full_product_name=${PRODUCT_NAME_DSP_CRASH}
    ...  serial_number=${SERIAL_NUMBER_DSP_CRASH}  vendor_unit_number=${PRODUCT_CODE_DSP_CRASH}  unit_position=${UNIT_POSITION_DSP_CRASH}
    ...  core_unit_position=${CORE_UNIT_POSITION_DSP_CRASH}

    [Teardown]  Run Keyword And Continue On Failure  Teardown Admin  alias=cellsCheck


Step${index}: Trigged Sw Node Crash
    Log  \nStep${index}: Trigged Sw Node Crash.  console=true
    ${node_id}  Convert To Hex  ${SW_NODE_FOR_CRASH}[parameters][nodeId]  prefix=0x
    ${node_id}  Convert To Lower Case  ${node_id}
    Crash Central CPlane Software Node  ${node_id}  ${SW_NODE_FOR_CRASH}[distName]
    Log  Verify fault appearance and recovery.  console=true
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=wncel
    ${fault_4383_params}  Get String With Alarm Parameters  ${FAULT_4383_RAT_AUTO_RST}
    ${fault_4383_bkg}  Run Keyword In Background  Assert Alarm Active  parameters=${fault_4383_params}  timeout=400
    Start Async  ute_admin_infomodel  Query Infomodel  get list //RECOVERY_RESET_IND-*  timeout=400  alias=recovery
    ${wncel_cells_status_bkg}  Run Keyword In Background  Assert Every  WNCEL  parameters=operationalState=${DISABLED}  timeout=400  alias=wncel

    ${status_fault}  ${dict_result}  Run Keyword And Ignore Error  Collect Keyword Result  ${fault_4383_bkg}  timeout=400
    IF  '${status_fault}'=='FAIL'  Fail  message=Fault ${FAULT_4383_RAT_AUTO_RST} is not visible in WebEM. [NOK]
    Log  Fault ${FAULT_4383_RAT_AUTO_RST} is visible in WebEM. [OK]  console=true
    ${status_reset_recovery}  ${async_result}  Run Keyword And Ignore Error  Wait For Async Result  alias=recovery
    IF  '${status_reset_recovery}'=='FAIL'
        Set Test Restriction  Recovery reset indication is not visible under FRI. [NOK]
    ELSE
        Log  Recovery reset indication is visible uder FRI. [OK]  console=true
    END
    ${wncel_cells_status}  Run Keyword And Return Status  Collect Keyword Result  ${wncel_cells_status_bkg}  timeout=900
    IF  ${wncel_cells_status}
        Log  WCDMA cells were failed while fault occured. [OK]  console=true
    ELSE
        Set Test Restriction  WCDMA cells were not failed while fault occured. [NOK]
    END
    ${lncel_cells_status}  Run Keyword And Return Status  Assert Every  LNCEL  operationalState=${ENABLED}
    IF  '${lncel_cells_status}'=='FAIL'  Fail  At least one of LNCEL is disabled.
    ${gncel_cells_status}  Run Keyword And Return Status  Assert Every  GNCEL  operationalState=${ENABLED}
    IF  '${gncel_cells_status}'=='FAIL'  Fail  At least one of GNCEL is disabled.
    Assert Alarm Inactive  parameters=${fault_4383_params}  timeout=120

    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4383_RAT_AUTO_RST}
    ...                                                                               time_from=${start_time}
    ...                                                                               additional_fault_id=${FAULT_4383_RAT_AUTO_RST}[fault_id]
    ...                                                                               dist_name=PLMN-PLMN/RNC-${RNC_ID}/WBTS-${WBTS_ID}
    Log  Fault ${FAULT_4383_RAT_AUTO_RST} reported & cleared in Netact.  console=true
    Log  Check fault signature in WebEM and Mantaray.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_4383_RAT_AUTO_RST}[fault_id]  category=${CATEGORY}  extra_info=${EXTRA_INFO}
    ...  info=${INFO_SW_NODE_CRASH}  load_name=${SW_VERSION}  minor=${MINOR_SW_NODE_CRASH}  reset_counter=${RESET_COUNTER}  scope=${SCOPE}
    ...  full_product_name=${PRODUCT_NAME_SW_NODE_CRASH}  serial_number=${SERIAL_NUMBER_SW_NODE_CRASH}
    ...  vendor_unit_number=${PRODUCT_CODE_SW_NODE_CRASH}  unit_position=${UNIT_POSITION_SW_NODE_CRASH}
    ...  core_unit_position=${CORE_UNIT_POSITION_SW_NODE_CRASH}
    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_4383_RAT_AUTO_RST}[fault_id]  time_from=${start_time}
    ...  category=CATEGORY:${SPACE}${CATEGORY}  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO_SW_NODE_CRASH}
    ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  minor=MINOR:${SPACE}${MINOR_SW_NODE_CRASH}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}
    ...  scope=SCOPE:${SPACE}${SCOPE}  full_product_name=${PRODUCT_NAME_SW_NODE_CRASH}  serial_number=${SERIAL_NUMBER_SW_NODE_CRASH}
    ...  vendor_unit_number=${PRODUCT_CODE_SW_NODE_CRASH}  unit_position=${UNIT_POSITION_SW_NODE_CRASH}
    ...  core_unit_position=${CORE_UNIT_POSITION_SW_NODE_CRASH}  dist_name=PLMN-PLMN/RNC-${RNC_ID}/WBTS-${WBTS_ID}

    [Teardown]  Run Keywords
    ...  Stop Async  alias=recovery
    ...  AND
    ...  Run Keyword And Continue On Failure  Teardown Admin  alias=wncel


Step4: Trigger 4th WCDMA DSP Crash
    Log  \nStep4: Verify behavior after 4th WCDMA DSP crash.  console=true
    Log  DSPs stateInfo will be checked under specified pattern:  console=true
    ${dsp_parameters}  coam.Get Parameters  ${DSP_L_DN}
    Verify Parameters For DSP L Object  ${dsp_parameters}
    Verify SMOD Type And Trigger DSP Crash
    Log  Waiting ${ALARM_TIMEOUT}s for alarm to be active.  console=true
    ${fault_dsp_app_fatal_err}  Copy Dictionary  ${FAULT_6707_DSP_APP_FATAL_ERR}
    Set To Dictionary  ${fault_dsp_app_fatal_err}  fault_id=regex"6707|6708|6709"
    ${alarm_parameters}  Get String With Alarm Parameters  ${fault_dsp_app_fatal_err}
    ${alarms}  Assert Alarm Active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    ${alarm}  Evaluate  next((alarm for alarm in ${alarms} if (u'faultName', 'DSP application fatal error') in alarm.items()))
    Log  Fault ${alarm_parameters} is visible in WebEM.  console=true

    ${fault_4th_crash_netact}  Set Variable  ${alarm}[faultId]
    ${fault_dict_netact}  Copy Dictionary  ${FAULT_6707_DSP_APP_FATAL_ERR}
    Set To Dictionary  ${fault_dict_netact}  fault_id=${fault_4th_crash_netact}
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{fault_dict_netact}  additional_fault_id=${fault_dict_netact}[fault_id]
    Log  Fault ${fault_dict_netact} is reported in NetAct.  console=true
    IF  '${ENB_BRANCH}' >= 'SBTS24R3'  Verify Fault 4753 Appearance
    Change Parameter ActForce(Unit)AutoReset  ${ACT_FORCE_AUTO_RESET_INI}  actForceAutoReset


Step5: Activate Maintenance Window
    IF  '${ENB_BRANCH}' < 'SBTS25R3'  RETURN
    Log  \nStep5: Activate Maintenance Window.  console=true
    Create Maintenance Window
    Wait Until Keyword Succeeds  900s  10s
    ...  Check All Cells
    ${parameter_object}  Wait Until Keyword Succeeds  300  10  Get Forced Recovery Parameter When Is Completed
    Verify Force Recovery Parameters  ${parameter_object}  ${FAULT_6707_DSP_APP_FATAL_ERR}


Step6: Deactivate Maintenance Window
    IF  '${ENB_BRANCH}' < 'SBTS25R3'  RETURN
    Log  \nStep6: Deactivate Maintenance Window.  console=true
    Delete Maintenance Window


Step7: Perform Site Reset
    Log  \nStep7: Perform Site Reset.  console=true
    Perform Site Reset


Verify Fault 4753 Appearance
    Block online cells for given RAT  wcdma
    Sleep  11 min  Wait for fault to appear.
    Assert Alarm Active  parameters=${4753_PARAMETERS}  timeout=120s
    Log  Fault ${FAULT_4753} reported in WebEM. [OK]  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_4753}  additional_fault_id=${FAULT_4753}[fault_id]
    Log  Fault ${FAULT_4753} is reported in NetAct.  console=true
    Change FMCADM parameter  actAlarmOfRatOutage  false
    Assert Alarm Inactive  parameters=${4753_PARAMETERS}  timeout=300s
    Log  Fault ${FAULT_4753} cleared from WebEM. [OK]  console=true


Recovery Action If Test Fails
    Maintenance Window Cleanup
    Perform Site Reset


Set Fault Signature Variables
    Log  Setting variables for fault signature.  console=true
    Set Test Variable  ${SCOPE}  WCDMA RAT
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${RESET_COUNTER}  [0-9]+
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=WCDMA:[0-9]+.*(gracefully_shutdown_cells:[0-9]+)?
    Set Test Variable  ${INFO_SW_NODE_CRASH}  CCS supervised command exited.*
    ${dsp_node_id}  Get Substring  ${NODE_ID}  0  5
    Set Test Variable  ${MINOR_DSP_CRASH}  ${dsp_node_id}
    Set Test Variable  ${INFO_DSP_CRASH}  .*FATAL EXCEPTION Nid:${MINOR_DSP_CRASH}.*

    ${soc_l}  Fetch From Left  ${CORE_ID}[dist_name]  /DSP_L
    ${is_bbu}  Run Keyword And Return Status  Should Contain  ${soc_l}  BBU_L
    IF  ${is_bbu}
        ${module_l_dn}  Fetch From Left  ${soc_l}  /BBU_L
    ELSE
        ${module_l_dn}  Fetch From Left  ${SOC_soc_l}  /BOARD_L
    END
    ${is_bbmod}  Run Keyword And Return Status  Should Contain  ${module_l_dn}  BBMOD
    ${type}  Set Variable If  ${is_bbmod}  BBMOD  SMOD
    ${module_parameters}  coam.Get Parameters For  ${type}  ${module_l_dn}
    Set Test Variable  ${PRODUCT_NAME_DSP_CRASH}  ${module_parameters}[productName]
    Set Test Variable  ${SERIAL_NUMBER_DSP_CRASH}  ${module_parameters}[serialNumber]
    Set Test Variable  ${PRODUCT_CODE_DSP_CRASH}  ${module_parameters}[productCode]
    ${module_r_dn}  Get Runtime Object Dist_name From Logical Object Dist_name  ${module_l_dn}
    Set Unit Position For Fault Signature  ${module_r_dn}
    Set Test Variable  ${CORE_UNIT_POSITION_DSP_CRASH}  ${CORE_UNIT_POSITION}
    Set Test Variable  ${UNIT_POSITION_DSP_CRASH}  ${UNIT_POSITION}

    ${node_id}  Convert To Hex  ${SW_NODE_FOR_CRASH}[parameters][nodeId]  prefix=0x
    ${node_id}  Convert To Lower Case  ${node_id}
    ${hostname}  Get Regexp Matches  ${SW_NODE_FOR_CRASH}[parameters][hostname]  [A-Z_]*
    ${minor_id}  Set Variable If  '${ENB_BRANCH}' < 'SBTS24R3'  ${node_id}  ${hostname}[0]${SPACE}${node_id}
    Set Test Variable  ${MINOR_SW_NODE_CRASH}  ${minor_id}
    ${is_board}  Run Keyword And Return Status  Should Contain  ${SW_NODE_FOR_CRASH}[distName]  BOARD
    ${string}  Set Variable If  ${is_board}  /BOARD  /CCU
    ${smod_l_dn}  Fetch From Left  ${SW_NODE_FOR_CRASH}[distName]  ${string}
    ${smod_l_parameters}  coam.Get Parameters  ${smod_l_dn}
    ${smod_r_dn}  Get Module Dist Name By Serial Number And Class  ${smod_l_parameters}[serialNumber]  SMOD
    Set Test Variable  ${PRODUCT_NAME_SW_NODE_CRASH}  ${smod_l_parameters}[productName]
    Set Test Variable  ${SERIAL_NUMBER_SW_NODE_CRASH}  ${smod_l_parameters}[serialNumber]
    Set Test Variable  ${PRODUCT_CODE_SW_NODE_CRASH}  ${smod_l_parameters}[productCode]
    Set Unit Position For Fault Signature  ${smod_r_dn}
    Set Test Variable  ${CORE_UNIT_POSITION_SW_NODE_CRASH}  ${CORE_UNIT_POSITION}
    Set Test Variable  ${UNIT_POSITION_SW_NODE_CRASH}  ${UNIT_POSITION}


Choose Central CPlane Software Node
    ${ccp_nodes}  Create List
    ${sw_nodes_list}  coam.Get Managed Objects  SW_NODE_L
    FOR  ${sw_node}  IN  @{sw_nodes_list}
        IF  '${sw_node}[parameters][rat]'=='WCDMA' and '${sw_node}[parameters][applicationGroup]'=='CentralCPlane'
            Append To List  ${ccp_nodes}  ${sw_node}
        END
    END
    ${random_sw_node}  Evaluate  random.choice(${ccp_nodes})  random
    Set Test Variable  ${SW_NODE_FOR_CRASH}  ${random_sw_node}


Crash Central CPlane Software Node
    [Arguments]  ${sw_node_id}  ${sw_node_dist_name}

    ${bts_l_dn}  Fetch From Left  ${sw_node_dist_name}  /EQM
    ${bts_l_parameters}  coam. Get Parameters  ${bts_l_dn}
    Open Connection To Primary Core
    IF  'Idle' in '${bts_l_parameters}[storedRole]'  Open Connection To Secondary Core
    SSHLibrary.Write  lxc-attach -n ${sw_node_id} ps aux | grep btssw
    ${lxc_attach_output}  SSHLibrary.Read Until Prompt
    ${matches}  Get Regexp Matches  ${lxc_attach_output}  btssw\\s+\\d+
    ${random_match}  Evaluate  random.choice(${matches})  random
    ${words}  Split String  ${random_match}
    ${process_id}  Get From List  ${words}  1
    SSHLibrary.Write  lxc-attach -n ${sw_node_id} -- kill -9 ${process_id}
    SSHLibrary.Read Until Prompt

    [Teardown]  SSHLibrary.Close All Connections


Verify Parameters For DSP L Object
    [Arguments]  ${dsp_parameters}
    Should Contain  ${ENABLED}
    ...             ${dsp_parameters}[stateInfo][operationalState]
    ...             msg=Operational state is not ${ENABLED}.
    Should Contain  ${ONLINE}
    ...             ${dsp_parameters}[stateInfo][availabilityStatus]
    ...             msg=Availability status is not ${ONLINE}.
    Should Contain  ${ROUTING_LOADED}
    ...             ${dsp_parameters}[stateInfo][proceduralState]
    ...             msg=Procedural state is not ${ROUTING_LOADED}.
    Log  DSP L object parameters are verified. [OK]  console=true


TC Setup
    Common Test Setup  tc_name=FM__RAT_reset_counter_exceeded_multi_RAT
    Setup NetAct


TC Teardown
    Change Parameter ActForce(Unit)AutoReset To False
    IF  '${ENB_BRANCH}' >= 'SBTS24R3'  Run Keyword If Test Failed  Change FMCADM parameter  actAlarmOfRatOutage  false
    Run Keyword If Test Failed  Recovery Action If Test Fails
    Teardown NetAct
    Common Test Teardown