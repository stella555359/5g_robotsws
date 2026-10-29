*** Settings ***
Documentation
...   author: Grzegorz Slowinski
...   contact: grzegorz.slowinski@nokia.com
...   Test for CB008241 A#B1 test automation

Library    ../5GC001167/resources/delta_keywords.py
Library    ute_ue
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Resource   ../regression/regression_keywords.robot
Resource   ./resources/keywords.robot

*** Keywords ***
[1] TC01_CB008241_A#B1_PCI_Resolution_and_neighbour_relation_addition–Success_case
    Set Attenuation For ANR Cell With Id    2_1
    Attenuate All Ports
    Decrease Attenuation For ANR Cell With Id    3
    counters.Wait For Pm Counters Interval
    Require Ue    UE_2    UE_2
    Attach Ue   UE_2    timeout=${10}
    Decrease Attenuation For ANR Cell With Id    2
    Trigger A2 Attenuation For ANR Cell With Id    3
    Log    Starting NRREL Check    console=yes
    Wait Until Keyword Succeeds     120    15     Check ANR Nrrel    3
    Verify Counter Value    M55124C05002    1    3    wait_for_interval=${TRUE}
    Verify Counter Value    M55124C05001    1    3
    Verify Counter Value    M55147C01001    1    3
    Verify Counter Value    M55147C01002    0    3
    [Teardown]    Run Keywords    Nullify Attenuation On All Ports    AND
    ...    ute_ue.Detach Ue   UE_2
