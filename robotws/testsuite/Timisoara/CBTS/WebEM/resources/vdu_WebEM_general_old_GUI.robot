*** Settings ***
Documentation  *AUTHOR*: andreea.burtic@nokia.com
...  This resource is used for vDU WebEM TCs with the old GUI.


*** Variables ***
${VDU_OPTIONS_MENU}  //*[@class="side-bar-container"]/div/div[1]/a[11]/i  # Xpath for options menu
${VDU_SITE_VIEW}  //*[contains(@title, "Site View")]/button/span[2]  # Xpath for site view button
${VDU_DASHBOARD}  //*[contains(@title, "Dashboard")]/button/span[2]  # Xpath for dashboard button
${VDU_PARAMETER_EDITOR}  //*[contains(@title, "Parameter Editor")]/button/span[2]  # Xpath for parameter editor button
${VDU_ALARMS_FROM_SITE_VIEW}  //button[contains(@class, 'alarm-counter ui-corner-all ui-button-secondary p-button ui-state-default')]
...  # Xpath for alarms button
${VDU_PERFORMANCE}  //*[contains(@class,'side-bar-icon mdi-16px mdi mdi-chart-bar ng-star-inserted')]  # Xpath for performance button


*** Keywords ***
Open Commissioning Wizard
    [Documentation]  This keyword is used to open commissioning wizard tab.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com

    ${configuration_tab}  Catenate  SEPARATOR=  //*[@id="webem-root"]/div/div/webem-single-column-layout/webem-page-layout/div/
    ...  webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[5]/i
    Wait Until Element Is Clicked  ${configuration_tab}  120
    Wait Until Element Is Clicked  //*[contains(text(), "Commissioning Wizard")]  120
    Sleep  30s  Time for page to be updated
    Page should contain  Create Plan
    Log  Commissioning Wizard was opened successfully![OK]  console=true


Open RF Diagnostic Tab
    [Documentation]  This keyword is used to open RF diagnostic tab.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com

    ${rf_diagnostic_xpath}  Catenate  SEPARATOR=  //*[@id="webem-root"]/div/div/webem-single-column-layout-with-actions-bar/webem-page-layout/div/
    ...  webem-page-navigation-menu/ui-webem-side-bar-menu/div/div/div[1]/a[8]/i
    Wait Until Element Is Clicked  ${rf_diagnostic_xpath}  120
    Click Element  //*[contains(text(), "RF Diagnostic Test")]
    Sleep  10s  This sleep is for page to be uploaded.

