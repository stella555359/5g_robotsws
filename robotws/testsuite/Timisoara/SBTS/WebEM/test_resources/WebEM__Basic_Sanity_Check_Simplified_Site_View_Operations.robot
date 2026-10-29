*** Settings ***
Documentation
    ...  This test case is created to perform operations on selected units.
    ...  Site Block is performed. Site Unblock is performed and verify if all cells are in expected state.
    ...  Reset site is performed and verify if all cells are in expected state.
    ...  Reset BBMODs that supports 5G and check all cells.
    ...  Lock/unlock all BBMODs and check all cells.
    ...  Reset all RMODS and check all cells.
    ...  Lock/unlock all RMODs and check all cells.
    ...  Cells Block is performed and verify if all cells are in expected state.
    ...  Cells Unblock is performed and verify if all cells are in expected state.
    ...  All available RATs are blocked and unblocked.
    ...  Reset all available RATs.
    ...  Block/unblock four random TRXs if GSM is available on SBTS.
    ...  All operations are verified in Operation History.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${DISABLED_TIMEOUT}  600  # Time for SBTS to be disabled.
${RECOVERY_TIMEOUT}  1200  # Time for SBTS to recovery.


*** Keywords ***
TC__WebEM__Basic_Sanity_Check_Simplified_Site_View_Operations
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-21225
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 21.04.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21225 - Initial TAT creation
    ...  - 20.10.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22067 - Adapt WebEM TCs for CNI-61110
    ...  - 16.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22199 - Some KWs are moved in ca_WebEM_general
    ...  - 12.09.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23223 - Improve the test
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  - 10.10.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26227 - Changes according to CB008880
    ...  - 08.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26880 - Changes for RAT reset button
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  - 16.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27749 - Improve TC
    ...  - 16.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28622 - Fix reset method for ABIA BBMODs
    ...  - 28.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28821 - Fix ABIA Reset in Op History
    ...  - 17.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30283 - Fix TRXs block/unblock method

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-SBTS21

    Step1: Site Block/unblock And Reset
    Step2: BBMODs Reset And Lock/unlock
    Step3: RMODs Reset And Lock/unlock
    Step4: Cells Block/unblock
    Step5: RAT Block/unblock
    Step6: RAT Reset
    Step7: TX Block/Unblock


