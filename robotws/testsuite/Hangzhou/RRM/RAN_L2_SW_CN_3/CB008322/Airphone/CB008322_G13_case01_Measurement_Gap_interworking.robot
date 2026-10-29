# *** Settings ***
# Documentation     Author: shuihe
# ...
# ...               example case for RAN HZ L2 SW11. test step description in QC as below:
# ...
# ...               QC case full name:
# ...               CB008322_G13_case01_Measurement_Gap_interworking
# ...
# 
# Test Timeout      60 minutes
# Suite Setup       Run Keywords    Common Suite Setup    AND    RUN    pip install pandas
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    CIT    SBTS00    SBTS23R1    Owner_shuihe
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library           taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# Library      	  ./py_check/g13_mg_check.py															 
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      SCF/SCFC_8322_G13_case01.xml
# ${AIRPHONE_NAME}    WTS/AP_iphy_AQQL_C1_case07.xml
# ${WTS_NAME}       WTS/wts_config_ASIB_ABIO_G13.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# 
# ${dlMimoMode}                              text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                              text|4DL4UL|//*[@name\="nrCellType"]
# ${actCsirsMultiplexing}                    text|true|//*[@name\="actCsirsMultiplexing"]
# ${actDlSrsBm}                              text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                              text|true|//*[@name\="actUlSrsBm"]
# #${actDlSrsSubbandBm}                       text|true|//*[@name\="actDlSrsSubbandBm"]
# ${actUlClosedLoopPwrCtrl}                  text|disabled|//*[@name\="actUlClosedLoopPwrCtrl"]
# ${actCDrx}                                 text|false|//*[@name\="actCDrx"]
# ${srsUePeriodicity}                        text|slots160|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                    text|49|//*[@name\="cSRS"]
# ${bSRS}                                    text|2|//*[@name\="bSRS"]
# ${srsPowerThresholdForDlBm}                text|-1270|//*[@name\="srsPowerThresholdForDlBm"]
# ${srsTypeAllocForDlBm}                     text|codebook|//*[@name\="srsTypeAllocForDlBm"]
# ${bfSubbandSize}                           text|8 PRBs|//*[@name\="bfSubbandSize"]
# ${maxNumUeSrs}                             text|4|//*[@name\="maxNumUeSrs"]
# ${srsQualityThreshold}                     text|-1200|//*[@name\="srsQualityThreshold"]
# ${prbRatioHysteresis}                         text|5|//*[@name\="prbRatioHysteresis"]
# ${prbRatioThreshold}                         text|6|//*[@name\="prbRatioThreshold"]
# ${srsUePeriodicityInput}                    text|slots20|//*[@name\="srsUePeriodicityInput"]
# ${srsUePeriodicityOutput}                   text|slots20|//*[@name\="srsUePeriodicityOutput"]
# ${numWbSrsConfigSample}                     text|5|//*[@name\="numWbSrsConfigSample"]
# ${prbSampleHighLowPercentage}               text|60|//*[@name\="prbSampleHighLowPercentage"]
# ${wbSrsPowerThreshold}                      text|-1200|//*[@name\="wbSrsPowerThreshold"]
# ${srsPowerThreshold}                        text|-1340|//*[@name\="srsPowerThreshold"]
# ${actCustomBsr}                             text|true|//*[@name\="actCustomBsr"]
# ${customBeamSetName}                        text|BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001|//*[@name\="customBeamSetName"]
# #${ActFullRRCConfigurationSaHo}                             text|enabled|//*[@name\="ActFullRRCConfigurationSaHo"]
# ${srsSinrThreshold}                        text|-400|//*[@name\="srsSinrThreshold"]
# 
# ${cmd_1_00}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=0 test_type=SRS multi_path_config=true
# ${cmd_002_001}    num_of_nlos_paths=1 azimuth=14 zenith=-2 srs_transmit_power_per_port=-100,-100,-100,-100
# ${cmd_002_002}    num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-350,-500,-350,-500
# ${cmd_002_003}    num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-700,-700,-700,-700
# ${cmd_003}    subband_config_subband_prb_size=16
# ${cmd_004}    subband_config_stepsize_azimuth=2 subband_config_stepsize_zenith=2 subband_config_start_prb=1 subband_config_num_of_prb=216
# ${cmd_2_00}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=SRS multi_path_config=true
# ${cmd_1_20}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=2 init_sub_quad_pos=0 test_type=SRS multi_path_config=true
# ${cmd_2_20}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=2 init_sub_quad_pos=0 test_type=SRS multi_path_config=true
# ${FILTER1}    itf_l2_ps_user_usermodifyreq||itf_l2_ps_user_rrcreconfcompletedreq||itf_l2_ps_user_reconfigurationrequiredind||f1ap
# @{title1}    frame.time    3gpp.rnti
# ...    itf_l2_ps_UeCapability.dlShortTermBeamformingCapability_item    itf_l2_ps_user_RrcReconfCompletedReq_t.tasSrsResourceChangeInd_item
# ...    nr-rrc.rrcReconfigurationComplete_element    nr-rrc.criticalExtensions
# ${FILTER2}    uldata_srsreceivereq||uldata_srsreceiverespbwvps
# @{title2}    frame.time    3gpp.rnti    UlData_srsReceiveReqSubcell_t.srsBwvEnable
# ...    UlData_srsBwvReport_t.result
# 
# *** Test Cases ***
# CB008322_G13_case01_Measurement_Gap_interworking
#     Step 1: Set parameter and wait for onair
#     Step 2: Attach CA UE to cell2
#     Step 3: Initiate big DL data transfer for UE
# 	Step 4: Perform UE handover to gnb2 cell1
# 	Step 5: Detach all UEs
# 
# *** Keywords ***
# Step 1: Set parameter and wait for onair
#     Start Capture GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
# 	change_iphy_rru_version        ${CURDIR}/config/${SW_BRANCH}${/}${AIRPHONE_NAME}
# 	Wts Execute Aashell Command   
# 	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
# 	modify_swconfig_by_CB007922    ${CURDIR}/config/${SW_BRANCH}${/}${SCFC_NAME}
# 	modify_swconfig_by_CB008322    ${CURDIR}/config/${SW_BRANCH}${/}${SCFC_NAME}
# 	${scfc_path}                Set Variable                          ${TEST_LOG_DIRECTORY()}${/}scfc.xml
# 	copy_file          ${CURDIR}/config/${SW_BRANCH}${/}${SCFC_NAME}     ${scfc_path}
# 	${modify_list}      create list
#     ...       ${dlMimoMode}    ${nrCellType}    ${actCsirsMultiplexing}
#     ...       ${actDlSrsBm}    ${actUlSrsBm}    ${actUlClosedLoopPwrCtrl}
#     ...       ${actCDrx}    ${srsUePeriodicity}    ${cSRS}    ${bSRS}
#     ...       ${srsPowerThresholdForDlBm}    ${srsTypeAllocForDlBm}    ${bfSubbandSize}    ${maxNumUeSrs}
#     ...       ${srsQualityThreshold}    ${prbRatioHysteresis}
# 	...      ${prbRatioThreshold}    ${srsUePeriodicityInput}    ${srsUePeriodicityOutput}    ${numWbSrsConfigSample}
# 	...      ${prbSampleHighLowPercentage}    ${wbSrsPowerThreshold}    ${srsPowerThreshold}   ${actCustomBsr}    ${customBeamSetName}
# 	#...      ${ActFullRRCConfigurationSaHo}
# 	...      ${srsSinrThreshold} 
#     modify_xml  	    ${scfc_path}        ${scfc_path}         ${modify_list}
#     Modify TL VM And AP SCTP Configuration
# 	Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
# 	Add L2PS Deubg Logs
# 	Perform Full Commission And Reach Onair With Log
# 	...    ${scfc_path}
# 	...    ${CURDIR}/config/${SW_BRANCH}${/}${WTS_NAME}
# 	...    reset_after_commission=${False}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'step1_before_onair' File
# 
# modify_swconfig_by_CB008322
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}
# 	${local_save_path}=     Download All Common Config Files From Golden Server
# 	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
# 	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
# 	add_txt_node    0x340000:5         #as PM counter period update to 15/15=1min
# 	add_txt_node    0x590103:2       #whether codebook SRS is reused for TAS SRS
# 	add_txt_node    0x580789:0x1       #rdEnableNiddFor8322
# 	#add_txt_node    0x580717:0       #rdPdcchApplyToSeparateStreams
#     add_txt_node    0x600018:0        #rdUlUpFragmentationEnable
#     teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Step 2: Attach CA UE to cell2
#     Start Capture GNB and AP Syslog in 'step2_ue_attach' File
#     Start GNB Ttitrace With Streaming Mode
#     Airphone Location Change    id=${UE_ID}    cell_id=2
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     run keyword and continue on failure    Airphone SA Attach    ue_id=${UE_ID}
#     run keyword and continue on failure    Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
# 	Wait Throughput Timer    10
# 	Airphone Execute Egate Command    ${cmd_1_00} ${cmd_002_001}
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}step2_ue_attach   unzip=TRUE
# 	${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}/egate_console.log.001   crnti: (\\d+)
# 	Set test Variable	 ${rnti_1} 	${rnti_list[0]}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'step2_ue_attach' File
# 
# Step 3: Initiate big DL data transfer for UE
#     Start Capture GNB and AP Syslog in 'step3_send_data' File
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
# 	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
# 	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    pdu_id=${PDU_ID}    duration=${3600}
# 	Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=5    pdu_id=${PDU_ID}    duration=${3600}
# 	Airphone SA Start Data Traffic    ${UE_ID}    UL    175M     trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Start GNB Ttitrace With Streaming Mode
# 	Wait Throughput Timer    2
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_send_data
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}step3_send_data
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/G13_case01_tti_dl.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/G13_case01_tti_ul.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}step3_send_data   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'step3_send_data' File
# 
# Step 4: Perform UE handover to gnb2 cell1
# 	Start Capture GNB and AP Syslog in 'step4_HO_to_gnb2_1' File
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}step4_HO_to_gnb2_1
#     Inquery UE'1' NR Measurement Identities
# 	run keyword and continue on failure    Start collect 'cellSetup' tcpdump
# 	Start GNB BIP Log
# 	Log To Console    \n\r==================the beginning of HO==================\n\r
# 	Wait Throughput Timer    1
# 	${cmd}=    Set Variable    ue_measurement_send_nr id=1 meas_id=1 event=A2 srsrp_nr=45
#     airphone_execute_egate_command    ${cmd}
# 	Stop Gnb BIP Log    log_dir=${save_log}/enterMG
# 	run keyword and continue on failure    Stop collect 'cellSetup' tcpdump
# 	run keyword and continue on failure    Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/cellSetup.pcap
# 	...    ${save_log}/cplog_enterMG.csv    ${FILTER1}    ${title1}
# 	${result}    ${output}    Run and return RC and output    cd ${TEST_LOG_DIRECTORY()}/All/;rm -rf ./cellSetup.pcap
# 	run keyword and continue on failure    Start collect 'cellSetup' tcpdump
# 	Start GNB BIP Log
# 	Wait Throughput Timer    1
# 	${cmd}=    Set Variable    ue_measurement_send_nr id=1 meas_id=3 event=A1 srsrp_nr=80
# 	airphone_execute_egate_command    ${cmd}
# 	Stop Gnb BIP Log    log_dir=${save_log}/leaveMG
# 	${cmd}=    Set Variable    ue_measurement_send_nr id=1 meas_id=5 event=A2 srsrp_nr=45
# 	airphone_execute_egate_command    ${cmd}
# 	Inquery UE'1' NR Measurement Identities
# 	${cmd}=    Set Variable    ue_measurement_send_nr id=1 meas_id=6 event=A1 srsrp_nr=80
# 	#airphone_execute_egate_command    ${cmd}
# 	#${cmd}=    Set Variable    ue_measurement_send_nr id=1 meas_id=8 event=A2 srsrp_nr=45
# 	#airphone_execute_egate_command    ${cmd}
# 	#${cmd}=    Set Variable    ue_measurement_send_nr id=1 meas_id=9 event=A1 srsrp_nr=80
# 	airphone_execute_egate_command    ${cmd}
# 	run keyword and continue on failure    Stop collect 'cellSetup' tcpdump
# 	run keyword and continue on failure    Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/All/cellSetup.pcap
#     ...    ${save_log}/cplog_leaveMG.csv    ${FILTER1}    ${title1}
# 	: FOR    ${i}    IN RANGE    10
# 	\    run keyword and ignore error    Convert BIP To CSV    ${save_log}/enterMG/tcpdump_L2L1_bip_filtering_off.pcap${i}
#     ...    ${save_log}/enterMG/biplog${i}.csv    ${FILTER2}    ${title2}
# 	: FOR    ${i}    IN RANGE    10
# 	\    run keyword and ignore error    Convert BIP To CSV    ${save_log}/leaveMG/tcpdump_L2L1_bip_filtering_off.pcap${i}
#     ...    ${save_log}/leaveMG/biplog${i}.csv    ${FILTER2}    ${title2}
# 	combine csv    ${save_log}/enterMG/    ${save_log}/combined_entering_mg.csv
# 	${entering_mg_time}    get entering mg time    ${save_log}/cplog_enterMG.csv
# 	check bwv request not sent entering mg    ${save_log}/combined_entering_mg.csv    ${entering_mg_time}
# 	combine csv    ${save_log}/leaveMG/    ${save_log}/combined_leaving_mg.csv
# 	${leaving_mg_time}    ${rnti}    get leaving mg time and rnti    ${save_log}/cplog_leaveMG.csv
# 	check bwv request sent leaving mg    ${save_log}/combined_leaving_mg.csv    ${leaving_mg_time}    ${rnti}
# 	Log To Console    \n\r==================the END of HO==================\n\r
# 	Start GNB Ttitrace With Streaming Mode
# 	Wait Throughput Timer    2
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_HO_to_gnb2_1
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}step4_HO_to_gnb2_1
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/G13_case01_tti_dl.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/G13_case01_tti_ul.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	Run Keyword And Ignore Error    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}step4_HO_to_gnb2_1   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'step4_HO_to_gnb2_1' File
# 
# Inquery UE'${u_id}' NR Measurement Identities
#     Wait Throughput Timer    3
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=${u_id}
#     ...      pass_regexp=NR MEASUREMENT IDENTITIES
#     Wait Throughput Timer    3
# 
# Add L2PS Deubg Logs	
#     ${debuglogs}    create list    level=DBG\n    L2.L2_PS.DEBUG=1\n    L2.L2_PS.DL.SUBBAND_BEAMFORMING=1\n    L2.L2_PS.SRS_BASED_BM=1\n 
# 	Active L2ps Feature Debug Traces    ${debuglogs}
# 	TAF_SSH.connect to    192.168.255.1   toor4nsn    oZPS0POrRieRtu   alias=bsh
# 	TAF_SSH.execute    rm /ffs/run/HashContainer*    connection=bsh
# 	
# Step 5: Detach all UEs
#     Start capture GNB and AP Syslog in 'Step5_Detach_all_UEs' File
#     : FOR    ${i}    IN RANGE    1    2
#     \    Stop UE DL Traffic    ${i}
#     \    Detach UE    ${i}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step5_Detach_all_UEs' File
# 	
# Stop UE DL Traffic
#     [Arguments]    ${ue_id}
#     airphone_sa_stop_data_traffic    ${ue_id}    DL
# 	
# Detach UE
#     [Arguments]    ${ue_id} 
#     airphone_sa_detach    ue_id=${ue_id}    timeout=30
# 	