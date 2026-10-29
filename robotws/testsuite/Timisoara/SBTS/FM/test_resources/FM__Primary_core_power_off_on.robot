*** Settings ***
Documentation
    ...  This test is created to check that Fault Signature is correctly returned after primary core power off/on.
    ...  Starting from 23R1 for all non-FSMF products, if actFaultSignature == 'true' the BTS shall send alarm
    ...  for fault 4590 EFaultId_CrashOrFailureSignatureAl enriched with fault signature after encountering an
    ...  unexpected reset due to power off and on of a system module.
    ...  Frozen in 22R4 for all products except FSMF, if actFaultSignature == 'true' the BTS shall enrich the alarm reported due to
    ...  fault 4592 EFaultId_BtsResetCauseAl with fault signature only after a BTS power reset (the fault cause is power-on reset due to power-off).

Library  DateTime
Library  ute_async
Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  1200  # [in seconds] Timeout for alarm to appear in WebEM
${NETACT_TIMEOUT}  120  # [in seconds] Timeout for alarm to appear in Netact


*** Keywords ***
TC__FM__Primary_core_power_off_on
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-19533
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  08.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19533 - Initial creation
    ...  26.05.2020 - https://jira3.int.net.nokia.com/browse/TAT-19626 - Update FM_Primary_core_power_off_on for single core
    ...  03.12.2020 - https://jira3.ext.net.nokia.com/browse/TAT-20343 - RP002956 SBTS Operability support for 5G
    ...  12.01.2021 - https://jira3.ext.net.nokia.com/browse/TAT-20726 - fault 4592 not detected by test Primary_Core_power_off_on
    ...  27.01.2021 - https://jira3.ext.net.nokia.com/browse/TAT-20794 - Keyword arguments fail for test Primary_Core_power_off_on
    ...  27.08.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21633 - FastPass improvement - add Netact check in different scenarios
    ...  10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  01.02.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22577 - ta_netact_* libary replacement with taf.nms.netact
    ...  28.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23842 - Remove Test Specific Teardown and Setup
    ...  14.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24111 - Migrate from hran_ssh to taf.transport.ssh
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  11.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25336 - Testcase has wrong unitPosition field in FaultSignature
    ...  31.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25478 - Update FM testcases for actFaultSignature
    ...  08.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25922 - Update test after requirements change
    ...  13.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26042 - Add check for systemTime
    ...  25.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26146 - Testcase fails at checking fault signature for 4590
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  16.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26711 - TC fails at checking fault name
    ...  08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26518 - Changing the checking of the component field in the fault signature
    ...  27.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27000 - Adapt the check of component field in the fault signature for 23R3/4
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  06.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26877 - Add new steps
    ...  21.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27160 - Keyword enhancement in resource file
    ...  15.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27107 - Add SW version check before powering off RMOD
    ...  17.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27606 - Multiple keywords for checking fault signature in FM testcases
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29190 - Enhancement of all test cases in regression to check fault signature
    ...  25.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29459 - Enhancement of all test cases in regression to check FS component field
    ...  19.09.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29766 - Added core variables for fault signature
    ...  21.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30161 - Adjust variables for the fault signature
    ...  11.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30527 - Updated the FID10 verification in WebEM
    ...  ******************

    Set Tags  CA-FM  OWNER-laura.craciunel@nokia.com  AUTHOR-bogdan.boldurean@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS20  FEATURE-RP001825

    Step0: Check All Required States
    Step1: Power Off Primary Core
    Step2: Power On Primary Core
    Step3: Power Off And On RMOD If Applicable
    Step4: Check Fault Signature
    Step5: Check States After Site Is Up


Step0: Check All Required States
    [Documentation]  In this step specific states will be checked.

    Log  Step0: Check all required states.  console=true
    Set SMOD Variables For Fault Signature Check
    Set Random RMOD Information
    Set ActFaultSignature Value  true
    ${date}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${date}
    ${status_ecpri}  Check l3Protocol For Given RMOD Type  ${RMOD_PRODUCT_NAME}  .*(ecpri|eCPRI|ECPRI).*
    IF  ${status_ecpri}
        ${transceiver_identifier}  Get Sfp Transceiver Identifier For Radio Module  ${RMOD_R_DN}
        ${suppl_alarm_info_text}  Catenate  RU not detected after BTS startup\.(?:.*?
        ...  SFP type is ${transceiver_identifier},\\s*Protocol is eCPRI\.)?
        Set Test Variable  ${SUPPL_ALARM_INFO}  ${suppl_alarm_info_text}
    ELSE
        ${suppl_alarm_info_text}  Catenate  RU not detected after BTS startup\.
        Set Test Variable  ${SUPPL_ALARM_INFO}  ${suppl_alarm_info_text}
    END


