*** Settings ***
Documentation
...   author: Grzegorz Slowinski
...   contact: grzegorz.slowinski@nokia.com
...   Test for CB008239 A#B7 test automation wit counters

Library    ../5GC001167/resources/delta_keywords.py
Library    ute_ue
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library    ./resources/nrrele.py
Resource   ../regression/regression_keywords.robot
Resource   ./resources/keywords.robot

*** Keywords ***
CB008239_A_B7_TC06_New_inter_RAT_Neighbour_object_addition_to_Network_Plan_File
    Set Attenuation For ANR Cell With Id    2_1
    Attenuate All Ports
    Decrease Attenuation For ANR Cell With Id    3
    counters.Wait For Pm Counters Interval
    Require Ue    UE_2    UE_2
    Attach Ue   UE_2    timeout=${10}
    Trigger A2 Attenuation For ANR Cell With Id    3
    Decrease Attenuation For ANR Cell With Id    1
    Log    Starting NRREL Check    console=yes
    Wait Until Keyword Succeeds     120    15     Check ANR Nrrele    3
    ${counter1}    Verify Counter Value    M55124C07002    1    3    wait_for_interval=${TRUE}
    ${counter2}    Verify Counter Value    M55124C07001    1    3
    Verify Counter Value    M55147C01501    1
    Verify Counter Value    M55147C01502    0    3
    [Teardown]    Run Keywords    Clear Attenuation On Ports    AND
    ...    Detach Ue   UE_2
