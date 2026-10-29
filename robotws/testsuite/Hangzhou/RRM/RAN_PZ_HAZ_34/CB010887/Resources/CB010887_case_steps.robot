*** Settings ***
Documentation    CB010887 TA cases common steps
...              Author: jun.8.chen@nokia-sbell.com

Resource    CB010887_common.robot


*** Variables ***
${MRBTS_ID}    ${tl.gnbs[0].instance_id}
${NRBTS_ID}    ${tl.gnbs[0].global_bts_id}
@{SWCONFIG_rdSrsSymPolicy_rdTiltOffset}    0x590100=11
@{scf_params_B_02}    modify:NRCELL-1:bSRS=2
...                   modify:NRCELL-1:cSRS=63
...                   modify:NRCELL-1:srsUePeriodicity=slots40
...                   modify:NRCELL-1:tiltOffset=2
...                   modify:NRCELL-1:actUlSrsBm=true
...                   modify:NRCELL-1:actDlSrsBm=true
...                   modify:NRCELL-2:bSRS=2
...                   modify:NRCELL-2:cSRS=33
...                   modify:NRCELL-2:srsUePeriodicity=slots40
...                   modify:NRCELL-2:tiltOffset=2
...                   modify:NRCELL-2:actUlSrsBm=true
...                   modify:NRCELL-2:actDlSrsBm=true
...                   modify:NRCELL-3:bSRS=2
...                   modify:NRCELL-3:cSRS=13
...                   modify:NRCELL-3:srsUePeriodicity=slots40
...                   modify:NRCELL-3:tiltOffset=2
...                   modify:NRCELL-3:actUlSrsBm=true
...                   modify:NRCELL-3:actDlSrsBm=true
...                   modify:NRCELL-4:bSRS=2
...                   modify:NRCELL-4:cSRS=13
...                   modify:NRCELL-4:srsUePeriodicity=slots40
...                   modify:NRCELL-4:tiltOffset=2
...                   modify:NRCELL-4:actUlSrsBm=true
...                   modify:NRCELL-4:actDlSrsBm=true
@{scf_params_B_04}    modify:NRCELL-1:bSRS=0
...                   modify:NRCELL-1:cSRS=63
...                   modify:NRCELL-1:srsUePeriodicity=slots10
...                   modify:NRCELL-1:srsPowerThresholdForDlBm=-1200
...                   modify:NRCELL-1:srsPowerThresholdForUlBm=-1200
...                   modify:NRCELL-1:actUlSrsBm=true
...                   modify:NRCELL-1:actDlSrsBm=true
...                   modify:NRCELL-2:bSRS=0
...                   modify:NRCELL-2:cSRS=33
...                   modify:NRCELL-2:srsUePeriodicity=slots10
...                   modify:NRCELL-2:srsPowerThresholdForDlBm=-1200
...                   modify:NRCELL-2:srsPowerThresholdForUlBm=-1200
...                   modify:NRCELL-2:actUlSrsBm=true
...                   modify:NRCELL-2:actDlSrsBm=true
...                   modify:NRCELL-3:bSRS=0
...                   modify:NRCELL-3:cSRS=13
...                   modify:NRCELL-3:srsUePeriodicity=slots10
...                   modify:NRCELL-3:srsPowerThresholdForDlBm=-1200
...                   modify:NRCELL-3:srsPowerThresholdForUlBm=-1200
...                   modify:NRCELL-3:actUlSrsBm=true
...                   modify:NRCELL-3:actDlSrsBm=true
...                   modify:NRCELL-4:bSRS=0
...                   modify:NRCELL-4:cSRS=13
...                   modify:NRCELL-4:srsUePeriodicity=slots10
...                   modify:NRCELL-4:srsPowerThresholdForDlBm=-1200
...                   modify:NRCELL-4:srsPowerThresholdForUlBm=-1200
...                   modify:NRCELL-4:actUlSrsBm=true
...                   modify:NRCELL-4:actDlSrsBm=true
&{framestructure_1208}    1=1208    2=1208    3=1208    4=1208    5=1208    6=1208
&{framestructure_11160ms}    1=11160ms    2=11160ms    3=11160ms    4=11160ms    5=11160ms    6=11160ms
@{direction_component_list}    UL    DL
@{dl_direction_component_list}    DL
${7_5_UTE5G402T273_HW_TYPE}    GUANGHETONG
${7_5_UTE5G402T272_HW_TYPE}    YIYUAN

