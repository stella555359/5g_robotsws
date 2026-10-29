*** Settings ***
Documentation    Author
...              \n Please do not edit the existing keywords in this file without testing.
...              \n list of available keywords in CORE.
...              \n https://docs.taf.nsn-rdnet.net/taf.collectors.core/2.0.10/1/robot.collector_keywords/

*** Keywords ***
Start SA UE Internal Trf DLUL
    [Arguments]    ${ue_id}    ${mbps_dl}    ${mbps_ul}    ${pdu_id}=1
    SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    ${mbps_dl}    trf_id=1
    SA Start UL Traffic Internal    ${ue_id}    ${pdu_id}    ${mbps_ul}    trf_id=1

Trigger MSG3 Retran
    [Arguments]    ${ue_id}    ${msg3_retr_num}
    ute_wtssim.Execute Egate Command    cmd=cont_res_testmode_nr msg3_retx=${msg3_retr_num} profile_id=1
    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id=${ue_id} testmode=contention_resolution profile_id=1 action=activate scell=primary

Check SA UE DLandUL Internal Avg L3 Tput
    [Arguments]    ${ue_id}    ${target_tput_dl}    ${target_tput_ul}    ${rate}=0.2    ${pdu_id}=1    ${qfi}=1
    Sleep    2s    reason=wait tput stable
    SA Check UE L3 Tput In Target Range    ${ue_id}    dl    ${target_tput_dl}    ${rate}    ${pdu_id}    ${qfi}
    SA Check UE L3 Tput In Target Range    ${ue_id}    ul    ${target_tput_ul}    ${rate}    ${pdu_id}    ${qfi}

Trigger Paging
    [Arguments]    ${ue_id}    ${cause}    ${AMF}=1    ${default_drx}=256    ${max_paging_retries}=10
    ute_wtssim.Execute Egate Command    cmd=amf_paging_param id=${AMF} default_drx=${default_drx} max_paging_retries=${max_paging_retries}
    ${output}    ute_wtssim.Execute Egate Command       cmd=ue_ng_ctx_release id=${ue_id} cause=${cause}
    ...       pass_regexp=OnReceiveUeContextReleaseComplete    timeout=3s
    ${output}    ute_wtssim.Execute Egate Command         cmd=amf_paging_start id=${AMF} ue=${ue_id}
    ...      pass_regexp=pagingRecordList    timeout=3s
    Sleep        2s    reason=wait paging is stable

SA UEs Attach And Trf
    SA Single UE Attach    ${UE_1}
    Start SA UE Internal Trf DLUL    ${UE_1}    ${UE_DL_TRF}    ${UE_UL_TRF}
    SA Single UE Attach    ${UE_2}
    Start SA UE Internal Trf DLUL    ${UE_2}    ${UE_DL_TRF}    ${UE_UL_TRF}
    SA Single UE Attach    ${UE_3}
    Start SA UE Internal Trf DLUL    ${UE_3}    ${UE_DL_TRF}    ${UE_UL_TRF}
    SA Single UE Attach    ${UE_4}
    Start SA UE Internal Trf DLUL    ${UE_4}    ${UE_DL_TRF}    ${UE_UL_TRF}

Ue Attach And Get Ttitrace
    [Arguments]    ${UE_num}    ${TTI_LOG_Path}
    SA UEs Attach And Trf
    Start Ttitrace With Streaming Mode
    Trigger MSG3 Retran    ${UE_num}    ${MSG3_RETR_NUM}
    Ue Attched And Trf    ${UE_num}
    Stop Ttitrace    ${TTI_LOG_NAME}    ${TTI_LOG_Path}
    Decode Ttitrace Log    ${TTI_LOG_Path}

A2A Check TTI Log
    [Arguments]    ${A2A_File_name}    ${TTI_LOG_Path}    ${A2A_PATH}
    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}${A2A_PATH}${/}${A2A_File_name}
    ...    i    save_log_directory=${TTI_LOG_Path}

Ue Attched And Trf
    [Arguments]    ${UE_NUM}
    SA Single UE Attach    ${UE_NUM}
    Start SA UE Internal Trf DLUL    ${UE_NUM}    ${UE_DL_TRF}    ${UE_UL_TRF}

Copy File For Multi UEs
    [Arguments]    ${WTS_MULTI_UE}
    OperatingSystem.Run  cp ${LOCAL_WTS_DIR}/${WTS_MULTI_UE} ${WTS_DIR}
    Wait Until Keyword Succeeds    5s    1s    OperatingSystem.File Should Exist    ${WTS_DIR}/${WTS_MULTI_UE}

Multi UEs Attach By Script
    [Arguments]    ${WTS_MULTI_UE}    ${sa_ue_id_begin}    ${sa_ue_id_end}
    Log To Console    start multi UEs register...
    ute_wtssim.Execute Egate Command    cmd=script file\=${WTS_MULTI_UE} entry=start_multiue_call(${sa_ue_id_begin},${sa_ue_id_end},1,internal)
    ...    pass_regexp=All UEs are established successfully    timeout=5min
    Sleep    5s    reason=Wait for all ue info printed in egate console log.

Setup Pdu For The UEs
    FOR    ${index}    IN RANGE    1    51
    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_setup pdu=1 ue=${index} nwslice=1 gw=1
    END
    Sleep    60s    reason=Wait for all ue attached.

Convert BIP To CSV Check TransientUE
    [Arguments]       ${log_name}
    ${filter}=    Set Variable    dldata_pdcchsendreq||dldata_pdschpayloadtbsendreq
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot
    Convert BIP To CSV By MCShark    ${OUTPUT_DIR}/${log_name}     ${OUTPUT_DIR}/pdcch.csv    ${filter}    ${csv_title_list}

Trigger multi UEs L3 Call and Capture Bip Log
    Start Gnb BIP Log
    Setup Pdu For The UEs
    common_SA_ue_command.Start SA UE Big UL Traffic Internal    1    mbps=50
    common_SA_ue_command.Start SA UE Big DL Traffic Internal    1    mbps=50
    Stop Gnb BIP Log    ${OUTPUT_DIR}

