*** Settings ***
Documentation
...  author: Sebastian Mikos
...  contact: sebastian.mikos@nokia.com

Library         ute_ue

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Resource        testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource        testsuite/Wroclaw/RRM/resources/logs.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/FGCR-10228/resources/kw_fgcr10228.robot

Test Setup      Run keywords
...    Require Ue    UE_1    capabilities=REAL_ANDROID_UE_SA   AND
...    Require Ue    UE_2    capabilities=REAL_ANDROID_UE_S20_1  AND
...    Require Ue    UE_3    capabilities=REAL_ANDROID_UE_S20_2  AND
...    Require Ue    UE_4    capabilities=REAL_ANDROID_UE_NOKIA


Test Teardown   Run Keywords
...    Detach Ue     UE_1    AND
...    Detach Ue     UE_2    AND
...    Detach Ue     UE_3    AND
...    Detach Ue     UE_4

*** Variables ***
${tput_DL_bandwith_10228}     1200 Mbits/sec
${tput_UL_bandwith_10228}     50 MBits/sec
${tput_DL_bandwith_10228_Nokia}     100 Mbits/sec
${tput_UL_bandwith_10228_Nokia}     30 MBits/sec
${tput_deviation}       10%
${tput_duration_10228}        300s
${Packet_Size}          1200

*** Test Cases ***
[1]FGCR-10228_05_Simultaneous_max_tput_with_3UEs_on_different_CA_sectors_and_1UE_on_DSS_cell_-_11_cells
    [Documentation]   This scenario is to verify that gNB can successfully handle bidirectional data transfer
    ...     for a single UE in all CA sectors and, at least, in one DSS cell simultaneously. In this test, gNB is configured with 11 cells
    Start syslog collection
    sleep  10s
    Setup attenuators
    Log to console   Attenuator 1 set
    Set attenuator for 10228 step 1
    sleep   5s
    Attach UE   UE_1   #Qualcomm
    ${UE_1_IP}=    ute_ue.Get Ue Info    UE_1   IP
    Log to console  ${UE_1_IP}
    Attach UE   UE_2   # Samsung 1
    ${UE_2_IP}=    ute_ue.Get Ue Info    UE_2   IP
    Log to console  ${UE_2_IP}
    Attach UE   UE_3   # Samsung 2
    ${UE_3_IP}=    ute_ue.Get Ue Info    UE_3   IP
    Log to console  ${UE_3_IP}
    Log to console   Attenuator 2 set
    Set attenuator for 10228 step 2
    Attach UE   UE_4  # Nokia
    ${UE_4_IP}=    ute_ue.Get Ue Info    UE_4   IP
    ${UE_4_CELL_ID}=    ute_ue.Get Ue Info    UE_4   PCI
    Log to console  ${UE_4_IP}
    Log to console  ${UE_4_CELL_ID}
    sleep  5s
    Start tput on Qualcomm UE1   ${tput_DL_bandwith_10228}   ${tput_UL_bandwith_10228}   ${tput_duration_10228}
    Start tput on Samsung UE2    ${tput_DL_bandwith_10228}   ${tput_UL_bandwith_10228}   ${tput_duration_10228}
    Start tput on Samsung UE3    ${tput_DL_bandwith_10228}   ${tput_UL_bandwith_10228}   ${tput_duration_10228}
    Start tput on Nokia UE4      ${tput_DL_bandwith_10228_Nokia}   ${tput_UL_bandwith_10228_Nokia}   ${tput_duration_10228}
    Run Keyword and Ignore Error   Verify tputs   ${tput_DL_bandwith_10228}   ${tput_UL_bandwith_10228}
    Run Keyword and Ignore Error   Veryfy tput on Nokia   ${tput_DL_bandwith_10228_Nokia}   ${tput_UL_bandwith_10228_Nokia}
    Stop syslog collection
    Verify registration to FDD PCells
    Verify TDD SCells activation
    Verify PM Counters 10228

