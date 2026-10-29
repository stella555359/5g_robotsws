*** Settings ***
Documentation
...   author: Grzegorz Slowinski
...   contact: grzegorz.slowinski@nokia.com
...   Test for CB008239 B#B4 test automation

Library    ../5GC001167/resources/delta_keywords.py
Library    ute_ue
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library    ./resources/nrrele.py
Resource   ../regression/regression_keywords.robot
Resource   ./resources/keywords.robot
Resource   ../5GC001167/resources/keywords.robot

*** Keywords ***
CB008239_B_B4_inter_RAT_ANR_Neighbour_relation_removal_due_to_consecutive_RE_CHECK_state_reporting
    Attenuate All Cells
    Decrease Attenuation For ANR Cell With Id    3
    Require Ue    UE_2    UE_2
    Attach Ue   UE_2    timeout=${10}
    Trigger A2 Attenuation For ANR Cell With Id    3
    Decrease Attenuation For ANR Cell With Id    1
    Log    Starting NRREL Check    console=yes
    Wait Until Keyword Succeeds     120    15     Check ANR Nrrele    3
    Log    Barring LTE cell   console=yes
    cell_barred
    Attenuate All Cells
    Decrease Attenuation For ANR Cell With Id    3
    Trigger A2 Attenuation For ANR Cell With Id    3
    Decrease Attenuation For ANR Cell With Id    1
    Log    Starting NRREL Removal Check    console=yes
    Wait Until Keyword Succeeds     120    15    Check ANR Nrrele Removal     3
    [Teardown]    Run Keywords    8239 Teardown   AND
    ...    Detach Ue   UE_2
