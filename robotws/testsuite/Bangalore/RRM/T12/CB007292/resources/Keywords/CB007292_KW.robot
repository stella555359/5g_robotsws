*** Settings ***
Documentation     :copyright: Nokia
...             :author   : Bhakti Kapatel
...             :contact  : bhakti.ka_patel@nokia.com
...             This is feature specific keywords and verification.
Library         traffic_varification.py
Library         ta5g_pm_counters
Resource       ${CURDIR}/../../../resources/Keywords/HO_KW.robot
Resource       ${CURDIR}/../../../resources/Keywords/generic_kw.robot
Resource       ${CURDIR}/../../../resources/Keywords/gnb_Keywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/tsharkPcapVerifyKeywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/ute_wts_runner.robot
Resource       ${CURDIR}/../../../resources/Keywords/ap_Keywords.robot
Resource       ${CURDIR}/../../../resources/Keywords/common_keywords.robot


*** Variables ***
${AP_CONFIG_BASIC}     ${CURDIR}/../../config/wts
${scf}                 ${CURDIR}/../../config/scf/
${pdu_5qi}        ngap.pDUSessionID == 1 && ngap.fiveQI ==1
${pdu2_5qi}       ngap.pDUSessionID == 2 && ngap.fiveQI ==1
${arp}            ngap.priorityLevelARP
${qosflowdel}     ngap.QosFlowListWithCause == 1
${qos}            ngap.qosFlowIdentifier
${modified_pdu_add}        modified_pdu_add
${modified_pdu_delete}     modified_pdu_delete
${UE1}      1
${UE2}      2
${UE3}      3
${CELL1}    1
${ENB2}     2
${ENB3}     3
${QFI1}     1
${QFI2}     2
${QFI3}     3
${Pdu_session_ID2}    2
${GW2}    2
${GW3}    3
${pdu_unsuccessful}    Deleted Unsuccessful QosFlow
${Pdu_session_ID3}      3
${pdml_file}     /home/ute/logs/converted_PCAP.pdml
${SIB1}    SystemInformationBlockType1-NR updated
${SIB2}     eNB 3 cell 1: SystemInformationBlockType2-NR updated
${SIB5}     eNB 3 cell 1: SystemInformationBlockType5-NR updated
${location}    location
${timeout}      150
${pdu_session_modify}     Added QosFlow with QFI
${pdu_setup}    setup/reestablishment complete
${pdu_session_modify_delete}       Removed FiveQi
${VLAN_ID}        ${tl.gnbs[0].cu.x2c.vlan_id}
${MRBTS_DISTNAME}         MRBTS-1
${vlanif_distname}         ${MRBTS_DISTNAME}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1


*** Keywords ***
Suite Setup for 7292
    Updated Suite Setup
    Backup Scf    /home/ute/Downloads    Backup
    Update BSR Package For RJIO

Prepare for CB007292_B1_TC04
    [Documentation]    This keyword loads all required configurations like scf, cfg.
    ${Test_CaseNumber}=     Set Variable    CB007292_B_B1_TC4
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Link SCOUT SCF to Configuration ID for Reporting
    Create Basic Interface on UTE
    GNB Delta Commission    ${scf}/Delta_B_B1_TC04.json
    sleep   120s
    Wait Coam Site to be Ready
    Start UTE WTS     RJIO_B1_TC04.cfg
    NG Link Should Be UP
    Sleep    60s
    wtsrunner.sim_log_set
    set global variable    ${Log_Path}

Teardown for CB007292_B1_TC04
    GNB Delta Commission    ${scf}/Delta_B_B1_TC04_Rev.json
    sleep   60s
    RAT Block Unblock
    Wait Coam Site to be Ready

Prepare for CB007292_B_B5_TC16
    [Documentation]    This keyword loads all required configurations like scf, cfg.
    ${Test_CaseNumber}=     Set Variable    CB007292_B_B5_TC16
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Link SCOUT SCF to Configuration ID for Reporting
    Create Basic Interface on UTE
    GNB Delta Commission    ${scf}/Delta_B_B5_TC16.json
    sleep   30s
    Wait Coam Site to be Ready
    Start UTE WTS    RJIO_TC16.cfg
    NG Link Should Be UP
    Sleep    60s
    wtsrunner.sim_log_set
    set global variable    ${Log_Path}

Teardown for CB007292_B_B5_TC16
    GNB Delta Commission    ${scf}/Delta_B_B5_TC16_Rev.json
    Wait Coam Site to be Ready
    RAT Block Unblock


