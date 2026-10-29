*** Settings ***
Documentation
    ...  This TC update alias and password for local users.
    ...  User Account Management window is opened.
    ...  Alias name are provided for each users(System, Security, Application and Read).
    ...  New passwords are provided too (Nokia02! for all users).
    ...  Save updates for each user.
    ...  Disconnect from current user and connect on each user created via WebEM.
    ...  Verify if the correct user is visible on WebEM.
    ...  Provide wrong alias for each user(System<, Security<, Application< and Read<).
    ...  Error message 'Username or alias is invalid' is visible.
    ...  Provide password and confirm password are different.
    ...  Error message 'New password and confirm password are not the same' is visible.
    ...  Provide incorrect old password for BTS System Administrator.
    ...  Error message 'Invalid old password. Please try again' is visible.
    ...  Provide incorrect old password for BTS Security Administrator.
    ...  Error message 'Invalid old password. Please try again' is visible.
    ...  Configuration reset is needded for all accounts to be restored.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${AFTER_COMMISSIONING_TIMEOUT}  1200s  # Timeout for cells to be onAir after commissioning!
${BTS_RESCUE_CONSOLE_TIMEOUT}  600s  # Timeout for BTS Rescue Console to appear!
${CONFIG_RESET_OPTION}  6  # Number of configuration reset option from BTS Rescue Console


*** Keywords ***
TC__WebEM__UAM_Update_alias_and_password_for_local_users
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-27179
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 09.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-27179 - Initial TAT creation
    ...  - 26.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28135 - Fix account name xpath
    ...  - 03.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30284 - Fix downgrade privileges pop-up xpath for trunk
    ...  - 14.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30366 - Add Set Accounts State To Be Inactive In Case Of Accounts Are Active KW

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS24

    Step1: Open User Account Management Window
    Step2: Provide Alias Name And Password For All Local Users And Activate The Accounts
    Step3: Connect On Each User Via WebEM
    Step4: Provide Alias Which Is Not Unique Or Not As Per Rule
    Step5: Provide Password And Confirm Password Are Different
    Step6: Provide Incorrect Old Password For BTS System Administrator
    Step7: Provide Incorrect Old Password For BTS Security Administrator
    Step8: Restore Accounts As Default


Step1: Open User Account Management Window
    Log  \nStep1: Open User Account Management window  console=true
    Wait Until Element Is Clicked  ${USER_ACCOUNT_TAB}  120
    Wait Until Element Is Clicked  ${USER_ACCOUNT_MANAGEMENT}  120
    Wait Until Element Is Visible  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[2]  60
    Log  User Account Management window is visible![OK]  console=true
    Wait Until Element Is Clicked  xpath=//span[contains(@title, 'Choose account you want to update')]
    Wait Until Element Is Visible  //*[contains(@data-value, 'BTS System Administrator')]  10
    Log  BTS System Administrator is visible![OK]  console=true
    Element Should Be Visible  //*[contains(@data-value, 'BTS Security Administrator')]
    Log  BTS Security Administrator is visible![OK]  console=true
    Element Should Be Visible  //*[contains(@data-value, 'BTS Application Administrator')]
    Log  BTS Application Administrator is visible![OK]  console=true
    Element Should Be Visible  //*[contains(@data-value, 'BTS Read-Only User')]
    Log  BTS Read-Only User is visible![OK]  console=true
    Click Element  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[2]/div/modal-body/uam-modal-body/wf-tabs/ul/li[1]/a
    Set Accounts State To Be Inactive In Case Of Accounts Are Active


Step2: Provide Alias Name And Password For All Local Users And Activate The Accounts
    Log  \nStep2: Provide alias name and password for all local users and activate the accounts  console=true
    Wait Until Element Is Clicked  ${SELECTED_TO_UPDATE_XPATH}
    Provide Alias And Password For A Specific User And Activate The Account  BTS System Administrator  System
    Wait Until Element Is Clicked  xpath=//span[contains(@title, 'BTS System Administrator')]
    Provide Alias And Password For A Specific User And Activate The Account  BTS Security Administrator  Security
    Wait Until Element Is Clicked  xpath=//span[contains(@title, 'BTS Security Administrator')]
    Provide Alias And Password For A Specific User And Activate The Account  BTS Application Administrator  Application
    Wait Until Element Is Clicked  xpath=//span[contains(@title, 'BTS Application Administrator')]
    Provide Alias And Password For A Specific User And Activate The Account  BTS Read-Only User  Read


