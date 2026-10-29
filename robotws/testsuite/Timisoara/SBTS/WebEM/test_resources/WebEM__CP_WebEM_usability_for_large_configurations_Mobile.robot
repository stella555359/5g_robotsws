*** Settings ***
Documentation
    ...  This test case verify usability for large configurations Mobile.
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

Resource  ../../common_resources/ca_WebEM_mobile.robot


*** Variables ***
${PATH_AVERAGE_SCF}  #Mandatory! Path to average SCF.
${PATH_BIG_SCF}  #Mandatory! Path to big SCF.
${RECOVERY_TIMEOUT}  1200  #Time for SBTS to be onAir
${DISABLED_TIMEOUT}  600  #Time for HW to be disabled.


*** Keywords ***
TC__WebEM__CP_WebEM_usability_for_large_configurations_Mobile
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-29881
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 10.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29881 - Initial TAT creation
    ...  - 25.11.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30226 - Change of BTS Start-up View verification with big scf on m-plane ip
    ...  - 05.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30471 - Change logs2 with share1 because logs2 was deleted
    ...  - 25.02.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30513 - Change map shares KW
    ...  - 06.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30584 - Add login on WebEM if lock screen or logout performed after site reset

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


Step${index}: Perform Site Reset, Block/Unblock One NR Cell, Reset One BBMOD, Reset One RMOD and Open WebEM On Ip ${ip}
    Log  \nStep${index}: Perform Site Reset, Block/Unblock One NR Cell, Reset One BBMOD, Reset One RMOD and Open WebEM On Ip ${ip}  console=true
    IF  ${index} == 8
        Reset SBTS From Admin Via Mobile With Close BTS Start-up View If Visible
    ELSE
        Reset SBTS From Admin Via Mobile
    END
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State
    Log  All cells and units are onAir!  console=true
    Log  Site was reset successfully![OK]  console=true
    Login On WebEM If Lock Screen Or Logout Performed Via Mobile
    Close Startup View If Visible Via Mobile
    Block One NR Cell Via Mobile
    Unblock The Cell Via Mobile
    Reset One Baseband Module Via Mobile
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State
    Log  All cells and units are onAir!  console=true
    Reset One Radio Module Via Mobile
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State
    Log  All cells and units are onAir!  console=true
    Open WebEM Via Mobile On A Specific IP  ${ip}


Step${index}: Change Configuration With ${type} SCF from ${path_scf}
    Log  \nStep${index}: Change Configuration With ${type} SCF from ${path_scf}  console=true
    Log  Loading ${type} SCF from ${path_scf} will be performed...  console=true
    Load A Specific SCF  ${path_scf}  ${RECOVERY_TIMEOUT}
    Login On WebEM If Lock Screen Or Logout Performed Via Mobile
    Close Startup View If Visible Via Mobile


Open WebEM Via Mobile On A Specific IP
    [Arguments]  ${ip}

    Log  Open WebEM Via Mobile On IP ${ip}  console=true
    Run Keyword And Ignore Error  Download Application Logs Via Mobile
    Run Keyword And Ignore Error  Logout From SBTS Via Mobile
    Close Browser
    ${user_agent}  Catenate  SEPARATOR=  "Mozilla/5.0 (Linux; Android 4.2.1; en-us; Nexus 5 Build/JOP40D)" \ "AppleWebKit/535.19 (KHT
    ...  ML, like Gecko) Chrome/18.0.1025.166 Mobile Safari/535.19"
    ${visual}  Create Dictionary  width=${1920}  height=${1100}  pixelRatio=${4.0}
    ${mobile_emulation}  Create Dictionary  userAgent=${user_agent}  deviceMetrics=${visual}
    ${prefs}  Create Dictionary  download.default_directory=/home/ute/Downloads  plugins.plugins_disabled=${DISABLED}
    ${chrome_options}  Evaluate  sys.modules['selenium.webdriver'].ChromeOptions()  sys, selenium.webdriver
    Call Method  ${chrome_options}  add_experimental_option  mobileEmulation  ${mobile_emulation}
    Call Method  ${chrome_options}  add_experimental_option  prefs  ${prefs}
    Call Method  ${chrome_options}  add_argument  --ignore-ssl-errors
    Call Method  ${chrome_options}  add_argument  --ignore-certificate-errors
    Call Method  ${chrome_options}  add_argument  --disable-popup-blocking
    IF  ${VIRTUAL_DISPLAY}  Call Method  ${chrome_options}  add_argument  --headless
    Create Webdriver  Chrome  options=${chrome_options}
    Go To  https://${ip}
    Set Window Size  ${1920}  ${1400}
    Login SBTS Via Mobile
    Legal Notice Via Mobile


Block One NR Cell Via Mobile
    ${cell_xpath}  Evaluate  random.choice(${NR_CELLS_XPATH})  random
    Set Test Variable  ${NR_CELL_XPATH_FOR_BLOCK}  ${cell_xpath}
    Block NR Cell By ${NR_CELL_XPATH_FOR_BLOCK} Via Mobile
    Assert Any  NRCEL  blockingState=${BLOCKED}  timeout=150
    Log  NRCEL is blocked!  console=true