Step1: Power Off Primary Core
    [Documentation]  Turn off Primary core and check for core to not be reachable.

    Log  Step1: Power off primary core.  console=true
    Set Test Variable  ${SMOD_IF}  SMOD_${SERIAL_NUMBER}
    Pdu BTS Interface Off  ${SMOD_IF}
    Sleep  5
    ${ping_loss_status}  Run Keyword And Return Status  Wait For Target To Be Not Reachable  hostname=${OAM_BTS_IP}  timeout=300
    IF  ${ping_loss_status}==${FALSE}
        Set Test Restriction  Ping has not been lost within timeout.
    ELSE
        Log  Ping to primary core is lost.  console=true
    END
    Sleep  60s  Wait a minute to make sure the site reset happens.


Step2: Power On Primary Core
    [Documentation]  Turn off Primary core and check for core to be reachable.

    Log  Step2: Power on primary core.  console=true
    Log  Wait for primary core to be reachable.  console=true
    Pdu BTS Interface On  ${SMOD_IF}
    ${ping_up_status}  Run Keyword And Return Status  Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=300
    IF  ${ping_up_status}==${FALSE}
        Set Test Restriction  Ping has not been regained within timeout.
    ELSE
        Log  Primary core is back online.  console=true
    END
    Sleep  60s  Wait a minute for the SBTS connections to become available.


Step3: Power Off And On RMOD If Applicable
    [Documentation]  Perform power off/on on radio module.

    Log  Step3: Power off and on RMOD if applicable.  console=true
    IF  '${ENB_BRANCH}' >= 'SBTS24R2'
        Performing Power Off And On RMOD
    ELSE
        Log  This step will not be continued because the SW version is not greater than SBTS24R2 or equal with SBTS24R2.  console=true
    END


Step4: Check Fault Signature
    [Documentation]  In this step fault signature is check for the correct values.

    Log  Step4: Check fault signature.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${EXPECTED_FAULT}[fault_id]  category=${EXPECTED_CATEGORY}  info=${EXPECTED_INFO}
    ...  load_name=${SW_VERSION}  reset_counter=${RESET_COUNTER}  scope=${EXPECTED_SCOPE}  full_product_name=${PRODUCT_NAME}
    ...  serial_number=${SERIAL_NUMBER}  core_serial_number=${CORE_SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}
    ...  core_vendor_unit_number=${CORE_PRODUCT_CODE}  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}
    Check Fault Signature Of Alarm In Netact  fault_id=${EXPECTED_FAULT}[fault_id]  category=CATEGORY:${SPACE}${EXPECTED_CATEGORY}
    ...  info=INFO:${SPACE}${EXPECTED_INFO}  load_name=LOAD_NAME:${SPACE}${SW_VERSION}  reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}
    ...  scope=SCOPE:${SPACE}${EXPECTED_SCOPE}  full_product_name=${PRODUCT_NAME}  serial_number=${SERIAL_NUMBER}
    ...  core_serial_number=${CORE_SERIAL_NUMBER}  vendor_unit_number=${PRODUCT_CODE}  core_vendor_unit_number=${CORE_PRODUCT_CODE}
    ...  unit_position=${UNIT_POSITION}  core_unit_position=${CORE_UNIT_POSITION}  time_from=${START_TIME}


