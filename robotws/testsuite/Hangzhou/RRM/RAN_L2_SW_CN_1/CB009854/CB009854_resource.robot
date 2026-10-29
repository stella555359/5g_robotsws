*** Settings ***
Resource          ./../CUDU_L2/common_setup_teardown.robot

*** Variables ***
@{cell_id_list}    16385    16387    16388    16389    16390

*** Keywords ***
Start WTS And Check OnAir
    [Documentation]    This keyword is to start WTS, wait for onAir
    Start UTE WTS
    UE SIB Decoding
    Check All Cells Received SIB2

L3 Call For UE
    [Arguments]    ${UE_ID}    ${SCELL_info}    ${dl_mbps}    ${ul_mbps}
    SA Single UE Attach    ${UE_ID}
    Sleep    5s    reason=Wait for egate log
    Get And Check Scell Infos    ${SCELL_info}
    Start SA UE Big DL Traffic Internal    ${UE_ID}    ${dl_mbps}
    Start SA UE Big UL Traffic Internal    ${UE_ID}    ${ul_mbps}
    Sleep    10s    reason=Wait for traffic stable
	
Online Modify NIDD
    [Arguments]    ${json_path}
    ${json_file}=    Change Delta XML File To Delta Json File    ${json_path}
    Delta Commission With SCF File    ${json_file}

Check UL And DL DTX From Ttitrace	
    [Arguments]    ${log_id}    ${duration}
    CUDU_L2 Capture And Decode TTitrace    ${log_id}    ${duration}
    CUDU_L2 Check DTXNACK Rate    ${log_id}
    CUDU_L2 Check UL DTXCRC Rate    ${log_id}

Check Common Srsreceivereq
    [Arguments]    ${log_id}
    Convert BIP To CSV By MCShark For UlData_SrsReceiveReq    ${log_id}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_srsreceivereq.ini    ${LOG_PATH}/csv_Srsreceivereq.csv   

trigger A2 Release For Scells
    Trigger A2 Scell Release    ${UE3_ID}    4    20    56    5
    Trigger A2 Scell Release    ${UE3_ID}    3    20    54    4
    Trigger A2 Scell Release    ${UE3_ID}    2    20    52    3
    Trigger A2 Scell Release    ${UE3_ID}    1    20    51    2
	
Common log check for Srs
    [Arguments]    ${log_id}    
    Start Gnb BIP Log
    Sleep    1s
    Stop Gnb BIP Log    ${OUTPUT_DIR}/BIP/${log_id}
    Check Common Srsreceivereq    ${log_id}

Common log check for No Srs
    [Arguments]    ${log_id} 
    Start Gnb BIP Log
    Sleep    1s
    Stop Gnb BIP Log    ${OUTPUT_DIR}/BIP/${log_id}
    Check No Srsreceivereq    ${log_id}  

