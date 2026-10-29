*** Settings ***
Resource    ../../common_resources/ca_WebEM_mobile.robot


*** Keywords ***
TC__WebEM__Check_operational_state_of_each_RAT_and_BTS
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22344
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case check operational state of each RAT (GSM, WCDMA, LTE, NR)
    ...  Check if BTS contains BTS ID
    ...  Check if BTS contains BTS NAME
    ...  Check if BTS contains Active SW
    ...  Check if BTS contains GSM/WCDMA/LTE/NR RATs
    ...  Check if BTS contains Alarms number
    ...  History of changes
    ...  ******************
    ...  - 16.12.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22344 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 23.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24352 - Get bts name and set it as a test variable

    Set Tags    CA-WebEM    OWNER-george.gheban@nokia.com    AUTHOR-andreea.burtic@nokia.com
    ...    MAINTAINER-andreea.burtic@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf    FEATURE-CB005750
    ...    PHASE-CRT    SW-SBTS21

    Step1: TC Preconditions
    Step2: Check if BTS contains basic info


Step1: TC Preconditions
    ${BTS_ID}  Admin Get BTS Id
    Set Test Variable  ${BTS_ID}
    ${out_admin_bts_name}  Get Bts Name
    Set test variable  ${OUT_ADMIN_BTS_NAME}  ${out_admin_bts_name}
    Get Active Software Versions

Step2: Check if BTS contains basic info
    Log  Start Basic BTS Information in mobile WebEM test  console=true
    Log  Check if BTS contains basic info  console=true
    Wait Until Keyword Succeeds  120  3  Click Element  //*[@id="main-view"]/div/div[1]/app-header/div[2]/i
    Wait Until Element Is Visible  locator=//span[contains(text(), "BTS ID:")]  timeout=60
    ${id}  Run keyword and return status  Wait Until Element Is Visible  locator=//div[contains(text(), "${BTS_ID}")]  timeout=60
    Run keyword if  ${id}
    ...  Log  BTS ID: ${BTS_ID} is visible in WebEM![OK]  console=true
    ...  ELSE
    ...  Fail  BTS ID: ${BTS_ID} is not visible in WebEM![NOK]
    Wait Until Element Is Visible  locator=//span[contains(text(), "BTS name:")]  timeout=60
    ${BTS_name}  Run keyword and return status  Wait Until Element Is Visible  locator=//div[contains(text(), "${OUT_ADMIN_BTS_NAME}")]  timeout=60
    Run keyword if  ${BTS_name}
    ...  Log  BTS NAME: ${OUT_ADMIN_BTS_NAME} is visible in WebEM![OK]  console=true
    ...  ELSE
    ...  Fail  BTS NAME: ${OUT_ADMIN_BTS_NAME} is not visible in WebEM![NOK]
    ${active_sw}  Run keyword and return status  Wait Until Element Is Visible  locator=//span[contains(text(), "${OUT_ACTIVE_SW}")]  timeout=60
    Run keyword if  ${active_sw}
    ...  Log  Active SW: ${OUT_ACTIVE_SW} is visible in WebEM![OK]  console=true
    ...  ELSE
    ...  Fail  Active SW: ${OUT_ACTIVE_SW} is not visible in WebEM![NOK]
    Run keyword if  ${SCF_COUNT_NR}
    ...  Verify if NR exists
    Run keyword if  ${SCF_COUNT_LTE}
    ...  Verify if LTE exists
    Run keyword if  ${SCF_COUNT_WCDMA}
    ...  Verify if WCDMA exists
    Run keyword if  ${SCF_COUNT_GSM}
    ...  Verify if GSM exists
    ${alarms_number}  Run keyword and return status  Wait Until Element Is Visible  locator=//span[contains(text(), "Alarms total number:")]
    ...  timeout=10
    Run keyword if  ${alarms_number}
    ...  Log  Alarms number is visible in WebEM![OK]  console=true
    ...  ELSE
    ...  Fail  Alarms number is not visible in WebEM![NOK]
    Wait Until Element Is Visible  locator=//div[contains(@class, 'nbts-operational-state') and contains(text(), 'On air')]  timeout=10
    Click Element  //*[@id="main-view"]/div/div[1]/app-header/md-backdrop

ADMIN Get Parameters For All BTS
    [Arguments]    ${timeout}=10
    ${out_list_of_bts_parameters_dict}=    ADMIN Get Parameters For All  class_name=BTS  timeout=${timeout}
    [Return]    ${out_list_of_bts_parameters_dict}

Create List Of Bts Parameters
    ${out_bts_parameters}=    ADMIN Get Parameters For All BTS
    Set Test Variable    ${OUT_ADMIN_BTS_PARAMETERS}    ${out_bts_parameters}

Get Active Software Versions
    Create List Of Bts Parameters
    ${out_active_sw}=    Get From Dictionary    @{OUT_ADMIN_BTS_PARAMETERS}    activeSoftwareVersion
    Set Test Variable    ${OUT_ACTIVE_SW}    ${out_active_sw}

Verify if ${technology} exists
    ${status}  Run keyword and return status  Wait Until Element Is Visible  locator=//div[contains(text(), "${technology}")]  timeout=60
    Run keyword if  ${status}
    ...  Log  ${technology} is visible in WebEM![OK]  console=true
    ...  ELSE
    ...  Fail  ${technology} is not visible in WebEM![NOK]


TC Setup
    Common test setup
    WebEM Setup via Mobile

TC Teardown
    WebEM Teardown via Mobile
    Common test teardown
