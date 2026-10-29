*** Settings ***

Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource        testsuite/Wroclaw/RRM/resources/logs.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001390/resources/kw_1390.robot


#Test Setup      Run keyword
#...    Require Ue    UE_2    capabilities=REAL_ANDROID_UE_SA
#
#Test Teardown   Run Keyword
#...    Detach Ue     UE_2

*** Variables ***
${tput_DL_bandwith_1390L}     980 Mbits/sec
${tput_UL_bandwith_1390L}     50 MBits/sec
${tput_deviation}       10%
${tput_duration_1390L}        330s
${Packet_Size}          1200

*** Keywords ***
[1]5GC001390_L_02_Inter-band_FDD_-_Inter-band_FDD_-_FR1_TDD_CA_for_SA_UE
    [Documentation]   This case is to test CA FR1 TDD with FDD PCI 101 as Pcell and TDD PCI 104 as SCell.
    Setup attenuators
    Set attenuators for 1390L
    Run keyword and ignore error   Delete old DCAP folder
    Start syslog collection
    sleep  10s
    Prepare and start DCAP   bts_mpalne=10.44.76.47   nrCells=NRCELL_R-101 NRCELL_R-102 NRCELL_R-103
    Attach UE    UE_2
    Sleep  5s
    Set attenuation and check  lines=${lines_gNB_410_AEHC_4_TDD}   value=0
    Start ULDL UDP SA  ${tput_DL_bandwith_1390L}   ${tput_UL_bandwith_1390L}   ${tput_duration_1390L}
    Sleep  10s
    Stop syslog collection
    Stop DCAP trace and download logs
    Run Keyword and Ignore Error   Verify ULDL UDP SA     ${tput_DL_bandwith_1390L}   ${tput_UL_bandwith_1390L}
    Verify registration to FDD PCell
    Verify TDD SCell activation
    kw_1390.Verify PM Counters
