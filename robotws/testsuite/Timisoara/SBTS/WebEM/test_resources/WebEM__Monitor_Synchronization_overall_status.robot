*** Settings ***
Documentation
    ...  This test case is transferred from BOAM_ET to ST_OAM_WebEM.
    ...  This test case check synchronization, time and GNSS satellite information.
    ...  Go to diagnostic tab and choose Synchronization.
    ...  Chack Synchronization and Tuning mode.
    ...  Check Synchronization and Time source.
    ...  Check GNSS Satellite Information.
    ...  Open the chart and after close it.

Resource  ../../common_resources/ca_WebEM_general.robot


*** Variables ***
${SYNCHRONIZATION_MODE}  Phase synchronization  # Synchronization mode for SBTS. Can be Phase or Frecquency synchronization


*** Keywords ***
TC__WebEM__Monitor_Synchronization_overall_status
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24465
    ...
    ...  *****************
    ...  History of changes
    ...  ******************
    ...  - 14.03.2023 - https://jiradc.ext.net.nokia.com/browse/TAT-24465 - Initial TAT creation
    ...  - 16.02.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26914 - Adding GLONASS satellites

    Set Tags  CA-WebEM  OWNER-cristina.antoci@nokia.com  AUTHOR-andreea.burtic@nokia.com  MAINTAINER-andreea.burtic@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS23  FEATURE-CRL24911

    Step1: Go To Diagnostic Tab And Check Synchronization And Tuning Mode
    Step2: Check Synchronization And Time Source
    Step3: Check GNSS Satellite Information


Step1: Go To Diagnostic Tab And Check Synchronization And Tuning Mode
    Log  Step1: Go to Diagnostic Tab and Check Synchronization and Tuning mode  console=true
    Open Diagnostic Menu
    Wait Until Element Is Clicked  //span[contains(text(),'Synchronization')]
    Log  Synchronization is open!  console=true
    Run Keyword If  '${GUI_VERSION}' == 'new'
    ...  Wait Until Element Is Clicked  //*[@id="synchronization-status"]
    Sleep  10s  Time for page to be upload.
    Element Should Be Visible  //*[@*="sync-mode" and contains(text(),'Synchronization mode:')]
    Element Should Be Visible  //*[@*="sync-mode" and contains(text(),'${SYNCHRONIZATION_MODE}')]
    Log  Synchronization mode is ${SYNCHRONIZATION_MODE}!  console=true
    Element Should Be Visible  //*[@*="tuning-mode" and contains(text(),'Tuning mode:')]
    Element Should Be Visible  //*[@*="tuning-mode" and contains(text(),'Normal tuning')]
    Log  Tuning mode is Normal tuning!  console=true
    Element Should Be Visible  //time-sources[@*="time-sources"]//thead//tr//th[contains(text(),"Active")]
    Element Should Be Visible  //time-sources[@*="time-sources"]//thead//tr//th[contains(text(),"Type")]
    Element Should Be Visible  //time-sources[@*="time-sources"]//thead//tr//th[contains(text(),"IP address")]
    Element Should Be Visible  //time-sources[@*="time-sources"]//thead//tr//th[contains(text(),"Status")]


Step2: Check Synchronization And Time Source
    Log  Step2: Check Synchronization and Time source  console=true
    Element Should Be Visible  //header[contains(text(),'Synchronization source')]
    Page Should Contain Element  //td[contains(text(), "Available, usable")]/parent::tr[@class="ng-star-inserted"]  2
    Log  Synchronization source is available and usable!  console=true
    Element Should Be Visible  //sync-source[@*="sync-source"]//thead//tr//th[contains(text(),"Active")]
    Element Should Be Visible  //sync-source[@*="sync-source"]//thead//tr//th[contains(text(),"Priority")]
    Element Should Be Visible  //sync-source[@*="sync-source"]//thead//tr//th[contains(text(),"Synchronization source")]
    Element Should Be Visible  //sync-source[@*="sync-source"]//thead//tr//th[contains(text(),"Status")]
    Log  Check If Parameters In Sync Table Are Valid  console=true
    Element Should Be Visible  //tbody//tr[1][@class='ng-star-inserted']//td[1]//div//span[@aria-hidden="true" and @class="source-sync-icon"]
    Element Should Be Visible  //tbody//tr[1][@class='ng-star-inserted']//td[2][contains(text()," 1 ")]
    Page Should Contain Element  //tbody//tr[1][@class='ng-star-inserted']//td[4][contains(text(),"Available, usable")]  2
    Log  Check If Parameters In Time Table Are Valid  console=true
    Element Should Be Visible  //header[contains(text(),'Time sources')]
    Element Should Be Visible  //tbody//tr[1][@class='ng-star-inserted']//td[1]//div//span[@aria-hidden="true" and @class="time-sources-active-icon"]
    Element Should Be Visible  //tbody//tr[1][@class='ng-star-inserted']//td[2][contains(text()," 1 ")]
    Page Should Contain Element  //tbody//tr[1][@class='ng-star-inserted']//td[4][contains(text(),"Available, usable")]  2
    Log  Time source is available and usable!  console=true


