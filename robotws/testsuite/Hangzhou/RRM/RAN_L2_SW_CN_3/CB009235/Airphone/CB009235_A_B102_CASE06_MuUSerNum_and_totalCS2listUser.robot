# *** Settings ***
# Documentation     Author: shuiheng.he@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB009235_A_B102_CASE06_getAnUeForCheck_CorrelationCheckNeeded_with_MuUSerNum_and_totalCS2listUser
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
# ${dlMimoMode}                              text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                              text|16DL8UL|//*[@name\="nrCellType"]
# ${actUeCsirsCoexistCellCsirs}              text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${actCsirsMultiplexing}                    text|true|//*[@name\="actCsirsMultiplexing"]
# ${actDlMuMimoEnh}                          text|true|//*[@name\="actDlMuMimoEnh"]
# ${actDlSrsBm}                              text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                              text|true|//*[@name\="actUlSrsBm"]
# ${actUl256Qam}                             text|true|//*[@name\="actUl256Qam"]
# ${actDl256Qam}                             text|true|//*[@name\="actDl256Qam"]
# ${srsPowerThresholdForDlBm}                text|-1150|//*[@name\="srsPowerThresholdForDlBm"]
# ${tiltOffset}                text|0|//*[@name\="tiltOffset"]
# ${cmd_00}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=SRS multi_path_config=true
# ${cmd_01}    ul_mimo_srs_beam_pos_nr profile_id=2 mode=fixed init_quad_pos=0 init_sub_quad_pos=1 test_type=SRS multi_path_config=true
# ${cmd_02}    ul_mimo_srs_beam_pos_nr profile_id=3 mode=fixed init_quad_pos=0 init_sub_quad_pos=2 test_type=SRS multi_path_config=true
# ${cmd_03}    ul_mimo_srs_beam_pos_nr profile_id=4 mode=fixed init_quad_pos=0 init_sub_quad_pos=3 test_type=SRS multi_path_config=true
# ${cmd_10}    ul_mimo_srs_beam_pos_nr profile_id=5 mode=fixed init_quad_pos=1 init_sub_quad_pos=0 test_type=SRS multi_path_config=true
# ${cmd_30}    ul_mimo_srs_beam_pos_nr profile_id=6 mode=fixed init_quad_pos=1 init_sub_quad_pos=3 test_type=SRS multi_path_config=true
# ${cmd_31}    ul_mimo_srs_beam_pos_nr profile_id=7 mode=fixed init_quad_pos=3 init_sub_quad_pos=1 test_type=SRS multi_path_config=true
# ${cmd_32}    ul_mimo_srs_beam_pos_nr profile_id=8 mode=fixed init_quad_pos=3 init_sub_quad_pos=2 test_type=SRS multi_path_config=true
# ${cmd_33}    ul_mimo_srs_beam_pos_nr profile_id=9 mode=fixed init_quad_pos=3 init_sub_quad_pos=3 test_type=SRS multi_path_config=true
# ${cmd_00_10}    ul_mimo_srs_beam_pos_nr profile_id=10 mode=fixed init_quad_pos=0 init_sub_quad_pos=0 test_type=SRS multi_path_config=true
# 
# ${cmd_001}    num_of_nlos_paths=1 azimuth=58 zenith=2 srs_transmit_power_per_port=-250,-250,-300,-300
# ${cmd_001_1}    num_of_nlos_paths=1 azimuth=58 zenith=2 srs_transmit_power_per_port=-700,-700,-700,-700
# ${cmd_002}    num_of_nlos_paths=1 azimuth=52 zenith=2 srs_transmit_power_per_port=-300,-500,-300,-500
# ${cmd_003}    num_of_nlos_paths=1 azimuth=52 zenith=-2 srs_transmit_power_per_port=-300,-500,-300,-500
# ${cmd_004}    num_of_nlos_paths=1 azimuth=58 zenith=-2 srs_transmit_power_per_port=-250,-250,-300,-300
# ${cmd_004_1}    num_of_nlos_paths=1 azimuth=58 zenith=-2 srs_transmit_power_per_port=-700,-700,-700,-700
# ${cmd_005}    num_of_nlos_paths=1 azimuth=-14 zenith=2 srs_transmit_power_per_port=-300,-500,-300,-500
# ${cmd_006}    num_of_nlos_paths=1 azimuth=30 zenith=40 srs_transmit_power_per_port=-300,-500,-300,-500
# ${cmd_007}    num_of_nlos_paths=1 azimuth=14 zenith=-8 srs_transmit_power_per_port=-300,-500,-300,-500
# ${cmd_008}    num_of_nlos_paths=1 azimuth=14 zenith=8 srs_transmit_power_per_port=-300,-500,-300,-500
# ${cmd_009}    num_of_nlos_paths=1 azimuth=18 zenith=8 srs_transmit_power_per_port=-300,-500,-300,-500
# ${cmd_010}    num_of_nlos_paths=1 azimuth=55 zenith=2 srs_transmit_power_per_port=-250,-250,-300,-300
# 
# #${cmd_003}    num_of_nlos_paths=1 azimuth=-14 zenith=2 srs_transmit_power_per_port=-300,-500,-300,-500
# #${cmd_003}    subband_config_subband_prb_size=16
# #${cmd_004}    subband_config_stepsize_azimuth=2 subband_config_stepsize_zenith=2 subband_config_start_prb=1 subband_config_num_of_prb=216
# 
# *** Test Cases ***
# CB009235_A_B102_CASE06_getAnUeForCheck_CorrelationCheckNeeded_with_MuUSerNum_and_totalCS2listUser
#     Step1:Commission the above configuration on WebUI
#     Step2:attach 10 ues at all high corr position
#     Step3:Do Traffic and check block ue list num 8
# 	Step4:Detach 2 UEs to make corr check not needed 
#     Step5:change 8 UEs low srs power to make only 2 eligible ues
# 	#Step6:Detach all UEs
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}WTS${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008322    ${CURDIR}/config/${SW_BRANCH}${/}SCF${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}${/}SCF${/}${SCFC_NAME}    ${scfc_path}
#     ${modify_list}    create list
#     ...      ${actMuAwareTdSch}    ${dlMuAwareCorrThd}    ${dlMuAwarePrbRatio}    ${dlMuMaxNumLayerPerMuRbg}    ${dlMuMimoCorrThd}
#     ...      ${dlMuMimoCqiThd}    ${dlMuMimoRankAdaption}    ${dlMuMimoSpectralEffThd}    ${dlMuMimoTaperingH}    ${dlMuMimoTaperingV}
#     ...      ${dlMuPairingPrbRatio}    ${dlMimoMode}    ${nrCellType}    ${actUeCsirsCoexistCellCsirs}    ${actCsirsMultiplexing}
# 	...      ${actCsirsMultiplexing}     ${actDlSrsBm}    ${actDlMuMimoEnh}    ${actUl256Qam}    ${actDl256Qam}    ${srsPowerThresholdForDlBm}
# 	...      ${tiltOffset}
# 	modify_xml  	    ${scfc_path}        ${scfc_path}         ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_N01_COVERAGE_00392_00001
#     Add L2PS Deubg Logs	
# 	Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CURDIR}/config/${SW_BRANCH}${/}WTS${/}${WTS_NAME}
#     ...    reset_after_commission=${False}
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
# 	add_txt_node   0x9D0000:15        #as PM counter period update to 15/15=1min, 0x340000 was replaced by 0x9D0000
# 	add_txt_node    0x58077e:1   #This R&D parameter enables ttiTrace for DL Mu aware scheduling information
#     add_txt_node    0x580539:9   #Num UE threshold,to collect trace
#     teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Step2:attach 10 ues at all high corr position
#     Start Capture GNB and AP Syslog in 'Step2_attach' File
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
# 	Log To Console    \n\r==================the beginning of traffic commands==================\n\r
# 	#Wait Throughput Timer    120
# 	#Start GNB Ttitrace With Streaming Mode
# 	Start GNB BIP Log
#     run keyword and continue on failure    Attach SA ue with capability to 5g cell    10    CA_P2_8x4_t2r4_n2
# 	Airphone Execute Egate Command    ${cmd_00} ${cmd_001}
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=1-4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0
# 	Airphone Execute Egate Command    ${cmd_03} ${cmd_004}
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=5-8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4 scell\=0
# 	Airphone Execute Egate Command    ${cmd_00_10} ${cmd_010}
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=9-10 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10 scell\=0	
# 	Log To Console    \n\r==================the ending of traffic commands==================\n\r
# 	Stop Gnb BIP Log    log_dir=${save_log}
# 	Start GNB Ttitrace With Streaming Mode
# 	Wait Throughput Timer    2
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}Step2_attach   unzip=TRUE
# 	${rnti_sa_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
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
# Step3:Do Traffic and check block ue list num 8
# 	[Documentation]    Cs2List.numberOfMuEligibleUes > 2, start to check corr, so block ue list num is 8
# 	...    if pucch block ues has higher sub priority than the first MU UE，block ue list num will be less than 8
#     Start Capture GNB and AP Syslog in 'Step3_Do_DL_Traffic' File
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_Do_DL_Traffic
#     : FOR    ${i}    IN RANGE    1    11
#     \    Airphone SA Start Data Traffic    ${i}    DL    25M    trf_id=1    pdu_id=1    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    DL    25M    trf_id=2    pdu_id=1    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    DL    25M    trf_id=3    pdu_id=1    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    DL    25M    trf_id=4    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    DL    25M    trf_id=5    pdu_id=1    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    DL    25M    trf_id=6    pdu_id=1    duration=${3600}   
# 	Start GNB Ttitrace With Streaming Mode
# 	Wait Throughput Timer    1
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    check_block_ue_list_num    ${save_log}/tti_dl.csv    8
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case02_tti_dl.ini    log_need_to_check=i    save_log_directory=${save_log}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3_Do_DL_Traffic' File
# 
# Step4:Detach 2 UEs to make corr check not needed
#     [Documentation]     not meet the condition "rrmMaxNumUesFdmDl - toBeScheduledUeList.size()  < number of un-checked UEs in Cs2List
#     ...    	+ CorrelationCheckBlockUeList.size() + nonCorrCheckUeList.size()", corr check not needed.
# 	Start Capture GNB and AP Syslog in 'Step4_Detach_2_UEs' File
# 	: FOR    ${i}    IN RANGE    1    3
#     \    Stop UE DL Traffic    ${i}
#     \    Detach UE    ${i}
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    1
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_Detach_2_UEs
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Wait Throughput Timer    2
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    check_block_ue_list_num    ${save_log}/tti_dl.csv    0
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case02_tti_dl.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	run keyword and continue on failure    Attach SA ue with capability to 5g cell    2    CA_P2_8x4_t2r4_n2
# 	Airphone Execute Egate Command    ${cmd_00} ${cmd_001}
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=1-2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0
# 	: FOR    ${i}    IN RANGE    1    3
#     \    Airphone SA Start Data Traffic    ${i}    DL    25M    trf_id=1    pdu_id=1    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    DL    25M    trf_id=2    pdu_id=1    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    DL    25M    trf_id=3    pdu_id=1    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    DL    25M    trf_id=4    pdu_id=1    duration=${3600}
#     \    Airphone SA Start Data Traffic    ${i}    DL    25M    trf_id=5    pdu_id=1    duration=${3600}
# 	\    Airphone SA Start Data Traffic    ${i}    DL    25M    trf_id=6    pdu_id=1    duration=${3600}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4_Detach_2_UEs' File
# 
# Step5:change 8 UEs low srs power to make only 2 eligible ues
#     [Documentation]    not meet the condition "Cs2List.numberOfMuEligibleUes > 2", corr check not needed.
# 	Start Capture GNB and AP Syslog in 'Step5_only_2_eligible_ues' File
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=1-4 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=1 scell\=0
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=5-8 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=4 scell\=0
# 	Airphone Execute Egate Command    ${cmd_00} ${cmd_001_1}
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=1-4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0
# 	Airphone Execute Egate Command    ${cmd_03} ${cmd_004_1}
# 	Airphone Execute Egate Command    ue_testmode_set_nr id\=5-8 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4 scell\=0
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_only_2_eligible_ues
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    1
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Wait Throughput Timer    2
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    check_block_ue_list_num    ${save_log}/tti_dl.csv    0
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/case02_tti_dl.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	#Start GNB BIP Log
# 	#Wait Throughput Timer    1
#     #Stop Gnb BIP Log    log_dir=${save_log}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step5_only_2_eligible_ues' File
# 	
# Step6:Detach all UEs
#     Start capture GNB and AP Syslog in 'Step6_Detach_all_UEs' File
#     : FOR    ${i}    IN RANGE    1    11
#     \    Stop UE DL Traffic    ${i}
#     \    Detach UE    ${i}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step6_Detach_all_UEs' File
# 
# Add L2PS Deubg Logs
#     ${debuglogs}    create list    level=DBG\n    L2.L2_PS.DEBUG=1\n    L2.L2_PS.PRESCHED=1\n    L2.L2_PS.SRS_BASED_BM=1\n
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
