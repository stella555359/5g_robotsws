*** Settings ***
Documentation
    ...  This test case verify number of concurrent webem user sessions.
    ...  Parameter btsEMMaxSimulSession is changed with a default value, 10.
    ...  Checking the number of already active sessions in WebEM via admin cli.
    ...  Opening the number of browsers so that 10 sessions are opened successfully and the page is loaded with OAM IP.
    ...  Save a screenshot for every sesions.
    ...  Open the session number 11 and verify the 'Session establishment error' pop-up.
    ...  All browsers are closed.
    ...  Power off/on is performed to reset the number of sessions.
    ...  All browsers are closed.
    ...  Checking the number of already active sessions in WebEM via admin cli.
    ...  Opening the number of browsers so that 10 sessions are opened successfully and the page is loaded with M-PLANE IP.
    ...  Save a screenshot for every sesions.
    ...  Open the session number 11 and verify the 'Session establishment error' pop-up.
    ...  All browsers are closed.
    ...  Power off/on is performed to reset the number of sessions.


Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__CP_Number_of_concurrent_WebEM_user_sessions_in_a_SBTS
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29865
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 01.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29865 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-SBTS26  FEATURE-C&P

    Step0: Test Preconditions
    Step1: Start Concurrent WebEM User Sessions With OAM IP
    Step2: Verify If The Pop-up Displayed In The Last WebEM Session With OAM IP
    Step3: Start Concurrent WebEM User Sessions With M-PLANE IP
    Step4: Verify If The Pop-up Displayed In The Last WebEM Session With M-PLANE IP


Step0: Test Preconditions
    Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/AMGR-1/LUAC-1  btsEMMaxSimulSession  update  10  skip_parameter_relation_errors=true
    Log  btsEMMaxSimulSession was setting successfully with value 10!  console=true
    Setup Admin CLI  ${ACTIVE_SW_VERSION}  ${MPLANE_IP}


Step1: Start Concurrent WebEM User Sessions With OAM IP
    Log  \nStep1: Start Concurrent WebEM User Sessions With OAM IP  console=true
    Set All Active Sessions
    ${em_remaining_sessions}  Evaluate  10-${EM_ACTIVE_SESSIONS}
    FOR  ${session}  IN RANGE  1  ${em_remaining_sessions}+1
        Open Chrome and Login  ${OAM_BTS_IP}
        Legal Notice
        Log  Wait until the page is loaded.  console=true
        Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[1]/div  60
        ...  WebElement is not fully loaded in 60 seconds.
        ${session_id}  Evaluate  10-${em_remaining_sessions}+${session}
        Capture Page Screenshot  WebEM_SBTS_session_${session_id}.png
        Log  Session number ${session_id} was opened successfully, a screenshot is saved in ${BTS_FILES}/selenium_screenshot_${TEST_NAME}!
        ...  console=true
    END


Step2: Verify If The Pop-up Displayed In The Last WebEM Session With OAM IP
    Log  \nStep2: Verify If The Pop-up Displayed In The Last WebEM Session With OAM IP  console=true
    Open Chrome and Login  ${OAM_BTS_IP}
    Wait Until Element Is Visible  //*[contains(@title, 'Session establishment error')]  300
    Log  In session number 11, pop-up 'Session establishment error' is visible!  console=true
    Page Should Contain  Session couldn't be established. Sessions number limit reached.
    Log  Text 'Session couldn't be established. Sessions number limit reached.' is visible!  console=true
    Capture Page Screenshot  WebEM_SBTS_session_11.png
    Wait Until Element Is Clicked  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/ui-button/button  120
    Legal Notice
    Wait Until Element Is Visible  //*[contains(@data-connection-status, 'mdi mdi-link-variant-off')]  300
    Page Should Contain  No data
    Log  WebEM is disconnected!  console=true
    Set All Active Sessions
    Should Be Equal  ${EM_ACTIVE_SESSIONS}  ${10}  EM active sessions number is not 10![NOK]
    Log  EM active sessions number is 10![OK]  console=true
    Run Keyword And Ignore Error  Close All Browsers
    Recovery action to delete current sessions


Step3: Start Concurrent WebEM User Sessions With M-PLANE IP
    Log  \nStep3: Start Concurrent WebEM User Sessions With M-PLANE IP  console=true
    Open Chrome and Login  ${MPLANE_IP}
    Legal Notice
    Log  Wait until the page is loaded.  console=true
    Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[1]/div  60
    ...  WebElement is not fully loaded in 60 seconds.
    Capture Page Screenshot  WebEM_SBTS_mplane_initial_state.png
    Set All Active Sessions
    ${em_remaining_sessions}  Evaluate  10-${EM_ACTIVE_SESSIONS}
    FOR  ${session}  IN RANGE  1  ${em_remaining_sessions}+1
        Open Chrome and Login  ${MPLANE_IP}
        Legal Notice
        Log  Wait until the page is loaded.  console=true
        Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[1]/div  60
        ...  WebElement is not fully loaded in 60 seconds.
        ${session_id}  Evaluate  10-${em_remaining_sessions}+${session}
        Capture Page Screenshot  WebEM_SBTS_mplane_session_${session_id}.png
        Log  Session number ${session_id} was opened successfully, a screenshot is saved in ${BTS_FILES}/selenium_screenshot_${TEST_NAME}!
        ...  console=true
    END


