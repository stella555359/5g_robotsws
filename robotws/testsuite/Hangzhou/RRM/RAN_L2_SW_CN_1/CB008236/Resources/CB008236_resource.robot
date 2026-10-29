*** Settings ***
Library      ../../python/ta_kiss_gnb/    WITH NAME    ta_kiss_gnb
Resource    ./../../CUDU_L2/common_setup_teardown.robot

*** Keywords ***
Adjust Sinr Target Pathloss
    [Arguments]    ${ue_id}=1    ${sinr_target_pathloss}=130    ${pusch_type}=typeB
    ute_wtssim.Execute Egate Command
    ...    cmd=ul_sinr_testmode_nr profile_id=1 pathloss=${sinr_target_pathloss}
    ${command}    Set Variable    ue_testmode_set_nr id\=${ue_id} testmode=ul_sinr action=activate profile_id=1
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=rrc-TransactionIdentifier \\d+,\\s+\\S+ rrcReconfigurationComplete
    ...    timeout=3minutes
    Check Rel16 TDRA Table From Output    ${output}    ${pusch_type}

Deactive Pathloss
    [Arguments]    ${ue_id}=1    ${profile_id}=1
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_testmode_set_nr id\=${ue_id} testmode=ul_sinr action=deactivate profile_id=${profile_id}

Modify PDU Session with VONR
    [Arguments]    ${ue_id}    ${vonr_drx}=${False}
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
    ${output_0}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=3minutes
    ${qfi_5qi_5}    Get QFI for 5QI setup    ${output_0}    5
    Log To Console    ${output_0}
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf
    ${output_1}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=3minutes
    Run Keyword If    ${vonr_drx}    String.Get Lines Matching Regexp    ${output_1}    drx-Config setup    partial_match=${true}
    ${qfi_5qi_1}    Get QFI for 5QI setup    ${output_1}    1
    Log To Console    ${output_1}
    [Return]    ${qfi_5qi_5}    ${qfi_5qi_1}

Get QFI for 5QI setup
    [Arguments]    ${content}    ${5QI_id}
    ${qosflow_added}    Set Variable    Added QosFlow with QFI:(\\d) 5QI:${5QI_id} SEID:\\d+
    ${qfi_id}    String.Get Regexp Matches    ${content}    ${qosflow_added}    1
    Log to Console    ${qfi_id}
    [Return]    ${qfi_id}[0]

Release PDU Session with VONR
    [Arguments]    ${ue_id}    ${common_drx}=${False}
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=3
    #${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=3 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=3minutes
    Run Keyword If    ${common_drx}    String.Get Lines Matching Regexp    ${output}    drx-Config setup    partial_match=${true}
    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=2 by=amf
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ${command}
    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
    ...    timeout=3minutes
    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
    Log To Console    ${output}

SA Start VONR Traffic
    [Arguments]    ${ue_id}=1
    Log To Console    Start DL UDP Traffic
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=3 dir=dl trf_id=1 bps=12200 size=42 protocol=udp
    Log To Console    Start UL UDP Traffic
    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=1 qfi=3 dir=ul trf_id=1 bps=12200 size=42 protocol=udp
    Sleep    5s    reason=wait traffic is stable


Check Rel16 TDRA Table
    [Arguments]    ${pusch_type}=typeB
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${ret1}=    OperatingSystem.Run    cat /opt/iphy/latest/egate_console.log
    Should Contain    ${ret1}=    pusch-TimeDomainAllocationListDCI-0-1-r16 setup
    Should Contain    ${ret1}=    k2-r16
    Should Contain    ${ret1}=    puschAllocationList-r16
    Should Contain    ${ret1}=    mappingType-r16 ${pusch_type}
    Should Contain    ${ret1}=    startSymbolAndLength-r16
    Should Contain    ${ret1}=    numberOfRepetitions-r16

Check DRX Profile
    [Arguments]   ${drx-onDurationTimer}=ms10    ${drx-InactivityTimer}=ms80    ${drx-LongCycleStartOffset}=ms160
    [Documentation]    This keyword is to check the latest one DRX profile parameter from egate_console.log
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${ret1}=    OperatingSystem.Run    grep -A 10 "drx-Config setup" /opt/iphy/latest/egate_console.log|tail -11
    Should Contain    ${ret1}=    drx-Config setup
    Should Contain    ${ret1}=    drx-onDurationTimer milliSeconds : ${drx-onDurationTimer}
    Should Contain    ${ret1}=    drx-InactivityTimer ${drx-InactivityTimer}
    Should Contain    ${ret1}=    drx-LongCycleStartOffset ${drx-LongCycleStartOffset}

