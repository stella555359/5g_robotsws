*** Settings ***
Documentation
...  authors: Piotr Szlegel, Jakub Migdalek and Karolina Pawlik
...  contact: piotr.szlegel@nokia.com | jakub.migdalek@nokia.com | karolina.pawlik.ext@nokia.com
...  Description: Test Cases for 5GC000866-G and 5GC000865-G 19B features:
...  5GC000865_Integrity_Protection_for_C-Plane_5GC000866_Ciphering_of_U-Plane_&_C-Plane

# Library         taf.ue
# Library         taf.ul.messaging.mtk      WITH NAME    mtk
# Resource        testsuite/RRM/Wroclaw/resources/preconditions.robot
# Resource        testsuite/RRM/Wroclaw/resources/connections.robot
# Resource        testsuite/RRM/Wroclaw/5GC000865/resources/bts_log_check.robot
# Resource        testsuite/RRM/Wroclaw/5GC000900/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001348/resources/resources.robot

*** Variables ***
${tput_DL_bandwith_866}     10Mbits/sec
${tput_UL_bandwith_866}     2MBits/sec
${tput_deviation}       15%
${tput_duration_866}        30s
${Packet_Size}          1200

*** Keywords ***

[1]5GC000865-G_5GC000866-G_1_AS_Integrity_SNOW_and_Ciphering_AES_without_new_PDU_Session_one_cell
    [Documentation]     This test case checks gNB behavior for Access Stratum security activation, security
                        ...  algorithm selection, securitykey derivation, security activation for SRB1, SRB2
                        ...  and DRBs during Initial Context Setup with one or multiple PDU sessions.
    Perform commissioning with given parameters  nea0=1
    ...                 nea1_128=4
    ...                 nea2_128=9
    ...                 nea3_128=2
    ...                 nia0=0
    ...                 nia1_128=9
    ...                 nia2_128=4
    ...                 nia3_128=2
    ...                 inactivityTimerSA=60
    bts_log_check.Pcap collection
    Run Keyword And Ignore Error  Check adb devices
    Attach UE SA For test
    Start ULDL UDP SA   ${tput_DL_bandwith_866}   ${tput_UL_bandwith_866}   ${tput_duration_866}
    Verify ULDL UDP SA   ${tput_DL_bandwith_866}   ${tput_UL_bandwith_866}

    Waiting for RRC idle

    Start ULDL UDP SA   ${tput_DL_bandwith_866}   ${tput_UL_bandwith_866}   ${tput_duration_866}
    Verify ULDL UDP SA   ${tput_DL_bandwith_866}   ${tput_UL_bandwith_866}
    bts_log_check.Pcap log downlad
    Detach UEs Used By Test
    Check pcap log  nea=nea2  nia=nia1

[1]5GC000865-G_5GC000866-G_1_AS_Integrity_AES_and_Ciphering_NULL_Nullfallback_Off_with_new_PDU_Session_one_cell
    [Documentation]     This test case checks gNB behavior for Access Stratum security activation, security
                        ...  algorithm selection, securitykey derivation, security activation for SRB1, SRB2
                        ...  and DRBs during Initial Context Setup with one or multiple PDU sessions.
    Perform commissioning with given parameters
    ...                 nea0=1
    ...                 nea1_128=3
    ...                 nea2_128=9
    ...                 nea3_128=2
    ...                 nia0=0
    ...                 nia1_128=3
    ...                 nia2_128=9
    ...                 nia3_128=2
    ...                 inactivityTimerSA=60
    Run Keyword And Ignore Error  Check adb devices
    Attach UE SA For test
    Start ULDL UDP SA   ${tput_DL_bandwith_866}   ${tput_UL_bandwith_866}   ${tput_duration_866}
    Verify ULDL UDP SA   ${tput_DL_bandwith_866}   ${tput_UL_bandwith_866}

    Waiting for RRC idle

    Start ULDL UDP SA   ${tput_DL_bandwith_866}   ${tput_UL_bandwith_866}   ${tput_duration_866}
    Verify ULDL UDP SA   ${tput_DL_bandwith_866}   ${tput_UL_bandwith_866}
    Detach UEs Used By Test