Check No Srsreceivereq
    [Arguments]    ${log_id}
    Convert BIP To CSV By MCShark For UlData_SrsReceiveReq    ${log_id}
    ${sfn_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${LOG_PATH}/csv_Srsreceivereq.csv    3gpp.sfn    ["1025", ""]    except    no
    ${count}    Get Length    ${sfn_list}
    should be equal as numbers   ${count}    0	
	
Convert BIP To CSV By MCShark For UlData_SrsReceiveReq
    [Arguments]    ${log_id}
    ${filter}=    Set Variable    uldata_srsreceivereq
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    UlData_srsBmResource_t.srsResourceIdentity
    Convert BIP To CSV By MCShark    ${OUTPUT_DIR}/BIP/${log_id}/5GBipL2L1_filtering_off.pcap
    ...    ${LOG_PATH}/csv_Srsreceivereq.csv    ${filter}    ${csv_title_list}
	
Check Bip For Csi Multiplexing On Pusch
    [Arguments]    ${log_id}    
    Start Gnb BIP Log
    Sleep    2s
    Stop Gnb BIP Log    ${OUTPUT_DIR}/BIP/${log_id}
    Check D005 Ucibits    ${log_id}
	
Check D005 Ucibits
    [Arguments]    ${log_id}
    Convert BIP To CSV By MCShark For UlData_PuschReceiveReq    ${log_id}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/pusch_uci.ini    ${LOG_PATH}/pusch.csv
	
Convert BIP To CSV By MCShark For UlData_PuschReceiveReq
    [Arguments]    ${log_id}
    ${filter}=    Set Variable    uldata_puschreceivereq
    @{csv_title_list}=    Create List    3gpp.slot    UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits    3gpp.dmrsScramblingSequenceInt
    Convert BIP To CSV By MCShark    ${OUTPUT_DIR}/BIP/${log_id}/5GBipL2L1_filtering_off.pcap
    ...    ${LOG_PATH}/pusch.csv    ${filter}    ${csv_title_list}

Send Ri0 And Beam switch Then Check Bip
    [Arguments]    ${log_id}
    Set CQI Testmode    12    15    fixed    1    15    0       
    CUDU L2 Send Action To GNB    3    csi_override    activate    12    2 
    Sleep    2s    reason=Wait for ri stable
    Beam Switch For UE 
    Sleep    2s    reason=Wait for beam switch stable
    Start Gnb BIP Log
    Sleep    2s
    Stop Gnb BIP Log    ${OUTPUT_DIR}/BIP/${log_id}
    Check Beam1 And Ri0    ${log_id} 

Check Beam1 And Ri0
    [Arguments]    ${log_id}
    Check Bip For Beam Switch    ${log_id}
    Check Bip For Ri0    ${log_id}
	
Check Bip For Beam Switch
    [Arguments]    ${log_id}
    Convert BIP To CSV By MCShark For DlData_PdcchSendReq    ${log_id}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/switch.ini    ${LOG_PATH}/pdcch.csv	

Check Bip For Ri0
    [Arguments]    ${log_id}
    Convert BIP To CSV By MCShark For DlData_PdschSendReq    ${log_id}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/layer1.ini    ${LOG_PATH}/pdsch.csv	
	
Convert BIP To CSV By MCShark For DlData_PdcchSendReq
    [Arguments]    ${log_id}
    ${filter}=    Set Variable    dldata_pdcchsendreq
    @{csv_title_list}=    Create List    DlData_PdcchSendReq_t.beamId    3gpp.dmrsScramblingSequenceInt
    Convert BIP To CSV By MCShark    ${OUTPUT_DIR}/BIP/${log_id}/5GBipL2L1_filtering_off.pcap
    ...    ${LOG_PATH}/pdcch.csv    ${filter}    ${csv_title_list}

Convert BIP To CSV By MCShark For DlData_PdschSendReq
    [Arguments]    ${log_id}
    ${filter}=    Set Variable    dldata_pdschsendreq
    @{csv_title_list}=    Create List    DlData_PdschGrant.numOfLayers    3gpp.dmrsScramblingSequenceInt
    Convert BIP To CSV By MCShark    ${OUTPUT_DIR}/BIP/${log_id}/5GBipL2L1_filtering_off.pcap
    ...    ${LOG_PATH}/pdsch.csv    ${filter}    ${csv_title_list}

Send Ri3 And Check Csi On Pucch
    [Arguments]    ${log_id}
    Set CQI Testmode    13    15    fixed    1    15    3
    CUDU L2 Send Action To GNB    3    csi_override    activate    13    2
    Start Gnb BIP Log
    Sleep    3s
    Stop Gnb BIP Log    ${OUTPUT_DIR}/BIP/${log_id}
    Check Ri3 And Ucibits    ${log_id}
	
Check Ri3 And Ucibits
    [Arguments]    ${log_id}
    Convert BIP To CSV By MCShark For UlData_PucchReceiveReq    ${log_id}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/pucch_uci.ini    ${LOG_PATH}/pucch.csv	
    Convert BIP To CSV By MCShark For DlData_PdschSendReq    ${log_id}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/layer3.ini    ${LOG_PATH}/pdsch.csv	

Convert BIP To CSV By MCShark For UlData_PucchReceiveReq
    [Arguments]    ${log_id}
    ${filter}=    Set Variable    uldata_pucchreceivereq
    @{csv_title_list}=    Create List    3gpp.slot    UlData_pucchReceiveReqPucchResource_t.numOfBitsOfUciInformation    
    ...    3gpp.dmrsScramblingSequenceInt    UlData_pucchReceiveReqPucchResource_t.nANPucch
    Convert BIP To CSV By MCShark    ${OUTPUT_DIR}/BIP/${log_id}/5GBipL2L1_filtering_off.pcap
    ...    ${LOG_PATH}/pucch.csv    ${filter}    ${csv_title_list}

Check NumOfUciCsiPart1Bits On Specific Scell
    [Arguments]    ${log_id}    ${physcellid}    ${expectucibits}
    Log To Console    Check NumOfUciCsiPart1Bits
    @{ucibits}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_dl.csv
    ...    source_column_name1=csiSrReportData.csiOnPuschMeas.numOfUciCsiPart1Bits    source_column_name2=physCellId
    ...    condition1=["0", "", "7", "0.0"]    operation1=except    condition2=${physcellid}    operation2=include
    ...    target_column_name=csiSrReportData.csiOnPuschMeas.numOfUciCsiPart1Bits    remove_duplicate=no
    Should Be True    ${ucibits}[0]==${expectucibits}

Check ULchannel On Specific Scell
    [Arguments]    ${log_id}    ${physcellid}    ${expectulchannel}
    Log To Console    Check ulchannel
    @{ulchannel}=    filter_2source_column_return_other    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}/output_dl.csv
    ...    csiSrReportData.csiOnPuschMeas.numOfUciCsiPart1Bits    physCellId    ["0", "", "7"]
    ...    except    ${physcellid}    include    csiSrReportData.ulChannel    no
    Should Be True    "${ulchannel}[0]"=="${expectulchannel}"

