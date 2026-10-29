*** Settings ***
Documentation    CB008360 TA cases common steps
...              Author: Stella.lin@nokia-sbell.com, lei.jia@nokia-sbell.com

Resource    CB008360_keywords.robot
Variables    TestCaseVariables.py

*** Variables ***
${tddpcell_index}                    ${3}
${fddcell_index}                     ${1}
${chbw_40M_ullayer1_tput}            24
${chbw_40M_ullayer1_tput_unpaired}   12
${chbw_40M_ullayer2_tput}            48
${chbw_40M_ullayer2_tput_unpaired}   24
${chbw_40M_ullayer4_tput}            96
${chbw_100M_ullayer2_tput}           100
${chbw_100M_ullayer1_ul256qam_tput}                100
${chbw_100M_ullayer1_ul64qam_tput}                 70

*** Keywords ***
CB008360-5G-A_B2_12_Two_UEs_paired_when_correlation_lower_than_ulMuMimoCorrThd_and_UL_SINR_Difference_less_than_rdPairedUEsDeltaSINR
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  set default ulMuMimoCorrThd=0.5, ulSinrDiffThreshold=-10
    ...                  Two NSA UEs can be paired if the correlation of this two UEs is less than ulMuMimoCorrThd
    ...                  2022-01-05: rdPairedUEsDeltaSINR change to NIDD para ulsinrDiffThreshold, and it does not work for two rank1 UE
    ...                  UE-A and UE-B should not be paired when UL SINR difference between UE-A and UE-B is greater than ulSinrDiffThreshold.
    ...                  This para ulSinrDiffThreshold does not work for two rank1 UEs
    Log To Console    \n***Step1:ue attach for two ues and start traffic***\n
    ${org_NRULMUMIMO_Params}    Get ULMUMIMO Related Paras    cell_index=${tddpcell_index}
    set test variable    ${org_NRULMUMIMO_Params}
    ${attachinfo_dict}    Start L3 Call With UEs    start_keep_on_duration=2200    target_DL_avg_percent=0.85
    Log To Console    \n***Step2:stop dl traffic and capture tti, check two ues paired in the bip and ul tput from tti***\n
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
    ${ttitrace_ue_paired}    ${bip_ue_paired}     Stop DL Traffic and Capture BIP and TTI for UES    cell_index=${tddpcell_index}
#    Run Keyword And Continue On Failure    MultiUE.Stop UL Traffic
#    Run Keyword And Ignore Error    UE Deattach for UEs
    Log To Console    \n***Step3:add ue1's attenuation 20db to make UL SINR difference greater than ulSinrDiffThreshold\n
    Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=20
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
    Log To Console    \n***Step5:modify ulSinrDiffThreshold from -10 to -25, in this way two ues' sinr must be the same for rank2 UEs\n
    Run Keyword If    '${stream}'=='SBTS23R1'    Update Prameter tmpParam5    cell_index=${tddpcell_index}    update_value=-25
    ...    ELSE    Update Prameter ulSinrDiffThreshold    cell_index=${tddpcell_index}    update_value=-25
#    Start L3 Call With UEs    target_UL_avg_percent=0.55
#    ${ttitrace_sinr_diff}    ${bip_log_sinr_diff}    Stop DL Traffic and Capture BIP and TTI for UES    cell_index=${tddpcell_index}
    ${ttitrace_sinr_diff}    Run Keyword And Continue On Failure    Capture TTI with gnb logs    cell_index=${tddpcell_index}
    Log To Console    \n***Check point1:Two NSA UEs can be paired if the correlation of this two UEs is less than ulMuMimoCorrThd
    Log To Console    \n***evaluate ue tput with tti for step1***\n
    Run Keyword And Continue On Failure    Evaluate Single UE Average Tput For UL With TTI    file_path=${ttitrace_ue_paired}
    ...    expect_tput_value=${chbw_40M_ullayer1_tput}
    Log To Console    \n***check ue paried in tti for step1***\n
    Run Keyword And Continue On Failure    Two UEs should be paired    file_path=${ttitrace_ue_paired}
    Log To Console    \n***Check point2:modify ue1's attenuation,check two ues unpaired***\n
    Log To Console    \n***evaluate ue tput with tti for step3***\n
    Run Keyword And Continue On Failure    Evaluate Single UE Average Tput For UL With TTI    file_path=${ttitrace_sinr_diff}
    ...    expect_tput_value=${chbw_40M_ullayer1_tput_unpaired}    unexpect_bler=0.15    average_tput_percent=0.85
    Log To Console    \n***as two rank1 UE, it is still paired for step3***\n
    Run Keyword And Continue On Failure    Two UEs should be paired    file_path=${ttitrace_sinr_diff}    percent_exp=0.85
    [Teardown]    Run Keyword If    '${stream}'=='SBTS23R1'    Update Prameter tmpParam5    cell_index=${tddpcell_index}    update_value=-10
    ...    ELSE    Update Prameter ulSinrDiffThreshold    cell_index=${tddpcell_index}    update_value=-10


CB008360-5G-A_B3_17_Two_UEs_paired_when_UE_Spectrum_efficiency_satisfied_for_ulMuMimoLinkAdaptionSwitch=MCS_compensation
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  set default ulMuMimoSpectralEffThd=1, rdPairedUEsDeltaSINR=5
    ...                  UE-A& UE-B is paired when UE-A and UE-B Spectrum efficiency are satisfied. Otherwise two UEs will not be paired
    Log To Console    \n***Step1:ue attach for two ues and start traffic***\n
    ${org_NRULMUMIMO_Params}    Get ULMUMIMO Related Paras    cell_index=${tddpcell_index}
    set test variable    ${org_NRULMUMIMO_Params}
    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    ulMuMimoLinkAdaptionSwitch=MCS compensation
    ${attachinfo_dict}    Start L3 Call With UEs
    Log To Console    \n***Step2:stop dl traffic and capture tti, check two ues paired in the bip and ul tput from tti***\n
    ${ttitrace_ue_paired}    ${bip_ue_paired}     Stop DL Traffic and Capture BIP and TTI for UES    cell_index=${tddpcell_index}
    Log To Console    \n***Step3:modify ulMuMimoSpectralEffThd=1, and capture bip, check two ues paired***\n
    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    ulMuMimoSpectralEffThd=10    ulMuMimoLinkAdaptionSwitch=MCS compensation
    Run Keyword And Continue On Failure    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}
    ${ttitrace_ulMuMimoSpectralEffThd1}    ${bip_ulMuMimoSpectralEffThd1}
    ...    Stop DL Traffic and Capture BIP and TTI for UES    cell_index=${tddpcell_index}
    Log To Console    \n***Step4:modify ulMuMimoSpectralEffThd=2, and capture bip, check two ues unpaired***\n
    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    ulMuMimoSpectralEffThd=20    ulMuMimoLinkAdaptionSwitch=MCS compensation
    Run Keyword And Continue On Failure    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}
    ${ttitrace_ulMuMimoSpectralEffThd2}    ${bip_ulMuMimoSpectralEffThd2}
    ...    Stop DL Traffic and Capture BIP and TTI for UES    cell_index=${tddpcell_index}
    Log To Console    \n***Check point1:Two NSA UEs can be paired when Spectrum efficiency are satisfied
    Log To Console    \n***evaluate ue tput with tti for step1***\n
    Run Keyword And Continue On Failure    Evaluate Single UE Average Tput For UL With TTI    file_path=${ttitrace_ue_paired}
    ...    expect_tput_value=${chbw_40M_ullayer1_tput}
    Log To Console    \n***checp ue paired in bip for step1***\n
    Run Keyword And Continue On Failure    Two UEs should be paired    file_path=${ttitrace_ue_paired}
    Log To Console    \n***Check point2:Two NSA UEs can be paired when Spectrum efficiency are satisfied
    Log To Console    \n***evaluate ue tput with tti for step3***\n
    Run Keyword And Continue On Failure    Evaluate Single UE Average Tput For UL With TTI    file_path=${ttitrace_ulMuMimoSpectralEffThd1}
    ...    expect_tput_value=${chbw_40M_ullayer1_tput}
    Log To Console    \n***checp ue paired in bip for step3***\n
    Run Keyword And Continue On Failure    Two UEs should be paired    file_path=${ttitrace_ulMuMimoSpectralEffThd1}
    Log To Console    \n***Check point3:modify ulMuMimoSpectralEffThd=2, and capture bip, check two ues unpaired***\n
    Log To Console    \n***evaluate ue tput with tti for step4***\n
    Run Keyword And Continue On Failure    Evaluate Single UE Average Tput For UL With TTI    file_path=${ttitrace_ulMuMimoSpectralEffThd2}
    ...    expect_tput_value=${chbw_40M_ullayer1_tput_unpaired}    unexpect_bler=0.1
    Run Keyword And Continue On Failure    Two UEs should be unpaired    file_path=${ttitrace_ulMuMimoSpectralEffThd2}
    [Teardown]    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}
    ...            ulMuMimoSpectralEffThd=${org_NRULMUMIMO_Params['ulMuMimoSpectralEffThd']}
    ...            ulMuMimoLinkAdaptionSwitch=${org_NRULMUMIMO_Params['ulMuMimoLinkAdaptionSwitch']}

