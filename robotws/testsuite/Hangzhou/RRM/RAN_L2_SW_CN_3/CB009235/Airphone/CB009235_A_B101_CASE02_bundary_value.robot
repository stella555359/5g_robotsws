# *** Settings ***
# Documentation     Author: shuiheng.he@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB009235_A_B101_CASE02_interface and_dlMuAwareCorrThd_dlMuAwarePrbRatio_bundary_value
# ...
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# 
# Force Tags        CLOUD_5G_I_LO_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_shuihe
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library           ./py_check/tti_check.py
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/config
# #${SCFC_NAME}    SCFC_9235_A_B101_CASE02_16DL8UL.xml
# #${AIRPHONE_NAME}    AP_iphy_AQQL_A_B101_CASE02.xml
# #${WTS_NAME}       wts_9235_A_B101_CASE02.lua
# 
# ${SCFC_NAME}      SCFC_9235_16D8U_1070_100M_case02.xml
# ${AIRPHONE_NAME}    IPHY_AQQL_1CELL_APLO_case02.xml
# ${WTS_NAME}       wts_SA_NSA_case02.cfg
# @{LOG_NAME_LIST}      gnb_snapshot    ap_snapshot    egatelog
# ${actMuAwareTdSch}                         text|true|//*[@name\="actMuAwareTdSch"]
# ${dlMuAwareCorrThd}                        text|10|//*[@name\="dlMuAwareCorrThd"]
# ${dlMuAwarePrbRatio}                       text|100|//*[@name\="dlMuAwarePrbRatio"]
# ${dlMuMaxNumLayerPerMuRbg}                 text|16|//*[@name\="dlMuMaxNumLayerPerMuRbg"]
# ${dlMuMimoCorrThd}                         text|33|//*[@name\="dlMuMimoCorrThd"]
# ${dlMuMimoCqiThd}                          text|1|//*[@name\="dlMuMimoCqiThd"]
# ${dlMuMimoRankAdaption}                    text|adaptive|//*[@name\="dlMuMimoRankAdaption"]
# ${dlMuMimoSpectralEffThd}                  text|10|//*[@name\="dlMuMimoSpectralEffThd"]
# ${dlMuMimoTaperingH}                       text|25dB|//*[@name\="dlMuMimoTaperingH"]
# ${dlMuMimoTaperingV}                       text|NoTapering|//*[@name\="dlMuMimoTaperingV"]
# ${dlMuPairingPrbRatio}                     text|100|//*[@name\="dlMuPairingPrbRatio"]
# 
# ${cellDepType}                             text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                                    text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                              text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                              text|8DL4UL|//*[@name\="nrCellType"]
# ${actUeCsirsCoexistCellCsirs}              text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${actCsirsMultiplexing}                    text|true|//*[@name\="actCsirsMultiplexing"]
# ${actDlSrsBm}                              text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                              text|true|//*[@name\="actUlSrsBm"]
# ${actDlSrsSubbandBm}                       text|true|//*[@name\="actDlSrsSubbandBm"]
# ${actUlClosedLoopPwrCtrl}                  text|pucchPuschSrs|//*[@name\="actUlClosedLoopPwrCtrl"]
# ${actCDrx}                                 text|true|//*[@name\="actCDrx"]
# ${actFdmScheduling}                        text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}                      text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                       text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}                       text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}                 text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}                        text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                                    text|63|//*[@name\="cSRS"]
# ${bSRS}                                    text|0|//*[@name\="bSRS"]
# ${srsPowerThresholdForDlBm}                text|-1200|//*[@name\="srsPowerThresholdForDlBm"]
# ${srsTypeAllocForDlBm}                     text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
# ${bfSubbandSize}                           text|8 PRBs|//*[@name\="bfSubbandSize"]
# ${maxNumUeSrs}                             text|4|//*[@name\="maxNumUeSrs"]
# ${srsQualityThreshold}                     text|-1200|//*[@name\="srsQualityThreshold"]
# 
# ${FILTER1}    uldata_srsreceivereq
# @{title1}    3gpp.rnti    frame.time    3gpp.sfn    3gpp.slot    UlData_srsReceiveReqSubcell_t.srsSuMimoEnable
# ...          UlData_srsReceiveReqSubcell_t.srsBmEnable    UlData_srsReceiveReqSubcell_t.srsBwvEnable   
#    ...     UlData_srsReceiveReqUes_t.transmissionComb
# ...          UlData_srsBmStruct_t.transmissionComb    UlData_srsBwvStruct_t.transmissionComb
# ...          UlData_srsReceiveReqUes_t.powerOffsetSrsToPuschPerAllocatedRe    UlData_srsBmCsInfo_t.bmCyclicShift
# ...          UlData_srsBmCombShiftPairs_t.transmissionCombId
# ${srsPowerThresholdForUlBm}                 text|-1200|//*[@name\="srsPowerThresholdForUlBm"]
# ${dllaDeltaCqiMax}                          text|0|//*[@name\="dllaDeltaCqiMax"]
# ${dllaDeltaCqiMin}                          text|0|//*[@name\="dllaDeltaCqiMin"]
# ${dllaDeltaCqiStepdown}                     text|0|//*[@name\="dllaDeltaCqiStepdown"]
# ${actIncreasedFdmUsersPerSlot}              text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
# ${actDlMuMimoEnh}                           text|true|//*[@name\="actDlMuMimoEnh"]
# ${actCsirsBeamPowerBalance}                 text|false|//*[@name\="actCsirsBeamPowerBalance"]
# ${comb}                                     text|comb4|//*[@name\="comb"]
# ${actUl256Qam}                              text|true|//*[@name\="actUl256Qam"]
# ${actDl256Qam}                              text|true|//*[@name\="actDl256Qam"]
# ${bwp_profile5}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-5|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile52}     text|MRBTS-1/NRBTS-1/BWP_PROFILE-52|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# ${cmd_00}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=SRS multi_path_config=true
# ${cmd_01}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=0 init_sub_quad_pos=1 test_type=SRS multi_path_config=true
# ${cmd_02}    ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=0 init_sub_quad_pos=2 test_type=SRS multi_path_config=true
# ${cmd_03}    ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed init_quad_pos=0 init_sub_quad_pos=3 test_type=SRS multi_path_config=true
# ${cmd_10}    ul_mimo_srs_beam_pos_nr profile_id=5 mode=fixed init_quad_pos=1 init_sub_quad_pos=0 test_type=SRS multi_path_config=true
# ${cmd_30}    ul_mimo_srs_beam_pos_nr profile_id=6 mode=fixed init_quad_pos=1 init_sub_quad_pos=3 test_type=SRS multi_path_config=true
# ${cmd_31}    ul_mimo_srs_beam_pos_nr profile_id=7 mode=fixed init_quad_pos=3 init_sub_quad_pos=1 test_type=SRS multi_path_config=true
# ${cmd_32}    ul_mimo_srs_beam_pos_nr profile_id=8 mode=fixed init_quad_pos=3 init_sub_quad_pos=2 test_type=SRS multi_path_config=true
# ${cmd_33}    ul_mimo_srs_beam_pos_nr profile_id=9 mode=fixed init_quad_pos=3 init_sub_quad_pos=3 test_type=SRS multi_path_config=true
# 
# ${cmd_001}    num_of_nlos_paths=1 azimuth=58 zenith=2 srs_transmit_power_per_port=-300,-500,-300,-500
# ${cmd_002}    num_of_nlos_paths=1 azimuth=52 zenith=2 srs_transmit_power_per_port=-300,-500,-300,-500
# ${cmd_003}    num_of_nlos_paths=1 azimuth=52 zenith=-2 srs_transmit_power_per_port=-300,-500,-300,-500
# ${cmd_004}    num_of_nlos_paths=1 azimuth=58 zenith=-2 srs_transmit_power_per_port=-300,-500,-300,-500
# ${cmd_005}    num_of_nlos_paths=1 azimuth=-14 zenith=2 srs_transmit_power_per_port=-300,-500,-300,-500
# ${cmd_006}    num_of_nlos_paths=1 azimuth=30 zenith=40 srs_transmit_power_per_port=-300,-500,-300,-500
# ${cmd_007}    num_of_nlos_paths=1 azimuth=14 zenith=-8 srs_transmit_power_per_port=-300,-500,-300,-500
# ${cmd_008}    num_of_nlos_paths=1 azimuth=14 zenith=8 srs_transmit_power_per_port=-300,-500,-300,-500
# ${cmd_009}    num_of_nlos_paths=1 azimuth=18 zenith=8 srs_transmit_power_per_port=-300,-500,-300,-500
# 
# ${cmd_003}    num_of_nlos_paths=1 azimuth=-14 zenith=2 srs_transmit_power_per_port=-300,-500,-300,-500
# ${cmd_003}    subband_config_subband_prb_size=16
# ${cmd_004}    subband_config_stepsize_azimuth=2 subband_config_stepsize_zenith=2 subband_config_start_prb=1 subband_config_num_of_prb=216
# 
# *** Test Cases ***
# CB009235_A_B101_CASE02_interface and_dlMuAwareCorrThd_dlMuAwarePrbRatio_bundary_value
#     Step1:Commission the above configuration on WebUI
#     Step2:UEs with different capability attach to cell1
#     Step3:Do Traffic to make the UEs be configured as wide band SRS
# 	Step4:Online change dlMuAwareCorrThd into 100
#     Step5:Online change dlMuAwareCorrThd into 32
# 	Step6:Online change dlMuAwareCorrThd into 0
# 	Step7:Change the full buffer of all UEs into low buffer
# 	Step8:Online change dlMuAwarePrbRatio into 0
# 	#Step9:Detach all UEs
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}WTS${/}${AIRPHONE_NAME}
# 	#change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008322    ${CURDIR}/config/${SW_BRANCH}${/}SCF${/}${SCFC_NAME}
# 	#Add RD
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}${/}SCF${/}${SCFC_NAME}    ${scfc_path}
# 	#del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     ${modify_list}    create list
#     ...      ${actMuAwareTdSch}    ${dlMuAwareCorrThd}    ${dlMuAwarePrbRatio}    ${dlMuMaxNumLayerPerMuRbg}    ${dlMuMimoCorrThd}
#     ...      ${dlMuMimoCqiThd}    ${dlMuMimoRankAdaption}    ${dlMuMimoSpectralEffThd}    ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}
#     ...      ${dlMuPairingPrbRatio}
# 	...      ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUeCsirsCoexistCellCsirs}
# 	...      ${actCsirsMultiplexing}    ${actDlSrsBm}    ${actUlSrsBm}    ${actUlClosedLoopPwrCtrl}    ${actCDrx}    ${actFdmScheduling}
#    	...      ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}    ${prachConfigurationIndex}
# 	...      ${srsUePeriodicity}    ${cSRS}    ${bSRS}     ${srsPowerThresholdForDlBm}
# 	...      ${srsTypeAllocForDlBm}
# 	...      ${actDlSrsSubbandBm}    ${bfSubbandSize}    ${maxNumUeSrs}    ${srsQualityThreshold}
# 	...      ${dllaDeltaCqiMax}    ${dllaDeltaCqiMin}    ${dllaDeltaCqiStepdown}    ${actIncreasedFdmUsersPerSlot}    ${actDlMuMimoEnh}
# 	...      ${actCsirsBeamPowerBalance}    ${comb}    ${actUl256Qam}    ${actDl256Qam}    ${bwp_profile5}    ${bwp_profile52}
#     #modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
# 	#Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
#     #Add L2PS Deubg Logs	
# 	#Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
# 	Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CURDIR}/config/${SW_BRANCH}${/}WTS${/}${WTS_NAME}
#     ...    reset_after_commission=${False}
#     #Prepare gnb onair
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step1_before_onair
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
# 	#add_txt_node    0x580789:0x1       #rdEnableNiddFor8322
# 	#add_txt_node    0x580776:0x1       #This flag is used to control DL MU-MIMO interworking with subband BWVs
# 	add_txt_node    0x58077e:1   #This R&D parameter enables ttiTrace for DL Mu aware scheduling information
#     
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
# 	#Start GNB Ttitrace With Streaming Mode
# 	#Start GNB BIP Log
# 	#COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     #COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=actUlClosedLoopPwrCtrl
#     #...    operation=update    value=pucchPuschSrs    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     #Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     run keyword and continue on failure    Attach SA ue with capability to 5g cell    10    CA_P2_8x4_t2r4_n2
# 	Attach SA ue with capability    11    CA_P2_8x4_t2r4_n2
# 	airphone_set_traffic_type    11    1    internal
# 	Airphone Pdu Session Setup    11    1    1    2
# 	Attach SA ue with capability    12    CA_P2_8x4_t2r4_n2
# 	airphone_set_traffic_type    12    1    internal
# 	Airphone Pdu Session Setup    12    1    1    2
# 	Attach SA ue with capability    13    CA_P2_8x4_t2r4_n2
# 	airphone_set_traffic_type    13    1    internal
# 	Airphone Pdu Session Setup    13    1    1    2
# 	Attach SA ue with capability    14    CA_P2_8x4_t2r4_n2
# 	airphone_set_traffic_type    14    1    internal
# 	Airphone Pdu Session Setup    14    1    1    2
# 	Attach SA ue with capability    15    CA_P2_8x4_t2r4_n2
# 	airphone_set_traffic_type    15    1    internal
# 	Airphone Pdu Session Setup    15    1    1    2
# 	Airphone Execute Egate Command    ${cmd_00} ${cmd_001}
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0
# 	Airphone Execute Egate Command    ${cmd_01} ${cmd_002}
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=0
# 	Airphone Execute Egate Command    ${cmd_02} ${cmd_003}
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=3 scell\=0
# 	Airphone Execute Egate Command    ${cmd_03} ${cmd_004}
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4 scell\=0
# 	Airphone Execute Egate Command    ${cmd_10} ${cmd_005}
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=5 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5 scell\=0
# 	Airphone Execute Egate Command    ${cmd_30} ${cmd_006}
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=6 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=6 scell\=0
# 	Airphone Execute Egate Command    ${cmd_31} ${cmd_007}
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=7 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=7 scell\=0
# 	Airphone Execute Egate Command    ${cmd_32} ${cmd_008}
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=8 scell\=0
# 	Airphone Execute Egate Command    ${cmd_33} ${cmd_009}
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=9 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=9 scell\=0
# 	Log To Console    \n\r==================the ending of traffic commands==================\n\r
# 	#Stop Gnb BIP Log    log_dir=${save_log}
# 	#${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	#Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap0    ${save_log}/attach.csv    ${FILTER1}    ${title1}
#     #run keyword and continue on failure    check_log_with_au2anlysis
#     #...    ini_path=${CURDIR}/log_check/D4_case033_tti_step2.ini    log_need_to_check=i    save_log_directory=${save_log}
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}Step2_attach   unzip=TRUE
# 	${rnti_sa_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
# 	Set test Variable	 ${rnti_1} 	${rnti_sa_list[0]}
# 	Set test Variable	 ${rnti_2} 	${rnti_sa_list[1]}
# 	Set test Variable	 ${rnti_3} 	${rnti_sa_list[2]}
# 	Set test Variable	 ${rnti_4} 	${rnti_sa_list[3]}
# 	Set test Variable	 ${rnti_5} 	${rnti_sa_list[4]}
# 	Set test Variable	 ${rnti_6} 	${rnti_sa_list[5]}
# 	Set test Variable	 ${rnti_7} 	${rnti_sa_list[6]}
# 	Set test Variable	 ${rnti_8} 	${rnti_sa_list[7]}
# 	Set test Variable	 ${rnti_9} 	${rnti_sa_list[8]}
# 	Set test Variable	 ${rnti_10} 	${rnti_sa_list[9]}
# 	Set test Variable	 ${rnti_11} 	${rnti_sa_list[10]}
# 	Set test Variable	 ${rnti_12} 	${rnti_sa_list[11]}
# 	Set test Variable	 ${rnti_13} 	${rnti_sa_list[12]}
# 	Set test Variable	 ${rnti_14} 	${rnti_sa_list[13]}
# 	Set test Variable	 ${rnti_15} 	${rnti_sa_list[14]}
# 	#${rnti_nsa_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   newUE-Identity (\\d+)
# 	#Set test Variable	 ${rnti_5} 	${rnti_nsa_list[0]}
#     [Teardown]    Stop Capture GNB and AP Syslog in 'Step2_attach' File
# 
# ul_mimo_srs_beam_pos_active_test_type_srs
#     [Arguments]    ${ue}    ${profile}    ${init}    ${sub}    ${scell}=0    ${step}=10    ${puxch}=0    ${u}=trigger_puxch_update
#     ...    ${iq}=init_quad_pos    ${sq}=init_sub_quad_pos    ${m}=multi_path_config    ${mu_path}=0    ${p}=profile_id    ${y}=test_type
#     ...    ${t}=SRS
#     airphone_execute_egate_command
#     ...    ul_mimo_srs_beam_pos_nr ${p}\=${profile} mode\=fixed ${iq}\=${init} ${sq}\=${sub} step\=${step} ${u}\=${puxch} 
#    ...    ${m}\=${mu_path} ${y}\=${t}
# 	airphone_execute_egate_command
# 	...    ue_testmode_set_nr id\=${ue} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${profile} scell\=${scell}
# 
# 
# Step3:Do Traffic to make the UEs be configured as wide band SRS
#     Start Capture GNB and AP Syslog in 'Step3_Do_DL_Traffic' File
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_Do_DL_Traffic
# 	Log To Console    \n\r==================the beginning of traffic commands==================\n\r
# 	#Wait Throughput Timer    120
# #	Start GNB Ttitrace With Streaming Mode
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_Do_DL_Traffic
#     : FOR    ${i}    IN RANGE    1    16
#     \    Airphone SA Start Data Traffic    ${i}    DL    25M    trf_id=1    pdu_id=1    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    DL    25M    trf_id=2    pdu_id=1    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    DL    25M    trf_id=3    pdu_id=1    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    DL    25M    trf_id=4    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    DL    25M    trf_id=5    pdu_id=1    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    DL    25M    trf_id=6    pdu_id=1    duration=${3600}
# 	Log To Console    \n\r==================the ending of traffic commands==================\n\r    
#     #airphone_execute_egate_command    csi_override_testmode_nr profile_id\=1 ri\=0
#     #airphone_execute_egate_command    ue_testmode_set_nr id\=1-10 testmode\=csi_override action\=activate profile_id\=1
# 	Start GNB Ttitrace With Streaming Mode
# 	Wait Throughput Timer    1
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	#Start GNB BIP Log
#     #Wait Throughput Timer    1
#     #Stop Gnb BIP Log    log_dir=${save_log}
# 	#Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap0    ${save_log}/bip.csv    ${FILTER1}    ${title1}
# 	#run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
# 	#run keyword and continue on failure    check_log_with_au2anlysis
#     #...    ini_path=${CURDIR}/log_check/D4_case033_tti_step3_dl.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	#run keyword and continue on failure    check_log_with_au2anlysis
#     #...    ini_path=${CURDIR}/log_check/C1_case06_tti_ul_step3.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	#${tput}    get DL UL tput from PM counter    ${save_log}
#     #run keyword and continue on failure    should be true    ${tput}[0]>850
# 	#run keyword and continue on failure    should be true    ${tput}[1]>130
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3_Do_DL_Traffic' File
# 
# Step4:Online change dlMuAwareCorrThd into 100
#     [Documentation]    corr may bigger than 1, so there are a few ues who are added into block ue list， but much more UEs have less than 1 corr,
# 	...    so block ue list nums are almost 0
# 	Start Capture GNB and AP Syslog in 'Step4_Online_change_dlMuAwareCorrThd_into_100' File
# 	COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuAwareCorrThd
#     ...    operation=update    value=100    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    1
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_Online_change_dlMuAwareCorrThd_into_100
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Wait Throughput Timer    2
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    check_block_ue_list_num    ${save_log}/tti_dl.csv    0
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case02_tti_dl.ini    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4_Online_change_dlMuAwareCorrThd_into_100' File
# 
# Step5:Online change dlMuAwareCorrThd into 32
#     [Documentation]    hard to TA check
# 	Start Capture GNB and AP Syslog in 'Step5_Online_change_dlMuAwareCorrThd_into_32' File
# 	COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuAwareCorrThd
#     ...    operation=update    value=32   skip_parameter_relation_errors=True    should_activate=True    connection=online
# 	Log to console    ====================032==============================
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    1
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_Online_change_dlMuAwareCorrThd_into_32
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Wait Throughput Timer    2
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case02_tti_dl.ini    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step5_Online_change_dlMuAwareCorrThd_into_32' File
# 
# Step6:Online change dlMuAwareCorrThd into 0
#     [Documentation]    total UEs num is 15, the fist MU is added to toBeScheduleList without corr check.
# 	...    due to dlMuAwarePrbRatio=1, corr check condition, sum_requiredPrb > maxNumberOfPrbAllowedByBBRM *dlMuAwarePrbRatio does not meet,
# 	...    the 2nd UE will not perform corr check, and is add to toBeScheduleList directly.
# 	...    from the third UE, start to check corr, so block ue list nums are almost 15-2=13
# 	...    except those PUCCH block UEs who has highest sub priority.
#     Start Capture GNB and AP Syslog in 'Step6_Online_change_dlMuAwareCorrThd_into_0' File
# 	COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuAwareCorrThd
#     ...    operation=update    value=0    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    1
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6_Online_change_dlMuAwareCorrThd_into_0
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Wait Throughput Timer    2
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    check_block_ue_list_num    ${save_log}/tti_dl.csv    13
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case02_tti_dl.ini    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step6_Online_change_dlMuAwareCorrThd_into_0' File
# 
# Step7:Change the full buffer of all UEs into low buffer
#     [Documentation]     dlMuAwareCorrThd=0.1, dlMuAwarePrbRatio=1, block ue lists are always 0
#     Start Capture GNB and AP Syslog in 'Step7_Change_the_full_buffer_of_all_UEs_into_low_buffer' File
# 	COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuAwareCorrThd
#     ...    operation=update    value=10    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
# 	: FOR    ${i}    IN RANGE    1    16
#     \    Stop UE DL Traffic    ${i}
# 	: FOR    ${i}    IN RANGE    1    16
#     \    Airphone SA Start Data Traffic    ${i}    DL    1M    trf_id=1    pdu_id=1    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    DL    1M    trf_id=2    pdu_id=1    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    DL    1M    trf_id=3    pdu_id=1    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    DL    1M    trf_id=4    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    DL    1M    trf_id=5    pdu_id=1    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    DL    1M    trf_id=6    pdu_id=1    duration=${3600}
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    1
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step7_Change_the_full_buffer_of_all_UEs_into_low_buffer
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Wait Throughput Timer    2
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	#run keyword and continue on failure    check_block_ue_list_more_than_0    ${save_log}/tti_dl.csv
# 	run keyword and continue on failure    check_block_ue_list_num    ${save_log}/tti_dl.csv    0
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case02_tti_dl.ini    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    run keyword and continue on failure
#     ...    Stop Capture GNB and AP Syslog in 'Step7_Change_the_full_buffer_of_all_UEs_into_low_buffer' File
# 
# Step8:Online change dlMuAwarePrbRatio into 0
#     [Documentation]     dlMuAwareCorrThd=0.1, dlMuAwarePrbRatio=0, corr will be check, so theres are block ue lists whose num is bigger than 0 
#     Start Capture GNB and AP Syslog in 'Step8_Online_change_dlMuAwarePrbRatio_into_0' File
# 	COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuAwarePrbRatio
#     ...    operation=update    value=0    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    1
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step8_Online_change_dlMuAwarePrbRatio_into_0
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Wait Throughput Timer    2
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    check_block_ue_list_more_than_0    ${save_log}/tti_dl.csv
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case02_tti_dl.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1/NRDLMUMIMO-1    parameter=dlMuAwarePrbRatio
#     ...    operation=update    value=100    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step8_Online_change_dlMuAwarePrbRatio_into_0' File
# 	
# Step9:Detach all UEs
#     Start capture GNB and AP Syslog in 'Step9_Detach_all_UEs' File
#     : FOR    ${i}    IN RANGE    1    16
#     \    Stop UE DL Traffic    ${i}
#     \    Detach UE    ${i}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step9_Detach_all_UEs' File
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
# 
# Stop UE DL Traffic
#     [Arguments]    ${ue_id}
#     airphone_sa_stop_data_traffic    ${ue_id}    DL
# 	
# Detach UE
#     [Arguments]    ${ue_id} 
#     airphone_sa_detach    ue_id=${ue_id}    timeout=30
