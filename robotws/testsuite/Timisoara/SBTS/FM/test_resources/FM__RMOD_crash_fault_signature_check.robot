*** Settings ***
Documentation
    ...  This test case is created to perform power off/on operation on AEQE RMODs and to verify fault 4589
    ...  First, actFaultSignature is set to true and SBTS is verified to be on air
    ...  RMOD is switched off and then back on, and fault signature is verified
    ...  Last, alarm with fault 4589 is verified in NetAct

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${RMOD_TYPE}  AENB  # Radio module type for test
${ALARM_TIMEOUT}  1200  # [in seconds] Timeout for alarm to appear in WebEm
${NETACT_TIMEOUT}  300  # [in seconds] Timeout for alarm to appear in Netact
${RECOVERY_TIMEOUT}  600  # [in seconds] Timeout for SBTS to recover after power off on


*** Keywords ***
FM__RMOD_crash_fault_signature_check
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-23691
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  16.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23691 - Initial TAT creation
    ...  28.10.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23931 - Move keywords to resource file
    ...  08.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24056 - "RMOD_check_fault_signature" failed at Check fault signature step
    ...  17.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24955 - FM files refactor to robotws standard
    ...  31.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25478 - Update FM testcases for actFaultSignature
    ...  28.06.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25298 - Incresed timeout value and added parameter
    ...  15.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25658 - Create new resources for NetAct and ONAP KWs
    ...  01.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26055 - Add supplementary alarm info check
    ...  13.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26588 - Remove supplementary alarm info check
    ...  05.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26813 - Refactor FM testcase for assert alarm active parameters
    ...  19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  07.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26872 - Add new steps
    ...  27.03.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27173 - Update fault checking
    ...  17.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27606 - Multiple keywords for checking fault signature in FM testcases
    ...  30.08.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28027 - Add check for 4241-4247 faults in Raw Alarm History
    ...  31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  07.11.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28341 - Test fails when checking fault in rawAlarmHistory
    ...  21.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28360 - Enhancement for eCPRI RMODS - not checking faults 4242-4247
    ...  31.07.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29602 - Supplementary alarm changes for certain RMODs from 26R1 onwards
    ...  22.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29716 - Extracted serial number variable for RMOD
    ...  10.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30033 - Test fails when checking suppAlarmInfo for fid 10
    ...  15.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30307 - Correcting the space indicator from suppl alarm info regexp
    ...  ******************

    Set Tags  CA-FM  OWNER-delia.nacov@nokia.com  AUTHOR-anna.benzar@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT

    Step1: Change ActFaultSignature Parameter Value
    Step2: Performing Power Off/on On Radio Module And Verify Alarm Presence
    Step3: Check Fault Signature Of Fault 4589
    Step4: Verify Faults Presence In RawAlarmHistory File


Step1: Change ActFaultSignature Parameter Value
    Log  \nStep1: Change actFaultSignature parameter value.  console=true
    Set ActFaultSignature Value  true
    Set Test Variable  ${EXPECTED_SCOPE}  RFM
    Set Test Variable  ${CATEGORY}  POWER_OFF
    Set Test Variable  ${RESET_COUNTER}  [0-9]+
    ${current_date_time_raw}  Get BTS time in UTC format  %Y-%b-%d %H:%M:%S
    Set Test Variable  ${CURRENT_DATE_TIME_RAW}
    ${expected_faults_raw}  Create List  4241  4242  4243  4244  4246  4247
    Set Test Variable  ${EXPECTED_FAULTS_RAW}
    Log  Verify SBTS state.  console=true
    Wait Until Keyword Succeeds  120  20  Check Modules And Cells


