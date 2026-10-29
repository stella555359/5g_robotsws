*** Settings ***
Documentation
...   author: Grzegorz Slowinski
...   contact: grzegorz.slowinski@nokia.com
...   Test for  TC212 CB008053 A#B3 test automation

Library    ../5GC001167/resources/delta_keywords.py
Library    ute_ue
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/l1l2_verifiers.py
Library    ../5GC002640/resources/scell_management.py
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2     WITH NAME    L1L2
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod     WITH NAME    Tcpdump
Resource   ../regression/regression_keywords.robot
Resource   ./resources/keywords.robot
Resource    ../regression/regression_keywords.robot

*** Keywords ***
CB008053_B3_Interaction_between_1F_3T_DL_CA_and_1F_1T_UL_CA
    keywords.Set MaxnumScell    maxNumScellsDlFr1    3
    counters.Wait For Pm Counters Interval
    Attenuate All Cells
    keywords.Decrease Attenuation For ANR Cell With Id    5
    ute_ue.Require Ue    UE_1    UE_1
    ute_ue.Attach Ue   UE_1    timeout=${120}
    Set Attenuation For 5CC Cell With Id    1    8
    Set Attenuation For 5CC Cell With Id    5    66
    Clear Attenuation
    Start DL Traffic For Ue    UE_1    900Mbits/sec    duration=100s
    Start UL Traffic For Ue    UE_1    80Mbits/sec     duration=100s
    Verify 4CC counters
    Verify DL Tput For Ue    UE_1
    Verify UL Tput For Ue    UE_1
    [Teardown]    Run Keywords    Clear Attenuation    AND
    ...    Detach Ue   UE_1

