*** Settings ***
Documentation    CB010708 TA cases common steps
...              Author: xiaoxia.hao@nokia-sbell.com

Resource    CB010708_common.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/Common/counter_check.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB010887/Resources/CB010887_case_steps.robot

*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
${filter_ports}    ((port 38472) or (port 38412)or (port 38462) or (port 36422) or (port 38422))
${wireshark_capture_interface}    -i any '((sctp) and ${filter_ports})' -s 0
@{direction_component_list}    UL    DL
&{startprb_mapping_table}    0=9    1=21    2=33    3=45    4=57    5=69    6=81    7=93    8=105    9=117
...    10=129    11=141    12=153   13=165    14=177    15=189   16=201    17=213    18=225   19=237

*** Keywords ***
CB010708-SR-A_018_Rank_switch_with_SRS-based_Beamforming
    Activate PRB Blank For CB0010708
#    Update_HighSpeedCell_Values
#    Log to console    step1:numberOfRxBeamforming change to 8Rx,numberOfRxPucch is 4RX
#    Start Btslog With Path Check
#    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
#    ${expect_pci}    ${cpif_log_on_testPC}    Start To Attach And Capture Cpif File    ues_index=${${0}}
#    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
#    Run Keyword And Continue On Failure    Check L1L2 Error Info From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
#    #--- start ul/dl traffic --- #
#    DingLi_Client.Start Data Transfer    ues_index=${${0}}    ul_throughput=350000    dl_throughput=1200M
#    Sleep  30sec
#    Log to console    step0:start to test in rank2 situation
#    @{direction_component_list}    Create List    UL    DL
#    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
#    ...                                                                duration=120
#    ...                                                                expect_ul_tput=290
#    ...                                                                expect_dl_tput=1000
#    ...                                                                cellid=1
#    ...                                                                target_avg_percent=0.95
#    ...                                                                ue_type=huawei_sigspark
#    ...                                                                check_source=aasyslog
#    ...                                                                min_percent=0
#    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
#    Run Keyword And Continue On Failure    Check AVQL Err and WRN Log On RF
#    Run Keyword And Ignore Error    DingLi_Client.Stop Data Transfer
#    Run Keyword And Ignore Error    DingLi_Client.Detach
#    Update_numberOfRxPucch To 8RX and Add Channels For 2T8R
#    Log to console    step2:numberOfRxBeamforming change to 8Rx,numberOfRxPucch is 8RX
#    ${expect_pci}    ${cpif_log_on_testPC}    Start To Attach And Capture Cpif File    ues_index=${${0}}
#    #--- start ul/dl traffic --- #
#    DingLi_Client.Start Data Transfer    ues_index=${${0}}    ul_throughput=350000    dl_throughput=1200M
#    Sleep  30sec
#    Log to console    step0:start to test in rank2 situation
#    ${used_bip_file_rank2_8RX}    Get BIP log For CB010708     expect_pci=${expect_pci}
#    ...                                                      target_file_name=used_bip_file_rank2_8RX
#    ...                                                      duration=15sec
#    @{direction_component_list}    Create List    UL    DL
#    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
#    ...                                                                duration=120
#    ...                                                                expect_ul_tput=290
#    ...                                                                expect_dl_tput=1000
#    ...                                                                cellid=1
#    ...                                                                target_avg_percent=0.95
#    ...                                                                ue_type=huawei_sigspark
#    ...                                                                check_source=aasyslog
#    ...                                                                min_percent=0
#    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
#    Run Keyword And Continue On Failure    Check AVQL Err and WRN Log On RF
#    Run Keyword And Ignore Error    DingLi_Client.Stop Data Transfer
#    Run Keyword And Ignore Error    DingLi_Client.Detach
#    Log to console    step3:numberOfRxBeamforming change to 16Rx,numberOfRxPucch is 8RX
#    Update_Param_numberOfRxBeamforming_To_16Rx
    DingLi_Client.SA And NSA Mode Change
    SLeep    1min
    Start Btslog With Path Check
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    ${expect_pci}    ${cpif_log_on_testPC}    Start To Attach And Capture Cpif File    ues_index=${${0}}
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Run Keyword And Continue On Failure    Check L1L2 Error Info From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    #--- start ul/dl traffic --- #
    DingLi_Client.Start Data Transfer    ues_index=${${0}}    ul_throughput=350000    dl_throughput=1200M
    Sleep  180sec
    Log to console    step2:start to test in rank2 situation for 16Rx
