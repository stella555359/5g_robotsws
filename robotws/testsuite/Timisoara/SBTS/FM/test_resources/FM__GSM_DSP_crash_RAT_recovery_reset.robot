*** Settings ***
Documentation
    ...  This test case is created to verify the GSM RAT reset functionality introduced by RP001610/RP001334.
    ...  GSM RAT reset is proveked by crashing the DSP core associated with GSM RAT.
    ...  The crash will be performed by running a command: rioboot -c write -a 0x128FFFFF -f echo 0xFFFF <node_id>.
    ...  DSP and its core ID will be choosen randomly from the pool of all aviable DSP's.
    ...  Recovery action will be tested by checking appearence of alarm 7101 'BASE STATION/UNIT AUTONOMOUS RESET NOTIFICATION'
    ...  with fault ID 6707/6708/6709/4019.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  900  # Timeout for alarm reporting in WebEM
${NETACT_TIMEOUT}  300  # Timeout for alarm reporting in Netact
${RECOVERY_TIMEOUT}  360  # Timeout for SBTS to recover after RAT reset
${STARTUP_TIMEOUT}  600  # Timeout for SBTS to recover after site reset


*** Keywords ***
TC__FM__GSM_DSP_crash_RAT_recovery_reset
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-15717
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  10.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-15717 - Initial TAT creation
    ...  28.05.2019 - https://jira3.int.net.nokia.com/browse/TAT-16401 - Timeouts for alarm 7101 assertion (activation and deactivation) increased
    ...  06.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-16444 - Infomodel restart after site reset implementation
    ...  28.06.2019 - https://jira3.int.net.nokia.com/browse/TAT-16740 - Change the way of historical alarms verification
    ...  14.01.2020 - https://jira3.int.net.nokia.com/browse/TAT-18478 - Test case adaptation for missing ${entity.variant}
    ...  26.08.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20122 - Modify assign variable to cores for Airscale+FSMF configurations
    ...  27.08.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21633 - FastPass improvement - add Netact check in different scenarios
    ...  10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  01.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22577 - ta_netact_* libary replacement with taf.nms.netact
    ...  28.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23842 - Remove Test Specific Teardown and Setup
    ...  14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  30.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24827 - Wrong formatting of variables
    ...  12.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25140 - Test fail since test does not wait enough to occur for fault
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  13.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26594 - GSM_DSP_crash_RAT_recovery_reset fail to check the fid 6707
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26898 - Variable not found
    ...  13.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26919 - Update parameters for assert alarm
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  01.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27105 - Update alarm checking
    ...  26.06.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27704 - Add option to skip RMOD power check
    ...  10.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27763 - Raise FID 4753 and check it's appearance
    ...  13.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27947 - Check FID 4753 only for newer releases
    ...  21.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27965 - Block cells that are on air
    ...  29.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28007 - Add keyword perform site reset
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  27.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-27812 - Update TC to work on ASIL/ASIM/ASOG system module
    ...  16.05.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28442 - Verification of fault signature scope field for FM test cases
    ...  19.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29381 - Changes to send crash on Flexi DSP
    ...  19.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29766 - Added core variables for fault signature
    ...  *******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-marcin.skop@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS19A  FEATURE-RP001610  FEATURE-RP001334

    Step0: Change ActAlarmOfRatOutage Parameter And Perform Site Reset
    Step1: Check All Required States
    Step2: Trigger DSP Crash
    Step3: Trigger DSP Crash
    Step4: Trigger DSP Crash
    Step5: Trigger DSP Crash For The Last Time And Verify Critical Fault Appearance
    Step6: Wait 11 Minutes And Verify Fault 4753


Step0: Change ActAlarmOfRatOutage Parameter And Perform Site Reset
    [Documentation]  In this step actAlarmOfRatOutage parameter will be set to true and
    ...  Site Reset will be performed to clear all recovery reset counters.
    ...  Test Case will be continued if BTS will reach desired state otherwise, test will fail.

    Log  \nStep0: Change actAlarmOfRatOutage parameter and perform site reset.  console=true
    IF  '${ENB_BRANCH}' >= 'SBTS24R3'  Change FMCADM parameter  actAlarmOfRatOutage  true
    Perform Site Reset
    ${ims_path}  Set Variable  ${BTS_FILES}/IM/InfoModel_log_before_IM_restart.ims2
    Save The Log And Restart Infomodel  ${ims_path}