CB008360-5G-A_B1_09_Two_UEs_Not_paired_when_rescaled_SINR_less_than_ulMuMimoSinrThd
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  set default ulMuMimoSinrThd = 25, rdPairedUEsDeltaSINR=5
    ...                  Two NSA UEs can be paired if ul sinr of this two UEs is greater than ulMuMimoSinrThd
    ...                  UE-A and UE-B should not be paired when ul sinr of this two UEs is less than ulMuMimoSinrThd
    ...                  while UL SINR difference between UE-A and UE-B is less than rdPairedUEsDeltaSINR.
    Log To Console    \n***Step1:ue attach for two ues and start traffic***\n
    ${org_NRULMUMIMO_Params}    Get ULMUMIMO Related Paras    cell_index=${tddpcell_index}
    set test variable    ${org_NRULMUMIMO_Params}
    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    ulMuMimoSinrThd=20
    ${attachinfo_dict}    Start L3 Call With UEs
    Log To Console    \n***Step2:make two ues paired in the bip and ul tput from tti***\n
    ${ttitrace_ue_paired}    ${bip_ue_paired}     Stop DL Traffic and Capture BIP and TTI for UES    cell_index=${tddpcell_index}
    Log To Console    \n***Step4:add ue2's attenuation 14db to make to make UL SINR difference less than ulMuMimoSinrThd\n
    Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=14
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}
    ${ttitrace_sinr_low}    ${bip_log_sinr_low}    Stop DL Traffic and Capture BIP and TTI for UES    cell_index=${tddpcell_index}
    Log To Console    \n***Check point1:Two NSA UEs can be paired if ul sinr of this two UEs is greater than ulMuMimoSinrThd
    Log To Console    \n***evaluate ue tput with tti for step1***\n
    Run Keyword And Continue On Failure    Evaluate Single UE Average Tput For UL With TTI    file_path=${ttitrace_ue_paired}
    ...    expect_tput_value=${chbw_40M_ullayer1_tput}
    Log To Console    \n***check ue paried in tti for step1***\n
    Run Keyword And Continue On Failure    Two UEs should be paired    file_path=${ttitrace_ue_paired}
    Log To Console    \n***Check point2:add ue1's attenuation,check two ues unpaired***\n
    Log To Console    \n***evaluate ue tput with tti for step4***\n
    Run Keyword And Continue On Failure    Evaluate Single UE Average Tput For UL With TTI    file_path=${ttitrace_sinr_low}
    ...    expect_tput_value=${chbw_40M_ullayer1_tput_unpaired}    unexpect_bler=0.1    average_tput_percent=0.8
    Log To Console    \n***check ue unparied in tti for step2***\n
    Run Keyword And Continue On Failure    Two UEs should be unpaired    file_path=${ttitrace_sinr_low}
    [Teardown]    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    ulMuMimoSinrThd=${org_NRULMUMIMO_Params['ulMuMimoSinrThd']}

CB008360-5G-A_B1_05_Two_UEs_blindly_paired_Controled_by_Different_Cell_load
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                  UE-A & UE-B will be paired only when two UEs with non-GBR traffic required total PRB load higher than
    ...                 AvaiablePrbForMu*rdUlPrbScaleRatio: rrmRequiredMuPrbNum > rrmAvailablePrbForMu * rdUlPrbScaleRatio
    [Arguments]     ${pcell_index}=${tddpcell_index}
    Log To Console    \n***Step0:configure rdUlPrbScaleRatio Default value is 1.1***\n
    Log To Console    \n***Step1:ue attach for two ues and start traffic***\n
    ${attachinfo_dict}    Start L3 Call With UEs
    Log To Console    \n***Step2:stop dl traffic and capture tti, check two ues paired in the bip and ul tput from tti***\n
    ${ttitrace_ue_paired}    ${bip_cell_load_high}     Stop DL Traffic and Capture BIP and TTI for UES    cell_index=${tddpcell_index}
    Log To Console    \n***Step3:stop ul traffic and start a few UL traffic about 2Mbits, ue should not be paired***\n
    Log To Console    \n***step3:when rrmRequiredMuPrbNum < rrmAvailablePrbForMu * rdUlPrbScaleRatio , ue should not be paired***\n
    MultiUE.Stop UL Traffic
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    ul_throughput=1M    dl_throughput=1M    dl_process_num=1
    sleep     10s
    ${tti_log_cell_load_low}    Run Keyword And Continue On Failure    Capture TTI with gnb logs    cell_index=${pcell_index}
    Log To Console    \n***Check point1:Two NSA UEs can be paired for step1
    Log To Console    \n***evaluate ue tput with tti for step1***\n
    Run Keyword And Continue On Failure    Evaluate Single UE Average Tput For UL With TTI    file_path=${ttitrace_ue_paired}
    ...    expect_tput_value=${chbw_40M_ullayer1_tput}
    Log To Console    \n***check ue paried in tti for step1***\n
    Run Keyword And Continue On Failure    Two UEs should be paired    file_path=${ttitrace_ue_paired}
    Log To Console    \n***Check point2:Two NSA UEs can be unpaired for step2
    Run Keyword And Continue On Failure    Two UEs should be unpaired    file_path=${tti_log_cell_load_low}    percent_exp=0.9

CB008360-5G-A_B3_16_Two_UEs_paired_when_UE_Spectrum_efficiency_satisfied_for_ulMuMimoLinkAdaptionSwitch=MU-SINR_Estimation
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    Log To Console    \n***Step1:start UE attach and data ul data transfer***\n
    ${attachinfo_dict}    UE attach for UES    ue_mode=NSA    whether_do_ue_prepare=${False}
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    whether_start_dl_call=${False}
    Log To Console    \n***Step2:check ue paried and per ue tput under ulMuMimoSpectralEffThd=0***\n
    ${tti_file_under_param_0}    Run Keyword And Continue On Failure    Capture TTI with gnb logs    cell_index=${tddpcell_index}
    Log To Console    \n***Step3:start dl tput and check total ul/dl tput***\n
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    whether_start_ul_call=${False}
    Procedures.Check Tput    ue_type=${UE0_TYPE}    check_scell_tput=${False}    scell_mapping=${None}
    ...    tput_collect_duration=120
    Log To Console    \n***Step4:test with ulMuMimoSpectralEffThd=1: ue paired***\n
    ${org_NRULMUMIMO_Params}    Get ULMUMIMO Related Paras    cell_index=${tddpcell_index}
    set test variable    ${org_NRULMUMIMO_Params}
    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    ulMuMimoSpectralEffThd=10
    MultiUE.Stop DL Traffic
    Sleep  10sec
    ${tti_file_under_param_1}    Run Keyword And Continue On Failure    Capture TTI with gnb logs    cell_index=${tddpcell_index}
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    whether_start_ul_call=${False}
    Run Keyword And Continue On Failure
    ...    Procedures.Check Tput    ue_type=${UE0_TYPE}    check_scell_tput=${False}
    ...    scell_mapping=${None}    tput_collect_duration=120
    Log To Console    \n***Step5:test with ulMuMimoSpectralEffThd=2: ue unpaired***\n
    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    ulMuMimoSpectralEffThd=20
    Sleep  10sec
    ${tti_file_under_param_2}    Run Keyword And Continue On Failure    Capture TTI with gnb logs    cell_index=${tddpcell_index}
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    whether_start_ul_call=${False}
    Procedures.Check Tput    ue_type=${UE0_TYPE}   check_scell_tput=${False}    scell_mapping=${None}
    ...                      tput_collect_duration=120    check_ul_pcell_tput_type=layer1
    Run Keyword And Ignore Error    MultiUE.Stop Traffic
    Run Keyword And Continue On Failure    Check UE Paried Status Via TTITrace    ttitrace_filt_path=${tti_file_under_param_0}
    Run Keyword And Continue On Failure    Check UE Paried Status Via TTITrace    ttitrace_filt_path=${tti_file_under_param_1}
    Run Keyword And Continue On Failure    Check UE Paried Status Via TTITrace
    ...                                    ttitrace_filt_path=${tti_file_under_param_2}
    ...                                    exp_staus=notPaired
    ...                                    is_ulmustatus_need_to_check=${False}
    Run Keyword And Continue On Failure    Evaluate Single UE Average Tput For UL With TTI
    ...    file_path=${tti_file_under_param_0}    expect_tput_value=${chbw_40M_ullayer1_tput}
    Run Keyword And Continue On Failure    Evaluate Single UE Average Tput For UL With TTI
    ...    file_path=${tti_file_under_param_1}    expect_tput_value=${chbw_40M_ullayer1_tput}
    Evaluate Single UE Average Tput For UL With TTI    file_path=${tti_file_under_param_2}
    ...                                                expect_tput_value=${chbw_40M_ullayer1_tput_unpaired}

