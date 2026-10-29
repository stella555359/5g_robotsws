*** Settings ***
Documentation
    ...  This test case login to WebEM as read-only.
    ...  Verify if "Downgraded privileges" title is visible.
    ...  Verify if "The user has downgraded Read-only privileges" is visible.
    ...  Verify if the current software version is visible.
    ...  Verify if the rollback button is not available. If it's available, test will be failed.

Resource  ../../common_resources/ca_WebEM_mobile.robot


*** Keywords ***
TC__WebEM__User_rights_downgrade
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22511
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22511 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 21.09.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26148 - Changing xpaths for login
    ...  - 07.03.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28866 - Confirm first appeared pop-up

    Set Tags  CA-WebEM  OWNER-george.gheban@nokia.com  AUTHOR-andreea.burtic@nokia.com  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS22

    Step1: Login To WebEM As Read-only
    Step2: Verify If WebEM Is Read-only


Step1: Login To WebEM As Read-only
    Log  Step1: Login to WebEM as read-only  console=true
    Start Web Element Manager On Mobile
    Wait Until Element Is Visible  ${LOGIN_USERNAME_MOBILE}  30
    Input Text  ${LOGIN_USERNAME_MOBILE}  Nemuadmin
    Input Password  ${LOGIN_PASSWORD_MOBILE}  nemuuser
    Wait Until Element Is Clicked For Mobile  xpath=${LOGIN_OPTION_MOBILE}
    Wait Until Element Is Clicked For Mobile  xpath=//*[contains(text(), "Read Only")]
    Wait Until Element Is Clicked For Mobile  xpath=${LOGIN_BUTTON_MOBILE}
    ${legal_notice_status}  Run Keyword And Return Status  Legal Notice Via Mobile
    IF  ${legal_notice_status}
        Verify And Close Read-Only Pop-up
    ELSE
        Verify And Close Read-Only Pop-up
        Legal Notice Via Mobile
    END

Step2: Verify If WebEM Is Read-only
    Log  Step2: Verify if WebEM is read-only  console=true
    Click Element  ${MOBILE_MENUS_TAB}
    Wait Until Element Is Clicked For Mobile  xpath=//*[contains(text(), "Software Management")]
    Log  Verify if current software version appear...  console=true
    ${status_sw}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  locator=//h2[contains(text(), "Current software version")]  timeout=10
    IF  ${status_sw}
        Log  Current software version is visible![OK]  console=true
    ELSE
        Fail  Current software version is not visible![NOK]
    END
    ${status_rollback}  Run Keyword And Return Status
    ...  Wait Until Page Does Not Contain Element  timeout=10  locator=//button[contains(text(), " Rollback...")]
    IF  ${status_rollback}
        Log  Rollback button is not available![OK]  console=true
    ELSE
        Fail  Rollback button is available![NOK]
    END


Verify And Close Read-Only Pop-up
    ${status_title}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  locator=//h4[contains(text(), "Downgraded privileges")]  timeout=10
    IF  ${status_title}
        Log  Downgraded privileges, appeared![OK]  console=true
    ELSE
        Fail  Downgraded privileges does not appeared![NOK]
    END
    ${status}  Run Keyword And Return Status
    ...  Wait Until Element Is Visible  locator=//div[contains(text(), "The user has downgraded Read-only privileges")]  timeout=10
    IF  ${status}
        Log  The user has downgraded Read-only privileges, appeared![OK]  console=true
    ELSE
        Fail  The user has downgraded Read-only privileges does not appeared![NOK]
    END
    Log  Close button will be pushed...  console=true
    Click Element  xpath=//button[contains(text(), "Close")]


TC Setup
    Common Test Setup


TC Teardown
    WebEM Teardown Via Mobile
    Common Test Teardown