Step1: Check All Required States
    [Documentation]  In this step user input and specific states will be checked.

    Log  \nStep1: Check all required states.  console=true
    Check Commissioned Technologies  GSM
    ${all_tx_power_before_reset}  Create Dictionary
    Set Test Variable  ${ALL_TX_POWER_BEFORE_RESET}
    ${all_tx_power_after_reset}  Create Dictionary
    Set Test Variable  ${ALL_TX_POWER_AFTER_RESET}
    Get All Tx Power From All RMs  ${ALL_TX_POWER_BEFORE_RESET}

    Log  Check if actForceAutoReset value is true.  console=true
    Change FMCADM Parameter  actForceAutoReset  true
    Choose DSP For Crash  GSM
    ${fault_rat_auto_rst}  Copy Dictionary  ${FAULT_6707_RAT_AUTO_RST}
    Set To Dictionary  ${fault_rat_auto_rst}  fault_id=regex"6707|6708|6709|4019"
    ${6707_parameters}  Get String With Alarm Parameters  ${fault_rat_auto_rst}
    Set Test Variable  ${6707_PARAMETERS}
    IF  '${ENB_BRANCH}' < 'SBTS24R3'  RETURN
    ${fault_6707_fatal_err}  Copy Dictionary  ${FAULT_6707_DSP_APP_FATAL_ERR}
    ${6707_fatal_err_parameters}  Get String With Alarm Parameters  ${fault_6707_fatal_err}
    Set Test Variable  ${6707_FATAL_ERR_PARAMETERS}
    ${fault_service_out}  Copy Dictionary  ${FAULT_4753}
    ${4753_parameters}  Get String With Alarm Parameters  ${fault_service_out}
    Set Test Variable  ${4753_PARAMETERS}
    Set Fault Signature Variables


Step${index}: Trigger DSP Crash
    [Documentation]  In this step DSP crash will be performed and recovery action will be checked.

    Log  \nStep${index}: Trigger DSP crash.  console=true
    ${date_netact}  Get Current Date  time_zone=UTC  result_format=datetime
    Log  Connect to SMOD via ssh and trigger crash.  console=true
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=checkActiveFault
    ${check_active_fault}  Run Keyword In Background  Assert Alarm Active  parameters=${6707_PARAMETERS}  timeout=${ALARM_TIMEOUT}
    ...  alias=checkActiveFault
    Verify SMOD Type And Trigger DSP Crash
    Log  Check FSP states:  console=true
    ${fsp_dist_name}  Fetch From Left  ${CORE_ID.dist_name}  /POWER_GROUP_L-
    ${fsp}  Create Dictionary  dist_name=${fsp_dist_name}
    ${fsp_list}  Create List
    Append To List  ${fsp_list}  ${fsp}
    ${fsp_status}  Verify Parameters  ${fsp_list}  .stateInfo  operationalState=Enabled  availabilityStatus=Degraded

    Log  Check SMOD states:  console=true
    ${smod_status}  Assert Every  SMOD  operationalState=${ENABLED}
    Log  Check if recovery reset indicator is visible:  console=true
    ${recovery_reset}  Run Keyword And Return Status  Query Infomodel  get list //RECOVERY_RESET_IND-*  timeout=300
    IF  ${recovery_reset}
        Log  Recovery Reset Indication is visible under FRI. [OK]  console=true
    ELSE
        Set Test Restriction  Recovery Reset Indication is not visible under FRI. [NOK]
    END

    Log  Check if alarm is present:  console=true
    ${fault_status}  Collect Keyword Result  ${check_active_fault}  timeout=${ALARM_TIMEOUT}
    IF  ${fault_status}
        Log  Fault ${FAULT_6707_RAT_AUTO_RST}[fault_name] is active. [OK]  console=true
    ELSE
        Fail  Fault ${FAULT_6707_RAT_AUTO_RST}[fault_name] is not visible. [NOK]
    END
    Run Keyword And Continue On Failure  Teardown Admin  alias=checkActiveFault
    Log  Check cells status:  console=true
    ${all_cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    Assert Alarm Inactive  parameters=${6707_PARAMETERS}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_6707_RAT_AUTO_RST}[fault_id] "${FAULT_6707_RAT_AUTO_RST}[fault_name]" - cleared from WebEM. [OK]  console=true

    Log  Check fault signature.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${EXPECTED_FAULT_ID}  category=${CATEGORY}  extra_info=${EXTRA_INFO}  info=${INFO}
    ...  load_name=${SW_VERSION}  minor=${MINOR}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${EXPECTED_FAULT_ID}  time_from=${date_netact}  category=CATEGORY:${SPACE}${CATEGORY}
    ...  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:${SPACE}${INFO}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}
    ...  minor=MINOR:${SPACE}${MINOR}  scope=SCOPE:${SPACE}${SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}


