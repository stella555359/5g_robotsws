*** Settings ***
Documentation
...    author: Łukasz Filipek
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 24R3

*** Variables ***
${TRAFFIC_DURATION_SEC}=        60s
${file1}=                      L2TraceLo
${file2}=                      L2TraceHi_CU
${file3}=                      L2TraceHi_DU
${snapshot_dir}=               ${OUTPUT DIR}/CNI/[1][1.0] CNI-106544-SR/gnb_sbts_snapshot/
${snapshot_file_list_path}=    ${OUTPUT DIR}/CNI/[1][1.0] CNI-106544-SR/gnb_sbts_snapshot/snapshot/snapshot_file_list.txt

*** Keywords ***
CNI-106544-SR
    Register Ue With Default Pdu Session
    Start 50 Mbps Dl And 20 Mbps Ul Data Traffic
    Check Dl And Ul Data Traffic
    Collect L2Hi and L2Lo Component Traces
    Deregister Ue    ue_id=1
    Collect Snapshot
    Extract Snapshot And Verify L2 Component Trace Presence

Start 50 Mbps Dl And 20 Mbps Ul Data Traffic
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=50
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=20
    Sleep    ${TRAFFIC_DURATION_SEC}

Display Ue Statistics
    Display Qfi stats    qfi_id=1
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long

Check Dl And Ul Data Traffic
    Display Ue Statistics
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=1
    ...    expected_throughput=50    unit=mbps    margin=0.2    direction=dl
    Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=1
    ...    expected_throughput=20    unit=mbps    margin=0.2    direction=ul
    Check Number Of Total Packets Lost    ue_id=1    pdu_id=1    qfi_id=1    packet_loss=0
    ...    margin=0.0    direction=bi

Extract Snapshot And Verify L2 Component Trace Presence
    Extract Snapshot    snapshot_dir=${snapshot_dir}
    Find File In Snapshot    snapshot_file_list_path=${snapshot_file_list_path}    file_to_find=${file1}
    Find File In Snapshot    snapshot_file_list_path=${snapshot_file_list_path}    file_to_find=${file2}
    Find File In Snapshot    snapshot_file_list_path=${snapshot_file_list_path}    file_to_find=${file3}