#    ${used_bip_file_rank2}    Get BIP log For CB010708     expect_pci=${expect_pci}
#    ...                                                      target_file_name=used_bip_file_rank2
#    ...                                                      duration=10sec
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=312
    ...                                                                expect_dl_tput=1000
    ...                                                                cellid=1
    ...                                                                target_avg_percent=0.9
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Run Keyword And Continue On Failure    Check AVQL Err and WRN Log On RF
#    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs
#    Run Keyword And Ignore Error    Get Captured Mixed File
    Log to console    step3:start to test in -110db rank1 situation
    ${att_value}    Set Variable IF    '${stream}'=='SBTS00'    25    57
    ${target_att_Value}    Set Variable IF    '${stream}'=='SBTS00'    49    61
    Cycle UPdate ATT Value    att_value=${att_value}    target_att_Value=${target_att_Value}
    Sleep    30sec
    ${used_bip_log_rank1_bad1}    Get BIP log For CB010708     expect_pci=${expect_pci}
    ...                                                      target_file_name=used_bip_log_rank1_bad1
    ...                                                      duration=5sec
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=312
    ...                                                                expect_dl_tput=1000
    ...                                                                cellid=1
    ...                                                                target_avg_percent=0.05
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Run Keyword And Continue On Failure    Check AVQL Err and WRN Log On RF
    Log to console    step4:start to test in fallback to rank2
    ${att_value}    Set Variable IF    '${stream}'=='SBTS00'    25    45
    ${target_att_Value}    Set Variable IF    '${stream}'=='SBTS00'    6    21
    Cycle Fallback ATT Value  att_value=${att_value}    target_att_Value=${target_att_Value}
    Sleep  30sec
    ${used_fallback_bip_log_rank2}    Get BIP log For CB010708     expect_pci=${expect_pci}
    ...                                                      target_file_name=used_fallback_bip_log_rank2
    ...                                                      duration=10sec
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=312
    ...                                                                expect_dl_tput=1000
    ...                                                                cellid=1
    ...                                                                target_avg_percent=0.8
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Run Keyword And Continue On Failure    Check AVQL Err and WRN Log On RF
#    Run Keyword And Ignore Error    Capture Mix Logs With gNB_logs
#    Run Keyword And Ignore Error    Get Captured Mixed File
#    Log to console    checkpoint for rank2 8Rx
#    Run Keyword And Continue On Failure    Check StartPrb For SRS    file_path=${used_bip_file_rank2_8RX}    subcell_id=0
#    Run Keyword And Continue On Failure    Check UL Rank On UlData_PuschReceiveRespPs    file_path=${used_bip_file_rank2_8RX}    subcell_id=0
#    Run Keyword And Continue On Failure    Check UL Rank On UlData_PuschReceiveReq    file_path=${used_bip_file_rank2_8RX}    subcell_id=0
#    Run Keyword And Continue On Failure    Check Rxpower And Sinr In UlData_PuschReceiveRespPs
#    ...     file_path=${used_bip_file_rank2_8RX}    subcell_id=0
#    Run Keyword And Continue On Failure    Check PatternId In uldata_puschreceivereql1ru
#    ...     file_path=${used_bip_file_rank2_8RX}    subcell_id=0    force_count_of_value=4
#    Log to console    checkpoint for rank2 16Rx
#    Run Keyword And Continue On Failure    Check StartPrb For SRS    file_path=${used_bip_file_rank2}    subcell_id=0
#    Run Keyword And Continue On Failure    Check UL Rank On UlData_PuschReceiveRespPs    file_path=${used_bip_file_rank2}    subcell_id=0
#    Run Keyword And Continue On Failure    Check UL Rank On UlData_PuschReceiveReq    file_path=${used_bip_file_rank2}    subcell_id=0
#    Run Keyword And Continue On Failure    Check Rxpower And Sinr In UlData_PuschReceiveRespPs
#    ...     file_path=${used_bip_file_rank2}    subcell_id=0    rxpower_ie_item=${16}
#    Run Keyword And Continue On Failure    Check PatternId In uldata_puschreceivereql1ru
#    ...     file_path=${used_bip_file_rank2}    subcell_id=0
    Run Keyword And Continue On Failure    Check UL Rank On UlData_PuschReceiveRespPs
    ...    file_path=${used_fallback_bip_log_rank2}    subcell_id=0
    Run Keyword And Continue On Failure    Check UL Rank On UlData_PuschReceiveReq
    ...    file_path=${used_fallback_bip_log_rank2}    subcell_id=0
