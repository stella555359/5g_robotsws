*** Settings ***
Documentation
...  author: Kamil Bielecki
...  contact: kamil.bielecki@nokia.com

Library     DateTime                                                          WITH NAME    dt
Library     taf.sbts.oam.coam.admin                                           WITH NAME    admin
Library     taf/rfrl/procedures/resources/python/sleeping_cell_detector.py    WITH NAME    scd
Resource    taf/rfrl/bts/robot/gnb.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Variables   taf/rfrl/procedures/resources/python/common_allowed_alarms.py

Suite Setup         Suite Setup
Suite Teardown      Common Suite Teardown
Test Setup          Test Setup
Test Teardown       Test Teardown

*** Test Cases ***
CB009029-5G-G5-B1_1_Reaching_OnAir_state_with_NR_FDD_cells_25Mhz_in_NSA_Mode
    Log Action To Console       Performing NSA commissioning
    Perform Full Commissioning on Classical gNB    prefix_tag=NSA    awaiting_time=500
    Wait until all cells are onair
    Verify Default Allowed Alarms on gNB

CB009029-5G-G5-B1_2_Reaching_OnAir_state_with_NR_FDD_cells_25Mhz_in_SA_Mode
    Log Action To Console       Performing SA commissioning
    Perform Full Commissioning on Classical gNB    prefix_tag=SA    awaiting_time=500
    Wait until all cells are onair
    Verify Default Allowed Alarms on gNB


*** Keywords ***
Log Action To Console
    [Arguments]   ${msg}    ${datatime}=${True}    ${new_line_before}=${True}    ${new_line_after}=${False}
    [Documentation]  :param msg:     message logged
    Run keyword if    '${new_line_before}'=='${True}'   Log To Console    \n    no_newline=${True}
    ${date}=    Run keyword if    '${datatime}'=='${True}'   Get Current Date
    Run keyword if    '${datatime}'=='${True}'   Log To Console    [*][${date}] ${msg}    no_newline=${True}
    Run keyword if    '${datatime}'=='${False}'   Log To Console    [*] ${msg}    no_newline=${True}
    Run keyword if    '${new_line_after}'=='${True}'   Log To Console    \n    no_newline=${True}

Suite Setup
    Log Action To Console      Suite Setup
    Common Suite Setup With OnAir Test Line Preparation
    ...     swconfig_from_path=commissionings/Krakow/swconfig/default_swconfig.txt
    ...     should_LTE_neighbour_be_changed=False

Test Teardown
    scd.Verify Sleeping Cell Detection
    Collect Logs After Test Finished
    Common Postconditions

Test Setup
    scd.Start Sleeping Cell Detection Watchdog  log_dir=${OUTPUTDIR}/SleepingCell
    Collect Logs During Test

Wait until all cells are onair
    Log Action To Console    Wait until all cells are onair
    Wait Until Keyword Succeeds    5min    15sec
    ...     Verify Setup Of All Cells


