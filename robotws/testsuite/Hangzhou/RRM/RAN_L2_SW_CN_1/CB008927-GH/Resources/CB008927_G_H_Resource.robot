*** Settings ***


*** Variables ***
${SLEEP_TIMER}        5s   

*** Keywords ***
Check Non CA UE DL UL Tput With In Range
    [Arguments]    ${start_ue_num}    ${stop_ue_num}    ${dl_tput}    ${ul_tput}    ${threshold}
    FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
	    ${dl_tp}=    Get CA Cell Average Throughput    ue_id=${ue_id}    dir=dl    cell_type=pcell    scell_index=0
	    ${ul_tp}=    Get CA Cell Average Throughput    ue_id=${ue_id}    dir=ul    cell_type=pcell    scell_index=0
	    Log To Console    DL Troughput is ${dl_tp}
	    Log To Console    UL Troughput is ${ul_tp}
	    ${dl_thres}    Evaluate    abs(${dl_tp}-${dl_tput})/${dl_tput}
	    Should Be True    ${dl_thres}<${threshold}
	    ${ul_thres}    Evaluate    abs(${ul_tp}-${ul_tput})/${ul_tput}
	    Should Be True    ${ul_thres}<${threshold}
    END

SA NoncaUE Attach AND PDU Session Setup
    [Arguments]    ${start_ue_num}    ${stop_ue_num}   ${pdu_id}    ${nwslice}=1
    FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
        Log To Console    UE${ue_id} Start Attach...
        SA Set Traffic Type To Internal    ue_id=${ue_id}    pdu_id=${pdu_id}
        SA 5G Attach    ue_id=${ue_id}
        ${output}    SA 5G NonGBR AND VONR PDU Session Setup    ${ue_id}    pdu_id=${pdu_id}    nwslice=${nwslice}
        [Return]    ${output}
    END

SA 5G NonGBR AND VONR PDU Session Setup
    [Arguments]    ${ue_id}    ${pdu_id}    ${nwslice}
    Log To Console    start 5G NonGBR AND VONR PDU Session Setup...
    ${command}    Set Variable    ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=${nwslice} gw=${ue_id}
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Initial Context Setup Successful    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}	

NonGBR To GBR OR Vonr
    [Arguments]    ${start_ue_num}    ${stop_ue_num}    ${pdu_id}    ${qosflows_to_add}
    FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
        Change NonGBR TO GBR OR Vonr    ${ue_id}    ${pdu_id}    ${qosflows_to_add}
    END

Change NonGBR TO GBR OR Vonr
    [Arguments]    ${ue_id}    ${pdu_id}    ${qosflows_to_add}
    Log To Console    Change NonGBR to GBR or VONR...
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=${pdu_id} qosflows_to_add=${qosflows_to_add} by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP    timeout=1minutes
    Sleep    ${SLEEP_TIMER}    reason=wait GBR or VONR is stable

SA Start NONGBR OR GBR OR VONR DLUL Traffic 
    [Arguments]    ${start_ue_num}    ${stop_ue_num}   ${pdu_id}=1    ${trf_id}=1    ${qfi_id}=1
    FOR    ${ue_id}    IN RANGE    ${start_ue_num}    ${stop_ue_num}+1
        SA DL Traffic Internal    ${ue_id}    ${pdu_id}    ${DL_DATA}    ${trf_id}    ${qfi_id}
        SA UL Traffic Internal    ${ue_id}    ${pdu_id}    ${UL_DATA}    ${trf_id}    ${qfi_id}
    END

SA DL Traffic Internal
    [Arguments]    ${ue_id}    ${pdu_id}    ${mbps}    ${trf_id}    ${qfi_id}
    Log To Console    UE${ue_id} start DL ${mbps}M traffic...
    ${times}    Evaluate    int(${mbps}/${175})
    Run Keyword If    ${times}==${0} or '${mbps}'=='175'     ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi_id} dir=dl mbps\=${mbps} trf_id\=${trf_id}
    ...    ELSE    Start SA UE Big DL Traffic Internal    ${ue_id}    ${mbps}    ${pdu_id}    ${trf_id}    ${qfi_id}
    Sleep    ${SLEEP_TIMER}    reason=wait DL traffic is stable
    ${command}    Set Variable    ue_stats_nr id=${ue_id} type=pdsch scell=primary,secondary
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=NR PDSCH Throughput    timeout=1minutes

SA UL Traffic Internal
    [Arguments]    ${ue_id}    ${pdu_id}    ${mbps}    ${trf_id}    ${qfi_id}
    Log To Console    \nStart UE${ue_id} UL ${mbps}M traffic...
    ${times}    Evaluate    int(${mbps}/${175})
    Run Keyword If    ${times}==${0} or '${mbps}'=='175'     ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} qfi\=${qfi_id} dir=ul mbps\=${mbps} trf_id\=${trf_id}
    ...    ELSE    Start SA UE Big UL Traffic Internal    ${ue_id}    ${mbps}    ${pdu_id}    ${trf_id}    ${qfi_id}
    Sleep    ${SLEEP_TIMER}    reason=wait UL traffic is stable
    ${command}    Set Variable    ue_stats_nr id=${ue_id} type=pusch scell=primary,secondary
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}    pass_regexp=NR PUSCH Throughput    timeout=1minutes

Capture And Covert BIP To Csv
    [Arguments]    ${FILTER}    ${COLUMN_NAME}
    Sleep    1s    reason=Wait For Transmission Stable
    Start Gnb BIP Log
    Sleep    3s    reason=Capture BIP log
    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}
    ${bip_name}    Set Variable    ${TEST_LOG_DIRECTORY}/5GBipL2L1_filtering_off.pcap
    Convert BIP To CSV By MCShark    ${bip_name}    ${TEST_LOG_DIRECTORY}/5GBipL2L1_filtering_off.csv    filter=${FILTER}
    ...        csv_title_list=${COLUMN_NAME}

Setup Multi UE GBR And Start DL UL Traffic
    [Arguments]    ${ue_list}    ${qosflows}    ${qfi_id}    ${dldata}    ${uldata}
    FOR    	${ue_id}     IN ZIP    ${ue_list} 
	    ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
        sleep    1s    reason=wait RAB setup
        ute_wtssim.Execute Egate Command    cmd=ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=${qosflows} by=amf
        sleep    1s    reason=wait RAB setup
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=${qfi_id} dir=dl mbps=${dldata} trf_id=1 seconds=6000
        sleep    1s    reason=wait RAB setup
        ute_wtssim.Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=${qfi_id} dir=ul mbps=${uldata} trf_id=1 seconds=6000	    
	END
	
Override The MCS
    [Arguments]    ${profile_id}    ${mcs}
    ute_wtssim.Execute Egate Command    cmd=bler_testmode_nr profile_id\=${profile_id} target_mcs\=${mcs}
	
Delete The MCS Override
    [Arguments]    ${profile_id}
    ute_wtssim.Execute Egate Command    cmd=bler_testmode_nr profile_id\=${profile_id} delete=on

Multi UE Testmode Change Action
    [Arguments]    ${ue_list}    ${testmode}    ${action}    ${profile_id}=1
    FOR    	${ue_id}     IN ZIP    ${ue_list}
          CUDU L2 Send Action To GNB    ${ue_id}    ${testmode}    ${action}    ${profile_id}
    END