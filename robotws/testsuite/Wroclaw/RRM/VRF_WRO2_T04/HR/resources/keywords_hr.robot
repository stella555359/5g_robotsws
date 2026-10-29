*** Settings ***
Documentation
...   feature keywords

Library    keywords_hr.py
Variables    variables_hr.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/cell_utilities.py

*** Keywords ***
Perform test on all rmods
    FOR  ${rmod}  IN  @{RMODS.keys()}
        Log To Console    Current RMOD: ${rmod}
        ${cell_id}    Get Substring   ${rmod}    -1
        Set Preferred Cell    ${cell_id}
        Test On Rmod    ${rmod}
    END
    [Teardown]  Detach All Ues

Perform Test On All Cells With Locking
    FOR  ${cell}  IN  @{CELLS.keys()}
        Log To Console    Current Cell: ${cell}
        ${cell_id}    Get Substring   ${cell}    -1
        Set Preferred Cell    ${cell_id}
        Test On All Cells With Locking    ${cell}
    END
    [Teardown]  Detach All Ues

Perform Test With Cplane Process Crash
    FOR  ${container}  IN  @{CPLANE_CONTAINERS.keys()}
        Log To Console    Current Container: ${container}
        Perform Test With Cplane Crash    ${container}
    END
    [Teardown]  Detach All Ues
