*** Settings ***
Documentation
    ...  This test case is created to perform operations on selected units.
    ...  Site Block is performed. Site Unblock is performed and verify if all cells are in expected state.
    ...  Reset site is performed and verify if all cells are in expected state.
    ...  Reset all RMODS and check all cells.
    ...  Cells Block is performed and verify if all cells are in expected state.
    ...  Cells Unblock is performed and verify if all cells are in expected state.
    ...  All available RATs are blocked and unblocked.
    ...  Reset all available RATs.

Resource  ../../common_resources/ca_WebEM_mobile.robot


*** Variables ***
${RECOVERY_TIMEOUT}  1200  # Timeout for SBTS to recover.


*** Keywords ***
TC__WebEM__Mobile_Simplified_Site_View_for_ASOE
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21844
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.09.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21844 - Initial TAT creation
    ...  - 20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22067 - Adapt WebEM TCs for CNI-61110
    ...  - 05.04.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22931 - Wrong check for RAT block/unblock
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  - 15.05.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25322 - Adding recovery actions
    ...  - 11.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26374 - Resolving issue with element not found in Click Element kw
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS21B

    Step1: Site Block/Unblock And Reset Site
    Step2: RMODs Reset And Cells Block/Unblock
    Step3: RATs Block/Unblock
    Step4: RATs Reset


Step1: Site Block/Unblock And Reset Site
    Log  \nStep1: Site Block/Unblock and Reset Site  console=true
    Site Block Via Mobile
    Log  Site was blocked successfully![OK]  console=true
    Site Unblock Via Mobile
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    Log  All cells are Enabled!  console=true
    Log  Site was unblocked successfully![OK]  console=true
    Check Session Has Not Timedout
    Reset SBTS From Admin Via Mobile Confirmation Canceled
    Reset SBTS From Admin Via Mobile
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    Log  All cells are Enabled!  console=true
    Log  Site was reset successfully![OK]  console=true


Step2: RMODs Reset And Cells Block/Unblock
    Log  Step2: RMODs Reset and Cells Block/Unblock  console=true
    RMODs Reset Confirmation Canceled Via Mobile
    RMODs Reset Via Mobile
    Log  Wait for all cells to be Online!  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    Log  All cells are Enabled!  console=true
    Run Keyword If  ${SCF_COUNT_GSM}
    ...  GSM Cells Block/Unblock And Verify GNCEL
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  WCDMA Cells Block/Unblock And Verify WNCEL
    Run Keyword If  ${SCF_COUNT_LTE}
    ...  LTE Cells Block/Unblock And Verify LNCEL
    Run Keyword If  ${SCF_COUNT_NR}
    ...  NR Cells Block/Unblock And Verify NRCEL


Step3: RATs Block/Unblock
    Log  \nStep3: RATs Block/Unblock  console=true
    Run Keyword If  ${SCF_COUNT_GSM}
    ...  GSM RAT Block/Unblock And Verify GNCEL
    ...  ELSE
    ...  Log  No GSM cell exists!  console=true
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  WCDMA RAT Block/Unblock And Verify WNCEL
    ...  ELSE
    ...  Log  No WCDMA cell exists!  console=true
    Run Keyword If  ${SCF_COUNT_LTE}
    ...  LTE RAT Block/Unblock And Verify LNCEL
    ...  ELSE
    ...  Log  No LTE cell exists!  console=true
    Run Keyword If  ${SCF_COUNT_NR}
    ...  NR RAT Block/Unblock And Verify NRCEL
    ...  ELSE
    ...  Log  No NR cell exists!  console=true


Step4: RATs Reset
    Log  \nStep4: RATs Reset  console=true
    Run Keyword If  ${SCF_COUNT_GSM}
    ...  GSM Reset And Verify GNCEL
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  WCDMA Reset And Verify WNCEL
    Run Keyword If  ${SCF_COUNT_LTE}
    ...  LTE Reset And Verify LNCEL
    Run Keyword If  ${SCF_COUNT_NR}
    ...  NR Reset And Verify NRCEL


${rat} Cells Block/Unblock And Verify ${cell}
    Block Cells Confirmation Canceled Via Mobile  ${rat}
    Block Cells Via Mobile  ${rat}
    Check Session Has Not Timedout
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All ${cell} Blocking State To Be Blocked
    Log  ${rat} Cells are Blocked![OK]  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All ${cell} Availability Status To Be ${OFFLINE}
    Log  ${rat} Cells are Offline![OK]  console=true
    Log  ${rat} cells were successfully blocked!  console=true
    Verify If ${rat} Cell Button Is Unblock
    Unblock Cells Confirmation Canceled Via Mobile  ${rat}
    Unblock Cells Via Mobile  ${rat}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All ${cell} Blocking State To Be Unblocked
    Log  ${rat} Cells are Unblocked![OK]  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All ${cell} Operational State To Be ${ENABLED}
    Log  ${rat} Cells are Enabled![OK]  console=true
    Log  ${rat} cells were successfully unblocked!  console=true
    Verify If ${rat} Cell Button Is Block


