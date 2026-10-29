*** Settings ***
Documentation
    ...  This test case verify usability for large configurations WebEM.
    ...  Path to average SCF must be specified.
    ...  Path to big SCF must be specified.
    ...  Map Share1 if doesn't exist.
    ...  Perform site reset, block/unblock one random NR cell, reset one random BBMOD and reset one random RMOD.
    ...  Download application logs, logout and close browser.
    ...  Open WebEM on m-plane ip.
    ...  Repet site reset, block/unblock one random NR cell, reset one random BBMOD and reset one random RMOD.
    ...  Download application logs, logout and close browser.
    ...  Open WebEM on oam ip.
    ...  Change configuration with average SCF.
    ...  Perform site reset, block/unblock one random NR cell, reset one random BBMOD and reset one random RMOD.
    ...  Download application logs, logout and close browser.
    ...  Open WebEM on m-plane ip.
    ...  Repet site reset, block/unblock one random NR cell, reset one random BBMOD and reset one random RMOD.
    ...  Download application logs, logout and close browser.
    ...  Open WebEM on oam ip.
    ...  Change configuration with big SCF.
    ...  Perform site reset, block/unblock one random NR cell, reset one random BBMOD and reset one random RMOD.
    ...  Download application logs, logout and close browser.
    ...  Open WebEM on m-plane ip.
    ...  Repet site reset, block/unblock one random NR cell, reset one random BBMOD and reset one random RMOD.
    ...  Download application logs, logout and close browser.
    ...  Open WebEM on oam ip.
    ...  Change configuration with initial SCF.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${PATH_AVERAGE_SCF}  #Mandatory! Path to average SCF.
${PATH_BIG_SCF}  #Mandatory! Path to big SCF.
${RECOVERY_TIMEOUT}  1200  #Time for SBTS to be onAir
${DISABLED_TIMEOUT}  500  #Time for HW to be disabled.


*** Keywords ***
TC__WebEM__CP_WebEM_usability_for_large_configurations_WebEM
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29880
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 13.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29880 - Initial TAT creation
    ...  - 25.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30226 - Change of BTS Start-up View verification with big scf on m-plane ip
    ...  - 05.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30471 - Change logs2 with share1 because logs2 was deleted
    ...  - 25.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30513 - Change map shares KW

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  SW-SBTS26  FEATURE-C&P

    Step0: Test Preconditions
    Step1: Perform Site Reset, Block/Unblock One NR Cell, Reset One BBMOD, Reset One RMOD and Open WebEM On Ip ${MPLANE_IP}
    Step2: Perform Site Reset, Block/Unblock One NR Cell, Reset One BBMOD, Reset One RMOD and Open WebEM On Ip ${OAM_BTS_IP}
    Step3: Change Configuration With Average SCF from ${PATH_AVERAGE_SCF}
    Step4: Perform Site Reset, Block/Unblock One NR Cell, Reset One BBMOD, Reset One RMOD and Open WebEM On Ip ${MPLANE_IP}
    Step5: Perform Site Reset, Block/Unblock One NR Cell, Reset One BBMOD, Reset One RMOD and Open WebEM On Ip ${OAM_BTS_IP}
    Step6: Change Configuration With Big SCF from ${PATH_BIG_SCF}
    Step7: Perform Site Reset, Block/Unblock One NR Cell, Reset One BBMOD, Reset One RMOD and Open WebEM On Ip ${MPLANE_IP}
    Step8: Perform Site Reset, Block/Unblock One NR Cell, Reset One BBMOD, Reset One RMOD and Open WebEM On Ip ${OAM_BTS_IP}
    Step9: Change Configuration With Initial SCF from ${COMMISSIONING_PATH}


Step0: Test Preconditions
    Should Not Be Empty  ${PATH_AVERAGE_SCF}
    ...  Path to average SCF must be specified, please provide it and retest.
    Should Not Be Empty  ${PATH_BIG_SCF}
    ...  Path to big SCF must be specified, please provide it and retest.
    Map Shares
    Set Window Size  ${1920}  ${1400}