Step5: Trigger DSP Crash For The Last Time And Verify Critical Fault Appearance
    [Documentation]  In this step DSP crash will be performed and recovery action will be checked.

    Log  \nStep5: Trigger DSP crash for the last time. console=true
    IF  '${ENB_BRANCH}' < 'SBTS24R3'
        Log  Software branch is: ${ENB_BRANCH}. No need to run this step.  console=true
        RETURN
    END
    Log  Connect to SMOD via ssh and trigger crash.  console=true
    Open Connection To Primary Core
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=checkActiveFault
    Verify SMOD Type And Trigger DSP Crash
    ${fault_background}  Run Keyword In Background  Assert alarm active  parameters=${6707_FATAL_ERR_PARAMETERS}  timeout=${ALARM_TIMEOUT}
    ...  alias=checkActiveFault

    Log  Check FSP states:  console=true
    ${fsp_dist_name}  Fetch From Left  ${CORE_ID.dist_name}  /POWER_GROUP_L-
    ${fsp}  Create Dictionary  dist_name=${fsp_dist_name}
    ${fsp_list}  Create List
    Append To List  ${fsp_list}  ${fsp}
    ${fsp_status}  Verify Parameters  ${fsp_list}  .stateInfo  operationalState=Enabled  availabilityStatus=Degraded
    Log  Check SMOD states:  console=true
    ${smod_status}  Assert Every  SMOD  operationalState=${ENABLED}
    Log  Check if recovery reset indicator is visible:  console=true
    ${recovery_reset}  Run Keyword And Return Status  Query Infomodel  get list //RECOVERY_RESET_IND-*  timeout=300
    IF  ${recovery_reset}
        Log  Recovery Reset Indication is visible under FRI. [OK]  console=true
    ELSE
        Set Test Restriction  Recovery Reset Indication is not visible under FRI. [NOK]
    END

    ${fault_status_webem}  Run Keyword And Return Status  Collect Keyword Result  ${fault_background}  timeout=${ALARM_TIMEOUT}
    IF  ${fault_status_webem}
        Log  Fault ${FAULT_6707_DSP_APP_FATAL_ERR}[fault_id] "${FAULT_6707_DSP_APP_FATAL_ERR}[fault_name]" - reported in WebEM. [OK]  console=true
    ELSE
        Fail  Fault ${FAULT_6707_DSP_APP_FATAL_ERR}[fault_id] "${FAULT_6707_DSP_APP_FATAL_ERR}[fault_name]" - not reported in WebEM. [NOK]
    END
    Run Keyword And Continue On Failure  Teardown Admin  alias=checkActiveFault
    ${fault_status_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_6707_DSP_APP_FATAL_ERR}
    ...  additional_fault_id=${FAULT_6707_DSP_APP_FATAL_ERR}[fault_id]
    IF  ${fault_status_netact}
        Log  Fault ${FAULT_6707_DSP_APP_FATAL_ERR}[fault_id] - ${FAULT_6707_DSP_APP_FATAL_ERR}[fault_name] - reported in NetAct. [OK]  console=true
    ELSE
        Fail  Fault ${FAULT_6707_DSP_APP_FATAL_ERR}[fault_id] - ${FAULT_6707_DSP_APP_FATAL_ERR}[fault_name] - not reported in NetAct. [NOK]
    END


