# *** Settings ***
# Documentation     Author: shuiheng.he@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008322_D4_case033_Comb4_Coexist_of_3_types_of_SRS_based_beamforming_srsUePeriodicity_slots20_frame1116_3ms_70Mhz
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
# ${SCFC_NAME}    SCF/SCFC_8322_D4_case033_70M_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_4S_1CC_MP.xml
# ${AIRPHONE_NAME}    WTS/AP_iphy_AQQL_D3_case032_MP.xml
# ${WTS_NAME}       WTS/wts_config_AQQL_D3_case032.cfg
# @{LOG_NAME_LIST}      gnb_snapshot    ap_snapshot    egatelog
# ${cellDepType}                             text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                    text|70 MHz|//*[@name\="chBw"]
# ${dlMimoMode}                              text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                              text|8DL4UL|//*[@name\="nrCellType"]
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
# ${cSRS}                                    text|42|//*[@name\="cSRS"]
# ${bSRS}                                    text|2|//*[@name\="bSRS"]
# ${srsPowerThresholdForDlBm}                text|-1200|//*[@name\="srsPowerThresholdForDlBm"]
# ${srsTypeAllocForDlBm}                     text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
# ${bfSubbandSize}                           text|8 PRBs|//*[@name\="bfSubbandSize"]
# ${maxNumUeSrs}                             text|4|//*[@name\="maxNumUeSrs"]
# ${srsQualityThreshold}                     text|-1200|//*[@name\="srsQualityThreshold"]
# 
# ${FILTER1}    ulcell_setupreq
# @{title1}    UlCell_SRSconfig_t.transmissionComb
# 
# ${srsPowerThresholdForUlBm}                 text|-1200|//*[@name\="srsPowerThresholdForUlBm"]
# ${dllaDeltaCqiMax}                          text|0|//*[@name\="dllaDeltaCqiMax"]
# ${dllaDeltaCqiMin}                          text|0|//*[@name\="dllaDeltaCqiMin"]
# ${dllaDeltaCqiStepdown}                     text|0|//*[@name\="dllaDeltaCqiStepdown"]
# ${actIncreasedFdmUsersPerSlot}              text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
# ${actDlMuMimoEnh}                           text|false|//*[@name\="actDlMuMimoEnh"]
# ${actCsirsBeamPowerBalance}                 text|false|//*[@name\="actCsirsBeamPowerBalance"]
# ${comb}                                     text|comb4|//*[@name\="comb"]
# ${actUl256Qam}                              text|true|//*[@name\="actUl256Qam"]
# ${actDl256Qam}                              text|true|//*[@name\="actDl256Qam"]
# ${prbRatioThreshold}                         text|2|//*[@name\="prbRatioThreshold"]
# ${srsUePeriodicityInput}                    text|slots40|//*[@name\="srsUePeriodicityInput"]
# ${srsUePeriodicityOutput}                   text|slots40|//*[@name\="srsUePeriodicityOutput"]
# ${numWbSrsConfigSample}                     text|5|//*[@name\="numWbSrsConfigSample"]
# ${prbSampleHighLowPercentage}               text|80|//*[@name\="prbSampleHighLowPercentage"]
# ${wbSrsPowerThreshold}                       text|-1200|//*[@name\="wbSrsPowerThreshold"]
# ${srsSinrThreshold}                text|-400|//*[@name\="srsSinrThreshold"]
# 
# ${cmd_1_00}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=0 test_type=SRS multi_path_config=true
# ${cmd_002_001}    num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-350,-500,-350,-500
# ${cmd_002_002}    num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-350,-500,-350,-500
# ${cmd_002_003}    num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-700,-700,-700,-700
# ${cmd_003}    subband_config_subband_prb_size=16
# ${cmd_004}    subband_config_stepsize_azimuth=2 subband_config_stepsize_zenith=2 subband_config_start_prb=1 subband_config_num_of_prb=216
# ${cmd_2_00}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=SRS multi_path_config=true
# ${cmd_1_20}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=2 init_sub_quad_pos=0 test_type=SRS multi_path_config=true
# ${cmd_2_20}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=2 init_sub_quad_pos=0 test_type=SRS multi_path_config=true
# 
# *** Test Cases ***
# CB008322_D4_case033_Comb4_Coexist_of_3_types_of_SRS_based_beamforming_srsUePeriodicity_slots20_frame1116_3ms_70Mhz
#     Step1:Commission the above configuration on WebUI
#     Step2:UEs with different capability attach to cell1
#     Step3:Do Traffic to make the UEs be configured as wide band SRS
#     Step4:Triger sub-band TAS SRS by buffer
# 	Step5:Return to RT beam
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CURDIR}/config/${SW_BRANCH}${/}${AIRPHONE_NAME}
# 	#change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008322    ${CURDIR}/config/${SW_BRANCH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CURDIR}/config/${SW_BRANCH}${/}${SCFC_NAME}    ${scfc_path}	
#     ${modify_list}    create list
# 	...      ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUeCsirsCoexistCellCsirs}
# 	...      ${actCsirsMultiplexing}    ${actDlSrsBm}    ${actUlSrsBm}    ${actUlClosedLoopPwrCtrl}    ${actCDrx}    ${actFdmScheduling}
# #	...      ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}    ${prachConfigurationIndex}
# 	...      ${srsUePeriodicity}    ${cSRS}    ${bSRS}
# 	#...      ${srsTypeAllocForDlBm}
# 	...      ${actDlSrsSubbandBm}    ${bfSubbandSize}    ${maxNumUeSrs}
# 	...      ${dllaDeltaCqiMax}    ${dllaDeltaCqiMin}    ${dllaDeltaCqiStepdown}    ${actIncreasedFdmUsersPerSlot}    ${actDlMuMimoEnh}
# 	...      ${actCsirsBeamPowerBalance}    ${comb}    ${actUl256Qam}    ${actDl256Qam}
# 	...      ${prbRatioThreshold}    ${srsUePeriodicityInput}    ${numWbSrsConfigSample}
# 	...      ${prbSampleHighLowPercentage}    ${srsSinrThreshold}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     #Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
#     #Add L2PS Deubg Logs	
# 	Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CURDIR}/config/${SW_BRANCH}${/}${WTS_NAME}
#     ...    reset_after_commission=${False}
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step1_before_onair
# 	Convert BIP To CSV    ${TEST_LOG_DIRECTORY()}/cellSetup0.pcap    ${save_log}/ulcell_setupreq.csv    ${FILTER1}    ${title1}
#     run keyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/D4_case033_tti_step1.ini    log_need_to_check=i
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
# 	add_txt_node    0x5805ae:1       #Flag to enable or disable dynamic Wb/Sb Srs Switch
# 	#add_txt_node    0x590103:2       #whether codebook SRS is reused for TAS SRS
# 	#add_txt_node    0x58076c:0x2       #the percentage of scheduled PRB
# 	#add_txt_node    0x5901E6:40         #wideband periodic
# 	#add_txt_node    0x5805B5:5         #rdNumSrsCheck
# 	#add_txt_node    0x5805B0:80         #rdSrsBufPercent
# 	#add_txt_node    0x580764:-1200         #rdWbSrsQualTresh
# 	#add_txt_node    0x5901E8:1     #CPRT rdActCB009496
#     add_txt_node    0x600013:1     # BOAM_RAT_ADAPT
#     add_txt_node    0x19040F:1     # BOAM_FRONTHAUL
#     #add_txt_node    0x42008E:1     # BOAM DCS
#     #add_txt_node    0x88004B:0             # L1FH rdEnableSktMvp, 0 for 9496; 1 for SKTMVP
#     #add_txt_node    0x880x31:14 	  #L1FH rdBwvTxOpportunities, 14 for 9496;  3 for SKTMVP
#     #add_txt_node    0x580556:65535   #L2PS rdStartPatternId, 65535 for 9496
# 	add_txt_node    0x580789:0x1       #rdEnableNiddFor8322
# 	add_txt_node    0x580776:0x1       #This flag is used to control DL MU-MIMO interworking with subband BWVs
# 	add_txt_node    0x600018:0        #rdUlUpFragmentationEnable
#     teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Step2:UEs with different capability attach to cell1
#     Start Capture GNB and AP Syslog in 'Step2_attach' File
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
# 	Log To Console    \n\r==================the beginning of traffic commands==================\n\r
# 	#Wait Throughput Timer    120
# 	Start GNB Ttitrace With Streaming Mode
# 	Start GNB BIP Log
# 	COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=actUlClosedLoopPwrCtrl
#     ...    operation=update    value=pucchPuschSrs    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     run keyword and continue on failure    Attach SA ue with capability to 5g cell    2    CA_P2_8x4_t2r4_n2
# 	Attach SA ue with capability    3    CA_P2_8x4_noTas_n2
# 	airphone_set_traffic_type    3    1    internal
# 	Airphone Pdu Session Setup    3    1    1    2
#     Attach SA ue with capability    4    CA_P2_8x4_t1r4_n1
# 	airphone_set_traffic_type    4    1    internal
# 	Airphone Pdu Session Setup    4    1    1    2
# 	: FOR    ${i}    IN RANGE    11     12
# 	\    Airphone NSA Attach    ${i}
# 	#Airphone Execute Egate Command    ${cmd_1_00} ${cmd_002_001}
# 	#Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0
# 	#Airphone Execute Egate Command    ${cmd_2_20} ${cmd_002_002}
# 	#Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=0
# 	Log To Console    \n\r==================the ending of traffic commands==================\n\r
# 	Stop Gnb BIP Log    log_dir=${save_log}
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	#Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap0    ${save_log}/attach.csv    ${FILTER1}    ${title1}
#     #run keyword and continue on failure    check_log_with_au2anlysis
#     #...    ini_path=${CURDIR}/log_check/D4_case033_tti_step2.ini    log_need_to_check=i    save_log_directory=${save_log}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}Step2_attach   unzip=TRUE
# 	${rnti_sa_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
# 	Set test Variable	 ${rnti_1} 	${rnti_sa_list[0]}
# 	Set test Variable	 ${rnti_2} 	${rnti_sa_list[1]}
# 	Set test Variable	 ${rnti_3} 	${rnti_sa_list[2]}
# 	Set test Variable	 ${rnti_4} 	${rnti_sa_list[3]}
# 	${rnti_nsa_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   newUE-Identity (\\d+)
# 	Set test Variable	 ${rnti_5} 	${rnti_nsa_list[0]}
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
# 	Log To Console    \n\r==================the beginning of traffic commands==================\n\r
# 	#Wait Throughput Timer    120
# #	Start GNB Ttitrace With Streaming Mode
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_Do_DL_Traffic
#     : FOR    ${i}    IN RANGE    11     12
# 	\    Airphone NSA Start Data Traffic    ${i}    DL    175M    duration=${3600}    trf_id=1
# 	\    Airphone NSA Start Data Traffic    ${i}    UL    175M    duration=${3600}    trf_id=1
# 	: FOR    ${i}    IN RANGE    1    2
#     \    Airphone SA Start Data Traffic    3    DL    175M    trf_id=${i}    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    3    UL    175M    trf_id=${i}    pdu_id=1    duration=${3600}
# 	: FOR    ${i}    IN RANGE    1    2
# 	\    Airphone SA Start Data Traffic    1    DL    175M    trf_id=${i}    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    1    UL    175M    trf_id=${i}    pdu_id=1    duration=${3600}
# 	: FOR    ${i}    IN RANGE    1    2
# 	\    Airphone SA Start Data Traffic    2    DL    175M    trf_id=${i}    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    2    UL    175M    trf_id=${i}    pdu_id=1    duration=${3600}
# 	: FOR    ${i}    IN RANGE    1    2
# 	\    Airphone SA Start Data Traffic    4    DL    175M    trf_id=${i}    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    4    UL    175M    trf_id=${i}    pdu_id=1    duration=${3600}
# 	Log To Console    \n\r==================the ending of traffic commands==================\n\r    
#     Start GNB Ttitrace With Streaming Mode
# 	Wait Throughput Timer    2
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	Start GNB BIP Log
#     Wait Throughput Timer    1
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_Do_DL_Traffic
#     Stop Gnb BIP Log    log_dir=${save_log}
# 	#Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap0    ${save_log}/bip.csv    ${FILTER1}    ${title1}
# 	run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/D4_case033_tti_step3_dl.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/C1_case06_tti_ul_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	#${tput}    get DL UL tput from PM counter    ${save_log}
#     #run keyword and continue on failure    should be true    ${tput}[0]>850
# 	#run keyword and continue on failure    should be true    ${tput}[1]>130
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3_Do_DL_Traffic' File
# 
# Step4:Triger sub-band TAS SRS by buffer
# 	Start Capture GNB and AP Syslog in 'Step4_triger_subband_tas_srs' File
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=1 scell\=0
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2 scell\=0
# 	Airphone Execute Egate Command    ${cmd_2_00} ${cmd_002_003}
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=0
# 	Airphone Execute Egate Command    ${cmd_2_20} ${cmd_002_003}
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=0
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    3
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_triger_subband_tas_srs
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Wait Throughput Timer    2
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	Start GNB BIP Log
#     Wait Throughput Timer    1
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_triger_subband_tas_srs
#     Stop Gnb BIP Log    log_dir=${save_log}
# 	#Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap0    ${save_log}/bip.csv    ${FILTER1}    ${title1}
# 	run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/D4_case033_tti_step4_dl.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/D4_case033_tti_step4_ul.ini    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4_triger_subband_tas_srs' File
# 
# Step5:Return to RT beam
#     Start Capture GNB and AP Syslog in 'Step5_Return_to_RT_beam' File
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2 scell\=0
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=2 scell\=0
# 	Start GNB Ttitrace With Streaming Mode
# 	#Airphone Execute Egate Command    ${cmd_1_00} ${cmd_002_001}
# 	#Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0
# 	#Airphone Execute Egate Command    ${cmd_2_20} ${cmd_002_002}
# 	#Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=0
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_Return_to_RT_beam
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	Start GNB BIP Log
#     Wait Throughput Timer    3
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_Return_to_RT_beam
#     Stop Gnb BIP Log    log_dir=${save_log}
# 	#Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap0    ${save_log}/bip.csv    ${FILTER1}    ${title1}
# 	run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/D4_case033_tti_step3_dl.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/C1_case06_tti_ul_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
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