${rat} RAT Block/Unblock And Verify ${cell}
    RAT Block Confirmation Canceled Via Mobile  ${rat}
    RAT Block Via Mobile  ${rat}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All ${cell} Blocking State To Be Blocked
    Log  ${rat} Cells are Blocked![OK]  console=true
    Run Keyword If  '${rat}' == 'GSM'
    ...  Run Keywords
    ...  Check All GNCEL Administrative State To Be ${UNLOCKED}
    ...  AND
    ...  Log  ${rat} Cells are Unlocked![OK]  console=true
    Log  ${rat} RAT was blocked successfully!  console=true
    Sleep  20s
    Check Alarm To Be Present  4614 RAT blocked  ${rat}
    Verify If ${rat} RAT Button Is Unblock
    RAT Unblock Confirmation Canceled Via Mobile  ${rat}
    RAT Unblock Via Mobile  ${rat}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All ${cell} Blocking State To Be Unblocked
    Log  ${rat} Cells are Unblocked![OK]  console=true
    Run Keyword If  '${rat}' == 'GSM'
    ...  Run Keywords
    ...  Check All GNCEL Administrative State To Be Unlocked
    ...  AND
    ...  Log  ${rat} Cells are Unlocked![OK]  console=true
    Run Keyword If  '${rat}' == 'NR'
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All NRCEL Operational State To Be ${ENABLED}
    Log  ${rat} RAT was unblocked successfully!  console=true
    Verify If ${rat} RAT Button Is Block


${rat} Reset And Verify ${cell}
    RAT Reset Confirmation Canceled Via Mobile  ${rat}
    RAT Reset Via Mobile  ${rat}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All ${cell} Availability Status To Be ${OFFLINE}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All ${cell} Operational State To Be ${ENABLED}
    Log  ${rat} Cells are Enabled!  console=true
    Log  ${rat} RAT was reset successfully!  console=true


Check All ${technology_cells} Availability Status To Be ${availability_status}
    Assert Every  ${technology_cells}  availabilityStatus=${availability_status}  timeout=60


Check All ${technology_cells} Administrative State To Be ${administrative_state}
    Assert Every  ${technology_cells}  administrativeState=${administrative_state}  timeout=60


Check All ${technology_cells} Blocking State To Be ${blocking_state}
    Assert Every  ${technology_cells}  blockingState=${blocking_state}  timeout=60


Check All ${technology_cells} Operational State To Be ${operational_state}
    Assert Every  ${technology_cells}  operationalState=${operational_state}  timeout=60


Check Session Has Not Timedout
    ${status_session}  Run Keyword And Return Status
    ...  Element Should Be Visible  //*[@id="mobile-login-view"]/div/login/div/form/div[6]/div[1]/div[1]/p-button
    Run Keyword If  ${status_session}
    ...  Run Keywords
    ...  Log  Web session has timed out. Retrying login!  console=true
    ...  AND
    ...  Login SBTS Via Mobile
    ...  AND
    ...  Legal Notice Via Mobile


Recovery Action For Blocked RATs
    Run Keyword If  ${SCF_COUNT_GSM}
    ...  Unblock Rat  GSM  timeout=300
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  Unblock Rat  WCDMA  timeout=300
    Run Keyword If  ${SCF_COUNT_LTE}
    ...  Unblock Rat  LTE  timeout=300
    Run Keyword If  ${SCF_COUNT_NR}
    ...  Unblock Rat  NR  timeout=300


Recovery Action For Blocked Cells
    Run Keyword If  ${SCF_COUNT_GSM}
    ...  Unblock All Cells  GSM  timeout=300
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  Unblock All Cells  WCDMA  timeout=300
    Run Keyword If  ${SCF_COUNT_LTE}
    ...  Unblock All Cells  LTE  timeout=300
    Run Keyword If  ${SCF_COUNT_NR}
    ...  Unblock All Cells  NR  timeout=300


Recovery Actions Via Mobile
    ${fault_50_params}  Get String With Alarm Parameters  ${FAULT_50}
    ${fault_4614_params}  Get String With Alarm Parameters  ${FAULT_4614}
    ${fault_49_params}  Get String With Alarm Parameters  ${FAULT_49}
    ${status_bts}  Run Keyword And Return Status
    ...  Assert Alarm Active  parameters=${fault_50_params}  timeout=120
    ${status_rat}  Run Keyword And Return Status
    ...  Assert Alarm Active  parameters=${fault_4614_params}  timeout=120
    ${status_cells}  Run Keyword And Return Status
    ...  Assert Alarm Active  parameters=${fault_49_params}  timeout=120
    Run Keyword If  ${status_bts}
    ...  Site Unblock Via Mobile
    ...  ELSE IF  ${status_rat}
    ...  Run Keyword And Ignore Error
    ...  Recovery Action For Blocked RATs
    ...  ELSE IF  ${status_cells}
    ...  Run Keyword And Ignore Error
    ...  Recovery Action For Blocked Cells
    ...  ELSE
    ...  coam.Reset Site
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    Log  All cells are Enabled!  console=true


TC Setup
    Common Test Setup  tc_name=WebEM__Mobile_Simplified_Site_View_for_ASOE
    WebEM Setup Via Mobile


TC Teardown
    Run Keyword If Test Failed
    ...  Recovery Actions Via Mobile
    WebEM Teardown Via Mobile
    Common Test Teardown