*** Keywords ***
CB011026_D_03_eCPRI_7_2e_L3_call_Work_SUMIMO_Work_for_32Trx_RU
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    Log To Console    \n***start to run test case***
    ${cprtPatternIdDict}    Get patternId Dict Via CPRT Log
    ${expect_pci}    ${cpif_log_on_testPC}    Start To Attach And Capture Cpif File
    ${cprtPatternId_Dict}    Create Dictionary    ${expect_pci}[0]=${cprtPatternIdDict}
    #--- start ul/dl traffic --- #
    DingLi_Client.Start Data Transfer    ues_index=${${0}}    ul_throughput=220000    dl_throughput=1600M
    Sleep    30sec
    #--- Expected peak throughput is reached --- #
    Log To Console    \n*** start to check whether peak throughput is reached ***
    Run Keyword And Continue On Failure    Start To Check The Throughput    target_avg_percent=0.90    expect_ul_tput=155
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Run Keyword And Continue On Failure    Check AVQL Err and WRN Log On RF
    csn.reset_cache
    #--- Capture the bip log --- #
    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${expect_pci}
    ...                                                                                 target_file_name=bip_log_normal
    Sleep    5sec
    ${bip_log_normal}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
    ...                                                             target_file_name=bip_log_normal

    #--- Increase attenuation to make srspower lower than -120dBm and switch from ul rank2 to rank1 --- #
    Log To Console    \n*** Increase attenuation to make srspower lower than -120dBm and switch from ul rank2 to rank1 ***
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=45
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    Sleep    5sec
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=50
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    Sleep    5sec
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=51
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    Sleep    5sec
    #--- No Call drop. But peak throughput is not reached after Increase attenuation to 120 --- #
    Log To Console    \n*** start to check the peak throughput ***
    Run Keyword And Continue On Failure    Start To Check The Throughput    target_avg_percent=0.05    expect_ul_tput=155
    #--- Capture the bip log after Increase attenuation to 120 --- #
    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${expect_pci}
    ...                                                                                 target_file_name=bip_log_rank1
    Sleep    5sec
    ${bip_log_rank1}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
    ...                                                                         target_file_name=bip_log_rank1

    #--- Change attenuation to normal --- #
    Log To Console    \n*** start to Change attenuation to normal ***
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=10
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    Sleep    5sec
    #--- No traffic drop. And peak throughput is reached after Change attenuation to normal --- #
    Log To Console    \n*** start to check the peak throughput ***
    Run Keyword And Continue On Failure    Start To Check The Throughput    target_avg_percent=0.90    expect_ul_tput=155
    #--- Capture the bip log after Change attenuation to normal --- #
    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${expect_pci}
    ...                                                                                 target_file_name=bip_log_back_to_normal
    Sleep    5sec
    ${bip_log_back_to_normal}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
    ...                                                                         target_file_name=bip_log_back_to_normal
    #--- Change MCS angle --- #
    Log To Console    \n*** start to change MCS angle ***
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${7}    second_beam_horizontal_angle=${22}    vertical_angle=${-9}
    ...    vertical_distance=${2}
    Sleep    5sec
    #--- No traffic drop. expected peak throughput is reached after change MCS angle --- #
    Log To Console    \n*** start to check the peak throughput ***
    Run Keyword And Continue On Failure    Start To Check The Throughput    target_avg_percent=0.90    expect_ul_tput=155
    #--- Capture the bip log after mcs angle changed --- #
    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${expect_pci}
    ...                                                                                 target_file_name=bip_log_after_change_angle
    Sleep    5sec
    ${bip_log_after_change_angle}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
    ...                                                                         target_file_name=bip_log_after_change_angle
    #--- Start to verify the related check points --- #
    Log To Console    \n*** start to verify the related check points ***

    ${slot_List}    ${srsUePeriodicity}    Run Keyword And Continue On Failure
    ...    Verify srsForBeamMgmt Whether Are Same Between SCF And RRC Message    cpif_log_path=${cpif_log_on_testPC}    srs_num=${2}
    Set Test Variable    ${test_slot_list}    ${slot_List}
    Run Keyword And Continue On Failure    Check Values On UlData_SrsReceiveRespBmPs    bip_file_path=${bip_log_normal[0]}
    ...                                                                                 slot_List=${test_slot_list}
    ...                                                                                 srsUePeriodicity=${srsUePeriodicity}
    #--- SrsPower Values will lower than -120--- #
    Run Keyword And Continue On Failure    Check SrsPower Values On UlData_SrsReceiveRespBmPs    bip_file_path=${bip_log_normal[0]}

    Run Keyword And Continue On Failure    Check Whether uldata_srsreceiveRespPs Message In BIP Log    bip_file_path=${bip_log_normal[0]}
    Run Keyword And Continue On Failure    Check srsSuMimoEnable In UlData_SrsReceiveReq Via BIP Log    bip_file_path=${bip_log_normal[0]}
    Run Keyword And Continue On Failure    Check srsBmEnable In UlData_SrsReceiveReq Via BIP Log    bip_file_path=${bip_log_normal[0]}
    Run Keyword And Continue On Failure    Check The Rank Of PUSCH Via BIP Log    bip_file_path=${bip_log_normal[0]}
    #--- Beam pattern ids range is in cprt startup log during cell setup --- #
    ${pdschsendreq_dict}    ${puschreceivereq_dict}    ${csirssendreq_patternId_dict}    Run Keyword And Continue On Failure
    ...    Get PatternId For Related Message Via BIP Log    bip_file_path=${bip_log_normal[0]}    pci=${expect_pci}
    Run Keyword And Continue On Failure    Compare PatternidList Between CPRT And BIP_Between PDSCH And CSIRS
    ...                                        pdschsendreq_dict=${pdschsendreq_dict}
    ...                                        puschreceivereq_dict=${puschreceivereq_dict}
    ...                                        csirssendreq_patternId_dict=${csirssendreq_patternId_dict}
    ...                                        cprtPatternIdDict=${cprtPatternId_Dict}
    ...                                        pci=${expect_pci}

    #--- Start to verify the related check points after UL RANK1 --- #
    Log To Console    \n*** start to verify the related check points after UL RANK1 ***
    Run Keyword And Continue On Failure    Check Whether uldata_srsreceiveRespPs Message In BIP Log
    ...    bip_file_path=${bip_log_rank1[0]}    whether_in_value=${True}
    Run Keyword And Continue On Failure    Check srsSuMimoEnable In UlData_SrsReceiveReq For Special Slot
    ...    bip_file_path=${bip_log_rank1[0]}    srs_slot_List=${test_slot_list}
    Run Keyword And Continue On Failure    Check srsBmEnable In UlData_SrsReceiveReq Via BIP Log    bip_file_path=${bip_log_rank1[0]}
    ...                                                                                             srsBmEnable_value=${True}
    Run Keyword And Continue On Failure    Check The Rank Of PUSCH Via BIP Log    bip_file_path=${bip_log_rank1[0]}    pusch_rank=1
    #--- SrsPower Values will lower than -120--- #
    Run Keyword And Continue On Failure    Check SrsPower Values On UlData_SrsReceiveRespBmPs    bip_file_path=${bip_log_rank1[0]}
    ...                                                                                          srspower=120
    Run Keyword And Continue On Failure    Check Values On UlData_SrsReceiveRespBmPs    bip_file_path=${bip_log_rank1[0]}
    ...                                                                                 slot_List=${test_slot_list}
    ...                                                                                 dtx_value=DTX
    ...                                                                                 srsUePeriodicity=${srsUePeriodicity}
    #--- PDSCH and CSIRS with trsInfo=DISABLED fallback to Second Default SSB beams --- #
    ${pdschsendreq_dict}    ${csirssendreq_patternId_dict}    Run Keyword And Continue On Failure
    ...    Get PatternId For PDSCH And CSIRS Message Via BIP Log    bip_file_path=${bip_log_rank1[0]}    pci=${expect_pci}
    Run Keyword And Continue On Failure    Compare PatternidList Between CPRT And BIP
    ...                                        pdschsendreq_dict=${pdschsendreq_dict}
    ...                                        csirssendreq_patternId_dict=${csirssendreq_patternId_dict}
    ...                                        cprtPatternIdDict=${cprtPatternId_Dict}
    ...                                        pci=${expect_pci}
    #--- PUSCH fallback to Second Default SSB beams --- #
