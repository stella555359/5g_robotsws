# *** Settings ***
# Documentation     Author: zhaoyang.xu@nokia-sbell.com
# ...               QC case full name:
# ...               CB009198_A_B4_case105_Dynamic_Transform_Precoder_Switching,_SA_and_TDD_FR1,_no_PTRS_RRC_reestablish
# ...               This case is to verify gNB behavior when feature 5G000545 is activated without PTRS and reestablish is triggered
# ...               The cases initail test in ASIL ,cloud change to ASIB ,BIP log is change ,so BIP log check change to TTItrace log
# 
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
# ${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# @{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
# #CB009198_parameters
# ${actUlDftSOfdm}                  text|true|//*[@name\="actUlDftSOfdm"]
# ${ulTransPrecodeOffSinrThresh}    text|120|//*[@name\="ulTransPrecodeOffSinrThresh"]
# ${ulTransPrecodeOnSinrThresh}     text|100|//*[@name\="ulTransPrecodeOnSinrThresh"]
# ${ulTransPrecodeOffSinrThrRedCap}    text|120|//*[@name\="ulTransPrecodeOffSinrThrRedCap"]
# ${ulTransPrecodeOnSinrThrRedCap}     text|100|//*[@name\="ulTransPrecodeOnSinrThrRedCap"]
# ${ulTransPrecodePi2Bpsk}          text|true|//*[@name\="ulTransPrecodePi2Bpsk"]
# ${ulTransPrePi2BpskPwrBoost}      text|true|//*[@name\="ulTransPrePi2BpskPwrBoost"]
# ${actUlPtrs}                      text|false|//*[@name\="actUlPtrs"]
# ${actUlDataDmrsFdm}               text|true|//*[@name\="actUlDataDmrsFdm"]
# ${ulDataDmrsFdmThres256QamMcs}    text|20|//*[@name\="ulDataDmrsFdmThres256QamMcs"]
# ${ulDataDmrsFdmThres64QamMcs}     text|20|//*[@name\="ulDataDmrsFdmThres64QamMcs"]
# #5GC001116_0ms
# ${frameStructureType}          text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}           text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}           text|3/7|//*[@name\="ulDlDataSlotRatio"]
# ${tdLteUlDlConfig}             text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${prachConfigurationIndex}    text|98|//*[@name\="prachConfigurationIndex"]
# 
# ${chBw}    text|100MHz|//*[@name\="chBw"]
# ${ulMimoMode}    text|Closed loop Spatial Multiplexing (2x2)|//*[@name\="ulMimoMode"]
# ${BWP_PROFILE-6}    text|MRBTS-1/NRBTS-1/BWP_PROFILE-6|//*[@name\='cellBwpList']/item[1]/*[@name\='bwpDN']
# ${BWP_PROFILE-67}    text|MRBTS-1/NRBTS-1/BWP_PROFILE-67|//*[@name\='cellBwpList']/item[2]/*[@name\='bwpDN']
# 
# #${ue_cap_pattern}    PTRS enable DFT-s-OFDM enabled UE NR 
#     
# ${filter_1}    uldata_puschreceivereq
# @{titles_1}    3gpp.sfn    3gpp.slot    3gpp.rnti
# ...    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag    UlData_puschReceiveReqGrant_t.mcs
# ...    UlData_puschReceiveReqGrant_t.modulationOrder    UlData_puschReceiveReqGrant_t.numOfLayers
# 
# *** Test Cases ***
# CB009198_A_B4_case105_Dynamic_Transform_Precoder_Switching_SA_and_TDD_FR1_no_PTRS_RRC_reestablish
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach UEs and send UL data
#     Step3:Increase pathloss for UEs
#     Step4:Increase pathloss for UE1 to RRC release
# 	Step5:Decrease pathloss for UE to RRC reestablish
#     Ste6:Decrease passloss for UE to disable CB009198
# 	Step7:Detach All UEs
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
# 	#modify_swconfig_by_CB009198    ${CONFIG_DIR_PATH}/${SCFC_NAME}    Pi2BPSK
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_vonr_extend_parameter_on_bts    xml_path=${scfc_path}
# 	del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
#     ${modify_list}    create list
#     ...    ${actUlDftSOfdm}    ${ulTransPrecodeOffSinrThresh}    ${ulTransPrecodeOnSinrThresh}    
# 	...    ${ulTransPrecodeOffSinrThrRedCap}    ${ulTransPrecodeOnSinrThrRedCap}    
# 	...    ${ulTransPrecodePi2Bpsk}    ${ulTransPrePi2BpskPwrBoost}
#     ...    ${actUlPtrs}    ${actUlDataDmrsFdm}
#     ...    ${frameStructureType}     ${guardPeriodLength}    ${ulDlDataSlotRatio}    ${tdLteUlDlConfig}
#     ...    ${prachConfigurationIndex}    ${chBw}    ${ulMimoMode}    ${BWP_PROFILE-6}    ${BWP_PROFILE-67}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step1' File
# 
# Step2:Attach UEs and send UL data
#     Start Capture GNB and AP Syslog in 'Step2' File
#     Attach Sa Ue With Capability    1 	
#     Airphone SA Start Data Traffic    1    UL    120M    trf_id=1    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    1    DL    150M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    1    UL    120M    trf_id=2    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    1    DL    150M    trf_id=2    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    1    UL    120M    trf_id=3    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    1    DL    150M    trf_id=3    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    1    DL    150M    trf_id=4    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    1    DL    150M    trf_id=5    pdu_id=1    duration=${3600}	
# 	Wait Throughput Timer    30
#     ${Dl_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul	
# 	${Ul_throughput_ue} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=0    type=pusch    tput_type=ave  
#     run keyword and continue on failure    Should Be True    ${Dl_throughput_ue1} > 630000
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue} > 230000
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
#     Decrease SINR To Trigger CB009198 Enabled    1    5
#     Wait Throughput Timer    5
#     ${Dl_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul	
#     run keyword and continue on failure    Should Be True    ${Dl_throughput_ue1} > 630000
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue1} > 20000    
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step3
#    	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/CB009198_on_no_dtx.ini    log_need_to_check=i    save_log_directory=${save_log}
#    	Start GNB BIP Log
# 	Wait Throughput Timer    1
# 	Stop Gnb BIP Log    log_dir=${save_log}/
# 	#Check CB009198 Flag Enable In Bip    ${save_log}/
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step3${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3' File
# 
# Step4:Increase pathloss for UE1 to RRC release
#     Start Capture GNB and AP Syslog in 'Step4' File    
#     Increase Pathloss To Trigger UE release    1    1
# 
# 
# Step5:Decrease pathloss for UE to RRC reestablish   
#     Decrease Pathloss To Trigger UE reestablish    1   1
#     Wait Throughput Timer    2
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step4${/}   unzip=TRUE		    
# 	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step4
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#    	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/CB009198_on_no_dtx.ini    log_need_to_check=i    save_log_directory=${save_log}	
# 	Start GNB BIP Log
# 	Wait Throughput Timer    1
# 	Stop Gnb BIP Log    log_dir=${save_log}/
# 	#Check CB009198 Flag Enable In Bip    ${save_log}/
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4' File
# 
# 
# 
# Ste6:Decrease passloss for UE to disable CB009198
#     Start Capture GNB and AP Syslog in 'Step6' File    
#     Increase SINR To Trigger CB009198 Disabled    1    4
#     Wait Throughput Timer    10
#     ${Dl_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     #${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul	
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul 	
# 	${Ul_throughput_ue} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=0    type=pusch    tput_type=ave 	
#     run keyword and continue on failure    Should Be True    ${Dl_throughput_ue1} > 630000
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue} > 220000 	
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step6
#    	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/CB009198_off_no_bler.ini    log_need_to_check=i    save_log_directory=${save_log}	
#    	Start GNB BIP Log
# 	Wait Throughput Timer    1
# 	Stop Gnb BIP Log    log_dir=${save_log}/
# 	#Check CB009198 Flag Disable In Bip    ${save_log}/
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step6${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step6' File
# 
# 
# Step7:Detach All UEs
#     Detach '1'UE
#     Wait Throughput Timer    60
#     Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
# 
# Attach Sa Ue With Capability
#     [Arguments]    ${ue_id}
#     Airphone SA Attach    ue_id=${ue_id}
#     airphone_set_traffic_type    ${ue_id}    1    internal
#     Airphone Pdu Session Setup    ${ue_id}    1    1    ${ue_id}
#     Wait '2s' for stable running
# 
# 
# Check CB009198 Flag Enable In Bip
#     [Arguments]    ${log_dir}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_1:0.pcap0    ${log_dir}/CB009198_bip.csv    ${filter_1}    ${titles_1}
#     run keyword and continue on failure    Check Log With Au2anlysis
#     ...    ini_path=${CURDIR}/ini/CB009198_enable_flag.ini     log_need_to_check=i    save_log_directory=${log_dir}
# 
# Check CB009198 Flag Disable In Bip
#     [Arguments]    ${log_dir}
#     Convert BIP To CSV    ${log_dir}/tcpdump_L2L1_bip_filtering_1:0.pcap0    ${log_dir}/CB009198_bip.csv    ${filter_1}    ${titles_1}
#     run keyword and continue on failure    Check Log With Au2anlysis
#     ...    ini_path=${CURDIR}/ini/CB009198_disable_flag.ini     log_need_to_check=i    save_log_directory=${log_dir}
# 
# 
# Decrease SINR To Trigger CB009198 Enabled
#     [Arguments]    ${ue_id}=1     ${max_num_pathloss}=5
#     ${sinr_target_pathloss} =    Set Variable    58
#     : For    ${index_time}    IN RANGE    1    ${max_num_pathloss}+1
#     \    ${sinr_target_pathloss} =    Evaluate    ${sinr_target_pathloss}+10
# 	\    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=${sinr_target_pathloss}
# 	\    airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
#     \    Wait Throughput Timer    5
# 
# Increase SINR To Trigger CB009198 Disabled
#     [Arguments]    ${ue_id}=1     ${max_num_pathloss}=5
#     ${sinr_target_pathloss} =    Set Variable    100
#     : For    ${index_time}    IN RANGE    1    ${max_num_pathloss}+1
#     \    ${sinr_target_pathloss} =    Evaluate    ${sinr_target_pathloss}-10
# 	\    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=${sinr_target_pathloss}
# 	\    airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
#     \    Wait Throughput Timer    5
#    airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_sinr action\=deactivate profile_id\=1 scell\=0
# 
# Increase Pathloss To Trigger UE release
#     [Arguments]    ${ue_id}=1     ${max_num_pathloss}=2
#     ${sinr_target_pathloss} =    Set Variable    105
#     : For    ${index_time}    IN RANGE    1    ${max_num_pathloss}+1
#     \    ${sinr_target_pathloss} =    Evaluate    ${sinr_target_pathloss}+10
# 	\    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=${sinr_target_pathloss}
# 	\    airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
#     \    Wait Throughput Timer    1
# 
# Decrease Pathloss To Trigger UE reestablish
#     [Arguments]    ${ue_id}=1     ${max_num_pathloss}=5
#     ${sinr_target_pathloss} =    Set Variable    115
#     : For    ${index_time}    IN RANGE    1    ${max_num_pathloss}+1
#     \    ${sinr_target_pathloss} =    Evaluate    ${sinr_target_pathloss}-10
# 	\    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=${sinr_target_pathloss}
# 	\    airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
#     \    Wait Throughput Timer    1
# 	