CB008360-5G-A_B1_07_Two_UEs_paired_Control_Verify_for_Root_UE_Req_PRB_less_than_ulMinPrbThreshold
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ${org_NRULMUMIMO_Params}    Get ULMUMIMO Related Paras    cell_index=${tddpcell_index}
    set test variable    ${org_NRULMUMIMO_Params}
    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    ulMinPrbThreshold=100    ulMuMimoPrbThresholdAbsolute=30
    ${attachinfo_dict}    UE attach for UES    ue_mode=NSA    whether_do_ue_prepare=${False}
    ${ue0_index}    Create List    ${0}
    ${ue1_index}    Create List    ${1}
    MultiUE.Start Data Transfer    ues_index=${ue0_index}    attachinfo_dict=${attachinfo_dict}
    ...     whether_start_dl_call=${False}    ul_throughput=25M
    MultiUE.Start Data Transfer    ues_index=${ue1_index}    attachinfo_dict=${attachinfo_dict}
    ...     whether_start_dl_call=${False}    ul_throughput=15M
    Sleep    10sec
    ${ttitrace_file}    Run Keyword And Continue On Failure    Capture TTI with gnb logs   cell_index=${tddpcell_index}
    Run Keyword And Continue On Failure    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    whether_start_ul_call=${False}
    Run Keyword And Continue On Failure    Procedures.Check Tput
    ...                                    ue_type=${UE0_TYPE}
    ...                                    check_scell_tput=${False}
    ...                                    scell_mapping=${None}
    ...                                    tput_collect_duration=180
    ...                                    check_ul_pcell_tput_type=layer1
    ${root_ue_rnti}    ${candidate_ue_rnti}    Run Keyword And Continue On Failure    Check UE Paried Status With Varied Reqprb
    ...                                                                               ttitrace_file=${ttitrace_file}
    ${candidate_ue_tput_exp}    Set Variable    15
    Run Keyword And Continue On Failure    Evaluate Single UE Average Tput Via TTITrace Based On Rnti
    ...                                    rnti=${root_ue_rnti}
    ...                                    ttitrace_file=${ttitrace_file}
    ...                                    expect_tput_value=${chbw_40M_ullayer1_tput}
    Evaluate Single UE Average Tput Via TTITrace Based On Rnti
    ...    rnti=${candidate_ue_rnti}
    ...    ttitrace_file=${ttitrace_file}
    ...    expect_tput_value=${candidate_ue_tput_exp}

CB008360-5G-B_03_Two_Rank2_UEs_Paired_or_Unpaired_with_online_parameters_change
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    ulMaxMuMimoLayer=2
    Log To Console    \n***Multi-UE2: port5/6 θ_h/θ_v:-7/-6 ATT=10, port7/8 θ_h/θ_v:-22/-6 ATT=10
    Log To Console    \n***Multi-UE3: port9/10 θ_h/θ_v:7/-6 ATT=10, port11/12 θ_h/θ_v:22/-6 ATT=10
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${-7}    second_beam_horizontal_angle=${-22}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=10
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
    ...    first_beam_horizontal_angle=${7}    second_beam_horizontal_angle=${22}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=10
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}
    UE Prepare for UES    ues_index=${${2},${3},${4},${5}}
    Disable AutoConnect For 8UE Module    ues_index=${${2},${3},${4},${5}}
    Deployment SA And NSA Mode For 8UE Module    ue_mode=SA    ues_index=${${3},${4}}
    ${attachinfo_dict}     UE attach for UES    ues_index=${${3},${4}}    whether_do_ue_prepare=${False}
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    is_power_ue_code=${True}    ues_index=${${3},${4}}    ue_mode=SA
    ...                            whether_start_dl_call=${False}    ul_throughput=70M
    Sleep    10sec
    ${ttitrace_file_0}    Run Keyword And Continue On Failure    Capture TTI with gnb logs   cell_index=${tddpcell_index}
#    Run Keyword And Continue On Failure    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    whether_start_ul_call=${False}
#    ...                                    ue_mode=SA    ues_index=${${3},${4}}    is_power_ue_code=${True}
#    Run Keyword And Continue On Failure    Procedures.Check Tput
#    ...                                    ue_type=${UE2_TYPE}
#    ...                                    check_scell_tput=${False}
#    ...                                    scell_mapping=${None}
#    ...                                    tput_collect_duration=120
#    MultiUE.Stop DL Traffic
    ${direction_component_list}=  Create List    UL_L2LO
    set test variable    ${ue_type}    qct_dx50
    Run Keyword And Continue On Failure    Check Tput With Power UE
    ...                         direction_component_list=${direction_component_list}
    ...                         expect_ul_tput=${chbw_40M_ullayer2_tput_unpaired}
    ...                         duration=120
    ...                         cellid=${tddpcell_index}
    ...                         min_percent=0.1
    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    ulMaxMuMimoLayer=4
    Sleep  10sec
    ${ttitrace_file_1}    Run Keyword And Continue On Failure    Capture TTI with gnb logs   cell_index=${tddpcell_index}
#    Run Keyword And Continue On Failure    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    whether_start_ul_call=${False}
#    ...                                    ue_mode=SA    ues_index=${${3},${4}}    is_power_ue_code=${True}
#    Run Keyword And Continue On Failure    Procedures.Check Tput    ue_type=${UE2_TYPE}    check_scell_tput=${False}
#    ...                                    scell_mapping=${None}    tput_collect_duration=120
    Run Keyword And Continue On Failure    Check Tput With Power UE
    ...                         direction_component_list=${direction_component_list}
    ...                         expect_ul_tput=${chbw_40M_ullayer2_tput}
    ...                         duration=120
    ...                         cellid=${tddpcell_index}
    ...                         min_percent=0.1
    Run Keyword And Ignore Error    MultiUE.Stop Traffic
    Run Keyword And Continue On Failure    Check UE Paried Status Via TTITrace    ttitrace_filt_path=${ttitrace_file_0}
    ...                                    exp_staus=notPaired
    ...                                    ulmustatus=MUNONELIGIBLE_MAXLAYERREACHED
    Run Keyword And Continue On Failure    Check UE Paried Status Via TTITrace    ttitrace_filt_path=${ttitrace_file_1}
    Run Keyword And Continue On Failure    Check AntPort For Subcells     ttitrace_file=${ttitrace_file_1}
    ...                                                                   cell_index=${tddpcell_index}
    ...                                                                   expect_subcell0_port=port01
    ...                                                                   expect_subcell1_port=port23
    Run Keyword And Continue On Failure    Evaluate Single UE Average Tput For UL With TTI    file_path=${ttitrace_file_0}
    ...                                                expect_tput_value=${chbw_40M_ullayer2_tput_unpaired}
    Evaluate Single UE Average Tput For UL With TTI    file_path=${ttitrace_file_1}
    ...                                                expect_tput_value=${chbw_40M_ullayer2_tput}