Convert BIP To CSV For PdschSendReq
    [Arguments]       ${log_name}
    ${filter}=    Set Variable    dldata_pdschsendreq
    @{csv_title_list}=    Create List   3gpp.sfn    3gpp.slot    DlData_PdschGrant.numOfPrb    DlData_PdschGrant.startPrb
    Convert BIP To CSV By MCShark    ${OUTPUT_DIR}/${log_name}     ${OUTPUT_DIR}/pdsch.csv    ${filter}    ${csv_title_list}

Check TransientUE PRB Contiguous
    Convert BIP To CSV For PdschSendReq    5GBipL2L1_filtering_off.pcap
    A2A_Check_CSV_Table    ${CURDIR}/A2A/A2A_B006/pdsch.ini    ${OUTPUT_DIR}/pdsch.csv    ${OUTPUT_DIR}

Check TranisentUE Multi With SIB1/OSI
    Convert BIP To CSV Check TransientUE    5GBipL2L1_filtering_off.pcap
    A2A_Check_CSV_Table    ${CURDIR}/A2A/A2A_B006/pdcch.ini    ${OUTPUT_DIR}/pdcch.csv    ${OUTPUT_DIR}

Set Value For MUE Testmode In Same Prach Time
    [Arguments]    ${profile_id}=7    ${numOfSfn}=8
    Log To Console    Set Value For MUE Testmode In Same Prach Time...
    ${cmd}    Set Variable
    ...    mue_prach_control_testmode_nr profile_id=${profile_id} mUe_in_same_prach_time=true numOfSfnToBeAddedInPrachTime=${numOfSfn}
    ute_wtssim.Execute Egate Command    ${cmd}

Set Value For MUE Testmode In Consecutive Prach Time
    [Arguments]    ${profile_id}=8
    Log To Console    Set Value For MUE Testmode In Consecutive Prach Time...
    ${cmd}    Set Variable    mue_prach_control_testmode_nr profile_id=${profile_id} mUe_in_consecutive_prachTime=true
    ute_wtssim.Execute Egate Command    ${cmd}

Trigger SIB1/OSI Multi with msg2/msg4 By MUE Testmode
    [Documentation]    This keyword is to trigger SIB1 OSI multiplexed with msg2 and msg4 on same slot
    Log To Console   \Trigger FDM By MUE Testmode...\n
    Set Value For MUE Testmode In Same Prach Time
    CUDU_L2 Send Action To GNB    9-16    mue_prach_control    activate    7
    Set Value For MUE Testmode In Consecutive Prach Time
    CUDU_L2 Send Action To GNB    1-8    mue_prach_control    activate    8
    CUDU_L2 Send Action To GNB    17-24    mue_prach_control    activate    8
    ${cmd_1}    Set Variable    ue_register id=1-24
    ute_wtssim.Execute Egate Command    ${cmd_1}
    Sleep    5s    reason=make sure the cmd take affect

Check SIB1/OSI Multi with msg2/msg4 and PRB Contiguous
    ta_a2a.Check Log With Au2anlysis    ${CURDIR}${/}A2A${/}A2A_B007${/}CB009550_B007.ini
    ...    i    save_log_directory=${output_dir}/ttitrace_streaming

Check Msg2 Multiplexed With Msg4
    [Arguments]       ${log_name}=5GBipL2L1_filtering_off.pcap
    ${filter}=    Set Variable    dldata_pdschsendreql1sw || dldata_pdschpayloadtbsendreql1sw || dldata_pdcchsendreql1sw
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    DlData_PdschGrantL1sw.rachStatus    DlData_DciInfoL1sw.rachStatus
    ...    DlData_PdschGrantL1sw.numOfPrb    DlData_PdschGrantL1sw.startPrb
    Convert BIP To CSV By MCShark    ${TEST_LOG_DIRECTORY}/${log_name}    ${TEST_LOG_DIRECTORY}/rachStatus.csv    ${filter}    ${csv_title_list}
    #A2A_Check_CSV_Table    ${CURDIR}/A2A/A2A_B011/rachStatus.ini    ${TEST_LOG_DIRECTORY}/rachStatus.csv    ${TEST_LOG_DIRECTORY}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/A2A_B011/rachStatus_prb.ini    ${TEST_LOG_DIRECTORY}/rachStatus.csv    ${TEST_LOG_DIRECTORY}

Trigger Msg2 Multiplexed With Msg4
    ${cmd}    Set Variable    cont_res_testmode_nr profile_id=4 msg4_nacks=8
    ute_wtssim.Execute Egate Command    ${cmd}
    CUDU_L2 Send Action To GNB    1-7    contention_resolution    activate    4
    #Set Value For MUE Testmode In Consecutive Prach Time
    #CUDU_L2 Send Action To GNB    1-7    mue_prach_control    activate    8
    Set Suite Variable    ${Trigger_sucess_flag}    ${False}
    FOR    ${index}    IN RANGE    1    ${MAX_Trigger_TIME}+1
        Log To Console    ===============Trigger Time: ${index}==============
        Set Suite Variable    ${log_id}    ${index}
        Start Gnb BIP Log
        ${cmd_1}    Set Variable    ue_register id=1-7
        Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command    ${cmd_1}
        Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/${log_id}
        ${res}    Run Keyword And Return Status    Check Msg2 Multiplexed With Msg4    log_name=${log_id}/5GBipL2L1_filtering_off.pcap
        ${Trigger_sucess_flag}=    Set Variable If    '${res}'=='True'    ${True}
        ${cmd_2}    Set Variable    ue_deregister id=1-7 ue_deregister_type=switch_off
        Run Keyword If    '${res}'=='False'    Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command    ${cmd_2}
        Sleep    5s    reason=Wait for all ue dettached.
        Exit For Loop If    '${res}'=='True'
    END
    Should Be True    "${Trigger_sucess_flag}"=="${True}"

Modify MinRbReservedForNonSiPaging To ExceededTheLimit
    Block Cell With Admin    ${cell_name}
    Start Gnb Wireshark Log
    Start GNB AP Syslog    ${TEST_LOG_DIRECTORY}
    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_Exceeded_B011.xml
    Delta Commission With SCF File    ${json_file}
    Sleep        30S    reason=wait for gnb status backs to normal after Delta Commission
    Unblock Cell With Admin    ${cell_name}
    Stop Gnb Wireshark Log
    ${gnb_wireshark}=    Collect Gnb Wireshark Log    log_dir=${TEST_LOG_DIRECTORY}/Exceed
    Check MinRbExceededTheLimit    ${gnb_wireshark}

