*** Settings ***
Documentation
...   author: Grzegorz Slowinski
...   contact: grzegorz.slowinski@nokia.com
...   Test for  [1]TC08_CB006733_B_21_5CC A4-based SCell Addition test automation

Library    ../5GC001167/resources/delta_keywords.py
Library    ute_ue
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/resources/attenuator_keywords.py
Library    testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/l1l2_verifiers.py
Library    ../5GC002640/resources/scell_management.py
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring.L1L2     WITH NAME    L1L2
Library    testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod.TcpdumpSmod     WITH NAME    Tcpdump
Resource   ../regression/regression_keywords.robot
Resource   ./resources/keywords.robot

*** Keywords ***
CB006733_B_21_5CC A4_based SCell Addition
    counters.Wait For Pm Counters Interval
    Attenuate All Cells
    Decrease Attenuation For ANR Cell With Id    1
    ute_ue.Require Ue    UE_1    UE_1
    ute_ue.Reboot Ue   UE_1    180
    ute_ue.Attach Ue   UE_1    timeout=${10}
    Start DL Traffic For Ue    UE_1    2Mbits/sec    duration=100s
    BuiltIn.Sleep    15
#    Set Attenuation For 5CC Cell With Id    1    8
    Set Attenuation For 5CC Cell With Id    5    36
    Decrease Attenuation For ANR Cell With Id    2
    Decrease Attenuation For ANR Cell With Id    6
    BuiltIn.Sleep    15
    Start DL Traffic For Ue    UE_1    1500Mbits/sec    duration=100s
    Verify DL Tput For Ue    UE_1
    5CC Counters Loop
    [Teardown]    Run Keywords    Clear Attenuation    AND
    ...    Detach Ue   UE_1

