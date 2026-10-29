# *** Settings ***
# Documentation     Author: shuiheng.he@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008322_C1_case01_Coexist_with_UL_SRS_BF_Codebook_and_TAS_with_different_SRS_resource
# ...
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# #Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_shuihe
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library     taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# #${SCFC_NAME}    gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.xml
# #${AIRPHONE_NAME}    AP_iphy_AQQL_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.xml
# #${WTS_NAME}       wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.cfg
# ${SCFC_NAME}    SCF/SCFC_8322_D4_case033_70M_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_4S_1CC_MP.xml
# ${AIRPHONE_NAME}    WTS/AP_iphy_AQQL_D3_case032_MP.xml
# ${WTS_NAME}       WTS/wts_config_AQQL_D3_case032.cfg
# @{LOG_NAME_LIST}      gnb_snapshot    ap_snapshot    egatelog
# ${cellDepType}                             text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                    text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                              text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                              text|8DL4UL|//*[@name\="nrCellType"]
# ${actUeCsirsCoexistCellCsirs}              text|true|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${actCsirsMultiplexing}                    text|true|//*[@name\="actCsirsMultiplexing"]
# ${actDlSrsBm}                              text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                              text|true|//*[@name\="actUlSrsBm"]
# ${actDlSrsSubbandBm}                       text|true|//*[@name\="actDlSrsSubbandBm"]
# ${actUlClosedLoopPwrCtrl}                  text|disabled|//*[@name\="actUlClosedLoopPwrCtrl"]
# ${actCDrx}                                 text|false|//*[@name\="actCDrx"]
# ${actFdmScheduling}                        text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}                      text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                       text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}                       text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                 text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                        text|slots20|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                    text|63|//*[@name\="cSRS"]
# ${bSRS}                                    text|1|//*[@name\="bSRS"]
# ${srsPowerThresholdForDlBm}                text|-1200|//*[@name\="srsPowerThresholdForDlBm"]
# ${srsTypeAllocForDlBm}                     text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
# ${bfSubbandSize}                           text|16 PRBs|//*[@name\="bfSubbandSize"]
# ${maxNumUeSrs}                             text|4|//*[@name\="maxNumUeSrs"]
# ${srsQualityThreshold}                     text|-1200|//*[@name\="srsQualityThreshold"]
# @{Rdparameter}       0x340000:5
# 
# ${FILTER1}    (itf_l2_ps_cell_cellsetupreq)||(ulcell_setupreq)
# @{title1}    UlCell_SetupReq_t.pSRSBwvAct    itf_l2_ps_cell_BfSetup.actDlSrsBm    itf_l2_ps_cell_BfSetup.actDlSrsSubbandBm
# ...    itf_l2_ps_cell_DlSubbandBmConfig.bfSubbandSize
# ...    itf_l2_ps_cell_DlSubbandBmConfig.maxNumUeSrs
# ${srsPowerThresholdForUlBm}                 text|-1320|//*[@name\="srsPowerThresholdForUlBm"]
# ${dllaDeltaCqiMax}                          text|0|//*[@name\="dllaDeltaCqiMax"]
# ${dllaDeltaCqiMin}                          text|0|//*[@name\="dllaDeltaCqiMin"]
# ${dllaDeltaCqiStepdown}                     text|0|//*[@name\="dllaDeltaCqiStepdown"]
# ${actIncreasedFdmUsersPerSlot}              text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
# ${actDlMuMimoEnh}                           text|false|//*[@name\="actDlMuMimoEnh"]
# ${bwp_profile5}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-5|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile52}     text|MRBTS-1/NRBTS-1/BWP_PROFILE-52|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# ${customBeamSetName}              text|BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001|//*[@name\="customBeamSetName"]
# 
# *** Test Cases ***
# CB008322_C1_case01_Coexist_with_UL_SRS_BF_Codebook_and_TAS_with_different_SRS_resource
#     Step1:Commission the above configuration on WebUI
#     Step2:SA UE with t2r4 capability attach to cell1
#     Step3:Do Traffic to make the UEs be configured as wide band SRS
#     Step4:Triger sub-band TAS SRS by low cqi
# 	Step5:Return to RT beam
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CURDIR}/config/${SW_BRANCH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008322    ${CURDIR}/config/${SW_BRANCH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CURDIR}/config/${SW_BRANCH}${/}${SCFC_NAME}    ${scfc_path}
#     del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     #del_elements_from_xml    xml_path=${scfc_path}    parameter=tdLteUlDlConfig
#     #add_bwplist_list_in_cells_new    ${scfc_path}    key_4
#     add_element_from_xml    ${scfc_path}    MRBTS-1/NRBTS-1/NRCELL-1    srsPowerThresholdForUlBm    1320
#     ${modify_list}    create list
# 	...      ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUeCsirsCoexistCellCsirs}
# 	...      ${actCsirsMultiplexing}    ${actDlSrsBm}    ${actUlSrsBm}    ${actUlClosedLoopPwrCtrl}
# 	...      ${actCDrx}    ${actFdmScheduling}    ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}
# 	...      ${prachConfigurationIndex}    ${srsUePeriodicity}    ${cSRS}    ${bSRS}     ${srsPowerThresholdForDlBm}
# 	...      ${srsTypeAllocForDlBm}
# 	...      ${actDlSrsSubbandBm}    ${bfSubbandSize}    ${maxNumUeSrs}    ${srsQualityThreshold}
# 	...      ${dllaDeltaCqiMax}    ${dllaDeltaCqiMin}    ${dllaDeltaCqiStepdown}    ${actIncreasedFdmUsersPerSlot}    ${actDlMuMimoEnh}
# 	...      ${bwp_profile5}    ${bwp_profile52}    ${customBeamSetName}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
# 	Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CURDIR}/config/${SW_BRANCH}${/}${WTS_NAME}
#     ...    reset_after_commission=${False}										  
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step1_before_onair
# 	Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/cellSetup0.pcap    ${save_log}/cellsetup.csv    ${FILTER1}    ${title1}
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/C1_case01_bip_step1.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# modify_swconfig_by_CB008322
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}
# 	${local_save_path}=     Download All Common Config Files From Golden Server
# 	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
# 	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
# 	add_txt_node    0x340000:5         #as PM counter period update to 15/15=1min
#     #add_txt_node    0x580556:0x834        #rdStartPatternId
# 	#add_txt_node    0x5805ae:1       #Flag to enable or disable dynamic Wb/Sb Srs Switch
# 	#the UE periodicity for wideband periodic antenna switching SRS used by the UE to send SRS to gNB for RT beam management
# 	#add_txt_node    0x5901E6:80
# 	add_txt_node    0x5901E8:1     #CPRT rdActCB009496
#     add_txt_node    0x600013:1     # BOAM_RAT_ADAPT
#     add_txt_node    0x19040F:1     # BOAM_FRONTHAUL
#     add_txt_node    0x42008E:1     # BOAM DCS
#     add_txt_node    0x88004B:0             # L1FH rdEnableSktMvp, 0 for 9496; 1 for SKTMVP
#     add_txt_node    0x880x31:14 	  #L1FH rdBwvTxOpportunities, 14 for 9496;  3 for SKTMVP
#     add_txt_node    0x580556:65535   #L2PS rdStartPatternId, 65535 for 9496
# 	
#     teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Step2:SA UE with t2r4 capability attach to cell1
#     Start Capture GNB and AP Syslog in 'Step2_attach' File
#     run keyword and continue on failure    Attach SA ue with capability to 5g cell    2    CA_P2_8x4_t2r4_n2
# 	#ul_mimo_srs_beam_pos_active    ue=1    profile=1    init=0    sub=0
#     #ul_mimo_srs_beam_pos_active    ue=2    profile=2    init=1    sub=0
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}Step2_attach   unzip=TRUE
# 	run keyword and continue on failure	check_log_with_au2anlysis  ini_path=${CURDIR}/log_check/C1_case01_RRC_step2.ini
#      ...	 log_need_to_check=p	save_log_directory=${TEST_LOG_DIRECTORY()}Step2_attach
#     [Teardown]    Stop Capture GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Do Traffic to make the UEs be configured as wide band SRS
#     Start Capture GNB and AP Syslog in 'Step3_Do_DL_Traffic' File
# 	Log To Console    \n\r==================the beginning of traffic==================\n\r
#     : FOR    ${i}    IN RANGE    1     11
#     \    Airphone SA Start Data Traffic    1    DL    150M    trf_id=${i}    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    1    UL    50M    trf_id=${i}    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    2    DL    150M    trf_id=${i}    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    2    UL    50M    trf_id=${i}    pdu_id=1    duration=${3600}
#     Wait Throughput Timer    8
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_Do_DL_Traffic
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/C1_case01_tti_dl_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/C1_case01_tti_ul_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	${tput}    get DL UL tput from PM counter    ${save_log}
#     run keyword and continue on failure    should be true    ${tput}[0]>900
# 	run keyword and continue on failure    should be true    ${tput}[1]>130
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3_Do_DL_Traffic' File
# 	
# get DL UL tput from PM counter
#     [Arguments]    ${log_dir}    ${cell}=1
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     ${remaining_time}     evaluate    ${remaining_time}+60
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${log_dir}${/}
#     ${PM_counter_DL_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55309C12001
#     ...   cell_id=${cell}
#     ${DL_throughput}    evaluate    ${PM_counter_DL_value}*8/1024/1024
# 	${PM_counter_UL_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55309C12002
#     ...   cell_id=${cell}
#     ${UL_throughput}    evaluate    ${PM_counter_UL_value}*8/1024/1024
#     [Return]    ${DL_throughput}    ${UL_throughput}
# 
# Step4:Triger sub-band TAS SRS by low cqi
# 	Start Capture GNB and AP Syslog in 'Step4_triger_subband_tas_srs' File
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_triger_subband_tas_srs
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/C1_case01_tti_step4_MP.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/C1_case01_tti_ul_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4_triger_subband_tas_srs' File
# 
# Step5:Return to RT beam
#     Start Capture GNB and AP Syslog in 'Step5_Return_to_RT_beam' File
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 cqi\=15
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_Return_to_RT_beam
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/C1_case01_tti_dl_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/C1_case01_tti_ul_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	${tput}    get DL UL tput from PM counter    ${save_log}
#     run keyword and continue on failure    should be true    ${tput}[0]>900
# 	run keyword and continue on failure    should be true    ${tput}[1]>130
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step5_Return_to_RT_beam' File