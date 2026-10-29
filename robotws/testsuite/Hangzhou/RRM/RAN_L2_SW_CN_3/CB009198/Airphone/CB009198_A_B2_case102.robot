# *** Settings ***
# Documentation     Author: zhaoyang.xu@nokia-sbell.com
# ...               QC case full name:
# ...               CB009198_A_B2_case102_DFT_s_OFDM_for_PUSCH_Feature_Deactivation_multi_UE_some_ue_not_support_DFT_s_OFDM__Pi2BPSK_enable
# ...               The cases initail test in ASIL ,cloud change to ASIB ,BIP log is change ,so BIP log check change to TTItrace log
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# #Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BLLL_AP_LOO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_zhaoxu
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library           taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# Library           taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN
# Library           string
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIL_ABIL_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC_CB009198.xml
# ${AIRPHONE_NAME}      AP_iphy_AEQE_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC_CB009198.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC_CB009198.cfg
# ${gnb_swconfig}       gNB_swconfig_BLLL_AP_LOO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC.txt
# ${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# @{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
# 
# #CB009198_parameters
# ${actUlDftSOfdm}                  text|true|//*[@name\="actUlDftSOfdm"]
# ${ulTransPrecodeOffSinrThresh}    text|200|//*[@name\="ulTransPrecodeOffSinrThresh"]
# ${ulTransPrecodeOnSinrThresh}     text|180|//*[@name\="ulTransPrecodeOnSinrThresh"]
# ${ulTransPrecodeOffSinrThrRedCap}    text|200|//*[@name\="ulTransPrecodeOffSinrThrRedCap"]
# ${ulTransPrecodeOnSinrThrRedCap}     text|180|//*[@name\="ulTransPrecodeOnSinrThrRedCap"]
# ${ulTransPrecodePi2Bpsk}          text|true|//*[@name\="ulTransPrecodePi2Bpsk"]
# #UlPtrs
# ${actUlPtrs}                     text|true|//*[@name\="actUlPtrs"]
# ${ulPtrsFreqDensityThresNrb0}    text|278|//*[@name\="ulPtrsFreqDensityThresNrb0"]
# ${ulPtrsFreqDensityThresNrb1}    text|24|//*[@name\="ulPtrsFreqDensityThresNrb1"]
# #5GC001116_3ms
# ${frameStructureType}            text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}             text|6Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}             text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${lteToNrFrameShift}             text|3ms|//*[@name\="lteToNrFrameShift"]
# ${tdLteUlDlConfig}               text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${prachConfigurationIndex}       text|98|//*[@name\="prachConfigurationIndex"]
# #basic_parameters
# ${chBw}                          text|100MHz|//*[@name\="chBw"]
# ${ulMimoMode}                    text|Closed loop Spatial Multiplexing (2x2)|//*[@name\="ulMimoMode"]
# ${puschMappingType}              text|TypeB|//*[@name\="puschMappingType"]
# #UlDmrs
# ${ulDMRSAdditionalPosition}      text|Automatic|//*[@name\="ulDMRSAdditionalPosition"]
# ${actUlDataDmrsFdm}              text|true|//*[@name\="actUlDataDmrsFdm"]
# ${ulDataDmrsFdmThres64QamMcs}    text|20|//*[@name\="ulDataDmrsFdmThres64QamMcs"]
# ${ulDataDmrsFdmThres256QamMcs}    text|20|//*[@name\="ulDataDmrsFdmThres256QamMcs"]
# #BWP_CONFIG
# ${BWP_PROFILE-8}               text|MRBTS-1/NRBTS-1/BWP_PROFILE-8|//*[@name\='cellBwpList']/item[1]/*[@name\='bwpDN']
# ${BWP_PROFILE-87}              text|MRBTS-1/NRBTS-1/BWP_PROFILE-87|//*[@name\='cellBwpList']/item[2]/*[@name\='bwpDN']
# 
# #${ue_cap_pattern}    PTRS enable DFT-s-OFDM enabled UE NR 
# 
# @{PUSCH_initial_DFT-s-OFDM_PM}    M55302C06000    M55302C06001    M55302C06002
# ...    M55302C06027
# @{Success_initial_Tx_DFTsOFDM_PM}    M55302C08000    M55302C08001    M55302C08002
# ...    M55302C08027
# @{Successful_any_Tx_with_DFTsOFDM}    M55302C09000    M55302C09001    M55302C09002
# @{Unsuccessful_HARQ_reTx_with_DFTsOFDM}    M55302C07000    M55302C07001    M55302C07002
# 
# ${filter_1}    uldata_puschreceivereq
# #||uldata_puschreceiverespharqu
# @{titles_1}    3gpp.sfn    3gpp.slot    3gpp.rnti
# ...    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag    UlData_puschReceiveReqGrant_t.mcs
# ...    UlData_puschReceiveReqGrant_t.modulationOrder    UlData_puschReceiveReqGrant_t.numOfLayers
# 
# 
# *** Test Cases ***
# CB009198_A_B2_case102_DFT_s_OFDM_for_PUSCH_Feature_Deactivation_multi_UE_some_ue_not_support_DFT_s_OFDM__Pi2BPSK_enable
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach 4UEs and send UL data
#     Step3:Increase pathloss for UEs
# 	Step4:Check DFT-s-OFDM related PM counter
#     Step5:Online change actUlDftSOfdm to false
#     Step6:reattach UEs and send UL data
# 	Step7:Decrease pathloss for UEs
#     Step8:Detach All UEs
# 	
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
# 	modify_swconfig_by_CB009198    ${CONFIG_DIR_PATH}/${gnb_swconfig}    Pi2BPSK
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_vonr_extend_parameter_on_bts    xml_path=${scfc_path}	
#     ${modify_list}    create list
#     ...    ${actUlDftSOfdm}     ${ulTransPrecodeOffSinrThresh}    ${ulTransPrecodeOnSinrThresh}    ${ulTransPrecodePi2Bpsk}
# 	...    ${ulTransPrecodeOffSinrThrRedCap}    ${ulTransPrecodeOnSinrThrRedCap}
#     ...    ${actUlPtrs}    ${ulPtrsFreqDensityThresNrb0}    ${ulPtrsFreqDensityThresNrb1}
#     ...    ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}    ${lteToNrFrameShift}
#     ...    ${tdLteUlDlConfig}    ${prachConfigurationIndex} 
#     ...    ${chBw}    ${ulMimoMode}    ${puschMappingType}
#     ...    ${ulDMRSAdditionalPosition}    ${actUlDataDmrsFdm}    ${ulDataDmrsFdmThres64QamMcs}     ${ulDataDmrsFdmThres256QamMcs}
#     ...    ${BWP_PROFILE-8}    ${BWP_PROFILE-87}  
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step1' File
# 
# Step2:Attach 4UEs and send UL data
#     Start Capture GNB and AP Syslog in 'Step2' File
#     Attach Sa Ue With Capability    1
#     Attach Sa Ue With Capability    2
# 	#NO_support_DFT-S-OFDM_Capability UE_id from 3 to 4 define in cfg file
#     Attach_Sa_Ue_With_NO_support_DFT-S-OFDM_Capability    3
#     Attach_Sa_Ue_With_NO_support_DFT-S-OFDM_Capability    4
# 	: FOR    ${i}    IN RANGE    1     5
#     \    Airphone SA Start Data Traffic    ${i}    UL    100M    trf_id=1    pdu_id=1    duration=${3600}
# 	Wait Throughput Timer    30
#     ${Dl_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
#     ${Ul_throughput_ue3} =    Airphone Sa Get Throughput    ue_id=3    direction=ul
#     ${Ul_throughput_ue4} =    Airphone Sa Get Throughput    ue_id=4    direction=ul
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue1} > 2000
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue2} > 2000
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue3} > 2000
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue4} > 2000		
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step2
#    	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/CB009198_off_no_bler.ini    log_need_to_check=i    save_log_directory=${save_log}
#     Start GNB BIP Log
# 	Wait Throughput Timer    1
# 	Stop Gnb BIP Log    log_dir=${save_log}/
#     #Check CB009198 Flag Disable In Bip    ${save_log}/
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step2' File
# 
# Step3:Increase pathloss for UEs
#     Start Capture GNB and AP Syslog in 'Step3' File
#     : FOR    ${i}    IN RANGE    1     5
#     \    Decrease SINR To Trigger CB009198 Enabled    ${i}    5
#     Wait Throughput Timer    10
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
#     ${Ul_throughput_ue3} =    Airphone Sa Get Throughput    ue_id=3    direction=ul
#     ${Ul_throughput_ue4} =    Airphone Sa Get Throughput    ue_id=4    direction=ul
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue1} > 800
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue2} > 800
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue3} > 1800
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue4} > 1800	
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step3
#    	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/CB009198_on_no_dtx_Mixed_UEs.ini    log_need_to_check=i    save_log_directory=${save_log}	
#    	Start GNB BIP Log
# 	Wait Throughput Timer    2
# 	Stop Gnb BIP Log    log_dir=${save_log}/
# 	#Check CB009198 Flag Enable In Bip    ${save_log}/
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step3${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3' File
# 
# Step4:Check DFT-s-OFDM related PM counter
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}Step4${/}
# 	${Count_PUSCH_initial_DFT-s-OFDM_PM}    Set Variable    0
# 	${Count_Success_initial_Tx_DFTsOFDM_PM}    Set Variable    0
# 	${Count_Successful_any_Tx_with_DFTsOFDM}    Set Variable    0
# 	${Count_Unsuccess_HARQ_reTx_with_DFTsOFDM}    Set Variable    0	
# 	:FOR    ${i}    IN     @{PUSCH_initial_DFT-s-OFDM_PM}
# 	\    ${PM_counter}    get_counter_value_from_counter_file     counter_file=${PM_counter_file}    counter_id=${i}    cell_id=1
# 	\    ${Count_PUSCH_initial_DFT-s-OFDM_PM}    evaluate     ${Count_PUSCH_initial_DFT-s-OFDM_PM}+ ${PM_counter}
# 	:FOR    ${i}    IN     @{Success_initial_Tx_DFTsOFDM_PM}
# 	\    ${PM_counter}    get_counter_value_from_counter_file     counter_file=${PM_counter_file}    counter_id=${i}    cell_id=1
# 	\    ${Count_Success_initial_Tx_DFTsOFDM_PM}    evaluate     ${Count_Success_initial_Tx_DFTsOFDM_PM}+ ${PM_counter}	
# 	:FOR    ${i}    IN     @{Successful_any_Tx_with_DFTsOFDM}
# 	\    ${PM_counter}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${i}    cell_id=1
# 	\    ${Count_Successful_any_Tx_with_DFTsOFDM}    evaluate     ${Count_Successful_any_Tx_with_DFTsOFDM}+ ${PM_counter}
# 
# 	:FOR    ${i}    IN    @{Unsuccessful_HARQ_reTx_with_DFTsOFDM}
# 	\    ${PM_counter}    get_counter_value_from_counter_file     counter_file=${PM_counter_file}    counter_id=${i}    cell_id=1
# 	\    ${Count_Unsuccess_HARQ_reTx_with_DFTsOFDM}    evaluate    ${Count_Unsuccess_HARQ_reTx_with_DFTsOFDM}+ ${PM_counter}
#     log    ${Count_PUSCH_initial_DFT-s-OFDM_PM} 
# 	log    ${Count_Success_initial_Tx_DFTsOFDM_PM}
#     log    ${Count_Successful_any_Tx_with_DFTsOFDM}
# 	log    ${Count_Unsuccess_HARQ_reTx_with_DFTsOFDM}
#     Should Be True    ${Count_PUSCH_initial_DFT-s-OFDM_PM} > 0
# 	Should Be True    ${Count_Success_initial_Tx_DFTsOFDM_PM} > 0
#     Should Be True    ${Count_Successful_any_Tx_with_DFTsOFDM} > 0
# 	Should Be True    ${Count_Unsuccess_HARQ_reTx_with_DFTsOFDM} >= 0	
# 
# Step5:Online change actUlDftSOfdm to false
#     Start Capture GNB and AP Syslog in 'Step5' File
#     Online recommissioning with delta json file    ${CURDIR}/JSON/actUlDftSOfdm_to_false.json
#     Block Cell1
#     Unlock Cell1
#     Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step5${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step5' File
# 
# Step6:reattach UEs and send UL data
#     Start Capture GNB and AP Syslog in 'Step6' File
#     Attach Sa Ue With Capability    1
#     Attach Sa Ue With Capability    2
# 	#NO_support_DFT-S-OFDM_Capability UE_id from 3 to 4 define in cfg file
#     Attach_Sa_Ue_With_NO_support_DFT-S-OFDM_Capability    3
#     Attach_Sa_Ue_With_NO_support_DFT-S-OFDM_Capability    4
#     : FOR    ${i}    IN RANGE    1     5
#     \    Airphone SA Start Data Traffic    ${i}    UL    100M    trf_id=1    pdu_id=1    duration=${3600}
# 	Wait Throughput Timer    30
# 	${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
#     ${Ul_throughput_ue3} =    Airphone Sa Get Throughput    ue_id=3    direction=ul
#     ${Ul_throughput_ue4} =    Airphone Sa Get Throughput    ue_id=4    direction=ul
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue1} > 800
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue2} > 800
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue3} > 1800
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue4} > 1800	
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step6
#    	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/CB009198_online_change_no_bler.ini    log_need_to_check=i    save_log_directory=${save_log}
#     Start GNB BIP Log
# 	Wait Throughput Timer    2
# 	Stop Gnb BIP Log    log_dir=${save_log}/
#     #Check CB009198 Flag after actUlDftSOfdm change to false    ${save_log}/
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step6${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step6' File
# 
# Step7:Decrease pathloss for UEs
#     Start Capture GNB and AP Syslog in 'Step7' File
#     : FOR    ${i}    IN RANGE    1     5
#     \    Increase SINR To Trigger CB009198 Disabled    ${i}    5
#     Wait Throughput Timer    10
#    	${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue2} =    Airphone Sa Get Throughput    ue_id=2    direction=ul
#     ${Ul_throughput_ue3} =    Airphone Sa Get Throughput    ue_id=3    direction=ul
#     ${Ul_throughput_ue4} =    Airphone Sa Get Throughput    ue_id=4    direction=ul
#     run keyword and continue on failure    should be true     ${Ul_throughput_ue1}>2000
# 	run keyword and continue on failure    should be true     ${Ul_throughput_ue2}>2000
# 	run keyword and continue on failure    should be true     ${Ul_throughput_ue3}>2000
# 	run keyword and continue on failure    should be true     ${Ul_throughput_ue4}>2000
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step7
#    	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti	
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/CB009198_off_no_bler.ini    log_need_to_check=i    save_log_directory=${save_log}	
#    	Start GNB BIP Log
# 	Wait Throughput Timer    2
# 	Stop Gnb BIP Log    log_dir=${save_log}/
# 	#Check CB009198 Flag Disable In Bip    ${save_log}/
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step7${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step7' File
# 
# 
# 		
# Step8:Detach All UEs
#     Detach '4'UE	
#     Wait Throughput Timer    60
#     Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
# 		
# 
# Attach Sa Ue With Capability
#     [Arguments]    ${ue_id}
#     Airphone SA Attach    ue_id=${ue_id}
#     airphone_set_traffic_type    ${ue_id}    1    internal
#     Airphone Pdu Session Setup    ${ue_id}    1    1    ${ue_id}
#     Wait '2s' for stable running
# 
# 
# Attach_Sa_Ue_With_NO_support_DFT-S-OFDM_Capability
#     [Arguments]    ${ue_id}
# 	Airphone Sa Attach    ue_id=${ue_id}
#     airphone_set_traffic_type    ${ue_id}    1    internal
#     Airphone Pdu Session Setup    ${ue_id}    1    1    ${ue_id}
#     Wait '2s' for stable running
# 
# Check CB009198 Flag Enable In Bip
#     [Arguments]    ${log_dir}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_1:0.pcap0    ${log_dir}/CB009198_bip.csv    ${filter_1}    ${titles_1}
#     run keyword and continue on failure    Check Log With Au2anlysis
#     ...    ini_path=${CURDIR}/ini/CB009198_enable_flag_Mixed_UEs.ini     log_need_to_check=i    save_log_directory=${log_dir}
# 
# Check CB009198 Flag Disable In Bip
#     [Arguments]    ${log_dir}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_1:0.pcap0    ${log_dir}/CB009198_bip.csv    ${filter_1}    ${titles_1}
#     run keyword and continue on failure    Check Log With Au2anlysis
#     ...    ini_path=${CURDIR}/ini/CB009198_disable_flag.ini     log_need_to_check=i    save_log_directory=${log_dir}
# 
# Check CB009198 Flag after actUlDftSOfdm change to false
#     [Arguments]    ${log_dir}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_1:0.pcap0    ${log_dir}/CB009198_bip.csv    ${filter_1}    ${titles_1}
#     run keyword and continue on failure    Check Log With Au2anlysis
#     ...    ini_path=${CURDIR}/ini/CB009198_online_change_false_flag.ini     log_need_to_check=i    save_log_directory=${log_dir}
# 
# 
# Decrease SINR To Trigger CB009198 Enabled
#     [Arguments]    ${ue_id}=1     ${max_num_pathloss}=5
#     ${sinr_target_pathloss} =    Set Variable    60
#     : For    ${index_time}    IN RANGE    1    ${max_num_pathloss}+1
#     \    ${sinr_target_pathloss} =    Evaluate    ${sinr_target_pathloss}+10
# 	\    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=${sinr_target_pathloss}
# 	\    airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
#     \    Wait Throughput Timer    5
# 
# 
# Increase SINR To Trigger CB009198 Disabled
#     [Arguments]    ${ue_id}=1     ${max_num_pathloss}=5
#     ${sinr_target_pathloss} =    Set Variable    115
#     : For    ${index_time}    IN RANGE    1    ${max_num_pathloss}+1
#     \    ${sinr_target_pathloss} =    Evaluate    ${sinr_target_pathloss}-10
# 	\    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=${sinr_target_pathloss}
# 	\    airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
#     \    Wait Throughput Timer    5
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_sinr action\=deactivate profile_id\=1 scell\=0
# 
# 
# Block Cell1
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning
#     ...    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=administrativeState    operation=update    value=Locked
#     ...    skip_parameter_relation_errors=True    connection=online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait Throughput Timer    60
# 
# Unlock Cell1
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning
#     ...    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=administrativeState    operation=update    value=Unlocked
#     ...    skip_parameter_relation_errors=True    connection=online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait Throughput Timer    60
