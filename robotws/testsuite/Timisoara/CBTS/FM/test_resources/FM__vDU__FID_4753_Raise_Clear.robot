*** Settings ***
Documentation
    ...  Test case will verify if the implementation of faults 7516 and 4753 is working according
    ...  to specifications.
    ...  First, one NR cell is randomly chosen and fault 7516 'Incorrect cell parameter configuration'
    ...  is triggered by changing gscnOrSsPbchArfcn parameter to 3279165. actAlarmOfRatOutage is set to
    ...  true and after 660 seconds, fault 4753 'RAT Service Outage' must be visible.
    ...  Then, actAlarmOfRatOutage is set to false and fault 4753 should be cleared while NR cell
    ...  remains failed.
    ...  Fault 7516 must be cleared after gscnOrSsPbchArfcn is set to its initial value and NR cell
    ...  is blocked and unblocked.
    ...  Both faults should be visible in WebEM and NetAct.
    ...  After clearing these faults, vDU must reach on air state.

Resource  ../../common_resources/vdu_frame.robot
Resource  ../../common_resources/vdu_general.robot


*** Variables ***
${BLOCK_TIMEOUT}  360  # [in seconds] Timeout for cell blocking.
${ALARM_TIMEOUT}  360  # [in seconds] Timeout for alarm to be active in WebEM.
${NETACT_TIMEOUT}  180  # [in seconds] Timeout for alarm to appear in Netact.
${RECOVERY_TIMEOUT}  900  # [in seconds] Timeout for CBTS to recover.
${NETACT_IP_CMWAS}  ${EMPTY}  # Mandatory. CMWAS node IP for connection to Netact.


*** Keywords ***
TC__FM__vDU__FID_4753_Raise_Clear
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27768
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 10.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27768 - Initial TAT creation

    Set Tags  CA-FM  OWNER-florin-sebastian.nedelcu@nokia.com  AUTHOR-laura.craciunel@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-vDU24  FEATURE-CB007964

    Step0: Testcase Preconditions
    Step1: Set Parameters To Test Values
    Step2: Verify Fault 7516
    Step3: Verify Fault 4753
    Step4: Set actAlarmOfRatOutage To Initial Value To Clear Fault 4573
    Step5: Set gscnOrSsPbchArfcn to Initial Value And Block/Unblock Cell To Clear Fault 7516


Step0: Testcase Preconditions
    Log  Step0: Testcase Preconditions.  console=true
    ${all_cells}  vdu.Get Vdu Cells Status
    ${selected_cell}  Evaluate  random.choice(${all_cells})  random
    ${cell_dn}  Set Variable  ${selected_cell}[dist_names][config]
    ${cell_id}  Fetch From Right  ${cell_dn}  -
    Set Test Variable  ${CELL_DN}
    Set Test Variable  ${CELL_ID}
    Log  Selected cell:\n ${CELL_DN}  console=true

    ${CELL_PARAM_INITIAL_VALUE}  VDU Get Parameter Value  gscnOrSsPbchArfcn  ${CELL_DN}
    Set Test Variable  ${CELL_PARAM_INITIAL_VALUE}

    netact.Add Node  cmwas  ${NETACT_IP_CMWAS}  ${NETACT_USERNAME}  ${NETACT_PASSWORD}
    ${netact_web_url}  netact.Detect Web Url
    Set Test Variable  ${NETACT_WEB_URL}  ${netact_web_url}
    netact.Add Web Url  ${NETACT_WEB_URL}  ${NETACT_USERNAME}  ${NETACT_PASSWORD}
    Set Test Variable  ${MRBTS_DN}  PLMN-PLMN/MRBTS-${VDU_MRBTS_ID}
    Set Variables For Visible Faults


Step1: Set Parameters To Test Values
    Log  \nStep1: Set Parameters To Test Values.  console=true
    Change Specific Parameter For VDU  actAlarmOfRatOutage  true  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    Change Specific Parameter For VDU  gscnOrSsPbchArfcn  3279165  ${CELL_DN}


