*** Settings ***
Documentation
...   author: Grzegorz Slowinski
...   contact: grzegorz.slowinski@nokia.com
...   Test for CB008239 A#B7 counter test automation

Library    ./resources/nrrele.py
Library    ute_ue
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library         taf.sbts.oam.coam.admin  WITH NAME   admin
Library     ta5g_cell_operations
Resource   ../regression/regression_keywords.robot
Resource   ./resources/keywords.robot

*** Keywords ***
CB008239_A_B7_counters
    Lock All Cells
    Set Attenuation For ANR Cell With Id    2_1
    Attenuate All Ports
    Decrease Attenuation For ANR Cell With Id    3
    counters.Wait For Pm Counters Interval
    ute_ue.Require Ue    UE_2    UE_2
#    ute_ue.Reboot Ue   UE_2    180
    ute_ue.Attach Ue   UE_2
    Trigger A2 Attenuation For ANR Cell With Id    3
    Decrease Attenuation For ANR Cell With Id    1
    Log    Starting NRREL Check    console=yes
    Wait Until Keyword Succeeds     120    15     Check ANR Nrrele    3

    ${counter1}    Verify Counter Value    M55124C07002    1    3    wait_for_interval=${TRUE}
    ${counter2}    Verify Counter Value    M55124C07001    1    3    wait_for_interval=${TRUE}
    [Teardown]    Run Keywords
    ...    Clear Attenuation On Ports    AND
    ...    ute_ue.Detach Ue   UE_2    AND
    ...    Unlock All Cells