Check EXITDRX In TTitrace
    [Arguments]    ${log_id}
    Sleep    10s    reason=Wait for step stable
    CUDU L2 Capture And Decode TTitrace    ${log_id}
    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_DRX.ini    output_ul.csv    ${TEST_LOG_DIRECTORY}/ttitrace/${log_id}

Check NumOfUciCsiPart1Bits For D006
    [Arguments]    ${log_id}
    Check NumOfUciCsiPart1Bits On Specific Scell    ${log_id}    physcellid=54    expectucibits=30
    Check NumOfUciCsiPart1Bits On Specific Scell    ${log_id}    physcellid=55    expectucibits=22
    Check NumOfUciCsiPart1Bits On Specific Scell    ${log_id}    physcellid=56    expectucibits=26

Check Cell Throughput
    Sleep    10s    reason=Wait for traffic stable
    ${tp_syslog}=    Get Cell Throughput From Btslog    10s
    Check Cell Throughput For CB009854    ${tp_syslog}    16387    dl    70
    Check Cell Throughput For CB009854    ${tp_syslog}    16385    dl    70
    Check Cell Throughput For CB009854    ${tp_syslog}    16388    dl    115
    Check Cell Throughput For CB009854    ${tp_syslog}    16389    dl    95
    Check Cell Throughput For CB009854    ${tp_syslog}    16390    dl    55

Check Whether UE In CA Mode
    [Arguments]    ${UE_ID}=1    ${ca_num}=1    ${type}=pdsch
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data     cmd=ue_stats_nr id\=${UE_ID} type=${type} scell=0-31    pass_regexp=EGATE
    Log    ${output}
    Should Contain X Times    ${output}    CellIndex-    ${ca_num}   msg=UE is not in ${ca_num} CC mode
	
Check Cell Throughput For CB009854
    [Arguments]    ${tp_list}    ${cell_id}    ${direction}    ${target_tp}    ${aver_ratio}=${0.95}    ${min_ratio}=${0.85}
    [Documentation]    Check Throughput Quality from keyword "Get Cell Throughput From Btslog"
    ...    | Input Parameters | Man. | Description |
    ...    | ${tp_list} | YES | return value from keyword "Get Throughput From Bts" |
    ...    | ${cell_id} | YES | cell id|
    ...    | ${direction} | YES | dl/ul|
    Should Be True    ${tp_list}[${direction}][${cell_id}][ave]>${target_tp}*${aver_ratio}    Syslog average TP is lower than Target
	
Check Throughput For CB009854
    [Arguments]    ${dl_tp}=0    ${target_tp}=550    ${aver_ratio}=${0.95}
    Sleep    10s    reason=Wait for traffic stable
    ${tp_list}=    Get Cell Throughput From Btslog    10s
    FOR    ${cell_id}  IN  @{cell_id_list}
        ${dl_tp}=    Evaluate    ${tp_list}[dl][${cell_id}][ave]+${dl_tp}
    END
    Should Be True    ${dl_tp}>${target_tp}*${aver_ratio}

Set Value For BLER Testmode
    [Arguments]    ${profile_id}=31    ${dl_bler}=1000,1000,1000,1000,1000,1000,1000,0
    Log To Console    Set Value For BLER Testmode...
    ${cmd}    Set Variable    bler_testmode_nr profile_id=${profile_id} dl_bler=${dl_bler}
    ute_wtssim.Execute Egate Command    ${cmd}