Step2: Verify Fault 7516
    Log  \nStep2: Verify Fault 7516.  console=true
    Wait Until Keyword Succeeds  ${ALARM_TIMEOUT}  10
    ...  Check If Fault Is Visible In VDU WebEM  ${FAULT_7516}[alarm_id]  ${FAULT_7516}[alarm_name]  ${FAULT_7516}[fault_id]
    ...  ${FAULT_7516}[fault_name]  ${FAULT_7516}[severity]
    Log  Fault ${FAULT_7516}[fault_id] "${FAULT_7516}[fault_name]" is reported in WebEm.  console=true

    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault  ${FAULT_7516}[fault_id]  ${FAULT_7516}[fault_name]  ${FAULT_7516}[alarm_id]
    ...  ${FAULT_7516}[alarm_name]  ${FAULT_7516}[severity]  suppl_info=additionalFaultID=${FAULT_7516}[fault_id]
    Log  Fault ${FAULT_7516}[fault_id] "${FAULT_7516}[fault_name]" is reported in Netact.  console=true


Step3: Verify Fault 4753
    Log  \nStep3: Verify Fault 4753.  console=true
    Sleep  660s  Wait for fault to be reported.
    Check If Fault Is Visible In VDU WebEM  ${FAULT_4753}[alarm_id]  ${FAULT_4753}[alarm_name]  ${FAULT_4753}[fault_id]
    ...  ${FAULT_4753}[fault_name]  ${FAULT_4753}[severity]
    Log  Fault ${FAULT_4753}[fault_id] "${FAULT_4753}[fault_name]" is reported in WebEm.  console=true

    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10s
    ...  Check Additional Information For Given Alarm And Fault  ${FAULT_4753}[fault_id]  ${FAULT_4753}[fault_name]  ${FAULT_4753}[alarm_id]
    ...  ${FAULT_4753}[alarm_name]  ${FAULT_4753}[severity]  suppl_info=additionalFaultID=${FAULT_4753}[fault_id]
    Log  Fault ${FAULT_4753}[fault_id] "${FAULT_4753}[fault_name]" is reported in Netact.  console=true


Step4: Set actAlarmOfRatOutage To Initial Value To Clear Fault 4573
    Log  \nStep4: Set actAlarmOfRatOutage To Initial Value To Clear Fault 4573.  console=true
    ${time_from}  Get Current Date  time_zone=UTC  result_format=datetime
    Change Specific Parameter For VDU  actAlarmOfRatOutage  false  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1
    Wait Until Keyword Succeeds  60  10  Check If Fault Is Cleared From VDU WebEM  ${FAULT_4753}[alarm_id]
    ...  ${FAULT_4753}[fault_id]
    Log  Fault ${FAULT_4753}[fault_id] "${FAULT_4753}[fault_name]" is inactive in WebEM.  console=true

   Wait Until Keyword Succeeds  60  10s  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms
    ...  ${FAULT_4753}[fault_id]  ${FAULT_4753}[fault_name]  ${FAULT_4753}[alarm_id]  ${FAULT_4753}[alarm_name]  ${FAULT_4753}[severity]
    ...  ${time_from}  suppl_info=additionalFaultID=${FAULT_4753}[fault_id]
    Log  Fault ${FAULT_4753}[fault_id] "${FAULT_4753}[fault_name]" is cleared in Netact.  console=true