Step3: Connect On Each User Via WebEM
    Log  \nStep3: Connect on each user via WebEM  console=true
    Wait Until Element Is Clicked  //button[@ui-tooltip='Close']  120
    Disconnect From Actual Account And Connect On A Specific Account Via WebEM  System  BTS System Administrator
    Disconnect From Actual Account And Connect On A Specific Account Via WebEM  Security  BTS Security Administrator
    Disconnect From Actual Account And Connect On A Specific Account Via WebEM  Application  BTS Application Administrator
    Disconnect From Actual Account And Connect On A Specific Account Via WebEM  Read  BTS Read-Only User
    Disconnect From Actual Account And Connect On A Specific Account Via WebEM  System  BTS System Administrator


Step4: Provide Alias Which Is Not Unique Or Not As Per Rule
    Log  \nStep4: Provide alias which is not unique or not as per rule  console=true
    Wait Until Element Is Clicked  ${USER_ACCOUNT_TAB}  120
    Wait Until Element Is Clicked  ${USER_ACCOUNT_MANAGEMENT}  120
    Wait Until Element Is Visible  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[2]  60
    Log  User Account Management window is visible![OK]  console=true
    Wait Until Element Is Clicked  xpath=//span[contains(@title, 'Choose account you want to update')]
    Provide Wrong Alias Or Password For A Specific User  BTS System Administrator  System<  Nokia02!  Nokia02!  Username or alias is invalid
    ...  Nokia02!
    Wait Until Element Is Clicked  xpath=//span[contains(@title, 'BTS System Administrator')]
    Provide Wrong Alias Or Password For A Specific User  BTS Security Administrator  Security<  Nokia02!  Nokia02!  Username or alias is invalid
    Wait Until Element Is Clicked  xpath=//span[contains(@title, 'BTS Security Administrator')]
    Provide Wrong Alias Or Password For A Specific User  BTS Application Administrator  Applicati<  Nokia02!  Nokia02!  Username or alias is invalid
    Wait Until Element Is Clicked  xpath=//span[contains(@title, 'BTS Application Administrator')]
    Provide Wrong Alias Or Password For A Specific User  BTS Read-Only User  Read<  Nokia02!  Nokia02!  Username or alias is invalid
    Wait Until Element Is Clicked  //button[@ui-tooltip='Close']  120


Step5: Provide Password And Confirm Password Are Different
    Log  \nStep5: Provide password and confirm password are different  console=true
    Wait Until Element Is Clicked  ${USER_ACCOUNT_TAB}  120
    Wait Until Element Is Clicked  ${USER_ACCOUNT_MANAGEMENT}  120
    Wait Until Element Is Visible  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[2]  60
    Log  User Account Management window is visible![OK]  console=true
    Wait Until Element Is Clicked  xpath=//span[contains(@title, 'Choose account you want to update')]
    Provide Wrong Alias Or Password For A Specific User  BTS System Administrator  System  Nokia02@  Nokia02#
    ...  New password and confirm password are not the same  Nokia02!
    Wait Until Element Is Clicked  xpath=//span[contains(@title, 'BTS System Administrator')]
    Provide Wrong Alias Or Password For A Specific User  BTS Security Administrator  Security  Nokia02@  Nokia02#
    ...  New password and confirm password are not the same
    Wait Until Element Is Clicked  xpath=//span[contains(@title, 'BTS Security Administrator')]
    Provide Wrong Alias Or Password For A Specific User  BTS Application Administrator  Applicati  Nokia02@  Nokia02#
    ...  New password and confirm password are not the same
    Wait Until Element Is Clicked  xpath=//span[contains(@title, 'BTS Application Administrator')]
    Provide Wrong Alias Or Password For A Specific User  BTS Read-Only User  Read  Nokia02@  Nokia02#
    ...  New password and confirm password are not the same
    Wait Until Element Is Clicked  //button[@ui-tooltip='Close']  120


Step6: Provide Incorrect Old Password For BTS System Administrator
    Log  \nStep6: Provide incorrect old password for BTS System Administrator  console=true
    Wait Until Element Is Clicked  ${USER_ACCOUNT_TAB}  120
    Wait Until Element Is Clicked  ${USER_ACCOUNT_MANAGEMENT}  120
    Wait Until Element Is Visible  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[2]  60
    Log  User Account Management window is visible![OK]  console=true
    Wait Until Element Is Clicked  xpath=//span[contains(@title, 'Choose account you want to update')]
    Provide Wrong Alias Or Password For A Specific User  BTS System Administrator  System  Nokia02#  Nokia02#  Invalid old password. Please try again
    ...  Nokia02@


