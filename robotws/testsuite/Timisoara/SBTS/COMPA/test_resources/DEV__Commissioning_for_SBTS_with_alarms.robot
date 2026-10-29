*** Settings ***
Documentation
    ...  TC for SBTS commissioning from given SCF file via ADMIN API. BTS should be in 'notCommissioned' state.
    ...  | *Parameters*          | *Example*|
    ...  | COMMISSIONING_PATH    | /home/ute/btsauto/hran_ta/config/Wroclaw/SBTS_18232_Skomiszon/commissioning/SCF_02_SBTS17.xml|
    ...  | COMMISSIONING_TIMEOUT | 600 |
    ...  | STARTUP_TIMEOUT       | 15

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${COMMISSIONING_PATH}  ${EMPTY}  # Absolute path to commissioning file
${SKIP_PARAM_RELATION_ERRORS}  ${TRUE}  # Should relation errors be skipped (True, False)
${IPSEC_INSTALL}  ${FALSE}  # Is IPSec configuration enabled on BTS (True, False)
${COMMISSIONING_TIMEOUT}  600  # Timeout for commissioning procedure (wait for reconnection after reset)
${STARTUP_TIMEOUT}  15  # In minute: Timeout for BTS to startup after reset, default value 15 min
${PING_STABLE_TIMEOUT}  420  # Timeout for ping until target is stable


*** Keywords ***
TC__DEV__Commissioning_for_SBTS_with_alarms
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-10989
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 27.08.2018 - https://jira3.int.net.nokia.com/browse/TAT-10989 - Test creation
    ...  - 21.01.2019 - https://jira3.int.net.nokia.com/browse/TAT-14104 - Custom setup created
    ...  - 25.03.2019 - https://jira3.int.net.nokia.com/browse/TAT-15462 - SMODS and RMODS count added to post check
    ...  - 21.05.2019 - https://jira3.int.net.nokia.com/browse/TAT-16233 - Change modules and cells states verification
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  - 04.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27101 - Adapt TC for cloud
    ...  - 04.06.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29022 - Fix teardown for Scfc parser
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-10989

    Set Tags  CA-CM  AUTHOR-jacek.mnich@nokia.com  MAINTAINER-wojciech.sikora@nokia.com  PHASE-COMPA  PHASE-CRT  SW-SBTS17  SW-SBTS18  SW-SBTS19

    Step 1: Check Commissioning File Presence
    Step 2: SBTS Commissioning
    Run Keyword If  ${IPSEC_INSTALL}
    ...  Step 2a: Perform IPSec Certificates Installation  /home/ute/btsauto/hran_ta/config/${HW_LOCATION_CODE}/${TESTLINE_NAME}/certificates  360s
    Step 3: Check SBTS State After Commissioning


Step 1: Check Commissioning File Presence
    [Timeout]  15 min

    Log Step Header  Step 1: Check commissioning file presence
    ${file_status}  Run Keyword And Return Status
    ...  OperatingSystem.File Should Exist  ${COMMISSIONING_PATH}
    Run Keyword If  ${file_status}
    ...  Log  Commissioning file exists at ${COMMISSIONING_PATH}  console=true
    ...  ELSE
    ...  Fail  File ${COMMISSIONING_PATH} doesn't exist


Step 2: SBTS Commissioning
    Log Step Header  Step 2: SBTS commissioning
    Admin Get Bts_id And Perform Commissioning  ${COMMISSIONING_PATH}  ${SKIP_PARAM_RELATION_ERRORS}  ${COMMISSIONING_TIMEOUT}
    Log  Commissioning done. Check BTS states will be performed  console=true


Step 2a: Perform IPSec Certificates Installation
    [Arguments]  ${cert_path}  ${timeout}

    Log Step Header  Step 2a: Perform IPSec certificates installation
    Install IPSec Certificates  ${cert_path}
    Log  All certificates installed. Wait ${timeout} for clear state  console=true
    Sleep  ${timeout}  Wait for clear state after certificates installation


Step 3: Check SBTS State After Commissioning
    Log Step Header  Step 3: Check SBTS state after commissioning
    Check If Target Is Stable  ip=${SMOD1['TRS_IP']}  min_uptime=300  max_downtime=3  timeout=${PING_STABLE_TIMEOUT}
    hran_file_operations.Teardown SCFC Parser
    ${scf_parser_started}  hran_file_operations.Setup SCFC Parser  ${COMMISSIONING_PATH}  parser_technology=SBTS
    Set Test Variable  ${SCF_PARSER_STARTED}
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  30 sec
    ...  Check SBTS Cells, Modules And Alarms