Step${index}: Perform Site Reset, Block/Unblock One NR Cell, Reset One BBMOD, Reset One RMOD and Open WebEM On Ip ${ip}
    Log  \nStep${index}: Perform Site Reset, Block/Unblock One NR Cell, Reset One BBMOD, Reset One RMOD and Open WebEM On Ip ${ip}  console=true
    IF  ${index} == 8
        Reset SBTS From Admin With Close Startup View If Visible
    ELSE
        Reset SBTS From Admin
    END
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State
    Log  All cells and units are onAir!  console=true
    Log  Site was reset successfully![OK]  console=true
    Block One NR Cell
    Unblock The Cell
    Reset One Baseband Module
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State
    Log  All cells and units are onAir!  console=true
    Reset One Radio Module
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State
    Log  All cells and units are onAir!  console=true
    Open WebEM On A Specific IP  ${ip}


Step${index}: Change Configuration With ${type} SCF from ${path_scf}
    Log  \nStep${index}: Change Configuration With ${type} SCF from ${path_scf}  console=true
    Log  Loading ${type} SCF from ${path_scf} will be performed...  console=true
    Load A Specific SCF  ${path_scf}  ${RECOVERY_TIMEOUT}
    Login On WebEM If Lock Screen Or Logout Performed
    Close Startup View If Visible


Open WebEM On A Specific IP
    [Arguments]  ${ip}

    Log  Open WebEM On IP ${ip}  console=true
    Run Keyword And Ignore Error  Download Application Logs
    Run Keyword And Ignore Error  Logout From SBTS
    Close Browser
    ${chrome_options}  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    ${prefs}  Create Dictionary  download.default_directory=/home/ute/Downloads
    Call Method  ${chrome_options}  add_experimental_option  prefs  ${prefs}
    Call Method  ${chrome_options}  add_argument  --ignore-ssl-errors
    Call Method  ${chrome_options}  add_argument  --ignore-certificate-errors
    Call Method  ${chrome_options}  add_argument  --disable-popup-blocking
    IF  ${VIRTUAL_DISPLAY}  Call Method  ${chrome_options}  add_argument  --headless
    Create Webdriver  Chrome  options=${chrome_options}
    Go To  https://${ip}
    Set Window Size  ${1920}  ${1400}
    Check Private Connection
    Login SBTS
    Legal Notice
    Log  Wait until the page is loaded on ${ip}.  console=true
    Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[1]/div  120
    ...  WebElement is not fully loaded in 120 seconds.


Block One NR Cell
    ${cell_xpath}  Evaluate  random.choice(${NR_CELLS_XPATH})  random
    Set Test Variable  ${NR_CELL_XPATH_FOR_BLOCK}  ${cell_xpath}
    Block NR Cell By ${NR_CELL_XPATH_FOR_BLOCK}
    Assert Any  NRCEL  blockingState=${BLOCKED}  timeout=150
    Log  NRCEL is blocked!  console=true


Unblock The Cell
    Wait Until Keyword Succeeds  60  10  Unblock NR Cell By ${NR_CELL_XPATH_FOR_BLOCK}
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State
    Log  All cells are onAir!  console=true


${block_unblock} NR Cell By ${cell_xpath}
    Log  ${block_unblock} one NR cell.  console=true
    Click Element  ${cell_xpath}
    Wait Until Element Is Clicked  //*[contains(text(), '${block_unblock}')][contains(text(), 'Cell')]  60
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button