CB008360-5G-B_04_One_Rank2_UE_and_Two_Rank1_UEs_Paired_or_Notpaired_with_online_parameters_change
    [Documentation]    Auther: lei.jia@nokia-sbell.com
    Log To Console    \n***Step1:modify actUlMuMimoTapering = true, ue1 SA call, UE3&4 NSA call***\n
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${-50}    second_beam_horizontal_angle=${-45}    vertical_angle=${-6}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=8
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${-20}    second_beam_horizontal_angle=${-15}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
    ...    first_beam_horizontal_angle=${15}    second_beam_horizontal_angle=${20}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${13}   first_beam_end_output_port=${14}
    ...    second_beam_begin_output_port=${15}    second_beam_end_output_port=${16}
    ...    first_beam_horizontal_angle=${45}    second_beam_horizontal_angle=${50}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=10
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}
    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    ulMaxMuMimoLayer=4    actUlMuMimoTapering=true
    Log To Console    \n***Step2:make ue1 SA call, UE3&4 NSA call, and check tput***\n
    ${ue1_index}    create list    ${1}
    UE Prepare for UES    ues_index=${${1},${2},${3},${4}}
    Disable AutoConnect For 8UE Module    ues_index=${${1},${2},${3},${4}}
    Deployment SA And NSA Mode For 8UE Module    ue_mode=SA    ues_index=${ue1_index}
    Deployment SA And NSA Mode For 8UE Module    ue_mode=NSA    ues_index=${${3},${4}}
    ${ue1_attachinfo_dict}     UE attach for UES    ues_index=${ue1_index}   whether_do_ue_prepare=${False}    ue_mode=SA
    ${ue3_4_attachinfo_dict}     UE attach for UES    ues_index=${${3},${4}}    whether_do_ue_prepare=${False}    ue_mode=NSA
    MultiUE.Start Data Transfer    attachinfo_dict=${ue1_attachinfo_dict}    is_power_ue_code=${True}    ues_index=${ue1_index}   ue_mode=SA
    ...                            whether_start_dl_call=${False}    ul_throughput=70M
    MultiUE.Start Data Transfer    attachinfo_dict=${ue3_4_attachinfo_dict}    is_power_ue_code=${True}    ues_index=${${3},${4}}    ue_mode=NSA
    ...                            whether_start_dl_call=${False}    ul_throughput=70M
    Sleep    10sec
#    ${ttitrace_file_tapering_true}    Run Keyword And Continue On Failure    Capture TTI with gnb logs   cell_index=${tddpcell_index}
#    ...                                                                                                  duration=15
#    ...                                                                                                  tti_log_option=T
#    ...                                                                                                  tti_package_file_name=tti_packed
    ${ttitrace_file_tapering_true}    Capture And Decode TTitrace Log
    ${direction_component_list}=  Create List    UL_L2LO
    set test variable    ${ue_type}    qct_dx50
    Run Keyword And Continue On Failure    Check Tput With Power UE
    ...                         direction_component_list=${direction_component_list}
    ...                         expect_ul_tput=${chbw_40M_ullayer4_tput}
    ...                         duration=120
    ...                         cellid=${tddpcell_index}
    ...                         min_percent=0.1
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
    Log To Console    \n***Step3:modify actUlMuMimoTapering = false, ue1 SA call, UE3&4 NSA call***\n
    Run Keyword And Ignore Error       csn.reset_cache
    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    ulMaxMuMimoLayer=4    actUlMuMimoTapering=false
#    ${ttitrace_file_tapering_false}    Run Keyword And Continue On Failure    Capture TTI with gnb logs   cell_index=${tddpcell_index}
#    ...                                                                                                  duration=15
#    ...                                                                                                  tti_log_option=T
#    ...                                                                                                  tti_package_file_name=tti_packed
    ${ttitrace_file_tapering_false}    Capture And Decode TTitrace Log
    Run Keyword And Continue On Failure    Check Tput With Power UE
    ...                         direction_component_list=${direction_component_list}
    ...                         expect_ul_tput=${chbw_40M_ullayer4_tput}
    ...                         duration=120
    ...                         cellid=${tddpcell_index}
    ...                         min_percent=0.1
    ...                         target_avg_percent=0.8
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
    Run Keyword And Ignore Error    MultiUE.Stop Traffic    ues_index=${ue1_index}
    Run Keyword And Ignore Error    MultiUE.Stop Traffic    ues_index=${${3},${4}}
    Log To Console    \n***check ue paried with tapering in tti for step2***\n
    Run Keyword And Continue On Failure    Check UE Paried Status Via TTITrace    ttitrace_filt_path=${ttitrace_file_tapering_true}
    ...                                    ulmustatus=MUPAIRED_TAPERING
    Evaluate Single UE Average Tput For UL With TTI    file_path=${ttitrace_file_tapering_true}
    ...                                                expect_tput_value=${chbw_40M_ullayer1_tput}
    Log To Console    \n***check ue paried with non taperingin tti for step3***\n
    Run Keyword And Continue On Failure    Check UE Paried Status Via TTITrace    ttitrace_filt_path=${ttitrace_file_tapering_false}
    ...                                    ulmustatus=MUPAIRED_NO_TAPERING
    ...                                    percent_exp=0.75
    Evaluate Single UE Average Tput For UL With TTI    file_path=${ttitrace_file_tapering_false}
    ...                                                expect_tput_value=${chbw_40M_ullayer1_tput}
    ...                                                average_tput_percent=0.8

CB008360-5G-B_15_Two_Rank2_UEs_Paired_with_retransmission_When_Two_UL_C4_subcell_located_at_different_L1pool
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    UE Prepare for UES    ues_index=${${4},${5}}
    Disable AutoConnect For 8UE Module    ues_index=${${4},${5}}
    Deployment SA And NSA Mode For 8UE Module    ue_mode=SA    ues_index=${${4},${5}}
    ${attachinfo_dict}     UE attach for UES    ues_index=${${4},${5}}    whether_do_ue_prepare=${False}    ue_mode=SA
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    is_power_ue_code=${True}    ues_index=${${4},${5}}    ue_mode=SA
    ...                            whether_start_dl_call=${False}    ul_throughput=70M
    Sleep    5sec
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=30
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=25
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}
    Sleep    5sec
    ${ttitrace_file}    Run Keyword And Continue On Failure    Capture TTI with gnb logs   cell_index=${tddpcell_index}
    Check Subcell Allocation Same For Retransmission Data    ttitrace_filt_path=${ttitrace_file}

CB008360-5G-B_05_Four_Rank1_UEs_Paired_or_Notpaired_with_online_parameters_change
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ...                2024/4/7 haoxiaxia: change case to only check 4 rank1 tput
    Log To Console    \n***Multi-UE2: port5/6 θ_h/θ_v:-22/-6 ATT=6, port7/8 θ_h/θ_v:-37/-6 ATT=6
    Log To Console    \n***Multi-UE3: port9/10 θ_h/θ_v:6/-6 ATT=8, port11/12 θ_h/θ_v:21/-6 ATT=8
    Log To Console    \n***Multi-UE3: port13/14 θ_h/θ_v:-6/-6 ATT=8, port15/16 θ_h/θ_v:-21/-6 ATT=8
    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    ulMaxMuMimoLayer=4
    ...    actUlMuMimoTapering=true
    ...    ulMuMimoSinrThd=5
#    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
#    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
#    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
#    ...    first_beam_horizontal_angle=${-50}    second_beam_horizontal_angle=${-52}    vertical_angle=${-6}
#    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
#    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
#    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
#    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
#    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
#    ...    first_beam_horizontal_angle=${36}    second_beam_horizontal_angle=${41}    vertical_angle=${-6}
#    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
#    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
#    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
#    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
#    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
#    ...    first_beam_horizontal_angle=${-7}    second_beam_horizontal_angle=${-15}    vertical_angle=${-6}
#    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
#    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}
#    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
#    ...    first_beam_begin_output_port=${13}   first_beam_end_output_port=${14}
#    ...    second_beam_begin_output_port=${15}    second_beam_end_output_port=${16}
#    ...    first_beam_horizontal_angle=${15}    second_beam_horizontal_angle=${20}    vertical_angle=${-6}
#    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
#    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}
    UE Prepare for UES    ues_index=${${1},${2},${3},${4}}
    Deployment SA And NSA Mode For 8UE Module    ue_mode=NSA    ues_index=${${1},${2},${3},${4}}
    ${attachinfo_dict}     UE attach for UES    ues_index=${${1},${2},${3},${4}}    whether_do_ue_prepare=${False}    ue_mode=NSA
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    is_power_ue_code=${True}    ues_index=${${1},${2},${3},${4}}
    ...                            ue_mode=NSA    whether_start_dl_call=${False}    ul_throughput=70M
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
#    ${ttitrace_file}    Run Keyword And Continue On Failure    Capture TTI with gnb logs   cell_index=${tddpcell_index}
#    ...                   duration=10
    ${ttitrace_file}    Capture And Decode TTitrace Log
    Run Keyword And Ignore Error    MultiUE.Stop Traffic    ues_index=${${1},${2},${3},${4}}
    Update_actUlMuMimoGroupPairing_Values    cell_index=${tddpcell_index}
    ${ue1_index}    create list    ${1}
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    is_power_ue_code=${True}    ues_index=${ue1_index}
    ...                            ue_mode=NSA    whether_start_dl_call=${False}    ul_throughput=70M
     MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    is_power_ue_code=${True}    ues_index=${${2},${3},${4}}
    ...                            ue_mode=NSA    whether_start_dl_call=${False}    ul_throughput=5M
    UPdate All ATT Value
    Sleep    10sec
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
#    ${ttitrace_file_bad}    Run Keyword And Continue On Failure    Capture TTI with gnb logs   cell_index=${tddpcell_index}
#    ...                   duration=10
    ${ttitrace_file_bad}    Capture And Decode TTitrace Log
    Run Keyword And Continue On Failure    Evaluate Single UE Average Tput For UL With TTI
    ...                                    file_path=${ttitrace_file}
    ...                                    expect_tput_value=${chbw_40M_ullayer1_tput}
    Run Keyword And Continue On Failure    Check MUGroup Paried Status Via TTITrace
    ...                                    ttitrace_filt_path=${ttitrace_file_bad}
    ...                                    group_paird_percent_exp=0
