*** Settings ***
Documentation
    ...  The purpose is to immprove fault management to provide to user more proper escalation when the autonomous recovery is not possible due to
    ...  flag actForceAutoReset is set to false. This feature intends to improve fault instruction to customers for the below list of faults:
    ...  149 : EFaultId_DspNacksReceivedAl
    ...  1806 : EFaultId_CommunicationFailureAl
    ...  2400 : EFaultId_TrxInitFailureAl
    ...  4383 : EFaultId_VirtualNodeNotRespondingAl
    ...  4539 : EFaultId_GnbConfigurationFailed
    ...  6292 : EFaultId_ResourcePoolConfigurationFailedAl
    ...  7317 : EFaultId_NgSetupStopRetryAl
    ...  7501 : EFaultId_F1ResetDuInitRetryFailGuardTimerAl
    ...  7502 : EFaultId_F1SetupRetryFailRespAl
    ...  7503 : EFaultId_F1ApDuProtocolErrAl
    ...  7700 : EFaultId_E1SetupRetryFailGuardTimerAl
    ...  7701 : EFaultId_E1SctpSetupFailAl
    ...  When one of the above fault is raised, the fault instruction shall be checked to validate the updated instruction to operator. The fault
    ...  instruction shall contain new recommended recovery action, such as a RAT/board reset instead of a full BTS reset or software rollback. This
    ...  minimizes disruption to other cells. Above is the list of faults which shall be handled in this feature.

Resource  ../../common_resources/ca_FM_general.robot
Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${STARTUP_TIMEOUT}  1200  # [in seconds] Timeout for SBTS to recover after reset.
${NETACT_TIMEOUT}  180  # [in seconds] Timeout for alarm to be reported in Netact.


*** Keywords ***
FM__Fault_instructions_improved_FID7317
    [Documentation]
    ...  [CASE LINK] : https://jiradc.ext.net.nokia.com/browse/TAT-29405
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  16.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29405 - Initial TAT creation
    ...  25.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30344 - Changed xpaths and added a timeout for delta recommissioning
    ...  20.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30657 - Changed the parameter value to lowercase
    ...  *******************

    Set Tags  CA-FM  OWNER-radu.steici@nokia.com  AUTHOR-laura.craciunel@nokia.com  GROUP_IN_CHARGE-TIM_4_Vrf
    ...  PHASE-CRT  SW-SBTS25  FEATURE-CB013579

    Step0: Testcase Preconditions
    Step1: Change Parameter To Dummy Value And Trigger Fault
    Step2: Return Parameter To Initial Value And Clear Fault


Step0: Testcase Preconditions
    Log  \nStep0: Testcase preconditions.  console=true
    IF  '${SCF_COUNT_NR}'=='0'  Fail  NR cells are not commissioned.
    ${nrbts_id}  Admin Get NRBTS ID
    Set Test Variable  ${NRBTS_ID}
    ${list}  Create List  mnc
    ${object}  Get Parameter By Distname  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}  ${list}
    Set Test Variable  ${NRBTS_MNC_VALUE}  ${object}[0][parameters][mnc]
    ${nsa_cells}  Create List
    ${sa_nsa_cells}  Create List
    ${sa_cells}  Create List
    ${all_cells}  Get Cells Info
    FOR  ${cell}  IN  @{all_cells}
         ${nsa_status}  Run Keyword And Return Status  Should Be Equal As Strings  ${cell}[cellDepType]  NSA
         ${sa_nsa_status}  Run Keyword And Return Status  Should Be Equal As Strings  ${cell}[cellDepType]  SA+NSA
         IF  ${nsa_status}
             Append To List  ${nsa_cells}  ${cell}[id][internal]
         ELSE IF  ${sa_nsa_status}
             Append To List  ${sa_nsa_cells}  ${cell}[id][internal]
         ELSE
             Append To List  ${sa_cells}  ${cell}[id][internal]
         END
    END
    Set Test Variable  ${SA_CELLS}
    Set Test Variable  ${NSA_CELLS}
    Set Test Variable  ${SA_NSA_CELLS}
    Change FMCADM Parameter  actForceAutoReset  false
    ${date}  Get Current Date  time_zone=UTC  result_format=datetime
    Set Test Variable  ${START_TIME}  ${date}