Unblock The Cell Via Mobile
    Wait Until Keyword Succeeds  60  10  Unblock NR Cell By ${NR_CELL_XPATH_FOR_BLOCK} Via Mobile
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Admin Check All Required State
    Log  All cells are onAir!  console=true


${block_unblock} NR Cell By ${cell_xpath} Via Mobile
    Log  ${block_unblock} one NR cell.  console=true
    Wait Until Element Is Clicked For Mobile  ${cell_xpath}  180
    Wait Until Element Is Clicked For Mobile  ${cell_xpath}/div/div/div/div[1]  180
    ${status}  Run Keyword And Return Status  Element Should Be Visible  ${cell_xpath}/div/div/div/div[1]/span/div/div[1]/button
    IF  not ${status}  Click Action Points And Check If Button Is Visible  ${cell_xpath}
    ${text_button_block}  Get Text  ${cell_xpath}/div/div/div/div[1]/span/div/div[1]/button
    ${status}  Run Keyword And Return Status  Should Match Regexp  ${text_button_block}  Cell ${block_unblock}|${block_unblock} Cell
    IF  ${status}
        Wait Until Element Is Clicked For Mobile  ${cell_xpath}/div/div/div/div[1]/span/div/div/button  120
    ELSE
        Wait Until Element Is Clicked For Mobile  ${cell_xpath}/div/div/div/div[1]/span/div/div[2]/button  120
    END
    Log  NR Cell ${block_unblock} is ongoing.  console=true
    Wait Until Element Is Clicked For Mobile
    ...  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button  300
    Sleep  10s  Wait for notifications to disappear


Reset One Radio Module Via Mobile
    ${xpath}  Evaluate  random.choice(${RMODS_XPATH})  random
    Wait Until Element Is Clicked For Mobile  xpath=${xpath}
    ${rmod_name}  Get Text  ${xpath}/div/div[3]/div[2]/div[1]
    ${rmod_number}  Get Text  ${xpath}/div/div[3]/div[2]/div[2]
    Log  \nReset for ${rmod_number}: ${rmod_name} will be performed!  console=true
    Wait Until Element Is Clicked For Mobile  xpath=${xpath}/div/div[3]/div[1]
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
    Wait Until Element Is Clicked For Mobile  xpath=${xpath}/div/div[3]/div[1]/span/div/div[1]/button
    Wait Until Element Is Clicked For Mobile  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button
    Wait Until Keyword Succeeds  ${DISABLED_TIMEOUT}  10  Check RMOD State Via Mobile  ${xpath}  Not installed
    Log  ${rmod_number}: ${rmod_name} is Not installed!  console=true
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10  Check RMOD State Via Mobile  ${xpath}  Online|Enabled
    Log  ${rmod_number}: ${rmod_name} is Online!  console=true
    Wait Until Element Is Clicked For Mobile  xpath=${xpath}/div/div[3]/div[1]
    ${status}  Run Keyword And Return Status  Element Should Be Enabled  ${xpath}/div/div[3]/div[1]/span/div/div[1]/button
    IF  ${status}
        Log  ${rmod_number}: ${rmod_name} was successfully reset!  console=true
        Wait Until Element Is Clicked For Mobile  xpath=${xpath}/div/div[3]/div[1]
    END


Reset One Baseband Module Via Mobile
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


Login On WebEM If Lock Screen Or Logout Performed Via Mobile
    ${session_locked}  Run Keyword and Return Status  Element Should Be Visible  //*[@class="screen-lock-container"]
    IF  ${session_locked}  Login From Lock Screen Via Mobile
    ${logout}  Run Keyword and Return Status  Element Should Be Visible  ${LOGIN_USERNAME_MOBILE}
    IF  ${logout}==${TRUE} and ${session_locked}==${FALSE}
        Login SBTS Via Mobile
        Legal Notice Via Mobile
        Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[1]/div  30s
    END


Login From Lock Screen Via Mobile
    Input Password  //*[@id="screen-lock-password-input"]  nemuuser
    Click Element  //*[contains(text(), 'Login')]


Reset SBTS From Admin Via Mobile With Close BTS Start-up View If Visible
    Log  Reset Site will be performed.  console=true
    Wait Until Element Is Clicked For Mobile  //*[contains(@a-text, "Reset Site")]  120
    Click Element  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button[1]/button
    Log  Reset site is ongoing!  console=true
    Sleep  30  Time for page to be updated
    Log  Wait until NMS is visible on WebEM  console=true
    Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div/div[2]/div[3]/div[2]  600
    Close Startup View If Visible Via Mobile
    Log  Reset site was performed!  console=true


TC Setup
    Common Test Setup  infomodel_launch=${FALSE}  tc_name=WebEM__CP_usability_for_large_configurations_Mobile
    WebEM Setup Via Mobile


TC Teardown
    Run Keyword If Test Failed  Load A Specific SCF  ${COMMISSIONING_PATH}  ${RECOVERY_TIMEOUT}
    WebEM Teardown Via Mobile
    Common Test Teardown
