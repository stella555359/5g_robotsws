*** Settings ***
Documentation
    ...  This test case is created to check user access control permission for BBMOD power reset.
    ...  In this test case, WebEM must show/enable views and buttons depending on the privileges assigned to each type of user roles.
    ...  WebEM supports the following user roles: BTS System Administrator, BTS Security Administrator, BTS Application Administrator,
    ...  BTS Read-Only User.
    ...  The user logs in successfully with one of the supported user account types in WebEM.
    ...  The user is permitted access to a limited application functionality depending on the user account type associated to the user.
    ...  For users who allow BBMOD reset, perform BBMOD Power Reset and check the operation in "Operation History".

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__User_access_control_permission_for_BBMOD_power_reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-26067
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 18.12.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26067 - Initial TAT creation
    ...  - 10.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30308 - Confirm button changed for read-only pop-up

    Set Tags  CA-WebEM  OWNER-lucian.ivanescu@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23

    Step1: Create Other Types Of Users
    Step2: Authenticate And Verify Permissions For Users


Step1: Create Other Types Of Users
    Log  \nStep1: Create other types of users  console=true
    Wait Until Element Is Clicked  ${USER_ACCOUNT_TAB}  120
    Wait Until Element Is Visible  ${USER_ACCOUNT_MANAGEMENT}  timeout=30
    Wait Until Element Is Clicked  xpath=${USER_ACCOUNT_MANAGEMENT}
    ${users_types_dictionary}  Create Dictionary  BTS Security Administrator=User_Security  BTS Application Administrator=User_Application
    ...  BTS Read-Only User=User_Read_Only
    ${choose_account_xpath}  Catenate  SEPARATOR=  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[2]/div/modal-body/uam-modal-body
    ...  /wf-tabs/div/wf-pane[1]/div/div/uam-local-tab/form/div[1]/fieldset/div[1]/ui-select/div/wf-dropdown/div/button
    FOR  ${user_type}  IN  @{users_types_dictionary.keys()}
        Click Element  ${choose_account_xpath}
        Wait Until Element Is Visible  locator=//span[contains(text(),'${user_type}')]  timeout=30
        Wait Until Element Is Clicked  xpath=//span[contains(text(),'${user_type}')]
        Input Text  //*[@id="uam-local-alias"]/div/input  ${users_types_dictionary}[${user_type}]
        Input Password  //*[@id="uam-local-password"]/div/input  Nokia02!
        Input Password  //*[@id="uam-local-confirm-password"]/div/input  Nokia02!
        Wait Until Element Is Clicked  xpath=//*[@id="uam-local-account-state"]/div/wf-dropdown/div/button/span[2]
        Wait Until Element Is Clicked  xpath=//span[contains(text(),'Active')]
        Wait Until Element Is Clicked
        ...  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[3]/div/modal-footer/uam-modal-footer/ui-button[1]/button
        Wait Until Element Is Visible  locator=//*[contains(text(),' Process completed.')]  timeout=180
    END
    Wait Until Element Is Clicked  xpath=//button[contains(text(),' Close')]
    Log  \nAll types of users are created.  console=true


Step2: Authenticate And Verify Permissions For Users
    Log  \nStep2: Authenticate and verify permissions for users  console=true
    ${users}  Create Dictionary  Nemuadmin=nemuuser  User_Security=Nokia02!  User_Application=Nokia02!  User_Read_Only=Nokia02!
    FOR  ${user_type}  IN  @{users.keys()}
        Logout From SBTS
        Input Text  //*[@id="login-username"]  ${user_type}
        Input Password  //*[@id="login-password"]  ${users}[${user_type}]
        Wait Until Element Is Clicked  xpath=//*[contains(text(), 'Login')]
        Legal Notice
        Log  Wait until the page is loaded.  console=true
        Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[1]/div  90s
        ...  WebElement is not fully loaded in 90s seconds.
        Capture Page Screenshot  WebEM_SBTS_initial_state.png
        Check BBMOD Power Reset  ${user_type}
    END


Check BBMOD Power Reset
    [Arguments]  ${user}

    IF  '${user}'=='User_Read_Only'
        Wait Until Keyword Succeeds  120  5  Page Should Contain  The user has downgraded Read-only privileges.
        Wait Until Element Is Clicked  //*[@id="laf-component"]/div/div/div[3]/div/p-button/button/span
    END
    ${status_power_reset}  Run Keyword And Return Status  Open Baseband Module Power Reset
    ${user_type_status}  Run Keyword And Return Status  Should Match Regexp  ${user}  (Nemuadmin|User_Application)
    IF  ${status_power_reset} and ${user_type_status}
        Perform BBMOD Power Reset
        Log  \n${user} user can access 'Baseband Module Power Reset' module.  console=true
    ELSE IF  ${status_power_reset} and ${user_type_status}==${FALSE}
        Fail  msg=User type ${user} should not have BBMOD reset permission.
    ELSE IF  ${status_power_reset}==${FALSE} and ${user_type_status}
        Fail  msg=User type ${user} should have BBMOD reset permission.
    ELSE
        Log  \n${user} user cannot access 'Baseband Module Power Reset' module.  console=true
    END


Perform BBMOD Power Reset
    Log  \nPerform BBMOD power reset  console=true
    Click Element  xpath=//*[@class="bb-power-reset-list"]/p-listbox/div/div[2]/ul/li[1]/div/div
    ${bbmod_value}  SeleniumLibrary.Get Text  locator=//*[@class="bb-power-reset-list"]/p-listbox/div/div[2]/ul/li[1]/div/div
    ${bbmod_left_value}  Fetch From Left  ${bbmod_value}  (
    ${bbmod_right_value}  Fetch From Right  ${bbmod_left_value}  /
    ${bbmod_r}  Get Substring  ${bbmod_right_value}  1  -1
    Wait Until Element Is Clicked  //*[contains(@class, 'bb-power-reset-excute')]/p-button/button/span  150
    ${div_number}  Set Variable If  '${GUI_VERSION}' == 'new'  2  3
    Wait Until Element Is Clicked  xpath:/html/body/div[${div_number}]/div/div[3]/ot-footer/p-button[1]/button/span
    Wait Until Keyword Succeeds  10m  20s  ca_SBTS_general.Admin Check All Required State
    Check If Operation Is Visible In The "Operations History"  ${bbmod_r}


Check If Operation Is Visible In The "Operations History"
    [Arguments]  ${bbmod_r}

    Open Operations History
    ${operation_value}  SeleniumLibrary.Get Text  locator=//*[@id="operation.id"]
    ${operation_status}  Run Keyword And Return Status  Should Contain  ${operation_value}  Power reset
    ${details_status}  Run Keyword And Return Status  Should Contain  ${operation_value}  ${bbmod_r}
    IF  ${operation_status} and ${details_status}  Log  The triggered operation is visible accordingly in the "Operations History" on the BBMOD_R-1.
    ...  console=true


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
