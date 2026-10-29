*** Settings ***
Documentation
...  author: Karol Palac
...  contact: karol.palac@nokia.com
...  Description: This feature introduces Carrier Aggregation between FDD carrier as PCell and up to 2 SCells,
...               FR1 TDD or FDD carriers.

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/keywords_5GC002640-H.robot

*** Variables ***
${resource_path_2640-H}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources

*** Keywords ***
[1][1.0] 5GC002640-H_32_#B2 SCell change based on A1-PCell measurement for SA UE from 3CC F+F+F CA to 3CC F+T+T CA
    [Documentation]  This sub feature is for F+T+T configuration with enabled beamforing, 15MHz PCell, 1x50MHz + 1x20MHz Scells.
    ...              Veryfing CA Scells addition, CSI-RS for Channel Acquistion, CQI measurements, PM counters, DT ULDL.
    Set test variable  ${test_name}  5GC002640-H_32
    Set SCells start attenuation H32
    Set PCell start attenuation
    Setup attenuators for T186
    Sleep  10s
    Start syslog collection
    Attach UE  UE_1
    Log to console  >Attach<
    Start New L1L2 Logs
    Sleep   5s
    Log to console  L1L2 logs started succesfully
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_1    direction=dl    duration=200s    throughput=110Mbits/sec
    ...                    protocol=udp
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_1    direction=ul    duration=200s    throughput=45Mbits/sec
    ...                    protocol=udp
    Conditions on SCell2 deteriorate H32
    Get Average Throughput         DT_UL_SA
    Get Average Throughput         DT_DL_SA
    Sleep  30s
    Log to console  >SCell2 became inactive<
    Attenuate SCell2
    Get Average Throughput         DT_UL_SA
    Get Average Throughput         DT_DL_SA
    Await Data Transfer Finish   DT_UL_SA
    Verify Average Throughput    DT_DL_SA    tput_min=30Mbits/sec    omit=20
    Verify Average Throughput    DT_UL_SA    tput_min=16Mbits/sec    omit=20
    Verify Average Throughput    DT_DL_SA    tput_min=35Mbits/sec    omit=100
    Verify Average Throughput    DT_UL_SA    tput_min=18Mbits/sec    omit=100
    Stop New L1L2 Logs And Download PCAP
    Stop syslog collection
    Verify DT DL Flows through all cells
    Verify DT UL Flows through FDD Pcell
    Log to Console    >Traffic flows through cells as expected.<

[1]5GC002640-H_30_#B1.1 SCell change based on A1-PCell measurement for SA UE from 3CC F+T+T CA with FDD PCell to 2CC F+F CA
    [Documentation]  This sub feature is for F+F+T configuration with enabled beamforing. PCell 304 + Scells 145 and 311.
    Set test variable  ${test_name}  5GC002640-H_30
    Set PCell start attenuation
    Sleep  10s
    Attach UE  UE_1
    Log to console  >Attach<
    Sleep   5s
    Set SCells start attenuation H30
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_1    direction=dl    duration=120s    throughput=1000Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_1    direction=ul    duration=120s    throughput=45Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Sleep    30s
    Conditions on SCell2 deteriorate H30
    Sleep  10s
    Log to console  >Scell has been attenuated<
    Attenuate SCell2 H30
    Log to console  Attenuate SCell2 H30 done
    Run keyword and ignore error    Stop Data Transfer           DT_DL_SA
    Run keyword and ignore error    Stop Data Transfer           DT_UL_SA
    Log to console  Data transfer stopped
    Log to Console    >Traffic flows through cells as expected.<
    Verify PM Counters 2640-H