#    Run Keyword And Continue On Failure    Check Rxpower And Sinr In UlData_PuschReceiveRespPs
#    ...     file_path=${used_fallback_bip_log_rank2}    subcell_id=0    rxpower_ie_item=${16}
#    Run Keyword And Continue On Failure    Check PatternId In uldata_puschreceivereql1ru
#    ...     file_path=${used_fallback_bip_log_rank2}    subcell_id=0
    Log to console    checkpoint for rank1 bad1
    Run Keyword And Continue On Failure     Check Values On UlData_SrsReceiveRespPs
    ...    file_path=${used_bip_log_rank1_bad1}    subcell_id=0    value_infor_length=${16}
    Run Keyword And Continue On Failure    Check UL Rank On UlData_PuschReceiveReq
    ...     file_path=${used_bip_log_rank1_bad1}    subcell_id=0    expect_rank=1
    Run Keyword And Continue On Failure    Check UlData_SrsReceiveReq Exist    file_path=${used_bip_log_rank1_bad1}    subcell_id=0
#    Run Keyword And Continue On Failure    Check UL Rank On UlData_PuschReceiveRespPs
#    ...    file_path=${used_bip_log_rank1_bad1}    subcell_id=0    expect_rank=255
    Run Keyword And Continue On Failure    Check Pattern ID In uldata_srsreceivereq
    ...    file_path=${used_bip_log_rank1_bad1}    subcell_id=0
    Run Keyword And Continue On Failure    Check PBoost Value On Cell Edge    file_path=${used_bip_log_rank1_bad1}    subcell_id=0

CB010708-SR-C_001_16RX_IRC_reception_for_2_PUSCH_Rank2_UEs
    Run Keyword If    '${stream}'=='SBTS00' or '${stream_version}'=='26R2'    Update_Param_For_CB010708_C_trunk    ELSE    Update_Param_For_CB010708_C
    Update_UlMuMimo_Values
    DingLi_Client.SA And NSA Mode Change
    SLeep    1min
    ${used_ues_index}    Set Variable    ${${0},${1},${2},${3}}
    ${expect_pci}    ${cpif_log_on_testPC}    Start To Attach And Capture Cpif File    ues_index=${used_ues_index}
    #--- low ul traffic --- #
    DingLi_Client.Start Data Transfer    ues_index=${used_ues_index}    ul_throughput=130000    dl_throughput=400M
    sleep    30sec
#    ${two_sa_ues_paired_bip}    Get BIP log For CB010708     expect_pci=${expect_pci}
#    ...                                                      target_file_name=two_sa_ues_paired_bip
#    ...                                                      duration=5sec
#    ${two_sa_ues_paired_ttitrace}    Run Keyword And Continue On Failure    Capture TTI with gnb logs
#    ${two_sa_ues_paired_ttitrace}    Run Keyword And Continue On Failure    Capture And Decode TTitrace Log
    #--- big dl traffic ---#
