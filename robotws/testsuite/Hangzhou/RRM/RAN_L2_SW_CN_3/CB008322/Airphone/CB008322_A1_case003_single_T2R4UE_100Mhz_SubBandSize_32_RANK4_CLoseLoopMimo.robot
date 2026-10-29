# *** Settings ***
# Documentation     Author: lili.1.yu@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008322_A1_case003_single_T2R4UE_100Mhz_SubBandSize_32_RANK4_CLoseLoopMimo
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_lilyu
# Test Timeout      60 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}    gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AQQL_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.xml
# ${WTS_NAME}       wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.cfg
# &{GNBMIRRORINGCONFIGS}    BB_SLOT_2='false'   BB_SLOT_1='false'    BB_SLOT_5='true'    SYSCOM_MIRRORING='true'
# ...    L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='false'  NUMBER_OF_FILES=30
# ${COMAVALUE}    ${CURDIR}/../../resources/sg11/internal_resource/config/AP/coma_AQQL_8701.txt
# 
# @{LOG_NAME_LIST}    gnb_snapshot    egatelog
# ${UE_NUM}         6
# ${PDU_ID}         1
# ${SLICE_ID}       1
# ${par_of_bsr_name}       BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
# ${FILTER0}    (itf_l2_ps_cell_cellsetupreq)||(itf_l2_ps_cell_cellsetupresp)||(itf_l2_ps_cell_dlsubbandbfconfig)
# @{title0}    itf_l2_ps_cell_BfSetup.actDlSrsBm    itf_l2_ps_cell_BfSetup.actDlSrsSubbandBm    itf_l2_ps_cell_DlSubbandBmConfig.bfSubbandSize
# ...    itf_l2_ps_cell_DlSubbandBmConfig.maxNumUeSrs    itf_l2_ps_cell_DlSubbandBmConfig.srsQualityThreshold   
# 
# ${FILTER1}    ((uldata_srsreceivereq)||(dldata_pdschsendreq)||(uldata_puschreceivereq)||(uldata_srsreceiverespps)||(uldata_srsreceiverespbwvps))
# ...    && (3gpp.rnti !=65535)
# @{title1}    UlData_srsReceiveReqSubcell_t.srsBwvEnable    UlData_srsBwvReportRequest_t.startPatternId    UlData_srsBwvReport_t.result
# ...    DlData_PdschGrant.patternId_item    3gpp.rnti  
# 
# #8322
# ${actDlSrsSubbandBm}                           text|true|//*[@name\="actDlSrsSubbandBm"]
# ${bfSubbandSize}                           text|32 PRBs|//*[@name\="bfSubbandSize"]
# ${srsQualityThreshold}                           text|-1200|//*[@name\="srsQualityThreshold"]
# ${maxNumUeSrs}                           text|1|//*[@name\="maxNumUeSrs"]
# 
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                         text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                                   text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                                   text|4DL4UL|//*[@name\="nrCellType"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${actDl256Qam}                              text|false|//*[@name\="actDl256Qam"]
# #1116
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}                            text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${lteToNrFrameShift}                            text|3ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                             text|slots80|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                         text|63|//*[@name\="cSRS"]
# ${bSRS}                                         text|0|//*[@name\="bSRS"]
# ${actBeamforming}                               text|true|//*[@name\="actBeamforming"]
# ${basicBeamSet}                                 text|beamSet_6|//*[@name\="basicBeamSet"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${msg1FrequencyStart}                           text|0|//*[@name\="msg1FrequencyStart"]
# ${actUlSrsBm}                           text|false|//*[@name\="actUlSrsBm"]
# 
# ${pattern}    CA_P2_8x4_t2r4_n2
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=3 step\=5 trigger_puxch_update\=0 test_type=SRS
# ${SET_PROFILE1}    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
# 
# *** Test Cases ***
# CB008322_A1_case003_single_T2R4UE_100Mhz_SubBandSize=32_RANK4_CLoseLoopMimo
#     Step1:Commission the above configuration on WebUI
#     Step2:t2r4 UE with dlShortTermBF Capability attach to cell
#     Step3:ue detach attach detach
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
#     ...       ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}      ${actFdmScheduling}    ${msg1FrequencyStart}
#     ...       ${frameStructureType}     ${guardPeriodLength}    ${ulDlDataSlotRatio}   ${prachConfigurationIndex}
#     ...       ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${actBeamforming}    ${basicBeamSet}    ${actUlSrsBm}
#     ...       ${bfSubbandSize}    ${srsQualityThreshold}    ${actDl256Qam}   ${actDlSrsSubbandBm}    ${nrBtsBeamRefinementP2}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    ${par_of_bsr_name}
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:t2r4 UE with dlShortTermBF Capability attach to cell
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
# 	#check cellsetup
#     Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/cellSetup0.pcap    ${save_log}/bip_case003_cellsetup.csv    ${FILTER0}    ${title0}
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case003_bip_cellsetup.ini    log_need_to_check=i
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
# 	Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
# 	Airphone SA Start Data Traffic    ue_id=1    direction=ul    throughput=17M    trf_id=1    pdu_id=1    duration=3600s
#     Airphone SA Start Data Traffic    ue_id=1    direction=dl    throughput=170M    trf_id=1    pdu_id=1    duration=3600s
# 	Airphone SA Start Data Traffic    ue_id=1    direction=dl    throughput=170M    trf_id=2    pdu_id=1    duration=3600s
# 	Airphone SA Start Data Traffic    ue_id=1    direction=dl    throughput=170M    trf_id=3    pdu_id=1    duration=3600s
# 	Airphone SA Start Data Traffic    ue_id=1    direction=dl    throughput=170M    trf_id=4    pdu_id=1    duration=3600s
# 	Airphone SA Start Data Traffic    ue_id=1    direction=dl    throughput=170M    trf_id=5    pdu_id=1    duration=3600s
# 	Airphone SA Start Data Traffic    ue_id=1    direction=dl    throughput=170M    trf_id=6    pdu_id=1    duration=3600s
# 	Airphone SA Start Data Traffic    ue_id=1    direction=dl    throughput=170M    trf_id=7    pdu_id=1    duration=3600s
# 	Wait Throughput Timer    30
#     Start GNB BIP Log
#     Wait Throughput Timer    1
# 	Stop Gnb BIP Log    log_dir=${save_log}
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 	airphone_collect_egate_log_files      ${save_log}   unzip=TRUE
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti	
# 	#check rrc	
#    # run keyword and continue on failure    
# 	#...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case003_attach_rrc.ini    log_need_to_check=p    save_log_directory=${save_log}
# 	#check tti
# 	run keyword and continue on failure    
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case003_buffer_tti.ini     log_need_to_check=i    save_log_directory=${save_log}
# 	#check bip
# 	${log_dir}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap00    ${log_dir}/bip_case003_attach.csv    ${FILTER1}    ${title1}
# 	run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case003_bip_attach.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# 
# Step3:ue detach attach detach
#     Start capture only gnb syslog in 'Step3' file
# 	airphone_sa_detach    ue_id=1
# 	Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
# 	airphone_sa_detach    ue_id=1
#     [Teardown]    Stop capture only gnb syslog in 'Step3' file
# 
# 
# Set UEs Pos
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command    ${SET_PROFILE1}
#     airphone_execute_egate_command    ${PROFILE2}
#     airphone_execute_egate_command    ${SET_PROFILE2}
#     airphone_execute_egate_command    ${PROFILE3}
#     airphone_execute_egate_command    ${SET_PROFILE3}
#     airphone_execute_egate_command    ${PROFILE4}
#     airphone_execute_egate_command    ${SET_PROFILE4}
#     airphone_execute_egate_command    ${PROFILE5}
#     airphone_execute_egate_command    ${SET_PROFILE5}
#     airphone_execute_egate_command    ${PROFILE6}
#     airphone_execute_egate_command    ${SET_PROFILE6}
#     airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=9 sinr_target_srs\=-50 noise_srs\=-1053
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1-6 testmode\=ul_sinr action\=activate profile_id\=5
# 
# 
# modify_swconfig_by_CB008322
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}
# 	${local_save_path}=     Download All Common Config Files From Golden Server
# 	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
# 	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
# 	add_txt_node    0x340000:1         #as PM counter period update to 15/15=1min
#     #add_txt_node    0x580556:0x834        #rdStartPatternId
# 	add_txt_node    0x5901EB:1
#     teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# #    add_txt_node    0x70690:1         #enable 1086 and 8247
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