Step3: Check GNSS Satellite Information
    Log  Step3: Check GNSS Satellite Information  console=true
    Element Should Be Visible  //div[@class="gnss-sky-visibility-status"]
    Element Should Be Visible  //header[contains(text(),'Satellite information of external GNSS receiver')]
    Log  Satellite information of external GNSS receiver is visible!  console=true
    Element Should Be Visible
    ...  //gnss-table//header[@id="gnss-table-header"]//..//p-table//div//div//table//thead//tr//th[contains(text(),"Constellation")]
    Log  Constellation is visible!  console=true
    Element Should Be Visible
    ...  //gnss-table//header[@id="gnss-table-header"]//..//p-table//div//div//table//thead//tr//th[contains(text(),"Satellite ID")]
    Log  Satellite ID is visible!  console=true
    Element Should Be Visible  //gnss-table//header[@id="gnss-table-header"]//..//p-table//div//div//table//thead//tr//th[contains(text(),"In use")]
    Log  In use is visible!  console=true
    Element Should Be Visible
    ...  //gnss-table//header[@id="gnss-table-header"]//..//p-table//div//div//table//thead//tr//th//div[contains(text(),"Signal level (dB/Hz)")]
    Log  Signal level (dB/Hz) is visible!  console=true
    ${count_satellites}  SeleniumLibrary.Get Element Count
    ...  //td[contains(text(), "GPS") or contains(text(),"GLONASS")]/parent::tr[@class="ng-star-inserted"]
    Check Parameters For GNSS Satellite SBTS  ${count_satellites}
    Click Element  //*[contains(@class, 'p-button-icon mdi mdi-chart-bar')]
    Log  Chart is open!  console=true
    Wait Until Element Is Clicked  //*[contains(@class, 'p-dialog-header-close-icon')]  90
    Log  Chart is close!  console=true


Check Parameters For GNSS Satellite SBTS
    [Arguments]  ${count}

    ${active_satellites}  Set Variable  0
    FOR  ${item}  IN RANGE  1  ${count}+1
        Wait Until Keyword Succeeds  30  5
        ...  Element Should Be Visible
        ...  //gnss-table[1]/section/p-table/div/div/table/tbody/tr[${item}]/td[1][contains(text(),"GPS") or contains(text(),"GLONASS")]
        Wait Until Keyword Succeeds  30  5
        ...  Element Should Be Visible  //gnss-table[1]/section/p-table/div/div/table/tbody/tr[${item}]/td[2]
        Wait Until Keyword Succeeds  30  5
        ...  Element Should Be Visible  //gnss-table[1]/section/p-table/div/div/table/tbody/tr[${item}]/td[3]
        ${active}  Run Keyword And Return Status
        ...  Wait Until Keyword Succeeds  30  5
        ...  Element Should Be Visible  //tr[${item}][@class="ng-star-inserted"]//td[3][contains(text(),"Yes")]
        ${active_satellites}  Run Keyword If  ${active}
        ...  Evaluate  ${active_satellites}+1
        ...  ELSE
        ...  Exit For Loop
        Wait Until Keyword Succeeds  30  5
        ...  Element Should Be Visible  //gnss-table[1]/section/p-table/div/div/table/tbody/tr[${item}]/td[4]
        ${signal_level}  Get Text  //gnss-table[1]/section/p-table/div/div/table/tbody/tr[${item}]//td[4]
        Run Keyword If  ${active}
        ...  Should Be true  ${signal_level}>0
    END
    Should Be true  ${active_satellites}>0


TC Setup
    Common Test Setup
    WebEM Setup


TC Teardown
    WebEM Teardown
    Common Test Teardown
