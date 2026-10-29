*** Settings ***
Documentation
...  author: Karol Palac
...  contact: karol.palac@nokia.com
...  Description: This user scenario describes successful call setup with FDD ? TDD FR1 4CC DL CA and DSS disabled.

Library         ute_ue
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/resources/logs.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/kw_2640.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008533/resources/kw_8533.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/resource/dcap/dcap.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001390/resources/kw_1390.robot
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/keywords_2640.py
Library         testsuite/Wroclaw/RRM/resources/logs.py

*** Variables ***
${resource_path_8533-C}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/config
${labpcip}=                10.44.72.183
${tput_deviation}          10%

*** Keywords ***
[1][1.0] CB008533-C#B2A Single UE Call - pCSI reporting configuration for 4CC 2F+ 2T DL CA with common PUCCH resource ID
    [Documentation]  This user scenario describes the configuration of PUCCH Format 3 (PF3) resources in the FDD PCell
    ...              to carry UCI data for each configured SCell, the main user scenario assumes FDD PCell + 2 TDD
    ...              SCells + 1 FDD SCells. Beamforming with Beam Refinement is activated on the TDD SCells.
    ...              PCell 1 + Scells 21, 301, 311.
    ${stream_name}    Get stream name
    ${stream_name}=   Set Variable If  '${stream_name}' == 'TRUNK'  default    ${stream_name}
    Wait until keyword succeeds    15 min    30s    Verify all cells are onair with admin
    coam.perform_delta_recommissioning    delta_file=${resource_path_8533-C}/${stream_name}/delta_8533-C.json
    ...    connection=cOAM
    Wait until keyword succeeds    15 min    30s    Verify all cells are onair with admin
    Change actHighestEstNrTputBcSel
    Setup attenuators for T186
    Set attenuation for 8533-AB5-1  # the same config as in subfeature A, not to double keywords
    Set test variable  ${test_name}  CB008533-CB2A
    Start syslog collection
    Attach UE    UE_1
    Sleep  5s
    Start New L1L2 Logs
    Sleep    10s
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_1    direction=dl    duration=400s    throughput=1600Mbits/sec
    ...                    protocol=tcp    packet_size=1300
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_1    direction=ul    duration=330s    throughput=100Mbits/sec
    ...                    protocol=tcp    packet_size=1300
    Sleep   25s
    Stop syslog collection
    Stop New L1L2 Logs And Download PCAP
    Run keyword and ignore error    Stop Data Transfer     DT_UL_SA
    Run keyword and ignore error    Stop Data Transfer     DT_DL_SA
    Run Keyword and Ignore Error
    ...  Verify Average Throughput    DT_DL_SA    tput_min=500Mbits/sec    omit=5
    Run Keyword and Ignore Error
    ...  Verify Average Throughput    DT_UL_SA    tput_min=40Mbits/sec    omit=5
    Verify registration to FDD PCell 8533
    Log to Console    >Registration to FDD PCell successful.<
    Verify CSI-RS for Channel Acquisition    cells=${subcells_8533_A}
    Log to Console    >CSI-RS Chanel Acquisition successful.<
    Verify PM Counters 8533-C
    Log to Console    >CQI Measurements detected successfully.<
    [Teardown]  Run keywords
    ...         Run keyword and ignore error    Stop syslog collection    AND
    ...         delta.roll_delta_back    initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...         delta_scf_filename=delta_8533-C.json