#    ${puschreceivereq_list}    Run Keyword And Continue On Failure
#    ...    Get PatternId For UlData_PuschReceiveReq Via BIP Log    bip_file_path=${bip_log_rank1[0]}
    ${puschreceivereq_dict}    Run Keyword And Continue On Failure
    ...    Get PatternId For UlData_PuschReceiveReqL1RU Via BIP Log    bip_file_path=${bip_log_rank1[0]}    pci=${expect_pci}
    Run Keyword And Continue On Failure    Compare PatternidList Between CPRT And BIP For PUSCH
    ...                                        puschreceivereq_dict=${puschreceivereq_dict}
    ...                                        cprtPatternIdDict=${cprtPatternId_Dict}
    ...                                        pci=${expect_pci}

    #--- Start to verify the related check points after back to normal --- #
    Log To Console    \n*** start to verify the related check points after back to normal ***
    Run Keyword And Continue On Failure    Check Whether uldata_srsreceiveRespPs Message In BIP Log
    ...    bip_file_path=${bip_log_back_to_normal[0]}
    Run Keyword And Continue On Failure    Check srsSuMimoEnable In UlData_SrsReceiveReq Via BIP Log
    ...    bip_file_path=${bip_log_back_to_normal[0]}
    Run Keyword And Continue On Failure    Check srsBmEnable In UlData_SrsReceiveReq Via BIP Log
    ...    bip_file_path=${bip_log_back_to_normal[0]}
    Run Keyword And Continue On Failure    Check The Rank Of PUSCH Via BIP Log    bip_file_path=${bip_log_back_to_normal[0]}
    #--- Beam pattern ids range is in cprt startup log during cell setup --- #
    ${pdschsendreq_dict}    ${puschreceivereq_dict}    ${csirssendreq_patternId_dict}    Run Keyword And Continue On Failure
    ...    Get PatternId For Related Message Via BIP Log    bip_file_path=${bip_log_back_to_normal[0]}    pci=${expect_pci}
    Run Keyword And Continue On Failure    Compare PatternidList Between CPRT And BIP_Between PDSCH And CSIRS
    ...                                        pdschsendreq_dict=${pdschsendreq_dict}
    ...                                        puschreceivereq_dict=${puschreceivereq_dict}
    ...                                        csirssendreq_patternId_dict=${csirssendreq_patternId_dict}
    ...                                        cprtPatternIdDict=${cprtPatternId_Dict}
    ...                                        pci=${expect_pci}
    #--- DFT beams scheduled for both DL and UL from BIP log after change mcs angle --- #
    ${pdschsendreq_dict1}    ${puschreceivereq_dict1}    ${csirssendreq_patternId_dict1}    Run Keyword And Continue On Failure
    ...    Get PatternId For Related Message Via BIP Log    bip_file_path=${bip_log_after_change_angle[0]}    pci=${expect_pci}
    Run Keyword And Continue On Failure    Compare PatternidList Between CPRT And BIP_Between PDSCH And CSIRS
    ...                                        pdschsendreq_dict=${pdschsendreq_dict1}
    ...                                        puschreceivereq_dict=${puschreceivereq_dict1}
    ...                                        csirssendreq_patternId_dict=${csirssendreq_patternId_dict1}
    ...                                        cprtPatternIdDict=${cprtPatternId_Dict}
    ...                                        pci=${expect_pci}

CB011026_A_01_Validate_FH_Cplane_Fragmentation_Aggregation_Function_with_Periodic_SRS_in_Single_Cells
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    Log To Console    \n***start to run test case***
    ${cprtPatternIdDict}    Get patternId Dict Via CPRT Log
    Run Keyword And Continue On Failure    Check EleSteeringCenter Degree Via CPRT Log
    Run Keyword And Continue On Failure    Check Tilt Value Via CPRT Log
    ${expect_pci}    ${cpif_log_on_testPC}    Start To Attach And Capture Cpif File    ues_index=${${0},${1},${2},${3}}
    ${cprtPatternId_Dict}    Create Dictionary    ${expect_pci}[0]=${cprtPatternIdDict}
    DingLi_Client.Start Data Transfer    ues_index=${${0},${1},${2},${3}}    ul_throughput=100000    dl_throughput=500M
    Sleep    30sec
    Log To Console    \n*** start to check whether peak throughput is reached ***
    Run Keyword And Continue On Failure    Start To Check The Throughput    target_avg_percent=0.90
    ...                                                                     expect_ul_tput=160
    ...                                                                     expect_dl_tput=1450
    #--- Capture the TTiTrace log --- #