#    DingLi_Client.Start Data Transfer    ues_index=${used_ues_index}    whether_start_ul_call=${False}    dl_throughput=400M
#    sleep    30sec
    @{direction_component_list}    Create List    UL    DL
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=426
    ...                                                                expect_dl_tput=1450
    ...                                                                cellid=1
    ...                                                                target_avg_percent=0.95
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Run Keyword And Continue On Failure    Check AVQL Err and WRN Log On RF
    Run Keyword And Ignore Error    DingLi_Client.Stop Data Transfer
    Run Keyword And Ignore Error    DingLi_Client.Detach
    Sleep    30sec
    #--- check ue paired on bad ----#
    ${expect_pci}    ${cpif_log_on_testPC}    Start To Attach And Capture Cpif File    ues_index=${used_ues_index}
    #--- low ul traffic --- #
    DingLi_Client.Start Data Transfer    ues_index=${${0}}    whether_start_dl_call=${False}    ul_throughput=400000
    DingLi_Client.Start Data Transfer    ues_index=${${1},${2},${3}}    whether_start_dl_call=${False}    ul_throughput=20000
    ...                                  refine_ue_port=56660
    sleep    10sec
    Run Keyword If    '${stream}'=='SBTS00'    UPdate All ATT Value    ELSE    UPdate All ATT Value For Branch
    Sleep    30sec
#    ${two_sa_ues_paired_bip_bad}    Get BIP log For CB010708     expect_pci=${expect_pci}
#    ...                                                      target_file_name=two_sa_ues_paired_bip_bad
#    ...                                                      duration=5sec
#    ${two_sa_ues_paired_ttitrace_bad}    Run Keyword And Continue On Failure    Capture TTI with gnb logs
    ${two_sa_ues_paired_ttitrace_bad}    Run Keyword And Continue On Failure    Capture And Decode TTitrace Log
    #--- big dl traffic ---#
    DingLi_Client.Start Data Transfer    ues_index=${used_ues_index}    whether_start_ul_call=${False}    dl_throughput=400M
    sleep    30sec
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Run Keyword And Continue On Failure    Check AVQL Err and WRN Log On RF
    Run Keyword And Ignore Error    DingLi_Client.Stop Data Transfer
    Run Keyword And Ignore Error    DingLi_Client.Detach
    Run Keyword And Continue On Failure    Check MUGroup Paried Status Via TTITrace
    ...                                    ttitrace_filt_path=${two_sa_ues_paired_ttitrace_bad}
    ...                                    group_paird_percent_exp=0
    Run Keyword If    '${stream}'=='SBTS00'    Start L3 Call On Second Cell
    #checkpoint
#    Run Keyword And Continue On Failure    ULMUMIMO.Check UE Paried Status Via TTITrace
#    ...                                    ttitrace_filt_path=${two_sa_ues_paired_ttitrace}
#    ...                                    ulmustatus=MUPAIRED_TAPERING
#    ...                                    percent_exp=0.94
#    Run Keyword And Continue On Failure    ULMUMIMO.Check Single UE Average Tput Via TTITrace
#    ...                                    ttitrace_filt_path=${two_sa_ues_paired_ttitrace}
#    ...                                    expect_tput_value=107
#    Run Keyword And Continue On Failure    Check PatternId In uldata_puschreceivereql1ru    force_count_of_value=16
#    ...     file_path=${two_sa_ues_paired_bip}    subcell_id=0



#    Run Keyword And Continue On Failure    Check MUGroup Paried Status Via TTITrace
#    ...                                    ttitrace_filt_path=${two_sa_ues_paired_ttitrace_bad}
#    ...                                    group_paird_percent_exp=0

CB010708-SR-E_004_4_RANK1_UEs_paired
    Update_Param_For_CB010708_C
    Run Keyword If    '${stream}'=='SBTS00'    Update MCS Phase And ATT For 4NSA    ELSE    Update MCS Phase And ATT For 4NSA Branch
