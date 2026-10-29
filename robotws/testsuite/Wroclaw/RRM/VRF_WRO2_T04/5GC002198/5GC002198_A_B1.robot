*** Settings ***
Documentation
...   author: Grzegorz Slowinski
...   contact: grzegorz.slowinski@nokia.com
...   Test for 5GC002198 A#B1 test automation

Library    ../5GC001167/resources/delta_keywords.py
Library    ute_ue
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Resource   ../regression/regression_keywords.robot
Resource   ./resources/keywords.robot

*** Keywords ***
[1]TC01_A_B1_PCI_Resolution_and_neighbour_relation_addition_(Inter_Frequency_Intra_gNB_UE based)_Without_SRB3
    Set Attenuation For ANR Cell With Id    2_1
    Require Ue    UE_1    UE_1
    Attach Ue   UE_1    timeout=${10}
    Set Attenuation For ANR Cell With Id    2
    Log    Starting NRREL Check    console=yes
    Wait Until Keyword Succeeds     120    15     Check ANR Nrrel    2
    Log    Checking counters    console=yes
    Verify Counter Value    M55124C05002    1    2    wait_for_interval=${TRUE}
    Verify Counter Value    M55124C05001    1    2
    Verify Counter Value    M55147C01001    1    2
    [Teardown]    Run Keywords    Nullify Attenuation On All Ports    AND
    ...    Detach Ue   UE_1
