*** Settings ***
Documentation
    ...  This test case is created to automatically log off and session lock.
    ...  Set session lock on 15min and session logout on 900s.
    ...  Wait 15min and check if logout is performed instead session lock.
    ...  Login to WebEM again.
    ...  Trigger snapshot collection.
    ...  Verify if logout is perform after session lock.
    ...  Login to WebEM again.
    ...  Triger Troubleshooting script for a random LTE cell.
    ...  Verify if logout is perform after session lock.
    ...  Login to WebEM again.
    ...  Set session logout on 960s.
    ...  Wait for lock screen to happened after 15 min and logout 1 min later.
    ...  Login to WebEM again.
    ...  Restore the original scf.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Automatically_log_off_and_Session_Lock
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22508
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22508 - Initial TAT creation
    ...  - 12.08.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23542 - Changing session lock/logout verification
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 21.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26148 - Changing xpaths for login
    ...  - 03.07.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27620 - New steps added

    Set Tags  CA-WebEM  OWNER-george.gheban@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS22  FEATURE-CNI-38910_1SB_FD1

    Step1: Set Session Lock On 15min And Session Logout On 900s
    Step2: Wait 15min And Check If Logout Is Performed
    Step3: Trigger Snapshot Collection And Verify If Session Logout Is Perform After Session Lock
    Step4: Triger Troubleshooting Script And Verify If Session Logout Is Perform After Session Lock
    Step5: Set Session Logout On 960s And Wait For Lock Screen To Happened After 15 Min And Logout 1 Min Later
    Step6: Restore The Original Scf


Step1: Set Session Lock On 15min And Session Logout On 900s
    Log  \nStep1: Set session lock on 15min and session logout on 900s  console=true
    Log  Set webEMSessionLogoutTimer on 900s!  console=true
    Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1  webEMSessionLogoutTimer  update  900  skip_parameter_relation_errors=true
    Log  webEMSessionLogoutTimer was setting successfully!  console=true
    Change Session Lock Value  15


Step2: Wait 15min And Check If Logout Is Performed
    Log  \nStep2: Wait 15min and check if logout is performed  console=true
    Sleep  860s  Time for session lock pop-up to be visible
    Page Should Contain Element  //*[contains(text(), "Screen Lock")]
    Log  Screen lock pop-up is visible!  console=true
    Wait Until Element Is Visible  //*[@id="login-username"]  120s
    Log  Logout was performed!  console=true
    Log  Login to SBTS again is performing!  console=true
    Login SBTS
    Legal Notice
    Log  Wait until the page is loaded.  console=true
    Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[1]/div  30s  WebElement is not fully loaded in 30s seconds.


Step3: Trigger Snapshot Collection And Verify If Session Logout Is Perform After Session Lock
    Log  \nStep3: Trigger snapshot collection and verify if session logout is perform after session lock  console=true
    Open Snapshot Collection
    Log  Collect snapshot is performing!  console=true
    Wait Until Element Is Clicked  //*[contains(@a-text, 'Collect Snapshot')]/button
    Wait Until Element Is Visible  //*[contains(text(), "Collection completed")]  600
    Log  'Collection completed' text is visible!  console=true
    ${elapsed_time}  Get Text  //*[@timer-id="snapshotTimerId"]/div
    ${minutes}  Fetch From Right  ${elapsed_time}  Elapsed time: 00:0
    ${minute}  Fetch From Left  ${minutes}  :
    ${minutes_for_logout}  Evaluate  ${minute} + 2
    ${minutes_for_lock}  Evaluate  15 - ${minute} - 1
    Log  Sleep ${minutes_for_lock}m for session lock pop-up to be visible  console=true
    Sleep  ${minutes_for_lock}m  Time for session lock pop-up to be visible
    Wait Until Element Is Visible  //*[contains(text(), "Screen Lock")]  60s
    Log  Screen lock pop-up is visible!  console=true
    Wait Until Element Is Visible  //*[@id="screen-lock-password-input"]  70s
    Log  Screen lock page is visible!  console=true
    Log  Sleep ${minutes_for_logout} min for logout page to be visible!  console=true
    Sleep  ${minutes_for_logout}  Time for session logout page to be visible
    Wait Until Element Is Visible  //*[@id="login-username"]  200s
    Log  Logout was performed!  console=true
    Log  Login to SBTS again is performing!  console=true
    Login SBTS
    Legal Notice
    Log  Wait until the page is loaded.  console=true
    Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[1]/div  30s  WebElement is not fully loaded in 30s seconds.