Check SBTS Cells, Modules And Alarms
    ${skipped_faults_present}  Skipped Faults Presence
    ${rmods_count}  Check RMODS Count
    ${smods_count}  Check SMODS Count
    ${bts_state_is_correct}  Run Keyword And Return Status
    ...  Verify BTS ProceduralState  ^(?!.*NotCommissioned).*
    ${are_smods_online}  Run Keyword And Return Status
    ...  Verify Modules  SMOD  scf_check=${FALSE}
    ${are_rmods_online}  Run Keyword And Return Status
    ...  Verify Modules  RMOD  scf_check=${FALSE}
    ${gsm_cells_on}  Run Keyword And Return Status
    ...  Verify Cells  GSM  scf_check=${FALSE}
    ${wcdma_cells_on}  Run Keyword And Return Status
    ...  Verify Cells  WCDMA  scf_check=${FALSE}
    ${lte_cells_on}  Run Keyword And Return Status
    ...  Verify Cells  LTE  scf_check=${FALSE}
    ${ignored_fault}  Set Variable  ${FAULT_23}[fault_id]|${FAULT_1868}[fault_id]
    ${alarms_status}  Run Keyword And Return Status
    ...  Check SOAM Active Alarms  ignored_fault=${ignored_fault}
    Should Be True  ${rmods_count} and ${smods_count}  Count of modules in SCF vs BTS missmatch RMODS:${rmods_count}, SMODS:${smods_count}
    Should Be True  ${are_smods_online} and ${are_rmods_online} and ${bts_state_is_correct}
    ...  Modules state is incorrect BTS:${bts_state_is_correct}, SMODS:${are_smods_online}, RMODS:${are_rmods_online}
    Should Be True  ${alarms_status}  Unwanted alarms were found!
    Should Be True  ${skipped_faults_present} or ${gsm_cells_on} and ${wcdma_cells_on} and ${lte_cells_on}
    ...  Cells state is incorrect GSM:${gsm_cells_on}, WCDMA:${wcdma_cells_on}, LTE:${lte_cells_on}


Check RMODS Count
    ${scf_rmods}  hran_file_operations.Get Radios
    ${scf_rmods}  Get Length  ${scf_rmods}
    ${rt_rmods}  Get Ids For All  RMOD
    ${rt_rmods}  Get Length  ${rt_rmods}
    Return From Keyword If  ${rt_rmods} == ${scf_rmods}  ${TRUE}

    [Return]  ${FALSE}


Check SMODS Count
    ${scf_smods}  hran_file_operations.Get System Modules
    ${scf_smods}  Get Length  ${scf_smods}
    ${rt_smods}  Get Ids For All  SMOD
    ${rt_smods}  Get Length  ${rt_smods}
    Return From Keyword If  ${rt_smods} == ${scf_smods}  ${TRUE}

    [Return]  ${FALSE}


Skipped Faults Presence
    ${critical_alarm}  Create Dictionary  faultId=${FAULT_23}[fault_id]|${FAULT_1868}[fault_id]
    ${critical}  Create List  ${critical_alarm}
    ${status}  ${alarms_msg}  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms TAF  critical_patterns=${critical}
    Return From Keyword If  '${status}'=='FAIL'  ${TRUE}

    [Return]  ${FALSE}


Check SOAM Active Alarms
    [Arguments]  ${critical_alarms_severity}=Major|Critical  ${ignored_fault}=None  ${expected_fault}=None  ${notifier}=.*

    Log  ------------------------------------------------------------------------------------------  console=true
    ${expected_alarms}  Create Dictionary  faultId=${expected_fault}  notifier=${notifier}
    ${expected_patterns}  Create List  ${expected_alarms}
    ${critical_alarms}  Create Dictionary  severity=${critical_alarms_severity}  faultId=^((?!${ignored_fault}).)*$
    ${critical_patterns}  Create List  ${critical_alarms}
    ${ignored_alarms}  Create Dictionary  faultId=${ignored_fault}
    ${ignored_patterns}  Create List  ${ignored_alarms}

    ${alarms_status}  ${alarms_return}  Run Keyword If  '${expected_fault}'!='None'
    ...  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms TAF  expected_patterns=${expected_patterns}
    ...  critical_patterns=${critical_patterns}
    ...  ignored_patterns=${ignored_patterns}
    ...  ELSE
    ...  Run Keyword And Ignore Error
    ...  Admin Check Active Alarms TAF  critical_patterns=${critical_patterns}  ignored_patterns=${ignored_patterns}
    Run Keyword If  '${alarms_status}'=='FAIL'
    ...  Fail  Failed at expected alarms:${expected_alarms} critical alarms: ${critical_alarms} ignored alarms:${ignored_alarms}
    Run Keyword If  ${alarms_return}
    ...  Set Test Restriction  Minor alarm found.


TC Setup
    TRY
        Common Test Setup  expected_bts_status=NotCommissioned  modules_check=False  cells_check=False  alarms_check=False
    ...  tc_name=DEV__Commissioning_for_SBTS_with_alarms
    EXCEPT  AssertionError: Extension System Module not detected despite declared in config file.
        Log  Common Test Setup failed. Continue anyway.  console=true
    END


TC Teardown
    Common Test Teardown