#
##    Run Keyword And Continue On Failure    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    whether_start_ul_call=${False}
##    ...                                    ue_mode=NSA    ues_index=${${2},${3},${4},${5}}     is_power_ue_code=${True}
##    Run Keyword And Continue On Failure    Procedures.Check Tput
##    ...                                    ue_type=${UE2_TYPE}
##    ...                                    check_scell_tput=${False}
##    ...                                    scell_mapping=${None}
##    ...                                    tput_collect_duration=120
##    MultiUE.Stop DL Traffic
##    Comment   \n***Step0:test with  ulMaxMuMimoLayer=4 four ues paired***\n
##    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    ulMaxMuMimoLayer=4
##    ${ttitrace_file_0}    Run Keyword And Continue On Failure    Capture TTI with gnb logs   cell_index=${tddpcell_index}   duration=20
##    Comment   \n***Step1:test with ulMuMimoSinrThd = 40: four ues unpaired***\n
##    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    ulMuMimoSinrThd=40    ulMaxMuMimoLayer=4
##    Sleep    5sec
##    ${ttitrace_file_1}    Run Keyword And Continue On Failure    Capture TTI with gnb logs   cell_index=${tddpcell_index}    duration=20
##    Comment   \n***Step2:test with ulMuMimoSinrThd = 40: four ues paired***\n
##    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    ulMuMimoSinrThd=5    ulMaxMuMimoLayer=4
##    Sleep    5sec
##    ${ttitrace_file_2}    Run Keyword And Continue On Failure    Capture TTI with gnb logs   cell_index=${tddpcell_index}    duration=20
#    Comment   \n***Step3:test with ulMuMimoCorrThd2=0: four ues unpaired***\n
#    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    ulMuMimoCorrThd2=1    ulMaxMuMimoLayer=4
#    Sleep    10sec
#    ${ttitrace_file_3}    Run Keyword And Continue On Failure    Capture TTI with gnb logs   cell_index=${tddpcell_index}
#    ...                   duration=60
#    ${direction_component_list}=  Create List    UL_L2LO
#    set test variable    ${ue_type}    qct_dx50
##    Run Keyword And Continue On Failure    Check Tput With Power UE
##    ...                         direction_component_list=${direction_component_list}
##    ...                         expect_ul_tput=${chbw_40M_ullayer1_tput_unpaired}
##    ...                         duration=120
##    ...                         cellid=${tddpcell_index}
##    ...                         min_percent=0.1
#    Comment   \n***Step4:test with ulMuMimoCorrThd2=15: four ues paired***\n
#    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    ulMuMimoCorrThd2=15    ulMaxMuMimoLayer=4
#    Sleep    5sec
#    ${ttitrace_file_4}    Run Keyword And Continue On Failure    Capture TTI with gnb logs   cell_index=${tddpcell_index}
#    ...                   duration=60
##    Run Keyword And Continue On Failure    Check Tput With Power UE
##    ...                         direction_component_list=${direction_component_list}
##    ...                         expect_ul_tput=${chbw_40M_ullayer1_tput}
##    ...                         duration=120
##    ...                         cellid=${tddpcell_index}
##    ...                         min_percent=0.1
#    Recover Collect Syslog On Control PC
#    Start Btslog With Path Check
#    Sleep    1min
#    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}
#    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
#    Recover Collect Syslog On Control PC
#    Run Keyword And Ignore Error    MultiUE.Stop Traffic    ues_index=${${3},${4},${5}}
##    Comment   \n***Step5:test with actUlMuMimoTapering=true: four ues paired***\n
##    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    actUlMuMimoTapering=true    ulMaxMuMimoLayer=4
##    Sleep    5sec
##    ${ttitrace_file_5}    Run Keyword And Continue On Failure    Capture TTI with gnb logs   cell_index=${tddpcell_index}    duration=20
##    Comment   \n***Step6:test with actUlMuMimoTapering=false: four ues paired***\n
##    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    actUlMuMimoTapering=false   ulMaxMuMimoLayer=4
##    Sleep    5sec
##    ${ttitrace_file_6}    Run Keyword And Continue On Failure    Capture TTI with gnb logs   cell_index=${tddpcell_index}    duration=20
##    Comment   \n***Step7:test with ulMaxMuMimoLayer = 2: four ues paired***\n
##    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    ulMaxMuMimoLayer=2
##    Sleep    5sec
##    ${ttitrace_file_7}    Run Keyword And Continue On Failure    Capture TTI with gnb logs   cell_index=${tddpcell_index}    duration=20
##    Run Keyword And Continue On Failure    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    whether_start_ul_call=${False}
##    ...                                    ue_mode=NSA    ues_index=${${2},${3},${4},${5}}     is_power_ue_code=${True}
##    Run Keyword And Continue On Failure    Procedures.Check Tput
##    ...                                    ue_type=${UE2_TYPE}
##    ...                                    check_scell_tput=${False}
##    ...                                    scell_mapping=${None}
##    ...                                    tput_collect_duration=120
#    Comment    \n***All Checkpoints For TTItrace***\n
##    Run Keyword And Continue On Failure    Check Ues Subcells Allocation And ulMuStaus    ttitrace_file=${ttitrace_file_0}
##    ...                                    cell_index=${tddpcell_index}    subcell0_rnti_number=2    subcell1_rnti_number=2
##    Run Keyword And Continue On Failure    Check Ues Subcells Allocation And ulMuStaus    ttitrace_file=${ttitrace_file_1}
##    ...                                    cell_index=${tddpcell_index}    ulMuStatus=MUNEEDLESS    exp_staus=notPaired
##    Run Keyword And Continue On Failure    Check Ues Subcells Allocation And ulMuStaus    ttitrace_file=${ttitrace_file_2}
##    ...                                    cell_index=${tddpcell_index}    subcell0_rnti_number=2    subcell1_rnti_number=2
#    Run Keyword And Continue On Failure    check_ue_unpaired_with_corrthd_not_reached    file_path=${ttitrace_file_3}
#    Run Keyword And Continue On Failure    Check Ues Subcells Allocation And ulMuStaus    ttitrace_file=${ttitrace_file_4}
#    ...                                    cell_index=${tddpcell_index}    subcell0_rnti_number=2    subcell1_rnti_number=2
#    ...                                    percent_exp=0.90
#    Run Keyword And Continue On Failure    Evaluate Single UE Average Tput For UL With TTI
#    ...                                    file_path=${ttitrace_file_3}
#    ...                                    expect_tput_value=${chbw_40M_ullayer1_tput_unpaired}
##    Run Keyword And Continue On Failure    Evaluate Single UE Average Tput For UL With TTI    file_path=${ttitrace_file_4}
##    ...                                                                                       expect_tput_value=${chbw_40M_ullayer1_tput}
##    Run Keyword And Continue On Failure    Check Ues Subcells Allocation And ulMuStaus    ttitrace_file=${ttitrace_file_5}
##    ...                                    cell_index=${tddpcell_index}    subcell0_rnti_number=2    subcell1_rnti_number=2
##    ...                                    ulMuStatus=MUPAIRED_TAPERING
##    Run Keyword And Continue On Failure    Check Ues Subcells Allocation And ulMuStaus    ttitrace_file=${ttitrace_file_6}
##    ...                                    cell_index=${tddpcell_index}    subcell0_rnti_number=2    subcell1_rnti_number=2
##    Run Keyword And Continue On Failure    Check Ues Subcells Allocation And ulMuStaus    ttitrace_file=${ttitrace_file_7}
##    ...                                    cell_index=${tddpcell_index}    subcell0_rnti_number=4
##    Check VirtualUes Number For 4UES Per Slot    ttitrace_file=${ttitrace_file_7}