Step5: Check States After Site Is Up
    [Documentation]  Check of states on RMODs and cells.

    Log  Step5: Check states after site is up.  console=true
    ${rmods}  Run Keyword And Return Status  Wait Until Keyword Succeeds  600s  10s  Assert Every  RMOD  operationalState=${ENABLED}  timeout=60
    IF  ${rmods}
        Log  All rmods are operationalState=enabled - recovery succedeed. [OK]  console=true
    ELSE
        Fail  Some rmods statuses are wrong - recovery failed. [NOK]
    END
    ${cells}  Run Keyword And Return Status  Wait Until Keyword Succeeds  300s  10s  Check All Cells
    IF  ${cells}
        Log  All cells are in working state. [OK]  console=true
    ELSE
        Fail  Some cells are NOT in working state - recovery failed. [NOK]
    END
    ${alarm_status}  Run Keyword And Return Status  Assert Alarm Inactive  faultId=${EXPECTED_FAULT}[fault_id]
    IF  ${alarm_status}
        Log  Fault ${EXPECTED_FAULT}[fault_id] is cleared.  console=true
    ELSE
        Fail  Fault ${EXPECTED_FAULT}[fault_id] did not cleared.
    END
    ${historical_alarms}  coam.Get Historic Alarms
    FOR  ${alarm}  IN  @{historical_alarms}
        ${status_fault_id}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[faultId]  ${EXPECTED_FAULT}[fault_id]
        ${alarm_webem}  Set Variable If  ${status_fault_id}  ${alarm}
        IF  ${status_fault_id}  BREAK
    END
    ${default_system_time}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm_webem}[systemTime]  Default System Time
    ${string}  Catenate  SEPARATOR=;  ${EXPECTED_FAULT}[fault_name]  Default System Time
    ${fault_name_string}  Set Variable If  ${default_system_time}  ${string}  ${EXPECTED_FAULT}[fault_name]
    ${alarm_parameters_dict}  Set To Dictionary  ${EXPECTED_FAULT}  fault_name=${fault_name_string}
    ${check_fault_na}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{alarm_parameters_dict}  time_from=${START_TIME}
    ...  additional_fault_id=${expected_fault}[fault_id]
    IF  ${check_fault_na}
        Log  Given alarm and fault fields are correct in NA, alarm is cleared in NA [OK].  console=true
    ELSE
        Fail  Given alarm and fault fields are incorrect in NA or alarm is missing in NA [NOK].
    END


Set SMOD Variables For Fault Signature Check
    ${smods_list}  Get Fsm Info
    FOR  ${smod}  IN  @{smods_list}
       ${status_active_role}  Run Keyword And Return Status  Should Not Be Empty  ${smod}[activeRole]
       IF  ${status_active_role}==${FALSE}  BREAK
       IF  '${smod}[activeRole]' == 'Primary'  BREAK
    END
    Set Test Variable  ${SERIAL_NUMBER}  ${smod}[serialNumber]
    ${smod_r_dn}  Set Variable  ${smod}[id][internal]
    Set Test Variable  ${PRODUCT_NAME}  ${smod}[productName]
    Set Unit Position For Fault Signature  ${smod_r_dn}
    ${smod_l_parameters}  coam.Get Parameters  ${smod_r_dn}
    Set Test Variable  ${PRODUCT_CODE}  ${smod_l_parameters}[productCode]
    Set Test Variable  ${CORE_SERIAL_NUMBER}  ${smod_l_parameters}[coreHwBoardSerialNumber]
    Set Test Variable  ${CORE_PRODUCT_CODE}  ${smod_l_parameters}[coreHwBoardProductCode]
    ${check_fsmf}  Run Keyword And Return Status  Should Contain  ${PRODUCT_NAME}  FSMF
    ${expected_fault}  Set Variable If  '${ENB_BRANCH}' >= 'SBTS23R1' or '${check_fsmf}' == 'False'  ${FAULT_4590}  ${FAULT_4592}
    ${expected_info}  Set Variable If  '${ENB_BRANCH}' >= 'SBTS23R1' or '${check_fsmf}' == 'False'
    ...  Unknown power reset. Possible causes e.g. HW watchdog or external power off/on cycle  Power off/on reset
    Set Test Variable  ${EXPECTED_FAULT}
    Set Test Variable  ${EXPECTED_INFO}
    Set Test Variable  ${EXPECTED_SCOPE}  Site
    Set Test Variable  ${RESET_COUNTER}  [0-9]+
    Set Test Variable  ${EXPECTED_CATEGORY}  POWER_OFF