Check MinRbExceededTheLimit
    [Arguments]    ${pcap_file}
    cap.Read Cap    cap_file=${pcap_file}    display_filter=itf_l2_ps_cell_cellsetupresp
    ${status} =    cap.get_element_value    element_expression=itf_SMessageResult5G.status    element_idx=${0}    default_value=True
    ...    condition_expression=itf_SMessageResult5G.status == 1
    Should Contain    ${status}    1
    ${cause} =    cap.get_element_value    element_expression=itf_SMessageResult5G.cause    element_idx=${0}    default_value=True
    ...    condition_expression=itf_SMessageResult5G.cause == 8
    Should Contain    ${cause}    8

Modify MinRbReservedForNonSiPaging To LessTheLimit
    Block Cell With Admin    ${cell_name}
    Start Gnb Wireshark Log
    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_Less_B011.xml
    Delta Commission With SCF File    ${json_file}
    Unblock Cell With Admin    ${cell_name}
    ${egate_file}    Set Variable    /opt/iphy/latest/egate_console.log
    Wait Until Keyword Succeeds    10s    5s    Check Egate Log With Message    ${egate_file}    ${CELL1_SIB}
    Stop Gnb Wireshark Log
    ${gnb_wireshark}=    Collect Gnb Wireshark Log    log_dir=${TEST_LOG_DIRECTORY}/Less
    Check MinRbSize And Msg2TargetRate    ${gnb_wireshark}

Check MinRbSize And Msg2TargetRate
    [Arguments]    ${pcap_file}
    cap.Read Cap    cap_file=${pcap_file}    display_filter=itf_l2_ps_cell_cellsetupreq || itf_l2_ps_cell_cellsetupresp
    ${FdmInitialBWP} =    cap.get_element_value    element_expression=itf_l2_ps_cell_FdmConfig.actFdmSchedulingInitialBWP
    ...    element_idx=${0}    default_value=True
    Should Contain    ${FdmInitialBWP}    True
    ${minRb} =    cap.get_element_value    element_expression=itf_l2_ps_cell_CellSetupReq_t.minRbReservedForNonSiPaging_item
    ...    element_idx=${0}    default_value=True    condition_expression=itf_l2_ps_cell_CellSetupReq_t.minRbReservedForNonSiPaging_item == 34
    Should Contain    ${minRb}    34
    ${Msg2TargetRate} =    cap.get_element_value    element_expression=itf_l2_ps_cell_CellSetupReq_t.raMsg2TargetRateIndex_item
    ...    element_idx=${0}    default_value=True    condition_expression=itf_l2_ps_cell_CellSetupReq_t.raMsg2TargetRateIndex_item == 20
    Should Contain    ${Msg2TargetRate}    20

Check Alarm Reported And Clear
    Log To Console    Check Alarm
    ute_syslog.Collect Syslog Results    alias=${GNB_SYSLOG.alias}    unzip=False    destination=${TEST_LOG_DIRECTORY}/Gnb_syslog.tar.gz
    ${rc}    ${output}=    OperatingSystem.Run And Return Rc And Output    cd ${TEST_LOG_DIRECTORY};tar -xzvf ${TEST_LOG_DIRECTORY}/Gnb_syslog.tar.gz
    Log    ${output}
    ${syslog_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}    Gnb_syslog_*    ${True}
    ${content}    OperatingSystem.Run    cat ${TEST_LOG_DIRECTORY}/Gnb_syslog_*|grep -i "FaultId: 7506"
    Should Contain    ${content}    Reported alarm
    Should Contain    ${content}    Clear alarm

Check Target Tput For MUE
    [Arguments]    ${start_ue_id}    ${end_ue_id}    ${dir}    ${pcell_index}    ${target_sum_tp}
    ${pcell_TP}    Get CA Cell Average Throughput For MUE    ${start_ue_id}    ${end_ue_id}    ${dir}    ${pcell_index}
    Log To Console    Pcell's ${dir} Troughput is ${pcell_TP}    console=True
    Should Be True    ${pcell_TP}>=${target_sum_tp}

Multi UE L3 call
    [Arguments]    ${index}=8    ${mbps}=5    ${expect_tupt}=35
    FOR    ${ue_id}    IN RANGE    1    ${index}
        SA Set Traffic Type To Internal    ${ue_id}
        SA 5G PDU Session Setup    ${ue_id}
        SA Start UL Traffic Internal    ${ue_id}    pdu_id=1    mbps=${mbps}
        SA Start DL Traffic Internal    ${ue_id}    pdu_id=1    mbps=${mbps}
    END
    Sleep        10S    reason=wait trf is stable
    ${new}    Evaluate    ${index}-1
    Check Target Tput For MUE    1    ${new}    dl    0    ${expect_tupt}
    #Check Target Tput For MUE    1    ${new}    ul    0    ${expect_tupt}

UE L3 Call For B006
    [Arguments]    ${index}=3    ${mbps}=5    ${expect_tupt}=10
    FOR    ${ue_id}    IN RANGE    1    ${index}
        SA Start UL Traffic Internal    ${ue_id}    pdu_id=1    mbps=${mbps}
        SA Start DL Traffic Internal    ${ue_id}    pdu_id=1    mbps=${mbps}
    END
    Sleep        10S    reason=wait trf is stable
    ${new}    Evaluate    ${index}-1
    Check Target Tput For MUE    1    ${new}    dl    0    ${expect_tupt}
    Check Target Tput For MUE    1    ${new}    ul    0    ${expect_tupt}

Configure VM Interface For CFRA HO
    [Arguments]    ${ip_addr_1}    ${ip_addr_2}
    [Documentation]    This keyword is to configure HO related interfaces on VM interfaces including GNB2 NG, XN and proxy.
    Log To Console    configure VM interfaces...
    OperatingSystem.Run    sudo ip addr add ${ip_addr_1} dev eth3
    OperatingSystem.Run    sudo ip addr add ${ip_addr_2} dev eth3

Trigger Inter GNB Handover With CFRA
    Trigger A3 Event for HO    ue_id=1-4    phycell_id=49  meas_id=1
    Start Gnb BIP Log
    Trigger A3 Event for HO    ue_id=1-4    phycell_id=50  meas_id=3
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}