Step6: Wait 11 Minutes And Verify Fault 4753
    Log  \nStep6: Wait 11 minutes and verify fault 4753.  console=true
    ${bsc_infomodel}  Query Infomodel  get object //RAT-*/GTS-*/BSC-*
    ${bcf_infomodel}  Query Infomodel  get object //RAT-*/GTS-*/BSC-*/BCF-*
    ${bsc_id}  Fetch From Right  ${bsc_infomodel}[dist_name]  BSC-
    ${bcf_id}  Fetch From Right  ${bcf_infomodel}[dist_name]  BCF-
    IF  '${ENB_BRANCH}' < 'SBTS24R3'
        Log  Software branch is: ${ENB_BRANCH}. No need to run this step.  console=true
        RETURN
    END
    Block online cells for given RAT  gsm
    ${date_netact}  Get Current Date  time_zone=UTC  result_format=datetime
    Sleep  11 min  Wait for fault 4753 to appear.
    Assert Alarm Active  parameters=${4753_PARAMETERS}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4753}[fault_id] "${FAULT_4753}[fault_name]" - reported in WebEM. [OK]  console=true
    ${fault_status_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_4753}  additional_fault_id=${FAULT_4753}[fault_id]
    ...  dist_name=PLMN-PLMN/BSC-${bsc_id}/BCF-${bcf_id}
    IF  ${fault_status_netact}
        Log  Fault ${FAULT_4753}[fault_id] "${FAULT_4753}[fault_name]" - reported in NetAct. [OK]  console=true
    ELSE
        Fail  Fault ${FAULT_4753}[fault_id] "${FAULT_4753}[fault_name]" - not reported in NetAct. [NOK]
    END
    Change FMCADM Parameter  actAlarmOfRatOutage  false
    Assert Alarm Inactive  parameters=${4753_PARAMETERS}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_4753}[fault_id] "${FAULT_4753}[fault_name]" - cleared from WebEM. [OK]  console=true
    ${fault_status_netact}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4753}  time_from=${date_netact}
    ...  additional_fault_id=${FAULT_4753}[fault_id]  dist_name=PLMN-PLMN/BSC-${bsc_id}/BCF-${bcf_id}
    IF  ${fault_status_netact}
        Log  Fault ${FAULT_4753}[fault_id] "${FAULT_4753}[fault_name]" - reported & cleared from NetAct. [OK]  console=true
    ELSE
        Fail  Fault ${FAULT_4753}[fault_id] "${FAULT_4753}[fault_name]" - not reported in NetAct. [NOK]
    END


Save Infomodel Log For TC Checks
    [Documentation]
    ...  The purpose of this KW is to collect .ims2 file to verify if WCDMA and LTE cells remained unaffected during GSM RAT recovery reset.
    [Timeout]  5 min

    Log  Save Infomodel log for TC checks.  console=true
    Save Infomodel Log  ${BTS_FILES}/IM/InfoModel_log_after_recovery_reset.ims2
    Set Test Variable  ${IM_LOG_PATH}  ${BTS_FILES}/IM/InfoModel_log_after_recovery_reset.ims2
    Log  Infomodel log saved under ${IM_LOG_PATH}.  console=true


Set Fault Signature Variables
    Log  Setting variables for fault signature.  console=true
    ${dsp_node_id}  Get Substring  ${NODE_ID}  0  5
    Set Test Variable  ${MINOR}   ${dsp_node_id}
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
    Set Test Variable  ${PRODUCT_NAME}  ${module_parameters}[productName]
    Set Test Variable  ${SERIAL_NUMBER}  ${module_parameters}[serialNumber]
    Set Test Variable  ${PRODUCT_CODE}  ${module_parameters}[productCode]
    ${module_r_dn}  Get Runtime Object Dist_name From Logical Object Dist_name  ${module_l_dn}
    Set Unit Position For Fault Signature  ${module_r_dn}
    Set Test Variable  ${EXPECTED_FAULT_ID}  ${FAULT_6707_RAT_AUTO_RST}[fault_id]
    Set Test Variable  ${SCOPE}  GSM RAT
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${INFO}  .*FATAL EXCEPTION Nid:${MINOR}.*
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=GSM:[0-9]+.*(gracefully_shutdown_cells:[0-9]+)?


TC Setup
    Common Test Setup  tc_name=FM__GSM_DSP_crash_RAT_recovery_reset
    Setup NetAct


TC Teardown
    Change FMCADM Parameter  actForceAutoReset  false
    IF  '${ENB_BRANCH}' >= 'SBTS24R3'
      Run Keyword If Test Failed  Change FMCADM Parameter  actAlarmOfRatOutage  false
      Perform Site Reset
    END
    Teardown NetAct
    Common Test Teardown