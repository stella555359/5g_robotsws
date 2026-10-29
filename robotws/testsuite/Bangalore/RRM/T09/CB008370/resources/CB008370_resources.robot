*** Settings ***
Documentation   8379 Keyword file

Resource         ../../../../resources/robot/Airphone.robot
#Resource         ../../resources/robot

Resource         ../../../../resources/robot/PM_Counters.robot
Resource         ../../../../resources/robot/wts_sim_keywords.robot
Resource         ../../CB008278/resources/common_CA.robot
Resource         ../../../../resources/robot/common_log_collection.robot
Resource         ../../5GC000937/resources/5GC000937_Keywords.robot
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../../../resources/robot/Setup_Env.robot
Library          ../../../../resources/python/BIP_Capture.py
Library          ../../../../resources/python/CPRT_Capture.py
Library          ../../../../resources/python/avg_dl_data.py
Library          OperatingSystem
Library          ./verify_rrcSetup_TDRA.py
Library          verify_SLIV_TTI_slots.py
Library          taf.sw.scout    WITH NAME     scout
Library          DateTime


*** Variables ***
${FILTER_B003}                 dldata_pdschsendreql1sw&&3gpp.subcellid==0
${FILTER_B004}                 dldata_pdcchsendreql1sw&&3gpp.subcellid==0
@{COLUMN_NAME}                 3gpp.sfn    3gpp.slot      3gpp.rnti     DlData_PdschGrantL1sw.startSymbol    DlData_PdschGrantL1sw.numOfPdschSymbols
...                            DlData_PdschGrantL1sw.numOfPrb    DlData_PdschGrantL1sw.startPrb      DlData_PdschGrantL1sw.rateMatchingOption
...                            DlData_PdschGrantL1sw.numRateMatchingRes
@{COLUMN_NAME_DCI}             3gpp.sfn    3gpp.slot      3gpp.rnti     DlData_PdcchSendReq_tL1sw.startDciIndex
...                            DlData_DciInfoL1sw.startSymbolNumber     DlData_DciInfoL1sw.numOfSymbols    DlData_DciInfoL1sw.aggregationLevel
${BIP_CSV_NAME}                BIP_L1L2.pcap_filter_SCN1.csv

*** Keywords ***
Collect TTI and decode
    [Arguments]       ${LOG_PATH}
    log to console     collecting TTI traces
    Start Ttitrace With Streaming Mode_2
    Sleep    3s    reason=get *L2TtiTrace_EventsSnapshot
    Stop Ttitrace
    Convert Ttitrace From Pcap To Excelcsv     ${LOG_PATH}/ttitrace_streaming/
    5GC000937_Keywords.Convert Tti To CSV Mode    ${LOG_PATH}/ttitrace_streaming/

Collect TTI trace and check PDSCH SLIVs present
    [Arguments]       ${LOG_PATH}    ${SLIV_numbers}    ${PCI}=${50}
    Collect TTI and decode      ${LOG_PATH}
    ${result}=   Check Numbers Found   ${LOG_PATH}/ttitrace_streaming/output_dl_formated.csv   ${SLIV_numbers}   ${PCI}

Collect TTI trace and check 8370_PDSCH SLIVs present in PCell and Scell
    [Arguments]       ${LOG_PATH}    ${SLIV_numbers}  ${PCell_PCI}  ${SCell_PCI}
    Collect TTI and decode      ${LOG_PATH}
    ${Pcell_check_result}=   Check Numbers Found   ${LOG_PATH}/ttitrace_streaming/output_dl_formated.csv   ${SLIV_numbers}  ${PCell_PCI}
    ${Scell_check_result}=   Check Numbers Found   ${LOG_PATH}/ttitrace_streaming/output_dl_formated.csv   ${SLIV_numbers}  ${SCell_PCI}
Check Numbers Found
    [Arguments]     ${csv_file}    ${numbers}    ${Phy_id}
    ${PDCCH_Symbol_shared_check}    check_numbers_in_sliv    ${csv_file}   ${numbers}   ${Phy_id}
    Run Keyword if   ${PDCCH_Symbol_shared_check}!=${True}   fail    No symbols shared
Start Multi UE DL traffic with multiple trafficID
    [Arguments]   ${start_ue}   ${end_ue}    ${dl_trf_id}    ${qfi_id}
    FOR   ${TRF_ID}  IN RANGE   1    ${dl_trf_id}+1
        wts_sim_keywords.MultiUE Trigger DL Traffic for SA    ${start_ue}   ${end_ue}  Traffic_rate=mbps     dl_rate=175    pdu_id=1
        ...    trf_id=${TRF_ID}    qfi_id=${qfi_id}
        sleep    2s
    END