Trigger FDD Inter GNB Handover With CFRA
    Trigger A2 Event For HO    ue_id=1-4
    Trigger A3 Event for HO    ue_id=1-4  phycell_id=381  meas_id=3  srsrp_nr=20  srsrq_nr=20  nrsrp_nr=61  nrsrq_nr=61
    Start Gnb BIP Log
    Trigger A3 Event for HO    ue_id=1-4  phycell_id=60  meas_id=1  srsrp_nr=8  srsrq_nr=8  nrsrp_nr=35  nrsrq_nr=35
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}

Trigger A3 Event for HO
    [Arguments]    ${ue_id}    ${meas_id}    ${phycell_id}    ${srsrp_nr}=20    ${srsrq_nr}=40    ${nrsrp_nr}=100    ${nrsrq_nr}=50
    Log To Console
    ...    Trigger A3 Event For Handover...
    ${ho}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A3 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    ...    phycell_id=${phycell_id} nrsrp_nr=${nrsrp_nr} nrsrq_nr=${nrsrq_nr} rs_type=ssb index=0 nrs_result=30:30:30
    Sleep    3s    reason=make sure the cmd take affect
    ${output}    ute_wtssim.Execute Egate Command    ${ho}
    Log To Console    ${output}

Trigger A2 Event For HO
    [Arguments]    ${ue_id}    ${meas_id}=1    ${srsrp_nr}=8    ${srsrq_nr}=8
    Log To Console    Trigger A2 Event For Inter Freq Handover
    ${cmd}    Catenate    ue_measurement_send_nr id=${ue_id} meas_id=${meas_id} event=A2 srsrp_nr=${srsrp_nr} srsrq_nr=${srsrq_nr}
    Sleep    3s    reason=make sure the cmd take affect
    ${output}    ute_wtssim.Execute Egate Command    ${cmd}
    Log To Console    ${output}

Check Msg2 Multiplexed With Msg2
    [Arguments]       ${log_name}=5GBipL2L1_filtering_off.pcap    ${A2A_path}=A2A_B021
    Log To Console    Check Msg2 Multiplexed With Msg2...
    ${filter}=    Set Variable    DlData_PdschGrantL1sw.rachStatus == 2
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    DlData_PdschGrantL1sw.rachStatus
    ...    DlData_PdschGrantL1sw.numOfPrb
    Convert BIP To CSV By MCShark    ${TEST_LOG_DIRECTORY}/${log_name}    ${TEST_LOG_DIRECTORY}/rachStatus.csv    ${filter}    ${csv_title_list}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/${A2A_path}/rachStatus.ini    ${TEST_LOG_DIRECTORY}/rachStatus.csv    ${TEST_LOG_DIRECTORY}

Trigger Msg2 Multiplexed With Msg4 When BF Enabled
    Set Suite Variable    ${Trigger_sucess_flag}    ${False}
    FOR    ${index}    IN RANGE    1    ${MAX_Trigger_TIME}+1
        ${res}    Run Keyword And Return Status    Check Msg2 Multiplexed With Msg4
        ${Trigger_sucess_flag}=    Set Variable If    '${res}'=='True'    ${True}
        Run Keyword If    '${res}'=='False'    Multi UEs Attach with MSG4 Retr For CaseB033
        Exit For Loop If    '${res}'=='True'
    END
    Should Be True    "${Trigger_sucess_flag}"=="${True}"
    Log To Console     Check Msg2 Multiplexed With Msg4 success

Trigger and Check Msg2 Multiplexed With Msg2 For Different RARNTI
    Set Suite Variable    ${Trigger_sucess_flag}    ${False}
    FOR    ${index}    IN RANGE    1    ${MAX_Trigger_TIME}+1
        ${res}    Run Keyword And Return Status    Check Msg2 Multiplexed With Msg2 For Different RARNTI
        ${Trigger_sucess_flag}=    Set Variable If    '${res}'=='True'    ${True}
        Run Keyword If    '${res}'=='False'    Multi UEs Attach For CaseB033
        Exit For Loop If    '${res}'=='True'
    END
    Should Be True    "${Trigger_sucess_flag}"=="${True}"
    Log To Console     Msg2 Multiplexed With Msg2 For Different RARNTI success

Trigger and Check Msg2 Multiplexed With Msg2 For Same RARNTI
    Set Suite Variable    ${Trigger_sucess_flag}    ${False}
    FOR    ${index}    IN RANGE    1    ${MAX_Trigger_TIME}+1
        ${res}    Run Keyword And Return Status    Check Msg2 Multiplexed With Msg2 For Same RARNTI
        ${Trigger_sucess_flag}=    Set Variable If    '${res}'=='True'    ${True}
        Run Keyword If    '${res}'=='False'    Multi UEs Attach For CaseB033
        Exit For Loop If    '${res}'=='True'
    END
    Should Be True    "${Trigger_sucess_flag}"=="${True}"
    Log To Console    Msg2 Multiplexed With Msg2 For Same RARNTI success

Trigger and Check Msg3 Multiplexed With Msg3
    Set Suite Variable    ${Trigger_sucess_flag}    ${False}
    FOR    ${index}    IN RANGE    1    ${MAX_Trigger_TIME}+1
        ${res}    Run Keyword And Return Status    Check Msg3 Multiplexed With Msg3
        ${Trigger_sucess_flag}=    Set Variable If    '${res}'=='True'    ${True}
        Run Keyword If    '${res}'=='False'    Multi UEs Attach For CaseB033
        Exit For Loop If    '${res}'=='True'
    END
    Should Be True    "${Trigger_sucess_flag}"=="${True}"
    Log To Console    Check Msg3 Multiplexed With Msg3 success

Trigger and Check Msg4 and Msg4 Multiplex
    Set Suite Variable    ${Trigger_sucess_flag}    ${False}
    FOR    ${index}    IN RANGE    1    ${MAX_Trigger_TIME}+1
        ${res}    Run Keyword And Return Status    Check Msg4 and Msg4 Multiplex
        ${Trigger_sucess_flag}=    Set Variable If    '${res}'=='True'    ${True}
        Run Keyword If    '${res}'=='False'    Multi UEs Attach with MSG4 Retr For CaseB033
        Exit For Loop If    '${res}'=='True'
    END
    Should Be True    "${Trigger_sucess_flag}"=="${True}"
    Log To Console    Check Msg4 and Msg4 Multiplex success