Step7: Provide Incorrect Old Password For BTS Security Administrator
    Log  \nStep7: Provide incorrect old password for BTS Security Administrator  console=true
    Wait Until Element Is Clicked  //button[@ui-tooltip='Close']  120
    Disconnect From Actual Account And Connect On A Specific Account Via WebEM  Security  BTS Security Administrator
    Wait Until Element Is Clicked  ${USER_ACCOUNT_TAB}  120
    Wait Until Element Is Clicked  ${USER_ACCOUNT_MANAGEMENT}  120
    Wait Until Element Is Visible  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[2]  60
    Log  User Account Management window is visible![OK]  console=true
    Wait Until Element Is Clicked  xpath=//span[contains(@title, 'Choose account you want to update')]
    Wait Until Element Is Clicked  xpath=//*[contains(@data-value, 'BTS Security Administrator')]
    Log  BTS Security Administrator user is opened!  console=true
    Input Text  //*[@id="uam-local-alias"]/div/input  Security
    Log  Alias Security is provided!  console=true
    Input Password  //*[@id="uam-local-old-password"]/div/input  Nokia02#
    Log  Old password Nokia02# is provided!  console=true
    Input Password  //*[@id="uam-local-password"]/div/input  Nokia02@
    Log  Password Nokia02@ is provided!  console=true
    Input Password  //*[@id="uam-local-confirm-password"]/div/input  Nokia02@
    Log  Confirmed password Nokia02@ is provided!  console=true
    Wait Until Element Is Clicked  xpath=//button[@ui-tooltip='Save']
    Wait Until Element Is Visible  //*[contains(text(),"Invalid old password. Please try again")]  timeout=300
    Log  Message 'Invalid old password. Please try again' is visible![OK]  console=true
    Wait Until Element Is Clicked  //button[@ui-tooltip='Close']  120


Step8: Restore Accounts As Default
    Log  \Step8: Restore accounts as default  console=true
    Restore As Default


Set Accounts State To Be Inactive In Case Of Accounts Are Active
    ${SELECTED_TO_UPDATE_XPATH}  Catenate  SEPARATOR=  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[2]/div/modal-body/uam-modal-body
    ...  /wf-tabs/div/wf-pane[1]/div/div/uam-local-tab/form/div[1]/fieldset/div[1]/ui-select/div/wf-dropdown/div/button/span[1]/span
    Set Test Variable  ${SELECTED_TO_UPDATE_XPATH}
    ${accounts_list}  Create List  BTS Security Administrator  BTS Application Administrator  BTS Read-Only User
    FOR  ${account}  IN  @{accounts_list}
        Wait Until Element Is Clicked  ${SELECTED_TO_UPDATE_XPATH}  60
        Wait Until Element Is Clicked  //*[contains(@data-value, '${account}')]  60
        Log  ${account} is visible![OK]  console=true
        ${account_state}  Get Text  //*[@id="uam-local-account-state"]/div/wf-dropdown/div/button/span[1]/span
        IF  '${account_state}' == 'Active'
            Log  ${account} state is active, should be changed to inactive!  console=true
            Wait Until Element Is Clicked  //*[@id="uam-local-account-state"]/div/wf-dropdown/div/button/span[1]/span  60
            Wait Until Element Is Clicked  //*[contains(@data-value, 'Inactive')]  60
            Wait Until Element Is Clicked  //button[@ui-tooltip='Save']  60
            Wait Until Element Is Visible  //*[contains(text(),"Process completed.")]  timeout=300
            Log  ${account} state was updated to inactive![OK]  console=true
        ELSE
            Log  ${account} is inactive![OK]  console=true
        END
    END


Provide Alias And Password For A Specific User And Activate The Account
    [Arguments]  ${user_name}  ${alias}

    Wait Until Element Is Clicked  xpath=//*[contains(@data-value, '${user_name}')]
    Log  ${user_name} user is opened!  console=true
    IF  '${user_name}' == 'BTS System Administrator'
        Input Text  //*[@id="uam-local-user-name"]/div/input  ${alias}
        Input Password  //*[@id="uam-local-old-password"]/div/input  nemuuser
    ELSE
        Input Text  //*[@id="uam-local-alias"]/div/input  ${alias}
    END
    Log  Alias ${alias} is provided!  console=true
    Input Password  //*[@id="uam-local-password"]/div/input  Nokia02!
    Log  Password Nokia02! is provided!  console=true
    Input Password  //*[@id="uam-local-confirm-password"]/div/input  Nokia02!
    Log  Password Nokia02! is confirmed!  console=true
    IF  '${user_name}' != 'BTS System Administrator'
        Wait Until Element Is Clicked  xpath=//span[contains(@title, 'Inactive')]
        Wait Until Element Is Clicked  xpath=//*[contains(@data-value, 'Active')]
        Log  Account was activated![OK]  console=true
    END
    Wait Until Element Is Clicked  xpath=//button[@ui-tooltip='Save']
    Wait Until Element Is Visible  //*[contains(text(),"Process completed.")]  timeout=300