Prepare for CB007292_B_B2_TC08
    [Documentation]    This keyword loads all required configurations like scf, cfg.
    ${Test_CaseNumber}     Set Variable    CB007292_B_B2_TC08
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Link SCOUT SCF to Configuration ID for Reporting
    set global variable    ${Log_Path}
    Create Basic Interface on UTE
    GNB Delta Commission     ${scf}/Delta_B_B2_TC8.json
    sleep   120s
    Wait Coam Site to be Ready
    Start UTE WTS     RJIO_B1_TC04.cfg
    NG Link Should Be UP
    Sleep    60s

Teardown for CB007292_B_B2_TC08
    GNB Delta Commission    ${scf}/Delta_B_B2_TC8_Rev.json
    Wait Coam Site to be Ready
    RAT Block Unblock

Prepare for CB007292_B_B3_TC12
    ${Test_CaseNumber}     Set Variable    CB007292_B_B3_TC12
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Link SCOUT SCF to Configuration ID for Reporting
    set global variable    ${Log_Path}
    Create Basic Interface on UTE
    GNB Delta Commission    ${scf}/Delta_B_B3_TC12.json
    sleep   120s
    Wait Coam Site to be Ready
    Start UTE WTS     RJIO_B1_TC04.cfg
    NG Link Should Be UP
    Sleep    60s

Teardown for CB007292_B_B3_TC12
    Snapshot Collection     ${Log_Path}     Snapshot.zip
    Collect Logs For The Test       ${Log_Path}
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CB007292_B_B3_TC12.zip ${LOG_PATH}
    GNB Delta Commission    ${scf}/Delta_B_B3_TC12_Rev.json
    sleep   120s
    Wait Coam Site to be Ready
    RAT Block Unblock

Prepare for CB007292_B_B4_TC15
    ${Test_CaseNumber}     Set Variable    CB007292_B_B4_TC15
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Link SCOUT SCF to Configuration ID for Reporting
    set global variable    ${Log_Path}
    Create Basic Interface on UTE
    GNB Delta Commission    ${scf}/Delta_B_B4_TC15.json
    sleep   60s
    Wait Coam Site to be Ready
    Start UTE WTS     RJIO_B1_TC04.cfg
    NG Link Should Be UP
    Sleep    60s

Teardown for CB007292_B_B4_TC15
    Snapshot Collection     ${Log_Path}     Snapshot.zip
    Collect Logs For The Test       ${Log_Path}
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CB007292_B_B4_TC15.zip ${LOG_PATH}
    GNB Delta Commission    ${scf}/Delta_B_B4_TC15_Rev.json
    sleep   20s
    Wait Coam Site to be Ready
    RAT Block Unblock

Prepare for CB007292_B_EC1_TC44
    ${Test_CaseNumber}     Set Variable    CB007292_B_EC1_TC44
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    set global variable    ${Log_Path}
    Link SCOUT SCF to Configuration ID for Reporting
    Create Basic Interface on UTE
    GNB Delta Commission    ${scf}/Delta_B_EC1.json
    sleep   120s
    Wait Coam Site to be Ready
    Start UTE WTS     RJIO_B1_TC04.cfg
    NG Link Should Be UP
    Sleep    60s

Teardown for CB007292_B_EC1_TC44
    GNB Delta Commission    ${scf}/Delta_B_EC1_Rev.json
    Wait Coam Site to be Ready
    RAT Block Unblock

Prepare for CB007292_B_EC2_TC46
    ${Test_CaseNumber}     Set Variable    CB007292_B_EC2_TC46
    ${Log_Path}      Create Log Directory    ${Test_CaseNumber}
    Link SCOUT SCF to Configuration ID for Reporting
    set global variable    ${Log_Path}
    Create Basic Interface on UTE
    GNB Delta Commission    ${scf}/Delta_B_EC2.json
    sleep   30s
    Wait Coam Site to be Ready
    Start UTE WTS     RJIO_B1_TC04.cfg
    NG Link Should Be UP
    Sleep    60s

TearDown for CB007292_B_EC2_TC46
    Snapshot Collection     ${Log_Path}     Snapshot.zip
    Collect Logs For The Test       ${Log_Path}
    Copy Files      ${WTS_WORKING_DIR}/egate_console.log      ${LOG_PATH}
    Run     zip -r ${OUTPUTDIR}/CB007292_B_EC2_TC46.zip ${LOG_PATH}
    RAT Block Unblock
    Wait Coam Site to be Ready

