*** Settings ***
Documentation
...    Author: Monika szlovak (monika.szlovak@nokia.com)
...    Maintainer: Monika szlovak (monika.szlovak@nokia.com)
...    Group in charge: MANO_SOAM3
...    References: doors
...    Feature Description:5GC000316

Library        String
Library        Telnet
Library        OperatingSystem
Library        Process
Library        BuiltIn

Resource    ../../resources/admin.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${XPath_header}=        //*[@id="ui-tabpanel-4"]/div/div[1]/tuning/div/tune-bts-clock/div/section/header
${XPath_NormalTuning}=  //*[@id="ui-tabpanel-1"]/div/div[1]/tuning/div/tuning-history/div/tuning-history-table/
...    p-table/div/div/table/tbody/tr[1]
${XPath_ShowGraph_Clock}=    //*[@id="ui-tabpanel-1"]/div/div[1]/tuning/div/tuning-history/div/tuning-history-table/
...    p-table/div/div/table/thead/tr/th[3]/div/p-button/button/span[1]
${XPath_ShowGraph_Clock_trunk}=    //*[@id="ui-tabpanel-1"]/div/div[1]/tuning/div/tuning-history/div/tuning-history-table/
...    p-table/div/div/table/thead/tr/th[3]/div/div/button/span[1]
#${XPath_ShowGraph_Clock_trunk}=
${XPath_ShowGraph_Satellite}=   //*[@id="ui-tabpanel-0"]/div/div[1]/sync-status/div/gnss-table[1]/section/
...    p-table/div/div/table/thead/tr/th[4]/div/p-button/button/span[1]

*** Keywords ***
5GC000316_Clock_control_value_is_shown_in_graph_View

    SELENIUM Prepare Enviroment
    SELENIUM Login To Web Element Manager
    Go to Diagnostic Synchronization Tuning Tab
    Get Tuning History
    Check time and clock control value in graph

    Close Browser
    [Teardown]    Run Keyword And Ignore Error    SELENIUM Teardown Enviroment

5GC000316_Satellite_signal_level_of_GNSS_receiver_in_graph_view

    SELENIUM Prepare Enviroment
    SELENIUM Login To Web Element Manager
    Go to Diagnostic Synchronization Status Tab
    Select Show Graph
    Check Satellite ID and Signal level in graph

    Close Browser
    [Teardown]    Run Keyword And Ignore Error    SELENIUM Teardown Enviroment

#-----------------------------------------------------------------------
Suite Teardown
    Log
    ...    message=\n+ Started Suite POSTconditions: ${SUITE_NAME}
    ...    console=yes
#    ADMIN Collect Snapshot
    PREPOST Collect Scf File Postsuite
    PREPOST Teardown Admin
    Log Variables
#    ADMIN Teardown Admin
    Log
    ...    message=\n+ Finished Suite POSTconditions: ${SUITE_NAME}
    ...    console=yes

Go To BTS Counter Tab
    Wait Until Page Contains Element    locator=//div[@aria-describedby="admin.navigationBar.performance.TITLE"]
    Sleep  5s
    Click Element    locator=//div[@aria-describedby="admin.navigationBar.performance.TITLE"]
    Click Element    locator=//span[text()="Performance Management"]

Go to Diagnostic Synchronization Tuning Tab
    log to console   Go to Tuning tab
    Wait Until Page Contains Element    locator=//div[@aria-describedby="admin.navigationBar.diagnostic.TITLE"]
    Sleep  5s
    Click Element    locator=//div[@aria-describedby="admin.navigationBar.diagnostic.TITLE"]
    Mouse Over       locator=//span[text()="Synchronization"]
    Click Element    locator=//span[text()="Tuning"]

Get Tuning History
    log to console     Get Tuning History
    ${is_visible}    Run Keyword And Return Status    Wait Until Page Contains Element    locator=${XPath_header}
    Run Keyword Unless    ${is_visible}    Wait Until Element Is Visible
    ...    locator=//header[contains(text(),"Tune BTS clock")]
    Wait Until Element Is Visible
    ...    locator=//header[contains(text(),"Tuning history")]
    ${is_visible}    Run Keyword And Return Status
    ...    Click Button    locator=//*[@id="ui-tabpanel-1"]/div/div[1]/tuning/div/tuning-history/div/div/div[1]/p-button/button
    Run Keyword Unless    ${is_visible}    Click Get History Button for Trunk
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//div[contains(text(), "STARTED")]
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//div[contains(text(), "ACCEPTED")]
    Run Keyword And Ignore Error    SELENIUM Click Visible Element   locator=//div[contains(text(), "SUCCEEDED")]
    Sleep   20
    Wait Until Element Is Visible
    ...    locator=//span[contains(text(),"Getting history report completed")]
    log to console     Tuning history table contain at least one line
    ${is_visible}    Run Keyword And Return Status    Wait Until Page Contains Element    locator=${XPath_NormalTuning}
    Run Keyword Unless    ${is_visible}    Wait Until Page Contains Element    locator=//tbody[@class="p-element p-datatable-tbody"]
    ${is_visible}    Run Keyword And Return Status    Click Show Graph Tuning for branch
    Run Keyword Unless    ${is_visible}    Click Show Graph Tuning for Trunk

