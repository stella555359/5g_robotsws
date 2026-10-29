*** Settings ***
Documentation  *AUTHOR*: andreea.burtic@nokia.com
...  This resource is used for vDU WebEM TCs with the new GUI.


*** Variables ***
${VDU_OPTIONS_MENU}  //*[contains(@aria-label, "Options menu")]/span  # Xpath for options menu
${VDU_SITE_VIEW}  //*[contains(@aria-label, "Site View")]/i  # Xpath for site view button
${VDU_DASHBOARD}  //*[contains(@aria-label, "Dashboard")]/i  # Xpath for dashboard button
${VDU_PARAMETER_EDITOR}  //*[contains(@aria-label, "Parameter Editor")]/i  # Xpath for parameter editor button
${VDU_ALARMS_FROM_SITE_VIEW}  //*[@id="laf-component"]/otx-product-bar/div/div/div[3]/a[6]/i  # Xpath for alarms button
${VDU_PERFORMANCE}  //*[contains(@aria-label, "Performance")]/i  # Xpath for performance button


*** Keywords ***
Open Commissioning Wizard
    [Documentation]  This keyword is used to open commissioning wizard tab.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com

    Wait Until Element Is Clicked  //*[contains(@aria-label, "Commissioning Wizard")]/i  120
    Sleep  30s  Time for page to be updated
    Page should contain  Plan
    Log  Commissioning Wizard was opened successfully![OK]  console=true


Open RF Diagnostic Tab
    [Documentation]  This keyword is used to open RF diagnostic tab.
    ...  *AUTHOR*: andreea.burtic@nokia.com
    ...  *MAINTAINER*: andreea.burtic@nokia.com

    Wait Until Keyword Succeeds  120  5
    ...  Mouse Over  //*[contains(@data-menu-header, "Diagnostic")]
    Wait Until Keyword Succeeds  120  5
    ...  Mouse Over  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'RF Diagnostic Test')]
    Click Element  //*[contains(@class, 'p-menuitem-text') and contains(text(), 'RF Diagnostic Test')]
    Sleep  10s  This sleep is for page to be uploaded.

