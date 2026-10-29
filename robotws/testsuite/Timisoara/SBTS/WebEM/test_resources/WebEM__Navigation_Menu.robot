*** Settings ***
Documentation
    ...  This TC performs log in to mobile WebEM and checks all sub-menu items of Navigation Menu.
    ...  Site View, BTS startup view, Site Report view, Alarms view, SW management view, EAC view,
    ...  SFP view, Remote Snapshot view are checked. All of them and their corresponding sub-items
    ...  must be visible and accesible. They should also correspond to the design.

Resource  ../../common_resources/ca_WebEM_mobile.robot


*** Keywords ***
TC__WebEM__Navigation_Menu
    [Documentation]
    ...  [CASE LINK]: https://jira3.ext.net.nokia.com/browse/TAT-22512
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.01.2022 - https://jira3.ext.net.nokia.com/browse/TAT-22512 - Initial TAT creation
    ...  - 25.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24131 - Refactor TCs with best practice

    Set Tags  CA-WebEM  OWNER-george.gheban@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_3_Vrf  PHASE-CRT  SW-SBTS22

    Step1: Check All The Sub-menu Items


Step1: Check All The Sub-menu Items
    Log  \nStep1: Check all the sub-menu items  console=true
    Webem Check All Nav Sub-menus


Webem Check All Nav Sub-menus
    ${site_view_status}  Run Keyword And Return Status
    ...  Webem Check Site-view
    Run Keyword If  ${site_view_status}
    ...  Log  Site view is accesible. [OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Site view is not accesible. [NOK]
    ${startup_view_status}  Run Keyword And Return Status
    ...  Webem Check BTS Startup-view
    Run Keyword If  ${startup_view_status}
    ...  Log  BTS startup view is accesible. [OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  BTS start up view is not accesible. [NOK]
    ${report_view_status}  Run Keyword And Return Status
    ...  Webem Check Site Report-view
    Run Keyword If  ${report_view_status}
    ...  Log  Site report view is accesible. [OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Site report view is not accesible. [NOK]
    ${alarms_view_status}  Run Keyword And Return Status
    ...  Webem Check Alarms-view
    Run Keyword If  ${alarms_view_status}
    ...  Log  Alarms view is accesible. [OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  Alarms view is not accesible. [NOK]
    ${sw_view_status}  Run Keyword And Return Status
    ...  Webem Check SW-management-view
    Run Keyword If  ${sw_view_status}
    ...  Log  SW management view is accesible. [OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  SW management view is not accesible. [NOK]
    ${eac_view_status}  Run Keyword And Return Status
    ...  Webem Check EAC-view
    Run Keyword If  ${eac_view_status}
    ...  Log  EAC view is accesible. [OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  EAC view is not accesible. [NOK]
    ${sfp_view_status}  Run Keyword And Return Status
    ...  Webem Check SFP-view
    Run Keyword If  ${sfp_view_status}
    ...  Log  SFP view is accesible. [OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  SFP view is not accesible. [NOK]
    ${remote_snapshot_status}  Run Keyword And Return Status
    ...  Webem Check Remote-Snapshot-view
    Run Keyword If  ${remote_snapshot_status}
    ...  Log  Remote snapshot view is accesible. [OK]\n  console=true
    ...  ELSE
    ...  Set Test Restriction  Remote snapshot view is not accesible. [NOK]\n


Webem Check Site-view
    Go To Site View Via Mobile
    Wait Until Element Is Visible  //div[contains(text(), "Site View")]  timeout=60


Webem Check BTS Startup-view
    Open BTS Start-up View Pop-up Via Mobile
    Wait Until Element Is Visible  //*[@class="modal-dialog n-dialog-confirm"]  timeout=10
    Wait Until Element Is Visible  //*[@class="bts-start-view-configuration"]  timeout=10
    Click Element  xpath:/html/body/div[1]/div/div/ui-modal-renderer/bts-status-modal/ui-modal/div/div/div[3]/div/ui-footer/div/ui-button/button


Webem Check Site Report-view
    Click Element  ${MOBILE_MENUS_TAB}
    Wait Until Element Is Clicked For Mobile  ${SITE_REPORT_MOBILE}  60
    Wait Until Element Is Visible  //*[@class="save-report-mob"]//*[@a-text="Save Report"]  timeout=10
    Wait Until Element Is Visible  //*[contains(text(), "Cabinet")]  timeout=10
    Wait Until Element Is Visible  //*[contains(text(), "System Modules")]  timeout=10
    Wait Until Element Is Visible  //*[contains(text(), "Baseband Modules")]  timeout=10
    Wait Until Element Is Visible  //*[contains(text(), "Radio Modules")]  timeout=10
    Wait Until Element Is Visible  //*[contains(text(), "NR Cell Groups")]  timeout=10
    Wait Until Element Is Visible  //*[contains(text(), "SW Release Versions")]  timeout=10


Webem Check Alarms-view
    Click Element  ${MOBILE_MENUS_TAB}
    Wait Until Element Is Clicked For Mobile  //*[contains(text(), "Alarms")]  60
    Wait Until Page Contains Element  //button[contains(@class, "alarm-faults")]  timeout=10
    Wait Until Page Contains Element  //*[@class="filter-button"]  timeout=10
    Capture Page Screenshot


Webem Check SW-management-view
    Click Element  ${MOBILE_MENUS_TAB}
    Wait Until Element Is Clicked For Mobile  //*[contains(text(), "Software Management")]  60
    Wait Until Element Is Visible  //h2[contains(text(), "Current software version")]  timeout=10
    Wait Until Element Is Visible  //button[contains(text(), "Rollback")]  timeout=10


Webem Check EAC-view
    Click Element  ${MOBILE_MENUS_TAB}
    Wait Until Element Is Clicked For Mobile  //*[contains(text(), "Diagnostic")]  60
    Wait Until Element Is Clicked For Mobile  //*[contains(text(), "EAC Functionality Test")]  60
    Wait Until Element Is Clicked For Mobile  //*[contains(text(), "Faults")]  60
    Wait Until Element Is Visible  //*[text()="Faults"]  timeout=10
    Wait Until Element Is Visible  //th[text()="Module"]  timeout=10
    Wait Until Element Is Visible  //th[text()="Line ID"]  timeout=10
    Wait Until Element Is Visible  //*[text()="Save Results"]  timeout=10
    Click Element  ${MOBILE_MENUS_TAB}
    Wait Until Element Is Clicked For Mobile  //*[contains(text(), "Controls")]  60
    Wait Until Element Is Visible  //*[text()="Controls"]  timeout=10
    Wait Until Element Is Visible  //th[text()="Module"]  timeout=10
    Wait Until Element Is Visible  //th[text()="Line ID"]  timeout=10
    Wait Until Element Is Visible  //span[text()="Save Results"]  timeout=10


Webem Check SFP-view
    Click Element  ${MOBILE_MENUS_TAB}
    Wait Until Element Is Clicked For Mobile  //*[contains(text(), "SFP Monitoring")]  60
    Wait Until Element Is Visible  //*[text()="SFP Monitoring"]  timeout=10
    ${stream}  Fetch From Left  ${ACTIVE_SW_VERSION}  _
    Run Keyword If  '${stream}'=='5G21A' or '${stream}'=='SBTS21B'
    ...  Run Keywords
    ...  Wait Until Element Is Visible  //*[contains(text(), "SFPs applied to current BTS HW connection")]  timeout=10
    ...  AND
    ...  Wait Until Element Is Visible  //*[contains(text(), "SFPs not applied to current BTS HW connection")]  timeout=10
    ...  ELSE
    ...  Run Keywords
    ...  Wait Until Element Is Visible  //*[contains(text(), "SFPs applied to both near and far end in current BTS")]  timeout=10
    ...  AND
    ...  Wait Until Element Is Visible  //*[contains(text(), "SFPs applied to only one end in current BTS")]  timeout=10


Webem Check Remote-Snapshot-view
    Click Element  ${MOBILE_MENUS_TAB}
    Wait Until Element Is Clicked For Mobile  //*[contains(text(), "Remote Snapshot")]  60
    Wait Until Element Is Visible  //h1[contains(text(), "Snapshot collection settings")]  timeout=10
    Wait Until Element Is Visible  //button[contains(text(), "Collect Snapshot")]  timeout=10


TC Setup
    Common Test Setup
    WebEM Setup Via Mobile


TC Teardown
    WebEM Teardown Via Mobile
    Common Test Teardown