Check Msg2 Multiplexed With Msg2 For Different RARNTI
    [Arguments]       ${log_name}=5GBipL2L1_filtering_off.pcap
    ${filter}=    Set Variable    dldata_pdschsendreq || dldata_pdschpayloadtbsendreq || dldata_pdcchsendreq
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    3gpp.rnti    DlData_PdschGrant.rachStatus
    ...    DlData_DciInfo.rachStatus   DlData_PdschGrant.numOfPrb    DlData_PdschGrant.startPrb
    Convert BIP To CSV By MCShark    ${TEST_LOG_DIRECTORY}/${log_name}    ${TEST_LOG_DIRECTORY}/rachStatus.csv    ${filter}    ${csv_title_list}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/A2A_B033/msg2msg2_prb.ini   ${TEST_LOG_DIRECTORY}/rachStatus.csv    ${TEST_LOG_DIRECTORY}

Check Msg2 Multiplexed With Msg2 For Same RARNTI
    [Arguments]       ${log_name}=5GBipL2L1_filtering_off.pcap
    ${filter}=    Set Variable    dldata_pdschsendreq || dldata_pdschpayloadtbsendreq || dldata_pdcchsendreq
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    3gpp.rnti    DlData_PdschGrant.rachStatus
    ...    DlData_DciInfo.rachStatus   DlData_PdschGrant.numOfPrb    DlData_PdschGrant.startPrb
    Convert BIP To CSV By MCShark    ${TEST_LOG_DIRECTORY}/${log_name}    ${TEST_LOG_DIRECTORY}/rachStatus.csv    ${filter}    ${csv_title_list}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/A2A_B033/msg2_prb.ini   ${TEST_LOG_DIRECTORY}/rachStatus.csv    ${TEST_LOG_DIRECTORY}

Check Msg4 and Msg4 Multiplex
    [Arguments]       ${log_name}=5GBipL2L1_filtering_off.pcap
    ${filter}=    Set Variable    dldata_pdschsendreq || dldata_pdschpayloadtbsendreq || dldata_pdcchsendreq
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    3gpp.rnti    DlData_PdschGrant.rachStatus
    ...     DlData_DciInfo.rachStatus   DlData_PdschGrant.numOfPrb    DlData_PdschGrant.startPrb
    Convert BIP To CSV By MCShark    ${TEST_LOG_DIRECTORY}/${log_name}    ${TEST_LOG_DIRECTORY}/rachStatus.csv    ${filter}    ${csv_title_list}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/A2A_B033/msg4msg4_prb.ini   ${TEST_LOG_DIRECTORY}/rachStatus.csv    ${TEST_LOG_DIRECTORY}

Check Msg3 Multiplexed With Msg3
    [Arguments]       ${log_name}=5GBipL2L1_filtering_off.pcap
    ${filter}=    Set Variable    uldata_puschreceivereq || uldata_puschreceiverespharqu
    @{csv_title_list}=    Create List    UlData_puschReceiveReqGrant_t.numOfPrb    UlData_puschReceiveReqGrant_t.startPrb
    ...    UlData_puschReceiveReqGrant_t.rachStatus
    Convert BIP To CSV By MCShark    ${TEST_LOG_DIRECTORY}/${log_name}     ${TEST_LOG_DIRECTORY}/rachStatus.csv    ${filter}    ${csv_title_list}
    ${result_list}     create list
    ${Prbs}  read csv columns      ${TEST_LOG_DIRECTORY}/rachStatus.csv    UlData_puschReceiveReqGrant_t.startPrb
    ...    filter=((UlData_puschReceiveReqGrant_t.numOfPrb=3,3)&(UlData_puschReceiveReqGrant_t.rachStatus=3,3))
    :FOR     ${prb}    IN    @{Prbs}
    \      ${tmp}   evaluate      "${prb}".split(',')
    \      ${ret}     evaluate    abs(int(${tmp[0]})-int(${tmp[1]}))
    \      run keyword if   ${ret}!=3    log to console     ${prb}
    \      append to list    ${result_list}     ${ret}
    ${result}    evaluate     list(set(${result_list}))
    ${judge1}     evaluate      len(${result})==1
    ${judge2}     evaluate      ${result[0]} == 3
    run keyword if     not (${judge1} and ${judge2})      fail

Multi UEs Attach For CaseB033
    Start Gnb BIP Log
    FOR    ${index}    IN RANGE    1    ${${UE_NUM}+1}    7
        Log To Console    Multi UEs Attach For CaseB033
        ${output}    ute_wtssim.Execute Egate Command And Wait For Data
        ...    ue_register id\=${index}-${${index}+3}    pass_regexp=REGISTRATION COMPLETE|Registration    timeout=1s
        ${output}    ute_wtssim.Execute Egate Command And Wait For Data
        ...    ue_register id\=${${index}+4}-${${index}+7}    pass_regexp=REGISTRATION COMPLETE|Registration    timeout=1s
        Sleep    5s
    END
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}
    Run Keyword And Ignore Error     SA 5G Detach    1-${${UE_NUM}+1}

Multi UEs Attach with MSG4 Retr For CaseB033
    ute_wtssim.Execute Egate Command
    ...    cmd=cont_res_testmode_nr profile_id=1 msg4_nacks=4
    Start Gnb BIP Log
    FOR    ${index}    IN RANGE    1    ${${UE_NUM}+1}    7
        Log To Console    Multi UEs Attach with MSG4 Retr For CaseB033
        ute_wtssim.Execute Egate Command
        ...    cmd=ue_testmode_set_nr id=${index}-${${index}+7} testmode=contention_resolution action=activate profile_id=1
        ${output}    ute_wtssim.Execute Egate Command And Wait For Data
        ...    ue_register id\=${index}-${${index}+3}    pass_regexp=REGISTRATION COMPLETE|Registration    timeout=1s
        ${output}    ute_wtssim.Execute Egate Command And Wait For Data
        ...    ue_register id\=${${index}+4}-${${index}+7}    pass_regexp=REGISTRATION COMPLETE|Registration    timeout=1s
        Sleep    5s
    END
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}
    Run Keyword And Ignore Error     SA 5G Detach    1-${${UE_NUM}+1}

