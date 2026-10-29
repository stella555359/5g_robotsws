*** Settings ***
Documentation
...   author: Tomasz Godlewski
...   contact: tomasz.godlewski@nokia.com

Library    ute_ue
Library   testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/testline_preparation.py
Library    taf.sw.syslog    WITH NAME    syslog
Library    ./resources/keywords_hr.py
Resource    ./resources/keywords_hr.robot
Variables    ./resources/variables_hr.py

*** Variables ***
@{RMOD_1_PORTS}  1  2  3  4
@{RMOD_2_PORTS}  5  6  7  8
@{RMOD_3_PORTS}  9  10  11  12

*** Keywords ***
hanging_resources_reset_rmod
    Require Ue    UE_1    capabilities=UE_1
    Require Ue    UE_2    capabilities=UE_2
    Detach All Ues
    FOR  ${i}  IN RANGE    ${NUM_OF_ITERATIONS}
        Log To Console    Iteration: ${i}
        Perform test on all rmods
    END
    [Teardown]    Run Keywords
    ...    Detach Ue    UE_1    AND
    ...    Detach Ue    UE_2    AND
    ...    Restore Preferred Cell    AND
    ...    syslog.Teardown All Aliases For Syslog    AND
    ...    Set Initial Attenuation 3 cells


hanging_resources_reset_nglink
    Require Ue    UE_1    capabilities=UE_1
    Require Ue    UE_2    capabilities=UE_2
    Detach All Ues
    FOR  ${i}  IN RANGE    ${NUM_OF_ITERATIONS}
        Log To Console    Iteration: ${i}
        Perform test with block ng link
    END
    [Teardown]    Run Keywords
    ...    Detach Ue    UE_1    AND
    ...    Detach Ue    UE_2    AND
    ...    syslog.Teardown All Aliases For Syslog    AND
    ...    Set Initial Attenuation 3 cells

hanging_resources_cell_lock
    Require Ue    UE_1    capabilities=UE_1
    Require Ue    UE_2    capabilities=UE_2
    Detach All Ues
    FOR  ${i}  IN RANGE    ${NUM_OF_ITERATIONS}
        Log To Console    Iteration: ${i}
        Perform test on all cells with locking
    END
    [Teardown]    Run Keywords
    ...    Detach Ue    UE_1    AND
    ...    Detach Ue    UE_2    AND
    ...    Restore Preferred Cell    AND
    ...    syslog.Teardown All Aliases For Syslog    AND
    ...    Set Initial Attenuation 3 cells

hanging_resources_cplane_process_crash
    Require Ue    UE_1    capabilities=UE_1
    Require Ue    UE_2    capabilities=UE_2
    Detach All Ues
    Perform Test With Cplane Process Crash
    [Teardown]    Run Keywords
    ...    Detach Ue    UE_1    AND
    ...    Detach Ue    UE_2    AND
    ...    syslog.Teardown All Aliases For Syslog    AND
    ...    Set Initial Attenuation 3 cells
