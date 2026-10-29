*** Settings ***
Documentation
    ...  This test case verify if all alarms are visible and filtering them.
    ...  Alarms menu is opened.
    ...  Get all alarms from WebEM
    ...  Get all alarms from admin CLI
    ...  If lists are equal the test will be continue. If lists are not equal the test will be failed.
    ...  Check details for all alarms.
    ...  Site block will be performed.
    ...  Verify all cells to have blockingState Blocked.
    ...  Alarms menu is open again.
    ...  Filtering alarms by severity.
    ...  First is choosen only Critical Alarms where fault id 50 with fault name BTS blocked should be visible.
    ...  Verify if number of alarms is the same as in Critical alarms button.
    ...  Second is choosen only Major Alarms.
    ...  Verify if number of alarms is the same as in Major alarms button.
    ...  Third is choosen only Minor Alarms.
    ...  Verify if number of alarms is the same as in Minor alarms button.
    ...  Site Unblock will be performed.
    ...  Verify all cells to be Enabled and Active.

Resource  ../../common_resources/ca_WebEM_mobile.robot


*** Variables ***
${RECOVERY_TIMEOUT}  1200  # Timeout for SBTS to recover


*** Keywords ***
TC__WebEM__Filtering_active_alarms
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22504
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  - 20.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22504 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice
    ...  - 15.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24316 - Refactor WebEM TCs and resources to use KWs from ca_SBTS_general
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Add watchdog alarm monitoring
    ...  - 20.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-28620 - Add snapshot collection
    ...  - 27.01.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28633 - Scroll element to get alarms.

    Set Tags  CA-WebEM  OWNER-george.gheban@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS22

    Step1: Check Initial Alarms
    Step2: Site Block
    Step3: Filtering Active Alarms On SBTS
    Step4: Unblock Site


Step1: Check Initial Alarms
    Log  Step1: Check initial alarms  console=true
    Open Alarms Menu
    ${mobile_webem_alarms_list}  Get All Alarms From Mobile WebEM
    ${cli_alarms_list}  Get All Alarms From Admin
    Sort List  ${cli_alarms_list}
    Sort List  ${mobile_webem_alarms_list}
    ${status}  Run Keyword And Return Status
    ...  Lists Should Be Equal  ${cli_alarms_list}  ${mobile_webem_alarms_list}
    Run Keyword If  ${status}
    ...  Log  Alarms are the same in WebEM and CLI![OK]  console=true
    ...  ELSE
    ...  Fail  Alarms are not the same in WebEM and CLI![NOK]
    ${alarms_list_len}  Get Length  ${mobile_webem_alarms_list}
    Run Keyword If  ${alarms_list_len}>0
    ...  Check All Alarms Details
    Wait Until Keyword Succeeds  120  5
    ...  Go To Site View Via Mobile


Step2: Site Block
    Log  Step2: Site block  console=true
    Site Block Via Mobile
    Run Keyword If  ${SCF_COUNT_GSM}
    ...  Check All GNCEL Blocking State To Be Blocked
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  Check All WNCEL Blocking State To Be Blocked
    Run Keyword If  ${SCF_COUNT_LTE}
    ...  Check All LNCEL Blocking State To Be Blocked
    Run Keyword If  ${SCF_COUNT_NR}
    ...  Check All NRCEL Blocking State To Be Blocked
    Log  Site was blocked successfully![OK]  console=true


Step3: Filtering Active Alarms On SBTS
    Log  Step3: Filtering active alarms on SBTS  console=true
    Open Alarms Menu
    ${icons}  SeleniumLibrary.Get Element Count
    ...  //*[@id="main-view"]/div/div[1]/div/ng-view/wf-panel/wf-panel-section/div/div/fault-management-downgrade/div/div[1]/alarm-icons/button
    FOR  ${index}  IN RANGE  1  ${icons}+1
        ${icon_button}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div/ng-view/wf-panel/wf-panel-section/div/div/
        ...  fault-management-downgrade/div/div[1]/alarm-icons/button[${index}]
        Click Element  ${icon_button}
    END
    ${icon}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div/ng-view/wf-panel/wf-panel-section/div/div/fault-management-downgrade
    ...  /div/div[1]/alarm-icons/button[1]
    Click Element  ${icon}
    ${critical_alarms_number}  Get Text
    ...  //*[@id="main-view"]/div/div[1]/div/ng-view/wf-panel/wf-panel-section/div/div/fault-management-downgrade/div/div[1]/alarm-icons/button[1]
    ${critical_alarm_grid_size}  SeleniumLibrary.Get Element Count  class:fm-alarm
    Run Keyword If  ${critical_alarms_number}==${critical_alarm_grid_size}
    ...  Run Keywords
    ...  Log  The number of Critical alarms is ok![OK]  console=true
    ...  AND
    ...  Check BTS Blocked Fault To Be Present In Critical Alarms
    ...  ELSE
    ...  Fail  The number of Critical alarms is not ok![NOK]
    ${button_1}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div/ng-view/wf-panel/wf-panel-section/div/div/fault-management-downgrade
    ...  /div/div[1]/alarm-icons/button[1]
    ${button_2}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div/ng-view/wf-panel/wf-panel-section/div/div/fault-management-downgrade/div
    ...  /div[1]/alarm-icons/button[2]
    Click Element  ${button_1}
    Click Element  ${button_2}
    ${major_alarms_number}  Get Text  ${button_2}
    ${major_alarm_grid_size}  SeleniumLibrary.Get Element Count  class:fm-alarm
    Run Keyword If  ${major_alarms_number}==${major_alarm_grid_size}
    ...  Log  The number of Major alarms is ok![OK]  console=true
    ...  ELSE
    ...  Fail  The number of Major alarms is not ok![NOK]
    Click Element  ${button_2}
    ${button_3}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div/ng-view/wf-panel/wf-panel-section/div/div/fault-management-downgrade/div
    ...  /div[1]/alarm-icons/button[3]
    Click Element  ${button_3}
    ${minor_alarms_number}  Get Text  ${button_3}
    ${minor_alarm_grid_size}  SeleniumLibrary.Get Element Count  class:fm-alarm
    Run Keyword If  ${minor_alarms_number}==${minor_alarm_grid_size}
    ...  Log  The number of Minor alarms is ok![OK]  console=true
    ...  ELSE
    ...  Fail  The number of Minor alarms is not ok![NOK]
    Click Element  ${button_3}
    Wait Until Keyword Succeeds  120  5
    ...  Go To Site View Via Mobile


