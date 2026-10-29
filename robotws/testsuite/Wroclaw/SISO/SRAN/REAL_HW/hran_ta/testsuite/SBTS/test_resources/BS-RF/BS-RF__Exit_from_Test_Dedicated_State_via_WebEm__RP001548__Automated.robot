*** Settings ***
Documentation
...  Test case should deactivate Test Dedicated State on BTS via Admin.

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot
Library           taf.selenium.sbts  WITH NAME  selenium_coam


*** Variables ***

${node}    default
${WEBUI_URL}     https://192.168.255.129/    # ADMIN url
${WEBUI_NAME}    Nemuadmin                   # ADMIN login
${WEBUI_PWD}     nemuuser                    # ADMIN password

*** Keywords ***
TC__BS-RF__Exit_from_Test_Dedicated_State_via_WebEm__RP001548__Automated
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-15065
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case should deactivate Test Dedicated State on BTS via Admin.
    ...  Before TC execution BTS should be in Test Dedicated State. Cells will be in disabled state.
    ...  After TC execution BTS should be in OnAir state.
    ...  You should use this TC after TC BS-RF__Enter_to_Test_Dedicated_State_via_WebEm__RP001548__Automated.
    ...
    ...  IMPORTANT:
    ...  For proper operation of Selenium2Library, Chrome Driver version is required to match the Google Chrome version !
    ...  During TC developing used Google Chrome 81.0 and Chrome Driver 81.X
    ...  Chrome Driver version that matches your version of Google Chrome can be found here: https://chromedriver.chromium.org/downloads
    ...  Path to chromedriver on Linux VM: opt/ute/chromedriver
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 03.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-15065 - Initial creation
    ...  - 03.07.2019 - https://jira3.int.net.nokia.com/browse/TAT-16762 - change expected BTS status to Test
    ...  - 21.08.2019 - https://jira3.int.net.nokia.com/browse/TAT-17233 - BTS Start-up view handling and dcumentation about Chrome Driver adding
    ...  - 01.10.2019 - https://jira3.int.net.nokia.com/browse/TAT-17670 - BTS Startup View button click optional
    ...  - 03.07.2020 - https://jira3.int.net.nokia.com/browse/TAT-19824 - Support for subpage "Your connection is not private"
    ...  - 08.10.2020 - https://jira3.int.net.nokia.com/browse/TAT-20214 - TC adjust for Selenium headless mode
    ...  - 06.05.2021 - https://jira3.int.net.nokia.com/browse/TAT-21297 - Adjust login to admin via Selenium for newer SBTS builds
    ...  - 27.10.2021 - https://jira3.int.net.nokia.com/browse/TAT-21754 - Changes due to CNI-61110
    ...  - 23.03.2022 - https://jira3.int.net.nokia.com/browse/TAT-22849 - Add states check for NR cells
    ...  - 21.05.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-47093 - Remove infomodel
    ...  - 18.09.2024 - change to taf.selenium.sbts library
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-15065.png


    Set Tags    CA-BS-RF    OWNER-mateusz-kawka@nokia.com    AUTHOR-mateusz-kawka@nokia.com
    ...    MAINTAINER-mateusz-kawka@nokia.com    GROUP_IN_CHARGE-WRO_3_Vrf    PHASE-CRT    SW-SBTS18
    ...    FEATURE-RP001548_2SB_FC22

    step0: Confirm Dedicated State
    step1: Exit Dedicated State via WebEM
    step2: Check if BTS is in OnAir State


step${step_number}: Confirm Dedicated State

    Log To Console    step${step_number}: Confirm Dedicated State

    ${is_lte}  admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}
    ${TDS_status}  Run Keyword And Return Status
    ...  Check if BTS is in Test Dedicated State  ${is_lte}

    Run Keyword If    ${TDS_status}==False    Fail    Set BTS in Test Dedicated State before run TC
    Log to console  BTS is in Test Dedicated State

    Log to console  Checking Google Chrome and Chrome Driver compatibility !${\n}
    Check And Repair Google Chrome And Chrome Driver Compatibility


step${step_number}: Exit Dedicated State via WebEM

    Log To Console    step${step_number}: Exit Dedicated State via WebEM

    Selenium Login And Disable Screen Lock TDS
    selenium_coam.Disable Test Dedicated State    timeout=300
    Selenium Logout And Close Browser TDS
    Log To Console    Reset to Test Dedicated State Disabled succeeds
    Log To Console    Reset BTS to OnAir State

step${step_number}: Check if BTS is in OnAir State

    Log To Console    step${step_number}: Check if BTS is in OnAir State
#    Sleep    300s    Wait for BTS restart
    Wait Until Keyword Succeeds    15 min  15 sec    Check If Modules And Cells Are OnAir

Check if BTS is in Test Dedicated State
    [Arguments]    ${is_lte}
    Log To Console  Checking for MRBTS state -> Test ...${\n}
    Wait Until Keyword Succeeds  10min  10s  Check MrBTS State  expected_state=Test

    Log To Console  MRBTS state -> Test${\n}Waiting for all RAT(s) state -> Test ...${\n}
    Wait Until Keyword Succeeds  5min  10s  Check RAT State from Infomodel  expected_state=Test

    Run Keyword If  ${is_lte}  Wait Until Keyword Succeeds  5m  10s
    ...  admin.Assert Every  LNCEL  proceduralState=regex"(?i)Prevalidated"  search_for_iot_cells=${True}

Check If Modules And Cells Are OnAir
    [Documentation]
    ...  KW checks if all cells are onAir and modules are Enabled
    Check If All Cells Are OnAir
    admin.Assert Every    RMOD    operationalState=regex"(?i)Enabled"
    admin.Assert Every    SMOD    operationalState=regex"(?i)Enabled"

Selenium Login And Disable Screen Lock TDS
    [Arguments]    ${download_dir}=${TestFiles}/selenium   ${screenshot_dir}=${TestFiles}/selenium
    ${browser}=  selenium_coam.Create Firefox Browser  download_dir=${download_dir}  screenshot_dir=${screenshot_dir}  name=firefox_browser
    ${sw_release}    admin.Get Sw Release Name
    selenium_coam.login  ${WEBUI_URL}  ${WEBUI_NAME}  ${WEBUI_PWD}  version=${sw_release}  browser=${browser}
    ${view_exists}  selenium_coam.start_up_view_window_exists
    Run Keyword If  ${view_exists}  selenium_coam.close_start_up_view_window
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock

Selenium Logout And Close Browser TDS
    Run Keyword And Ignore Error  selenium_coam.logout
    Run Keyword And Ignore Error  selenium_coam.close_browser


TC Setup
    Common Test Setup    expected_BTS_status=Test    cells_check=${false}

TC Teardown
    Run Keywords    Common Test Teardown    AND    SeleniumLibrary.Close Browser