Set Random RMOD Information
    ${list_rmods}  Get Parameters For All  RMOD
    FOR  ${rmod}  IN  @{list_rmods}
        IF  '${rmod}[productName]'=='AEHC'
            Remove Values From List  ${list_rmods}  ${rmod}
        ELSE
            CONTINUE
        END
    END
    ${lenght_list}  Get Length  ${list_rmods}
    ${random_rmod_index}  Evaluate  random.randint(0,${lenght_list}-1)  random
    Set Test Variable  ${RMOD_SN}  ${list_rmods}[${random_rmod_index}][serialNumber]
    Set Test Variable  ${RMOD_R_DN}  ${list_rmods}[${random_rmod_index}][id]
    Set Test Variable  ${RMOD_PRODUCT_NAME}  ${list_rmods}[${random_rmod_index}][productName]


Performing Power Off And On RMOD
    Log  Power off will be performed.  console=true
    Log  Serial number of RMOD is ${RMOD_SN}.  console=true
    Pdu BTS Interface Off  RMOD_${RMOD_SN}
    Log  Waiting for alarm "${FAULT_10_CRITICAL}[fault_name]" to be visible in WebEM.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  30s  Verify FID 10 To Be Active In WebEM
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_10_CRITICAL}  suppl_info=${SUPPL_ALARM_INFO}
    ...  additional_fault_id=${FAULT_10_CRITICAL}[fault_id]

    ${status_disabled}  Run Keyword And Return Status  Assert  RMOD  ${RMOD_R_DN}  operationalState=${DISABLED}
    IF  ${status_disabled}
        Log  RMOD with dist_name ${RMOD_R_DN} is disabled. [OK]  console=true
    ELSE
        Fail  RMOD with dist_name ${RMOD_R_DN} is not disabled. [NOK]
    END

    Log  Power on RMOD will be performed.  console=true
    Pdu BTS Interface On  RMOD_${RMOD_SN}
    ${status_enabled}  Run Keyword And Return Status  Assert  RMOD  ${RMOD_R_DN}  operationalState=${ENABLED}  timeout=300
    IF  ${status_enabled}
        Log  RMOD with dist_name ${RMOD_R_DN} is enabled. [OK]  console=true
    ELSE
        Fail  RMOD with dist_name ${RMOD_R_DN} is not enabled. [NOK]
    END


Verify FID 10 To Be Active In WebEM
    ${active_alarms}  coam.Get Active Alarms
    FOR  ${alarm}  IN  @{active_alarms}
        ${alarm_suppl_info}  Set Variable  ${alarm}[alarmText][alarmAdditionalInfo][supplAlarmInfo]
        ${status_fault_name}  Run Keyword And Return Status  Should Be Equal As Strings  ${alarm}[faultName]  ${FAULT_10_CRITICAL}[fault_name]
        ${status_suppl_alarm_info}  Run Keyword And Return Status  Should Match Regexp  ${alarm_suppl_info}  ${SUPPL_ALARM_INFO}
        IF  ${status_fault_name} and ${status_suppl_alarm_info}
            Log  Alarm ${FAULT_10_CRITICAL} with suppl alarm info '${SUPPL_ALARM_INFO}' is active in WebEM.  console=true
            RETURN
        END
    END
    Fail  Alarm ${FAULT_10_CRITICAL} with suppl alarm info '${SUPPL_ALARM_INFO}' is not active in WebEM.


Recovery Actions
    ${ping_up_status}  Run Keyword And Return Status  Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=300
    IF  ${ping_up_status}==${FALSE}
        Log  Ping on primary core is not ok.  console=true
        Pdu BTS Interface On  ${SMOD_IF}
    ELSE
        Log  Primary core is online. [OK]  console=true
    END
    ${status_rmod}  Run Keyword And Return Status  Assert  RMOD  ${RMOD_R_DN}  operationalState=${DISABLED}
    IF  ${status_rmod}
        Log  RMOD is not in the right state.  console=true
        Pdu BTS Interface On  RMOD_${RMOD_SN}
    ELSE
        Log  RMOD is ${ENABLED}. [OK]  console=true
    END


TC Setup
    Common Test Setup  tc_name=FM__Primary_core_power_off_on
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed
    ...  Run Keywords
    ...  Recovery Actions
    ...  AND
    ...  Step5: Check States After Site Is Up
    Teardown NetAct
    Common Test Teardown