Set Beam_control_testmode
    Log To Console    Set Beam_control_testmode
    ute_wtssim.Execute Egate Command
    ...    cmd=beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    ute_wtssim.Execute Egate Command
    ...    cmd=beam_control_testmode_nr profile_id=2 ueBeamIndexInitial=1,0 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-50
    FOR    ${index}    IN RANGE    1    ${UE_NUM}+1    2
        ute_wtssim.Execute Egate Command
        ...    cmd=ue_testmode_set_nr id=${index} testmode=beam_control action=activate profile_id=1 beamaction=attach
        ute_wtssim.Execute Egate Command
        ...    cmd=ue_testmode_set_nr id=${${index}+1} testmode=beam_control action=activate profile_id=2 beamaction=attach
    END

Set Beam_control_testmode and UE Attach
    Set Beam_control_testmode
    Log To Console    UE Attach...
    FOR    ${index}    IN RANGE    1    ${${UE_NUM}+1}    7
        ${output}    ute_wtssim.Execute Egate Command And Wait For Data
        ...    ue_register id\=${index}-${${index}+6}    pass_regexp=REGISTRATION COMPLETE|Registration    timeout=1s
        Sleep    1s
    END
    Run Keyword And Ignore Error    9550 PDU Setup    ${${UE_NUM}+1}

9550 PDU Setup
    [Arguments]    ${index}
    : FOR    ${ue_id}    IN RANGE    1    ${index}
    \    SA Set Traffic Type To Internal    ${ue_id}
    \    SA 5G PDU Session Setup    ${ue_id}

Set A2 measurement
    Log To Console    Set A2 measurement
    FOR    ${index}    IN RANGE    1    ${${UE_NUM}+1}
        ute_wtssim.Execute Egate Command
        ...    cmd=ue_measurement_send_nr id=${index} meas_id=1 event=A2 srsrp_nr=70 srsrq_nr=70
    END
    Sleep    10s

Trigger CFRA HO When BF enabled
    Log To Console    CFRA HO
    FOR    ${index}    IN RANGE    1    ${${UE_NUM}+1}   2
        ${cmd1}=    Catenate    ue_measurement_send_nr id=${index} meas_id=3 event=A3 srsrp_nr=70 srsrq_nr=70 ssinr_nr=10 phycell_id=51
        ...    nrsrp_nr=65 nrsrq_nr=40 nsinr_nr=50 rs_type=ssb index=0 nrs_result=30:30:30
        ${cmd2}=    Catenate    ue_measurement_send_nr id=${index} meas_id=3 event=A3 srsrp_nr=70 srsrq_nr=70 ssinr_nr=10 phycell_id=51
        ...    nrsrp_nr=65 nrsrq_nr=40 nsinr_nr=50 rs_type=ssb index=1 nrs_result=30:30:30
        ute_wtssim.Execute Egate Command
        ...    cmd=${cmd1}
        ute_wtssim.Execute Egate Command
        ...    cmd=${cmd2}
    END

Get and Check PM Counter After CFRA HO
    [Documentation]    RA_CF_STP_TIME: M55306C09012
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
    Log To Console    to reach next pm counter update time, need to wait ${time}...
    Sleep    ${time}    wait for pm counter file updated.
    Sleep    120s    wait pm counter file generated stable.
    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${OUTPUT_DIR}/test_pmcounter.gz
    ${ra_cf_stp_time}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55306C09012    cell_id=2
    Should Be True    "${ra_cf_stp_time}">"0"
    ${ra_comp_ded_prmbl}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55306C05001    cell_id=2
    ${ra_average}    evaluate    ${ra_cf_stp_time}/${ra_comp_ded_prmbl}
    Log To Console    ${ra_average}
    Should Be True    "${ra_average}"=="7500.0"

Set beam_control_testmode For B035
    ${cmd1}    Set Variable
    ...    beam_control_testmode_nr profile_id=3 ueBeamIndexInitial=0,1 ssbeam_bestbeam=0 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    ute_wtssim.Execute Egate Command    ${cmd1}
    ${cmd2}    Set Variable
    ...    beam_control_testmode_nr profile_id=4 ueBeamIndexInitial=1,0 ssbeam_bestbeam=1 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-50
    ute_wtssim.Execute Egate Command    ${cmd2}
    ${cmd3}    Set Variable
    ...    beam_control_testmode_nr profile_id=5 ueBeamIndexInitial=2,3 ssbeam_bestbeam=2 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    ute_wtssim.Execute Egate Command    ${cmd3}
    ${cmd4}    Set Variable
    ...    beam_control_testmode_nr profile_id=6 ueBeamIndexInitial=3,2 ssbeam_bestbeam=3 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-50
    ute_wtssim.Execute Egate Command    ${cmd4}
    ${cmd5}    Set Variable
    ...    beam_control_testmode_nr profile_id=7 ueBeamIndexInitial=4,5 ssbeam_bestbeam=4 ssbeam_rsrp_best=-44 ssbeam_rsrp_avg=-50
    ute_wtssim.Execute Egate Command    ${cmd5}
    ${cmd6}    Set Variable
    ...    beam_control_testmode_nr profile_id=8 ueBeamIndexInitial=5,4 ssbeam_bestbeam=5 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-50
    ute_wtssim.Execute Egate Command    ${cmd6}
    Set beam_control for Each UE With TestMode    1    3
    Set beam_control for Each UE With TestMode    5    4
    Set beam_control for Each UE With TestMode    9    5
    Set beam_control for Each UE With TestMode    13    6
    Set beam_control for Each UE With TestMode    17    7
    Set beam_control for Each UE With TestMode    21    8

Set beam_control for Each UE With TestMode
    [Arguments]    ${first_ue_id}=1    ${frofile_id}=3
    FOR     ${ue_id}    IN RANGE    ${first_ue_id}   ${first_ue_id}+4
    ${cmd}    Set Variable
    ...    ue_testmode_set_nr id=${ue_id} testmode=beam_control action=activate profile_id=${frofile_id} beamaction=attach
    ute_wtssim.Execute Egate Command    ${cmd}
    Sleep    1s
    END