Step5: Set gscnOrSsPbchArfcn to Initial Value And Block/Unblock Cell To Clear Fault 7516
    Log  \nStep5: Set gscnOrSsPbchArfcn to Initial Value And Block/Unblock Cell To Clear Fault 7516.  console=true
    ${time_from}  Get Current Date  time_zone=UTC  result_format=datetime

    Change Specific Parameter For VDU  gscnOrSsPbchArfcn  ${CELL_PARAM_INITIAL_VALUE}  ${CELL_DN}
    Wait Until Keyword Succeeds  180  10  Check The Specific Cell From VDU  ${CELL_ID}  availability_status=${FAILED}

    Block cell  cell_id=${CELL_ID}  timeout=${BLOCK_TIMEOUT}
    Wait Until Keyword Succeeds  180  10  Check The Specific Cell From VDU  ${CELL_ID}  blocking_state=${BLOCKED}
    Unblock cell  cell_id=${CELL_ID}  timeout=${BLOCK_TIMEOUT}

    Wait Until Keyword Succeeds   ${ALARM_TIMEOUT}  30  Check If Fault Is Cleared From VDU WebEM  ${FAULT_7516}[alarm_id]  ${FAULT_7516}[fault_id]
    Log  Fault ${FAULT_7516}[fault_id] "${FAULT_7516}[fault_name]" is inactive in WebEm.  console=true

    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  10s  Check Additional Information For Given Alarm And Fault In NA Cleared Alarms
    ...  ${FAULT_7516}[fault_id]  ${FAULT_7516}[fault_name]  ${FAULT_7516}[alarm_id]  ${FAULT_7516}[alarm_name]  ${FAULT_7516}[severity]
    ...  ${time_from}  suppl_info=additionalFaultID=${FAULT_7516}[fault_id]
    Log  Fault ${FAULT_7516}[fault_id] "${FAULT_7516}[fault_name]" is cleared in Netact.  console=true

    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells From VDU  availability_status=${ONLINE}  operational_state=${ENABLED}


Set Variables For Visible Faults
    ${FAULT_7516}  Create Dictionary  fault_id=7516  fault_name=Incorrect cell parameter configuration  alarm_id=7114
    ...  alarm_name=CELL SERVICE PROBLEM  severity=critical
    ${FAULT_4753}  Create Dictionary  fault_id=4753  fault_name=RAT Service Outage  alarm_id=7250  alarm_name=RAT SERVICE OUTAGE  severity=critical
    Set Test Variable  ${FAULT_7516}
    Set Test Variable  ${FAULT_4753}


Return To Original Configuration
    ${cell_is_on_air}  Run Keyword And Return Status  Check The Specific Cell From VDU  ${CELL_ID}  availability_status=${ONLINE}
    Return From Keyword If  ${cell_is_on_air}
    ${act_rat_outage}  VDU Get Parameter Value  actAlarmOfRatOutage  ${CELL_DN}
    Run Keyword If  '${act_rat_outage}'!='false'
    ...  Change Specific Parameter For VDU  actAlarmOfRatOutage  false  MRBTS-${VDU_MRBTS_ID}/MNL-1/MNLENT-1/FMCADM-1

    ${gscn_or_ss_pnch_arfcn}  VDU Get Parameter Value  gscnOrSsPbchArfcn  ${CELL_DN}
    Run Keyword If  '${gscn_or_ss_pnch_arfcn}'!='${CELL_PARAM_INITIAL_VALUE}'
    ...  Change Specific Parameter For VDU  gscnOrSsPbchArfcn  ${CELL_PARAM_INITIAL_VALUE}  ${CELL_DN}

    Block Cell  cell_id=${CELL_ID}  timeout=${BLOCK_TIMEOUT}
    Wait Until Keyword Succeeds  180  10  Check The Specific Cell From VDU  ${CELL_ID}  blocking_state=${BLOCKED}
    Unblock Cell  cell_id=${CELL_ID}  timeout=${BLOCK_TIMEOUT}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check All Cells From VDU  availability_status=${ONLINE}  operational_state=${ENABLED}


TC Setup
    Common VDU Setup
    Modify Resource Search Order  FM__vDU__FID_4753_Raise_Clear


TC Teardown
    Run Keyword If Test Failed  Return To Original Configuration
    netact.Delete Node  cmwas
    Common VDU Teardown