Start Multi UE UL traffic with multiple trafficID
    [Arguments]   ${start_ue}   ${end_ue}    ${ul_trf_id}    ${qfi_id}
    FOR   ${TRF_ID}  IN RANGE   1    ${ul_trf_id}+1
        wts_sim_keywords.MultiUE Trigger UL Traffic for SA    ${start_ue}   ${end_ue}  Traffic_rate=mbps     ul_rate=175    pdu_id=1
        ...    trf_id=${TRF_ID}    qfi_id=${qfi_id}
        sleep    2s
    END

Start Multi UE DL and UL traffic with multiple trafficID
    [Arguments]   ${start_ue}   ${end_ue}    ${dl_trf_id}    ${ul_trf_id}    ${qfi_id}
    Start Multi UE DL traffic with multiple trafficID   start_ue=${start_ue}   end_ue=${end_ue}    dl_trf_id=${dl_trf_id}    qfi_id=${qfi_id}
    Start Multi UE UL traffic with multiple trafficID   start_ue=${start_ue}   end_ue=${end_ue}    ul_trf_id=${ul_trf_id}    qfi_id=${qfi_id}

Intiate Bler for Ues and activate with pktloss
    [Arguments]    ${startue}    ${endue}    ${pkt_loss}
    ${profile}	   SET VARIABLE
    ...   bler_testmode_nr profile_id=1 dl_bler=${pkt_loss},${pkt_loss},${pkt_loss},${pkt_loss},${pkt_loss},${pkt_loss},${pkt_loss},${pkt_loss}
    ute_wtssim.execute_egate_command    ${profile}
    FOR     ${ue_idx}   IN RANGE    ${startue}    ${endue}+1
    ${activate}	   SET VARIABLE    ue_testmode_set_nr id=${ue_idx} testmode=bler profile_id=1 action=activate
    ute_wtssim.execute_egate_command    ${activate}
    END

Deactivate Bler for Ues
    [Arguments]    ${startue}    ${endue}
    FOR     ${ue_idx}   IN RANGE    ${startue}    ${endue}+1
    ${deactivate}	   SET VARIABLE    ue_testmode_set_nr id=${ue_idx} testmode=bler profile_id=1 action=deactivate
    ute_wtssim.execute_egate_command    ${deactivate}
    END

