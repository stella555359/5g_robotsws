*** Settings ***
Documentation
...  author: Karol Palac
...  contact: karol.palac@nokia.com
...  Description: This user scenario describes successful call setup with FDD ? TDD FR1 4CC DL CA and DSS enabled
...  in FDD PCell.

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC000900/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/resources/logs.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/kw_2640.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008533/resources/kw_8533.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC001390/resources/kw_1390.robot
Variables       testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/5GC002640/resources/keywords_2640.py
Library         testsuite/Wroclaw/RRM/resources/logs.py

*** Variables ***
${resource_path_8533-A}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/config
${labpcip}=                 10.44.72.183
${tput_deviation}           10%

*** Keywords ***
[1][6]_CB008533-A#B5-1_Single_UE_FDD_+_FR1_TDD_4CC_DL_CA_2F+2T_interworking_with_DSS_PCell_(with_DSS)+FDD_SCell_(non_DSS)+TDD_SCell+TDD_SCell
    [Documentation]  This sub feature is for 2F+2T configuration with enabled beamforing. Veryfing CA Scells addition, CSI reports on
    ...              Pucch (Format 3), Harq feedbacks, DT ULDL. PCell 1, Scells 21, 301, 311.
    ${stream_name}    Get stream name
    ${stream_name}=   Set Variable If  '${stream_name}' == 'TRUNK'  default    ${stream_name}
    coam.perform_delta_recommissioning    delta_file=${resource_path_8533-A}/${stream_name}/delta_8533-AB5-1.json
    ...    connection=cOAM
    Wait until keyword succeeds    15 min    30s    Verify all cells are onair with admin
    Setup attenuators for T186
    Setup attenuators
    Set attenuation for 8533-AB5-1
    Set test variable  ${test_name}  CB008533-AB5-1
    Wait until keyword succeeds    7 min    30s    Attach UE    UE_1
    Sleep  5s
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_1    direction=dl    duration=200s    throughput=1200Mbits/sec
    ...                    protocol=tcp    packet_size=1300
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_1    direction=ul    duration=200s    throughput=100Mbits/sec
    ...                    protocol=tcp    packet_size=1300
    Set attenuation and check    lines=${lines_gNB_410_AHFIB_8_FDD}   value=0
    Start New L1L2 Logs
    Sleep   10s
    Run Keyword and Ignore Error
    ...  Verify Average Throughput    DT_DL_SA    tput_min=300Mbits/sec    omit=10
    Run Keyword and Ignore Error
    ...  Verify Average Throughput    DT_UL_SA    tput_min=40Mbits/sec    omit=10
    Run Keyword and Ignore Error    Await Data Transfer Finish   DT_DL_SA
    Stop New L1L2 Logs And Download PCAP
    Verify Harq feedbacks are transmitted on Pucch or Pusch
    Log to Console    >Harq feedbacks detected successfully.<
    Verify PM Counters 8533-AB5-1
    [Teardown]    delta.roll_delta_back    initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...           delta_scf_filename=delta_8533-AB5-1.json

[1][16]_CB008533-A#_B11-1_Single_UE_Call_A1-PCell_Measurement_based_SCell_Addition_mobility_interfrequency_HO_from_2CC_to_3CC_to_4CC_to_2CC_CA
    [Documentation]  This scenario describes successful hand over from 2CC to 3CC to 4CC to 2CC CA. UE attach
    ...    to 2CC CA (FDD- TDD) hand over to another cell resulting in 3CC CA (FDD-TDD-TDD) and hand over to another
    ...    cell resulting in 4CC CA (FDD-FDD-TDD-TDD) and hand over to cell resulting in 2CC CA (FDD - TDD).
    Load scf for NR    ${resource_path_8533-A}    SCFs    scf_8533-noDSS.xml
    Setup attenuators
    Set attenuation for 8533-AB11-1
    Set test variable  ${test_name}  CB008533-AB11-1
    Start syslog collection
    Attach UE    UE_1
    Sleep  5s
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_1    direction=dl    duration=300s    throughput=1600Mbits/sec
    ...                    protocol=tcp
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_1    direction=ul    duration=300s    throughput=100Mbits/sec
    ...                    protocol=tcp
    Start New L1L2 Logs
    Sleep   10s
    Perform inter-frequency handover for 3CC CA
    Perform inter-frequency handover for 4CC CA
    Perform FDD and TDD SCells Release for 2CC CA
    Stop syslog collection
    Stop New L1L2 Logs And Download PCAP
    Run Keyword and Ignore Error
    ...  Verify Average Throughput    DT_DL_SA    tput_min=600Mbits/sec    omit=20
    Run Keyword and Ignore Error
    ...  Verify Average Throughput    DT_UL_SA    tput_min=40Mbits/sec    omit=20
    Await Data Transfer Finish   DT_DL_SA
#    Await Data Transfer Finish   DT_UL_SA
    Verify registration to FDD PCell
    Log to Console    >Registration to FDD PCell successful.<
    Verify TDD SCell activation
    Log to Console    >Activation of TDD SCell successful.<
    Verify PM Counters 8533-A
    Verify DT DL Flows through all cells    cells=${subcells_8533_A}
    Verify DT UL Flows through FDD Pcell
    Log to Console    >Traffic flows through cells as expected.<

[1]CB008533-A#_B11-1x_Single_UE_Call_A1-PCell_Measurement_based_SCell_Addition_mobility_interGNB_HO_via_Xn_link
    [Documentation]  This scenario describes interFrequency HO via Xn link with carrier aggregation enabled.Scenario
    ...              focuses on moblity between different gNBs configured in different frequency with A1 Scell
    ...              addition and Scell release.
    Prepare and check neightbour TL  7_16_UTE5GCLOUDT186
    ...    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008533/resources  SCFs/7-16-UTE5GCLOUD410  scf_8533-secondGNB.xml
    ${stream_name}    Get stream name
    ${stream_name}=   Set Variable If  '${stream_name}' == 'TRUNK'  default    ${stream_name}
    Wait until keyword succeeds    15 min    30s    Verify all cells are onair with admin
    coam.perform_delta_recommissioning
    ...    delta_file=${resource_path_8533-A}/${stream_name}/delta_8533-AB11-1x-mainGNB.json    connection=cOAM
	Wait until keyword succeeds    15 min    30s    Verify all cells are onair with admin
    Setup attenuators
    Setup attenuators for T186
    Set initial attenuation for interGNB handover 186
    Log to console  ATTACH CHECK
    Attach UE    UE_1
    Sleep  10s
    Set test variable  ${test_name}  CB008533-AB11-1x
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_1    direction=dl    duration=400s    throughput=1400Mbits/sec
    ...                    protocol=tcp    packet_size=1300
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_1    direction=ul    duration=400s    throughput=50Mbits/sec
    ...                    protocol=tcp    packet_size=1300
    Perform handover from 2CC T186 to 3CC T410
    Sleep   15s
    Perform inter-frequency handover for 4CC CA    #3CC->4CC on the same gNB
    Sleep   15s
    Perform handover from 4CC T410 to 2CC T186
    Sleep   15s
    Perform handover from 2CC T186 to 4CC T410
    Sleep   15s
    Run keyword and ignore error    Stop Data Transfer     DT_UL_SA
    Run keyword and ignore error    Stop Data Transfer     DT_DL_SA
    Verify PM Counters 8533-C   cell=1
    Verify PM Counters 2CC
    [Teardown]    delta.roll_delta_back    initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...           delta_scf_filename=delta_8533-AB11-1x-mainGNB.json