Step2: Performing Power Off/on On Radio Module And Verify Alarm Presence
    Log  \nStep2: Performing power off/on on radio module and verify alarm presence.  console=true
    Log  Choosing a radio module.  console=true
    ${rmod_d_ns}  Get Ids For All  RMOD
    ${rmod_sn}  Get First RMOD Serial Number That Matches Given RMOD Type  ${rmod_d_ns}
    IF  '${rmod_sn}' == '${None}'  Fail  There are no RMODs ${RMOD_TYPE} on SBTS.
    Set Test Variable  ${RMOD_SN}  ${rmod_sn}
    ${status_ecpri}  Check l3Protocol For Given RMOD Type  ${RMOD_TYPE}  .*(ecpri|eCPRI|ECPRI).*
    Set Test Variable  ${STATUS_ECPRI}  ${status_ecpri}
    ${start_time}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME_NETACT}  ${start_time}
    ${supplementary_alarm_info}  Set Variable  RU connection was lost in runtime
    IF  '${ENB_BRANCH}' >= 'SBTS26R1'
        ${rmods_list}  Create List  AEQB  AEQE  AEQE_I  AEQI  AEQK  AEQP  AEQK_I  AEQP_I  AEQU  AEQM  AEQM
        ...                         AZQI  AZHL  AZHM  AZHN  AZQJ  AZQP  AZQS  AZQO  AZQU  AZQW  AZTA
        ${status}  Run Keyword And Return Status  List Should Contain Value  ${rmods_list}  ${RMOD_TYPE}
        IF  ${status}
            ${supplementary_alarm_info}  Set Variable  RU connection was lost in runtime(;|.)(\\s)?RU power loss(.)?
        ELSE
            ${supplementary_alarm_info}  Set Variable  ${supplementary_alarm_info}
        END
    END

    Setup Admin  bts_host=${OAM_BTS_IP}  bts_port=443  use_ssl=True  alias=check_warning_alarm
    ${alarm_parameters_fault_4589}  Get String With Alarm Parameters  ${FAULT_4589_UNIT_POWER_RST}
    ${background_warning_alarm}  Run Keyword In Background  Assert Alarm Active  parameters=${alarm_parameters_fault_4589}
    ...                                                                          timeout=${ALARM_TIMEOUT}
    ...                                                                          alias=check_warning_alarm

    Log  Power off radio module with serial number: ${RMOD_SN}.  console=true
    Pdu Bts Interface Off  RMOD_${RMOD_SN}
    Log  Checking operationalState of ${RMOD_DN}.  console=true
    Assert  class_name=RMOD  id=${RMOD_DN}  parameters=operationalState=${DISABLED}  timeout=300
    Log  RMOD with dist_name ${RMOD_DN} is disabled. [OK]  console=true

    Log  Waiting for fault ${FAULT_10_CRITICAL} to be visible in WebEM.  console=true
    ${alarm_parameters_fault_10}  Get String With Alarm Parameters  ${FAULT_10_CRITICAL}
    ${alarm_parameters_with_suppl_info}  Catenate  SEPARATOR=${SPACE}  ${alarm_parameters_fault_10},
    ...  supplAlarmInfo=regex"${supplementary_alarm_info}"
    Assert Alarm Active  parameters=${alarm_parameters_with_suppl_info}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_10_CRITICAL} is visible in WebEM. [OK]  console=true

    Log  Waiting for fault ${FAULT_10_CRITICAL} to be visible in Netact.  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_10_CRITICAL}
    ...                                                          suppl_info=${supplementary_alarm_info}
    ...                                                          additional_fault_id=${FAULT_10_CRITICAL}[fault_id]
    Log  Fault ${FAULT_10_CRITICAL} is visible in Netact. [OK]  console=true

    Log  Power on radio module with serial number: ${RMOD_SN}.  console=true
    Pdu Bts Interface On  RMOD_${RMOD_SN}

    Log  Waiting for fault ${FAULT_4589_UNIT_POWER_RST} to be visible in WebEM.  console=true
    ${web_em_warming_alarm}  Collect Keyword Result  ${background_warning_alarm}  timeout=${ALARM_TIMEOUT}
    IF  ${web_em_warming_alarm}
        Log  Fault ${FAULT_4589_UNIT_POWER_RST} was active in WebEm. [OK]  console=true
    ELSE
        Fail  Fault ${FAULT_4589_UNIT_POWER_RST} was not active in WebEm. [NOK]
    END
    Assert Alarm Inactive  parameters=${alarm_parameters_fault_4589}  timeout=${ALARM_TIMEOUT}

    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_4589_UNIT_POWER_RST}
    ...                                                                               time_from=${START_TIME_NETACT}
    ...                                                                               additional_fault_id=${FAULT_4589_UNIT_POWER_RST}[fault_id]
    Log  Fault ${FAULT_4589_UNIT_POWER_RST} reported & cleared from NetAct. [OK]  console=true

    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  20  Check Modules And Cells
    Log  All modules and cells are operational. [OK]  console=true


