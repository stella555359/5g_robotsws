*** Settings ***
Documentation
...    author: Jiang Wenwen
...    contact: wenwen.jiang@nokia-sbell.com
...    squad group: MMW_HZ_SG_02

Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_siso_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot

*** Variables ***


*** Keywords ***
Test_suite_setup
    [Documentation]  Author: Wenwen Jiang
    ...              Description: test suite setup
    Log    case begin
    Du Check cell on air via WebUI

Test_suite_teardown
    [Documentation]  Author: Wenwen Jiang
    ...              Description: test suite teardown
    Log    case end
    
Cases common Setup
    [Documentation]    Author: Jiang Wenwen
    ...                Description: case common setup
    log     case begin
    Login WebUI to get MRBTS_ID

Cases Common teardown
    [Documentation]    Author: Jiang Wenwen
    ...                Description: case common teardown
    Check cell until cell on air
    CI_interface.Common Case Teardown

Login WebUI to get MRBTS_ID
    Du login page via WebUI
    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window    timeout=5 
    ${MRBTS_ID}    Get MRBTS Id in COAM WebEM
    set suite variable    ${MRBTS_ID}
    [teardown]    DU COAM selenium logout

Check cell until cell on air
    [Documentation]  Author: Wenwen Jiang
    ...              Description: Check cell until the cell on air
    Du login page via WebUI
    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window    timeout=5    
    Wait Until Keyword Succeeds    12min    20s    Du Check cell on air via WebUI without login
    [teardown]    DU COAM selenium logout

lock a cell for DU
    [Documentation]  Author: Wenwen Jiang
    ...              Description: lock cell
    Du login page via WebUI
    Run Keyword And Ignore Error    selenium_coam.lock_cell    1
    sleep    10s
    [teardown]    DU COAM selenium logout

unlock a cell for Du
    [Documentation]  Author: Wenwen Jiang
    ...              Description: unlock cell
    Du login page via WebUI
    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window    timeout=10
    selenium_coam.unlock_cell    1
    sleep    10s
    [teardown]    DU COAM selenium logout

Perform BTS DU Reset
    [Documentation]  Author: Wenwen Jiang
    ...              Description: reset NODEB's DU
    Du login page via WebUI
    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window    timeout=5
    selenium_coam.reset_site
    [Teardown]  DU COAM selenium logout
   
Login DU once it could login
    [Documentation]  Author: Wenwen Jiang
    ...              Description: log in DU once it could login in WebUI
    sleep    30s
    Wait Until Keyword Succeeds    3min    15s    Du login page via WebUI
    sleep    10s
    Run Keyword And Ignore Error    selenium_coam.close_start_up_view_window    timeout=10
    
Wait Until ABIL status OK
    Wait Until Keyword Succeeds    7min    15s    Check if ABIL status OK
    [Teardown]    DU COAM selenium logout

Check if ABIL status OK
    [Documentation]  Author: Wenwen Jiang
    ...              Description: log in DU to check if ABIL is OK
    &{BBMOD_locked}    selenium_coam.get_abil_info
    ${BBMOD_Locked}    set variable    ${BBMOD_locked}[Status]
    should be equal    ${BBMOD_Locked}[Operational state]    Enabled    ignore_case=True
    should be equal    ${BBMOD_Locked}[Administrative state]    Unlocked    ignore_case=True
    should be equal    ${BBMOD_Locked}[Availability status]    Online    ignore_case=True
    should be equal    ${BBMOD_Locked}[Procedural status]    configured    ignore_case=True
