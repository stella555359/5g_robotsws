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
${resource_path_delta-9103-E}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/config
${resource_path_9103-E}   testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB009103/resources
${labpcip}=               10.44.72.183

*** Keywords ***
[1]CB009103_E_B4_Deactivate_Ext_SCell_Directly_If_Very_Large_Delay_Is_Detected_No_Impact_On_DL_UL_SCell
    [Documentation]  This user scenario intends to validate that: in case very large delay is detected, ext-SCell
    ...    would be deactivated directly without suspending UL scheduling in DL&UL SCell first even if
    ...    data rate is preferred over UL CA.
#    Load scf for second NR    ${resource_path_8140-FA}    SCFs    scf_8140-FA-external.xml
    Wait until keyword succeeds    15 min    30s    Verify all cells are onair with admin
    ${stream_name}    Get stream name
    ${stream_name}=   Set Variable If  '${stream_name}' == 'TRUNK'  default    ${stream_name}
    coam.perform_delta_recommissioning
    ...    delta_file=${resource_path_delta-9103-E}/${stream_name}/delta_9103-E_mainGNB.json    connection=cOAM
    Wait until keyword succeeds    15 min    30s    Verify all cells are onair with admin
    Setup attenuators for T186
    Set initial attenuation for 9103-E
    Set test variable  ${test_name}  CB009103-E
    Prepare and start new DCAP   bts_mplane=10.44.137.51   nrCells=NRCELL_R-301 NRCELL_R-21
    Attach UE    UE_4
    Sleep  5s
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_4    direction=dl    duration=500s    throughput=600Mbits/sec
    ...                    protocol=udp    packet_size=1320
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_4    direction=ul    duration=500s    throughput=200Mbits/sec
    ...                    protocol=udp    packet_size=1320
    Sleep  35s
    Prepare and start delay with RUDE tool
    Log to Console   Prepare and start delay with RUDE tool
    Sleep    20s
    Set delay on RUDE      delay_value=0
    Stop new DCAP trace and download logs json    subdir=${test_name}
    ${delay_on_DL}         Get Average Throughput       DT_DL_SA
    ${delay_on_UL}         Get Average Throughput       DT_UL_SA
    Log to Console         ${delay_on_DL}
    Log to Console         ${delay_on_UL}
    Sleep    10s
    Run keyword and ignore error    Stop Data Transfer     DT_UL_SA
    Run keyword and ignore error    Stop Data Transfer     DT_DL_SA
    Detach UE    UE_4
    Should be true         ${delay_on_UL}>=40000
    Should be true         ${delay_on_DL}>=200000
    Verify JSON file from DCAP  expected_messages=${messages_9103_E}
    Verify PM Counters 9103-E Prime GNB
    Verify PM Counters 9103-E External GNB
    Log to Console    >PM Counters gotten successfully.<
    [Teardown]    Run keywords
    ...    Run keyword and ignore error    Set delay on RUDE      delay_value=0    AND
    ...    delta.roll_delta_back    initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...    delta_scf_filename=delta_9103-E_mainGNB.json