## secound part of test case
    Perform commissioning with given parameters
    ...                 nea0=9
    ...                 nea1_128=0
    ...                 nea2_128=0
    ...                 nea3_128=0
    ...                 nia0=0
    ...                 nia1_128=3
    ...                 nia2_128=9
    ...                 nia3_128=2
    ...                 nullFallback=false
    Pcap collection NGAP
    Run Keyword And Ignore Error    Attach UE SA For test
    bts_log_check.Pcap log downlad
    Detach UEs Used By Test
    Check pcap for NGAP

[1]5GC000865-G_5GC000866-G_1_AS_Integrity_SNOW_and_Ciphering_SNOW_without_new_PDU_Session
    [Documentation]     This test case checks gNB behavior for Access Stratum security activation, security
                        ...  algorithm selection, securitykey derivation, security activation for SRB1, SRB2
                        ...  and DRBs during Initial Context Setup with one or multiple PDU sessions.
    Perform commissioning with given parameters
    ...                 nea0=1
    ...                 nea1_128=9
    ...                 nea2_128=3
    ...                 nea3_128=2
    ...                 nia0=0
    ...                 nia1_128=9
    ...                 nia2_128=3
    ...                 nia3_128=2
    ...                 inactivityTimerSA=60
    Run Keyword And Ignore Error  Check adb devices
    bts_log_check.Pcap collection
    Attach UE SA For test
    Start ULDL UDP SA    ${tput_DL_bandwith_866}   ${tput_UL_bandwith_866}   ${tput_duration_866}
    Verify ULDL UDP SA   ${tput_DL_bandwith_866}   ${tput_UL_bandwith_866}

    Waiting for RRC idle

    Start ULDL UDP SA   ${tput_DL_bandwith_866}   ${tput_UL_bandwith_866}   ${tput_duration_866}
    Verify ULDL UDP SA   ${tput_DL_bandwith_866}   ${tput_UL_bandwith_866}
    bts_log_check.Pcap log downlad
    Detach UEs Used By Test
    Check pcap log  nea=nea1  nia=nia1


[1]5GC000865-G_5GC000866-G_1_AS_Integrity_AES_and_Ciphering_AES_without_new_PDU_Session
    [Documentation]      This test case checks gNB behavior for Access Stratum security activation, security
                        ...  algorithm selection, securitykey derivation, security activation for SRB1, SRB2
                        ...  and DRBs during Initial Context Setup with one or multiple PDU sessions.
       Perform commissioning with given parameters
    ...                 nea0=1
    ...                 nea1_128=3
    ...                 nea2_128=9
    ...                 nea3_128=2
    ...                 nia0=0
    ...                 nia1_128=3
    ...                 nia2_128=9
    ...                 nia3_128=2
    ...                 inactivityTimerSA=60
    Run Keyword And Ignore Error  Check adb devices
    bts_log_check.Pcap collection
    Attach UE SA For test
    Start ULDL UDP SA   ${tput_DL_bandwith_866}   ${tput_UL_bandwith_866}   ${tput_duration_866}
    Verify ULDL UDP SA   ${tput_DL_bandwith_866}   ${tput_UL_bandwith_866}

    Waiting for RRC idle

    Start ULDL UDP SA   ${tput_DL_bandwith_866}   ${tput_UL_bandwith_866}   ${tput_duration_866}
    Verify ULDL UDP SA   ${tput_DL_bandwith_866}   ${tput_UL_bandwith_866}
    Detach UEs Used By Test
    bts_log_check.Pcap log downlad
    Check pcap log  nea=nea2  nia=nia2

[1]5GC000865-G_5GC000866-G_1_AS_Integrity_AES_and_Ciphering_NULL_Nullfallback_Off_without_new_PDU_Session
    [Documentation]     This test case checks gNB behavior for Access Stratum security activation, security
                        ...  algorithm selection, securitykey derivation, security activation for SRB1, SRB2
                        ...  and DRBs during Initial Context Setup with one or multiple PDU sessions.
    Perform commissioning with given parameters
    ...                 nea0=9
    ...                 nea1_128=0
    ...                 nea2_128=0
    ...                 nea3_128=0
    ...                 nia0=0
    ...                 nia1_128=3
    ...                 nia2_128=9
    ...                 nia3_128=2
    ...                 nullFallback=false
    Run Keyword And Ignore Error  Check adb devices
    Pcap collection NGAP
    Attach UE SA For test
    bts_log_check.Pcap log downlad
    Detach UEs Used By Test
    Check pcap for NGAP