Multi Calls For B035
    #[Arguments]    ${index}=3    ${mbps}=5    ${expect_tupt}=10
    Attach UE25 and UE26 on Cell2 and Cell3
    Sleep    2s
    Run Keyword And Ignore Error    SA 5G Attach    1-4
    Sleep    2s
    Run Keyword And Ignore Error    SA 5G Attach    5-8
    Sleep    2s
    Run Keyword And Ignore Error    SA 5G Attach    9-12
    Sleep    2s
    Run Keyword And Ignore Error    SA 5G Attach    13-16
    Sleep    2s
    Run Keyword And Ignore Error    SA 5G Attach    17-20
    Sleep    2s
    Run Keyword And Ignore Error    SA 5G Attach    21-24
    Sleep    2s

Attach UE25 and UE26 on Cell2 and Cell3
    Log To Console    Attah UE25 and UE26 on Cell2 and Cell3
    SA 5G Attach    25
    SA 5G Attach    26
    FOR    ${ue_id}    IN RANGE    25    27
        SA Set Traffic Type To Internal    ${ue_id}    1
        SA 5G PDU Session Setup    ${ue_id}
        SA Start DL Traffic Internal    ${ue_id}    pdu_id=1    mbps=5
    END

Trigger RRC Reestablishment for B035
#    Copy ASOE LokiB BIP script
#    Start Gnb BIP Log
    Start GNB BIP By Admin Method
    Log To Console    ===============Trigger RRE===============
    ${cmd}    Set Variable
    ...    ue_rrc_reestablish id=1-24 gnb=2 cell=1 cause=otherFailure
    ute_wtssim.Execute Egate Command    ${cmd}
    Sleep    15s    reason=wait all RRE log collected
    Stop Gnb BIP By Admin Method
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}

Check msg5 FDMed with msg3 or msg5
    [Arguments]       ${log_name}=5GBipL2L1_filtering_off.pcap
    Log To Console    *********begin to check msg5 FDMed with msg5*********
    ${filter}=    Set Variable    uldata_puschreceivereq
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    UlData_puschReceiveReqGrant_t.rachStatus
    ...    UlData_puschReceiveReqGrant_t.numOfPrb    UlData_puschReceiveReqGrant_t.startPrb
    Convert BIP To CSV By MCShark    ${OUTPUT_DIR}/${log_name}    ${OUTPUT_DIR}/rachStatus.csv    ${filter}    ${csv_title_list}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/A2A_B035/rachStatus.ini    ${OUTPUT_DIR}/rachStatus.csv    ${OUTPUT_DIR}

Check Sib1 startPRB is Random
    [Arguments]       ${slot_num}=10    ${a2a_path}=A2A_B035    ${log_name}=5GBipL2L1_filtering_off.pcap
    Log To Console    *********begin to check Sib1 is random*********
    Log To Console    ${slot_num}
    ${filter}=    Set Variable
    ...    dldata_pdschsendreql1sw && 3gpp.rnti == 65535 && (DlData_PdschGrantL1sw.tbSize_bits > 800) && (3gpp.slot == 12) && 3gpp.subcellid == 0
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    3gpp.rnti    DlData_PdschGrantL1sw.startPrb
    Convert BIP To CSV By MCShark    ${OUTPUT_DIR}/${log_name}    ${OUTPUT_DIR}/sib1startPRB.csv    ${filter}    ${csv_title_list}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/${a2a_path}/sib1PRB.ini    ${OUTPUT_DIR}/sib1startPRB.csv    ${OUTPUT_DIR}

Check OSI startPRB is Random
    [Arguments]       ${a2a_path}=A2A_B035     ${log_name}=5GBipL2L1_filtering_off.pcap
    Log To Console    *********begin OSI startPRB is random*********
    ${filter}=    Set Variable
    ...    (dldata_pdschsendreql1sw) && (3gpp.rnti == 65535) && (DlData_PdschGrantL1sw.tbSize_bits < 500) && (3gpp.subcellid == 0)
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    3gpp.rnti    DlData_PdschGrantL1sw.startPrb
    Convert BIP To CSV By MCShark    ${OUTPUT_DIR}/${log_name}    ${OUTPUT_DIR}/osistartPRB.csv    ${filter}    ${csv_title_list}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/${a2a_path}/osiPRB.ini    ${OUTPUT_DIR}/osistartPRB.csv    ${OUTPUT_DIR}

Copy ASOE LokiB BIP script
    ${original_path}    Set Variable    /home/ute/MN/UTE/robotws/testsuite/Hangzhou/RRM/RAN_L2_SW_CN_1/CUDU_L2/scripts/shell/
    OperatingSystem.Run  cp ${CURDIR}/resources/bip_ASOE_little_traffic.sh ${original_path}
    Wait Until Keyword Succeeds    5s    1s    OperatingSystem.File Should Exist    ${original_path}/bip_ASOE_little_traffic.sh
    Log To Console    Copy ASOE shell script from local path completed

Check Tput for UE25 and UE26 for B035
    Log To Console    *********Begin to Check Tput for UE25 and UE26 *********
    Wait Until Keyword Succeeds    120s    15s    Check Target Tput For MUE    25    26    dl    0    2

Check SIB startPRB Fixed
    OperatingSystem.Copy Files    ${TEST_LOG_DIRECTORY}/${log_id}/5GBipL2L1_filtering_off.pcap    ${OUTPUT_DIR}
    Check Sib1 startPRB is Random    slot_num=12    a2a_path=A2A_B011    log_name=5GBipL2L1_filtering_off.pcap
    Check OSI startPRB is Random    a2a_path=A2A_B011    log_name=5GBipL2L1_filtering_off.pcap

Multi Calls For B037
#    [Arguments]    ${index}=3    ${mbps}=5    ${expect_tupt}=10
#    Set Value For MUE Testmode In Same Prach Time    7    26
#    Set sinr_target_preamble Testmode for FDD Cell
#    Set Value For MUE Testmode In Consecutive Prach Time
#    CUDU_L2 Send Action To GNB    1-4    mue_prach_control    activate    7
#    CUDU_L2 Send Action To GNB    5-8    mue_prach_control    activate    8
#    CUDU_L2 Send Action To GNB    1-8    ul_sinr    activate    3
    Start Gnb BIP Log
#    Start Ttitrace With Streaming Mode
    Run Keyword And Ignore Error    SA 5G Attach    1-2
    Run Keyword And Ignore Error    SA 5G Attach    3-4
    Run Keyword And Ignore Error    SA 5G Attach    5-6
    Run Keyword And Ignore Error    SA 5G Attach    7-8
    Sleep    2s
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}
#    Stop Ttitrace    ${TEST_LOG_DIRECTORY}
#    Decode Ttitrace Log    ${TEST_LOG_DIRECTORY}
    Setup PDU and Start Traffic for B037    8