Step1: Site Block/unblock And Reset
    Log  \nStep1: Site block/unblock and reset  console=true
    Set Window Size  ${1920}  ${2000}
    Open Operations History
    Site Block
    ${cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  120  5
    ...  Check All Cells To Be Blocked
    IF  ${cells_status}
        Log  All cells are blocked![OK]  console=true
    ELSE
        Fail  Not all cells are blocked after ${RECOVERY_TIMEOUT}s![NOK]
    END
    Log  Site was blocked successfully![OK]  console=true
    Wait Until Keyword Succeeds  120  5
    ...  Check A Specific Operation In Operations History  Block
    Sleep  10s
    Site Unblock
    ${cells_status_blocking_state}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells To Be Unblocked
    ${cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    IF  ${cells_status_blocking_state} and ${cells_status}
        Log  All cells are unblocked and enabled![OK]  console=true
    ELSE
        Fail  Not all cells are unblocked and enabled after ${RECOVERY_TIMEOUT}s![NOK]
    END
    Log  Site was unblocked successfully![OK]  console=true
    Wait Until Keyword Succeeds  120  5
    ...  Check A Specific Operation In Operations History  Unblock
    Reset SBTS From Admin Confirmation Canceled
    Reset SBTS From Admin
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    IF  ${status}
        Log  All cells are Enabled![OK]  console=true
    ELSE
        Fail  Not all cells are Enabled![NOK]
    END
    Log  Site was reset successfully![OK]  console=true
    Wait Until Keyword Succeeds  120  5
    ...  Check A Specific Operation In Operations History  Site reset


Step2: BBMODs Reset And Lock/unlock
    Log  \nStep2: BBMODs reset and lock/unlock  console=true
    ${bbmods_name_list}  Get BBMODs Name
    ${last_bbmod_name}  Get From List  ${bbmods_name_list}  -1
    BBMODs Reset Confirmation Canceled
    BBMODs Reset
    Log  Wait for all cells to be Enabled!  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    IF  ${status}
        Log  All cells are Enabled [OK].  console=true
    ELSE
        Fail  Not all cells are Enabled after BBMODs reset [NOK].
    END
    IF  '${last_bbmod_name}' == 'ABIA'
        Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  5
        ...  Check ABIA Reset In Operations History
    ELSE
        Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  5
        ...  Check A Specific Operation In Operations History  Warm reset
    END
    Lock BBMODs Confirmation Canceled
    Lock BBMODs
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${DISABLED_TIMEOUT}  10
    ...  Check Cells To Be Dependency  ${DEPENDENCY}
    IF  ${status}
        Log  All cells are Dependency![OK]  console=true
    ELSE
        Fail  Not all cells are Dependency![NOK]
    END
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  5
    ...  Check A Specific Operation In Operations History  Activate plan
    Unlock BBMODs Confirmation Canceled
    Unlock BBMODs
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    IF  ${status}
        Log  All cells are Enabled![OK]  console=true
    ELSE
        Fail  Not all cells are Enabled![NOK]
    END
    Wait Until Keyword Succeeds  120  5
    ...  Check A Specific Operation In Operations History  Activate plan


Step3: RMODs Reset And Lock/unlock
    Log  \nStep3: RMODs reset and lock/unlock  console=true
    RMODs Reset Confirmation Canceled
    RMODs Reset
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    IF  ${status}
        Log  All cells are Enabled [OK].  console=true
    ELSE
        Fail  Not all cells are Enabled after RMODs reset [NOK].
    END
    IF  '${ENB_BRANCH}' >= 'SBTS24R3'
        Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  5
        ...  Check A Specific Operation In Operations History  Hard reset
    ELSE
        Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  5
        ...  Check A Specific Operation In Operations History  Hardware reset
    END
    Lock RMODs Confirmation Canceled
    Lock RMODs
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${DISABLED_TIMEOUT}  10
    ...  Check Cells To Be Dependency  ${DEPENDENCY}
    IF  ${status}
        Log  All cells are Dependency![OK]  console=true
    ELSE
        Fail  Not all cells are Dependency![NOK]
    END
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  5
    ...  Check A Specific Operation In Operations History  Activate plan
    Unlock RMODs Confirmation Canceled
    Unlock RMODs
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    IF  ${status}
        Log  All cells are Enabled![OK]  console=true
    ELSE
        Fail  Not all cells are Enabled![NOK]
    END
    Wait Until Keyword Succeeds  120  5
    ...  Check A Specific Operation In Operations History  Activate plan


Step4: Cells Block/unblock
    Log  \nStep4: Cells block/unblock  console=true
    IF  ${SCF_COUNT_GSM}  GSM Cells Block/Unblock And Verify GNCEL
    IF  ${SCF_COUNT_WCDMA}  WCDMA Cells Block/Unblock And Verify WNCEL
    IF  ${SCF_COUNT_LTE}  LTE Cells Block/Unblock And Verify LNCEL
    IF  ${SCF_COUNT_NR}  NR Cells Block/Unblock And Verify NRCEL
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    IF  ${status}
        Log  All cells are Enabled![OK]  console=true
    ELSE
        Fail  Not all cells are Enabled![NOK]
    END


Step5: RAT Block/unblock
    Log  \nStep5: RAT block/unblock  console=true
    IF  ${SCF_COUNT_GSM}  GSM RAT Block/Unblock And Verify GNCEL
    IF  ${SCF_COUNT_WCDMA}  WCDMA RAT Block/Unblock And Verify WNCEL
    IF  ${SCF_COUNT_LTE}  LTE RAT Block/Unblock And Verify LNCEL
    IF  ${SCF_COUNT_NR}  NR RAT Block/Unblock And Verify NRCEL
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    IF  ${status}
        Log  All cells are Enabled![OK]  console=true
    ELSE
        Fail  Not all cells are Enabled![NOK]
    END


Step6: RAT Reset
    Log  \nStep6: RAT reset  console=true
    IF  ${SCF_COUNT_GSM}  GSM RAT Reset And Verify GNCEL
    IF  ${SCF_COUNT_WCDMA}  WCDMA RAT Reset And Verify WNCEL
    IF  ${SCF_COUNT_LTE}  LTE RAT Reset And Verify LNCEL
    IF  ${SCF_COUNT_NR}  NR RAT Reset And Verify NRCEL


Step7: TX Block/Unblock
    IF  ${SCF_COUNT_GSM}
        Log  Step7: TX Block/Unblock  console=true
        Choose Four Random TRX And Block/unblock
    END


Choose Four Random TRX And Block/unblock
    Wait Until Element Is Clicked  //*[contains(@heading, "Detailed Site View")]/a  120
    Sleep  10s  Time for the page to be visible.
    ${gncels_id}  coam.Get Ids For All  GNCEL
    ${trxs_list}  Create List
    ${trx_parameters}  Create List
    FOR  ${gncel}  IN  @{gncels_id}
        ${param}  coam.Get Cell Specific Info  ${gncel}
        ${length}  Get Length  ${param}[trxInformation]
        IF  ${length} >= 1
            FOR  ${index}  IN RANGE  0  ${length}
                Append To List  ${trxs_list}  ${param}[trxInformation][${index}][trxId]
            END
        END
    END
    ${random_trx_list}  Evaluate  random.sample(${trxs_list}, 4)  modules=random
    FOR  ${trx_index}  IN  @{random_trx_list}
        Wait Until Keyword Succeeds  30s  5s  Scroll Element Into View
        ...  //*[contains(@class, 'site-cell-channel-container TRX online-channel')]/../..//span[contains(text(), '${trx_index}')]
        Click Element  //*[contains(@class, 'site-cell-channel-container TRX online-channel')]/../..//span[contains(text(), '${trx_index}')]
        Log  \nBlock for ${trx_index} will be performed!  console=true
        Wait Until Keyword Succeeds  30s  5s  Scroll Element Into View  //*[contains(text(), 'Block TRX')]
        Click Element  xpath=//*[contains(text(), 'Block TRX')]
        Wait Until Element Is Clicked  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[2]/button  120
        Log  Block for ${trx_index} is canceled!  console=true
        Log  Block for ${trx_index} will be performed!  console=true
        Wait Until Element Is Clicked  //*[contains(text(), 'Block TRX')]  60
        Wait Until Element Is Clicked  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button  120
        Wait Until Element Is Visible  xpath=//*[contains(text(), 'Blocked')]  300
        Log  ${trx_index} is blocked!  console=true
        Wait Until Keyword Succeeds  120  5
        ...  Check A Specific Operation In Operations History  Block
        Log  Unblock for ${trx_index} will be performed!  console=true
        Wait Until Keyword Succeeds  30s  5s  Scroll Element Into View  //*[contains(text(), 'Unblock TRX')]
        Click Element  xpath=//*[contains(text(), 'Unblock TRX')]
        Wait Until Element Is Clicked  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[2]/button  120
        Log  Unblock for ${trx_index} is canceled!  console=true
        Log  Unblock for ${trx_index} will be performed!  console=true
        Wait Until Element Is Clicked  //*[contains(text(), 'Unblock TRX')]  60
        Wait Until Element Is Clicked  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button  120
        Wait Until Element Is Visible  xpath=//*[contains(text(), 'Unblocked')]  300
        Log  ${trx_index} is unblocked!  console=true
        Wait Until Keyword Succeeds  120  5
        ...  Check A Specific Operation In Operations History  Unblock
    END
    Wait Until Keyword Succeeds  120  3
    ...  Go To Site View
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All GNCEL Blocking State To Be Unblocked
    Log  GSM Cells are Unblocked![OK]  console=true
    Check RF Module Filter Alarm Is Not Visible


Check RF Module Filter Alarm Is Not Visible
    ${active_alarm}  Get Active Alarms From WebEM
    ${status}  Run Keyword And Return Status
    ...  Dictionary Should Not Contain Key  ${active_alarm}  1910
    IF  ${status}
        Log  Alarm with faultId 1910 and faultName "RF Module filter input power missing" is not visible![OK]  console=true
    ELSE
        Recovery Action For TRX Block/unblock
        Fail  Alarm with faultId 1910 and faultName "RF Module filter input power missing" is visible![NOK]
    END

${rat} Cells Block/Unblock And Verify ${cell}
    Log  \n${rat} cells will be blocked!  console=true
    Block Cells Confirmation Canceled  ${rat}
    Log  Operation is canceled!  console=true
    Log  \n${rat} cells will be blocked!  console=true
    Block Cells  ${rat}
    Wait Until Keyword Succeeds  ${DISABLED_TIMEOUT}  10
    ...  Check All ${cell} Blocking State To Be Blocked
    Log  ${rat} Cells are Blocked![OK]  console=true
    Wait Until Keyword Succeeds  ${DISABLED_TIMEOUT}  10
    ...  Check All ${cell} Availability Status To Be ${OFFLINE}
    Log  ${rat} Cells are Offline![OK]  console=true
    Log  ${rat} cells were successfully blocked!  console=true
    Wait Until Keyword Succeeds  300  5
    ...  Check A Specific Operation In Operations History  Block
    Log  \n${rat} cells will be unblocked!  console=true
    Unblock Cells Confirmation Canceled  ${rat}
    Log  Operation is canceled!  console=true
    Log  \n${rat} cells will be unblocked!  console=true
    Unblock Cells  ${rat}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All ${cell} Blocking State To Be Unblocked
    Log  ${rat} Cells are Unblocked![OK]  console=true
    Log  ${rat} cells were successfully unblocked!  console=true
    Wait Until Keyword Succeeds  300  5
    ...  Check A Specific Operation In Operations History  Unblock


${rat} RAT Reset And Verify ${cell}
    RAT Reset Confirmation Canceled  ${rat}
    RAT Reset  ${rat}
    Wait Until Keyword Succeeds  ${DISABLED_TIMEOUT}  10
    ...  Check All ${cell} Availability Status To Be ${OFFLINE}
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    IF  ${status}
        Log  All cells are Enabled![OK]  console=true
    ELSE
        Fail  Not all cells are Enabled![NOK]
    END
    Log  ${rat} RAT was reset successfully!  console=true
    IF  '${ENB_BRANCH}' == 'SBTS24R2' and '${rat}' in ['LTE', 'NR']
        Wait Until Keyword Succeeds  300  5
        ...  Check A Specific Operation In Operations History  Software reset
    ELSE IF  '${ENB_BRANCH}' >= 'SBTS24R3' and '${rat}' in ['LTE', 'NR']
        Wait Until Keyword Succeeds  300  5
        ...  Check A Specific Operation In Operations History  Soft reset
    ELSE IF  '${ENB_BRANCH}' >= 'SBTS24R3' and '${rat}' in ['GSM', 'WCDMA']
        Wait Until Keyword Succeeds  300  5
        ...  Check A Specific Operation In Operations History  Hard reset
    ELSE
        Wait Until Keyword Succeeds  300  5
        ...  Check A Specific Operation In Operations History  Hardware reset
    END


${rat} RAT Block/Unblock And Verify ${cell}
    RAT Block Confirmation Canceled  ${rat}
    RAT Block  ${rat}
    Wait Until Keyword Succeeds  ${DISABLED_TIMEOUT}  10
    ...  Check All ${cell} Blocking State To Be Blocked
    Log  ${rat} Cells are Blocked![OK]  console=true
    Log  ${rat} RAT was blocked successfully!  console=true
    Wait Until Keyword Succeeds  300  5
    ...  Check A Specific Operation In Operations History  Block
    RAT Unblock Confirmation Canceled  ${rat}
    RAT Unblock  ${rat}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All ${cell} Blocking State To Be Unblocked
    Log  ${rat} Cells are Unblocked![OK]  console=true
    Log  ${rat} RAT was unblocked successfully!  console=true
    Wait Until Keyword Succeeds  300  5
    ...  Check A Specific Operation In Operations History  Unblock


Check All Cells To Be ${blocking_state}
    IF  ${SCF_COUNT_WCDMA}  Assert Every  WNCEL  blockingState=${blocking_state}  timeout=60
    IF  ${SCF_COUNT_LTE}  Assert Every  LNCEL  blockingState=${blocking_state}  timeout=60
    IF  ${SCF_COUNT_GSM}  Assert Every  GNCEL  blockingState=${blocking_state}  timeout=60
    IF  ${SCF_COUNT_NR}  Assert Every  NRCEL  blockingState=${blocking_state}  timeout=60


Check Cells To Be Dependency
    [Arguments]  ${availability_state}

    IF  ${SCF_COUNT_WCDMA}  Assert Every  WNCEL  availabilityStatus=${availability_state}  timeout=60
    IF  ${SCF_COUNT_LTE}  Assert Every  LNCEL  availabilityStatus=${availability_state}  timeout=60
    IF  ${SCF_COUNT_GSM}  Assert Every  GNCEL  availabilityStatus=${availability_state}  timeout=60
    IF  ${SCF_COUNT_NR}  Assert Every  NRCEL  availabilityStatus=${availability_state}  timeout=60


Recovery Action For TRX Block/unblock
    Log  Reset Site will be performed as a recovery action because alarm is visible!  console=true
    coam.Reset Site
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells


TC Setup
    Common Test Setup  tc_name=WebEM__Basic_Sanity_Check
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
