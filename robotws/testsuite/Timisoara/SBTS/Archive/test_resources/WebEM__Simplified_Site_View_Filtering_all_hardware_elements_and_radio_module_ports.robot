*** Settings ***
Resource    ../../common_resources/ca_WebEM_general.robot


*** Keywords ***
TC__WebEM__Simplified_Site_View_Filtering_all_hardware_elements_and_radio_module_ports
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24466
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  This test case is transferred from BOAM_ET to ST_OAM_WebEM.
    ...  This test case check if sorting and ordering capabilities are possible.
    ...  Filter and Unfilter SMODs/BBMODs.
    ...  Select Show all ports and verify if all ports are available.
    ...  Select Show only used ports and verify if only used ports are available.
    ...  History of changes
    ...  ******************
    ...  - 10.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24466 - Initial TAT creation

    Set Tags    CA-WebEM    OWNER-cristina.antoci@nokia.com    AUTHOR-andreea.burtic@nokia.com
    ...    MAINTAINER-andreea.burtic@nokia.com    GROUP_IN_CHARGE-TIM_3_Vrf   PHASE-CRT    SW-SBTS23

    Step1: Navigate to Simplified Site View
    Step2: Check Simplified Site View Filtering for Cabinet Elements
    Step3: Check Simplified Site View Filtering for Radio Module Ports


Step1: Navigate to Simplified Site View
    Log  Step1: Navigate to Simplified Site View  console=true
    Click Element  locator=//div[@aria-describedby="admin.navigationBar.btsStatus.TITLE"]
    Click Element  locator=//span[contains(text(),'Site Runtime View')]

Step2: Check Simplified Site View Filtering for Cabinet Elements
    Log  Step2: Check Simplified Site View Filtering for Cabinet Elements  console=true
    ${smods}  Create list
    ${bbmods}  Create list
    ${unit_name}  Catenate  SEPARATOR=  //*[@id="main-view"]/div/div[1]/div[2]/details-panel/div/wf-panel/
    ...  wf-panel-section/div/div/details-panel-content/div/hardware-details/div/div/div[1]/div/div/div[2]/div[1]/div/span
    ${smods_xpath}  Get xpaths for SMODs
    FOR  ${smod_xpath}  IN  @{smods_xpath}
        Click Element  ${smod_xpath}
        ${smod_name}  Get Text  ${unit_name}
        Append to list  ${smods}  ${smod_name}
    END
    FOR  ${bbmod_xpath}  IN  @{BBMODS_XPATH}
        Click Element  ${bbmod_xpath}
        ${bbmod_name}  Get Text  ${unit_name}
        Append to list  ${bbmods}  ${bbmod_name}
    END
    Open Filters Tab
    Log  Unselect SMODs/BBMODs from Show filters tab  console=true
    Click Element  locator=//li[@ui-tooltip="SMODs/BBMODs"]
    Page Should Not Contain Element
    ...  locator=//li[@ui-tooltip="SMODs/BBMODs"]//input[contains(@class, 'ng-valid ng-dirty ng-touched ng-not-empty ng-valid-parse')]
    Close Filters Tab
    Page Should Not Contain Element
    ...  locator=//div[@class="runtime-view-container"]//*[contains(text(),'SMODs/BBMODs')]
    FOR  ${smod}  IN  @{smods}
        Page Should Not Contain Element
        ...   locator=//div[@class="runtime-view-container"]//*[contains(text(),'${smod}')]
        Log  ${smod} is not visible in WebEM![OK]  console=true
    END
    FOR  ${bbmod}  IN  @{bbmods}
        Page Should Not Contain Element
        ...   locator=//div[@class="runtime-view-container"]//*[contains(text(),'${bbmod}')]
        Log  ${bbmod} is not visible in WebEM![OK]  console=true
    END
    Open Filters Tab
    Log  Select SMODs/BBMODs from Show filters tab  console=true
    Click Element  locator=//li[@ui-tooltip="SMODs/BBMODs"]
    Page Should Contain Element
    ...  locator=//li[@ui-tooltip="SMODs/BBMODs"]//input[contains(@class, 'ng-valid ng-dirty ng-touched ng-not-empty ng-valid-parse')]
    Close Filters Tab
    Page Should Contain Element
    ...  locator=//div[@class="runtime-view-container"]//*[contains(text(),'SMODs/BBMODs')]
    FOR  ${smod}  IN  @{smods}
        Page Should Contain Element
        ...  locator=//div[@class="runtime-view-container"]//*[contains(text(),'${smod}')]
        Log  ${smod} is visible in WebEM![OK]  console=true
    END
    FOR  ${bbmod}  IN  @{bbmods}
        Page Should Contain Element
        ...  locator=//div[@class="runtime-view-container"]//*[contains(text(),'${bbmod}')]
        Log  ${bbmod} is visible in WebEM![OK]  console=true
    END

Step3: Check Simplified Site View Filtering for Radio Module Ports
    Log  Step3: Check Simplified Site View Filtering for Radio Module Ports  console=true
    ${initial_active_ports}  Selenium2Library.Get Element Count  xpath=//*[contains(@class, 'port-label used-port-label')]
    Log  Initial number of active ports is ${initial_active_ports}!  console=true
    Open Filters Tab
    Log  Select Show all ports from Show filters tab  console=true
    Click Element  locator=//fieldset[@class="link-filter"]//input[@value="SHOW_ALL_PORTS"]
    Page Should Contain Element  locator=//input[@value="SHOW_ALL_PORTS" and contains(@class,'ng-valid-parse')]
    ${not_used_ports}  Selenium2Library.Get Element Count  xpath=//*[contains(@class, 'port-label not-used-port-label')]
    Log  Number of not used ports is ${not_used_ports}!  console=true
    ${all_ports}  Evaluate  ${initial_active_ports}+${not_used_ports}
    Log  Number of all ports is ${all_ports}!  console=true
    Log  Select Show only used ports from Show filters tab  console=true
    Click Element  locator=//fieldset[@class="link-filter"]//input[@value="SHOW_ONLY_USED_PORTS"]
    Page Should Contain Element  locator=//input[@value="SHOW_ONLY_USED_PORTS" and contains(@class,'ng-valid-parse')]
    Page Should Contain Element  locator=//div[@class="radio-section"]//*[@class="port-label used-port-label"]
    ${active_ports}  Selenium2Library.Get Element Count  xpath=//*[contains(@class, 'port-label used-port-label')]
    Log  Number of active ports is ${active_ports}!  console=true
    ${status_of_ports}  Run keyword and return status  Page Should Not Contain Element
    ...  locator=//div[@class="radio-section"]//*[@class="port-label not-used-port-label"]
    Run keyword if  ${status_of_ports}
    ...  Log  Not used ports are not visible on SBTS![OK]  console=true
    ...  ELSE
    ...  Fail  Not used ports are still visible on SBTS![NOK]

${action} Filters Tab
    ${release}  Run Keyword And Return Status  Should Contain  ${active SW version}  22R4
    Run Keyword If  ${release}
    ...  Click Element  locator=//button[@ui-tooltip="Show filters"]
    ...  ELSE
    ...  Click Element  locator=//span[contains(text(), 'Filter')]
    Log  ${action} Filters Tab was performed successfully!  console=true


TC Setup
    Common test setup
    WebEM Setup

TC Teardown
    WebEM Teardown
    Common test teardown
