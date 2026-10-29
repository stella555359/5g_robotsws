*** Settings ***
Documentation    Author:lei.jia@nokia-sbell.com

Resource    ./CB008247_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008360/Resources/aaslog_keywords.robot
Variables   ../TestData/CB008247_variables.py

*** Keywords ***
#---  TestCases KW  ---#
CB008247-A_Beam_Switch_with_DFT_beams_got_from_TAS_used_for_DL_and_UL_follow_P-SRS
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${first_beam_begin_output_port}=${5}    ${first_beam_end_output_port}=${6}
    ...             ${second_beam_begin_output_port}=${7}    ${second_beam_end_output_port}=${8}
    Log To Console    Step1:Second SSB: port5/6 θ_h/θ_v:-7/-6 ATT=15, Best SSB: port7/8 θ_h/θ_v:-22/-6 ATT=10
    TOPYONG MCS ON AEHC With QC UE    att_value1=15    att_value2=10
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    ${cpif_log_path}    ${bip_log_beamswitch_scenario1}    Make_L3_Call_And_Check_Tput
    ...    is_need_stop_traffic=${False}
    Run Keyword And Continue On Failure    DFTBeam Should Be Used In BIP with mcshark    file_path=${bip_log_beamswitch_scenario1}
    Run Keyword And Continue On Failure    Check TAS SRS Is Used in RRC Message    file_path=${cpif_log_path}
    Check srsForBeamMgmt Is Same in SCF And RRC Message    file_path=${cpif_log_path}    cell_idx=${cell_idx}
    Log To Console    \n***keep traffic ongoing the whole case!
    Log To Console    Step2:modify att vaule to trigger best and second best beam switch, port9/10 att=10(best SSB), port11/12 att=15(second best)
    CB008247_keywords.Set Odd And Even ATT For Four Output Ports With Different Values    mcs_type=${mcs_type}    att_value1=10    att_value2=15
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    Sleep    10s
    ${bip_log_beamswitch_scenario2}    Start And Stop Bip Capture
    Run Keyword And Continue On Failure    Check Tput For CA Group
    ...                                    ue_type=${ue_type}
    ...                                    target_DL_avg_percent=0.9
    ...                                    target_UL_avg_percent=0.9
    ...                                    check_pcell_tput=${True}
    ...                                    check_scell_tput=${False}
    ...                                    scell_mapping=${None}
    Log To Console    Step3:modify best beam θ_h to trigger beam swith, port9/10 θ_h=-11 att=10(best SSB), port11/12 θ_h=-22 att=15(second best)
    Start Bip Capture
    CB008247_keywords.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    first_beam_horizontal_angle=${-11}
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    Sleep    5s
    ${bip_log_beamswitch_sce3_list}    Stop Bip Capture   asib_interface=eths3
    ${bip_log_beamswitch_scenario3}    Set Variable    ${bip_log_beamswitch_sce3_list[0]}
    Run Keyword And Continue On Failure    Check Tput For CA Group
    ...                                    ue_type=${ue_type}
    ...                                    target_DL_avg_percent=0.9
    ...                                    target_UL_avg_percent=0.9
    ...                                    check_pcell_tput=${True}
    ...                                    check_scell_tput=${False}
    ...                                    scell_mapping=${None}
    Log To Console    Check point1:from scenario1 to scenario2, SSB no change, first best beam and second best beam switch.
    ${PatternId_beamswitch_scenario1}    Run Keyword And Continue On Failure    Get patternId From BIP Log with mcshark
    ...    file_path=${bip_log_beamswitch_scenario1}
    ${PatternId_beamswitch_scenario2}    Run Keyword And Continue On Failure    Get patternId From BIP Log with mcshark
    ...    file_path=${bip_log_beamswitch_scenario2}
    Should Not Be Equal    ${PatternId_beamswitch_scenario1}    ${PatternId_beamswitch_scenario2}
    ...    msg="Pattern id is not changed from scenario1 to scenario2!"
    Log To Console    Check point2: from scenario2 to scenario3, TCI state change for best beam, DFT beam changed!
    ${PatternId_beamswitch_scenario3}    Run Keyword And Continue On Failure    Get patternId From BIP Log with mcshark
    ...    file_path=${bip_log_beamswitch_scenario3}
    Should Not Be Equal    ${PatternId_beamswitch_scenario2}    ${PatternId_beamswitch_scenario3}
    ...    msg="Pattern id is not changed from scenario2 to scenario3!"
    ${beamId_beamswitch_scenario2}    CB008247_keywords.Get BeamId From BIP Log with mcshark    file_path=${bip_log_beamswitch_scenario2}
    ${beamId_beamswitch_scenario3}    CB008247_keywords.Get BeamId From BIP Log with mcshark    file_path=${bip_log_beamswitch_scenario3}
    Should Not Be Equal    ${beamId_beamswitch_scenario2}    ${beamId_beamswitch_scenario3}
    ...    msg="DFT beam is not changed from scenario2 to scenario3!"

