*** Settings ***
Documentation
...  Test case should activate Reset to Test Dedicated State on BTS via Admin.

Resource    ../../../../resources/hran_frame_sbts_siso.robot
Resource    ../../../../resources/ca_BSRF_general.robot

*** Variables ***

${node}    default

*** Keywords ***
TC__BS-RF__Enter_to_Test_Dedicated_State_via_WebEm__RP001548__Automated
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-13236
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Test case should activate Reset to Test Dedicated State on BTS via Admin.
    ...  After TC execution BTS should be in Test Dedicated State. Cells will be in disabled state.
    ...  (This TC was implemented as a PRECONDITION for other Test Models TCes. Please be aware that after execution of
    ...  this TC cells remains in disabled state and TCes which expects in precondition OnAir state of cells will be failing.
    ...  After this TC you can use TC BS-RF__Exit_from_Test_Dedicated_State_via_WebEm__RP001548
    ...  or do site reset to exit from Test Dedicate STate).
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 21.11.2018 - https://jira3.int.net.nokia.com/browse/TAT-13236 - Initial creation
    ...  - 11.01.2019 - https://jira3.int.net.nokia.com/browse/TAT-13988 - Temporary resignation from one method of checking active TDS
    ...  - 02.04.2019 - https://jira3.int.net.nokia.com/browse/TAT-15594 - Extended time for checking active TDS
    ...  - 27.10.2021 - https://jira3.int.net.nokia.com/browse/TAT-21754 - Changes due to CNI-61110
    ...  - 21.05.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-47093 - Remove infomodel
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  .. image:: https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-13236.png


    Set Tags    CA-BS-RF    OWNER-lukasz.wystup@nokia.com    AUTHOR-lukasz.wystup@nokia.com
    ...    MAINTAINER-mateusz.kawka@nokia.com    GROUP_IN_CHARGE-WRO_3_Vrf    FEATURE-RP001548    PHASE-CRT    SW-SBTS18

    step1: Start Dedicated State


step1: Start Dedicated State

    Log To Console    step1: Start Dedicated State
    Log To Console    Reset to Test Dedicated State

    ${is_lte}  admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}
    admin.Reset To Test Dedicated
    ${TDS_status}  Run Keyword And Return Status
    ...  Check if BTS is in Test Dedicated State  ${is_lte}
    Run Keyword If    ${TDS_status}==False    Fail    Problem with enter to Test Dedicated State
    Log to console  BTS is in Test Dedicated State

Check if BTS is in Test Dedicated State
    [Arguments]    ${is_lte}

    Log To Console  Reset To Test Dedicated Test procedure completed, waiting for MRBTS state -> Test ...${\n}
    Wait Until Keyword Succeeds  10min  10s  Check MrBTS State  expected_state=Test

    Log To Console  MRBTS state -> Test${\n}Waiting for all RAT(s) state -> Test ...${\n}
    Wait Until Keyword Succeeds  5min  10s  Check RAT State from Infomodel  expected_state=Test

    Run Keyword If  ${is_lte}  Wait Until Keyword Succeeds  5m  10s
    ...  admin.Assert Every  LNCEL  proceduralState=regex"(?i)Prevalidated"  search_for_iot_cells=${True}


TC Setup
    Common Test Setup

TC Teardown
    Common Test Teardown
