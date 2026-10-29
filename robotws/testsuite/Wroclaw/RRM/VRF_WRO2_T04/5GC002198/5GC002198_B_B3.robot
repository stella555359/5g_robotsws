*** Settings ***
Documentation
...   author: Grzegorz Slowinski
...   contact: grzegorz.slowinski@nokia.com
...   Test for 5GC002198 B#B3 test automation

Library    ../5GC001167/resources/delta_keywords.py
Library    ute_ue
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Resource   ../regression/regression_keywords.robot
Resource   ./resources/keywords.robot
Resource   ../5GC001167/resources/keywords.robot

*** Keywords ***
[1]TC14_B_B3_Neighbour_relation_removal_due_to_consecutive_RECHECK_state_reporting_(Inter_Frequency_UE_based)
    Require Ue    UE_1    UE_1
    Attach Ue   UE_1    timeout=${10}
    Set Attenuation For ANR Cell With Id    2
    Wait Until Keyword Succeeds     120    15    Check ANR Nrrel    2
    Clear Attenuation
    Perform ANR HO
    Log    Modifiying MaxNumOfUsers    console=yes
    Set Max Number Of Scell Alloc For Cell  3    0
    Set Max Number Of Users For ANR Cell   3    0
    Wait Until Keyword Succeeds     120    15    Check ANR Nrrel    3
    Perform ANR HO
    Log    Starting NRREL Removal Check    console=yes
    Wait Until Keyword Succeeds     120    15    Check ANR Nrrel Removal    2
    [Teardown]    Run Keywords    ANR Teardown    AND
    ...    Detach Ue   UE_1
