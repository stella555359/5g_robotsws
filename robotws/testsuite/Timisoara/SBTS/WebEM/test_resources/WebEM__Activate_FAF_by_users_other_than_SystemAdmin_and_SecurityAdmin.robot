*** Settings ***
Documentation
    ...  This test case is created to check user access control permission for BTS Application Administrator role.
    ...  The user logs WebEM by BTS Application Administrator role.
    ...  Navigate to Parameter Editor. Check parameter 'actAntiTheftProtectionSystem' shall not able to be edited, only readable.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Activate_FAF_by_users_other_than_SystemAdmin_and_SecurityAdmin
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28012
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 12.09.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28012 - Initial TAT creation

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-cristina.adam@nokia.com  MAINTAINER-cristina.adam@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS24  FEATURE-CB012788

    Step1: Create BTS Application Administrator Type Of User
    Step2: Authenticate And Verify Permissions For ActAntiTheftProtectionSystem Parameter


Step1: Create BTS Application Administrator Type Of User
    Log  \nStep1: Create BTS Application Administrator Type Of User  console=true
    Wait Until Element Is Clicked  ${USER_ACCOUNT_TAB}  120
    Wait Until Element Is Clicked  ${USER_ACCOUNT_MANAGEMENT}  120
    Wait Until Element Is Clicked  //span[contains(@title, 'Choose account you want to update')]
    Wait Until Element Is Clicked  //*[contains(@data-value, 'BTS Application Administrator')]  120
    Input Text  //*[@id="uam-local-alias"]/div/input  User_Application
    Input Password  //*[@id="uam-local-password"]/div/input  Nokia02!
    Input Password  //*[@id="uam-local-confirm-password"]/div/input  Nokia02!
    Click Element  locator=//*[@id="uam-local-account-state"]/div/wf-dropdown/div/button/span[2]
    ${status}  Run Keyword And Return Status  Element Should Be Visible  //*[contains(@data-value, 'Active')]
    Run Keyword If  ${status}
    ...  Click Element  //*[contains(@data-value, 'Active')]
    Click Element  //button[@ui-tooltip='Save']
    Wait Until Element Is Visible  locator=//*[contains(text(),' Process completed.')]  timeout=180
    Click Element  locator=//button[contains(text(),' Close')]
    Log  \nBTS Application Administrator user is created.  console=true


Step2: Authenticate And Verify Permissions For ActAntiTheftProtectionSystem Parameter
    Log  \nStep2: Authenticate And Verify Permissions For ActAntiTheftProtectionSystem Parameter  console=true
    Log  Logout from SBTS will be performed!  console=true
    Logout From SBTS
    Wait Until Element Is Visible  xpath=//*[contains(text(), 'Login')]  60
    Input Text  //*[@id="login-username"]  User_Application
    Input Password  //*[@id="login-password"]  Nokia02!
    Wait Until Element Is Clicked  //*[contains(text(), 'Login')]  90  10
    Legal Notice
    Log  Wait until the page is loaded.  console=true
    Wait Until Element Is Visible  //*[@id="simplifiedSiteContainer"]/div/div/div[2]/div[2]/div[1]/div/div  90s
    ...  WebElement is not fully loaded in 90 seconds.
    Capture Page Screenshot  WebEM_SBTS_initial_state.png
    Check Permissions For ActAntiTheftProtectionSystem Parameter


Check Permissions For ActAntiTheftProtectionSystem Parameter
    Wait Until Element Is Clicked  ${PARAMETER_EDITOR}  90  10
    Double Click Element  locator=//*[contains(text(),'Current BTS configuration')]
    ${search_tab}  Catenate  SEPARATOR=  //*[contains(@class, 'global-search-panel view-panel ng-isolate-scope')]/wf-panel-section/div/div/div/div/
    ...  div[1]/global-search-tab-content/pe-global-search-objects/div/execution-bar/div/pe-global-search-filter/ui-text-input/div/input
    Input Text  ${search_tab}  FEATCADM-1
    Click Element  locator=//span[contains(text(),'FEATCADM-1')]
    ${planned_value_parameter}  Catenate  SEPARATOR=  //*[contains(@class, 'ui-view-panel-body-with-toolbar ng-scope')]
    ...  /div[2]/div/ui-view-panel-body/parameters-editor/div[2]/
    ...  parameters-editor-table-body/table/tbody/tr[6]/td[4]/parameter-input/div/ui-select/div/wf-dropdown/div/button
    ${permission_parameter}  SeleniumLibrary.Get Element Attribute  ${planned_value_parameter}  disabled
    Should Be Equal  ${permission_parameter}  true
    Log  \nPermissions for actAntiTheftProtectionSystem parameter are disabled.  console=true


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