Setup PDU and Start Traffic for B037
    [Arguments]    ${ue_num}=8
    FOR    ${ue_id}    IN RANGE    1    ${ue_num}+1
        SA Set Traffic Type To Internal    ${ue_id}    1
        Run Keyword And Ignore Error    SA 5G PDU Session Setup    ${ue_id}
        Run Keyword And Ignore Error    SA Start DL Traffic Internal    ${ue_id}    pdu_id=1    mbps=10
        Run Keyword And Ignore Error    SA Start UL Traffic Internal    ${ue_id}    pdu_id=1    mbps=5
        Sleep    2s
    END
    Wait Until Keyword Succeeds    120s    15s    Check Target Tput For MUE    1    ${ue_num}    dl    0    60

Get and Check PM Counter For CBRA for B037
    [Documentation]    RA_CB_STP_TIME: M55306C09013
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
    Log To Console    to reach next pm counter update time, need to wait ${time}...
    Sleep    ${time}    wait for pm counter file updated.
    Sleep    20s    wait pm counter file generated stable.
    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${OUTPUT_DIR}/test_pmcounter.gz
    ${ra_cb_stp_time}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55306C09013    cell_id=1
    Should Be True    "${ra_cb_stp_time}">"0"
    ${RA_MSG3_RECEP}=    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55306C06001    cell_id=1
    ${ra_average}    evaluate    ${ra_cb_stp_time}/${RA_MSG3_RECEP}
    Log To Console    ${ra_average}
    Should Be True    "${ra_average}"=="8000.0"

Get and Check PM Counter For CBRA
        ${res}    Run Keyword And Return Status    Get and Check PM Counter For CBRA for B037
        Run Keyword If    '${res}'=='False'    Deregister and Register and Check Counter for B037

Deregister and Register and Check Counter for B037
        ${cmd}    Set Variable    ue_deregister id=1-8 ue_deregister_type=switch_off
        Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command    ${cmd}
        Sleep    10s    reason=Wait for all ue dettached.
        Run Keyword And Ignore Error    SA 5G Attach    1-2
        Run Keyword And Ignore Error    SA 5G Attach    3-4
        Run Keyword And Ignore Error    SA 5G Attach    5-6
        Run Keyword And Ignore Error    SA 5G Attach    7-8
        Sleep    2s
        Get and Check PM Counter For CBRA for B037

Check Msg2 Multiplexed With Msg2 For Same RARNTI For B037
    [Arguments]       ${log_name}=5GBipL2L1_filtering_off.pcap
    ${filter}=    Set Variable    dldata_pdschsendreq && 3gpp.rnti == 15
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    3gpp.rnti    DlData_PdschGrant.rachStatus    DlData_PdschGrant.numOfPrb
    Convert BIP To CSV By MCShark    ${TEST_LOG_DIRECTORY}/${log_name}    ${TEST_LOG_DIRECTORY}/rachStatus.csv    ${filter}    ${csv_title_list}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/A2A_B037/msg2_prb.ini   ${TEST_LOG_DIRECTORY}/rachStatus.csv    ${TEST_LOG_DIRECTORY}

Set sinr_target_preamble Testmode for FDD Cell
    [Arguments]    ${profile_id}=3
    Log To Console    Setting sinr_target_preamble...
    ${cmd}    Set Variable
    ...    ul_sinr_testmode_nr profile_id=${profile_id} sinr_target_preamble=-28
    ute_wtssim.Execute Egate Command    ${cmd}

Covert BIP To Csv For B003
    ${bip_name}    Set Variable    ${TEST_LOG_DIRECTORY}/5GBipL2L1_filtering_off.pcap
    Convert BIP To CSV By MCShark    ${bip_name}    ${TEST_LOG_DIRECTORY}/${BIP_CSV_NAME}    filter=${FILTER_B003}    csv_title_list=${COLUMN_NAME}
    OperatingSystem.Copy File    ${TEST_LOG_DIRECTORY}/${BIP_CSV_NAME}    ${CURDIR}/resources/
    Sleep    2s

Trigger SIB1/OSI Multi With Msg2 For B003
    Set Suite Variable    ${Trigger_sucess_flag}    ${False}
    FOR    ${index}    IN RANGE    1    6
        Log To Console    ===============Trigger Time: ${index}==============
        Start Gnb BIP Log
        ${cmd_1}    Set Variable    ue_register id=1-20
        Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command    ${cmd_1}
        Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}
        Covert BIP To Csv For B003
        ${res}    Check Msg2 SIB1 OSI    ${CURDIR}/resources/${BIP_CSV_NAME}
        ${Trigger_sucess_flag}=    Set Variable If    '${res}'=='True'    ${True}
        ${cmd_2}    Set Variable    ue_deregister id=1-20 ue_deregister_type=switch_off
        Run Keyword If    '${res}'=='False'    Run Keyword And Ignore Error    ute_wtssim.Execute Egate Command    ${cmd_2}
        Sleep    5s    reason=Wait for all ue dettached.
        Exit For Loop If    '${res}'=='True'
    END
    Should Be True    "${Trigger_sucess_flag}"=="${True}"

Detach For B003
    ${command}    Set Variable    ue_deregister id=1-20 ue_deregister_type=switch_off
    ute_wtssim.Execute Egate Command    ${command}
    Sleep    5s    reason=make sure the cmd take affect

B003 Teardown
    Run Keyword And Ignore Error    Detach For B003
    Common Test Teardown 2

Multi UEs Attach For B14 By Script And Capture Bip Log
    [Arguments]    ${WTS_MULTI_UE}    ${sa_ue_id_begin}    ${sa_ue_id_end}
    Log To Console    start multi UEs register...
    Start Gnb BIP Log
    ute_wtssim.Execute Egate Command    cmd=script file\=${WTS_MULTI_UE} entry=start_multiue_call(${sa_ue_id_begin},${sa_ue_id_end},1,internal)
    Sleep    5s
	ute_wtssim.Execute Egate Command    cmd=ue_register id=51-100
	ute_wtssim.Execute Egate Command    cmd=ue_register id=101-150
    Sleep    90s    reason=Wait for all ue info printed in egate console log.
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}