Verify SIB for gnb 3
     [Documentation]    This is to receive SIB from RAN SIM GNB.
#     wtsrunner.gnb_param    id=3    sib1_period=40
#     sleep    2s
#     read_wtsemu_output_until      ${SIB1}     ${timeout}
     wtsrunner.gnb_param    id=3    sib2_period=40
     sleep    2s
     read_wtsemu_output_until      ${SIB2}     ${timeout}
     wtsrunner.gnb_param    id=3  sib5_period=40
     sleep    2s
     read_wtsemu_output_until      ${SIB5}     ${timeout}
     sleep    2s

Change UE location
    [Arguments]    ${ueid}    ${enb}    ${cell}
    [Documentation]    changes UE locations as per arguments.
    log to console    \nchanging UE location
    wtsrunner.ue_change_location    id=${ueid}    enb=${enb}     cell=${cell}
    run keyword and ignore error    read_wtsemu_output_until      ${location}    30
    sleep    5s

Validate TCP Traffic
    [Arguments]       ${UE_ID}    ${Pdu_session_ID}=${Pdu_session_ID}
    Log to Console    \nRunning DL + UL Traffic
    wtsrunner.trf_data_start     ue=${UE_ID}    pdu=${Pdu_session_ID}   qfi=1    dir=dl    protocol=tcp    seconds=3000
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=TCP DL TRF   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF   partial_match=${TRUE}
    Log to Console    ${output}
    sleep    5s
    wtsrunner.trf_data_start     ue=${UE_ID}   pdu=${Pdu_session_ID}   qfi=1    dir=ul    protocol=tcp    seconds=3000
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=TCP UL TRF    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF   partial_match=${TRUE}
    Log to Console    ${output}
    sleep    5s

Stop TCP Traffic
    [Arguments]       ${UE_ID}
    Log to Console    \nStopping DL + UL Traffic
    wtsrunner.trf_data_stop      ue=${UE_ID}    pdu=1   qfi=1    dir=dl
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Stopped Downlink Internal traffic   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    Stopped   partial_match=${TRUE}
    Log to Console    ${output}
    wtsrunner.trf_data_stop     ue=${UE_ID}   pdu=1   qfi=1    dir=ul
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=Stopping Uplink Internal traffic   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    uplink   partial_match=${TRUE}
    Log to Console    ${output}
    sleep    5s

Displays bearer statistics
    [Arguments]    ${ue_id}    ${QFI1}    ${Pdu_session_ID}=${Pdu_session_ID}
    LOG TO CONSOLE     \n Bearer stats for UE '${ue_id}' in DL direction
    bearer_stats    ue=${ue_id}   qfi=${QFI1}    pdu=${Pdu_session_ID}    dir=dl
    run keyword and ignore error    read_wtsemu_output_until       L3 stats for internal traffic     60
    sleep    10s
    LOG TO CONSOLE     \n Bearer stats for UE '${ue_id}' in UL direction
    bearer_stats    ue=${ue_id}    qfi=${QFI1}    dir=ul     pdu=${Pdu_session_ID}
    run keyword and ignore error    read_wtsemu_output_until       L3 stats for internal traffic     60
    sleep    10s

Modify PDU session for UE to add
    [Arguments]    ${ue_id}    ${Pdu_session_ID}=${Pdu_session_ID}    ${QFI}=${QFI2}     ${pattern}=${pdu_session_modify}
    ue_pdu_session_modify    ue=${ue_id}    pdu=${Pdu_session_ID}    qosflows_to_add=${QFI}   by=amf
    sleep    10s
    read_wtsemu_output_until    ${pattern}    ${timeout}
    sleep    5s

Modify PDU session for UE to delete
    [Arguments]    ${ue_id}
    ue_pdu_session_modify    ue=${ue_id}    pdu=1    qosflows_to_del=2    by=amf
    read_wtsemu_output_until    ${pdu_session_modify_delete}    ${timeout}
    sleep    10s

Validate Traffic with RTP
    [Arguments]   ${ue_id}    ${Pdu_session_ID}=${Pdu_session_ID}
    trf_data_start     ue=${UE_ID}    pdu=${Pdu_session_ID}   qfi=2  dir=dl  rtp_codec=amr_wb_18_25    seconds=3000
    ${output}   wtsrunner.read_wtsemu_output_until_re    expected=Started Downlink RTP Internal traffic over UDP    timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    \n${output}
    trf_data_start     ue=${UE_ID}   pdu=${Pdu_session_ID}   qfi=2  dir=ul    rtp_codec=amr_wb_18_25    seconds=3000
    ${output}    wtsrunner.read_wtsemu_output_until_re    expected=Started Uplink RTP Internal traffic over UDP   timeout=10
    ${output}         Get Lines Matching Regexp    ${output}    TRF:   partial_match=${TRUE}
    Log to Console    \n${output}
    Sleep    5s