Check UE Not In Sag Mode
    [Arguments]   ${logname}=save1
    ${savepoint} =  Capture savepoint  alias=${GNB_SYSLOG.alias}
    Sleep    5s    reason=Wait for log
    Collect from savepoint  savepoint=${savepoint}  destination_file=${TEST_LOG_DIRECTORY}/Gnb_syslog_${logname}  alias=${GNB_SYSLOG.alias}
    ${content_num}    OperatingSystem.Run    cat ${TEST_LOG_DIRECTORY}/Gnb_syslog_${logname}|grep -i "repetitions: sag"|wc -l
    Should Be True    ${content_num}==0

Check UE TP state
    [Arguments]   ${transformPrecoder}
    [Documentation]    the parameter should be enabled    disabled
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${ret1}=    OperatingSystem.Run    grep "transformPrecoder" /opt/iphy/latest/egate_console.log|tail -1
    Should Contain    ${ret1}=    transformPrecoder ${transformPrecoder}
    
Check TP Of DL And UL 
    [Arguments]    ${target_dl_tp}    ${target_ul_tp}    ${start_ue_id}=1    ${end_ue_id}=1    ${cell_index}=0
    Sleep    5s    reason=wait traffic is stable
    ${fdd_dl_TP}    Get CA Cell Average Throughput For MUE    ${start_ue_id}    ${end_ue_id}    dl    ${cell_index}
    Log To Console    FDD cell's DL Troughput is ${fdd_dl_TP}    console=True
    Should Be True    ${fdd_dl_TP}>=${target_dl_tp}
    ${fdd_ul_TP}    Get CA Cell Average Throughput For MUE    ${start_ue_id}    ${end_ue_id}    ul    ${cell_index}
    Log To Console    FDD cell's UL Troughput is ${fdd_ul_TP}    console=True
    Should Be True    ${fdd_ul_TP}>=${target_ul_tp}

Check SAG Info From Gnb_syslog
    [Arguments]    ${repetition_num}=1    ${mcs}=3    ${prb}=6
    Log To Console    \nCheck SAG Info from Gnb_syslog...
    ${syslog_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}    Gnb_syslog_*    ${True}
    ${sag_info}    OperatingSystem.Run
    ...    cat ${TEST_LOG_DIRECTORY}/Gnb_syslog_*|grep -i "repetitions: sag${repetition_num}x, mcs: ${mcs}, numOfPrbs: ${prb}"|wc -l
    Should Be True    ${sag_info}>=2

Trigger Force DTX Pusch
    [Arguments]    ${ue_id}=1    ${profile_id}=1    ${force_dtx_pusch}=100:0
    ute_wtssim.Execute Egate Command    cmd=forced_dtx_testmode_nr profile_id=${profile_id} force_dtx_pusch=${force_dtx_pusch}
    ute_wtssim.Execute Egate Command    cmd=ue_testmode_set_nr id\=${ue_id} testmode=forced_dtx profile_id=${profile_id} action=activate

Check TP Of DL 
    [Arguments]    ${target_dl_tp}    ${start_ue_id}=1    ${end_ue_id}=1    ${cell_index}=0
    Sleep    5s    reason=wait traffic is stable
    ${fdd_dl_TP}    Get CA Cell Average Throughput For MUE    ${start_ue_id}    ${end_ue_id}    dl    ${cell_index}
    Log To Console    FDD cell's DL Troughput is ${fdd_dl_TP}    console=True
    Should Be True    ${fdd_dl_TP}>=${target_dl_tp}

Change CQI
    [Arguments]    ${ue_id}=2    ${profile_id}=2    ${cqi}=15
    Log To Console    \nChange CQI ...
    ${prepare_1}    Set Variable
    ...    csi_override_testmode_nr profile_id=${profile_id} cqi=${cqi} cqi_mode=oneway cqi_min=4 cqi_max=15 cqi_step=-1 cqi_period=32
    ${prepare_2}    Set Variable
    ...    ue_testmode_set_nr id=${ue_id} testmode=csi_override profile_id=${profile_id} action=activate
    ute_wtssim.Execute Egate Command    ${prepare_1}
    ute_wtssim.Execute Egate Command    ${prepare_2}

Change RI
    [Arguments]    ${ue_id}=2    ${profile_id}=2    ${cqi}=15
    Log To Console    \nChange RI ...
    ${prepare_1}    Set Variable
    ...    csi_override_testmode_nr profile_id=${profile_id} cqi=${cqi} ri=0,1 ri_mode=varying ri_period=2 cqi_mode=fixed
    ${prepare_2}    Set Variable
    ...    ue_testmode_set_nr id=${ue_id} testmode=csi_override profile_id=${profile_id} action=activate
    ute_wtssim.Execute Egate Command    ${prepare_1}
    ute_wtssim.Execute Egate Command    ${prepare_2}
    