CB008360-5G-B_09_Eight_UEs_Paired_with_rdactUlMuMimoEnhance=false
    [Documentation]    Auther: lei.jia@nokia-sbell.com
    Log To Console    Step1:modify swconfig to rdActUlMuMimoEnhance_false
    Backup and Modify swconfig file    is_called_in_test_case_level=${True}    swconfig_modify=${SWCONFIG_rdActUlMuMimoEnhance_false}
    CB008360_keywords.COAM gNB Reset site and Wait Onair
    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    actUlMuMimoTapering=true    ulMaxMuMimoLayer=4
    UE Prepare for UES    ues_index=${${2},${3},${4},${5}}
    Disable AutoConnect For 8UE Module    ues_index=${${2},${3},${4},${5}}
    Log To Console    Step2:ue attach in NSA mode, ue1 start traffic 24M, ue2/3/4 start traffic with low tput 2M.
    ${ue2_index}    create list    ${2}
    Deployment SA And NSA Mode For 8UE Module    ue_mode=NSA    ues_index=${${2},${3},${4},${5}}
    ${attachinfo_dict}     UE attach for UES    ues_index=${${2},${3},${4},${5}}    whether_do_ue_prepare=${False}    ue_mode=NSA
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    is_power_ue_code=${True}    ues_index=${ue2_index}
    ...                            ue_mode=NSA    whether_start_dl_call=${False}    ul_throughput=24M
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    is_power_ue_code=${True}    ues_index=${${3},${4},${5}}
    ...                            ue_mode=NSA    whether_start_dl_call=${False}    ul_throughput=2M
    Log To Console    \nStep3:start to check UL tput, for chbw 40M NSA call
    set test variable    ${ue_type}    qct_dx50
    ${direction_component_list}=  Create List    UL_L2LO
    Run Keyword And Continue On Failure    Check Tput With Power UE
    ...                                    direction_component_list=${direction_component_list}
    ...                                    expect_ul_tput=${chbw_40M_ullayer1_tput}
    ...                                    duration=120
    ...                                    cellid=${tddpcell_index}
    ...                                    min_percent=0.1
    ...                                   target_avg_percent=0.95
    Log To Console    \nStart to capture tti and check ulMuStatus and ulMuGroupStatus
    ${ttitrace_file_0}    Run Keyword And Continue On Failure    Capture TTI with gnb logs   cell_index=${tddpcell_index}   duration=20
    Log To Console    Checkpoint2: MUPAIRED_NO_TAPERING,MUPAIRED_TAPERING, MUPAIRED_TAPERING_SIMPLERE, MUPAIRED_NON_TAPERING_SIMPLERE is about 11%
    Log To Console    Checkpoint3: MUGROUPSPAIRED_TAPERING_ROOT, MUGROUPSPAIRED_TAPERING_INGROUP in ulMuGroupStatus is 0%
    Run Keyword And Continue On Failure    check_ulMuStatus_and_ulMuGroupStatus_ratio_for_ues    file_path=${ttitrace_file_0}
    ...                                                                                          percent_exp=0.11
    ...                                                                                          group_paird_percent_exp=0
    [Teardown]    run keywords
    ...    Connect to Common Unit Master    AND
    ...    Run Keyword And Ignore Error    swconf.restore_swConfig_file_on_asik_and_crasign    asik_alias=ASIK Master    AND
    ...    Run Keyword And Ignore Error    CB008360_keywords.COAM gNB Reset site and Wait Onair

CB008360-5G-B_10_Eight_UEs_Paired_with_rdactUlMuMimoEnhance=true
    [Documentation]    Auther: lei.jia@nokia-sbell.com
    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    actUlMuMimoTapering=true    ulMaxMuMimoLayer=4
    Log To Console    Step1:modify swconfig to rdActUlMuMimoEnhance_true
    Backup and Modify swconfig file    is_called_in_test_case_level=${True}    swconfig_modify=${SWCONFIG_rdActUlMuMimoEnhance_true}
    CB008360_keywords.COAM gNB Reset site and Wait Onair
    UE Prepare for UES    ues_index=${${2},${3},${4},${5}}
    Disable AutoConnect For 8UE Module    ues_index=${${2},${3},${4},${5}}
    Log To Console    Step2:ue attach in NSA mode, ue1 start traffic 24M, ue2/3/4 start traffic with low tput 2M.
    ${ue2_index}    create list    ${2}
    Deployment SA And NSA Mode For 8UE Module    ue_mode=NSA    ues_index=${${2},${3},${4},${5}}
    ${attachinfo_dict}     UE attach for UES    ues_index=${${2},${3},${4},${5}}    whether_do_ue_prepare=${False}    ue_mode=NSA
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    is_power_ue_code=${True}    ues_index=${ue2_index}
    ...                            ue_mode=NSA    whether_start_dl_call=${False}    ul_throughput=24M
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    is_power_ue_code=${True}    ues_index=${${3},${4},${5}}
    ...                            ue_mode=NSA    whether_start_dl_call=${False}    ul_throughput=2M
    Log To Console    \nStep3:start to check UL tput, for chbw 40M NSA call
    set test variable    ${ue_type}    qct_dx50
    ${direction_component_list}=  Create List    UL_L2LO
    Run Keyword And Continue On Failure    Check Tput With Power UE
    ...                                    direction_component_list=${direction_component_list}
    ...                                    expect_ul_tput=${chbw_40M_ullayer1_tput}
    ...                                    duration=120
    ...                                    cellid=${tddpcell_index}
    ...                                    min_percent=0.1
    ...                                   target_avg_percent=1.0
    Log To Console    \nStart to capture tti and check ulMuStatus and ulMuGroupStatus
    ${ttitrace_file_0}    Run Keyword And Continue On Failure    Capture TTI with gnb logs   cell_index=${tddpcell_index}   duration=20
    Log To Console    Checkpoint2: MUPAIRED_NO_TAPERING,MUPAIRED_TAPERING, MUPAIRED_TAPERING_SIMPLERE, MUPAIRED_NON_TAPERING_SIMPLERE is about 18%
    Log To Console    Checkpoint3: MUGROUPSPAIRED_TAPERING_ROOT, MUGROUPSPAIRED_TAPERING_INGROUP in ulMuGroupStatus is 20%
    Run Keyword And Continue On Failure    check_ulMuStatus_and_ulMuGroupStatus_ratio_for_ues    file_path=${ttitrace_file_0}
    ...                                                                                          percent_exp=0.18
    ...                                                                                          group_paird_percent_exp=0.20
    [Teardown]    run keywords
    ...    Connect to Common Unit Master    AND
    ...    Run Keyword And Ignore Error    swconf.restore_swConfig_file_on_asik_and_crasign    asik_alias=ASIK Master    AND
    ...    Run Keyword And Ignore Error    CB008360_keywords.COAM gNB Reset site and Wait Onair

CB008360-5G-W_02_Cell_UL_Peak_Throughput_Four_Rank1_Ues
    [Documentation]    Author: lei.jia@nokia-sbell.com
    Log To Console    Step1:modify frame structure to 1208 + 100M + 8D8U + UL 256QAM OFF
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${37}    second_beam_horizontal_angle=${52}    vertical_angle=${-12}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=8
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${-38}    second_beam_horizontal_angle=${-53}    vertical_angle=${-6}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=8
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
    ...    first_beam_horizontal_angle=${6}    second_beam_horizontal_angle=${20}    vertical_angle=${-6}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=8
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${13}   first_beam_end_output_port=${14}
    ...    second_beam_begin_output_port=${15}    second_beam_end_output_port=${16}
    ...    first_beam_horizontal_angle=${-10}    second_beam_horizontal_angle=${-30}    vertical_angle=${-12}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=8
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${scf_name_prefix}    Set Variable    ${Golden_SCF_Path.split('SBTS')[0]}
    Common_setup_and_teardown.Case Common SetUp    update_param_name=${MODIFY_SCF_fs_1208__chbw_100MHz}
    ...                  is_dynamic_pdcch_update=${True}
    ...                  is_case_level_update_params_exist=${True}
    ...                  scf_file_path=${scf_name_prefix}${stream}_CB008360_B.xml
    Sleep 	90s 	Wait for calibration setup
    UE Prepare for UES    ues_index=${${2},${3},${4},${5}}
    Disable AutoConnect For 8UE Module    ues_index=${${2},${3},${4},${5}}
    Log To Console    Step2:ue attach in NSA mode, start ul&dl traffic.
    Deployment SA And NSA Mode For 8UE Module    ue_mode=NSA    ues_index=${${2},${3},${4},${5}}
    ${attachinfo_dict}     UE attach for UES    ues_index=${${2},${3},${4},${5}}    whether_do_ue_prepare=${False}    ue_mode=NSA
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    is_power_ue_code=${True}    ues_index=${${2},${3},${4},${5}}
    ...                            ue_mode=NSA    whether_start_dl_call=${False}    ul_throughput=120M
    Log To Console    \nStart to capture tti and check ulpaired
    ${ttitrace_file}    Run Keyword And Continue On Failure    Capture TTI with gnb logs   cell_index=${tddpcell_index}   duration=10
    Run Keyword And Continue On Failure    Check UE Paried Status Via TTITrace    ttitrace_filt_path=${ttitrace_file}
    ...                                    ulmustatus=MUPAIRED_TAPERING
    Evaluate Single UE Average Tput For UL With TTI    file_path=${ttitrace_file}
    ...                                                expect_tput_value=${chbw_100M_ullayer1_ul64qam_tput}