#    ${ttitrace_file}    Run Keyword And Continue On Failure    Capture TTI with gnb logs    duration=10
#    ...                                                                                     direction=dlAndUl
#    ...                                                                                     tti_log_option=T
#    ...                                                                                     tti_package_file_name=tti_packed
    ${tti_file_path_ul}    ${tti_file_path_dl}    Run Keyword And Continue On Failure    Capture TTI with gnb logs For 10887
    #--- Capture the bip log --- #
    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${expect_pci}
    ...                                                                                 target_file_name=bip_log_normal
    Sleep    3sec
    ${bip_log_normal}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
    ...                                                             target_file_name=bip_log_normal
    Sleep    5sec
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Run Keyword And Continue On Failure    Check AVQL Err and WRN Log On RF
    csn.reset_cache
    Log To Console    \n*** stop traffic and detach ***
    Run Keyword And Ignore Error    DingLi_Client.Stop Data Transfer
    Run Keyword And Ignore Error    DingLi_Client.Detach
    #--- Start to do cell block and unblock --- #
    Run Keyword And Continue On Failure    Block Cell And Check Status
    Run Keyword And Continue On Failure    Unblock Cell And Check Status
    #--- Start to Check L3 call after block/unblock cell --- #
    ${expect_pci}    ${cpif_log_on_testPC}    Start To Attach And Capture Cpif File    ues_index=${${0},${1},${2},${3}}
    DingLi_Client.Start Data Transfer    ues_index=${${0},${1},${2},${3}}    ul_throughput=100000    dl_throughput=500M
    Sleep    30sec
    Log To Console    \n*** start to check whether peak throughput is reached ***
    Run Keyword And Continue On Failure    Start To Check The Throughput    target_avg_percent=0.90
    ...                                                                     expect_ul_tput=160
    ...                                                                     expect_dl_tput=1450
    Sleep    5sec
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Run Keyword And Continue On Failure    Check AVQL Err and WRN Log On RF
    csn.reset_cache
    Log To Console    \n*** stop traffic and detach ***
    Run Keyword And Ignore Error    DingLi_Client.Stop Data Transfer
    Run Keyword And Ignore Error    DingLi_Client.Detach
    #--- Start to verify the related check points --- #
    Log To Console    \n*** start to verify the related check points ***
    Run Keyword And Continue On Failure    Check UE Capability Via CPIF Log    cpif_log_path=${cpif_log_on_testPC}
    Run Keyword And Continue On Failure    Check SRSResourceSet Via CPIF Log    cpif_log_path=${cpif_log_on_testPC}
    Run Keyword And Continue On Failure    Check Values On UlData_SrsReceiveRespBmPs For Multi UE    bip_file_path=${bip_log_normal[0]}
#    Run Keyword And Continue On Failure    Check Symbol In UlData_SrsReceiveReq Via BIP Log    bip_file_path=${bip_log_normal[0]}
    Run Keyword And Continue On Failure    Check Single UE UL Average Tput Via TTiTrace
    ...                                    ttitrace_filt_path=${tti_file_path_ul}
    ...                                    expect_tput_value=160
    Run Keyword And Continue On Failure    Check Single UE DL Average Tput Via TTiTrace
    ...                                    ttitrace_filt_path=${tti_file_path_dl}
    ...                                    expect_tput_value=1450
    #--- Beam pattern ids range is in cprt startup log during cell setup --- #
    ${pdschsendreq_dict}    ${puschreceivereq_dict}    ${csirssendreq_patternId_dict}    Run Keyword And Continue On Failure
    ...    Get PatternId For Related Message Via BIP Log    bip_file_path=${bip_log_normal[0]}    pci=${expect_pci}    ue_num=${4}
    Run Keyword And Continue On Failure    Compare PatternidList Between CPRT And BIP_Between PDSCH And CSIRS
    ...                                        pdschsendreq_dict=${pdschsendreq_dict}
    ...                                        puschreceivereq_dict=${puschreceivereq_dict}
    ...                                        csirssendreq_patternId_dict=${csirssendreq_patternId_dict}
    ...                                        cprtPatternIdDict=${cprtPatternId_Dict}
    ...                                        pci=${expect_pci}

