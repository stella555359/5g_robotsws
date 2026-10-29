*** Settings ***
Resource     ../resources/common_keywords.robot
Resource     ../resources/common_keywords_vran.robot
Resource     ../resources/common_variables.robot
Resource     ../resources/common_configuration.robot
Variables     ../resources/common_variables_vran.py
Library     ../resources/common_keywords.py
Library     ../resources/common_keywords_vran.py
Library    taf.collectors.snapshot    WITH NAME    snapshot
Library    taf.collectors.dcap    WITH NAME    dcap

Documentation
...    author: Łukasz Filipek
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    testline: CLOUD_5G_I_LO_AP_LO
...    release: 24R3

Test Setup    Run Keywords    Configure SA VM interfaces AiC
...   AND   Enable AiC DCAP Params
...   AND   Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
...   AND   Set Internal Traffic Type To UEs

Test Teardown    Run Keywords    Stop Default Processes And Gather Logs And Compress Logs
    ...       AND    Send Configuration ID To Scout

*** Variables ***
${TRAFFIC_DURATION_SEC}=   120s
${vcu_snapshot_path}=    ${OUTPUT DIR}/CNI-106544-CR/CNI-106544-CR/coam_cu_snapshot/
${vdu_snapshot_path}=    ${OUTPUT DIR}/CNI-106544-CR/CNI-106544-CR/coam_vdu_snapshot/
${vcu_snapshot_file_list_path}=    ${OUTPUT DIR}/CNI-106544-CR/CNI-106544-CR/coam_cu_snapshot/snapshot/snapshot_file_list.txt
${vdu_snapshot_file_list_path}=    ${OUTPUT DIR}/CNI-106544-CR/CNI-106544-CR/coam_vdu_snapshot/snapshot/snapshot_file_list.txt
${file1}=    L2TraceHi_CU
${file2}=    L2TraceHi_DU

*** Test Cases ***
CNI-106544-CR
    Register Ue With Default Pdu Session
    Start 10Mbps Ul And Dl Data Traffic
    Collect U-plane Traces
    Check Data Traffic
    Deregister Ue   ue_id=1
    Stop Collect U-plane Traces
    Collect_vCU_Snapshot
    Collect_vDU_Snapshot
    Extract Snapshot And Verify L2 Component Trace Presence

*** Keywords ***
Start 10Mbps Ul And Dl Data Traffic
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=10
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=ul mbps=10

Check Data Traffic
    Display Qfi stats    qfi_id=1
    Execute Egate Command And Wait For Data    cmd=uec_stats display type=cell_data_pdcp enb=2 cell=1 format=long
     Expected Throughput For Qfi Should Be Reached    ue_id=1    pdu_id=1    qfi_id=1
     ...    expected_throughput=10    unit=mbps    margin=0.2    direction=bi
     Check Number Of Total Packets Lost    ue_id=1    pdu_id=1    qfi_id=1    packet_loss=0
     ...    margin=0.2    direction=bi

Collect_vCU_Snapshot
    ${webservice}=  Create Dictionary
    ...  host=192.168.100.129
    ...  user=Nemuadmin
    ...  password=Nokia@123
    ...  port=443
    ...  secure=True
    ...  login_disabled=False
    snapshot.create_coam_cu_snapshot_collector
    ...  name=coam_cu_snapshot
    ...  webservice=${webservice}
    ...  request_timeout=60.0
    ...  operation_timeout=600.0
    snapshot.setup_collectors
    ...  names=coam_cu_snapshot
    snapshot.collect_collectors
    ...  names=coam_cu_snapshot
    snapshot.teardown_collectors
    ...  names=coam_cu_snapshot

Collect_vDU_Snapshot
    ${webservice}=  Create Dictionary
    ...  host=192.168.255.129
    ...  user=Nemuadmin
    ...  password=Nokia@123
    ...  secure=True
    ...  login_disabled=False
    snapshot.create_coam_vdu_snapshot_collector
    ...  name=coam_vdu_snapshot
    ...  webservice=${webservice}
    ...  request_timeout=60.0
    ...  operation_timeout=600.0
    snapshot.setup_collectors       names=coam_vdu_snapshot
    snapshot.collect_collectors     names=coam_vdu_snapshot
    snapshot.teardown_collectors    names=coam_vdu_snapshot

Extract Snapshot And Verify L2 Component Trace Presence
    Extract Snapshot    snapshot_dir=${vcu_snapshot_path}
    Extract Snapshot    snapshot_dir=${vdu_snapshot_path}
    Find File In Snapshot    snapshot_file_list_path=${vcu_snapshot_file_list_path}    file_to_find=${file1}
    Find File In Snapshot    snapshot_file_list_path=${vdu_snapshot_file_list_path}    file_to_find=${file2}