#    Run Keyword And Ignore Error    client.poweron     ue=${uegroup}    until_timeout=${300}
#    sleep    3min
    DingLi_Client.SA And NSA Mode Change    UE_mode=5G_NSA
    SLeep    1min
    ${used_ues_index}    Set Variable    ${${0},${1},${2},${3}}
    ${expect_pci}    ${cpif_log_on_testPC}    Start To Attach And Capture Cpif File    ues_index=${used_ues_index}    UE_mode=5G_NSA
    #--- low ul traffic --- #
    DingLi_Client.Start Data Transfer    ues_index=${used_ues_index}    ul_throughput=130000    dl_throughput=400M
    sleep    30sec
#    ${four_nsa_ues_paired_bip}    Get BIP log For CB010708     expect_pci=${expect_pci}
#    ...                                                      target_file_name=four_nsa_ues_paired_bip
#    ...                                                      duration=5sec
#    ${four_nsa_ues_paired_ttitrace}    Run Keyword And Continue On Failure    Capture And Decode TTitrace Log
#    ${four_nsa_ues_paired_ttitrace}    Run Keyword And Continue On Failure    Capture TTI with gnb logs    duration=10
    #--- big dl traffic ---#
#    DingLi_Client.Start Data Transfer    ues_index=${used_ues_index}    whether_start_ul_call=${False}    dl_throughput=400M
#    sleep    30sec
    @{direction_component_list}    Create List    UL    DL
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=400
    ...                                                                expect_dl_tput=1450
    ...                                                                cellid=1
    ...                                                                target_avg_percent=0.98
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Run Keyword And Continue On Failure    Check AVQL Err and WRN Log On RF
#    ${four_nsa_ues_paired_ttitrace}    Run Keyword And Continue On Failure    Capture And Decode TTitrace Log
    #---checkpoint for rank1 bad1---#
    Run Keyword If    '${stream}'=='SBTS00'    UPdate All ATT Value    ELSE    UPdate All ATT Value For Branch
    Sleep    30sec
#    ${four_nsa_ues_paired_bip_bad}    Get BIP log For CB010708     expect_pci=${expect_pci}
#    ...                                                      target_file_name=four_nsa_ues_paired_bip_bad
#    ...                                                      duration=10sec
#    ${four_nsa_ues_paired_ttitrace_bad}    Run Keyword And Continue On Failure    Capture TTI with gnb logs    duration=5
#    ${four_nsa_ues_paired_ttitrace_bad}    Run Keyword And Continue On Failure     Capture And Decode TTitrace Log    duration=5
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=250
    ...                                                                expect_dl_tput=1000
    ...                                                                cellid=1
    ...                                                                target_avg_percent=0.70
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Run Keyword And Continue On Failure    Check AVQL Err and WRN Log On RF
    Run Keyword And Continue On Failure    DingLi_Client.Stop DL Data Transfer    ues_index=${used_ues_index}
    Sleep    5sec
    ${four_nsa_ues_paired_ttitrace_bad}    Run Keyword And Continue On Failure     Capture And Decode TTitrace Log    duration=5
    #---checkpoint for 4nsa paird---#
#    Log To Console    Start to Check bip and TTI four_nsa_ues_paired
#    Run Keyword And Continue On Failure    ULMUMIMO.Check UE Paried Status Via TTITrace
#    ...                                    ttitrace_filt_path=${four_nsa_ues_paired_ttitrace}
#    ...                                    percent_exp=0.94
#    Run Keyword And Continue On Failure    ULMUMIMO.Check Single UE Average Tput Via TTITrace
#    ...                                    ttitrace_filt_path=${four_nsa_ues_paired_ttitrace}
#    ...                                    expect_tput_value=100
#    ...                                    average_tput_percent=0.98
#    Run Keyword And Continue On Failure    Check PatternId In uldata_puschreceivereql1ru
#    ...                                    file_path=${four_nsa_ues_paired_bip}    subcell_id=0
#    Run Keyword And Continue On Failure    Check startAntIndex In uldata_puschreceivereql1ru
#    ...                                    file_path=${four_nsa_ues_paired_bip}    subcell_id=0
#    Run Keyword And Continue On Failure    Check antPort In uldata_puschreceivereql1ru
#    ...                                    file_path=${four_nsa_ues_paired_bip}    subcell_id=0
    #---checkpoint for 4nsa paird bad---#
    Log To Console    Start to Check UE Paried and ingle UE Average Tput four_nsa_ues_paired on RSRS 80
    Run Keyword And Continue On Failure    ULMUMIMO.Check UE Paried Status Via TTITrace
    ...                                    ttitrace_filt_path=${four_nsa_ues_paired_ttitrace_bad}
    ...                                    percent_exp=0.8
    Run Keyword And Continue On Failure    ULMUMIMO.Check Single UE Average Tput Via TTITrace
    ...                                    ttitrace_filt_path=${four_nsa_ues_paired_ttitrace_bad}
    ...                                    expect_tput_value=40
    ...                                    unexpect_bler=0.1