Step4: Triger Troubleshooting Script And Verify If Session Logout Is Perform After Session Lock
    Log  \nStep4: Triger Troubleshooting script and verify if session logout is perform after session lock  console=true
    Open Diagnostic Menu
    Click Element  //*[contains(text(), "Troubleshooting Scripts")]
    Log  Troubleshooting Scripts is open!  console=true
    Log  Waiting for text "Fetching succeeded" to appear!  console=true
    ${status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  300  5
    ...  Element Should Be Visible  //*[contains(text(), 'Fetching succeeded')]
    Run Keyword If  ${status}
    ...  Log  Text "Fetching succeeded" appeard![OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Text "Fetching succeeded" is not appeard![NOK]
    Wait Until Element Is Clicked  //*[contains(@aria-label, 'l2_lte_col_cell')]
    Wait Until Element Is Clicked  //*[contains(@optionlabel, 'cellName')]/div/p-multiselect/div/div[2]  60
    ${div_number}  Set Variable If  '${GUI_VERSION}' == 'new'  2  3
    ${number_of_cells}  SeleniumLibrary.Get Element Count  xpath:/html/body/div[${div_number}]/div[2]/ul/p-multiselectitem
    FOR  ${cell}  IN RANGE  1  ${number_of_cells}+1
        ${cell_id}  Get Text  xpath:/html/body/div[${div_number}]/div[2]/ul/p-multiselectitem[${cell}]
        ${status_cell_name}  Run Keyword And Return Status
        ...  Should Match Regexp  ${cell_id}  LNCEL-*
        Run Keyword If  ${status_cell_name}
        ...  Run Keywords
        ...  Log  Cell ${cell_id} will be choose!  console=true
        ...  AND
        ...  Click Element  xpath://*[contains(text(), "${cell_id}")]
        ...  AND
        ...  Exit For Loop
    END
    Wait Until Element Is Clicked  //*[contains(@optionlabel, 'cellName')]/div/p-multiselect/div/div[2]  60
    Log  Launch script will be performed!  console=true
    Click Element  //*[contains(@class, 'launch-script')]/p-button/button
    Log  Wait until text with Collection completed appears!  console=true
    Wait Until Element Is Visible  //div[contains(text(), "Collection completed")]  300
    Log  'Collection completed' text is visible!  console=true
    ${elapsed_time}  Get Text  //*[contains(@class, 'troubleshooting-main-script')]/stopwatch/div
    ${minutes}  Fetch From Right  ${elapsed_time}  Elapsed time: 00:0
    ${minute}  Fetch From Left  ${minutes}  :
    ${minutes_for_logout}  Evaluate  ${minute} + 2
    ${minutes_for_lock}  Run Keyword If  ${minute}==0
    ...  Set Variable  14
    ...  ELSE
    ...  Evaluate  15 - ${minute}
    Log  Sleep ${minutes_for_lock}m for session lock pop-up to be visible  console=true
    Sleep  ${minutes_for_lock}m  Time for session lock pop-up to be visible
    Wait Until Element Is Visible  //*[contains(text(), "Screen Lock")]  60s
    Log  Screen lock pop-up is visible!  console=true
    Wait Until Element Is Visible  //*[@id="screen-lock-password-input"]  70s
    Log  Screen lock page is visible!  console=true
    Log  Sleep ${minutes_for_logout} min for logout page to be visible!  console=true
    Sleep  ${minutes_for_logout}  Time for session logout page to be visible
    Wait Until Element Is Visible  //*[@id="login-username"]  200s
    Log  Logout was performed!  console=true
    Log  Login to SBTS again is performing!  console=true
    Login SBTS
    Legal Notice
    Log  Wait until the page is loaded.  console=true
    Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[1]/div  30s  WebElement is not fully loaded in 30s seconds.


Step5: Set Session Logout On 960s And Wait For Lock Screen To Happened After 15 Min And Logout 1 Min Later
    Log  \nStep5: Set session logout on 960s and wait for lock screen to happened after 15 min and logout 1 min later  console=true
    Log  Set webEMSessionLogoutTimer on 960s!  console=true
    Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1  webEMSessionLogoutTimer  update  960  skip_parameter_relation_errors=true
    Log  webEMSessionLogoutTimer was setting successfully!  console=true
    Open Diagnostic Menu
    Go To Site View
    Log  Sleep ~15 min and wait for session lock pop-up!  console=true
    Sleep  850s  Time for session lock pop-up to be visible
    Wait Until Element Is Visible  //*[contains(text(), "Screen Lock")]  60s
    Log  Screen lock pop-up is visible!  console=true
    Wait Until Keyword Succeeds  120  5s
    ...  Page Should Contain  Session locked
    Log  Screen lock page is visible!  console=true
    Wait Until Element Is Visible  //*[@id="login-username"]  130s
    Log  Logout was performed!  console=true
    Log  Login to SBTS again is performing!  console=true
    Login SBTS
    Legal Notice
    Log  Wait until the page is loaded.  console=true
    Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[1]/div  30s  WebElement is not fully loaded in 30s seconds.


Step6: Restore The Original Scf
    Log  \nStep6: Restore the original scf  console=true
    Admin Get Bts_id And Perform Commissioning  ${COMMISSIONING_PATH}
    Close Startup View If Visible
    Wait Until Keyword Succeeds  1200  30s
    ...  Check All Cells


TC Setup
    Common Test Setup  tc_name=WebEM__Automatically_log_off_and_Session_Lock
    WebEM Setup


TC Teardown
    Run Keyword If Test Failed
    ...  Step6: Restore The Original Scf
    WebEM Teardown
    Common Test Teardown