Disconnect From Actual Account And Connect On A Specific Account Via WebEM
    [Arguments]  ${username}  ${account_name}

    Log  Logout from SBTS will be performed!  console=true
    Logout From SBTS
    Wait Until Element Is Visible  xpath=//*[contains(text(), 'Login')]  60
    Input Text  //*[@id="login-username"]  ${username}
    Input Password  //*[@id="login-password"]  Nokia02!
    Wait Until Element Is Clicked  xpath=//*[contains(text(), 'Login')]
    Log  Login on SBTS with username ${username}!  console=true
    Legal Notice
    IF  '${account_name}'=='BTS Read-Only User' and '${ENB_BRANCH}' < 'SBTS26R2'
        Wait Until Keyword Succeeds  120  5  Page Should Contain  The user has downgraded Read-only privileges.
        Wait Until Element Is Clicked  xpath:/html/body/div[1]/div/div/common-modal/div/div/div[3]/div/modal-footer/ui-button/button
    ELSE IF  '${account_name}'=='BTS Read-Only User' and '${ENB_BRANCH}' >= 'SBTS26R2'
        Wait Until Keyword Succeeds  120  5  Page Should Contain  The user has downgraded Read-only privileges.
        Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/p-button/button/span
    END
    Log  Wait until the page is loaded.  console=true
    Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[2]/div[1]/div/div  200s
    ...  WebElement is not fully loaded in 200s seconds.
    Capture Page Screenshot  WebEM_SBTS_${username}_account.png
    Log  Screenshot was performed and saved in ${BTS_FILES}/selenium_screenshot_${TEST_NAME}!  console=true
    Sleep  10s  Time for page to be updated
    Wait Until Element Is Clicked  ${USER_ACCOUNT_TAB}  120
    Sleep  10s  Time for page to be updated
    Wait Until Element Is Visible  //*[contains(@class, '${ACCOUNT_NAME_CLASS}') and contains(text(), '${username}')]  20
    Log  Username ${username} for account ${account_name} is visible on WebEM![OK]  console=true
    Wait Until Element Is Clicked  ${USER_ACCOUNT_TAB}  120


Provide Wrong Alias Or Password For A Specific User
    [Arguments]  ${user_name}  ${alias}  ${password}  ${confirmed_password}  ${message}  ${old_password}==None

    Wait Until Element Is Clicked  xpath=//*[contains(@data-value, '${user_name}')]
    Log  ${user_name} user is opened!  console=true
    IF  '${user_name}' == 'BTS System Administrator'
        Input Text  //*[@id="uam-local-user-name"]/div/input  ${alias}
        Input Password  //*[@id="uam-local-old-password"]/div/input  ${old_password}
    ELSE
        Input Text  //*[@id="uam-local-alias"]/div/input  ${alias}
    END
    Log  Alias ${alias} is provided!  console=true
    Input Password  //*[@id="uam-local-password"]/div/input  ${password}
    Log  Password ${password} is provided!  console=true
    Input Password  //*[@id="uam-local-confirm-password"]/div/input  ${confirmed_password}
    Log  Confirmed password ${confirmed_password} is provided!  console=true
    Wait Until Element Is Clicked  xpath=//button[@ui-tooltip='Save']
    Wait Until Element Is Visible  //*[contains(text(),"${message}")]  timeout=300
    Log  Message '${message}' is visible![OK]  console=true


Restore As Default
    Run Keyword And Ignore Error
    ...  Wait Until Element Is Clicked  //button[@ui-tooltip='Close']  120
    Disconnect From Actual Account And Connect On A Specific Account Via WebEM  System  BTS System Administrator
    Performing Configuration Reset And Verify SBTS To Be Not Commissioned  ${BTS_RESCUE_CONSOLE_TIMEOUT}  ${CONFIG_RESET_OPTION}  System  Nokia02!
    Sleep  300s  Time for all modules to be visible!
    Admin Get Bts_id And Perform Commissioning  ${COMMISSIONING_PATH}
    Close Startup View If Visible  120s
    Wait Until Keyword Succeeds  ${AFTER_COMMISSIONING_TIMEOUT}  30s
    ...  Check All Cells
    Logout From SBTS
    Wait Until Element Is Visible  xpath=//*[contains(text(), 'Login')]  60
    Login SBTS
    Legal Notice
    Log  Wait until the page is loaded.  console=true
    Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[1]/div  120s
    ...  WebElement is not fully loaded in 120s seconds.
    Log  Initial user is available again![OK]  console=true


TC Setup
    Common Test Setup  tc_name=WebEM__UAM_Update_alias_and_password_for_local_users
    WebEM Setup


TC Teardown
    Run Keyword If Test Failed
    ...  Restore As Default
    WebEM Teardown
    Common Test Teardown