CB008360-5G-W_06_Cell_Performance_With_Two_Rank2_UEs_and_2C4_Subcell_UL_MuMimo_On_VS_OFF_AWGN
    [Documentation]    Auther: lei.jia@nokia-sbell.com
    Set MCS Phase For SA MultiUE PAIRED
    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    actUlMuMimoTapering=true    ulMaxMuMimoLayer=4
    Log To Console    \n***Step0: set 8360 off and run performance testing
    Update Prameter actUlMuMimo    update_value=false    cell_index=${tddpcell_index}
    Log To Console    \n***Step1: ue attach for two SA UES
    UE Prepare for UES    ues_index=${${2},${3},${4},${5}}
    Disable AutoConnect For 8UE Module    ues_index=${${2},${3},${4},${5}}
    Deployment SA And NSA Mode For 8UE Module    ue_mode=SA    ues_index=${${2},${3}}
    Run Keyword And Ignore Error    UE Deattach for UEs    ues_index=${${2},${3},${4},${5}}    is_power_ue_code=${True}
    ${attachinfo_dict}     UE attach for UES    ues_index=${${2},${3}}    whether_do_ue_prepare=${False}    ue_mode=SA
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    is_power_ue_code=${True}    ues_index=${${2},${3}}    ue_mode=SA
    ...                            whether_start_dl_call=${False}    ul_throughput=70M
    Log To Console    \n***keep traffic ongoing the whole case, Start Performance from Good to Worse!
    Log To Console    \n***Step3: adjust RSRP for good: att=10, move from H[-60, +50], V[-6]and check tput
    set test variable    ${ue_type}    qct_dx50
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=10
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    ${tput_log_good}    Capturing Aasyslog through all the performance testing    att_value=10
    ${UL_TPUT_GOOD_8360_off}    Run Keyword And Continue On Failure    Check Tput For all the performance testing
    ...    cellid=${tddpcell_index}
    ...    tput_log=${tput_log_good}    expect_ul_tput=50
    Log To Console    \n***Step4: adjust RSRP for medium: att=22, move from H[-60, +50], V[-6]and check tput
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=22
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    ${tput_log_medium}    Capturing Aasyslog through all the performance testing    att_value=22
    ${UL_TPUT_MEDIUM_8360_off}    Run Keyword And Continue On Failure    Check Tput For all the performance testing
    ...    cellid=${tddpcell_index}
    ...    tput_log=${tput_log_medium}    expect_ul_tput=40
    Log To Console    \n***Step5: adjust RSRP for Worse: att=32, move from [-60, +50], V[-6]and check tput
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=32
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    ${tput_log_worse}    Capturing Aasyslog through all the performance testing    att_value=32
    ${UL_TPUT_WORSE_8360_off}    Run Keyword And Continue On Failure    Check Tput For all the performance testing
    ...    cellid=${tddpcell_index}
    ...    tput_log=${tput_log_worse}    expect_ul_tput=24
    Run Keyword And Ignore Error    MultiUE.Stop Traffic    ues_index=${${2},${3}}
    Run Keyword And Ignore Error    UE Deattach for UEs    ues_index=${${2},${3},${4},${5}}    is_power_ue_code=${True}
    Log To Console    \n***Step6: set 8360 on and run performance testing
    Update Prameter actUlMuMimo    update_value=true    cell_index=${tddpcell_index}
#    Deployment SA And NSA Mode For 8UE Module    ue_mode=SA    ues_index=${${2},${3}}
    Run Keyword And Ignore Error    UE Deattach for UEs    ues_index=${${2},${3},${4},${5}}    is_power_ue_code=${True}
    ${attachinfo_dict}     UE attach for UES    ues_index=${${2},${3}}    whether_do_ue_prepare=${False}    ue_mode=SA
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    is_power_ue_code=${True}    ues_index=${${2},${3}}    ue_mode=SA
    ...                            whether_start_dl_call=${False}    ul_throughput=70M
    Log To Console    \n***keep traffic ongoing the whole case, Start Performance from Good to Worse!
    Log To Console    \n***Step7: adjust RSRP for good: att=10, move from H[-60, +50], V[-6]and check tput
    set test variable    ${ue_type}    qct_dx50
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=10
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    ${tput_log_good}    Capturing Aasyslog through all the performance testing    att_value=10
    ${UL_TPUT_GOOD_8360_on}    Run Keyword And Continue On Failure    Check Tput For all the performance testing
    ...    cellid=${tddpcell_index}
    ...    tput_log=${tput_log_good}    expect_ul_tput=78
    Log To Console    \n***Step8: adjust RSRP for medium: att=22, move from H[-60, +50], V[-6]and check tput
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=22
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    ${tput_log_medium}    Capturing Aasyslog through all the performance testing    att_value=22
    ${UL_TPUT_MEDIUM_8360_on}    Run Keyword And Continue On Failure    Check Tput For all the performance testing
    ...    cellid=${tddpcell_index}
    ...    tput_log=${tput_log_medium}    expect_ul_tput=42
    Log To Console    \n***Step9: adjust RSRP for Worse: att=32, move from [-60, +50], V[-6]and check tput
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=32
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    ${tput_log_worse}    Capturing Aasyslog through all the performance testing    att_value=32
    ${UL_TPUT_WORSE_8360_on}    Run Keyword And Continue On Failure    Check Tput For all the performance testing
    ...    cellid=${tddpcell_index}
    ...    tput_log=${tput_log_worse}    expect_ul_tput=24
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
    Run Keyword And Ignore Error    MultiUE.Stop Traffic    ues_index=${${2},${3}}
    Should Be True    ${UL_TPUT_GOOD_8360_on[0]['average']} > ${UL_TPUT_GOOD_8360_off[0]['average']}
    Should Be True    ${UL_TPUT_MEDIUM_8360_on[0]['average']} > ${UL_TPUT_MEDIUM_8360_off[0]['average']}

CB008360-5G-D_01_UL_MuMIMO_with_Retransmission
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ${modify_cell_chbw_dict}    Create Dictionary     3    40MHz
    Log to console    start to update chbw:${modify_cell_chbw_dict}
    Update Chbw Dynamic Pdcch And Wait Gnb On Air     modify_cell_chbw_dict=${modify_cell_chbw_dict}
    ...                                               scf_file_path=${Golden_SCF_Path.split('.xm')[0]}_CB008360_D.xml
    ...                                               modify_cell_ids=part_cell
    ...                                               wait_gnb_up_timeout=30 min
    Online delete objects via rest api    objects_to_delete_via_api=${Cablink_TO_DELETE}
    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    ulMaxMuMimoLayer=4    actUlMuMimoTapering=true
    ...                              ulMuMimoSinrThd=5
    ${two_subcell_allocation_result}    Run Keyword And Continue On Failure    Check Two Subcells Allocation
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${-50}    second_beam_horizontal_angle=${-52}    vertical_angle=${-6}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${45}    second_beam_horizontal_angle=${50}    vertical_angle=${-6}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
    ...    first_beam_horizontal_angle=${-7}    second_beam_horizontal_angle=${-15}    vertical_angle=${-6}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${13}   first_beam_end_output_port=${14}
    ...    second_beam_begin_output_port=${15}    second_beam_end_output_port=${16}
    ...    first_beam_horizontal_angle=${20}    second_beam_horizontal_angle=${25}    vertical_angle=${-6}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}
