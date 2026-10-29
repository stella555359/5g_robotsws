*** Settings ***
Documentation
    ...  This test case is created to trigger LTE DSP crash and expect fault signature information.
    ...  It will be done by creating data.dat file by running command echo 0xFFFF >tmp/data.dat.
    ...  Than crashing DSP will be performed by running command: rioboot -c write -a 0x128FFFFF -f /tmp/data.dat <node_id>.
    ...  LTE DSP and CoreId will be choosen randomly from the pool of all LTE aviable DSP's.
    ...  Recovery action will be tested by checking faultID 6707/6708/6709 with alarmId=7101 is showing the correct fault signature information.

Library  ute_async
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  600  # [in seconds] Timeout for SBTS startup after site reset
${RECOVERY_TIMEOUT}  240  # [in seconds] Timeout for SBTS to recover
${ALARM_TIMEOUT}  660  # [in seconds] Timeout for alarm reporting in WebEM
${NETACT_TIMEOUT}  120  # [in seconds] Timeout for alarm to appear in Netact


*** Keywords ***
TC__FM__LTE_DSP_reset_actForceUnitAutoReset_false_faulty_cells_6709
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-19430
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19430 - Initial TAT creation
    ...  - 02.06.2020 - https://jira3.ext.net.nokia.com/browse/TAT-19639 - Fix for multiple failed LTE cells
    ...  - 31.03.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21122 - Checking based on lcrId id of the LTE cells affected by crash
    ...  - 23.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21227 - Modify how to get LTE DSPs dist names
    ...  - 17.08.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21635 - Implement new method of choosing DSP for crash based on DSPs in BBPOOL_L-*
    ...  - 24.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 28.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22643 - Fix for extraInfo fault signature
    ...  - 14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  - 17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  - 12.04.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25140 - Test fail since test does not wait enough for fault to occur
    ...  - 31.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25478 - Update FM testcases for actFaultSignature
    ...  - 05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  - 17.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27606 - Multiple keywords for checking fault signature in FM testcases
    ...  - 30.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27860 - Add setup and teardown for Netact
    ...  - 31.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27863 - Update extra info string for fault signature check
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  - 05.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28314 - Bug fix for TAT-28314
    ...  - 15.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27608 - Add check for fault signature
    ...  - 22.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28639 - Test fails when checking lcr ids
    ...  - 20.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28776 - Add BBMOD connection when required
    ...  - 16.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29638 - Test fails when ABIA is not connected on primary core
    ...  - 11.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30191 - Added one more DSP crash
    ...  ******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-bogdan.boldurean@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS20  FEATURE-RP001825

    Step0: Check All Required States
    Step1: Perform Site Reset
    Step2: Trigger DSP Crash On LTE DSP
    Step3: Trigger DSP Crash On LTE DSP
    Step4: Check Fault Signature
    Step5: Verify SBTS After Recovery


Step0: Check All Required States
    Log  \nStep0: Check all required states.  console=true
    Check Commissioned Technologies  LTE
    Choose DSP For Crash  LTE
    Set ActFaultSignature Value  true
    Set Variable For Fault Signature Check
    ${date}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${date}


Step1: Perform Site Reset
    Log  \nStep1: Site reset will be performed to clear all counters.  console=true
    Perform Site Reset


Step${index}: Trigger DSP Crash On LTE DSP
    Log  \nStep${index}: Trigger DSP crash on LTE DSP.  console=true
    ${ims_path}  Set Variable  ${BTS_FILES}/IM/InfoModel_log_before_IM_restart.ims2
    Save The Log And Restart Infomodel  ${ims_path}
    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=check_alarm
    IF  '${index}' == '2'
        ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_6707_DSP_GROUP_AUTO_RST}
        ${alarm_dict}  Set Variable  ${FAULT_6707_DSP_GROUP_AUTO_RST}
    ELSE
        ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_6707_DSP_APP_FATAL_ERR}
        ${alarm_dict}  Set Variable  ${FAULT_6707_DSP_APP_FATAL_ERR}
    END
    ${alarm_web_em}  Run Keyword In Background  Assert alarm active  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}  alias=check_alarm
    Verify SMOD Type And Trigger DSP Crash
    ${string_lcr_ids}  Get Matching Lcr Ids String For Checking Extra Info Field In Fault Signature
    Set Test Variable  ${EXTRA_INFO}  faulty_cells=LTE:${string_lcr_ids}

    ${check_alarm_webem}  Collect Keyword Result  ${alarm_web_em}  timeout=${ALARM_TIMEOUT}
    IF  ${check_alarm_webem}
        Log  Fault ${alarm_dict}[fault_id] - ${alarm_dict}[fault_name] was active in WebEm. [OK]  console=true
    ELSE
        Fail  Fault ${alarm_dict}[fault_id] - ${alarm_dict}[fault_name] was not active in WebEm. [NOK]
    END

    IF  '${index}' == '2'
        Assert Alarm Inactive  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
        ${check_fault_na}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10
        ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{alarm_dict}  time_from=${START_TIME}
        ...  additional_fault_id=${alarm_dict}[fault_id]
        Log  Fault is ${alarm_parameters} inactive.  console=true
    ELSE
        Assert  BBMOD  ${BBMOD_R_DN}  parameters=availabilityStatus=${DEGRADED}  timeout=120s
        Log  BBMOD is in the right state: degraded. [OK]  console=true
    END

    [Teardown]  Teardown Admin  alias=check_alarm