Get RNTI Of Two UEs
    ${UE1_RNTI}=    Get Crnti From Egate Log    1
    Set Suite Variable    ${UE1_RNTI}
    ${UE2_RNTI}=    Get Crnti From Egate Log    2
    Set Suite Variable    ${UE2_RNTI}

Setup SA L3 Call Iperf VoNR
    [Arguments]    ${ue_id}    ${vonr_drx}
    Log To Console    SA Attach Iperf VoNR...
    SA 5G Attach    ${ue_id}
    SA 5G PDU Session Setup    ${ue_id}
    CB008236_resource.Modify PDU Session with VONR    1    vonr_drx=${True}

SAG Online Modification
    [Arguments]    ${maxHarqBundlesUlSlotAgg}=10    ${minTbsUlSlotAgg}=384
    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
    COAM.Perform Parameter Recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    ...    parameter=maxHarqBundlesUlSlotAgg    operation=update    value=${maxHarqBundlesUlSlotAgg}    skip_parameter_relation_errors=True
    COAM.Perform Parameter Recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    ...    parameter=minTbsUlSlotAgg    operation=update    value=${minTbsUlSlotAgg}    skip_parameter_relation_errors=True
    [Teardown]    COAM.Teardown

Trigger Reestablish For FDD
    [Arguments]    ${rrc_id}=3
    ${command}    Set Variable    ue_rrc_reestablish id=1 gnb=2 cell=1 cause=otherFailure
    ${output}    ute_wtssim.Execute Egate Command and Wait for Data
    ...    ${command}    pass_regexp=rrc-TransactionIdentifier ${rrc_id},\\s+\\S+ rrcReconfigurationComplete    timeout=3minutes
    [Return]    ${output}

Check Rel16 TDRA Table From Output
    [Arguments]    ${output}    ${pusch_type}=typeB    ${rrc_times}=1
    Should Contain    ${output}=    pusch-TimeDomainAllocationListDCI-0-1-r16 setup
    Should Contain    ${output}=    k2-r16
    Should Contain    ${output}=    puschAllocationList-r16
    Should Contain    ${output}=    mappingType-r16 ${pusch_type}
    Should Contain    ${output}=    startSymbolAndLength-r16
    Should Contain    ${output}=    numberOfRepetitions-r16
    ${times}    evaluate    ${rrc_times}*14
    Should Contain X Times    ${output}    puschAllocationList-r16    ${times}

Check Zero TP Of UL
    [Arguments]    ${target_ul_tp}    ${start_ue_id}=1    ${end_ue_id}=1    ${cell_index}=0
    Sleep    5s    reason=wait traffic is stable
    ${fdd_ul_TP}    Get CA Cell Average Throughput For MUE    ${start_ue_id}    ${end_ue_id}    ul    ${cell_index}
    Log To Console    FDD cell's UL Troughput is ${fdd_ul_TP}    console=True
    Should Be True    ${fdd_ul_TP}==${target_ul_tp}

Check CG Info From syslog
    Log To Console    \nCheck CG Info from syslog...
    ${syslog_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}    AP_syslog_*    ${True}
    ${cg_info}    OperatingSystem.Run
    ...    cat ${TEST_LOG_DIRECTORY}/AP_syslog_*|grep -i "CG Activated"|wc -l
    Should Be True    ${cg_info}>=1

Check UE in SAG Mode From Gnb_syslog
    [Arguments]    ${mcs}=3    ${prb}=6
    Log To Console    \nCheck SAG Info from Gnb_syslog...
    ${syslog_names}    OperatingSystem.List Files In Directory    ${TEST_LOG_DIRECTORY}    Gnb_syslog_*    ${True}
    ${sag2x_info}    OperatingSystem.Run
    ...    cat ${TEST_LOG_DIRECTORY}/Gnb_syslog_*|grep -i "repetitions: sag2x, mcs: ${mcs}, numOfPrbs: ${prb}"|wc -l
    ${sag4x_info}    OperatingSystem.Run
    ...    cat ${TEST_LOG_DIRECTORY}/Gnb_syslog_*|grep -i "repetitions: sag4x, mcs: ${mcs}, numOfPrbs: ${prb}"|wc -l
    ${sag_nums}    evaluate    ${sag2x_info}+${sag4x_info}
    Should Be True    ${sag_nums}>0
    