Step4: Verify If The Pop-up Displayed In The Last WebEM Session With M-PLANE IP
    Log  \nStep4: Verify If The Pop-up Displayed In The Last WebEM Session With M-PLANE IP  console=true
    Open Chrome and Login  ${MPLANE_IP}
    Wait Until Element Is Visible  //*[contains(@title, 'Session establishment error')]  300
    Log  In session number 11, pop-up 'Session establishment error' is visible!  console=true
    Page Should Contain  Session couldn't be established. Sessions number limit reached.
    Log  Text 'Session couldn't be established. Sessions number limit reached.' is visible!  console=true
    Capture Page Screenshot  WebEM_SBTS_mplane_session_11.png
    Wait Until Element Is Clicked  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/ui-button/button  120
    Legal Notice
    Wait Until Element Is Visible  //*[contains(@data-connection-status, 'mdi mdi-link-variant-off')]  300
    Page Should Contain  No data
    Log  WebEM is disconnected!  console=true
    Set All Active Sessions
    Should Be Equal  ${EM_ACTIVE_SESSIONS}  ${10}  EM active sessions number is not 10![NOK]
    Log  EM active sessions number is 10![OK]  console=true
    Run Keyword And Ignore Error  Close All Browsers
    Recovery action to delete current sessions


Set All Active Sessions
    ${em_sessions_list}  Create List
    Log  \nSending command via Admin CLI for getActiveSessionList...  console=true
    ${request_status}  ${error_code}  ${request_message}  Admin CLI Send Request  {"requestId":1,"parameters":{"name":"getActiveSessionList"}}
    IF  '${request_status}' == 'completed' and ${error_code} == 0
        Log  Command sent with status: ${request_status} and error code: ${error_code}![OK]  console=true
    ELSE
        Fail  Command sent with status: ${request_status} and error code: ${error_code}![NOK]
    END
    FOR  ${session}  IN  @{request_message}
        ${session_type}  Get From Dictionary  ${session}  type
        IF  '${session_type}' == 'EM'  Append To List  ${em_sessions_list}  ${session_type}
    END
    ${EM_ACTIVE_SESSIONS}  Get Length  ${em_sessions_list}
    Set Test Variable  ${EM_ACTIVE_SESSIONS}
    Log  In active session list are available ${EM_ACTIVE_SESSIONS} sessions of the type EM!  console=true


Recovery action to delete current sessions
    Log  Power off BTS  console=true
    FOR  ${distname}  IN  @{INTERFACES}
        Pdu BTS Interface Off  ${distname}
        Log  Interface ${distname} turned off  console=true
        Sleep  1
    END
    Log  Power on BTS  console=true
    FOR  ${distname}  IN  @{INTERFACES}
        Pdu BTS Interface On  ${distname}
        Log  Interface ${distname} turned on  console=true
        Sleep  1
    END
    ${ping_regain_status}  Run Keyword And Return Status
    ...  Wait For Target To Be Reachable  hostname=${OAM_BTS_IP}  timeout=600
    IF  ${ping_regain_status}==${False}  Fail  Ping has not been regained within timeout
    Wait Until Keyword Succeeds  1200  10
    ...  Admin Check All Required State
    Run Keyword And Ignore Error  Close All Browsers


Open Chrome and Login
    [Arguments]  ${bts_ip}

    ${chrome_options}  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    ${prefs}  Create Dictionary  download.default_directory=/home/ute/Downloads
    Call Method  ${chrome_options}  add_experimental_option  prefs  ${prefs}
    Call Method  ${chrome_options}  add_argument  --ignore-ssl-errors
    Call Method  ${chrome_options}  add_argument  --ignore-certificate-errors
    Call Method  ${chrome_options}  add_argument  --disable-popup-blocking
    IF  ${VIRTUAL_DISPLAY}  Call Method  ${chrome_options}  add_argument  --headless
    Create Webdriver  Chrome  options=${chrome_options}
    Go To  https://${bts_ip}
    Set Window Size  ${1920}  ${1100}
    Check Private Connection
    Login SBTS


TC Setup
    Common Test Setup  tc_name=WebEM__CP_Number_of_concurrent_WebEM_user_sessions
    WebEM Setup
    Change ActCli Parameter  true


TC Teardown
    Change ActCli Parameter  false
    WebEM Teardown
    Run Keyword If Test Failed  Recovery action to delete current sessions
    Common Test Teardown