Stop pcap collection in gNB 7292
    [Arguments]     ${name}   ${Log_Path}
    core.stop_collectors    names=${name}
    core.collect_collectors    names=${name}    target_dir=${Log_Path}
    core.teardown_collectors    names=${name}
    ${pcap_file_path}=   set variable    ${Log_Path}/${name}/${name}.pcap
    [Return]     ${pcap_file_path}

Verify QFI from PCAP
    [Arguments]   ${pcap_file_path}        ${filter}       ${field}
    ${arq}    Get Fields from Pcap     ${pcap_file_path}        ${filter}      ${field}
    should be equal    ${arq}    1

Verify Qos deleted from PCAP
    [Arguments]   ${pcap_file_path}        ${filter}       ${field}
    ${qos}    Get Fields from Pcap     ${pcap_file_path}         ${filter}     ${field}
    should be equal    ${qos}    2

Establish Emergency RRCConnection
    [Arguments]    ${ue}
    wtsrunner.ue_nr_rrc_setup_param     id=${ue}    establishment_cause=emergency
    ue_im_exit    by=ue      id=${ue}
    sleep    10s

Modify PDU session should fail
    [Arguments]    ${ue_id}    ${pattern}
    ue_pdu_session_modify    ue=${ue_id}    pdu=1    qosflows_to_add=2    by=amf
    Run Keyword and ignore error    read_wtsemu_output_until       ${pattern}    ${timeout}
    sleep    5s

Set Priority For Qosflows
    [Arguments]    ${QFI}    ${PR}
    qosflow_modify     qos_flow=${QFI}    priority=${PR}
    log to console     \n Set priority ${PR} for Qos flow id ${QFI}
    qosflow_disp

Get Num Of Packets Received From Bearer Display
    [Arguments]    ${ue_id}    ${QFI}     ${pdu}
    LOG TO CONSOLE     \n Bearer stats for UE '${ue_id}' in UL direction
    bearer_stats     ue=${ue_id}    qfi=${QFI}    dir=dl     pdu=${pdu}
    ${output}    Read WTS Output Until Pattern Matches      Average packet interval     60
    ${packet_count}    check_received_packets    ${output}
    Log to Console    \n${packet_count}
    [Return]   ${packet_count}

Verify If Traffic Is Running
    [Arguments]    ${ue_id}    ${QFI}     ${pdu}
     ${packet_count1}   get num of packets received from bearer display    ${ue_id}    ${QFI}     ${pdu}
     sleep    5s
     ${packet_count2}   get num of packets received from bearer display    ${ue_id}    ${QFI}     ${pdu}
     ${result}=    Evaluate    ${packet_count2} > ${packet_count1}
     Should Be True    ${result}

Convert PCAP to PDML
    [Arguments]    ${pcap_file}
    create file     ${pdml_file}
    ${cmd}          Set Variable    tshark -r ${pcap_file} -Y  "ngap.radioNetwork" -T pdml > ${pdml_file}
    Run Process     ${cmd}    shell=True
    [Return]     ${pdml_file}

Verify UE registration and pdu setup
    [Arguments]    ${UE_ID}    ${Pdu_session_ID}=${Pdu_session_ID}    ${gw_ID}=${gw_ID}
    ue_register   id=${UE_ID}
    ${output}    Read WTS Output Until Pattern Matches    ${UE_register_complete_pattern}    ${Timeout_SA}
    Print Matching Lines from Output File    ${output}    ${UE_register_complete_pattern}
    wtsrunner.set_pdu_param   ue=${UE_ID}    pdu=${Pdu_session_ID}    trf_type=${Trf_type}
    wtsrunner.ue_pdu_session_setup    pdu=${Pdu_session_ID}    ue=${UE_ID}   nwslice=${nwslice_ID}   gw=${gw_ID}
    sleep    5s
    Read WTS Output For Pattern And Print matching Lines    ${pdu_setup}    ${Timeout_SA}

Teardown common MP AP L0
    [Documentation]    loading the backuped SCF file through full comm
    Log to Console      \n Sending full commission
    Full Commission With SCF File For UTE      /home/ute/Downloads/SCF_Backup.xml
    Sleep   180s
    Wait Coam Site to be Ready
