# *** Settings ***
# Documentation     Author: mao.qin@nokia-sbell.com
# ...               QC case full name:
# ...               CB009198_B_B10_case110_PUSCH_mapping_type_A_co_existence_with_DFT_s_OFDM_with_PTRS_for_ABIL_TDD_DFT_s_OFDM_online_change
# ...               This case is to verify gNB behavior when CB009198 interwork with CB007782(PUSCH mapping Type A), and DMRS is active.
# ...               And verify gNb behavior when online enable or disable CB009198.
# ...               The cases initail test in ASIL ,cloud change to ASIB ,BIP log is change ,so BIP log check change to TTItrace log
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# #Test Teardown    Common Test Teardown
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
# 
# ${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# @{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
# #CB009198_parameters
# ${actUlDftSOfdm}                  text|true|//*[@name\="actUlDftSOfdm"]
# ${ulTransPrecodeOffSinrThresh}    text|150|//*[@name\="ulTransPrecodeOffSinrThresh"]
# ${ulTransPrecodeOnSinrThresh}     text|120|//*[@name\="ulTransPrecodeOnSinrThresh"]
# ${ulTransPrecodeOffSinrThrRedCap}    text|150|//*[@name\="ulTransPrecodeOffSinrThrRedCap"]
# ${ulTransPrecodeOnSinrThrRedCap}     text|120|//*[@name\="ulTransPrecodeOnSinrThrRedCap"]
# ${ulTransPrecodePi2Bpsk}          text|true|//*[@name\="ulTransPrecodePi2Bpsk"]
# #UlPtrs
# ${actUlPtrs}                     text|true|//*[@name\="actUlPtrs"]
# ${ulPtrsFreqDensityThresNrb0}    text|278|//*[@name\="ulPtrsFreqDensityThresNrb0"]
# ${ulPtrsFreqDensityThresNrb1}    text|24|//*[@name\="ulPtrsFreqDensityThresNrb1"]
# #5GC001116_3ms
# ${frameStructureType}            text|semiStatic|//*[@name\="frameStructureType"]
# ${guardPeriodLength}             text|2Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}             text|3/7|//*[@name\="ulDlDataSlotRatio"]
# ${tdLteUlDlConfig}               text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${prachConfigurationIndex}       text|98|//*[@name\="prachConfigurationIndex"]
# #basic_parameters
# ${chBw}                          text|60MHz|//*[@name\="chBw"]
# ${ulMimoMode}                    text|Closed loop Spatial Multiplexing (2x2)|//*[@name\="ulMimoMode"]
# ${puschMappingType}              text|TypeA|//*[@name\="puschMappingType"]
# ${actAperCsi}                    text|false|//*[@name\="actAperCsi"]
# ${actUl256Qam}                   text|false|//*[@name\="actUl256Qam"]
# #UlDmrs
# ${ulDMRSAdditionalPosition}      text|Automatic|//*[@name\="ulDMRSAdditionalPosition"]
# ${dmrsTypeAPosition}             text|pos3|//*[@name\="dmrsTypeAPosition"]
# ${actUlDataDmrsFdm}              text|true|//*[@name\="actUlDataDmrsFdm"]
# ${ulDataDmrsFdmThres64QamMcs}    text|20|//*[@name\="ulDataDmrsFdmThres64QamMcs"]
# ${ulDataDmrsFdmThres256QamMcs}    text|20|//*[@name\="ulDataDmrsFdmThres256QamMcs"]
# #BWP_CONFIG
# ${BWP_PROFILE-6}               text|MRBTS-1/NRBTS-1/BWP_PROFILE-6|//*[@name\='cellBwpList']/item[1]/*[@name\='bwpDN']
# ${BWP_PROFILE-63}              text|MRBTS-1/NRBTS-1/BWP_PROFILE-63|//*[@name\='cellBwpList']/item[2]/*[@name\='bwpDN']
# 
# #${ue_cap_pattern}    PTRS enable DFT-s-OFDM enabled UE NR 
# ${filter_1}    uldata_puschreceivereq
# 
# @{titles_1}    3gpp.sfn    3gpp.slot    3gpp.rnti
# ...    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag    UlData_puschReceiveReqGrant_t.mcs
# ...    UlData_puschReceiveReqGrant_t.modulationOrder    UlData_puschReceiveReqGrant_t.numOfLayers
# 
# 
# @{PUSCH_initial_DFT-s-OFDM_PM}    M55302C06000    M55302C06001    M55302C06002    M55302C06003    M55302C06004   M55302C06005
# ...    M55302C06006    M55302C06007    M55302C06008    M55302C06009    M55302C06010    M55302C06011    M55302C06012
# ...    M55302C06013    M55302C06014    M55302C06015    M55302C06016    M55302C06017    M55302C06018    M55302C06019
# ...    M55302C06020    M55302C06021    M55302C06022    M55302C06023    M55302C06024    M55302C06025    M55302C06026
# ...    M55302C06027
# @{Success_initial_Tx_DFTsOFDM_PM}    M55302C08000    M55302C08001    M55302C08002    M55302C08003    M55302C08004    M55302C08005
# ...    M55302C08006    M55302C08007    M55302C08008    M55302C08009    M55302C08010    M55302C08011    M55302C08012
# ...    M55302C08013    M55302C08014    M55302C08015    M55302C08016    M55302C08017    M55302C08018    M55302C08019
# ...    M55302C08020    M55302C08021    M55302C08022    M55302C08023    M55302C08024    M55302C08025    M55302C08026
# ...    M55302C08027
# @{Successful_any_Tx_with_DFTsOFDM}    M55302C09000    M55302C09001    M55302C09002    M55302C09003    M55302C09004
# ...    M55302C09005    M55302C09006    M55302C09007    M55302C09008    M55302C09009    M55302C09010    M55302C09011
# ...    M55302C09012    M55302C09013    M55302C09014    M55302C09015    M55302C09016    M55302C09017    M55302C09018
# ...    M55302C09019    M55302C09020    M55302C09021    M55302C09022    M55302C09023    M55302C09024    M55302C09025
# ...    M55302C09026    M55302C09027
# @{Unsuccessful_HARQ_reTx_with_DFTsOFDM}    M55302C07000    M55302C07001    M55302C07002    M55302C07003    M55302C07004
# ...    M55302C07005    M55302C07006    M55302C07007    M55302C07008    M55302C07009    M55302C07010    M55302C07011
# ...    M55302C07012    M55302C07013    M55302C07014    M55302C07015    M55302C07016    M55302C07017    M55302C07018
# ...    M55302C07019    M55302C07020    M55302C07021    M55302C07022    M55302C07023    M55302C07024    M55302C07025
# ...    M55302C07026    M55302C07027
# 
# 
# 
# *** Test Cases ***
# CB009198_B_B10_case110_PUSCH_mapping_type_A_co_existence_with_DFT_s_OFDM_with_PTRS_for_ABIL_TDD_DFT_s_OFDM_online_change
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach UEs and send UL data
#     Step3:Increase pathloss for UEs
#     Step4:Decrease pathloss for UEs
# 	Step5:Online change actUlDftSOfdm to false
# 	Step6:Attach UEs again and send UL data
# 	Step7:Increase pathloss for UEs
# 	Step8:Online change actUlDftSOfdm to true
# 	Step9:Attach UEs again and send UL data
# 	Step10:Increase pathloss for UEs
#     Step11:Check DFT-s-OFDM related PM counter
# 	Step12:Detach All UEs
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
#     del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift	
#     ${modify_list}    create list
#     ...    ${actUlDftSOfdm}    ${ulTransPrecodeOffSinrThresh}    ${ulTransPrecodeOnSinrThresh}    ${ulTransPrecodePi2Bpsk}
# 	...    ${ulTransPrecodeOffSinrThrRedCap}    ${ulTransPrecodeOnSinrThrRedCap}
#     ...    ${actUlPtrs}    ${ulPtrsFreqDensityThresNrb0}    ${ulPtrsFreqDensityThresNrb1}
#     ...    ${frameStructureType}    ${guardPeriodLength}     ${ulDlDataSlotRatio}
#     ...    ${tdLteUlDlConfig}    ${prachConfigurationIndex} 
#     ...    ${chBw}     ${ulMimoMode}    ${puschMappingType}    ${actAperCsi}    ${actUl256Qam}
#     ...    ${ulDMRSAdditionalPosition}    ${dmrsTypeAPosition}    ${actUlDataDmrsFdm}
#     ...    ${ulDataDmrsFdmThres64QamMcs}    ${ulDataDmrsFdmThres256QamMcs}
#     ...    ${BWP_PROFILE-6}    ${BWP_PROFILE-63}  
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
# 	Airphone SA Start Data Traffic    1    UL    120M    trf_id=2    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    1    DL    150M    trf_id=2    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    1    DL    100M    trf_id=3    pdu_id=1    duration=${3600}	
# 	Wait Throughput Timer    30
#     ${Dl_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=0    type=pusch    tput_type=ave
#     run keyword and continue on failure    Should Be True    ${Dl_throughput_ue1} > 350000
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue} > 132000
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step2
#    	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/CB009198_off_no_bler.ini    log_need_to_check=i    save_log_directory=${save_log}
#     Start GNB BIP Log
# 	Wait Throughput Timer    2
# 	Stop Gnb BIP Log    log_dir=${save_log}/
#     #Check CB009198 Flag Disable In Bip    ${save_log}/
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step2' File
# 
# Step3:Increase pathloss for UEs
#     Start Capture GNB and AP Syslog in 'Step3' File    
#     Decrease SINR To Trigger CB009198 Enabled    1    5
# 	Wait Throughput Timer    10
# 	${Dl_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     run keyword and continue on failure    Should Be True    ${Dl_throughput_ue1} > 350000
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue1} > 14000	
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step3
#    	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/CB009198_on_no_dtx.ini    log_need_to_check=i    save_log_directory=${save_log}
#    	Start GNB BIP Log
# 	Wait Throughput Timer    2
# 	Stop Gnb BIP Log    log_dir=${save_log}/
# 	#Check CB009198 Flag Enable In Bip    ${save_log}/
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step3${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3' File
# 
# Step4:Decrease pathloss for UEs
#     Start Capture GNB and AP Syslog in 'Step4' File    
#     Increase SINR To Trigger CB009198 Disabled    1    5
#  	Wait Throughput Timer    10
# 	${Dl_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=0    type=pusch    tput_type=ave	
#     run keyword and continue on failure    Should Be True    ${Dl_throughput_ue1} > 350000
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue} > 130000		
# 	Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step4
#    	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/CB009198_off_no_bler.ini    log_need_to_check=i    save_log_directory=${save_log}	
#    	Start GNB BIP Log
# 	Wait Throughput Timer    2
# 	Stop Gnb BIP Log    log_dir=${save_log}/
# 	#Check CB009198 Flag Disable In Bip    ${save_log}/
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step4${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4' File
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
# Step6:Attach UEs again and send UL data
#     Start Capture GNB and AP Syslog in 'Step6' File
#     Attach Sa Ue With Capability    1
#     Airphone SA Start Data Traffic    1    UL    120M    trf_id=1    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    1    DL    150M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    1    UL    120M    trf_id=2    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    1    DL    150M    trf_id=2    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    1    DL    100M    trf_id=3    pdu_id=1    duration=${3600}	
# 	Wait Throughput Timer    30
#     ${Dl_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=0    type=pusch    tput_type=ave	
#     run keyword and continue on failure    Should Be True    ${Dl_throughput_ue1} > 350000
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue} > 130000		
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step6
#    	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/CB009198_off_no_bler.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step6${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step6' File
# 
# Step7:Increase pathloss for UEs
#     Start Capture GNB and AP Syslog in 'Step7' File    
#     Decrease SINR To Trigger CB009198 Enabled    1    5
# 	Wait Throughput Timer    10
# 	${Dl_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     run keyword and continue on failure    Should Be True    ${Dl_throughput_ue1} > 350000
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue1} > 30000		
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step7
#    	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/CB009198_actUlDftSOfdm_to_false.ini    log_need_to_check=i    save_log_directory=${save_log}	
#    	Start GNB BIP Log
# 	Wait Throughput Timer    2
# 	Stop Gnb BIP Log    log_dir=${save_log}/
# 	#Check CB009198 Flag Disable In Bip    ${save_log}/
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step7${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step7' File
# 	
# 	
# Step8:Online change actUlDftSOfdm to true	
#     Start Capture GNB and AP Syslog in 'Step8' File
# 	Increase SINR To Trigger CB009198 Disabled    1    5
# 	Wait Throughput Timer    5
#     Online recommissioning with delta json file    ${CURDIR}/JSON/actUlDftSOfdm_to_true.json
#     Block Cell1
#     Unlock Cell1
#     Wait until keyword succeeds    1500s    60s    Verify BTS Is Onair
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step8${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step8' File	
# 	
# Step9:Attach UEs again and send UL data
#     Start Capture GNB and AP Syslog in 'Step9' File
#     Attach Sa Ue With Capability    1
#     Airphone SA Start Data Traffic    1    UL    120M    trf_id=1    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    1    DL    150M    trf_id=1    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    1    UL    120M    trf_id=2    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    1    DL    150M    trf_id=2    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    1    DL    150M    trf_id=3    pdu_id=1    duration=${3600}	
# 	Wait Throughput Timer    20
#     ${Dl_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=0    type=pusch    tput_type=ave	
#     run keyword and continue on failure    Should Be True    ${Dl_throughput_ue1} > 350000
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue} > 130000		
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step9
#    	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/CB009198_off_no_bler.ini    log_need_to_check=i    save_log_directory=${save_log}
# 	airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step9${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step9' File
# 
# Step10:Increase pathloss for UEs
#     Start Capture GNB and AP Syslog in 'Step10' File    
#     Decrease SINR To Trigger CB009198 Enabled    1    5
# 	Wait Throughput Timer    10
# 	${Dl_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     ${Ul_throughput_ue} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=0    type=pusch    tput_type=ave	
#     run keyword and continue on failure    Should Be True    ${Dl_throughput_ue1} > 350000
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue} > 14000		
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step10
#    	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/CB009198_on_no_dtx.ini    log_need_to_check=i    save_log_directory=${save_log}	
#    	Start GNB BIP Log
# 	Wait Throughput Timer    2
# 	Stop Gnb BIP Log    log_dir=${save_log}/
# 	#Check CB009198 Flag Enable In Bip   ${save_log}/
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step10${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step10' File
# 	
# 
# 	
# Step11:Check DFT-s-OFDM related PM counter
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}Step11${/}
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
# 
# Step12:Detach All UEs
#     Increase SINR To Trigger CB009198 Disabled    1    5
#     Detach '1'UE
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
#     ${sinr_target_pathloss} =    Set Variable    60
#     : For    ${index_time}    IN RANGE    1    ${max_num_pathloss}+1
#     \    ${sinr_target_pathloss} =    Evaluate    ${sinr_target_pathloss}+10
# 	\    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=${sinr_target_pathloss}
# 	\    airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
#     \    Wait Throughput Timer    5
# 
# Increase SINR To Trigger CB009198 Disabled
#     [Arguments]    ${ue_id}=1     ${max_num_pathloss}=5
#     ${sinr_target_pathloss} =    Set Variable    110
#     : For    ${index_time}    IN RANGE    1    ${max_num_pathloss}+1
#     \    ${sinr_target_pathloss} =    Evaluate    ${sinr_target_pathloss}-10
# 	\    airphone_execute_egate_command    ul_sinr_testmode_nr profile_id\=1 pathloss\=${sinr_target_pathloss}
# 	\    airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_sinr action\=activate profile_id\=1 scell\=0
#     \    Wait Throughput Timer    5
# 	airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_sinr action\=deactivate profile_id\=1 scell\=0
# 
# 
# Block Cell1
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning
#     ...    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=administrativeState    operation=update    value=Locked
#     ...    skip_parameter_relation_errors=True    connection=online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait Throughput Timer    15
# 
# Unlock Cell1
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning
#     ...    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=administrativeState    operation=update    value=Unlocked
#     ...    skip_parameter_relation_errors=True    connection=online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait Throughput Timer    60
