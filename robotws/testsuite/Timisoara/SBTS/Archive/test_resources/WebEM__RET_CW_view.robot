*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot

*** Keywords ***
TC__WebEM__RET_CW_view
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-25874
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case is created to checks "Maximize window" button from Antenna Line Devices RET.
    ...  The operator goes to Commissioning Wizard, RET and opens the Step-by-Step view using the "Configure" button.
    ...  Operator clicks the "Maximize window" button.
    ...  Expected results:
    ...  The "Maximize window" button is visible in the upper right corner of the screen.
    ...  After clicking it, the window is maximized to fit the screen ( there will be some margin after maximizing).
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 31.08.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-25874 - Initial TAT creation
    ...  - 21.11.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-26447 - Waiting for xpath to appear

    Set Tags    CA-WebEM    OWNER-mihnea.spineanu@nokia.com    AUTHOR-cristina.adam@nokia.com
    ...    MAINTAINER-cristina.adam@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf    PHASE-CRT    SW-SBTS23

    Step1: Navigate to antenna line devices RET
    Step2: Check "Maximize window" button

Step1: Navigate to antenna line devices RET
    Log  \nStep1: Navigate to antenna line devices RET  console=true
    Wait Until Element Is Visible  locator=//*[@id="admin.navigationBar.configuration.TITLE"]
    ...                            timeout=120
    Click Element  locator=//*[@id="admin.navigationBar.configuration.TITLE"]
    Wait Until Element Is Visible  locator=//span[contains(text(),'Configuration Management')]
    ...                            timeout=30
    Click Element  locator=//span[contains(text(),'Configuration Management')]
    Wait Until Element Is Visible  locator=//*[@id="main-view"]/div/div[1]/div[2]/global-search/div/wf-panel/wf-panel-section/div/div/div/ul/li[2]/a
    ...                            timeout=30
    Click Element  locator=//*[@id="main-view"]/div/div[1]/div[2]/global-search/div/wf-panel/wf-panel-section/div/div/div/ul/li[2]/a
    Wait Until Element Is Visible  locator=//*[contains(@title, 'Antenna Line Devices')]
    ...                            timeout=30
    Click Element  locator=//*[contains(@title, 'Antenna Line Devices')]
    Wait Until Element Is Visible  locator=//span[contains(text(),'Antenna Line Devices RET')]
    ...                            timeout=30
    Click Element  locator=//span[contains(text(),'Antenna Line Devices RET')]

Step2: Check "Maximize window" button
    Log  \nStep2: Check "Maximize window" button  console=true
    Wait until keyword succeeds  180s  5s  Click Element  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[1]/button/i
    Log  \nButton for "Maximize window" is accessed.  console=true
    Wait Until Element Is Visible  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[1]/button/i
    ...                            timeout=30
    Click Element  xpath:/html/body/div[1]/div/div/div/common-modal/div/div/div[1]/button/i
    Log  \nButton for "Restore window" is accessed.  console=true
    Wait Until Element Is Visible  locator=//button[contains(text(),'Cancel')]
    ...                            timeout=30
    Click Element  locator=//button[contains(text(),'Cancel')]
    Wait Until Element Is Visible  locator=//*[@id="modal-title"]
    ...                            timeout=30
    Click Element  locator=//button[contains(text(),'Yes')]

TC Setup
    Common Test Setup
    WebEM Setup

TC Teardown
    WebEM Teardown
    Common Test Teardown