Get DL Throughput for Pcell
	[Arguments]    ${UE_ID}=1    ${end_UE_ID}=1    ${scell}=0      ${expected_thp}=700
    ${output}=    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=${UE_ID}-${end_UE_ID} scell=${scell} type=pdsch
    ...     pass_regexp=NR PDSCH Throughput      timeout=5
    log to console   DL Troughput is ${output}    console=True
    Sleep    5s
    ${output}=    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=${UE_ID}-${end_UE_ID} scell=${scell} type=pdsch
    ...        pass_regexp=NR PDSCH Throughput     timeout=5
    log to console   DL Troughput is ${output}    console=True
    ${pcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
    log to console   DL Troughput is ${pcell_tp}
    Should Be True    ${pcell_tp} > ${expected_thp}
    [Return]    ${pcell_tp}

Get UL Throughput for Pcell
	[Arguments]    ${UE_ID}=1    ${end_UE_ID}=1    ${scell}=0      ${expected_thp}=170
    ${output}=    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=${UE_ID}-${end_UE_ID} scell=${scell} type=pusch
    ...      pass_regexp=NR PUSCH Throughput       timeout=5
    log to console   UL Troughput is ${output}    console=True
    Sleep    5s
    ${output}=    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=${UE_ID}-${end_UE_ID} scell=${scell} type=pusch
    ...      pass_regexp=NR PUSCH Throughput        timeout=5
    log to console   UL Troughput is ${output}    console=True
    ${pcell_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
    log to console   UL Troughput is ${pcell_tp}
    Should Be True    ${pcell_tp} > ${expected_thp}

Get DL Throughput for 4CC
	[Arguments]    ${UE_ID}=1    ${scell}=0
    BuiltIn.log   ${UE_ID}   ${scell}
    ${output}=    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=1 scell=0,1,2,3    pass_regexp=NR PDSCH Throughput
    ...                     timeout=8
    log to console   DL Troughput is ${output}    console=True
    Sleep    5s
    ${output}=    ute_wtssim.Execute Egate Command    cmd=ue_stats_nr id=1 scell=0,1,2,3    pass_regexp=NR PDSCH Throughput
    ...                     timeout=8
    log to console   DL Troughput is ${output}    console=True


UE Register should be Successful And Fetch RNTI and TDRA list
    [Arguments]    ${ue_id}     ${pdu_id}=${Pdu_session_ID}     ${nw_id}=${nwslice_ID}      ${gw_id}=${gw_ID}    ${8370_flag}=0
    [Documentation]    This keyword checks the message for the completion of UE registration in the output file for the SA variant
    ${CurDate}    Get Current Date    result_format=%H%M%S
    ${ue_reg_cmd}	SET VARIABLE	ue_register id=${ue_id}
	${set_pdu_param_cmd}	SET VARIABLE	set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ${pdu_setup_cmd}	SET VARIABLE	ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=${nw_id} gw=${gw_id}
	ute_wtssim.Execute Egate Command    ${set_pdu_param_cmd}    timeout=${EGATE_COMMAND_TIMEOUT}
    ${output}		ute_wtssim.Execute Egate Command And Wait For Data  ${ue_reg_cmd}   pass_regexp=${UE_reg_complete_pattern}
    ...     timeout=${EGATE_COMMAND_TIMEOUT}
	Create File     ${OUTPUT_DIR}/Attach.txt     ${output}
	verify_rrcSetup_TDRA.check_rrcsetup_msg_tdra    ${OUTPUT_DIR}/Attach.txt   ${CurDate}
    ute_wtssim.Execute Egate Command And Wait For Data  ${pdu_setup_cmd}
	...		pass_regexp=(\?\:${PDU_session_resource_setup_response}|${Initial_context_setup_pattern})        timeout=${EGATE_COMMAND_TIMEOUT}
	Create File     ${OUTPUT_DIR}/regst.txt     ${output}
    ${crnti_value}=    Run     cat ${OUTPUT_DIR}/regst.txt |grep -i crnti |awk -F 'crnti:' '{print $2}'|cut -d ' ' -f 2
	BuiltIn.Log     ${crnti_value}
	Log to Console             ue_register_is_ok with ${crnti_value}
	${resp_value}    verify_rrcSetup_TDRA.validate_tdra     RrcSetup_MSG_${CurDate}1.txt    ${8370_flag}
    Run Keyword IF   ${resp_value}!=${True}   Fail   SLIV not matching
    ...    ELSE    log to console     SLIV matching
	[Return]      ${crnti_value}

Stop data traffic for Ues
    [Arguments]   ${start_ue}   ${end_ue}     ${step}
    FOR   ${Ues}  IN RANGE   ${start_ue}    ${end_ue}    ${step}
        wts_sim_keywords.Multiue DL TRF Data Stop for SA     ${Ues}   ${end_ue}
        wts_sim_keywords.Multiue UL TRF Data Stop for SA     ${Ues}   ${end_ue}
    END

Deregister ALL Ues
    [Arguments]   ${start_ue}   ${end_ue}
    wts_sim_keywords.MultiUE Deregister should be Successful     ${start_ue}    ${end_ue}

Collect Legacy Counters
    [Documentation]      This KW will collect 2 legacy counters
    ...                  M55308C03001 - PDSCH_OFDM_SYMBOLS     and
    ...                  M55308C03005 - PDSCH_OFDM_SYMBOLS_TIME
    [Arguments]       ${nrcell}=NRCELL-1

    Wait until the next Measurement Period starts
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${Cell1_C1}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C03001    moc=${nrcell}
    ${Cell1_C2}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C03005    moc=${nrcell}
    log to console       ${Cell1_C1}      ${Cell1_C2}
    [Return]    ${Cell1_C1}      ${Cell1_C2}

Collect Legacy and New Counters
    [Documentation]      This KW will collect 2 legacy counters and 2 new counters introduced as part of CB008370
    ...                  M55335C02019 - NUM_1_PDCCH_SYMB_SHARE_PDSCH (Number of slots where one PDCCH symbol is shared with PDSCH)
    ...                  M55335C02020 - NUM_2_PDCCH_SYMB_SHARE_PDSCH  (Number of slots where two PDCCH symbols are shared with PDSCH)
    [Arguments]   ${nrcell}=NRCELL-1
    ${Cell1_C1}      ${Cell1_C2}      Collect Legacy Counters    ${nrcell}
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${Cell1_C3}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55335C02019    moc=${nrcell}
    ${Cell1_C4}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55335C02020    moc=${nrcell}
    log to console       ${Cell1_C1}      ${Cell1_C2}
    log to console       ${Cell1_C3}      ${Cell1_C4}
    [Return]    ${Cell1_C1}      ${Cell1_C2}    ${Cell1_C3}      ${Cell1_C4}
Collect Legacy Counters Pcell Scell
    [Documentation]      This KW will collect 2 legacy counters in case of CA
    ...                  M55308C03001 - PDSCH_OFDM_SYMBOLS     and
    ...                  M55308C03005 - PDSCH_OFDM_SYMBOLS_TIME
    [Arguments]       ${Pcell}   ${Scell}
    Wait until the next Measurement Period starts
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${Pcell_C1}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C03001    moc=${Pcell}
    ${Pcell_C2}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C03005    moc=${Pcell}
    ${Scell_C1}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C03001    moc=${Scell}
    ${Scell_C2}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55308C03005    moc=${Scell}
    log to console     ${Pcell_C1} ${Pcell_C2} ${Scell_C1} ${Scell_C2}
    [Return]    ${Pcell_C1}      ${Pcell_C2}    ${Scell_C1}    ${Scell_C2}
Collect Legacy and New Counters Pcell Scell
    [Documentation]      This KW will collect 2 legacy counters and 2 new counters introduced as part of CB008370 in case of CA
    ...                  M55335C02019 - NUM_1_PDCCH_SYMB_SHARE_PDSCH (Number of slots where one PDCCH symbol is shared with PDSCH)
    ...                  M55335C02020 - NUM_2_PDCCH_SYMB_SHARE_PDSCH  (Number of slots where two PDCCH symbols are shared with PDSCH)
    [Arguments]   ${Pcell}   ${Scell}
    ${Pcell_C1}      ${Pcell_C2}    ${Scell_C1}    ${Scell_C2}      Collect Legacy Counters Pcell Scell   ${Pcell}   ${Scell}
    ${PM_dir1}     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    ${Pcell_C3}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55335C02019    moc=${Pcell}
    ${Pcell_C4}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55335C02020    moc=${Pcell}
    ${Scell_C3}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55335C02019    moc=${Scell}
    ${Scell_C4}    Get PM counter value    pm_files_location=${PM_dir1}    pi_id=M55335C02020    moc=${Scell}
    log to console       ${Pcell_C1} ${Pcell_C2} ${Scell_C1} ${Scell_C2}
    log to console       ${Pcell_C3} ${Pcell_C4} ${Scell_C3} ${Scell_C4}
    [Return]    ${Pcell_C1}    ${Pcell_C2}    ${Scell_C1}    ${Scell_C2}    ${Pcell_C3}    ${Pcell_C4}    ${Scell_C3}    ${Scell_C4}
Collect BIP and decode
    [Arguments]    ${test_scenario}    ${filter}=${FILTER_B003}    ${column_name}=${COLUMN_NAME}
    log to console      ${SW_VERSION_TOTAL}
    ${SW_VERSION_TOTAL}  Set Variable      ${GNB_SW_VERSION}
    Set Suite Variable    ${SW_VERSION_TOTAL}
    Start log  biptaf
    sleep    200ms
    ${path_SCN_1}   Stop log   biptaf    test_scenario=${test_scenario}
    Convert BIP To CSV By MCShark    ${path_SCN_1}[biptaf]/BIP_L1L2.pcap    ${path_SCN_1}[biptaf]/${BIP_CSV_NAME}
    ...                              filter=${filter}    csv_title_list=${column_name}
    Set Suite Variable    ${path_SCN_1}

Start DL Data and validate Paging is successful
    ${paging_cmd}	SET VARIABLE	amf_paging_start id=1 ue=1
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data    cmd=${paging_cmd}
    ...        pass_regexp=Initial Context Setup Successful for UE     timeout=10
    ${output2}         Get Lines Matching Regexp    ${output}
    ...    establishmentCause mt-Access    partial_match=${TRUE}
    ${output2}         Get Lines Matching Regexp    ${output}
    ...    Initial Context Setup Successful for UE    partial_match=${TRUE}
    Log to Console    Paging successful UE moved back to RRC_CONNECTED state