#    Run Keyword And Continue On Failure    Check PatternId In uldata_puschreceivereql1ru
#    ...                                    file_path=${four_nsa_ues_paired_bip_bad}    subcell_id=0
#    Run Keyword And Continue On Failure    Check startAntIndex In uldata_puschreceivereql1ru
#    ...                                    file_path=${four_nsa_ues_paired_bip_bad}    subcell_id=0
#    Run Keyword And Continue On Failure    Check antPort In uldata_puschreceivereql1ru
#    ...                                    file_path=${four_nsa_ues_paired_bip_bad}    subcell_id=0

CB008235-SR-A_004_4_RANK2_UE_pair_with_nrcelltype_16D8U
#    Update_Param_For_CB008235
    Run Keyword If    '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'    Update_Param_For_CB013394
    DingLi_Client.SA And NSA Mode Change
    SLeep    1min
    ${used_ues_index}    Set Variable    ${${0},${1},${2},${3}}
    ${dl_throughput}    Set Variable If    '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'    700M    400M
    ${expect_dl_tput}    Set Variable If    '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'    2670    1450
    ${expect_pci}    ${cpif_log_on_testPC}    Start To Attach And Capture Cpif File    ues_index=${used_ues_index}

    #--- low ul traffic --- #
    DingLi_Client.Start Data Transfer    ues_index=${used_ues_index}    ul_throughput=185000    dl_throughput=${dl_throughput}
    sleep    30sec
    ${dl_ues_paired_ttitrace}    Run Keyword If    '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'
    ...                                Run Keyword And Continue On Failure    Capture And Decode TTitrace Log    duration=1    direction=dl
    #--- big dl traffic ---#
#    DingLi_Client.Start Data Transfer    ues_index=${used_ues_index}    whether_start_ul_call=${False}    dl_throughput=400M
#    sleep    60sec
    Wait Until Next Counter Update
    Sleep    180sec
#    ${dis_name_dir}    set variable    MRBTS-${tl.gnbs[0].instance_id}/NRBTS-${tl.gnbs[0].global_bts_id}
#    ${M55308C36012_full_path}    set variable    ${dis_name_dir}/NRCELL-1/NCELA/PRB_UL_MU_MIMO_8LAYER
#    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
#    ${M55308C36012_value}    Get counter latest value    BTS_or_TRS=BTS    counter_id=M55308C36012
#    ...                                                  counter_full_path=${M55308C36012_full_path}
#    ${M55308C36012_value}    convert to integer     ${M55308C36012_value}
#    run keyword and continue on failure    should be true    ${M55308C36012_value}>1
    ${counter_info_dict_list}    Run Keyword If    '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'    BTS Counters List For 8235 On Trunk
    ...                          ELSE    BTS Counters List For 8235 On Branch
    Get And Check counters latest value For 8235    counter_info_dict_list=${counter_info_dict_list}
    @{direction_component_list}    Create List    UL    DL
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=668
    ...                                                                expect_dl_tput=${expect_dl_tput}
    ...                                                                cellid=1
    ...                                                                target_avg_percent=0.95
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Run Keyword And Continue On Failure    Check AVQL Err and WRN Log On RF
    Sleep    10sec
    Run Keyword If    '${stream}'=='SBTS00'    UPdate All ATT Value FOR RSRP 85    ELSE    UPdate All ATT Value FOR RSRP 85 For Branch
    Sleep    30sec
    #--- big dl traffic ---#
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=668
    ...                                                                expect_dl_tput=${expect_dl_tput}
    ...                                                                cellid=1
    ...                                                                target_avg_percent=0.5
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Run Keyword And Continue On Failure    Check AVQL Err and WRN Log On RF

