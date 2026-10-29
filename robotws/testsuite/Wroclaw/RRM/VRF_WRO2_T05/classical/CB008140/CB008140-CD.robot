*** Settings ***
Documentation
...  author: Karol Palac
...  contact: karol.palac@nokia.com
...  Description: This feature introduces Carrier Aggregation between FDD carrier as PCell and up to 3 SCells,
...               FR1 TDD or FDD carriers.

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/resources/logs.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/kw_2640.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001390/resources/kw_1390.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/dcap/dcap.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources/keywords.robot
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/keywords_2640.py

*** Variables ***
${resource_path_8140-CD}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/config
${labpcip}=                 10.44.72.183
${tes_emil}=                ${CURDIR}/resources/2640_emil.robot

*** Keywords ***
[1]CB008140-CD#B1A1_[F+F+T+T]_Event_A2_measurement_based_triggered_inter-gNB_CA_Partial_SCell_release_SA_4CC_CA
    [Documentation]  This user scenario describes the gNB behaviour, when a UE for which FDD-TDD carrier aggregation
    ...              has been configured (4CC CA) moves towards the cell edge and as the SCell degrades UE sends
    ...              measurement report for A2 (associated with external SCell) to trigger inter-gNB CA SCell release.
    ...              PCell: FDD PCI 101, SCells: TDD PCI 163,263 and FDD PCI 60.
    Prepare and check neightbour TL  7_16_UTE5GCLOUDT186
    ...    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources  SCFs/7-16-UTE5GCLOUD410  scf_8140-CD-external.xml
#     Load scf for second NR    ${resource_path_8140-CD}    SCFs    scf_8140-CD-external.xml
    ${stream_name}    Get stream name
    ${stream_name}=   Set Variable If  '${stream_name}' == 'TRUNK'  default    ${stream_name}
    Wait until keyword succeeds    15 min    30s    Verify all cells are onair with admin
    coam.perform_delta_recommissioning    delta_file=${resource_path_8140-CD}/${stream_name}/delta_8140-CD-mainGNB.json
    ...    connection=cOAM
	Wait until keyword succeeds    15 min    30s    Verify all cells are onair with admin
    Setup attenuators for T186
    Set initial attenuation for 8140-CD
    Set test variable  ${test_name}  CB008140-CD
    Prepare and start new DCAP   bts_mplane=10.44.137.51   nrCells=NRCELL_R-1
    Attach UE    UE_1
    Sleep  5s
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_1    direction=dl    duration=300s    throughput=1400Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_1    direction=ul    duration=300s    throughput=100Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Sleep    15s
    Perform SCell Release for 8140-CD
    Sleep    15s
    Stop new DCAP trace and download logs json    subdir=${test_name}
    Start New L1L2 Logs
    Sleep    5s
    Run keyword and ignore error    Stop Data Transfer           DT_DL_SA
#    Get Average Throughput       DT_DL_SA
    Run keyword and ignore error    Stop Data Transfer           DT_UL_SA
#    Get Average Throughput       DT_UL_SA
    Stop New L1L2 Logs And Download PCAP
    Verify CSI-RS for Channel Acquisition
    Log to Console    >CSI-RS Chanel Acquisition successful.<
    Verify PM Counters 8140-CD
    Log to Console    >PM Counters gotten successfully.<
    Verify JSON file from DCAP  expected_messages=${messages_8140}
#    [Teardown]    delta.roll_delta_back    initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
#    ...           delta_scf_filename=delta_8140-CD-mainGNB.json
