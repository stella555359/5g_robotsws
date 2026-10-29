# robocop: disable=empty-section
*** Settings ***
Documentation
...   author: Maciej Krysztofiak, Piotr Szlegel
...   contact: maciej.krysztofiak@nokia.com, piotr.szlegel@nokia.com
...   Description: Suite for Test Cases for 5GC000534-D

Library      taf.ue
Resource     testsuite/Wroclaw/RRM/resources/preconditions.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/keywords_534.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/setup_teardown.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common_kw.robot
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/legacy/common.py
Library      taf.converters.pcaptopdml   WITH NAME   pcaptopdml


*** Keywords ***
[1]5GC000534-D_001_UE_activating_beamSet
    Perform commissioning 5GC000534D
    ${alarms}=      get active alarms
    Check if no unexpected alarms       alarms_list=${alarms}
    Check dlChBw   80MHz
    Start L1L2 logs gathering
    sleep    20s
    ${path}  Stop L1L2 logs gathering and download pcap
#    ${cells_to_mirror}  Get global cell id of first cell
#    ${cells_to_mirror}  Create List  ${cells_to_mirror}
#    Start capturing interface mirroring logs  ${cells_to_mirror}  mirroring_time=10
#    ${path}  Collect interface mirroring logs
    Verify bip logs beamset 2  ${path}

[2]5GC000534-D_001_UE_activating_beamSet
    Perform commissioning 5GC000534D
    ...                 actBeamforming=true
    ...                 basicBeamSet=beamSet_6
    ...                 leftEdgeAngle=45
    ...                 nrBtsBeamRefinementP2=false
    ...                 rightEdgeAngle=45
    ...                 numberOfTransmittedSsBlocks=6 beams
    ...                 chBw=100MHz
    ${alarms}=      get active alarms
    Check if no unexpected alarms       alarms_list=${alarms}
    Check dlChBw   100MHz
    Start L1L2 logs gathering
    ${path}  Stop L1L2 logs gathering and download pcap
#    ${cells_to_mirror}  Get global cell id of first cell
#    ${cells_to_mirror}  Create List  ${cells_to_mirror}
#    Start capturing interface mirroring logs  ${cells_to_mirror}  mirroring_time=10
#    ${path}  Collect interface mirroring logs
    Verify bip logs beamset 6  ${path}

5GC000534-D_002_UE_beamSet_SSPBCH_decoding
    Perform commissioning 5GC000534D
    ...                 actBeamforming=true
    ...                 basicBeamSet=beamSet_2_2
    ...                 leftEdgeAngle=60
    ...                 nrBtsBeamRefinementP2=false
    ...                 rightEdgeAngle=60
    ...                 numberOfTransmittedSsBlocks=4 beams
    ...                 chBw=100MHz
    ${alarms}=      get active alarms
    Check if no unexpected alarms       alarms_list=${alarms}
    Check dlChBw   100MHz
    Detach Ue   AT_BASED_UE_1
    Start L1L2 logs gathering
#    ${cells_to_mirror}  Get global cell id of first cell
#    ${cells_to_mirror}  Create List  ${cells_to_mirror}
#    Start capturing interface mirroring logs  ${cells_to_mirror}  mirroring_time=10
    Attach Ue   AT_BASED_UE_1
    ${path}  Stop L1L2 logs gathering and download pcap
#    ${path}  Collect interface mirroring logs
    Verify bip logs sspbch_checking   ${path}

[1]5GC000534-D_003_UE_beamSet_L3call_best_beam_beamset4
    Perform commissioning 5GC000534D
    ...                 actBeamforming=true
    ...                 basicBeamSet=beamSet_4
    ...                 leftEdgeAngle=60
    ...                 nrBtsBeamRefinementP2=false
    ...                 rightEdgeAngle=60
    ...                 numberOfTransmittedSsBlocks=4 beams
    ...                 chBw=100MHz
    ${alarms}=      get active alarms
    Check if no unexpected alarms       alarms_list=${alarms}
    Check dlChBw   100MHz
    Detach Ue   AT_BASED_UE_1
    Start tcpdump on gnb ASIK master
    sleep  10s
    Attach Ue   AT_BASED_UE_1
    sleep  5s
#    ${path}   Stop pcap collection in gNB ASIK master
#    Verify SgNB addition    ${path}
    Detach Ue   AT_BASED_UE_1
    Start L1L2 logs gathering  time=10
#    ${cells_to_mirror}  Get global cell id of first cell
#    ${cells_to_mirror}  Create List  ${cells_to_mirror}
#    Start capturing interface mirroring logs  ${cells_to_mirror}  mirroring_time=10
    Attach Ue   AT_BASED_UE_1
    Start ULDL2  ue_alias=AT_BASED_UE_1
    ...          tput_duration=10s
    ...          tput_DL_bandwidth=1350 Mbits/sec
    ...          tput_UL_bandwidth=1350 Mbits/sec
    ...          packet_size=1400
    ...          protocol=udp
    Await Data Transfer Finish                 DT_UL
    Await Data Transfer Finish                 DT_DL
    sleep   10s
    ${path_1}  Stop L1L2 logs gathering and download pcap
#    ${path_1}  Collect interface mirroring logs
    Verify bip logs beamset_4_l3call_best_beam_check and l3call_best_beam_check   ${path_1}

[1]5GC000534-D_003_UE_beamSet_L3call_best_beam_beamset6
    Perform commissioning 5GC000534D
    ...                 actBeamforming=true
    ...                 basicBeamSet=beamSet_6
    ...                 leftEdgeAngle=60
    ...                 nrBtsBeamRefinementP2=false
    ...                 rightEdgeAngle=60
    ...                 numberOfTransmittedSsBlocks=6 beams
    ...                 chBw=100MHz
    ${alarms}=      get active alarms
    Check if no unexpected alarms       alarms_list=${alarms}
    Check dlChBw   100MHz
    Detach Ue   AT_BASED_UE_1
    Start tcpdump on gnb ASIK master
    sleep  10s
    Attach Ue   AT_BASED_UE_1
    sleep  5s
#    ${path}   Stop pcap collection in gNB ASIK master
#    Verify SgNB addition    ${path}
    Detach Ue   AT_BASED_UE_1
    Start L1L2 logs gathering
#    ${cells_to_mirror}  Get global cell id of first cell
#    ${cells_to_mirror}  Create List  ${cells_to_mirror}
#    Start capturing interface mirroring logs  ${cells_to_mirror}  mirroring_time=10
    Attach Ue   AT_BASED_UE_1
    Start ULDL2  ue_alias=AT_BASED_UE_1
    ...          tput_duration=10s
    ...          tput_DL_bandwidth=1350 Mbits/sec
    ...          tput_UL_bandwidth=1350 Mbits/sec
    ...          packet_size=1400
    ...          protocol=udp
    Await Data Transfer Finish                 DT_UL
    Await Data Transfer Finish                 DT_DL
    sleep   10s
    ${path_1}  Stop L1L2 logs gathering and download pcap
#    ${path_1}  Collect interface mirroring logs
    Verify bip logs beamset_6_l3call_best_beam_check and l3call_best_beam_check   ${path_1}