CB011026_A_02_Validate_FH_Cplane_Fragmentation_Aggregation_Function_with_Periodic_SRS_in_Multiple_Cells
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    Log To Console    \n***start to run test case***
    ${cprtPatternIdDict}    Get patternId Dict Via CPRT Log    cell_idx=1
    ${cprtPatternIdDict_2}    Get patternId Dict Via CPRT Log    cell_idx=2
    ${cprtPatternIdDict_3}    Get patternId Dict Via CPRT Log    cell_idx=3
    ${cprtPatternIdDict_4}    Get patternId Dict Via CPRT Log    cell_idx=4
    ${cprtPatternId_Dict}    Create Dictionary    721=${cprtPatternIdDict}
    Set To Dictionary    ${cprtPatternId_Dict}    722    ${cprtPatternIdDict_2}
    Set To Dictionary    ${cprtPatternId_Dict}    723    ${cprtPatternIdDict_3}
    Set To Dictionary    ${cprtPatternId_Dict}    724    ${cprtPatternIdDict_4}

    Log To Console    \n*** start to get peak number from nrdim ***
    Wait Until Keyword Succeeds    2 min    5 sec    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=${0}
    ${scf_path_nrdim}    coam_gnb_classical.COAM Download scf from cluster    scf_dir_path=${TS_CASE_LOG_PATH}    connection=GNB_OAM
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
    ${peak_dl_cell_1}    ${peak_ul_cell_1}    get_theoretical_throughput    scf_path=${scf_path_nrdim}    cell_id=1
    ${peak_dl_cell_2}    ${peak_ul_cell_2}    get_theoretical_throughput    scf_path=${scf_path_nrdim}    cell_id=2
    ${peak_dl_cell_3}    ${peak_ul_cell_3}    get_theoretical_throughput    scf_path=${scf_path_nrdim}    cell_id=3
    ${peak_dl_cell_4}    ${peak_ul_cell_4}    get_theoretical_throughput    scf_path=${scf_path_nrdim}    cell_id=4
    ${ue1_tupt_dic}    Create Dictionary    expect_dl_tput=${peak_dl_cell_1}    expect_ul_tput=${peak_ul_cell_1}
    ${ue2_tupt_dic}    Create Dictionary    expect_dl_tput=${peak_dl_cell_2}    expect_ul_tput=${peak_ul_cell_2}
    ${ue3_tupt_dic}    Create Dictionary    expect_dl_tput=${peak_dl_cell_3}    expect_ul_tput=${peak_ul_cell_3}
    ${ue4_tupt_dic}    Create Dictionary    expect_dl_tput=${peak_dl_cell_4}    expect_ul_tput=${peak_ul_cell_4}
    ${ue_tupt_mapping_table}    Create Dictionary    0=${ue1_tupt_dic}
    Set To Dictionary    ${ue_tupt_mapping_table}    1    ${ue2_tupt_dic}
    Set To Dictionary    ${ue_tupt_mapping_table}    2    ${ue3_tupt_dic}
    Set To Dictionary    ${ue_tupt_mapping_table}    3    ${ue4_tupt_dic}

    Log To Console    \n*** start to attach for one cell mapping one ue ***
    ${expect_pci}    ${cpif_log_on_testPC}    Start To Attach Mapping Cell Into UE
    ${ue_list}    Set Variable    ${${0},${1},${2},${3}}
    ${ue_index_in_tl}    Set Variable    ${1}
    ${dl_port}    Set Variable    ${tl.ues[${ue_index_in_tl}].iperf_details.port}
    ${ue_port}    Set Variable    ${tl.ues[${ue_index_in_tl}].iperf_details.port}
    Log To Console    \n*** start to DL for one cell mapping one ue ***
    FOR    ${ue}    IN    @{ue_list}
        ${ul_tput}    Set Variable    ${TESTCASE_INFO_MAPPING_TABLE['${TL_NAME}']['${ue}']['send_ul_tput']}
        ${dl_tput}    Set Variable    ${TESTCASE_INFO_MAPPING_TABLE['${TL_NAME}']['${ue}']['send_dl_tput']}
        DingLi_Client.Start Data Transfer    ues_index=${ue}
        ...                                  ul_throughput=${ul_tput}
        ...                                  dl_throughput=${dl_tput}
        ...                                  refine_dl_port=${dl_port}
        ...                                  refine_ue_port=${ue_port}
        ...                                  whether_start_ul_call=${False}
        ${dl_port}    Evaluate    ${dl_port}+1
    END
    Sleep    30sec
    Log To Console    \n*** start to check whether DL peak throughput is reached ***
    Run Keyword And Continue On Failure    Start To Check The Throughput For Multi UE    ue_tupt_mapping=${ue_tupt_mapping_table}
    ...    direction_component_list=@{dl_direction_component_list}
    Log To Console    \n*** start to UL for one cell mapping one ue ***
    FOR    ${ue}    IN    @{ue_list}
        ${ul_tput}    Set Variable    ${TESTCASE_INFO_MAPPING_TABLE['${TL_NAME}']['${ue}']['send_ul_tput']}
        ${dl_tput}    Set Variable    ${TESTCASE_INFO_MAPPING_TABLE['${TL_NAME}']['${ue}']['send_dl_tput']}
        DingLi_Client.Start Data Transfer    ues_index=${ue}
        ...                                  ul_throughput=${ul_tput}
        ...                                  dl_throughput=${dl_tput}
        ...                                  refine_dl_port=${dl_port}
        ...                                  refine_ue_port=${ue_port}
        ...                                  whether_start_dl_call=${False}
        ${ue_port}    Evaluate    ${ue_port}+1
    END
    Sleep    30sec
    Log To Console    \n*** start to check whether peak throughput is reached ***
    Run Keyword And Continue On Failure    Start To Check The Throughput For Multi UE    ue_tupt_mapping=${ue_tupt_mapping_table}
    #--- Capture the TTiTrace log --- #
    ${tti_file_path_ul}    ${tti_file_path_dl}    Run Keyword And Continue On Failure    Capture TTI with gnb logs For 10887
    #--- Capture the bip log --- #
    Run Keyword And Continue On Failure    Collect Interface Mirroring Bip Collector    nr_phy_cell_ids=${expect_pci}
    ...                                                                                 target_file_name=bip_log_normal
    Sleep    3sec
    ${bip_log_normal}    Run Keyword And Continue On Failure    Get Bip Log Via Interface Mirroring Collector
    ...                                                                     target_file_name=bip_log_normal
    Run Keyword And Continue On Failure    Start To Check L1L2 Error Info From Syslog
    Run Keyword And Continue On Failure    Check AVQL Err and WRN Log On RF
    csn.reset_cache
    Log To Console    \n*** stop traffic and detach ***
    Run Keyword And Ignore Error    DingLi_Client.Stop Data Transfer
    Run Keyword And Ignore Error    DingLi_Client.Detach
    #--- Start to verify the related check points --- #
    Log To Console    \n*** start to verify the related check points for one cell mapping one ue***
    Run Keyword And Continue On Failure    Check SRSResourceSet Via CPIF Log    cpif_log_path=${cpif_log_on_testPC}
    Run Keyword And Continue On Failure    Check Values On UlData_SrsReceiveRespBmPs For Multi UE    bip_file_path=${bip_log_normal[0]}
    #--- DFT beams scheduled for both DL and UL from BIP log after UE mapping cell one by one --- #
    ${pdschsendreq_dict1}    ${puschreceivereq_dict1}    ${csirssendreq_patternId_dict1}    Run Keyword And Continue On Failure
    ...    Get PatternId For Related Message Via BIP Log    bip_file_path=${bip_log_normal[0]}    pci=${expect_pci}    ue_num=${4}
    Run Keyword And Continue On Failure    Compare PatternidList Between CPRT And BIP_Between PDSCH And CSIRS
    ...                                        pdschsendreq_dict=${pdschsendreq_dict1}
    ...                                        puschreceivereq_dict=${puschreceivereq_dict1}
    ...                                        csirssendreq_patternId_dict=${csirssendreq_patternId_dict1}
    ...                                        cprtPatternIdDict=${cprtPatternId_Dict}
    ...                                        pci=${expect_pci}
    Check Multi UEs Bler Via TTiTrace     tti_file_path_ul=${tti_file_path_ul}    tti_file_path_dl=${tti_file_path_dl}