CB008247-A_Traffic_DFT_beams_got_from_TAS_used_for_PDCCH_PDSCH_UE-specific-CSI-RS_with_UL_follow_AP-SRS
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${first_beam_begin_output_port}=${5}    ${first_beam_end_output_port}=${6}
    ...             ${second_beam_begin_output_port}=${7}    ${second_beam_end_output_port}=${8}
    Log To Console    \nStep1:modify parameters to make 1086 off, 8247 on, start L3 call and check tput
    Modify Paras via SCF    parameters_to_update=${MODIFY_PARA_1086_off_8247_on_cni92005}
    Sleep 	90s 	Wait for calibration setup
    Log To Console    Step1:Second SSB: port5/6 θ_h/θ_v:-7/-6 ATT=10, Best SSB: port7/8 θ_h/θ_v:-22/-6 ATT=10
    TOPYONG MCS ON AEHC With QC UE
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    ${cpif_log_path}    ${bip_log_1086_off}    Make_L3_Call_And_Check_Tput
    Run Keyword And Continue On Failure    DFTBeam Should Be Used In BIP with mcshark    file_path=${bip_log_1086_off}
    Run Keyword And Continue On Failure    Check TAS SRS and Codebook AP SRS Is Used in RRC Message    file_path=${cpif_log_path}
    Run Keyword And Continue On Failure    Check 2 SRS Ports Used in RRC Message   file_path=${cpif_log_path}
    Check srsForBeamMgmt Is Same in SCF And RRC Message    file_path=${cpif_log_path}    cell_idx=${cell_idx}
    Log To Console    \nStep3:enable actCoverageNonCoherentUes, make new l3 call and check tput
    Modify Paras via SCF    parameters_to_update=${MODIFY_PARA_1086_off_actCoverageNonCoherentUes_on_cni92005}
    Sleep 	90s 	Wait for calibration setup
    ${cpif_log_actCov_on_channel_good}    ${bip_log_actCov_on}    Run Keyword And Continue On Failure    Make_L3_Call_And_Check_Tput
    ...                                    is_do_require_ue=${False}
    ...                                    is_need_stop_traffic=${False}
    Run Keyword And Continue On Failure    Check 2 SRS Ports Used in RRC Message   file_path=${cpif_log_actCov_on_channel_good}
    Log To Console    \nStep4:keep traffic ongoing, and ajust mcs att value to make channel condition bad!
    #    Best SSB: port9/10 θ_h/θ_v:-7/-6 ATT=32, Second SSB: port11/12 θ_h/θ_v:-22/-6 ATT=32
    ${attach_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
#    Start Container Capture Wireshark Log    tcpdump_collector_name=cpif_${attach_timestamp}    options=-i any -s 0
    CB008247_keywords.Set Odd And Even ATT For Four Output Ports With Different Values    mcs_type=${mcs_type}    att_value1=32    att_value2=32
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    Sleep    10s
#    ${cpif_log_actCov_on_channel_bad}    Stop Container Wireshark Log Collection    tcpdump_collector_name=cpif_${attach_timestamp}
    Run Keyword And Continue On Failure    Check Tput For CA Group
    ...                                    ue_type=${ue_type}
    ...                                    check_pcell_tput_type=not_peak
    ...                                    check_ul_pcell_tput_type=not_peak
    ...                                    check_pcell_tput=${True}
    ...                                    check_scell_tput=${False}
    ...                                    scell_mapping=${None}
    Log To Console    \nStep5:keep traffic ongoing, and ajust mcs att value to make channel condition good again!
    #    Best SSB: port9/10 θ_h/θ_v:-7/-6 ATT=10, Second SSB: port11/12 θ_h/θ_v:-22/-6 ATT=10
    ${attach_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
#    Start Container Capture Wireshark Log    tcpdump_collector_name=cpif_${attach_timestamp}    options=-i any -s 0
    CB008247_keywords.Set Odd And Even ATT For Four Output Ports With Different Values    mcs_type=${mcs_type}    att_value1=10    att_value2=10
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    Sleep    10s
#    ${cpif_log_actCov_on_channel_good_again}    Stop Container Wireshark Log Collection    tcpdump_collector_name=cpif_${attach_timestamp}
    Run Keyword And Continue On Failure    Check Tput For CA Group
    ...                                    ue_type=${ue_type}
    ...                                    target_DL_avg_percent=0.9
    ...                                    target_UL_avg_percent=0.9
    ...                                    check_pcell_tput=${True}
    ...                                    check_scell_tput=${False}
    ...                                    scell_mapping=${None}

B2_004_Check_best_and_second_used_DL_SRS_beams_with_TAS_incapable_UE
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${ue_index}=${0}
    ...    ${first_beam_begin_output_port}=${9}    ${first_beam_end_output_port}=${10}
    ...    ${second_beam_begin_output_port}=${11}    ${second_beam_end_output_port}=${12}
    Log To Console    Step1:modify scf from 8247-A to 8247-B(2200 on), actUeCsirsCoexistCellCsirs to cell specific CSI-RS
    Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=notBarred
#    Backup and Modify swconfig file    is_called_in_test_case_level=${True}    swconfig_modify=${SWCONFIG_cell_specific_CSI_RS}
    Modify Paras via Admin API    parameters_to_update=${MODIFY_PARA_1086_off_8247_on}
    ${case_updata_params_list}=    Set Variable If    '${stream}'=='SBTS23R2'        ${MODIFY_SCF_1086_on_8247_on_2200_on}
    ...     ${MODIFY_SCF_1086_on_8247_on_2200_on_add_scramblingIdStep}
    ${updated_scf}    Generate Commission File With TestCase Level Params
    ...    case_updata_params_list=${case_updata_params_list}
    ...    scf_file_path=${Golden_SCF_Path}
    Perform Commission          scf_file_path=${updated_scf}
    Sleep 	90s 	Wait for calibration setup
    ${cprtPatternIdDict}    Get patternIdDict From CPRT Logs    cell_idx=${cell_idx}
    Set Test Variable    ${cprtPatternIdDict}
    Set Test Variable    ${UL_PORT}    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    Set Test Variable    ${DL_PORT}    ${tl.ues[${ue_index}].iperf_details.port}
    Log To Console    Step2:Second SSB: port9/10 θ_h/θ_v:-7/-6 ATT=0, Best SSB: port11/12 θ_h/θ_v:-22/-6 ATT=0
    TOPYONG MCS ON AEHC With QC UE    att_value1=0    att_value2=0
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Run keyword if    '${ue_type}' == 'mtk'    MTK_common_keywords.Get UE Airmode status and Turnoff Airplane Mode    ue_index=${ue_index}
    ${cpif_log_path}    ${bip_log_beamswitch_scenario1}    Make_L3_Call_And_Check_Tput
    ...    is_need_stop_traffic=${False}    ue_index=${ue_index}
    ...    mode=NSA    check_ul_pcell_tput_type=layer1
    ...    target_DL_avg_percent=0.9
    Run Keyword And Continue On Failure    DFTBeam Should Be Used In BIP with mcshark    file_path=${bip_log_beamswitch_scenario1}
    Run Keyword And Continue On Failure    Check CodeBook SRS Is Used in RRC Message    file_path=${cpif_log_path}
    Check srsForBeamMgmt Is Same in SCF And RRC Message    file_path=${cpif_log_path}    cell_idx=${cell_idx}
#    Log To Console    \n***keep traffic ongoing the whole case!
#    Log To Console    Step3:modify att vaule to trigger best and second best beam switch, port9/10 att=0(best SSB), port11/12 att=5(second best)
#    CB008247_keywords.Set Odd And Even ATT For Four Output Ports With Different Values    mcs_type=${mcs_type}    att_value1=0    att_value2=5
#    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
#    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
#    Sleep    10s
#    ${bip_log_beamswitch_scenario2}    Start And Stop Bip Capture
#    Run Keyword And Continue On Failure    Check Tput For CA Group
#    ...                                    ue_type=${ue_type}
#    ...                                    target_DL_avg_percent=0.9
#    ...                                    target_UL_avg_percent=0.9
#    ...                                    check_pcell_tput=${True}
#    ...                                    check_scell_tput=${False}
#    ...                                    scell_mapping=${None}
#    Log To Console    Check point1:from scenario1 to scenario2, SSB no change, first best beam and second best beam switch.
#    ${PatternId_beamswitch_scenario1}    Run Keyword And Continue On Failure    Get patternId From BIP Log with mcshark
#    ...    file_path=${bip_log_beamswitch_scenario1}
#    ${PatternId_beamswitch_scenario2}    Run Keyword And Continue On Failure    Get patternId From BIP Log with mcshark
#    ...    file_path=${bip_log_beamswitch_scenario2}
#    Should Not Be Equal    ${PatternId_beamswitch_scenario1}    ${PatternId_beamswitch_scenario2}
#    ...    msg="Pattern id is not changed from scenario1 to scenario2!"

CB008247-A_DL_follow_legacyGoB_with_actUlSrsBm-disable_actDlSrsBm-enable_but_UE_incapable_of_TAS
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${ue_index}=${1}
    ...    ${first_beam_begin_output_port}=${9}    ${first_beam_end_output_port}=${10}
    ...    ${second_beam_begin_output_port}=${11}    ${second_beam_end_output_port}=${12}
    ${UL_PORT}    Set Test Variable    ${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    ${DL_PORT}    Set Test Variable    ${tl.ues[${ue_index}].iperf_details.port}
    Log To Console    \nStep1:modify parameters to make 1086 off, 8247 on, start L3 call and check tput
    Change cellBarred Parameter Value Of Lte Cells    list_cell_ids=all    exp_status=notBarred
    Modify Paras via Admin API    parameters_to_update=${MODIFY_PARA_1086_off_8247_on}
    Sleep 	90s 	Wait for calibration setup
    Log To Console    \nStep2: port9/10 θ_h/θ_v:-7/-6 ATT=0, port11/12 θ_h/θ_v:-22/-6 ATT=0
    TOPYONG MCS ON AEHC With QC UE    att_value1=0    att_value2=0
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    Run keyword if    '${ue_type}' == 'mtk'    MTK_common_keywords.Get UE Airmode status and Turnoff Airplane Mode    ue_index=${ue_index}
    ${cpif_log_path}    ${bip_log_1086_off}    Make_L3_Call_And_Check_Tput    ue_index=${ue_index}    is_need_stop_traffic=${False}
    ...    mode=NSA    check_ul_pcell_tput_type=layer1
    Run Keyword And Continue On Failure    SSBBeam Should Be Used with mcshark    file_path=${bip_log_1086_off}
#    Run Keyword And Continue On Failure    Check Periodic SRS Is Not Used in RRC Message    file_path=${cpif_log_path}

B2_001_Check_best_and_second_used_DL_SRS_beams_with_4CSIRS
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${first_beam_begin_output_port}=${5}    ${first_beam_end_output_port}=${6}
    ...             ${second_beam_begin_output_port}=${7}    ${second_beam_end_output_port}=${8}
    Log To Console    Step1:modify scf from 8247-A to 8247-B(2200 on), actUeCsirsCoexistCellCsirs to cell specific CSI-RS
#    Backup and Modify swconfig file    is_called_in_test_case_level=${True}    swconfig_modify=${SWCONFIG_cell_specific_CSI_RS}
    ${case_updata_params_list}=    Set Variable If
    ...     '${stream}'=='SBTS23R2'        ${MODIFY_SCF_1086_on_8247_on_2200_on}    ${MODIFY_SCF_1086_on_8247_on_2200_on_add_scramblingIdStep}
    ${updated_scf}    Generate Commission File With TestCase Level Params
    ...    case_updata_params_list=${case_updata_params_list}
    ...    scf_file_path=${Golden_SCF_Path}
    Perform Commission    scf_file_path=${updated_scf}
    Sleep 	90s 	Wait for calibration setup
    ${cprtPatternIdDict}    Get patternIdDict From CPRT Logs    cell_idx=${cell_idx}
    Set Test Variable    ${cprtPatternIdDict}
    Log To Console    Step2:Second SSB: port5/6 θ_h/θ_v:-7/-6 ATT=15, Best SSB: port7/8 θ_h/θ_v:-22/-6 ATT=10
    TOPYONG MCS ON AEHC With QC UE    att_value1=15    att_value2=10
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    ${cpif_log_path}    ${bip_log_beamswitch_scenario1}    Make_L3_Call_And_Check_Tput
    ...    is_need_stop_traffic=${False}
    Run Keyword And Continue On Failure    DFTBeam Should Be Used In BIP with mcshark    file_path=${bip_log_beamswitch_scenario1}
    Run Keyword And Continue On Failure    Check TAS SRS Is Used in RRC Message    file_path=${cpif_log_path}
    Run Keyword And Continue On Failure    Check cell specific CSIRS Used in RRC Message For Pcell    file_path=${cpif_log_path}
    Check srsForBeamMgmt Is Same in SCF And RRC Message    file_path=${cpif_log_path}    cell_idx=${cell_idx}
    Log To Console    \n***keep traffic ongoing the whole case!
    Log To Console    Step3:modify att vaule to trigger best and second best beam switch, port9/10 att=10(best SSB), port11/12 att=15(second best)
    CB008247_keywords.Set Odd And Even ATT For Four Output Ports With Different Values    mcs_type=${mcs_type}    att_value1=10    att_value2=15
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    Sleep    10s
    ${bip_log_beamswitch_scenario2}    Start And Stop Bip Capture
    Run Keyword And Continue On Failure    Check Tput For CA Group
    ...                                    ue_type=${ue_type}
    ...                                    target_DL_avg_percent=0.9
    ...                                    target_UL_avg_percent=0.9
    ...                                    check_pcell_tput=${True}
    ...                                    check_scell_tput=${False}
    ...                                    scell_mapping=${None}
    Log To Console    Check point1:from scenario1 to scenario2, SSB no change, first best beam and second best beam switch.
    ${PatternId_beamswitch_scenario1}    Run Keyword And Continue On Failure    Get patternId From BIP Log with mcshark
    ...    file_path=${bip_log_beamswitch_scenario1}
    ${PatternId_beamswitch_scenario2}    Run Keyword And Continue On Failure    Get patternId From BIP Log with mcshark
    ...    file_path=${bip_log_beamswitch_scenario2}
    Should Not Be Equal    ${PatternId_beamswitch_scenario1}    ${PatternId_beamswitch_scenario2}
    ...    msg="Pattern id is not changed from scenario1 to scenario2!"

B3_007_Check_used_beam_when_period_SRS_resource_exhaused_with_8247_1086_2200_enabled
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${first_beam_begin_output_port}=${5}    ${first_beam_end_output_port}=${6}
    ...             ${second_beam_begin_output_port}=${7}    ${second_beam_end_output_port}=${8}
    Log To Console    Step1:modify scf from 8247-A to 8247-B(2200 on), fix swconfig to cell specific CSI-RS
    Backup and Modify swconfig file    is_called_in_test_case_level=${True}    swconfig_modify=${SWCONFIG_SRS_exhuased}
    ${case_updata_params_list}=    Set Variable If    '${stream}'=='SBTS23R2'        ${MODIFY_SCF_1086_on_8247_on_2200_on_srsUePeriodicity}
    ...     ${MODIFY_SCF_1086_on_8247_on_2200_on_srsUePeriodicity_add_scramblingIdStep}
    ${updated_scf}    Generate Commission File With TestCase Level Params
    ...    case_updata_params_list=${case_updata_params_list}
    ...    scf_file_path=${Golden_SCF_Path}
    Perform Commission    scf_file_path=${updated_scf}
    Sleep 	90s 	Wait for calibration setup
    ${cprtPatternIdDict}    Get patternIdDict From CPRT Logs    cell_idx=${cell_idx}
    Set Test Variable    ${cprtPatternIdDict}
    Log To Console    Step2:Second SSB: port5/6 θ_h/θ_v:-7/-6 ATT=10, Best SSB: port7/8 θ_h/θ_v:-22/-6 ATT=10
    TOPYONG MCS ON AEHC With QC UE
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    ${cpif_log_path}    ${bip_log_path}    Make_L3_Call_And_Check_Tput
    ...    start_traffic_duration=600
    Run Keyword And Continue On Failure    PMIBeam Should Be Used with mcshark    file_path=${bip_log_path}
    Run Keyword And Continue On Failure    Check Periodic SRS Is Not Used in RRC Message   file_path=${cpif_log_path}


CB008247-D_05_IWK_with_DL_TT_CA_Multi_UE_with_TAS_Capable_CA_SA_UE_and_No_TAS_capable_non-CA_UE
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${first_beam_begin_output_port}=${5}    ${first_beam_end_output_port}=${6}
    ...             ${second_beam_begin_output_port}=${7}    ${second_beam_end_output_port}=${8}
    Log To Console    Step1:actUeCsirsCoexistCellCsirs to cell specific CSI-RS
    Modify Paras via Admin API    parameters_to_update=${MODIFY_PARA_cellspecific_8247_on_1086_on}
    ${pcell_cprtPatternIdDict}    Get patternIdDict From CPRT Logs    cell_idx=${cell_idx}
    Set Test Variable    ${pcell_cprtPatternIdDict}
    Log To Console    Step2:Second SSB: port5/6 θ_h/θ_v:7/-6 ATT=10, Best SSB: port7/8 θ_h/θ_v:22/-6 ATT=10
    TOPYONG MCS ON AEHC With QC UE
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    ...    first_beam_horizontal_angle=${7}    second_beam_horizontal_angle=${22}
    ${scell_index_list}    ${scell_technology}    Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=0
    ${cpif_log_cell_specific}    ${bip_log_cell_specific}    Make_L3_Call_And_Check_Tput
    ...             scell_mapping=${SCELL_MAPPING}
    ...             check_scell_tput=${True}
    ...             select_scell_index=${scell_index_list}
    ...             dl_data_transfer=1300M
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
    Run Keyword And Continue On Failure    DFTBeam Should Be Used In BIP For Pcell with mcshark    file_path=${bip_log_cell_specific}
    Run Keyword And Continue On Failure    PMIBeam Should Be Used In BIP For Scell with mcshark
    ...    file_path=${bip_log_cell_specific}   scell_index_list=${scell_index_list}
    Run Keyword And Continue On Failure    Check TAS SRS Is Used in RRC Message    file_path=${cpif_log_cell_specific}
    Run Keyword And Continue On Failure    Check cell specific CSIRS Used in RRC Message For Pcell    file_path=${cpif_log_cell_specific}
    Run Keyword And Continue On Failure    Check srsForBeamMgmt Is Same in SCF And RRC Message
    ...    file_path=${cpif_log_cell_specific}    cell_idx=${cell_idx}
    Run Keyword And Continue On Failure    Check rrcReestablishmentRequest Is Not Exist in RRC Message    file_path=${cpif_log_cell_specific}
    Log To Console    Step3:actUeCsirsCoexistCellCsirs to UE specific CSI-RS, 100M+40M CA， port5/6/7/8 θ_h/θ_v:-7/-6, -22/-6, att=10db
    CB008247_keywords.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    ${cur_scf_file}    COAM Download scf from cluster  scf_dir_path=${TS_CASE_LOG_PATH}
    Common_setup_and_teardown.Case Common SetUp    update_param_name=${MODIFY_SCF_actUeCsirsCoexistCellCsirs_true_chbw_100MHz_40MHz}
    ...                  is_dynamic_pdcch_update=${True}
    ...                  is_case_level_update_params_exist=${True}
    ...                  scf_file_path=${cur_scf_file}
    Sleep 	90s 	Wait for calibration setup
    ${pcell_cprtPatternIdDict}    Get patternIdDict From CPRT Logs    cell_idx=${cell_idx}
    Set Test Variable    ${pcell_cprtPatternIdDict}
    ${cpif_log_ue_specific}    ${bip_log_ue_specific}    Make_L3_Call_And_Check_Tput
    ...             scell_mapping=${SCELL_MAPPING}
    ...             check_scell_tput=${True}
    ...             select_scell_index=${scell_index_list}
    ...             dl_data_transfer=2000M
    ...             ul_data_transfer=120M
    ...             is_do_require_ue=${False}
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
    Run Keyword And Continue On Failure    DFTBeam Should Be Used In BIP For Pcell with mcshark    file_path=${bip_log_ue_specific}
    Run Keyword And Continue On Failure    PMIBeam Should Be Used In BIP For Scell with mcshark    file_path=${bip_log_ue_specific}
    ...    scell_index_list=${scell_index_list}
    Run Keyword And Continue On Failure    Check TAS SRS Is Used in RRC Message    file_path=${cpif_log_ue_specific}
    Run Keyword And Continue On Failure    Check ue specific CSIRS Used in RRC Message For Pcell    file_path=${cpif_log_ue_specific}
    Run Keyword And Continue On Failure    Check rrcReestablishmentRequest Is Not Exist in RRC Message    file_path=${cpif_log_ue_specific}

CB008247-D_08_IWK_with_DL_TF_CA_Single_UE_CSI-RS_reconfiguration_due_to_TAS_capability_change
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${fddcell_index}
    ...             ${first_beam_begin_output_port}=${5}    ${first_beam_end_output_port}=${6}
    ...             ${second_beam_begin_output_port}=${7}    ${second_beam_end_output_port}=${8}
    Log To Console    \n***Step1:Modify to ue specific CSIRS, 8247 on, 1086 off
    Log To Console    \n***Step1:Modify weightForSCellSelection to make FDD scell as first scell.
    Modify Paras via Admin API    parameters_to_update=${MODIFY_PARA_uespecific_true_8247_on_1086_off_weightforscell_fdd}
    Get All TDD-FDD Weighted Scell Bandwidth Value    pcell_index=${fddcell_index}
    ${pcell_cprtPatternIdDict}    Get patternIdDict From CPRT Logs    cell_idx=${fddcell_index}
    Set Test Variable    ${pcell_cprtPatternIdDict}
    Log To Console    \n***Step2:Second SSB: port5/6 θ_h/θ_v:-7/-6 ATT=10, Best SSB: port7/8 θ_h/θ_v:-22/-6 ATT=10, T+F CA with A1 Scell addition
    TOPYONG MCS ON AEHC With QC UE
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    ${scell_index_list}    ${scell_technology}    Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=0
    ${check_pcell_tput_type_ul_layer1}    Get Pcell Tput Type For UL Layer1
    ${check_scell_tput_type}    Get Tput Table For FDD DL Layer4    scell_index_list=${scell_index_list}
    ${cpif_log_path}    ${bip_log}    Make_L3_Call_And_Check_Tput
    ...             scell_mapping=${SCELL_MAPPING}
    ...             check_scell_tput=${True}
    ...             select_scell_index=${scell_index_list}
    ...             dl_data_transfer=1300M
    ...             check_ul_pcell_tput_type=${check_pcell_tput_type_ul_layer1}
    ...             check_scell_tput_type=${check_scell_tput_type}
    ...             target_DL_avg_percent=0.9
    ...             target_UL_avg_percent=0.9
    Log To Console    \n***Check point2:After scell addition UE is reconfigured to Cell specific CSI-RS + PMI beam for pcell.
    Run Keyword And Continue On Failure    PMIBeam Should Be Used In BIP For Pcell with mcshark    file_path=${bip_log}
    Log To Console    \n***Step3:Second SSB: port5/6 θ_h/θ_v:7/-6 ATT=10, Best SSB: port7/8 θ_h/θ_v:22/-6 ATT=10, T+F with blind Scell addition
    CB008247_keywords.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    ...    first_beam_horizontal_angle=${7}    second_beam_horizontal_angle=${22}
    Log To Console    Step4:blind Scell addition, CDRX=on, 1086=on, cb8247=on, actUeCsirsCoexistCellCsirs=true， DL Codebook SRS.
    Log To Console    Step4:without circulator, dl tput will jump for codebook SRS.
    Modify Paras via Admin API    parameters_to_update=${MODIFY_PARA_uespecific_true_8247_on_1086_on_scelladd_blind_weightforscell_fdd}
    ${pcell_cprtPatternIdDict}    Get patternIdDict From CPRT Logs    cell_idx=${fddcell_index}
    Set Test Variable    ${pcell_cprtPatternIdDict}
    ${cpif_log_path_scellblind}    ${bip_log_scellblind}    Make_L3_Call_And_Check_Tput
    ...             scell_mapping=${SCELL_MAPPING}
    ...             check_scell_tput=${True}
    ...             select_scell_index=${scell_index_list}
    ...             dl_data_transfer=1300M
    ...             check_ul_pcell_tput_type=${check_pcell_tput_type_ul_layer1}
    ...             check_scell_tput_type=${check_scell_tput_type}
    ...             target_DL_avg_percent=0.9
    ...             target_UL_avg_percent=0.9
    ...             is_do_require_ue=${False}
    ...             min_DL_percent=0.5
    Log To Console    \n***Check point1:before scell addition, TAS SRS + no codebook p-SRS assigned for pcell.
    Run Keyword And Continue On Failure    Check ue specific CSIRS Used in RRC Message For Pcell    file_path=${cpif_log_path}
    Run Keyword And Continue On Failure    Check TAS SRS and Codebook AP SRS Is Used in RRC Message    file_path=${cpif_log_path}
    Run Keyword And Continue On Failure    Check 2 SRS Ports Used in RRC Message   file_path=${cpif_log_path}
    Run Keyword And Continue On Failure    Check srsForBeamMgmt Is Same in SCF And RRC Message
    ...    file_path=${cpif_log_path}    cell_idx=${fddcell_index}
    Log To Console    \n***Check point2:After scell addition UE is reconfigured to Cell specific CSI-RS + PMI beam for pcell.
#    Run Keyword And Continue On Failure    PMIBeam Should Be Used In BIP For Pcell with mcshark    file_path=${bip_log}
    Run Keyword And Continue On Failure    Check cell specific CSIRS Used in RRC Message For Pcell
    ...    file_path=${cpif_log_path}    rrc_with_pdu=${False}
    Run Keyword And Continue On Failure    Check 1 SRS Port Used in RRC Message   file_path=${cpif_log_path}    rrc_with_pdu=${False}
    Run Keyword And Continue On Failure    Check All SRSResources Are Released in RRC Message    file_path=${cpif_log_path}
    Run Keyword And Continue On Failure    Check rrcReestablishmentRequest Is Not Exist in RRC Message    file_path=${cpif_log_path}
    Log To Console    \n***Check point3:After scell addition UE is reconfigured to UE specific CSI-RS, no rrcReestablishmentRequest.
    Run Keyword And Continue On Failure    Check ue specific CSIRS Used in RRC Message For Pcell
    ...    file_path=${cpif_log_path_scellblind}    rrc_with_pdu=${False}
    Run Keyword And Continue On Failure    Check rrcReestablishmentRequest Is Not Exist in RRC Message    file_path=${cpif_log_path_scellblind}
    Run Keyword And Continue On Failure    DFTBeam Should Be Used In BIP For Pcell with mcshark    file_path=${bip_log_scellblind}

CB008247-D_09_IWK_with_DL_FT_CA_To_TF_CA_Single_UE_with_PCell_Switch
    [Documentation]    Author:lei.jia@nokia-sbell.com
    [Arguments]    ${fddcell_index}    ${tddpcell_index}
    ...             ${first_beam_begin_output_port}=${5}    ${first_beam_end_output_port}=${6}
    ...             ${second_beam_begin_output_port}=${7}    ${second_beam_end_output_port}=${8}
    Log To Console    \n***Step1:Modify to ue specific CSIRS, 8247 on, 1086 off
    Log To Console    \n***Step1: F+T CA, generate pattern id for TDD scell
    Modify Paras via Admin API    parameters_to_update=${MODIFY_PARA_uespecific_true_8247_on_1086_on_weightforscell_fdd}
    Get All TDD-FDD Weighted Scell Bandwidth Value    pcell_index=${fddcell_index}
    Log To Console    \n***Step2:Modify antenuation value to make TDD cell rsrp < a1ThresholdPCellSwitchSsbRsrp, F+T CA
    Log To Console    \n***Step2:Second SSB: port5/6 θ_h/θ_v:-7/-6 ATT=13, Best SSB: port7/8 θ_h/θ_v:-22/-6 ATT=13
    TOPYONG MCS ON AEHC With QC UE
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    ...    att_value1=13    att_value2=13
    ${scell_index_list_before_pcellswitch}    ${scell_technology}    Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=0
    ${check_pcell_tput_type}    Get Tput Table For FDD DL Layer4
    ${check_ul_pcell_tput_type}    Get Tput Table For FDD Pcell UL
    ${cpif_log_F_T_CA}    ${bip_log_F_T_CA}    Make_L3_Call_And_Check_Tput
    ...             scell_mapping=${SCELL_MAPPING}
    ...             check_scell_tput=${True}
    ...             select_scell_index=${scell_index_list_before_pcellswitch}
    ...             dl_data_transfer=1300M
    ...             is_need_stop_traffic=${False}
    ...             check_pcell_tput_type=${check_pcell_tput_type}
    ...             check_ul_pcell_tput_type=${check_ul_pcell_tput_type}
    ...             target_DL_avg_percent=0.9
    ...             target_UL_avg_percent=0.9
    Log To Console    \n******Check Point For F+T CA Before A1 pcell switch***********************************************
    Log To Console    \n***Check point1:before scell addition, no TAS SRS assigned for fdd pcell, for tdd scell cell-specific CISRS + PMI beam
    Run Keyword And Continue On Failure    Check Periodic SRS Is Not Used in RRC Message    file_path=${cpif_log_F_T_CA}
    Run Keyword And Continue On Failure    PMIBeam Should Be Used In BIP For Scell with mcshark    file_path=${bip_log_F_T_CA}
    ...    scell_index_list=${scell_index_list_before_pcellswitch}
    Run Keyword And Continue On Failure    Check cell specific CSIRS Used in RRC Message For Scell
    ...    file_path=${cpif_log_F_T_CA}    scell_index_list=${scell_index_list_before_pcellswitch}
#    Log To Console    \n***Step3:Modify antenuation value to make TDD cell rsrp > a1ThresholdPCellSwitchSsbRsrp to triggr pcell switch
#    Log To Console    \n***Step3:FDD Scell addition > TDD RSRP > PCell change, pcell switch from F+T to T cell(no scell added)
#    Log To Console    \n***Step3:Second SSB: port5/6 θ_h/θ_v:-7/-6 ATT=3, Best SSB: port7/8 θ_h/θ_v:-22/-6 ATT=3,traffic ongoing!
#    ${cur_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
#    Start Container Capture Wireshark Log    tcpdump_collector_name=a1pcellswitch_${cur_timestamp}
#    CB008247_keywords.Set Odd And Even ATT For Four Output Ports With Different Values    mcs_type=${mcs_type}    att_value1=3    att_value2=3
#    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
#    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
#    Sleep    15s
#    ${cpif_log_T_nonCA}    Stop Container Wireshark Log Collection    tcpdump_collector_name=a1pcellswitch_${cur_timestamp}
#    Generate Pcell Mapping Info    pcell_index=${tddpcell_index}
#    ${pcell_cprtPatternIdDict}    Get patternIdDict From CPRT Logs    cell_idx=${tddpcell_index}
#    Set Test Variable    ${pcell_cprtPatternIdDict}
#    Check Tput For CA Group    ue_type=${ue_type}
#    ...                        check_pcell_tput=${True}
#    ...                        check_scell_tput=${False}
#    ...                        scell_mapping=${None}
#    ${bip_log_T_nonCA}    Start And Stop Bip Capture    sleep_interval=5 sec
#    ...                                                asib_interface=eths3
    Log To Console    \n***Step4:Modify antenuation value to make TDD cell rsrp > a1ThresholdSCellAddSsbRsrpFDD to do T+F scell addition
    Log To Console    \n***Step4:5G_CP_ARC_ALG_9030 specify that IntraGnbHo should not be performed, when target cell is barred
    @{expected_pcell_list}    create list    ${fddcell_index}     ${tddpcell_index}
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl
    Change status for parameter cellBarred on GNB    exp_status=notBarred   list_cell_ids=${expected_pcell_list}    timeout=${180}
    Log To Console    \n***Step4:Second SSB: port5/6 θ_h/θ_v:-7/-6 ATT=0, Best SSB: port7/8 θ_h/θ_v:-22/-6 ATT=0,traffic ongoing!
    ${cur_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Container Capture Wireshark Log    tcpdump_collector_name=a1pcellswitch_${cur_timestamp}
    CB008247_keywords.Set Odd And Even ATT For Four Output Ports With Different Values    mcs_type=${mcs_type}    att_value1=0    att_value2=0
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    Sleep    15s
    ${cpif_log_T_F_CA}    Stop Container Wireshark Log Collection    tcpdump_collector_name=a1pcellswitch_${cur_timestamp}
    Get All TDD-FDD Weighted Scell Bandwidth Value    pcell_index=${tddpcell_index}
    ${pcell_cprtPatternIdDict}    Get patternIdDict From CPRT Logs    cell_idx=${tddpcell_index}
    Set Test Variable    ${pcell_cprtPatternIdDict}
    ${scell_index_list_after_pcellswitch}    ${scell_technology}    Get Scell Index List from weighted scell bandwidth list
    ...                    index_in_sorted_scell_weight_list=0
    ${check_scell_tput_type}    Get Tput Table For FDD DL Layer4    scell_index_list=${scell_index_list_after_pcellswitch}
    Run Keyword And Continue On Failure    Check Tput For CA Group
    ...                                    ue_type=${ue_type}
    ...                                    target_DL_avg_percent=0.05
    ...                                    target_UL_avg_percent=0.05
    ...                                    min_DL_percent=0.01
    ...                                    min_UL_percent=0.01
    ...                                    min_scell_percent=0.01
    ...                                    check_ul_pcell_tput_type=no_data
    ...                                    check_pcell_tput_type=not_peak
    ...                                    check_scell_tput_type=${check_scell_tput_type}
    ...                                    addition_scell_index_list=${scell_index_list_after_pcellswitch}
    ${bip_log_T_F_CA}    Start And Stop Bip Capture
#    Log To Console    \n******Check Point For T non-CA After A1 Pcell Switch***************************************************
#    Log To Console    \n***Check point2:before scell addition, TAS SRS assigned for pcell, ue-specific CSIRS + DFT beam
#    Run Keyword And Continue On Failure    Check ue specific CSIRS Used in RRC Message For Pcell    file_path=${cpif_log_T_nonCA}
#    ...    rrc_with_pdu=${False}
#    Run Keyword And Continue On Failure    Check TAS SRS Is Used in RRC Message    file_path=${cpif_log_T_nonCA}
#    Run Keyword And Continue On Failure    Check 2 SRS Ports Used in RRC Message   file_path=${cpif_log_T_nonCA}    rrc_with_pdu=${False}
#    Run Keyword And Continue On Failure    Check srsForBeamMgmt Is Same in SCF And RRC Message
#    ...    file_path=${cpif_log_T_nonCA}    cell_idx=${tddpcell_index}
#    Run Keyword And Continue On Failure    DFTBeam Should Be Used In BIP For Pcell with mcshark    file_path=${bip_log_T_nonCA}
#    ${TASSRSresourceid_in_T_nonCA}    Run Keyword And Continue On Failure    Get tas ResourceSetId of TAS And Codebook P-SRS in ToAddModList
#    ...    file_path=${cpif_log_T_nonCA}
    Log To Console    \n***Check point3:After scell addition, TAS SRS resource released, tdd cell codebook SRS, UL nrofSRS port1
    Run Keyword And Continue On Failure    DFTBeam Should Be Used In BIP For Pcell with mcshark    file_path=${bip_log_T_F_CA}
    Run Keyword And Continue On Failure    Check 1 SRS Port Used in RRC Message   file_path=${cpif_log_T_F_CA}    rrc_with_pdu=${False}
    ${TASSRS_releaseResourceSetId}    Run Keyword And Continue On Failure    Get TAS SRSResourceSetId in SRS ResourceSetToReleaseList From CPIF Log
    ...    file_path=${cpif_log_T_F_CA}
#    Should Be Equal    ${TASSRSresourceid_in_T_nonCA}    ${TASSRS_releaseResourceSetId}
#    ...    msg=TAS SRS resource is not released for T+F CA after scell addition!

W06_Single_UE_Stationary_Performance_8x4_Good_Medium_Worse_15_Points_On_VS_OFF_AWGN_TAS_SRS
    [Documentation]    Author:lei.jia@nokia-sbell.com
    ...                2024-06-18: modify vertical_angle ${-12} to from ${-6}
    [Arguments]    ${first_beam_begin_output_port}=${5}    ${first_beam_end_output_port}=${6}
    ...             ${second_beam_begin_output_port}=${7}    ${second_beam_end_output_port}=${8}
    Log To Console    Step1:modify scf from 8247-A to 8247-B(2200 on), actUeCsirsCoexistCellCsirs to cell specific CSI-RS
    ${case_updata_params_list}=    Set Variable If    '${stream}'=='SBTS23R2'        ${MODIFY_SCF_1086_on_8247_on_2200_on}
    ...     ${MODIFY_SCF_1086_on_8247_on_2200_on_add_scramblingIdStep}
    ${updated_scf}    Generate Commission File With TestCase Level Params
    ...    case_updata_params_list=${case_updata_params_list}
    ...    scf_file_path=${Golden_SCF_Path}
    Perform Commission    scf_file_path=${updated_scf}
    Sleep 	90s 	Wait for calibration setup
    ${cprtPatternIdDict}    Get patternIdDict From CPRT Logs    cell_idx=${cell_idx}
    Set Test Variable    ${cprtPatternIdDict}
    Log To Console    Step2:Second SSB: port5/6 θ_h/θ_v:-7/-6 ATT=10, Best SSB: port7/8 θ_h/θ_v:-22/-6 ATT=10
    TOPYONG MCS ON AEHC With QC UE    att_value1=10    att_value2=10
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    ${cpif_log_path}    ${bip_log}    Make_L3_Call_And_Check_Tput
    ...    is_need_stop_traffic=${False}    start_traffic_duration=3000   duration=30
    CB008247_keywords.Set Odd And Even ATT For Four Output Ports With Different Values    mcs_type=${mcs_type}    att_value1=19    att_value2=19
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    CB008247_keywords.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    first_beam_horizontal_angle=${-45}
    ...    vertical_angle=${-6}    second_beam_horizontal_angle=${-35}
    ...    first_beam_begin_output_port=${first_beam_begin_output_port}   first_beam_end_output_port=${first_beam_end_output_port}
    ...    second_beam_begin_output_port=${second_beam_begin_output_port}    second_beam_end_output_port=${second_beam_end_output_port}
    Sleep    30s
    Log To Console    \n***keep traffic ongoing the whole case, Start Performance from Good to Worse!
    Log To Console    \n***Step3: adjust RSRP for good: att=19, move from H[-45, +35], V[-6]and check tput
    ${tput_log_good}    Capturing Aasyslog through all the performance testing    att_value1=19    att_value2=19
    ...                 vertical_angle=${-6}
    Run Keyword And Continue On Failure    Check Tput Without Power UE Collcet Tput    cellid=${cell_idx}
    ...    tput_log=${tput_log_good}    expect_ul_tput=30    expect_dl_tput=540
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
    Log To Console    \n***Step4: adjust RSRP for medium: att=29, move from H[-45, +35], V[-6]and check tput
    ${tput_log_medium}    Capturing Aasyslog through all the performance testing    att_value1=29    att_value2=29
    ...    vertical_angle=${-6}
    Run Keyword And Continue On Failure    Check Tput Without Power UE Collcet Tput    cellid=${cell_idx}
    ...    tput_log=${tput_log_medium}    expect_ul_tput=10    expect_dl_tput=380
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
    Log To Console    \n***Step5: adjust RSRP for Worse: att=39, move from H[-45, +35], V[-12]and check tput
    ${tput_log_worse}    Capturing Aasyslog through all the performance testing    att_value1=39    att_value2=39
    ...       vertical_angle=${-6}
    Run Keyword And Continue On Failure    Check Tput Without Power UE Collcet Tput    cellid=${cell_idx}
    ...    tput_log=${tput_log_worse}    expect_ul_tput=3    expect_dl_tput=200
    Recover Collect Syslog On Control PC
    ${timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Start Btslog With Path Check
    Sleep    1min
    Stop Btslog With Path Check    target_dir=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    run keyword and continue on failure    Check L1/L2 Error From Syslog    btslog_path=${TS_CASE_LOG_PATH}/btslog_${timestamp}
    Recover Collect Syslog On Control PC
    Run Keyword And Continue On Failure    DFTBeam Should Be Used In BIP with mcshark    file_path=${bip_log}
    Run Keyword And Continue On Failure    Check TAS SRS Is Used in RRC Message    file_path=${cpif_log_path}
    Run Keyword And Continue On Failure    Check cell specific CSIRS Used in RRC Message For Pcell    file_path=${cpif_log_path}
    Check srsForBeamMgmt Is Same in SCF And RRC Message    file_path=${cpif_log_path}    cell_idx=${cell_idx}