Step4: Check Fault Signature
    Log  \nStep4: Check fault signature.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_6707_DSP_GROUP_AUTO_RST}[fault_id]  category=${CATEGORY}  extra_info=${EXTRA_INFO}
    ...  info=${INFO}  load_name=${SW_VERSION}  reset_counter=${RESET_COUNTER}  scope=${SCOPE}  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_6707_DSP_GROUP_AUTO_RST}[fault_id]  time_from=${START_TIME}
    ...  category=CATEGORY:${SPACE}${CATEGORY}  extra_info=EXTRA_INFO:${SPACE}${EXTRA_INFO}  info=INFO:.*${INFO}.*
    ...  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}  scope=SCOPE:${SPACE}${SCOPE}
    ...  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  unit_position=${UNIT_POSITION}


Step5: Verify SBTS After Recovery
    Log  \nStep5: Verify SBTS after recovery.  console=true
    ${im_log_path}  Set Variable  ${BTS_FILES}/IM/InfoModel_log_after_recovery_reset.ims2
    Save Infomodel Log  ${im_log_path}
    Log  Check if cells status from other RATs remained unchanged.  console=true
    IF  ${SCF_COUNT_GSM}  Infomodel Check If Cells In RAT Were Operational According To IM Log  GSM  ${im_log_path}
    IF  ${SCF_COUNT_WCDMA}  Infomodel Check If Cells In RAT Were Operational According To IM Log  WCDMA  ${im_log_path}
    Perform Site Reset
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_6707_DSP_APP_FATAL_ERR}
    ${alarm_cleared}  Run Keyword And Return Status
    ...  Assert Alarm Inactive  parameters=${alarm_parameters}  timeout=${ALARM_TIMEOUT}
    IF  ${alarm_cleared}
        Log  Alarm 7101 "${FAULT_6707_DSP_APP_FATAL_ERR}[fault_name]" is cleared after recovery action. [OK]  console=true
    ELSE
        Fail  msg=Alarm 7101 "${FAULT_6707_DSP_APP_FATAL_ERR}[fault_name]" is still visible after recovery action. [NOK]
    END
    Admin Check Active Alarms TAF


Set Variable For Fault Signature Check
    ${bbmod_l_dn}  Fetch From Left  ${CORE_DN}  /BBU_L-
    ${bbmod_r_dn}  Get Runtime Object Dist_name From Logical Object Dist_name  ${bbmod_l_dn}
    ${bbmod_parameters}  coam.Get Parameters  ${bbmod_r_dn}
    Set Unit Position For Fault Signature  ${bbmod_r_dn}
    Set Test Variable  ${BBMOD_R_DN}  ${bbmod_r_dn}
    Set Test Variable  ${PRODUCT_NAME}  ${bbmod_parameters}[productName]
    Set Test Variable  ${PRODUCT_CODE}  ${bbmod_parameters}[productCode]
    Set Test Variable  ${SERIAL_NUMBER}  ${bbmod_parameters}[serialNumber]
    Set Test Variable  ${SCOPE}  DSP group
    Set Test Variable  ${CATEGORY}  SW_FAILURE
    Set Test Variable  ${RESET_COUNTER}  [0-9]+
    ${dsp_node_id}  Get Substring  ${NODE_ID}  0  5
    Set Test Variable  ${INFO}  .*FATAL EXCEPTION.*${dsp_node_id}.*


Get Matching Lcr Ids String For Checking Extra Info Field In Fault Signature
    [Documentation]  Keyword will query infomodel to get failed cells after DSP crash.
    ...  For each cell LCR id will be saved. LCR IDs list will be sorted. Based on LCR IDs, string for checking extra info will be constructed.
    ...  Extra info field e.g : faulty_cells=LTE:10,2,3,4,5,6,7,8
    ...  *AUTHOR* laura.craciunel@nokia.com

    ${lcr_ids}  Create List
    ${failed_cells}  Query Infomodel  get list //LNBTS_M-1/CELL_M-* is [stateInfo.availabilityStatus=Failed]  timeout=600
    FOR  ${cell}  IN  @{failed_cells}
        ${cell_dn_ref}  Query Infomodel  get object ${cell}[dist_name]/REF-1
        ${cell_dn}  Query Infomodel  get object ${cell_dn_ref}[distName]
        Append To List  ${lcr_ids}  ${cell_dn}[lcrId]
    END
    Sort List  ${lcr_ids}
    ${sorted_lcrs_list}  Sort Lcr Ids list For Extra Info Field  ${lcr_ids}
    ${string}  Set Variable  ${EMPTY}
    FOR  ${id}  IN  @{sorted_lcrs_list}
        ${string}  Catenate  SEPARATOR=,  ${string}  ${id}
    END
    ${string_lcr_ids}  Get Substring  ${string}  1
    Log  LCR IDs of cells are ${string_lcr_ids}  console=true

    [Return]  ${string_lcr_ids}


TC Setup
    Common Test Setup  tc_name=FM__LTE_DSP_reset_actForceUnitAutoReset_false_6709
    Setup Netact


TC Teardown
    Teardown Netact
    Common Test Teardown