Start To Attach And Capture Cpif File
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ues_index}=${${0}}    ${UE_mode}=5G_SA    ${is_restart_ue}=${False}    ${list_cell_ids}=1    ${expect_sceond_pci}=NULL
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Change status for parameter cellBarred on GNB    exp_status=notBarred    list_cell_ids=${list_cell_ids}    connection=GNB_OAM    timeout=300
    Connect to Common Unit Master     alias=ASIK Master   gnb_index=0
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log    tcpdump_collector_name=cpif_wireshark
    ...                                                                             asik_connection_alias=ASIK Master
    ...                                                                             gnb_index=0
    ...                                                                             du_index=0
    ${attach_status}    Run Keyword And Return Status    DingLi_Client.UE Attach With Retry    ues_index=${ues_index}    5G_band=78
    ...                                                                                        is_restart_ue=${is_restart_ue}    UE_mode=${UE_mode}
    ${expect_pci_trunk}    Create List    721
    ${expect_pci_branch}    Create List    732
    ${expect_master_pci}    Set Variable IF    '${STREAM_VERSION}'=='master'    ${expect_pci_trunk}    ${expect_pci_branch}
    ${expect_pci}    Set Variable IF    '${expect_sceond_pci}'=='NULL'    ${expect_master_pci}    ${expect_sceond_pci}
    Run Keyword If   '${attach_status}'=='${False}'    DingLi_Client.Check PCI In Attach Info    ues_index=${ues_index}
    ...                                                                                          expect_pci=${expect_pci}
    ${cpif_log_on_testPC}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=cpif_wireshark    target_dir=${TS_CASE_LOG_PATH}    gnb_index=0    du_index=0
    Run Keyword If   '${attach_status}'=='${False}'     FAIL    msg=attach failed.
    [Return]    ${expect_pci}    ${cpif_log_on_testPC}

Start To Attach Mapping Cell Into UE
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${ues_index}=${${0},${1},${2},${3}}    ${tcpdump_collector_name}=cpif_wireshark
    ${ue_cell_mapping_info}    Set Variable   ${TESTCASE_INFO_MAPPING_TABLE['${TL_NAME}']}
    ${ues_index_type}    Evaluate    type(${ues_index}).__name__
    ${convert_ues_index_to_list}    Create List    ${ues_index}
    ${ues_index}    Set Variable If    'list' in '${ues_index_type}' or 'tuple' in '${ues_index_type}'
    ...      ${ues_index}     ${convert_ues_index_to_list}
    Wait Until Keyword Succeeds    5min    30s    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=0
    Connect to Common Unit Master     alias=ASIK Master   gnb_index=0
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log    tcpdump_collector_name=${tcpdump_collector_name}
    ...                                                                             asik_connection_alias=ASIK Master
    ...                                                                             gnb_index=0
    ...                                                                             du_index=0
    ${all_PCIs}    Create List
    FOR    ${ue_index}    IN    @{ues_index}
        ${cell_index}    Set Variable   ${ue_cell_mapping_info['${ue_index}']['cell_index']}
        Change status for parameter cellBarred on GNB    exp_status=notBarred
        ...                                              list_cell_ids=${cell_index}
        ...                                              connection=GNB_OAM
        ...                                              timeout=300
        Sleep    5sec
        ${attach_status}    Run Keyword And Return Status    DingLi_Client.UE Attach With Retry    ues_index=${ue_index}
        ...                                                                                        5G_band=78
        ${expect_pci}    Set Variable    ${ue_cell_mapping_info['${ue_index}']['pci']}
        Append To List    ${all_PCIs}    ${expect_pci}
        Run Keyword If   '${attach_status}'=='${False}'    DingLi_Client.Check PCI In Attach Info    ues_index=${ue_index}
        ...                                                                                          expect_pci=${expect_pci}
        Run Keyword If   '${attach_status}'=='${False}'     FAIL    msg=attach failed.
    END
    Sleep    10sec
    ${cpif_log_on_testPC}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...    tcpdump_collector_name=${tcpdump_collector_name}    target_dir=${TS_CASE_LOG_PATH}    gnb_index=0    du_index=0
    [Return]    ${all_PCIs}    ${cpif_log_on_testPC}

Start To Check The Throughput
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${target_avg_percent}=0.90    ${duration}=120    ${expect_ul_tput}=200    ${expect_dl_tput}=1500
    ...            ${cellid}=1    ${min_percent}=0    ${ue_type}=huawei_sigspark    ${check_source}=aasyslog
    ...            ${ignore_time}=30s
    Check Tput With Power UE    direction_component_list=@{direction_component_list}
    ...                         duration=${duration}
    ...                         expect_ul_tput=${expect_ul_tput}
    ...                         expect_dl_tput=${expect_dl_tput}
    ...                         cellid=${cellid}
    ...                         target_avg_percent=${target_avg_percent}
    ...                         ue_type=${ue_type}
    ...                         check_source=${check_source}
    ...                         min_percent=${min_percent}
    ...                         ignore_time=${ignore_time}