Reset One Radio Module
    ${xpath}  Evaluate  random.choice(${RMODS_XPATH})  random
    Wait Until Element Is Clicked  xpath=${xpath}
    ${rmod_name}  Get Text  ${xpath}/div/div[3]/div[2]/div[1]
    ${rmod_number}  Get Text  ${xpath}/div/div[3]/div[2]/div[2]
    Log  \nReset for ${rmod_number}: ${rmod_name} will be performed!  console=true
    Wait Until Element Is Clicked  xpath=${xpath}/div/div[3]/div[1]
    ${text_button_reset}  Get Text  ${xpath}/div/div[3]/div[1]/span/div/div[1]/button
    IF  '${text_button_reset}'=='Reset'
        Log  ${rmod_number}: ${rmod_name} Reset button is visible![OK]  console=true
    ELSE
        Log  ${rmod_number}: ${rmod_name} Reset button is not visible![NOK]  console=true
    END
    ${status}  Run Keyword And Return Status  Element Should Be Disabled  ${xpath}/div/div[3]/div[1]/span/div/div[2]/button
    IF  ${status}
        Log  ${rmod_number}: ${rmod_name} Remove button is disabled![OK]  console=true
    ELSE
        Log  ${rmod_number}: ${rmod_name} Remove button is enabled![NOK]  console=true
    END
    Wait Until Element Is Clicked  xpath=${xpath}/div/div[3]/div[1]/span/div/div[1]/button
    Wait Until Element Is Clicked  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button
    Wait Until Keyword Succeeds  ${DISABLED_TIMEOUT}  10  Check RMOD State  ${xpath}  Not installed
    Log  ${rmod_number}: ${rmod_name} is Not installed!  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check RMOD State  ${xpath}  Online|Enabled
    Log  ${rmod_number}: ${rmod_name} is Online!  console=true
    Wait Until Element Is Clicked  xpath=${xpath}/div/div[3]/div[1]
    ${status}  Run Keyword And Return Status  Element Should Be Enabled  ${xpath}/div/div[3]/div[1]/span/div/div[1]/button
    IF  ${status}
        Log  ${rmod_number}: ${rmod_name} was successfully reset!  console=true
        Wait Until Element Is Clicked  xpath=${xpath}/div/div[3]/div[1]
    END


Reset One Baseband Module
    FOR  ${xpath}  IN  @{BBMODS_XPATH}
        Click Element  ${xpath}
        ${bbmod_name}  Get Text  ${xpath}/div/div[2]/div[1]
        ${bbmod_number}  Get Text  ${xpath}/div/div[2]/div[2]
        IF  '${bbmod_name}'=='ABIA' and '${ENB_BRANCH}'>='SBTS25R2'  CONTINUE
        Log  Reset for ${bbmod_number}: ${bbmod_name} will be performed!  console=true
        Click Element  ${xpath}/div/div[1]
        ${status_reset}  Run Keyword And Return Status
        ...  Element Should Be Enabled  ${xpath}/div/div[1]/span/div/div[1]/button
        IF  ${status_reset}
            Log  ${bbmod_number}: ${bbmod_name} Reset button is enabled because it supports 5G![OK]  console=true
            Click Element  ${xpath}/div/div[1]/span/div/div[1]/button
            Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button
            Log  ${bbmod_number}: ${bbmod_name} Reset is ongoing!  console=true
            Wait Until Keyword Succeeds  ${DISABLED_TIMEOUT}  10
            ...  Assert Any  BBMOD  availabilityStatus=${OFFLINE}
            BREAK
        ELSE
            Click Element  ${xpath}/div/div[1]
            Log  ${bbmod_number}: ${bbmod_name} Reset button is disabled because it doesn't support 5G![OK]  console=true
        END
    END


Reset SBTS From Admin With Close Startup View If Visible
    Log  Reset SBTS  console=true
    Wait Until Element Is Clicked  //*[contains(text(),'Reset Site')]
    Wait Until Element Is Clicked  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button
    Close Startup View If Visible  300s
    Log  SBTS reseted  console=true


TC Setup
    Common Test Setup  tc_name=WebEM__CP_WebEM_usability_for_large_configurations_WebEM
    WebEM Setup


TC Teardown
    Run Keyword If Test Failed  Load A Specific SCF  ${COMMISSIONING_PATH}  ${RECOVERY_TIMEOUT}
    WebEM Teardown
    Common Test Teardown