#    sleep    5sec
#    Run Keyword And Continue On Failure    DingLi_Client.Stop DL Data Transfer    ues_index=${used_ues_index}
#    ${two_sa_ues_paired_ttitrace_bad}    Run Keyword And Continue On Failure    Capture And Decode TTitrace Log
    #checkpoint
#    Log To Console    Start to Check Single UE Average Tput Via TTITrace
    Run Keyword If    '${stream}'=='SBTS00' or '${stream}'=='SBTS26R2'
    ...                Run Keyword And Continue On Failure    Check DL MUGroup Paried Status Via TTITrace
    ...                                                                               ttitrace_filt_path=${dl_ues_paired_ttitrace}
#    Log To Console    Start to Check Single UE Average Tput Via TTITrace on RSRP -85
#    Run Keyword And Continue On Failure    ULMUMIMO.Check Single UE Average Tput Via TTITrace
#    ...                                    ttitrace_filt_path=${two_sa_ues_paired_ttitrace_bad}
#    ...                                    expect_tput_value=100
#    ...                                    unexpect_bler=0.9

CB008235-SR-C_001_16_RANK2_UEs_MUgroup_pairing
    Update MCS Phase For 8SA
    DingLi_Client.SA And NSA Mode Change
    SLeep    1min
    ${used_ues_index}    Set Variable    ${${0},${1},${2},${3},${4},${5},${6},${7}}
    ${expect_pci}    ${cpif_log_on_testPC}    Start To Attach And Capture Cpif File    ues_index=${used_ues_index}
    #--- low ul traffic --- #
    ${used_ues_index}    Set Variable    ${${0},${1},${2},${3}}
    DingLi_Client.Start Data Transfer    ues_index=${used_ues_index}    ul_throughput=30000    dl_throughput=200M
    ${used_ues_index}    Set Variable    ${${4},${5},${6},${7}}
    DingLi_Client.Start Data Transfer    ues_index=${used_ues_index}    ul_throughput=20000    dl_throughput=200M
    ...                                  refine_ue_port=56376    refine_dl_port=56376
    sleep    30sec
#    ${two_sa_ues_paired_ttitrace}    Run Keyword And Continue On Failure    Capture And Decode TTitrace Log
    #--- big dl traffic ---#
#    DingLi_Client.Start Data Transfer    ues_index=${used_ues_index}    whether_start_ul_call=${False}    dl_throughput=400M
#    sleep    60sec
    @{direction_component_list}    Create List    UL    DL
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=210
    ...                                                                expect_dl_tput=1500
    ...                                                                cellid=1
    ...                                                                target_avg_percent=0.95
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Run Keyword And Continue On Failure    Check AVQL Err and WRN Log On RF
    Sleep    10sec
    UPdate All ATT Value FOR RSRP 85
    Sleep    30sec
    #--- big dl traffic ---#
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=210
    ...                                                                expect_dl_tput=1500
    ...                                                                cellid=1
    ...                                                                target_avg_percent=0.5
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Run Keyword And Continue On Failure    Check AVQL Err and WRN Log On RF

