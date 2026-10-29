# *** Settings ***
# Documentation     Author: zhaoyang.xu@nokia-sbell.com
# ...               QC case full name:
# ...               CB009198_B_B4_case107_Interaction_Voice_over_NR_enhancement_and_FR1_DFT_s_OFDM_
# ...               for_TDD_PUSCH_enable_VoNR_specific_DRX_profile_and_7922_TDD_DL_CA
# ...               TThis user scenario describes the gNB behaviour when feature 5G000545 is activated and TDD DL CA is enable
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
# ${SCFC_NAME}          gNB_scf_ASIL_ABIL_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC_CA.xml
# ${AIRPHONE_NAME}      AP_iphy_AEQE_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC_CA.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_2S_1CC_CA.cfg
# ${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
# @{LOG_NAME_LIST}      gnb_snapshot    sosreport    egatelog\
# #CB009198_parameters
# ${actUlDftSOfdm}                  text|true|//*[@name\="actUlDftSOfdm"]
# ${ulTransPrecodeOffSinrThresh}    text|150|//*[@name\="ulTransPrecodeOffSinrThresh"]
# ${ulTransPrecodeOnSinrThresh}     text|120|//*[@name\="ulTransPrecodeOnSinrThresh"]
# ${ulTransPrecodeOffSinrThrRedCap}    text|150|//*[@name\="ulTransPrecodeOffSinrThrRedCap"]
# ${ulTransPrecodeOnSinrThrRedCap}     text|120|//*[@name\="ulTransPrecodeOnSinrThrRedCap"]
# ${ulTransPrecodePi2Bpsk}          text|true|//*[@name\="ulTransPrecodePi2Bpsk"]
# ${actUlPtrs}                      text|true|//*[@name\="actUlPtrs"]
# ${ulPtrsFreqDensityThresNrb0}     text|278|//*[@name\="ulPtrsFreqDensityThresNrb0"]
# ${actUlDataDmrsFdm}               text|true|//*[@name\="actUlDataDmrsFdm"]
# #5GC001116_0ms
# ${frameStructureType}             text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}              text|6Symbols|//*[@name\="guardPeriodLength"]
# ${ulDlDataSlotRatio}              text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${lteToNrFrameShift}              text|3ms|//*[@name\="lteToNrFrameShift"]
# ${tdLteUlDlConfig}                text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${prachConfigurationIndex}        text|98|//*[@name\="prachConfigurationIndex"]
# 
# ${carrierAggregationSupportList}    text|ca_Fr1Tdd_Sa|//list[@name\="carrierAggregationSupportList"]/p
# ${chBw}                           text|80MHz|//*[@name\="chBw"]
# ${ulMimoMode}                     text|Closed loop Spatial Multiplexing (2x2)|//*[@name\="ulMimoMode"]
# 
# #CB007922 DL CA
# ${actCarrierAggregation}          text|true|//*[@name\="actCarrierAggregation"]
# ${caConfigurationSupport}          text|2CCDL_2CCUL|//*[@name\="caConfigurationSupport"]
# ${actInterNumerologyCa}           text|false|//*[@name\="actInterNumerologyCa"]
# ${sCellAdditionMethod}            text|blind|//*[@name\="sCellAdditionMethod"]
# ${sCellDeactivationTimerGNB}      text|infinity|//*[@name\="sCellDeactivationTimerGNB"]
# ${maxNumScellsDl}                 text|1|//*[@name\="maxNumScellsDl"]
# ${sCellActivationMethod}          text|blind|//*[@name\="sCellActivationMethod"]
# ${actMeasBasedSCellAddition}      text|true|//*[@name\="actMeasBasedSCellAddition"]
# ${a1MeasSCellAddEnabled}          text|rsrp|//*[@name\="a1MeasSCellAddEnabled"]
# ${sCellDeactivationBadRlqCount}    text|60|//*[@name\="sCellDeactivationBadRlqCount"]
# ${a1ThresholdSCellAddSsbRsrpTDD}    text|60|//*[@name\="a1ThresholdSCellAddSsbRsrpTDD"]
# ${sCellChannelEstimationPeriod}    text|2000|//*[@name\="sCellChannelEstimationPeriod"]
# 
# #CB006112_Voice over NR feature
# ${actCDrx}                         text|true|//*[@name\="actCDrx"]
# ${actCDrxVoNR}                     text|true|//*[@name\="actCDrxVoNR"]
# ${actVoNR}                         text|true|//*[@name\="actVoNR"]
# ${actEnhancedVoNR}                 text|true|//*[@name\="actEnhancedVoNR"]
# 
# 
# ${BWP_PROFILE-8}    text|MRBTS-1/NRBTS-1/BWP_PROFILE-8|//*[@name\='cellBwpList']/item[1]/*[@name\='bwpDN']
# ${BWP_PROFILE-85}    text|MRBTS-1/NRBTS-1/BWP_PROFILE-85|//*[@name\='cellBwpList']/item[2]/*[@name\='bwpDN']
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# 
# ${filter_1}    uldata_puschreceivereq
# @{titles_1}    3gpp.sfn    3gpp.slot    3gpp.rnti
# ...    UlData_puschReceiveReqGrant_t.puschTransformPrecoderFlag    UlData_puschReceiveReqGrant_t.mcs
# ...    UlData_puschReceiveReqGrant_t.modulationOrder    UlData_puschReceiveReqGrant_t.numOfLayers
# 
# #${ue_ability}     SA_VoNR_DRX_CA
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
# *** Test Cases ***
# CB009198_B_B4_case107_Interaction_Voice_over_NR_enhancement_and_FR1_DFT_s_OFDM_for_TDD_PUSCH_enable_VoNR_specific_DRX_profile_and_7922_TDD_DL_CA
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach ue1 to 5QI-1 with blind addition and activation scell
#     Step3:Send UE DL data traffic
#     Step4:Increase pathloss for UEs
# 	Step5:Check DFT-s-OFDM related PM counter
#     Step6:Decrease pathloss for UEs
# 	Step7:Release VONR and detach UE
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Capture GNB and AP Syslog in 'Step1' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
# 	#modify_swconfig_by_CB009198    ${CONFIG_DIR_PATH}/${SCFC_NAME}    Pi2BPSK
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_ca_relation_CB007922    ${scfc_path}
# 	add_vonr_extend_parameter_on_bts    xml_path=${scfc_path}
# 	add_drxprofile_list_in_cells    xml_path=${scfc_path}    profile_id=2
# 	...     drxInactivityTimer=4ms    drxLongCycle=40ms    drxOnDurationTimer=6ms    drxRetransTimerDl=0slot    drxRetransTimerUl=0slot	
#     ${modify_list}    create list
#     ...    ${actUlDftSOfdm}    ${ulTransPrecodeOffSinrThresh}    ${ulTransPrecodeOnSinrThresh}    ${ulTransPrecodePi2Bpsk} 
# 	...    ${ulTransPrecodeOffSinrThrRedCap}    ${ulTransPrecodeOnSinrThrRedCap}
#     ...    ${actUlPtrs}    ${ulPtrsFreqDensityThresNrb0}    ${actUlDataDmrsFdm}
#     ...    ${frameStructureType}    ${guardPeriodLength}    ${ulDlDataSlotRatio}    ${lteToNrFrameShift}
#     ...    ${lteToNrFrameShift}    ${tdLteUlDlConfig}    ${prachConfigurationIndex}
#     ...    ${carrierAggregationSupportList}     ${chBw}     ${ulMimoMode}
#     ...    ${actCarrierAggregation}    ${actInterNumerologyCa}    ${sCellAdditionMethod}    ${sCellDeactivationTimerGNB}
#     ...    ${maxNumScellsDl}    ${sCellActivationMethod}    ${actMeasBasedSCellAddition}    ${a1MeasSCellAddEnabled}
#     ...    ${sCellDeactivationBadRlqCount}     ${a1ThresholdSCellAddSsbRsrpTDD}    ${sCellChannelEstimationPeriod}
#     ...    ${actCDrx}    ${actCDrxVoNR}    ${actVoNR}    ${actEnhancedVoNR}    ${caConfigurationSupport}       
#     ...    ${BWP_PROFILE-8}     ${BWP_PROFILE-85}  
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step1' File
# 
# Step2:Attach ue1 to 5QI-1 with blind addition and activation scell
#     Start Capture GNB and AP Syslog in 'Step2' File
#     Attach Sa Ue With Capability    ${UE_ID}  
# 	Wait Throughput Timer    2
# 	Airphone Pdu Session Modify    qosflows_to_add=2    by=amf    pass_regexp=Created FiveQi:Qfi mapping fiveQi 5 qfi 2
# 	Wait Throughput Timer    5
# 	Airphone Pdu Session Modify    qosflows_to_add=3    by=amf    pass_regexp=Created FiveQi:Qfi mapping fiveQi 1 qfi 3
# 	Wait Throughput Timer    5
# 	airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=2 trf_id\=1 mbps\=1 dir\=dl seconds\=3600
# 	airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=3 trf_id\=1 mbps\=1 dir\=dl seconds\=3600
# 	check scell activated
#     [Teardown]    run_keyword_and_ignore_error    Stop Capture GNB and AP Syslog in 'Step2' File	
# 	
# check scell activated
#     Wait Throughput Timer    10s
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2${/}     unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/ini/Case107_ScellActivate.ini
#     ...        log_need_to_check=u    save_log_directory=${TEST_LOG_DIRECTORY()}/${/}Step2${/}	
# 	
# 	
# Step3:Send UE DL data traffic	
# 	Start Capture GNB and AP Syslog in 'Step3' File
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=1 mbps\=175 dir\=dl seconds\=3600
# 	airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=1 mbps\=100 dir\=ul seconds\=3600
#     Wait Throughput Timer    2
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=2 mbps\=175 dir\=dl seconds\=3600
# 	airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=2 mbps\=100 dir\=ul seconds\=3600
#     Wait Throughput Timer    2
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=3 mbps\=175 dir\=dl seconds\=3600
# 	airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=3 mbps\=100 dir\=ul seconds\=3600
# 	Wait Throughput Timer    2
#     airphone_execute_egate_command    trf_data_start ue\=1 pdu\=1 qfi\=1 trf_id\=4 mbps\=100 dir\=dl seconds\=3600	
# 	Wait Throughput Timer    30
#     ${Dl_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     run keyword and continue on failure    Should Be True    ${Dl_throughput_ue1} > 550000
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue1} > 120000
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step3
#    	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/CB009198_off_no_bler.ini    log_need_to_check=i    save_log_directory=${save_log}
#     Start GNB BIP Log
# 	Wait Throughput Timer    1
# 	Stop Gnb BIP Log    log_dir=${save_log}/
#     #Check CB009198 Flag Disable In Bip    ${save_log}/
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step3${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step3' File
# 
# Step4:Increase pathloss for UEs
#     Start Capture GNB and AP Syslog in 'Step4' File    
#     Decrease SINR To Trigger CB009198 Enabled    1    5
# 	Wait Throughput Timer    10
#     ${Dl_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     run keyword and continue on failure    Should Be True    ${Dl_throughput_ue1} > 550000
#     run keyword and continue on failure    Should Be True    ${Ul_throughput_ue1} > 8000	
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    2
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}${/}Step4
#    	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/ini/CB009198_on_no_dtx.ini    log_need_to_check=i    save_log_directory=${save_log}	
#    	Start GNB BIP Log
# 	Wait Throughput Timer    1
# 	Stop Gnb BIP Log    log_dir=${save_log}/
# 	#Check CB009198 Flag Enable In Bip    ${save_log}/
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step4${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step4' File
# 
# Step5:Check DFT-s-OFDM related PM counter
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${/}Step5${/}
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
# Step6:Decrease pathloss for UEs
#     Start Capture GNB and AP Syslog in 'Step6' File    
#     Increase SINR To Trigger CB009198 Disabled    1    5
# 	Wait Throughput Timer    10
#     ${Dl_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Ul_throughput_ue1} =    Airphone Sa Get Throughput    ue_id=1    direction=ul	
#     #run keyword and continue on failure    Should Be True    ${Dl_throughput_ue1} > 500000
#     #run keyword and continue on failure    Should Be True    ${Ul_throughput_ue1} > 100000		
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
# Step7:Release VONR and detach UE
#     Start Capture GNB and AP Syslog in 'Step7' File
#     Airphone Pdu Session Modify    qosflows_to_del=3    pass_regexp=Removed FiveQi:Qfi mapping fiveQi 1 qfi 3
#     Wait Throughput Timer    2
#     Airphone Pdu Session Modify    qosflows_to_del=2    pass_regexp=Removed FiveQi:Qfi mapping fiveQi 5 qfi 2
#     Wait Throughput Timer    2	
#     Detach '1'UE
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step7${/}   unzip=TRUE
#     [Teardown]    run keyword and continue on failure    Stop Capture GNB and AP Syslog in 'Step7' File
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
#     airphone_execute_egate_command    ue_testmode_set_nr id\=${ue_id} testmode\=ul_sinr action\=deactivate profile_id\=1 scell\=0
# 
# add_ca_relation_CB007922
#     [Arguments]    ${scfc_path}
# 	comment  cell1 and cell2 is intra cell
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
# 	
# Attach Sa Ue With Capability
#     [Arguments]    ${ue_id}
#     Airphone SA Attach    ue_id=${ue_id}
#     airphone_set_traffic_type    ${ue_id}    1    internal
#     Airphone Pdu Session Setup    ${ue_id}    1    1    ${ue_id}
#     Wait '2s' for stable running	