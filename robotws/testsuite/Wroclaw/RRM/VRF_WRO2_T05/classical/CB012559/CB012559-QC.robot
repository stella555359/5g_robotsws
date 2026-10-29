*** Settings ***
Documentation
...  author: Karol palac
...  contact: karol.apalac@nokia.com


Library     ta5g_delta     WITH NAME  delta
Library     ta5g_enb       WITH NAME  initial
Resource    testsuite/Wroclaw/RRM/resources/logs.robot
Resource    testsuite/Wroclaw/RRM/resources/pm_counters/pm_counters.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008717/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB012559/resources/keywords.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB008533/resources/kw_8533.robot
Resource    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/common_keywords/common_keywords.robot
Variables   testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/CB012559/resources/keywords.py


*** Variables ***
${resource_path_12559}    testsuite/Wroclaw/RRM/VRF_WRO2_T05/classical/regression/config


*** Keywords ***
[1]CB012559-QC_05_TF_A1ScellAddition_BufferScellActivation_A2ScellRealese
    [Documentation]    The purpose of this test case is to verify support of intra-band TDD FR1 CA feature activation
    ...                 when gNB cells are configured in SA (PCell 304, SCells 16, 145, 415, 415).
    Set test variable  ${test_name}  CB012559-QC
    Setup attenuators
    Setup attenuators for T186
    ${stream_name}    Get stream name
    ${stream_name}=   Set Variable If  '${stream_name}' == 'TRUNK'  default    ${stream_name}
    Wait until keyword succeeds    15 min    30s    Verify all cells are onair with admin
    coam.perform_delta_recommissioning    delta_file=${resource_path_8533-C}/${stream_name}/delta_12559-QC.json
    ...    connection=cOAM
    Wait until keyword succeeds    15 min    30s    Verify all cells are onair with admin
    Set attenuation for 8533-AB5-1  # the same config as in subfeature A, not to double keywords
    Prepare and start new DCAP       dcap_host=10.44.180.37  bts_mplane=10.44.137.51    nrCells=NRCELL_R-1
    Attach Ue     UE_4
    Sleep         7s
    ${PCI_UE1}=       ute_ue.Get Ue Info    UE_4   PCI
    Log to Console    UE attached PCI: ${PCI_UE1}
    Sleep    5s
    Start Data Transfer    dt_name=DT_DL_SA    ue_alias=UE_4    direction=dl    duration=300s    throughput=2500Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Start Data Transfer    dt_name=DT_UL_SA    ue_alias=UE_4    direction=ul    duration=300s    throughput=100Mbits/sec
    ...                    protocol=udp    packet_size=1300
    Sleep    30s
    Release 2 Cells
    ${DL_tput}         Get Average Throughput       DT_DL_SA
    Log to Console     DL Throughput: ${DL_tput}
    ${UL_tput}         Get Average Throughput       DT_UL_SA
    Log to Console     UL Throughput: ${UL_tput}
    Sleep    10s
    Stop new DCAP trace and download logs json    subdir=${test_name}
    Run keyword and ignore error    Stop Data Transfer     DT_UL_SA
    Run keyword and ignore error    Stop Data Transfer     DT_DL_SA
    Verify JSON file from DCAP  expected_messages=${messages_12559_QC}
    Verify PM Counters 12559-QC
    [Teardown]  delta.roll_delta_back    initial_scf_filename=${OUTPUT_DIR}/initial_commissioning.xml
    ...         delta_scf_filename=delta_12559-QC.json
    ...         delta_directory=${resource_path_12559}/${stream_name}