Start To Check The Throughput For Multi UE
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${direction_component_list}=@{direction_component_list}
    ...            ${ues_index}=${${0},${1},${2},${3}}
    ...            ${check_source}=aasyslog
    ...            ${duration}=360
    ...            ${connection}=GNB_OAM
    ...            ${gnb_index}=0
    ...            ${du_index}=0
    ...            ${ignore_time}=30s
    ...            ${target_avg_percent}=0.98
    ...            ${min_percent}=0.85
    ...            ${ue_type}=huawei_sigspark
    ...            ${ue_tupt_mapping}=${TESTCASE_INFO_MAPPING_TABLE}
    ${tput_log}    power_ue.Collect Tput    ue_type=${ue_type}    gnb_index=${gnb_index}
    ...    du_index=${du_index}    duration=${duration}    ignore_time=${ignore_time}    check_source=${check_source}
    FOR    ${ue_index}    IN    @{ues_index}
        ${cellid}    Set Variable    ${TESTCASE_INFO_MAPPING_TABLE['${TL_NAME}']['${ue_index}']['cell_index']}
        ${ul_tput}    Set Variable    ${ue_tupt_mapping['${ue_index}']['expect_ul_tput']}
        ${dl_tput}    Set Variable    ${ue_tupt_mapping['${ue_index}']['expect_dl_tput']}
        Check Tput With Power UE For Multi UE    direction_component_list=${direction_component_list}
        ...                                      tput_log=${tput_log}
        ...                                      expect_ul_tput=${ul_tput}
        ...                                      expect_dl_tput=${dl_tput}
        ...                                      cellid=${cellid}
        ...                                      connection=${connection}
        ...                                      gnb_index=${gnb_index}
        ...                                      target_avg_percent=${target_avg_percent}
        ...                                      ue_type=${ue_type}
        ...                                      check_source=${check_source}
        ...                                      min_percent=${min_percent}
    END

10887_Suite_SetUp
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${swconfig_flag}=${None}
    robot_common_operations.Common Suite Setup
    Run Keyword And Ignore Error    clear vm pid before run case
    @{ue_num}    Set Variable    ${tl.ues}
    ${ue_length}    Get Length    ${ue_num}
    Set Suite Variable    ${UE_LENGTH}    ${ue_length}
    FOR    ${ue_index}    IN RANGE    ${UE_LENGTH}
        ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
        Set Suite Variable    ${UE${ue_index}_TYPE}    ${ue_type}
    END
    ${stream_version}    Get Active SW Version Based On Stream Version
    Set Suite Variable    ${STREAM_VERSION}    ${stream_version}
    ${SCF_Path}    ${result}    Split String From Right    ${CURDIR}    testsuite     1
    ${ute_env}    Run Keyword And Return Status    Run Keywords
    ...    Variable Should Exist    ${CONFIGURATION}    AND    Variable Should Exist    ${ENB_BUILD}
    ${tmp_testline}   Run Keyword If    ${ute_env}    String.Fetch From Right    string=${CONFIGURATION}    marker=.
    ...           ELSE    Set Variable     ${testline_name}
    ${stream}    ${build}     Run Keyword If    ${ute_env}    CI_commssion._Get Stream From Variable    ${ENB_BUILD}
    ...    ELSE   CI_commssion._Get Stream From Variable    ${AF_PATH}
    Set Suite Variable    ${tmp_testline}
    ${tl_prefix}    Set Variable    ${tmp_testline.split('_')[-1][-4:]}
    Set Suite Variable    ${TL_NAME}    ${tl_prefix}
    Set Suite Variable    ${stream}
    Set Suite Variable    ${SCF_PATH}
    ${Golden_SCF_Path}    Set Variable    ${SCF_PATH}commissionings/HGZ/${tmp_testline}/SCF_${stream}_2S-4CC_11026.xml
    Set Suite Variable    ${Golden_SCF_Path}
    Suite Log Path Create
#    Upload Swconfig File And Reset Site
    Sleep    60sec
    Run Keyword If    '${swconfig_flag}'!='${None}'     Backup and Modify swconfig file
    ...                                                 swconfig_modify=@{SWCONFIG_${swconfig_flag}}
    ${ues_index}    Set Variable IF    '${stream}'=='SBTS00'    ${${0},${1},${2},${3},${4},${5},${6},${7}}    ${${0},${1},${2},${3}}
    DingLi_Client.UE Prepare    HW_TYPE=${${testline_name}_HW_TYPE}    ues_index=${ues_index}
#    DingLi_Client.SA And NSA Mode Change
#    Run Keyword And Ignore Error    client.detach     ue=${uegroup}    until_timeout=${300}     withpdu=1
    Sleep    5sec

10887_Suite_Teardown
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${swconfig_flag}=${None}
    Run Keyword And Continue On Failure     Run Keyword If    '${swconfig_flag}'!='${None}'    Connect to Common Unit Master
    Run Keyword And Continue On Failure     Run Keyword If    '${swconfig_flag}'!='${None}'
    ...    swconf.restore_swConfig_file_on_asik_and_crasign    asik_alias=ASIK Master
    Run Keyword And Ignore Error    DingLi_Client.Teardown
    ${1CC_SCF_Path}    Set Variable    ${SCF_PATH}commissionings/HGZ/${tmp_testline}/SCF_${stream}.xml
    Perform Commission    scf_file_path=${1CC_SCF_Path}
    ...                   gnb_index=${0}
    ...                   timeout_for_commission=900
    ...                   wait_gnb_up_timeout=30 min
    ...                   is_pdl_checking_needed=${True}
#    Act Ecpri Mode Switch    scf_path=${1CC_SCF_Path}    switch_to_mode=72a    log_path=${SUITE_LOG_PATH}
    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=GNB_OAM
    robot_common_operations.Common Suite Teardown

