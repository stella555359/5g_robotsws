*** Settings ***
Documentation
    ...  This test was created to imitate X2 link break scenario.
    ...  Testcase will break both LTE-GNB X2 and GNB-AMF F1 links.
    ...  Link break will be performed by modyfing iptables and drop incomming requests.
    ...  Alarms raised after link break will be checked. NR cells status will be verified.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${ALARM_TIMEOUT}  360  # [in seconds] Timeout for alarm to be reported in WebEM.
${CELLS_TIMEOUT}  360  # [in seconds] Timeout for cells to be in expected state.
${NETACT_TIMEOUT}  240  # [in seconds] Timeout for alarm to be reported in Netact.


*** Keywords ***
TC__FM__link_break_X2
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26013
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 18.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26013 - Initial TAT creation
    ...  - 31.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28025 - Enhancement for verifying additonalFaultID in NetAct
    ...  - 22.04.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29090 - additionalText3 doesn't have supplAlarmInfo
    ...  *******************


    Set Tags  CA-FM  OWNER-OWNER-lucian.ciurel@nokia.com  AUTHOR-laura.craciunel@nokia.com  MAINTAINER-laura.craciunel@nokia.com
    ...  GROUP_IN_CHARGE-TIM_4_Vrf  PHASE-CRT  SW-SBTS24


    Step0: Testcase Preconditions
    Step1: Provoke Link Break
    Step2: Restore Link And Verify Recovery


Step0: Testcase Preconditions
    Log  Step0: Testcase Preconditions.  console=True
    ${bts_info}  Get Bts Info
    ${gnb_cu_type}  Get From Dictionary  ${bts_info}  gNbCuType
    Set Test Variable  ${GNB_CU_TYPE}
    ${nr_cells}  coam.Get Cells Info
    ${sa_cells}  Create List
    ${nsa_cells}  Create List
    ${sa_nsa_cells}  Create List
    FOR  ${cell}  IN  @{nr_cells}
         Run Keyword If  '${cell}[cellDepType]' == 'NSA'
         ...  Append To List  ${nsa_cells}  ${cell}[id][internal]
         ...  ELSE IF  '${cell}[cellDepType]' == 'SA'
         ...  Append To List  ${sa_cells}  ${cell}[id][internal]
         ...  ELSE IF  '${cell}[cellDepType]' == 'SA+NSA'
         ...  Append To List  ${sa_nsa_cells}  ${cell}[id][internal]
    END
    Set Test Variable  ${SA_CELLS}
    Set Test Variable  ${NSA_CELLS}
    Set Test Variable  ${SA_NSA_CELLS}


Step1: Provoke Link Break
    Log  Step1: Provoke Link Break.  console=True
    Run Keyword If  '${GNB_CU_TYPE}' == 'NSA'
    ...  Provoke LTE-GNB X2 Link Break
    ...  ELSE IF  '${GNB_CU_TYPE}' == 'SA+NSA'
    ...  Run Keywords
    ...  Provoke LTE-GNB X2 Link Break
    ...  AND
    ...  Provoke GNB-AMF F1 Link Break
    ...  ELSE IF  '${GNB_CU_TYPE}' == 'SA'
    ...  Provoke GNB-AMF F1 Link Break


Step2: Restore Link And Verify Recovery
    Log  Step2: Restore Link And Verify Recovery.  console=True
    Modify Iptables For GNB-AMF F1 Link Restore
    Modify Iptables For LTE-GNB X2 Link Restore
    Wait Until Keyword Succeeds  ${CELLS_TIMEOUT}  10s  Check All Cells
    ${fault_7107_params}  Get String With Alarm Parameters  ${FAULT_7107}
    ${fault_7308_params}  Get String With Alarm Parameters  ${FAULT_7308}
    ${fault_7303_params}  Get String With Alarm Parameters  ${FAULT_7303}
    ${fault_7504_params}  Get String With Alarm Parameters  ${FAULT_7504}
    ${fault_6327_params}  Get String With Alarm Parameters  ${FAULT_6327}
    Assert Alarm Inactive  parameters=${fault_7107_params}  timeout=${ALARM_TIMEOUT}
    Assert Alarm Inactive  parameters=${fault_7308_params}  timeout=${ALARM_TIMEOUT}
    Assert Alarm Inactive  parameters=${fault_7303_params}  timeout=${ALARM_TIMEOUT}
    Assert Alarm Inactive  parameters=${fault_7504_params}  timeout=${ALARM_TIMEOUT}
    Assert Alarm Inactive  parameters=${fault_6327_params}  timeout=${ALARM_TIMEOUT}
    Log  Alarms are inactive after cells recovered.  console=True


