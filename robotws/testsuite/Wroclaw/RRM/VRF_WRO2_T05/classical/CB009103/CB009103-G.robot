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
${path_delta_9103-G}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/config
${resource_path_9103-G}   testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009103/resources
${labpcip}=               10.44.72.183

*** Keywords ***
[1]USCB009103-G_B4_6CC_CA_is_supported_with_mixed_intra-SCell(s)_and_ext-SCell(s)
    [Documentation]  This user scenario verifies the case that step-wise SCell addition can be finally result in UE
    ...    configured with 6CC CA and with the combination of intra-SCell and ext-SCell.
    Load scf for second NR    ${resource_path_9103-G}    SCFs    scf_9103-G-external.xml
    Wait until keyword succeeds    15 min    30s    Verify all cells are onair with admin
    ${stream_name}    Get stream name
    ${stream_name}=   Set Variable If  '${stream_name}' == 'TRUNK'  default    ${stream_name}
    coam.perform_delta_recommissioning    delta_file=${path_delta_9103-G}/${stream_name}/delta_9103-G_mainGNB.json
    ...    connection=cOAM
    Wait until keyword succeeds    15 min    30s    Verify all cells are onair with admin
    Setup attenuators for T186
    Set attenuation and check    lines=${lines_gNB_410_AHLOA_1_FDD}   value=0
    Set test variable  ${test_name}  CB009103-G
    Prepare and start new DCAP   bts_mplane=10.44.137.51   nrCells=NRCELL_R-1
    Attach UE    UE_4
    Sleep  5s
    Set initial attenuation for 9103-G
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_4    direction=dl    duration=500s    throughput=1500Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_4    direction=ul    duration=500s    throughput=100Mbits/sec
    ...                    protocol=udp    packet_size=1400
    Sleep  20s
    ${DL_tput}         Get Average Throughput       DT_DL_SA
    Log to Console     DL Throughput: ${DL_tput}
    ${UL_tput}         Get Average Throughput       DT_UL_SA
    Log to Console     UL Throughput: ${UL_tput}
    Stop new DCAP trace and download logs json    subdir=${test_name}
    Run keyword and ignore error    Stop Data Transfer     DT_UL_SA
    Run keyword and ignore error    Stop Data Transfer     DT_DL_SA
    Detach UE    UE_4
    Verify JSON file from DCAP  expected_messages=${messages_9103_G}
    Verify PM Counters 9103-G
    Log to Console    >PM Counters gotten successfully.<
    [Teardown]    Run keyword
    ...    delta.roll_delta_back    initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...    delta_scf_filename=delta_9103-G_mainGNB.json
