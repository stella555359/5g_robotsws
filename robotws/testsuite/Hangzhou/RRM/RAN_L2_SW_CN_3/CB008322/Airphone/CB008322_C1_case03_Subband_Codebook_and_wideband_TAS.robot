# *** Settings ***
# Documentation     Author: shuiheng.he@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008322_C1_case03_Coexist_with_UL_SRS_BF_Subband_Codebook_and_wideband_TAS
# ...
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
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
# ${CONFIG_DIR_PATH_scf}    ${CURDIR}/config/
# ${SCFC_NAME}    SCFC_8322_C1_case03.xml
# ${AIRPHONE_NAME}    AP_iphy_AQQL_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.xml
# ${WTS_NAME}       wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.cfg
# @{LOG_NAME_LIST}      gnb_snapshot    ap_snapshot    egatelog
# ${cellDepType}                             text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                    text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                              text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                              text|4DL4UL|//*[@name\="nrCellType"]
# ${actUeCsirsCoexistCellCsirs}              text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
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
# ${bfSubbandSize}                           text|128 PRBs|//*[@name\="bfSubbandSize"]
# ${maxNumUeSrs}                             text|4|//*[@name\="maxNumUeSrs"]
# ${srsQualityThreshold}                     text|-1200|//*[@name\="srsQualityThreshold"]
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
# ${srbInactivityTimerSA}                     text|600|//*[@name\="srbInactivityTimerSA"]
# ${bwp_profile5}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-5|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile52}     text|MRBTS-1/NRBTS-1/BWP_PROFILE-52|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# ${prbRatioThreshold}                         text|3|//*[@name\="prbRatioThreshold"]
# ${srsUePeriodicityInput}                    text|slots40|//*[@name\="srsUePeriodicityInput"]
# ${srsUePeriodicityOutput}                   text|slots40|//*[@name\="srsUePeriodicityOutput"]
# ${numWbSrsConfigSample}                     text|5|//*[@name\="numWbSrsConfigSample"]
# ${prbSampleHighLowPercentage}               text|80|//*[@name\="prbSampleHighLowPercentage"]
# ${wbSrsPowerThreshold}                       text|-1200|//*[@name\="wbSrsPowerThreshold"]
# ${prbRatioHysteresis}                       text|1|//*[@name\="prbRatioHysteresis"]
# ${srsSinrThreshold}                text|-400|//*[@name\="srsSinrThreshold"]
# 
# *** Test Cases ***
# CB008322_C1_case03_Coexist_with_UL_SRS_BF_Subband_Codebook_and_wideband_TAS
#     Step1:Commission the above configuration on WebUI
#     Step2:SA UE with t2r4 capability attach to cell1
#     Step3:Do Traffic to make the UEs be configured as wide band SRS
#     Step4:Triger sub-band TAS SRS by buffer
# 	Step5:Return to RT beam
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
# 	${CONFIG_DIR_PATH_scf}    Set Variable    ${CURDIR}/config/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
# 	Wts Execute Aashell Command   
# 	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
#     modify_swconfig_by_CB008322    ${CURDIR}/config/${SW_BRANCH}${/}SCF${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH_scf}${/}SCF${/}${SCFC_NAME}    ${scfc_path}
#     del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     del_elements_from_xml    xml_path=${scfc_path}    parameter=tdLteUlDlConfig
#     add_element_from_xml    ${scfc_path}    MRBTS-1/NRBTS-1/NRCELL-1    srsPowerThresholdForUlBm    1320
#     ${modify_list}    create list
# 	...      ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUeCsirsCoexistCellCsirs}
# 	...      ${actCsirsMultiplexing}    ${actDlSrsBm}    ${actUlSrsBm}    ${actUlClosedLoopPwrCtrl}
# 	...      ${actCDrx}    ${actFdmScheduling}    ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}
# 	...      ${prachConfigurationIndex}    ${srsUePeriodicity}    ${cSRS}    ${bSRS}     ${srsPowerThresholdForDlBm}
# 	...      ${srsTypeAllocForDlBm}
# 	...      ${actDlSrsSubbandBm}    ${bfSubbandSize}    ${maxNumUeSrs}    ${srsQualityThreshold}
# 	...      ${dllaDeltaCqiMax}    ${dllaDeltaCqiMin}    ${dllaDeltaCqiStepdown}    ${actIncreasedFdmUsersPerSlot}    ${actDlMuMimoEnh}
# 	...      ${srbInactivityTimerSA}    ${bwp_profile5}    ${bwp_profile52}
# 	...      ${prbRatioThreshold}    ${srsUePeriodicityInput}    ${srsUePeriodicityOutput}    ${numWbSrsConfigSample}
# 	...      ${prbSampleHighLowPercentage}    ${wbSrsPowerThreshold}    ${prbRatioHysteresis}    ${srsSinrThreshold}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
# 	Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
#     Add L2PS Deubg Logs
# 	Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step1_before_onair
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
# 	add_txt_node    0x590103:2       #whether codebook SRS is reused for TAS SRS
# 	#add_txt_node    0x5900FD:0x1       #The maximum number of SRS resource that can use same SRS symbol for frame structure defined in 5GC001208
# 	#add_txt_node    0x590128:0x1       #The maximum number of SRS resource that can use same SRS symbol for frame structure defined in 5GC001116
# 	#add_txt_node    0x590127:0x1       #The maximum number of SRS resource that can use same SRS symbol for frame structure defined in 5GC001208
# 	#add_txt_node    0x58076c:0x2       #the percentage of scheduled PRB(when -G is ready, change into 0x58076c:0x1)
#     #add_txt_node    0x590072=1    #CP-RT log level(1 = debug 2 = info 3 = warning 4 = error 5 = vip 6 = disable)
# 	#add_txt_node    0x5901E8:1     #CPRT rdActCB009496
#     #add_txt_node    0x600013:1     # BOAM_RAT_ADAPT
#     #add_txt_node    0x19040F:1     # BOAM_FRONTHAUL
#     #add_txt_node    0x42008E:1     # BOAM DCS
#     #add_txt_node    0x88004B:0             # L1FH rdEnableSktMvp, 0 for 9496; 1 for SKTMVP
#     #add_txt_node    0x880x31:14 	  #L1FH rdBwvTxOpportunities, 14 for 9496;  3 for SKTMVP
#     #add_txt_node    0x580556:65535   #L2PS rdStartPatternId, 65535 for 9496
# 	#add_txt_node    0x580789:0x1       #rdEnableNiddFor8322
# 	#add_txt_node    0x580776:0x1       #This flag is used to control DL MU-MIMO interworking with subband BWVs
# 	#add_txt_node    0x600018:0        #rdUlUpFragmentationEnable
# 	#add_txt_node    0x580717:0       #rdPdcchApplyToSeparateStreams
# 	teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# #    add_txt_node    0x70690:1         #enable 1086 and 8247
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Step2:SA UE with t2r4 capability attach to cell1
#     Start Capture GNB and AP Syslog in 'Step2_attach' File
# 	Log To Console    \n\r==================the beginning of attaching ue==================\n\r
# 	Wait Throughput Timer    120
#     run keyword and continue on failure    Attach SA ue with capability to 5g cell    3    CA_P2_8x4_t2r4_n2
# 	Log To Console    \n\r==================the end of attaching ue==================\n\r
# 	#: FOR    ${i}    IN RANGE    11     20
# 	#\    Airphone NSA Attach    ${i}
# 	Attach SA ue with capability    4    CA_P2_8x4_noTas_n2
# 	airphone_set_traffic_type    4    1    internal
# 	Airphone Pdu Session Setup    4    1    1    2
# 	#ul_mimo_srs_beam_pos_active_test_type_srs    ue=1    profile=1    init=0    sub=0
#     #ul_mimo_srs_beam_pos_active_test_type_srs    ue=2    profile=2    init=1    sub=0
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}Step2_attach   unzip=TRUE
# 	${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
# 	Set test Variable	 ${rnti_1} 	${rnti_list[0]}
# 	Set test Variable	 ${rnti_2} 	${rnti_list[1]}
# 	Set test Variable	 ${rnti_3} 	${rnti_list[2]}
# 	Set test Variable	 ${rnti_4} 	${rnti_list[3]}
# 	run keyword and continue on failure	check_log_with_au2anlysis  ini_path=${CURDIR}/log_check/C1_case01_RRC_step2.ini
#      ...	 log_need_to_check=p	save_log_directory=${TEST_LOG_DIRECTORY()}Step2_attach
#     [Teardown]    Stop Capture GNB and AP Syslog in 'Step2_attach' File
# 	
# ul_mimo_srs_beam_pos_active_test_type_srs
#     [Arguments]    ${ue}    ${profile}    ${init}    ${sub}    ${scell}=0    ${step}=10    ${puxch}=0    ${u}=trigger_puxch_update
#     ...    ${iq}=init_quad_pos    ${sq}=init_sub_quad_pos    ${m}=multi_path_config    ${mu_path}=0    ${p}=profile_id    ${y}=test_type
#     ...    ${t}=SRS
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr ${p}\=${profile} mode\=fixed ${iq}\=${init} ${sq}\=${sub} step\=${step} 
#    ...    ${u}\=${puxch} ${m}\=${mu_path} ${y}\=${t}
# 	airphone_execute_egate_command
# 	...    ue_testmode_set_nr id\=${ue} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${profile} scell\=${scell}
# 
# 
# Step3:Do Traffic to make the UEs be configured as wide band SRS
#     Start Capture GNB and AP Syslog in 'Step3_Do_DL_Traffic' File
# 	Log To Console    \n\r==================the beginning of traffic==================\n\r
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_Do_DL_Traffic
# 	Wait Throughput Timer    120
# 	#Start GNB BIP Log
#     : FOR    ${i}    IN RANGE    1    5     
#     \    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=1    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    UL    50M    trf_id=1    pdu_id=1    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    DL    150M    trf_id=2    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    UL    50M    trf_id=2    pdu_id=1    duration=${3600}
#     Log To Console    \n\r==================the ending of traffic commands==================\n\r
# 	#Stop Gnb BIP Log    log_dir=${save_log}
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/C1_case03_tti_dl_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/C1_case01_tti_ul_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	#${tput}    get DL UL tput from PM counter    ${save_log}
#     #run keyword and continue on failure    should be true    ${tput}[0]>850
# 	#run keyword and continue on failure    should be true    ${tput}[1]>130
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
# Step4:Triger sub-band TAS SRS by buffer
# 	Start Capture GNB and AP Syslog in 'Step4_triger_subband_tas_srs' File
#     : FOR    ${i}    IN RANGE    1    4 
# 	\    airphone_execute_egate_command    trf_data_stop ue\=${i} pdu\=1 qfi\=1 dir\=dl
# 	Wait Throughput Timer    1
# 	: FOR    ${i}    IN RANGE    1    4 
# 	\    Airphone SA Start Data Traffic    ${i}    DL    1M    trf_id=1    pdu_id=1    duration=${3600}
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_triger_subband_tas_srs
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	#Start GNB BIP Log
#     #Wait Throughput Timer    1
#     #Stop Gnb BIP Log    log_dir=${save_log}
# 	run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/C1_case03_tti_dl_step4.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/C1_case01_tti_ul_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4_triger_subband_tas_srs' File
# 
# Step5:Return to RT beam
#     Start Capture GNB and AP Syslog in 'Step5_Return_to_RT_beam' File
#     airphone_execute_egate_command    trf_data_stop ue\=1 pdu\=1 qfi\=1 dir\=dl
#     : FOR    ${i}    IN RANGE    2     11
#     \    Airphone SA Start Data Traffic    1    DL    150M    trf_id=${i}    pdu_id=1    duration=${3600}
# 	\    Airphone SA Start Data Traffic    2    DL    150M    trf_id=${i}    pdu_id=1    duration=${3600}
# 	\    Airphone SA Start Data Traffic    3    DL    150M    trf_id=${i}    pdu_id=1    duration=${3600}
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_Return_to_RT_beam
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	#Start GNB BIP Log
#     #Wait Throughput Timer    
#     #Stop Gnb BIP Log    log_dir=${save_log}
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/C1_case03_tti_dl_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/C1_case01_tti_ul_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	#${tput}    get DL UL tput from PM counter    ${save_log}
#     #run keyword and continue on failure    should be true    ${tput}[0]>850
# 	#run keyword and continue on failure    should be true    ${tput}[1]>130
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step5_Return_to_RT_beam' File
# 
# Add L2PS Deubg Logs	
#     ${debuglogs}    create list    level=DBG\n    L2.L2_PS.DEBUG=1\n    L2.L2_PS.DL.SUBBAND_BEAMFORMING=1\n    L2.L2_PS.SRS_BASED_BM=1\n    	
# 	Active L2ps Feature Debug Traces    ${debuglogs}
# 	TAF_SSH.connect to    192.168.255.1   toor4nsn    oZPS0POrRieRtu   alias=bsh
# 	TAF_SSH.execute    rm /ffs/run/HashContainer*    connection=bsh