10887_Case_SetUp
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${framestructure}=11160ms    ${update_params}=${None}    ${swconfig_flag}=${None}
    Log To Console    \n***start to case setup***
    robot_common_operations.Common Case Setup    fail_with_alarms=${False}
    ${gnb_allowed_fault_Before_Commission}   Create List    4203    1838    4741    4681   7311   7331
    ...                                                     4293    4297    4420    4775   1932   1934    1933
    Set Test Variable    ${gnb_allowed_fault_Before_Commission}
    AlarmWatchdog.add_allow_alarms    fault_id=${gnb_allowed_fault_Before_Commission}
    Create Case Log Path
    ${scf_path}    Set Variable    ${Golden_SCF_Path}
    ${scf_with_framestructure}    update_framestructure_chbw_pdcch_params    framestructure=${framestructure_${framestructure}}
    ...    basic_scf_path=${scf_path}    update_scf_path=${TS_CASE_LOG_PATH}/SCF_${stream}_framestructure_update.xml
    ...    modify_param=${STREAM_VERSION}
    ${scf_with_update_params}    perform_update_scf_params
    ...                          update_params=${update_params}
    ...                          basic_scf_path=${scf_with_framestructure}
    ...                          update_scf_path=${TS_CASE_LOG_PATH}/SCF_${stream}_final_update.xml
    Run Keyword If    '${swconfig_flag}'!='${None}'     Backup and Modify swconfig file
    ...                                                 swconfig_modify=@{SWCONFIG_${swconfig_flag}}
    Perform Commission    scf_file_path=${scf_with_update_params}
    ...                   gnb_index=${0}
    ...                   timeout_for_commission=900
    ...                   wait_gnb_up_timeout=30 min
    ...                   is_pdl_checking_needed=${False}
#    Act Ecpri Mode Switch    scf_path=${scf_with_update_params}    switch_to_mode=72e    log_path=${TS_CASE_LOG_PATH}
    ${numberOfRxBeamforming}    Get numberOfRxBeamforming Via SCF
    Set Test Variable    ${numberOfRxBeamforming}
    ${summary_alarm_info}    Get Active Alarms And Save Summary Infomation
    Set Test Variable    ${summary_alarm_info}
    ${allowed_faults_list}    Combine Current Active Alarm With White List Alarm List
    Set Test Variable    ${ALLOWED_FAULTS_LIST}    ${allowed_faults_list}
    Set MCS Phase And ATT For 10887

10887_Case_Teardown
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    [Arguments]    ${swconfig_flag}=${None}
    Run Keyword And Continue On Failure    robot_common_operations.Common Case Teardown
    Run Keyword And Continue On Failure     Run Keyword If    '${swconfig_flag}'!='${None}'    Connect to Common Unit Master
    Run Keyword And Continue On Failure     Run Keyword If    '${swconfig_flag}'!='${None}'
    ...    swconf.restore_swConfig_file_on_asik_and_crasign    asik_alias=ASIK Master
    Run Keyword And Continue On Failure     Run Keyword If    '${swconfig_flag}'!='${None}'    Do gNB Reset site and Wait Onair
    Run Keyword And Ignore Error    run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_index=${1}     mcs_type=${mcs_type}
    Run Keyword And Ignore Error    DingLi_Client.Stop Data Transfer
    Run Keyword And Ignore Error    DingLi_Client.Detach
    Run Keyword And Ignore Error    Common Case Teardown    is_save_snapshot=False
    Run Keyword And Ignore Error    Capture Snapshot If Case Failed
    Check Whether New Alarm Happened During Running Case    alarm_info_before=${summary_alarm_info}

Set MCS Phase And ATT For 10887
    [Documentation]  Author: jun.8.chen@nokia-sbell.com
    ${mcs_type}    mcs_common.Get MCS Type    mcs_index=${1}
    Set Test Variable    ${mcs_type}
    mcs_common.Setup MCS    mcs_type=${mcs_type}    frequency=${None}    mcs_index=${1}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${1}   first_beam_end_output_port=${2}
    ...    second_beam_begin_output_port=${3}    second_beam_end_output_port=${4}
    ...    first_beam_horizontal_angle=${-7}    second_beam_horizontal_angle=${22}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=10
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}    end_input_port=${32}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${5}   first_beam_end_output_port=${6}
    ...    second_beam_begin_output_port=${7}    second_beam_end_output_port=${8}
    ...    first_beam_horizontal_angle=${7}    second_beam_horizontal_angle=${-22}    vertical_angle=${-6}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=30
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}    end_input_port=${32}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${9}   first_beam_end_output_port=${10}
    ...    second_beam_begin_output_port=${11}    second_beam_end_output_port=${12}
    ...    first_beam_horizontal_angle=${-7}    second_beam_horizontal_angle=${22}    vertical_angle=${-10}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=20
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}    end_input_port=${32}
    Mcs.Set Phases According To Angles For Two Output Groups    mcs_type=${mcs_type}    mcs_index=${1}
    ...    first_beam_begin_output_port=${13}   first_beam_end_output_port=${14}
    ...    second_beam_begin_output_port=${15}    second_beam_end_output_port=${16}
    ...    first_beam_horizontal_angle=${7}    second_beam_horizontal_angle=${-22}    vertical_angle=${-10}
    ...    vertical_distance=${2}    end_input_port=${16}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=22
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}    end_input_port=${32}

    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=90
    ...    first_beam_begin_output_port=${1}    second_beam_end_output_port=${4}
    ...    begin_input_port=${33}    end_input_port=${64}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=90
    ...    first_beam_begin_output_port=${5}    second_beam_end_output_port=${8}
    ...    begin_input_port=${33}    end_input_port=${64}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=90
    ...    first_beam_begin_output_port=${9}    second_beam_end_output_port=${12}
    ...    begin_input_port=${33}    end_input_port=${64}
    Mcs.Set ATT Value For Four Output Ports     mcs_type=${mcs_type}    mcs_index=${1}     att_value=90
    ...    first_beam_begin_output_port=${13}    second_beam_end_output_port=${16}
    ...    begin_input_port=${33}    end_input_port=${64}