Click Show Graph Tuning for branch
    Wait Until Page Contains Element    locator=${XPath_ShowGraph_Clock}
    Click Element    locator=${XPath_ShowGraph_Clock}

Click Show Graph Tuning for Trunk
#    ${Show_graph_button}=   Get WebElement
#    ...    //div[@class="header-group"]//button[@ng-reflect-klass="ui-button-secondary"]
#    Click Element   locator=${Show_graph_button}
#    Wait Until Page Contains Element    locator=${XPath_ShowGraph_Clock_trunk}
#    Click Element    locator=${XPath_ShowGraph_Clock_trunk}
    Wait Until Page Contains Element    locator=//span[@class="p-button-icon mdi mdi-chart-line"]
    Click Element    locator=//span[@class="p-button-icon mdi mdi-chart-line"]

Click Get History Button for Trunk
    ${get_history_button}=   Get WebElement   //button[@ng-reflect-label="Get History"]
    Click Element   locator=${get_history_button}

Check time and clock control value in graph
    log to console    A pop-out window is shown
    ${is_visible}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...    locator=//span[contains(text(),'Clock Control Value Change Graph')]
    ...    timeout=30s
    Run Keyword Unless    ${is_visible}    Wait Until Element Is Visible
    ...    locator=//div[contains(text(),'Clock Control Value Change Gra')]
    ...    timeout=30s
    Wait Until Page Contains    text=Clock Control Value
    Wait Until Page Contains    text=Time (GMT

    Click Element At Coordinates  xpath=/html/body/div[3]/div/div[2]    30   30
    Capture Page Screenshot     clock_control_graph.png
    Current Frame Should Contain    text=DST

    log to console    click to close
    ${is_visible}    Run Keyword And Return Status    Click Element   xpath=/html/body/div[3]/div/div[1]/div/a/span
    Run Keyword Unless    ${is_visible}    Click Close Button for Trunk

#2
Go to Diagnostic Synchronization Status Tab
    log to console    Go to Status tab
    Wait Until Page Contains Element    locator=//div[@aria-describedby="admin.navigationBar.diagnostic.TITLE"]
    Sleep  5s
    Click Element    locator=//div[@aria-describedby="admin.navigationBar.diagnostic.TITLE"]
    Click Element    locator=//span[text()="Synchronization"]

Select Show Graph
    log to console    Select Show graph button
    Wait Until Page Contains Element    locator=//*[@id="gnss-table-header"]
    Sleep    3s
    ${is_present}    Run Keyword And Return Status    Click Show Graph for branch
    Run Keyword Unless    ${is_present}    Click Show Graph for Trunk

Click Show Graph for branch
    Wait Until Page Contains Element    locator=${XPath_ShowGraph_Satellite}
    Click Element    locator=${XPath_ShowGraph_Satellite}

Click Show Graph for Trunk
#    ${Show_graph_button}=   Get WebElement
#    ...    //div[@class="p-datatable-wrapper ng-star-inserted"]//button[@ng-reflect-text="Show graph"]
#    Click Element   locator=${Show_graph_button}
     Wait Until Page Contains Element    locator=//span[@class="p-button-icon mdi mdi-chart-bar"]
     Click Element    locator=//span[@class="p-button-icon mdi mdi-chart-bar"]

Check Satellite ID and Signal level in graph
    log to console     A pop-out window is shown
    ${is_visible}    Run Keyword And Return Status    Wait Until Page Contains Element    locator=//*[@id="ui-dialog-1-label"]
    Run Keyword Unless    ${is_visible}    Wait Until Page Contains Element
    ...    locator=//div[contains(text(),"Satellite Signal Level of Exte")]
    ${is_visible}    Run Keyword And Return Status    Wait Until Element Is Visible
    ...    locator=//span[contains(text(),'Satellite Signal Level of External GNSS Receiver')]
    ...    timeout=30s
    Run Keyword Unless    ${is_visible}    Wait Until Element Is Visible
    ...    locator=//div[contains(text(),"Satellite Signal Level of Exte")]
    ...    timeout=30s
    Wait Until Page Contains    text=Sky visibility status
    Wait Until Page Contains    text=Signal level (dB/Hz)
    Wait Until Page Contains    text=Satellite ID

    Click Element At Coordinates  xpath=/html/body/div[3]/div/div[2]    30   30
    Capture Page Screenshot     satellite_ID_graph.png
    Sleep    3s
    Current Frame Should Contain    text=Satellite ID:
    Current Frame Should Contain    text=Signal level:
    Current Frame Should Contain    text=Constellation: GPS
    Current Frame Should Contain    text=In use: Yes

    log to console    click to close
    ${is_visible}    Run Keyword And Return Status    Click Element   xpath=/html/body/div[3]/div/div[1]/div/a/span
    Run Keyword Unless    ${is_visible}    Click Close Button for Trunk

Click Close Button for Trunk
    ${close_button}=   Get WebElement
    ...    //button[@ng-reflect-ng-class="[object Object]"]
    Click Element   locator=${close_button}




