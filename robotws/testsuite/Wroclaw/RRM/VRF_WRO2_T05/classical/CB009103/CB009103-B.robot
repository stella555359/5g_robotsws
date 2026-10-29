*** Settings ***
Documentation
...  author: Karol Palac
...  contact: karol.palac@nokia.com

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009103/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008140/resources/keywords.robot
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/keywords_2640.py
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009103/resources/keywords.py

*** Variables ***
${resource_path_delta-9103-B}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/config
${resource_path_9103-B}   testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009103/resources
${labpcip}=               10.44.72.183

*** Keywords ***
[1]CB009103-B_PMO_B1_Counter_update_for_stepwise_ext-SCell_add_failure_A1_and_A4_with_configured_intra-SCells
    [Documentation]  This user scenario describes failure handling in execution phase of ext-CU during stepwise
    ...              ext-SCell addition procedure. PCell PCI: 304, SCells PCI: 145, 60 (SUCCESS) and 163 (FAILED A4).
#    Load scf for second NR    ${resource_path_8140-FA}    SCFs    scf_8140-FA-external.xml
#    Add flags to sw config CB009103-B t186
    Add flags to sw config CB009103-B t410
    Wait until keyword succeeds    15 min    30s    Verify all cells are onair with admin
    ${stream_name}    Get stream name
    ${stream_name}=   Set Variable If  '${stream_name}' == 'TRUNK'  default    ${stream_name}
    coam.perform_delta_recommissioning
    ...    delta_file=${resource_path_delta-9103-B}/${stream_name}/delta_9103-B_mainGNB.json    connection=cOAM
    Wait until keyword succeeds    15 min    30s    Verify all cells are onair with admin
    Setup attenuators for T186
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=10
    Set test variable  ${test_name}  CB009103-B
    Prepare and start new DCAP   bts_mplane=10.44.137.51   nrCells=NRCELL_R-1
    Attach UE    UE_1
    Sleep  5s
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_1    direction=dl    duration=300s    throughput=1500Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_1    direction=ul    duration=300s    throughput=100Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Sleep     10s
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}   value=0
    Set initial attenuation for 8140-CD
    Sleep     45s
    Run keyword and ignore error    Stop Data Transfer           DT_UL_SA
    Run keyword and ignore error    Stop Data Transfer           DT_DL_SA
    Stop new DCAP trace and download logs json    subdir=${test_name}
    Verify JSON file from DCAP  expected_messages=${messages_9103_B}
    Verify PM Counters 9103-B Prime GNB
    Verify PM Counters 9103-B External GNB
    Log to Console    >PM Counters gotten successfully.<
    [Teardown]    delta.roll_delta_back    initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...           delta_scf_filename=delta_9103-B_mainGNB.json
