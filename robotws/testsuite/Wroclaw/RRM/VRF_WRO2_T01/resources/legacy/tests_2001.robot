*** Settings ***
Documentation
...  author:        Maciej Krysztofiak
...  contact:       maciej.krysztofiak@nokia.com

Library         taf.ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/keywords_2001.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/pcap_common.robot

*** Keywords ***
[1]5GC002001-A-UC_#01_NSA_Feature_activate
    Cell preparation 2001
    Check active alarms

[1]5GC002001-A-UC_#02_NSA_Modifying_muted_beams_no_signaling
    Commissioning 2001 02
    Commissioning 2001 02_1

    Detach Ue   AT_BASED_UE_1
    sleep  20s
    Start L1L2 logs gathering
    Attach Ue   AT_BASED_UE_1
    sleep  30s
    ${path}  Stop L1L2 logs gathering and download pcap
#
    Verify BIP logs 2001 02  ${path}

[1]5GC002001-A-UC_#04_NSA_Ue_operates_muted_beam_counters_eCPRI [beamSet_6]
    Commissioning 2001 04
    Reattach
    Do Throughput
    ${tput_dl}  Get Throughput Dl
    ${tput_ul}  Get Throughput Ul

    Commissioning 2001 04_1
    Reattach

    Start L1L2 logs gathering
    sleep  5s
    Do Throughput
    ${tput_dl2}  Get Throughput Dl
    ${tput_ul2}  Get Throughput Ul
    sleep  5s
    ${path}  Stop L1L2 logs gathering and download pcap
    log to console  ${tput_dl}
    log to console  ${tput_dl2}
    log to console  ${tput_ul}
    log to console  ${tput_ul2}
    Verify BIP logs 2001 04  ${path}
    Verify BIP logs 2001 04  /home/ute/robotws5g/tcpdump_L2L1_bip_filtering_off.pcap
    Download Latest Counters  1m
    Check counters 2001 04
    Download Latest Counters  15m
    Check counters 2001 04

[1]5GC002001-A-UC_#05_NSA_Ue_operates_muted_beam_EIRP_counters_eCPRI_monitor
    Commissioning 2001 05
    Check active alarms
    Download latest counters
    Check counters 2001 05