Step3: Check Fault Signature Of Fault 4589
    Log  \nStep3: Check fault signature of fault 4589.  console=true
    Check Fault Signature Of Alarm In WebEM  fault_id=${FAULT_4589_UNIT_POWER_RST}[fault_id]
    ...                                      category=${CATEGORY}
    ...                                      component=${RMOD_SN}
    ...                                      load_name=${SW_VERSION}
    ...                                      reset_counter=${RESET_COUNTER}
    ...                                      scope=${EXPECTED_SCOPE}
    Check Fault Signature Of Alarm In Netact  fault_id=${FAULT_4589_UNIT_POWER_RST}[fault_id]
    ...                                       time_from=${START_TIME_NETACT}
    ...                                       category=CATEGORY:${SPACE}${CATEGORY}
    ...                                       component=COMPONENT:${SPACE}${RMOD_SN}
    ...                                       load_name=LOAD_NAME:${SPACE}${SW_VERSION}
    ...                                       reset_counter=RESET_COUNTER:${SPACE}${RESET_COUNTER}
    ...                                       scope=SCOPE:${SPACE}${EXPECTED_SCOPE}


Step4: Verify Faults Presence In RawAlarmHistory File
    Log  \nStep4: Verify Faults Presence In RawAlarmHistory File.  console=true
    Return From Keyword If  ${STATUS_ECPRI}
    FOR  ${fault_id}  IN  @{EXPECTED_FAULTS_RAW}
         ${fault_status}  Run Keyword And Return Status  Verify Alarm In RawAlarmHistory File  ${fault_id}  ${CURRENT_DATE_TIME_RAW}
         IF  ${fault_status}  RETURN
    END
    Fail  No fault from ${EXPECTED_FAULTS_RAW} list reported in "RawAlarmHistory" file on current date, after ${CURRENT_DATE_TIME_RAW}. [NOK]


Get First RMOD Serial Number That Matches Given RMOD Type
    [Arguments]  ${rmod_d_ns_list}

    FOR  ${rmod_dn}  IN  @{rmod_d_ns_list}
         ${rmod_parameters}  coam.Get Parameters  ${rmod_dn}
         IF  '${rmod_parameters}[productName]' == '${RMOD_TYPE}'
             Set Test Variable  ${RMOD_DN}  ${rmod_dn}
             RETURN  ${rmod_parameters}[serialNumber]
         END
    END

    RETURN  ${None}


Recovery Action
    ${status}  Run Keyword And Return Status  Assert  RMOD  ${RMOD_DN}  operationalState=${DISABLED}
    IF  ${status}
        Log  Radio module is not in the right state. Performing power on.  console=true
        Pdu BTS Interface On  RMOD_${RMOD_SN}
        Log  Radio module is ${ENABLED}. [OK]  console=true
    END
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  20  Check Modules And Cells


TC Setup
    Common Test Setup  tc_name=FM__RMOD_crash_fault_signature_check
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed  Recovery Action
    Teardown NetAct
    Common Test Teardown