CB010708-SR-L_002_Rank2_and_TPMI_Measurement_on_16Rx_SRS_with_2_interferers
    [Arguments]    ${list_cell_ids}=2    ${expect_sceond_pci}=722
    DingLi_Client.SA And NSA Mode Change
    SLeep    1min
    ${used_ues_index}    Set Variable    ${${0}}
    ${expect_pci}    ${cpif_log_on_testPC}    Start To Attach And Capture Cpif File    ues_index=${used_ues_index}
    #--- low ul traffic --- #
    DingLi_Client.Start Data Transfer    ues_index=${used_ues_index}    ul_throughput=250000    dl_throughput=1500M
    sleep    30sec
    Run Keyword And Continue On Failure     Capture And Decode TTitrace Log    duration=2    direction=ul
    sleep    30sec
    Wait Until Next Counter Update
    Sleep    180sec
    ${counter_info_dict_list}    BTS Counters List For 10708_L On Trunk
    Get And Check counters latest value For 10708_L    counter_info_dict_list=${counter_info_dict_list}
    Update The First RF ATT Value For 2 interferers
    sleep    30sec
    @{direction_component_list}    Create List    UL    DL
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=230
    ...                                                                expect_dl_tput=1370
    ...                                                                cellid=1
    ...                                                                target_avg_percent=0.7
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Run Keyword And Continue On Failure    Check AVQL Err and WRN Log On RF
    #--- check ue paired on bad ----#
    Update The Second RF ATT Value
    Sleep    30sec
    ${expect_pci}    ${cpif_log_on_testPC}    Start To Attach And Capture Cpif File    ues_index=${${1}}
    ...                                       list_cell_ids=${list_cell_ids}    expect_sceond_pci=${expect_sceond_pci}
    #--- low ul traffic --- #
    DingLi_Client.Start Data Transfer    ues_index=${${1}}    ul_throughput=45000    dl_throughput=300M
    ...                                  refine_ue_port=56660    refine_dl_port=56660
    sleep    30sec
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=230
    ...                                                                expect_dl_tput=1370
    ...                                                                cellid=1
    ...                                                                target_avg_percent=0.7
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=30
    ...                                                                expect_dl_tput=30
    ...                                                                cellid=2
    ...                                                                target_avg_percent=0.7
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Run Keyword And Continue On Failure    Check AVQL Err and WRN Log On RF
    [Teardown]    run keywords    run keyword and ignore error    Restore The Second RF ATT Value    AND
    ...                           run keyword and ignore error    Set MCS Phase And ATT For 10708

CB009527_D_2_RZF_Based_SB_BF_with_SB_SRS_Single_Ue_4CC_16DL
    Update_Param_For_CB009527
    DingLi_Client.SA And NSA Mode Change
    SLeep    1min
    ${used_ues_index}    Set Variable    ${${0}}
    ${expect_pci}    ${cpif_log_on_testPC}    Start To Attach And Capture Cpif File    ues_index=${used_ues_index}
    DingLi_Client.Start Data Transfer    ues_index=${used_ues_index}    ul_throughput=250000    dl_throughput=1500M
    sleep    30sec
    ${dl_ttitrace_peak}    Run Keyword And Continue On Failure     Capture And Decode TTitrace Log    duration=2    direction=dl
    @{direction_component_list}    Create List    UL    DL
    Run Keyword And Continue On Failure    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                                                                duration=120
    ...                                                                expect_ul_tput=239
    ...                                                                expect_dl_tput=1440
    ...                                                                cellid=1
    ...                                                                target_avg_percent=0.95
    ...                                                                ue_type=huawei_sigspark
    ...                                                                check_source=aasyslog
    ...                                                                min_percent=0
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Run Keyword And Continue On Failure    Check AVQL Err and WRN Log On RF
    Run Keyword And Ignore Error    DingLi_Client.Stop Data Transfer
    DingLi_Client.Start Data Transfer    ues_index=${used_ues_index}    ul_throughput=1000    dl_throughput=10M
    ${dl_ttitrace_low}    Run Keyword And Continue On Failure     Capture And Decode TTitrace Log    duration=2    direction=dl
    Log to console   staer to check beam Type for peak
    Check DL beamType Status Via TTITrace   ttitrace_filt_path=${dl_ttitrace_peak}
    Log to console   staer to check beam Type for low tput
    Check DL beamType Status Via TTITrace   ttitrace_filt_path=${dl_ttitrace_low}    beamType_value=DFTNONTAPERING