Step1: Change Parameter To Dummy Value And Trigger Fault
    Log  \nStep1: Change parameter to dummy value and trigger fault.  console=true
    @{instructions_for_fault_7317}  Create List  Follow the instructions until the issue is resolved:
    ...  1. Check the SERVEDAMF configuration and correct any issues seen there.
    ...  2. Check the configuration and status of the AMF (whether it is operational, overloaded, etc.).
    ...  3. Execute RAT reset manually, if not executed previously as an autonomous recovery action
    ...  4. Manually trigger a BTS reset.
    ...  5. Collect a snapshot and contact the Nokia support team.
    ${dummy_value}  Evaluate  random.randint(${NRBTS_MNC_VALUE}+1,10)  modules=random
    Change Mnc Values Under NRBTS And NRPLMN  ${dummy_value}
    Log  Parameters changed to dummy values. SBTS will reset.  console=true
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  30s  Check Modules And Cells  check_cells=${FALSE}
    ${alarm_parameters_7317}  Get String With Alarm Parameters  ${FAULT_7317}
    Assert Alarm Active  parameters=${alarm_parameters_7317}  timeout=${STARTUP_TIMEOUT}
    Log  Fault ${FAULT_7317} is active in WebEM.  console=true
    ${fault_7317_instructions_webem}  Get alarm fault instructions in WebEM  fault_id_value=7317
    @{list_of_instructions_webem}  Split String  ${fault_7317_instructions_webem}  \n
    Lists Should Be Equal  ${instructions_for_fault_7317}  ${list_of_instructions_webem}
    Log  Fault instructions checked.  console=true
    ${count_sa_cells}  Get Length  ${SA_CELLS}
    ${count_nsa_cells}  Get Length  ${NSA_CELLS}
    ${count_sa_nsa_cells}  Get Length  ${SA_NSA_CELLS}
    ${alarm_parameters_7107}  Get String With Alarm Parameters  ${FAULT_7107}
    IF  ${count_nsa_cells}
        Assert Alarm Active  parameters=${alarm_parameters_7107}  timeout=${STARTUP_TIMEOUT}
        Log  Fault ${FAULT_7107} is active in WebEM.  console=true
        Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10s  Check Additional Information For Given Alarm And Fault  &{FAULT_7107}
        Log  Fault ${FAULT_7107} is active in Netact.  console=true
    END
    IF  ${count_sa_cells}
        Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  60s
        ...  Check Parameters Status For Cells  ${SA_CELLS}  operationalState=${DISABLED}, availabilityStatus=${FAILED}
    END
    IF  ${count_sa_nsa_cells}
        Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  60s
        ...  Check Parameters Status For Cells  ${SA_NSA_CELLS}  operationalState=${ENABLED}, availabilityStatus=${DEGRADED}
    END
    IF  ${count_nsa_cells}
        Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  60s
        ...  Check Parameters Status For Cells  ${NSA_CELLS}  operationalState=${ENABLED}
    END
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10s  Check Additional Information For Given Alarm And Fault  &{FAULT_7317}
    Log  Fault ${FAULT_7317} is active in Netact.  console=true


Step2: Return Parameter To Initial Value And Clear Fault
    Log  \nStep2: Return parameter to initial value and clear fault.  console=true
    Return mnc value to original value


Return Mnc Value To Original Value
    Log  Return mnc value to original value.  console=true
    Change Mnc Values Under NRBTS And NRPLMN  ${NRBTS_MNC_VALUE}
    Log  Parameters changed to original values. SBTS will reset.  console=true
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}  30s  Check Modules And Cells
    ${alarm_parameters}  Get String With Alarm Parameters  ${FAULT_7317}
    Assert Alarm Inactive  parameters=${alarm_parameters}  timeout=${STARTUP_TIMEOUT}
    Log  Fault ${FAULT_7317} is inactive in WebEM.  console=true
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms  &{FAULT_7317}  time_from=${START_TIME}
    Log  Fault ${FAULT_7317} is inactive in Netact.  console=true


Change Mnc Values Under NRBTS And NRPLMN
    [Arguments]  ${value}

    ${delta_id}  Set Variable  1
    Create Delta  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}  mnc  ${value}  ${delta_id}
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/NRBTS-${NRBTS_ID}/NRPLMN-1  mnc  ${value}  ${delta_id}
    Get Delta  ${delta_id}
    Save Delta  ${BTS_FILES}/delta_change_mnc_to_${value}.json  delta_id=${delta_id}
    Perform Delta Recommissioning  ${BTS_FILES}/delta_change_mnc_to_${value}.json  skip_parameter_relation_errors=True  timeout=600
    Remove Delta  ${delta_id}


Get alarm fault instructions in WebEM
    [Arguments]  ${fault_id_value}

    WebEM Setup
    Wait Until Element Is Clicked  xpath=${ALARMS_BUTTON_SITE_VIEW}  retry_timeout=90s  retry_interval=5s
    Sleep  10s  Time for page to be updated.
    ${alarm}  SeleniumLibrary.Get Element Count  class:alarm-row
    ${instruction_text_path}  Catenate  SEPARATOR=  xpath=//*[contains(@class, 'details-panel-content')]/div/alarms-details/div/div[2]/
    ...  table/tbody[3]/tr[4]/td[2]//toggle-text-display-fm/div/div
    FOR  ${id}  IN RANGE  1  ${alarm}+1
         ${fault_id}  Get Text  //*[contains(@alarm-type, 'current')]/ui-table/div/ng-transclude/table/tbody/tr[${id}]/td[5]
         IF  ${fault_id}==${fault_id_value}
             Wait Until Element Is Clicked  //*[contains(@alarm-type, 'current')]/ui-table/div/ng-transclude/table/tbody/tr[${id}]/td[5]
             Wait Until Element Is Clicked  xpath=//*[contains(@class, 'details-panel-container')]/ui-button/button/i
             Double Click Element  ${instruction_text_path}
             ${fault_instructions_text}  Get Text  ${instruction_text_path}
             BREAK
        END
    END

   RETURN  ${fault_instructions_text}
   [Teardown]  Close Browser


TC Setup
    Common Test Setup  tc_name=FM__Fault_instructions_improved_FID7317
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed  Return mnc value to original value
    Teardown NetAct
    Common Test Teardown