#    UE Prepare for UES    ues_index=${${2},${3},${4},${5}}
#    Deployment SA And NSA Mode For 8UE Module    ue_mode=SA    ues_index=${${3},${5}}
#    Run Keyword And Ignore Error    UE Deattach for UEs    ues_index=${${2},${3},${4},${5}}    is_power_ue_code=${True}
#    Sleep  10sec
#    ${attachinfo_dict_SA}     UE attach for UES    ue_mode=SA    ues_index=${${3},${5}}    whether_do_ue_prepare=${False}
#    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict_SA}    is_power_ue_code=${True}    ues_index=${${3},${5}}    ue_mode=SA
#    ...                            whether_start_dl_call=${False}    ul_throughput=70M
#    Sleep    5sec
#    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=24
#    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}
#    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=24
#    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
#    Sleep    5sec
#    ${sa_retrans_round1}    Run Keyword And Continue On Failure    Capture TTI with gnb logs
#    ...                                                            cell_index=${tddpcell_index}
#    ...                                                            duration=90
#    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
#    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}
#    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
#    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
#    Sleep    30sec
#    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=24
#    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}
#    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=24
#    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
#    Sleep    8sec
#    ${sa_retrans_round2}    Run Keyword And Continue On Failure    Capture TTI with gnb logs
#    ...                                                            cell_index=${tddpcell_index}
#    ...                                                            duration=90
#    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
#    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}
#    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=6
#    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
#    Sleep    30sec
#    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=24
#    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}
#    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=24
#    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
#    Sleep    8sec
#    ${sa_retrans_round3}    Run Keyword And Continue On Failure    Capture TTI with gnb logs
#    ...                                                            cell_index=${tddpcell_index}
#    ...                                                            duration=90
#    Run Keyword And Ignore Error    MultiUE.Stop Traffic    ues_index=${${3},${5}}
#    Run Keyword And Ignore Error    UE Deattach for UEs    ues_index=${${3},${5}}    is_power_ue_code=${True}
#    Sleep  10sec
#    Run Keyword If    '${two_subcell_allocation_result}'=='FAIL'    Run Keyword And Continue On Failure
#    ...    Check Subcell Allocation Same For Retransmission Data   ttitrace_file=${sa_retrans_round1}
#    ${sa_retrans_pair_status}    ${sa_simple_pair}    ${sa_normal_pair}    Check Retransmission UEs Mustatus
#    ...    ttitrace_file=${sa_retrans_round1}
#    ${sa_retrans_pair_status}    ${sa_simple_pair}    ${sa_normal_pair}    Run Keyword Unless    ${sa_retrans_pair_status}
#    ...    Check Retransmission UEs Mustatus    ttitrace_file=${sa_retrans_round2}
#    ${sa_retrans_pair_status}    ${sa_simple_pair}    ${sa_normal_pair}    Run Keyword Unless    ${sa_retrans_pair_status}
#    ...    Check Retransmission UEs Mustatus    ttitrace_file=${sa_retrans_round3}
#    Run Keyword And Continue On Failure    Should Be True    '${sa_simple_pair}'=='${True}'
#    ...    msg=simple pair is not triggered for SA retransmission.
#    Run Keyword And Continue On Failure    Should Be True    '${sa_normal_pair}'=='${True}'
#    ...    msg=normal pair is not triggered for SA retransmission.
    UE Prepare for UES    ues_index=${${2},${3},${4},${5}}
    Deployment SA And NSA Mode For 8UE Module    ue_mode=NSA    ues_index=${${2},${3},${4},${5}}
    Run Keyword And Ignore Error    UE Deattach for UEs    ues_index=${${2},${3},${4},${5}}    is_power_ue_code=${True}
    Sleep    10sec
    ${attachinfo_dict_NSA}     UE attach for UES    ue_mode=NSA    ues_index=${${2},${3},${4},${5}}    whether_do_ue_prepare=${False}
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict_NSA}    is_power_ue_code=${True}    ues_index=${${2},${3},${4},${5}}
    ...                            ue_mode=NSA    whether_start_dl_call=${False}    ul_throughput=70M
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=24
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=26
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=22
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    att_value=28
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    Sleep    5sec
    ${nsa_retrans_round1}    Run Keyword And Continue On Failure    Capture TTI with gnb logs
    ...                                                            cell_index=${tddpcell_index}
    ...                                                            duration=120
    Sleep    5sec
    Run Keyword And Ignore Error    MultiUE.Stop Traffic    ues_index=${${2},${3},${4},${5}}
    Run Keyword If    '${two_subcell_allocation_result}'=='FAIL'    Run Keyword And Continue On Failure
    ...    Check Subcell Allocation Same For Retransmission Data   ttitrace_file=${nsa_retrans_round1}
    ${nsa_retrans_pair_status}    ${nsa_simple_pair}    ${nsa_normal_pair}    Check Retransmission UEs Mustatus
    ...    ttitrace_file=${nsa_retrans_round1}
    Run Keyword And Continue On Failure    Should Be True    '${nsa_simple_pair}'=='${True}'
    ...    msg=simple pair is not triggered for NSA retransmission.
    Run Keyword And Continue On Failure    Should Be True    '${nsa_normal_pair}'=='${True}'
    ...    msg=normal pair is not triggered for NSA retransmission.
#----------#
#    ${nsa_retrans_round2}    Run Keyword And Continue On Failure    Capture TTI with gnb logs
#    ...                                                             cell_index=${tddpcell_index}
#    ...                                                             duration=60
#    Sleep    5sec
#    ${nsa_retrans_round3}    Run Keyword And Continue On Failure    Capture TTI with gnb logs
#    ...                                                             cell_index=${tddpcell_index}
#    ...                                                             duration=60
#    ${nsa_retrans_pair_status}    ${nsa_simple_pair}    ${nsa_normal_pair}    Run Keyword Unless    ${nsa_retrans_pair_status}
#    ...    Check Retransmission UEs Mustatus    ttitrace_file=${nsa_retrans_round2}
#    ${nsa_retrans_pair_status}    ${nsa_simple_pair}    ${nsa_normal_pair}    Run Keyword Unless    ${nsa_retrans_pair_status}
#    ...    Check Retransmission UEs Mustatus    ttitrace_file=${nsa_retrans_round3}


CB008360-5G-W_01_Cell_UL_Peak_Throughput_Two_Rank2_UEs
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    Set MCS Phase For SA MultiUE PAIRED
    ${modify_cell_chbw_dict}    Create Dictionary     3    100MHz
    Log to console    start to update chbw:${modify_cell_chbw_dict}
    Update Chbw Dynamic Pdcch And Wait Gnb On Air     modify_cell_chbw_dict=${modify_cell_chbw_dict}
    ...                                               scf_file_path=${Golden_SCF_Path.split('.xm')[0]}_CB008360_D.xml
    ...                                               modify_cell_ids=part_cell
    ...                                               wait_gnb_up_timeout=30 min
    Generate Pcell Mapping Info    pcell_index=${tddpcell_index}
    Update ULMUMIMO Related Paras    cell_index=${tddpcell_index}    ulMaxMuMimoLayer=4
    UE Prepare for UES    ues_index=${${3},${4}}
    Disable AutoConnect For 8UE Module    ues_index=${${3},${4}}
    Deployment SA And NSA Mode For 8UE Module    ue_mode=SA    ues_index=${${3},${4}}
    Run Keyword And Ignore Error    UE Deattach for UEs    ues_index=${${2},${3},${4},${5}}    is_power_ue_code=${True}
    Sleep  10sec
    ${attachinfo_dict}     UE attach for UES    ues_index=${${3},${4}}    whether_do_ue_prepare=${False}    ue_mode=SA
    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    is_power_ue_code=${True}    ues_index=${${3},${4}}    ue_mode=SA
    ...                            whether_start_dl_call=${False}    ul_throughput=150M
    Sleep    10sec
#    ${ttitrace_file}    Run Keyword And Continue On Failure    Capture TTI with gnb logs   cell_index=${tddpcell_index}
    ${ttitrace_file}    Capture And Decode TTitrace Log
    Run Keyword And Continue On Failure    MultiUE.Start Data Transfer    attachinfo_dict=${attachinfo_dict}    whether_start_ul_call=${False}
    ...                                    ue_mode=SA    ues_index=${${3},${4}}    is_power_ue_code=${True}    dl_throughput=1500MKbits/sec
    Run Keyword And Continue On Failure    Procedures.Check Tput
    ...                                    ue_type=${UE2_TYPE}
    ...                                    check_scell_tput=${False}
    ...                                    scell_mapping=${None}
    ...                                    tput_collect_duration=180
    ...                                    min_UL_percent=0
    ...                                    min_DL_percent=0
    ...                                    target_DL_avg_percent=0.2
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
    Run Keyword And Ignore Error    MultiUE.Stop Traffic    ues_index=${${3},${4}}
    Run Keyword And Continue On Failure    Check UE Paried Status Via TTITrace    ttitrace_filt_path=${ttitrace_file}
    ...                                    percent_exp=0.94
    Run Keyword And Continue On Failure    Evaluate Single UE Average Tput For UL With TTI    file_path=${ttitrace_file}
    ...                                                expect_tput_value=${chbw_100M_ullayer2_tput}