Step4: Unblock Site
    Log  Step4: Unblock site  console=true
    Log  Collect snapshot before site unblock.  console=true
    Collect Snapshot And Ensure Mobile GUI Does Not Lock  snapshot_before_site_unblock.zip
    Site Unblock Via Mobile
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10
    ...  Check All Cells
    Log  All cells are Enabled!  console=true
    Log  Site was unblocked successfully![OK]  console=true


Check All ${technology_cells} Blocking State To Be Blocked
    Assert Every  ${technology_cells}  blockingState=Blocked  timeout=600


Open Alarms Menu
    Wait Until Element Is Clicked For Mobile  ${MOBILE_MENUS_TAB}  120
    Wait Until Element Is Clicked For Mobile  //*[contains(text(), "Alarms")]  60
    Log  Alarms menu is open![OK]  console=true
    Wait Until Page Contains Element  //button[contains(@class, "alarm-faults")]  timeout=10
    Wait Until Page Contains Element  //*[@class="filter-button"]  timeout=10


Get All Alarms From Mobile WebEM
    ${list_of_webem_alarms}  Get WebElements  locator=//div[@class="alarm-name"][1]/p[2]
    ${alarms_objects}  Get Length  ${list_of_webem_alarms}
    Set Test Variable  ${ALARMS_OBJECTS}
    ${mobile_webem_alarms_list}  Create List
    FOR  ${index}  IN RANGE  ${ALARMS_OBJECTS}
        Scroll Element Into View  locator=(//div[@class="alarm-name"][1]/p[2])[${index+1}]
        ${webem_alarm_detail}  Get Text  locator=(//div[@class="alarm-name"][1]/p[2])[${index+1}]
        ${single_alarm_id_webem}  Get Substring  ${webem_alarm_detail}  0  4
        Append To List  ${mobile_webem_alarms_list}  ${single_alarm_id_webem}
    END

    [Return]  ${mobile_webem_alarms_list}


Check BTS Blocked Fault To Be Present In Critical Alarms
    Wait Until Element Is Clicked For Mobile  (//div[@class="alarm-name"][1]/p[2])  120
    Wait Until Element Is Visible  locator=//label[text()="Severity:"]  timeout=10
    Wait Until Element Is Visible  locator=//label[text()="Alarm ID/Name:"]  timeout=10
    Wait Until Element Is Visible  locator=//label[contains(text(), "Appeared")]  timeout=10
    ${status_text}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div/ng-view/wf-panel/wf-panel-section/div/div/fault-management-downgrade
    ...  /alarms-details/div/div[2]/div[2]/div[5]/div
    ${status_alarm}  Get Text  ${status_text}
    Log  Alarm with fault id and fault name: ${status_alarm}, is visible!  console=true
    Wait Until Element Is Clicked For Mobile
    ...  //*[@id="main-view"]/div/div[1]/div/ng-view/wf-panel/wf-panel-section/div/div/fault-management-downgrade/alarms-details/div/div[1]/i  120


Get All Alarms From Admin
    ${cli_alarms_list}  Create List
    ${alarms_present}  Get AlarmID From Alarms
    FOR  ${item}  IN  @{alarms_present}
        ${single_alarm_id}  Get Substring  ${item}  -4
        Append To List  ${cli_alarms_list}  ${single_alarm_id}
    END

    [Return]  ${cli_alarms_list}


Get AlarmID From Alarms
    ${active_alarm_list}  coam.Get_active_alarms
    ${alarm_list_str}  Convert To String  ${active_alarm_list}
    ${alarm_id_match_alarm}  Get Regexp Matches  ${alarm_list_str}  \'alarmId\': ....

    [Return]  ${alarm_id_match_alarm}


Check All Alarms Details
    FOR  ${index}  IN RANGE  ${ALARMS_OBJECTS}
        Click Element  locator=(//div[@class="alarm-name"][1]/p[2])[${index+1}]
        Wait Until Element Is Visible  locator=//label[text()="Severity:"]  timeout=10
        Wait Until Element Is Visible  locator=//label[text()="Alarm ID/Name:"]  timeout=10
        Wait Until Element Is Visible  locator=//label[contains(text(), "Appeared")]  timeout=10
        ${status_text}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div/ng-view/wf-panel/wf-panel-section/div/div/
        ...  fault-management-downgrade/alarms-details/div/div[2]/div[2]/div[5]/div
        ${status_alarm}  Get Text  ${status_text}
        Log  Alarm with fault id and fault name: ${status_alarm}, is visible!  console=true
        Wait Until Element Is Clicked For Mobile
        ...  //*[@id="main-view"]/div/div[1]/div/ng-view/wf-panel/wf-panel-section/div/div/fault-management-downgrade/alarms-details/div/div[1]/i
        ...  120
    END


TC Setup
    Common Test Setup  tc_name=WebEM__Filtering_active_alarms
    WebEM Setup Via Mobile


TC Teardown
    WebEM Teardown Via Mobile
    Common Test Teardown
