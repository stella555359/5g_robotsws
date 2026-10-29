*** Settings ***
Documentation
...   author: Grzegorz Slowinski
...   contact: grzegorz.slowinski@nokia.com
...   Test for 5GC008241 B#B4 test automation

Library    ../5GC001167/resources/delta_keywords.py
Library    ute_ue
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Resource   ../regression/regression_keywords.robot
Resource   ./resources/keywords.robot

*** Keywords ***
[1]TC08_CB008241_B#B4_Neighbour_relation_removal_due_to_consecutive_RE_CHECK_state_reporting
    Attenuate All Cells
    Decrease Attenuation For ANR Cell With Id    3
    Require Ue    UE_2    UE_2
    Attach Ue   UE_2    timeout=${10}
    Decrease Attenuation For ANR Cell With Id    2
    Set Attenuation For ANR Cell With Id    3
    Log    Starting NRREL Check    console=yes
    Wait Until Keyword Succeeds     120    15     Check ANR Nrrel    3
    Log    Modifiying MaxNumOfUsers    console=yes
    Set maxNumOfSCellAlloc For 8241 Cell  2    0
    Set Max Number Of Users For 8241 Cell  2    0
    8241 HO
    Log    Starting NRREL Removal Check    console=yes
    Wait Until Keyword Succeeds     120    15    Check ANR Nrrel Removal    3
    [Teardown]    Run Keywords    8241 Teardown   AND
    ...    Detach Ue   UE_2
