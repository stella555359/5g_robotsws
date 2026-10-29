# *** Settings ***
# Documentation     Author: shuihe
# ...
# ...               QC case full name:
# ...               CNI105506_case01_16positions_16layers_16ues
# 
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# #Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_lilyu
# Test Timeout      120 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg10/internal_resource/internal_capture_log.robot
# Library          ../../resources/sg10/internal_resource/lib/check_btslog.py
# 
# *** Variables ***
# #${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${CONFIG_DIR_PATH}      ${CURDIR}/config
# ${SCFC_NAME}     gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_CNI105506.xml
# ${AIRPHONE_NAME}    AP_iphy_AEHC_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_CNI105506.xml
# ${WTS_NAME}    wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_CNI105506.cfg
# @{LOG_NAME_LIST}    egatelog\
# ${UE_NUM}         16
# ${PDU_ID}         1
# ${SLICE_ID}       1
# ${par_of_bsr_name}       BSR_AEHC_6_H6_ALN60
# 
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# #${dlMimoMode}                                   text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${dlMimoMode}                                   text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|16DL8UL|//*[@name\="nrCellType"]
# ${actDlMuMimoEnh}                               text|true|//*[@name\="actDlMuMimoEnh"]
# ${dlMuMimoCorrThd}                              text|50|//*[@name\="dlMuMimoCorrThd"]
# ${dlMuMimoCqiThd}                               text|1|//*[@name\="dlMuMimoCqiThd"]
# ${dlMuMimoRankAdaption}                         text|adaptive|//*[@name\="dlMuMimoRankAdaption"]
# ${dlMuMimoSpectralEffThd}                       text|10|//*[@name\="dlMuMimoSpectralEffThd"]
# ${dlMuMimoTaperingH}                            text|25dB|//*[@name\="dlMuMimoTaperingH"]
# ${dlMuMimoTaperingV}                            text|NoTapering|//*[@name\="dlMuMimoTaperingV"]
# ${dlMuMaxNumLayerPerMuRbg}                      text|16|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
# ${actDl256Qam}                                  text|false|//*[@name\="actDl256Qam"]
# #ulmumimo
# ${actUlMuMimoTapering}                          text|false|//*[@name\="actUlMuMimoTapering"]
# ${actUlSrsBm}                                   text|true|//*[@name\="actUlSrsBm"]
# ${actUlMuMimo}                                  text|false|//*[@name\="actUlMuMimo"]
# ${ulMaxMuMimoLayer}                             text|4|//*[@name\="ulMaxMuMimoLayer"]
# ${ulMinPrbThreshold}                            text|50|//*[@name\="ulMinPrbThreshold"]
# ${ulMuMimoPrbThresholdAbsolute}                 text|15|//*[@name\="ulMuMimoPrbThresholdAbsolute"]
# ${ulMuMimoCorrThd}                              text|50|//*[@name\="ulMuMimoCorrThd"]
# ${ulMuMimoSinrThd}                              text|5|//*[@name\="ulMuMimoSinrThd"]
# ${ulMuMimoSpectralEffThd}                       text|1|//*[@name\="ulMuMimoSpectralEffThd"]
# ${ulMuMimoLinkAdaptionSwitch}                   text|MU-SINR estimation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
# ${actUl256Qam}                                  text|true|//*[@name\="actUl256Qam"]
# 
# #1070
# ${frameStructureType}                           text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}                            text|3/7|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                      text|98|//*[@name\="prachConfigurationIndex"]
# 
# ${cSRS}                                         text|63|//*[@name\="cSRS"]
# ${bSRS}                                         text|0|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|0|//*[@name\="msg1FrequencyStart"]
# ${srsUePeriodicity}                             text|slots80|//*[@name\="srsUePeriodicity"]
# #bwp
# ${bwp_profile6}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-6|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile66}     text|MRBTS-1/NRBTS-1/BWP_PROFILE-66|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# ${pattern}    CA_P2_8x4_t2r4_n2
# @{custom_error}    WRN/L2-PS    L2_PS_L2NRT_ ERR    WRN/.uplane/L2-PS    ERR/
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE2}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=1 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE3}    ul_mimo_srs_beam_pos_nr profile_id\=3 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=2 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=3 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE5}    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE6}    ul_mimo_srs_beam_pos_nr profile_id\=6 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=1 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE7}    ul_mimo_srs_beam_pos_nr profile_id\=7 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=2 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE8}    ul_mimo_srs_beam_pos_nr profile_id\=8 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=3 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE9}    ul_mimo_srs_beam_pos_nr profile_id\=9 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE10}    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=1 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE11}    ul_mimo_srs_beam_pos_nr profile_id\=11 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE12}    ul_mimo_srs_beam_pos_nr profile_id\=12 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE13}    ul_mimo_srs_beam_pos_nr profile_id\=13 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=0 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE14}    ul_mimo_srs_beam_pos_nr profile_id\=14 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=1 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE15}    ul_mimo_srs_beam_pos_nr profile_id\=15 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${PROFILE16}    ul_mimo_srs_beam_pos_nr profile_id\=16 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 step\=5 
#    ...    trigger_puxch_update\=0 test_type=SRS
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1-2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# ${SET_PROFILE2}    ue_testmode_set_nr id\=3-4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2
# ${SET_PROFILE3}    ue_testmode_set_nr id\=5-6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3
# ${SET_PROFILE4}    ue_testmode_set_nr id\=7-8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4
# ${SET_PROFILE5}    ue_testmode_set_nr id\=9-10 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5
# ${SET_PROFILE6}    ue_testmode_set_nr id\=11-12 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6
# ${SET_PROFILE7}    ue_testmode_set_nr id\=13-14 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7
# ${SET_PROFILE8}    ue_testmode_set_nr id\=15-16 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8
# 
# ${quadrantMappings}    <quadrantMappings>
# ...                        <azQuadCenterUpper>0</azQuadCenterUpper>
# ...                        <azQuadCenterLower>0</azQuadCenterLower>
# ...                        <azSubQuadBorderUpperLeft>-30</azSubQuadBorderUpperLeft>
# ...                        <azSubQuadBorderLowerLeft>-30</azSubQuadBorderLowerLeft>
# ...                        <azSubQuadBorderUpperRight>30</azSubQuadBorderUpperRight>
# ...                        <azSubQuadBorderLowerRight>30</azSubQuadBorderLowerRight>
# ...                        <elQuadCenterLeft>90</elQuadCenterLeft>
# ...                        <elQuadCenterRight>90</elQuadCenterRight>
# ...                        <elSubQuadBorderUpperLeft>95</elSubQuadBorderUpperLeft>
# ...                        <elSubQuadBorderUpperRight>95</elSubQuadBorderUpperRight>
# ...                        <elSubQuadBorderLowerLeft>85</elSubQuadBorderLowerLeft>
# ...                        <elSubQuadBorderLowerRight>85</elSubQuadBorderLowerRight>
# ...                        <deltaAz>30</deltaAz>
# ...                        <deltaEl>6</deltaEl>
# ...                     </quadrantMappings>
# 
# *** Test Cases ***
# CNI105506_case01_16positions_16layers_16ues
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 16UEs
#     Step3:Push full buffer in DL
# 	Step8:Detach all UEs
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     #Start Capture GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
# 	modify_iphy    ${CONFIG_DIR_PATH}
# #    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CNI105506    ${CURDIR}/config/${SW_BRANCH}${/}SCF${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}${/}SCF${/}${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}     ${bwp_profile6}    ${bwp_profile66}
#     ...       ${frameStructureType}     ${guardPeriodLength}    ${ulDlDataSlotRatio}   ${prachConfigurationIndex}
#     ...       ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${srsUePeriodicity}
#     ...       ${actDlMuMimoEnh}    ${dlMuMimoCorrThd}    ${dlMuMimoCqiThd}    ${dlMuMimoSpectralEffThd}    ${dlMuMimoRankAdaption}
#     ...       ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}    ${dlMuMaxNumLayerPerMuRbg}
# #    ...       ${actUlMuMimoTapering}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}    ${ulMinPrbThreshold}    ${ulMuMimoPrbThresholdAbsolute}
# #    ...       ${ulMuMimoCorrThd}    ${ulMuMimoSinrThd}    ${ulMuMimoSpectralEffThd}    ${ulMuMimoLinkAdaptionSwitch}    ${actUl256Qam}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    ${par_of_bsr_name}
# #    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
# 	Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CURDIR}/config/${SW_BRANCH}${/}WTS${/}${WTS_NAME}
#     ...    reset_after_commission=${False}
#     #[Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File '${custom_error}'
# 	
# modify_swconfig_by_CNI105506
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}
# 	${local_save_path}=     Download All Common Config Files From Golden Server
# 	#${path_gnb}=            QC Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
#     ${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
# 	add_txt_node   0x9D0000:15        #as PM counter period update to 15/15=1min, 0x340000 was replaced by 0x9D0000
# 	add_txt_node   0x580264:0x3         #coma log
# 	add_txt_node   0x580477:1         #print beam calc log
# 	add_txt_node   0x450:10         #rdParallelSchScheme
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
# 
# Step2:Attach 16UEs
#     Start Capture GNB and AP Syslog in 'Step2_attach' File
#     #Start GNB BIP Log
#     Set UEs Pos
#     Attach SA ue with capability to 5g cell    16    CA_P2_8x4_t2r4_n2
#     #set_ue_layer    8    1
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
# 	Set test Variable	 ${rnti_1} 	${rnti_list[0]}
# 	Set test Variable	 ${rnti_2} 	${rnti_list[1]}
# 	Set test Variable	 ${rnti_3} 	${rnti_list[2]}
# 	Set test Variable	 ${rnti_4} 	${rnti_list[3]}
# 	Set test Variable	 ${rnti_5} 	${rnti_list[4]}
# 	Set test Variable	 ${rnti_6} 	${rnti_list[5]}
# 	Set test Variable	 ${rnti_7} 	${rnti_list[6]}
# 	Set test Variable	 ${rnti_8} 	${rnti_list[7]}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step2_attach' File '${custom_error}'
# 
# Step3:Push full buffer in DL
#     Start Capture GNB and AP Syslog in 'Step3_inject_buffer' File
#     #Start GNB BIP Log
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_inject_buffer
#     FOR    ${ID}    IN RANGE    1    17
#     Airphone SA Start Data Traffic    ${ID}    DL    175M    trf_id=1    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    ${ID}    DL    175M    trf_id=2    pdu_id=1    duration=${3600}
#     END
#     Wait Throughput Timer    2
#     capture_decode_ttiTrace    ${save_log}
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/case02_tti_dl.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     #${PM_counter_file}    download PM counter file    ${save_log}
#     #${PPRB_DL_MU_MIMO_16LAYER}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C34023    
#    ...    cell_id=1
# 	#${dL_thp_counter}=             get_counter_value_from_counter_file    counter_file=${PM_counter_file}       counter_id=M55309C12001
# 	#run keyword and continue on failure    should be true    ${dL_thp_counter} > 0
# 	#run keyword and continue on failure    should be true    ${PPRB_DL_MU_MIMO_16LAYER} >0
# 	#run keyword and continue on failure    GET THP
#     Build excel table
#     ${PM_counter_file}    Get counter file
#     ${8701_pair_counter_for_table}    Ideal line PRB_mulayer counter check    ${PM_counter_file}
#     ${9235_kpi_list}    KPI counter check    ${PM_counter_file}
# 	Record result for 9235 perfomance    1
#     ...    ${8701_pair_counter_for_table}    ${9235_kpi_list}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3_inject_buffer' File '${custom_error}'
# 
# Step8:Detach all UEs
#     Start capture GNB and AP Syslog in 'Step8_Detach_all_UEs' File
#     : FOR    ${i}    IN RANGE    1    16
#     \    Detach UE    ${i}
#     [Teardown]    run keyword and continue on failure    Stop capture GNB and AP Syslog in 'Step8_Detach_all_UEs' File '${custom_error}'
# 	
# Detach UE
#     [Arguments]    ${ue_id} 
#     airphone_sa_detach    ue_id=${ue_id}    timeout=30
# 
# GET THP
# 	FOR    ${ID}    IN RANGE    1    ${UE_NUM}+1
#     ${dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${ID}    type=pdsch    tput_type=current
#     END
# 
# Set UEs Pos
#     : FOR    ${num}    IN RANGE    1    17    #16pos
#     \    airphone_execute_egate_command    ${PROFILE${num}}
#     \    airphone_execute_egate_command    ue_testmode_set_nr id\=${num} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${num}
# 
# modify_iphy
#     [Arguments]    ${CONFIG_DIR_PATH}
#     add_xml_element
# 	...   ${CONFIG_DIR_PATH}${/}WTS${/}${AIRPHONE_NAME}    ${TEST_LOG_DIRECTORY()}${/}iphy_mod1.xml  ${quadrantMappings}|//vcell
#     change_iphy_rru_version    ${TEST_LOG_DIRECTORY()}${/}iphy_mod1.xml
# 
# set_ue_layer
#     [Arguments]    ${ue_num}    ${ri}
#     : FOR    ${num}    IN RANGE    1    ${ue_num}+1
#     \    csi_override_testmode_active    ueid=${num}    profile_id=1   ri=${ri}
# 
# capture_decode_ttiTrace
#     [Arguments]    ${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 
# Build excel table
#     ${colomn_9235}   create list
#     : FOR    ${num}    IN RANGE    2    17
#     \    append to list    ${colomn_9235}    PRB_DL_MU_MIMO_layer${num}
#     append to list    ${colomn_9235}    sum_prb_layer_X_layer
#     append to list    ${colomn_9235}    PRB_DL_SU_MIMO_layer_total
#     append to list    ${colomn_9235}    PRB_DL_MU_MIMO_layer_total
# 	append to list    ${colomn_9235}    PRB_DL_MU_MIMO_NOPAIR_UE    PRB_DL_MU_MIMO_2PAIR_UE    PRB_DL_MU_MIMO_3PAIR_UE    PRB_DL_MU_MIMO_4PAIR_UE
# 	...    PRB_DL_MU_MIMO_5PAIR_UE    PRB_DL_MU_MIMO_6PAIR_UE    PRB_DL_MU_MIMO_7PAIR_UE    PRB_DL_MU_MIMO_8PAIR_UE
#     append to list    ${colomn_9235}    KPI_NR_5055_bresidual_bler    KPI_NR_5054a_iniBler    KPI_NR_5108dSE_downlink    KPI_NR_5109dSE_uplink
#     append to list    ${colomn_9235}    KPI_NR_5242b_cell_tp_avg    KPI_NR_5258a_cell_tp_max    KPI_NR_5100b_ue_tp_avg   
#    ...     KPI_NR_5192c_UE_num_perTTi
#     modify excel cell       ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     0    0    ${SOFTWARE_INFO}_CB009235_perfomance_case11
#     : FOR    ${num}    IN RANGE    0    34
#     \    ${num_table}    evaluate    ${num}+1
#     \    modify excel cell       ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     ${num_table}    0    ${colomn_9235[${num}]}
# 
# Get counter file
#     Wait '60s' for stable
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     log to console    ${remaining_time}
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}pmcounter${/}
#     [Return]    ${PM_counter_file}
# 
# Ideal line PRB_mulayer counter check
#     [Arguments]    ${PM_counter_file}
#     ${8701_pair_counter}   create list
#     ${8701_pair_counter_for_table}   create list
#     : FOR    ${num}    IN RANGE    1    30
#     \    ${counter_1}   evaluate   4000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C3${counter_1}    cell_id=1
#     \    append to list    ${8701_pair_counter}    ${result}
#     log to console    8701_pair_counter all is = ${8701_pair_counter}
#     log to console    PRB_DL_SU_MIMO_layer_1_2_3_4 are = ${8701_pair_counter[0:4]}
#     log to console    PRB_DL_MU_MIMO_layer2_3_4_5_6_7_8 are = ${8701_pair_counter[4:11]}
#     log to console    PRB_DL_MU_MIMO_layer2 is = ${8701_pair_counter[4]}
#     log to console    PRB_DL_MU_MIMO_layer3 is = ${8701_pair_counter[5]}
#     log to console    PRB_DL_MU_MIMO_layer4 is = ${8701_pair_counter[6]}
#     log to console    PRB_DL_MU_MIMO_layer5 is = ${8701_pair_counter[7]}
#     log to console    PRB_DL_MU_MIMO_layer6 is = ${8701_pair_counter[8]}
#     log to console    PRB_DL_MU_MIMO_layer7 is = ${8701_pair_counter[9]}
#     log to console    PRB_DL_MU_MIMO_layer8 is = ${8701_pair_counter[10]}
#     log to console    PRB_DL_MU_MIMO_paired_UE_0_2_3_4_5_6_7_8 are = ${8701_pair_counter[11:15]} ${8701_pair_counter[23:27]}
#     log to console    PRB_DL_MU_MIMO_layer_9_10_11_12_13_14_15_16 are = ${8701_pair_counter[15:23]}
#     log to console    PRB_DL_MU_MIMO_layer_9 is = ${8701_pair_counter[15]}
#     log to console    PRB_DL_MU_MIMO_layer_10 is = ${8701_pair_counter[16]}
#     log to console    PRB_DL_MU_MIMO_layer_11 is = ${8701_pair_counter[17]}
#     log to console    PRB_DL_MU_MIMO_layer_12 is = ${8701_pair_counter[18]}
#     log to console    PRB_DL_MU_MIMO_layer_13 is = ${8701_pair_counter[19]}
#     log to console    PRB_DL_MU_MIMO_layer_14 is = ${8701_pair_counter[20]}
#     log to console    PRB_DL_MU_MIMO_layer_15 is = ${8701_pair_counter[21]}
#     log to console    PRB_DL_MU_MIMO_layer_16 is = ${8701_pair_counter[22]}
#     log to console    TOT_MU_MIMO_PAIR_UE and TOT_MU_MIMO_ELIG_UE are = ${8701_pair_counter[27]} ${8701_pair_counter[28]}
#     ${sum_prb_layer1}    evaluate    ${8701_pair_counter[4]}*2+${8701_pair_counter[5]}*3+${8701_pair_counter[6]}*4
#     ${sum_prb_layer2}    evaluate    ${8701_pair_counter[7]}*5+${8701_pair_counter[8]}*6+${8701_pair_counter[9]}*7+${8701_pair_counter[10]}*8
#     ${sum_prb_layer3}    evaluate    ${8701_pair_counter[15]}*9+${8701_pair_counter[16]}*10+${8701_pair_counter[17]}*11+${8701_pair_counter[18]}*12
#     ${sum_prb_layer4}    evaluate    
#    ...    ${8701_pair_counter[19]}*13+${8701_pair_counter[20]}*14+${8701_pair_counter[21]}*15+${8701_pair_counter[22]}*16
#     ${sum_prb_layer_X_layer}    evaluate    ${sum_prb_layer1}+${sum_prb_layer2}+${sum_prb_layer3}+${sum_prb_layer4}
# 
#     log to console    sum_prb_layer_X_layer is ${sum_prb_layer_X_layer}
# 
#     ${PRB_DL_SU_MIMO_layer_total}    evaluate    sum(${8701_pair_counter[0:4]})
#     ${PRB_DL_MU_MIMO_layer_total}    evaluate    sum(${8701_pair_counter[4:11]})+sum(${8701_pair_counter[15:23]})
#     ${PRB_DL_MU_paired_UE_total}    evaluate    sum(${8701_pair_counter[12:15]})+sum(${8701_pair_counter[23:27]})
# 	#${PRB_DL_MU_MIMO_NOPAIR_UE}    evaluate    ${8701_pair_counter[11]}
# 	#${PRB_DL_MU_MIMO_2PAIR_UE}    evaluate    ${8701_pair_counter[12]}
# 	#${PRB_DL_MU_MIMO_3PAIR_UE}    evaluate    ${8701_pair_counter[13]}
# 	#${PRB_DL_MU_MIMO_4PAIR_UE}    evaluate    ${8701_pair_counter[14]}
# 	#${PRB_DL_MU_MIMO_5PAIR_UE}    evaluate    ${8701_pair_counter[23]}
# 	#${PRB_DL_MU_MIMO_6PAIR_UE}    evaluate    ${8701_pair_counter[24]}
# 	#${PRB_DL_MU_MIMO_7PAIR_UE}    evaluate    ${8701_pair_counter[25]}
# 	#${PRB_DL_MU_MIMO_8PAIR_UE}    evaluate    ${8701_pair_counter[26]}
# #    ${pair_to_muelig}    evaluate    ${8701_pair_counter[27]}/${8701_pair_counter[28]}
#     run keyword and continue on failure   should be true   ${PRB_DL_MU_MIMO_layer_total}==${PRB_DL_MU_paired_UE_total}
#     run keyword and continue on failure   should be true   ${PRB_DL_SU_MIMO_layer_total}==${8701_pair_counter[11]}
#     run keyword and continue on failure   should be true   ${PRB_DL_MU_MIMO_layer_total}==${PRB_DL_MU_paired_UE_total}
# #    run keyword and continue on failure   should be true   ${pair_to_muelig}>0.98
#     log to console    PRB_DL_SU_MIMO_layer_total is = ${PRB_DL_SU_MIMO_layer_total}
#     log to console    PRB_DL_MU_MIMO_layer_total is = ${PRB_DL_MU_MIMO_layer_total}
#     log to console    PRB_DL_MU_paired_UE_total is = ${PRB_DL_MU_paired_UE_total}
#     append to list    ${8701_pair_counter_for_table}    ${8701_pair_counter[4]}    ${8701_pair_counter[5]}    ${8701_pair_counter[6]}
#     ...    ${8701_pair_counter[7]}    ${8701_pair_counter[8]}    ${8701_pair_counter[9]}    ${8701_pair_counter[10]}
#     ...    ${8701_pair_counter[15]}    ${8701_pair_counter[16]}    ${8701_pair_counter[17]}    ${8701_pair_counter[18]}
#     ...    ${8701_pair_counter[19]}    ${8701_pair_counter[20]}    ${8701_pair_counter[21]}    ${8701_pair_counter[22]}
#     ...    ${sum_prb_layer_X_layer}    ${PRB_DL_SU_MIMO_layer_total}    ${PRB_DL_MU_MIMO_layer_total}
# 	...    ${8701_pair_counter[11]}    ${8701_pair_counter[12]}    ${8701_pair_counter[13]}    ${8701_pair_counter[14]}
# 	...    ${8701_pair_counter[23]}    ${8701_pair_counter[24]}    ${8701_pair_counter[25]}    ${8701_pair_counter[26]}
#     set global variable    ${8701_pair_counter}
#     set global variable    ${8701_pair_counter_for_table}
#     [Return]    ${8701_pair_counter_for_table}
# 
# KPI counter check
#     [Arguments]    ${PM_counter_file}
#     ${PDSCH_UNSUCC_64TBL_MCS}    create list
#     ${PDSCH_SUCC_ANY_64TBL_MCS}    create list
#     ${PDSCH_UNSUCC_256TBL_MCS}    create list
#     ${PDSCH_SUCC_ANY_256TBL_MCS}    create list
#     : FOR    ${num}    IN RANGE    0    32
#     \    ${counter_2}   evaluate   2000+${num}
#     \    ${counter_3}   evaluate   3000+${num}
#     \    ${counter_6}   evaluate   6000+${num}
#     \    ${counter_7}   evaluate   7000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0${counter_2}    cell_id=1
#     \    append to list    ${PDSCH_SUCC_ANY_64TBL_MCS}    ${result}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0${counter_3}    cell_id=1
#     \    append to list    ${PDSCH_UNSUCC_64TBL_MCS}    ${result}
# 
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0${counter_6}    cell_id=1
#     \    append to list    ${PDSCH_SUCC_ANY_256TBL_MCS}    ${result}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0${counter_7}    cell_id=1
#     \    append to list    ${PDSCH_UNSUCC_256TBL_MCS}    ${result}
# 
# #    log to console    PDSCH_SUCC_ANY_64TBL_MCS 0_to_31 is ${PDSCH_SUCC_ANY_64TBL_MCS}
# #    log to console    PDSCH_UNSUCC_64TBL_MCS 0_to_31 is ${PDSCH_UNSUCC_64TBL_MCS}
# #    log to console    PDSCH_SUCC_ANY_256TBL_MCS 0_to_31 is ${PDSCH_SUCC_ANY_256TBL_MCS}
# #    log to console    PDSCH_UNSUCC_256TBL_MCS 0_to_31 is ${PDSCH_UNSUCC_256TBL_MCS}
#     ${unsucc}    evaluate    sum(${PDSCH_UNSUCC_64TBL_MCS})+sum(${PDSCH_UNSUCC_64TBL_MCS})
#     ${SUCC_ANY}    evaluate    sum(${PDSCH_SUCC_ANY_64TBL_MCS})+sum(${PDSCH_SUCC_ANY_256TBL_MCS})
#     ${NR_5055b}    evaluate    ${unsucc}/(${SUCC_ANY}+${unsucc})
#     run keyword and continue on failure   should be true   ${NR_5055b}<0.001
# #    log to console    KPI NR_5055b residual bler is ${NR_5055b}
# 
#     ${PDSCH_INITX_64TBL_MCS}    create list
#     ${PDSCH_SUCC_INI_64TBL_MCS}    create list
#     ${PDSCH_INI_256TBL_MCS}    create list
#     ${PDSCH_SUCC_INI_256TBL_MCS}    create list
# 
#     : FOR    ${num}    IN RANGE    0    10
#     \    ${counter_0}   evaluate   0+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0000${counter_0}    cell_id=1
#     \    append to list    ${PDSCH_INITX_64TBL_MCS}    ${result}
#     : FOR    ${num}    IN RANGE    10    29
#     \    ${counter_0}   evaluate   0+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C000${counter_0}    cell_id=1
#     \    append to list    ${PDSCH_INITX_64TBL_MCS}    ${result}
#     : FOR    ${num}    IN RANGE    0    29
#     \    ${counter_1}   evaluate   1000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0${counter_1}    cell_id=1
#     \    append to list    ${PDSCH_SUCC_INI_64TBL_MCS}    ${result}
#     : FOR    ${num}    IN RANGE    0    28   #256qam mcs max 28
#     \    ${counter_4}   evaluate   4000+${num}
#     \    ${counter_5}   evaluate   5000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0${counter_4}    cell_id=1
#     \    append to list    ${PDSCH_INI_256TBL_MCS}    ${result}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55300C0${counter_5}    cell_id=1
#     \    append to list    ${PDSCH_SUCC_INI_256TBL_MCS}    ${result}
# 
# #    log to console    PDSCH_INITX_64TBL_MCS 0_to_28 is ${PDSCH_INITX_64TBL_MCS}
# #    log to console    PDSCH_SUCC_INI_64TBL_MCS 0_to_28 is ${PDSCH_SUCC_INI_64TBL_MCS}
# #    log to console    PDSCH_INI_256TBL_MCS 0_to_27 is ${PDSCH_INI_256TBL_MCS}
# #    log to console    PDSCH_SUCC_INI_256TBL_MCS 0_to_27 is ${PDSCH_SUCC_INI_256TBL_MCS}
# 
#     ${ini_tx}    evaluate    sum(${PDSCH_INITX_64TBL_MCS})+sum(${PDSCH_INI_256TBL_MCS})
#     ${ini_SUCC}    evaluate    sum(${PDSCH_SUCC_INI_64TBL_MCS})+sum(${PDSCH_SUCC_INI_256TBL_MCS})
#     ${NR_5054a}    evaluate    (${ini_tx}-${ini_SUCC})/${ini_tx}
#     run keyword and continue on failure   should be true   ${NR_5054a}<0.1
# 
# 
#     ${PDSCH_INIRE_VOL_64TBL_MCS}    create list
#     ${PDSCH_INIRE_VOL_256TBL_MCS}    create list
#     : FOR    ${num}    IN RANGE    0    32
#     \    ${counter_22}   evaluate   2000+${num}
#     \    ${counter_6}   evaluate   6000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C0${counter_22}    cell_id=1
#     \    append to list    ${PDSCH_INIRE_VOL_64TBL_MCS}    ${result}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C0${counter_6}    cell_id=1
#     \    append to list    ${PDSCH_INIRE_VOL_256TBL_MCS}    ${result}
# #    log to console    PDSCH_INIRE_VOL_64TBL_MCS 0_to_31 is ${PDSCH_INIRE_VOL_64TBL_MCS}
# #    log to console    PDSCH_INIRE_VOL_256TBL_MCS 0_to_31 is ${PDSCH_INIRE_VOL_256TBL_MCS}
# 
#     ${rt1}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C03005    cell_id=1
#     ${rt2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C10001    cell_id=1
#     ${rt3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00008    cell_id=1
#     ${rt4}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00016    cell_id=1
#     ${rt5}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00018    cell_id=1
#     ${NR_5108d_numerato}    evaluate    8*(sum(${PDSCH_INIRE_VOL_64TBL_MCS})+sum(${PDSCH_INIRE_VOL_256TBL_MCS}))
#     ${NR_5108d}    evaluate    ${NR_5108d_numerato}/(${rt1}*180*(${rt2}/(${rt3}+${rt4}+${rt5})))
# #    log to console    KPI NR_5108d SE_downlink is ${NR_5108d}
# 
#     ${L_M55304C0400X}   create list
#     ${M55304C0400X}    set variable    0
#     : FOR    ${num}    IN RANGE    0    10
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C0400${num}    cell_id=1
#     \    ${M55304C0400X}    Evaluate    ${M55304C0400X}+${result}
#     \    append to list    ${L_M55304C0400X}    ${result}
# 
#     : FOR    ${num}    IN RANGE    10    32
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C040${num}    cell_id=1
#     \    ${M55304C0400X}    Evaluate    ${M55304C0400X}+${result}
#     \    append to list    ${L_M55304C0400X}    ${result}
# 
#     ${L_M55304C0800X}   create list
#     ${M55304C0800X}    set variable    0
#     : FOR    ${num}    IN RANGE    0    10
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C0800${num}    cell_id=1
#     \    ${M55304C0800X}    Evaluate    ${M55304C0800X}+${result}
#     \    append to list    ${L_M55304C0800X}    ${result}
# 
#     : FOR    ${num}    IN RANGE    10    32
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C080${num}    cell_id=1
#     \    ${M55304C0800X}    Evaluate    ${M55304C0800X}+${result}
#     \    append to list    ${L_M55304C0800X}    ${result}
# 
#     ${L_M55304C1000X}   create list
#     ${M55304C1000X}    set variable    0
#     : FOR    ${num}    IN RANGE    0    10
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C1000${num}    cell_id=1
#     \    ${M55304C1000X}    Evaluate    ${M55304C1000X}+${result}
#     \    append to list    ${L_M55304C1000X}    ${result}
# 
#     : FOR    ${num}    IN RANGE    10    32
#     \    ${result}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C100${num}    cell_id=1
#     \    ${M55304C1000X}    Evaluate    ${M55304C1000X}+${result}
#     \    append to list    ${L_M55304C1000X}    ${result}
# 
#     ${top_counter}    Evaluate    (${M55304C0400X}+${M55304C0800X}+${M55304C1000X})*8
#     ${L_M55308}   create list
#     ${M55308C03006}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C03006    cell_id=1
#     ${M55308C10002}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C10002    cell_id=1
#     ${M55308C00009}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00009    cell_id=1
#     ${M55308C00011}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00011    cell_id=1
#     append to list    ${L_M55308}    ${M55308C03006}
#     append to list    ${L_M55308}    ${M55308C10002}
#     append to list    ${L_M55308}    ${M55308C00009}
#     append to list    ${L_M55308}    ${M55308C00011}
#     ${bottom_counter}    Evaluate    ${M55308C03006}*180*(float(${M55308C10002})/(${M55308C00009}+${M55308C00011}))
#     ${NR_5109d}    Evaluate    float(${top_counter}/${bottom_counter})
# #    log to console    64qam:${L_M55304C0400X}
# #    log to console    dft_s_ofdm:${L_M55304C0800X}
# #    log to console    256qam:${L_M55304C1000X}
# #    log to console    ${L_M55308}
# #    log to console    SE_KPI_Value=${NR_5109d}
# 
#     ${MEAS_PERIOD_NR_MAC_PDU_TPUT}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55309C12001    cell_id=1
#     ${NR_5258a}    evaluate    8*${MEAS_PERIOD_NR_MAC_PDU_TPUT}/1000000
# #    log to console    KPI NR_5258a MAC SDU Cell Throughput in DL on DTCH is = ${NR_5258a}
# 
#     ${PDSCH_INI_VOL_64TBL_MCS_list}    create list
#     ${PDSCH_INI_VOL_256TBL_MCS_list}    create list
#     ${PDSCH_INI_VOL_LOWSE_MCS_list}    create list
#     : FOR    ${num}    IN RANGE    0    29
#     \    ${counter_2}   evaluate   1000+${num}
#     \    ${counter_3}   evaluate   5000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C0${counter_2}    cell_id=1
#     \    append to list    ${PDSCH_INI_VOL_64TBL_MCS_list}    ${result}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55366C0${counter_3}    cell_id=1
#     \    append to list    ${PDSCH_INI_VOL_LOWSE_MCS_list}    ${result}
#     : FOR    ${num}    IN RANGE    0    28
#     \    ${counter_3}   evaluate   5000+${num}
# 	\    ${result}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C0${counter_3}    cell_id=1
#     \    append to list    ${PDSCH_INI_VOL_256TBL_MCS_list}    ${result}
# 
#     ${MEAS_PERIOD_NR_MAC_PDU_TPUT}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55304C00001    cell_id=1
#     ${PRB_USED_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C10001    cell_id=1
#     ${PRB_AVAIL_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C10003    cell_id=1
# #    log to console    PDSCH_INI_VOL_64TBL_MCS_list 0_to_28 is ${PDSCH_INI_VOL_64TBL_MCS_list}
# #    log to console    PDSCH_INI_VOL_256TBL_MCS_list 0_to_27 is ${PDSCH_INI_VOL_256TBL_MCS_list}
# #    log to console    MEAS_PERIOD_NR_MAC_PDU_TPUT is ${MEAS_PERIOD_NR_MAC_PDU_TPUT}
# #    log to console    PRB_USED_PDSCH is ${PRB_USED_PDSCH}
# #    log to console    PRB_AVAIL_PDSCH is ${PRB_AVAIL_PDSCH}
# 
#     ${PDSCH_INI_VOL_64TBL_MCS_sum}    evaluate    sum(${PDSCH_INI_VOL_64TBL_MCS_list})
#     ${PDSCH_INI_VOL_256TBL_MCS_sum}    evaluate    sum(${PDSCH_INI_VOL_256TBL_MCS_list})
#     ${PDSCH_INI_VOL_LOWSE_MCS_sum}    evaluate    sum(${PDSCH_INI_VOL_LOWSE_MCS_list})
#     ${NR_5242b_fenzi1}    evaluate    8*(${PDSCH_INI_VOL_64TBL_MCS_sum}+${PDSCH_INI_VOL_256TBL_MCS_sum}+${PDSCH_INI_VOL_LOWSE_MCS_sum})
#     ${NR_5242b_fenzi2}    evaluate    ${NR_5242b_fenzi1}/${MEAS_PERIOD_NR_MAC_PDU_TPUT}
#     ${NR_5242b_fenmu}    evaluate    ${PRB_USED_PDSCH}/${PRB_AVAIL_PDSCH}
#     ${NR_5242b}    evaluate    ${NR_5242b_fenzi2}/${NR_5242b_fenmu}
# #    log to console    KPI NR_5242b MAC PDU Cell throughput on PDSCH considering PRB utilization is = ${NR_5242b}
# 
# 
#     ${DL_MAC_SDU_VOL_DTCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55309C01001    cell_id=1
#     ${DATA_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00005    cell_id=1
#     ${DATA_SLOT_PDSCH_TIME}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00008    cell_id=1
#     ${ACC_UE_DL_DRB_DATA}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C02000    cell_id=1
#     ${NR_5100b}    evaluate    8*${DL_MAC_SDU_VOL_DTCH}/(${ACC_UE_DL_DRB_DATA}*${DATA_SLOT_PDSCH_TIME}/${DATA_SLOT_PDSCH})
# 
#     ${ACC_SCHED_UE_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C17001    cell_id=1
#     ${TOTAL_COSCHED_UE_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C02004    cell_id=1
#     ${DL_DATA_SLOTS}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00001    cell_id=1
#     ${DATA_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00005    cell_id=1
#     ${SSB_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00015    cell_id=1
#     ${TRS_SLOT_PDSCH}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55308C00017    cell_id=1
#     ${NR_5192c}    evaluate    ${ACC_SCHED_UE_PDSCH}/(${DATA_SLOT_PDSCH}+${SSB_SLOT_PDSCH}+${TRS_SLOT_PDSCH})
#     ${NR_5112c}    evaluate    ${TOTAL_COSCHED_UE_PDSCH}/(${DL_DATA_SLOTS}+${SSB_SLOT_PDSCH}+${TRS_SLOT_PDSCH})
# 
#     log to console    KPI NR_5055b residual bler is = ${NR_5055b}
#     log to console    KPI NR_5054a iniBler is = ${NR_5054a}
#     log to console    KPI NR_5108d SE_downlink is = ${NR_5108d}
#     log to console    KPI NR_5109d SE_uplink is = ${NR_5109d}
#     log to console    KPI NR_5242b MAC PDU Cell throughput on PDSCH considering PRB utilization is = ${NR_5242b}
#     log to console    KPI NR_5258a MAC SDU Cell Throughput in DL on DTCH is = ${NR_5258a}
#     log to console    KPI NR_5100b Avg MAC user thp DL = ${NR_5100b}
#     log to console    KPI NR_5192c Average number of scheduled UEs on PDSCH = ${NR_5192c}
#     run keyword and continue on failure   should be true   ${NR_5054a}<0.1
#     run keyword and continue on failure   should be true   ${NR_5055b}<0.005
#     ${9235_kpi_list}   create list    ${NR_5055b}    ${NR_5054a}    ${NR_5108d}    ${NR_5109d}    ${NR_5242b}
#     ...    ${NR_5258a}    ${NR_5100b}    ${NR_5192c}
#     [return]     ${9235_kpi_list}
# 	
# Record result for 9235 perfomance
#     [Arguments]     ${table_tag}   ${8701_pair_counter_for_table}    ${9235_kpi_list}
#     modify excel cell       ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     0    ${table_tag}    CNI105506
#     : FOR    ${num}    IN RANGE    0    26
#     \    ${num_table}    evaluate    ${num}+1
#     \    modify excel cell       ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     ${num_table}    ${table_tag}
#     ...    ${8701_pair_counter_for_table[${num}]}
#     : FOR    ${num}    IN RANGE    0    8
#     \    ${num_table}    evaluate    ${num}+27
#     \    modify excel cell       ${TEST_LOG_DIRECTORY()}/All/9235.xls     Sheet1     ${num_table}     ${table_tag}
#     ...    ${9235_kpi_list[${num}]}