Provoke LTE-GNB X2 Link Break

    Modify Iptables For LTE-GNB X2 Link Break

    Log  Check cells state after link break.  console=True
    ${number_nsa_cells}  Get Length  ${NSA_CELLS}
    ${number_sa_cells}  Get Length  ${SA_CELLS}
    ${number_sa_nsa_cells}  Get Length  ${SA_NSA_CELLS}
    Run Keyword If  ${number_nsa_cells}
    ...  Wait Until Keyword Succeeds  ${CELLS_TIMEOUT}s  10s
    ...  Check Parameters Status For Cells  ${NSA_CELLS}  operationalState=${DISABLED}, availabilityStatus=${FAILED}
    Run Keyword If  ${number_sa_cells}
    ...  Wait Until Keyword Succeeds  ${CELLS_TIMEOUT}s  10s
    ...  Check Parameters Status For Cells  ${SA_CELLS}  operationalState=${ENABLED}
    Run Keyword If  ${number_sa_nsa_cells}
    ...  Wait Until Keyword Succeeds  ${CELLS_TIMEOUT}s  10s
    ...  Check Parameters Status For Cells  ${SA_NSA_CELLS}  operationalState=${ENABLED}, availabilityStatus=${DEGRADED}

    Log  Check alarms presence in WebEM.  console=True
    ${fault_7107_params}  Get String With Alarm Parameters  ${FAULT_7107}
    ${fault_7107_major_params}  Get String With Alarm Parameters  ${FAULT_7107_MAJOR}
    Run Keyword If  ${number_nsa_cells}
    ...  Run Keywords
    ...  Assert Alarm Active  parameters=${fault_7107_params}  timeout=${ALARM_TIMEOUT}
    ...  AND
    ...  Log  Fault ${FAULT_7107} is active in WebEM.  console=true
    Run Keyword If  ${number_sa_nsa_cells}
    ...  Run Keywords
    ...  Assert Alarm Active  parameters=${fault_7107_major_params}  timeout=${ALARM_TIMEOUT}
    ...  AND
    ...  Log  Fault ${FAULT_7107_MAJOR} is active in WebEM.  console=true

    ${fault_7308_params}  Get String With Alarm Parameters  ${FAULT_7308}
    ${check_fault_7308}  Assert Alarm Active  parameters=${fault_7308_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_7308} is active in WebEM.  console=true

    Log  Check alarms presence in Netact.  console=True
    Run Keyword If  ${number_nsa_cells}
    ...  Run Keywords
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_7107}  additional_fault_id=${FAULT_7107}[fault_id]
    ...  suppl_info=trigger=link-status-change, failureService=NSA
    ...  AND
    ...  Log  Fault ${FAULT_7107} is active in Netact.  console=True
     Run Keyword If  ${number_sa_nsa_cells}
    ...  Run Keywords
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_7107_MAJOR}  additional_fault_id=${FAULT_7107_MAJOR}[fault_id]
    ...  suppl_info=trigger=link-status-change, failureService=NSA
    ...  AND
    ...  Log  Fault ${FAULT_7107_MAJOR} is active in Netact.  console=True
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_7308}  additional_fault_id=${FAULT_7308}[fault_id]
    Log  Fault ${FAULT_7308} is active in Netact.  console=True


Provoke GNB-AMF F1 Link Break

    Modify Iptables For GNB-AMF F1 Link Break

    Log  Check cells state after link break.  console=True
    ${state}  Catenate  operationalState=${DISABLED}  availabilityStatus=${FAILED}
    Wait Until Keyword Succeeds  ${CELLS_TIMEOUT}s  10s  Assert Every  NRCEL  ${state}
    Log  All NR cells are disabled after link break.  console=True

    Log  Check alarms presence in WebEM.  console=True
    ${fault_7303_params}  Get String With Alarm Parameters  ${FAULT_7303}
    ${check_fault_7303}  Assert Alarm Active  parameters=${fault_7303_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_7303} is active in WebEM.  console=True
    ${fault_7504_params}  Get String With Alarm Parameters  ${FAULT_7504}
    ${check_fault_7504}  Assert Alarm Active  parameters=${fault_7504_params}  timeout=${ALARM_TIMEOUT}
    Log  Fault ${FAULT_7504} is active in WebEM.  console=True
    ${fault_6327_params}  Get String With Alarm Parameters  ${FAULT_6327}
    Run Keyword If  '${GNB_CU_TYPE}' == 'SA+NSA'
    ...  Run Keywords
    ...  Assert Alarm Active  parameters=${fault_6327_params}  timeout=${ALARM_TIMEOUT}
    ...  AND
    ...  Log  Fault ${FAULT_6327} is active in WebEM.  console=True

    Log  Check alarms presence in Netact.  console=True
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_7303}  additional_fault_id=${FAULT_7303}[fault_id]
    Log  Fault ${FAULT_7303} is active in Netact.  console=True
    Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30
    ...  Check Additional Information For Given Alarm And Fault  &{FAULT_7504}  additional_fault_id=${FAULT_7504}[fault_id]
    ...  suppl_info=Connection to [A-Za-z]+ is broken
    Log  Fault ${FAULT_7504} is active in Netact.  console=True
    Run Keyword If  '${GNB_CU_TYPE}' == 'SA+NSA'
    ...  Run Keywords
    ...  Wait Until Keyword Succeeds  ${NETACT_TIMEOUT}  30  Check Additional Information For Given Alarm And Fault  &{FAULT_6327}
    ...  additional_fault_id=${FAULT_6327}[fault_id]
    ...  suppl_info=X2 connection to adjacent gNB .+ failed due to SCTP association establishment failure
    ...  AND
    ...  Log  Fault ${FAULT_6327} is active in Netact.  console=True


Modify Iptables For LTE-GNB X2 Link Break
    Log  Provoke link break.  console=True
    Open Connection To Primary Core
    SSHLibrary.Set Client Configuration  prompt=>
    SSHLibrary.Write  iptables -I OUTPUT -p sctp --sport 36422 -j DROP
    SSHLibrary.Read Until Prompt
    Log  Drop incomming request for port 36422 added to iptables.  console=True


Modify Iptables For LTE-GNB X2 Link Restore
    Log  Restore link.  console=True
    Open Connection To Primary Core
    SSHLibrary.Set Client Configuration  prompt=>
    SSHLibrary.Write  iptables -D OUTPUT -p sctp --sport 36422 -j DROP
    SSHLibrary.Read Until Prompt
    Log  Changes to iptables reversed.  console=True


Modify Iptables For GNB-AMF F1 Link Break
    Log  Provoke link break.  console=True
    Open Connection To Primary Core
    SSHLibrary.Set Client Configuration  prompt=>
    SSHLibrary.Write  iptables -A OUTPUT -p sctp --dport 38472 -j DROP
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ip6tables -A OUTPUT -p sctp --dport 38472 -j DROP
    SSHLibrary.Read Until Prompt
    Log  Drop incomming request for port 38472 added to iptables.  console=True


Modify Iptables For GNB-AMF F1 Link Restore
    Log  Restore link.  console=True
    Open Connection To Primary Core
    SSHLibrary.Set Client Configuration  prompt=>
    SSHLibrary.Write  iptables -t filter -F OUTPUT
    SSHLibrary.Read Until Prompt
    SSHLibrary.Write  ip6tables -t filter -F OUTPUT
    SSHLibrary.Read Until Prompt
    Log  Changes to iptables reversed.  console=True


TC Setup
    Common Test Setup  tc_name=FM__link_break_X2
    Setup NetAct


TC Teardown
    Run Keyword If Test Failed
    ...  Step2: Restore Link And Verify Recovery
    Teardown NetAct
    Common Test Teardown