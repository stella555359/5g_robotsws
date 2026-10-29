# *** Settings ***
# Documentation     Author: wenchao.zhang@nokia-sbell.com
# ...
# ...               example case for RAN HZ L2 SW11. test step description in QC as below:
# ...
# ...               QC case full name:
# ...               CB007922_case24_D_4_Multiple_UE_bufferBased_Activation_Deactivation_with_ABIL
# ...
# ...               This user scenario describes the successful UE connection setup with TDD FR1-TDD FR1 Carrier aggregation 
# ...               Within this sub-feature the same CA functionalities are verified with CPRI configuration
# 
# Test Timeout      60 minutes
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_KLL_AP_KLL_SANSA_L1B_CPRI_CMWV_TDD    5G_RAN_TDD    FR1    Owner_wenczhan    5G00    SBTS23R1
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}   ../resources/sg11/internal_resource/config/
# ${SLICE_ID}       1
# ${SCFC_NAME}      scfc_ASIK_ABIL_Cpri.xml
# ${AIRPHONE_NAME}    iphy_ASIK_ABIL_Cpri.xml
# ${WTS_NAME}       wts_mue.cfg
# &{GNBMIRRORINGCONFIG}    BB_SLOT_2='true'    SYSCOM_MIRRORING='true'   L2HI_MIRRORING='true'   L2RT_MIRRORING='true'   CPRT_MIRRORING='true'
# ...    NUMBER_OF_FILES=30
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${MSG1}           itf_l2_ps_peerctrl_scellueschedulingreq
# ${MSG2}           itf_l2_ps_peerctrl_scellueschedulingresp
# ${FILTER1}        itf_l2_ps_peerctrl_ScellUeSchedulingReq.modifType.modifType_item_0
# ${FILTER2}        itf_l2_ps_peerctrl_ScellUeSchedulingResp.modifType.modifType_item_0
# ${carrierAggregationSupportList}                text|ca_Fr1Tdd_Sa|//list[@name\="carrierAggregationSupportList"]/p
# ${actInterNumerologyCa}                         text|false|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}                               text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}                              text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}                               text|false|//*[@name\="actBeamforming"]
# ${nrBtsBeamRefinementP2}                        text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${numberOfTransmittedSsBlocks}                  text|1 beam|//*[@name\="numberOfTransmittedSsBlocks"]
# ${basicBeamSet}                                 text|beamSet_1|//*[@name\="basicBeamSet"]
# ${cellDepType}                                  text|SA+NSA|//*[@name\="cellDepType"]
# ${actCDrx}                                      text|false|//*[@name\="actCDrx"]
# ${frameStructureType}                           text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                            text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                            text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}                      text|97|//*[@name\="prachConfigurationIndex"]
# ${ssBurstSetPeriod}                             text|20|//*[@name\="ssBurstSetPeriod"]
# ${sCellChannelEstimationPeriod}                 text|2000|//*[@name\="sCellChannelEstimationPeriod"]
# ${actDl256Qam}                                  text|true|//*[@name\="actDl256Qam"]
# ${sCellAdditionMethod}                          text|blind|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}                               text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}                             text|true|//*[@name\="actFdmScheduling"]
# ${sCellDeactivationBadRlqCount}                 text|100|//*[@name\="sCellDeactivationBadRlqCount"]
# ${sCellActivationMethod}                        text|bufferAndRLQualityBased|//*[@name\="sCellActivationMethod"]
# ${sCellGoodChannelQualityThreshold}             text|18|//*[@name\="sCellGoodChannelQualityThreshold"]
# ${sCellBadChannelQualityThreshold}              text|14|//*[@name\="sCellBadChannelQualityThreshold"]
# ${a1MeasSCellAddEnabled}                        text|rsrp|//*[@name\="a1MeasSCellAddEnabled"]
# ${a1ThresholdSCellAddSsbRsrpTDD}                text|60|//*[@name\="a1ThresholdSCellAddSsbRsrpTDD"]
# ${actMeasBasedSCellAddition}                    text|true|//*[@name\="actMeasBasedSCellAddition"]
# ${actCarrierAggregation}                        text|false|//*[@name\="actCarrierAggregation"]
# ${caConfigurationSupport}                       text|none|//*[@name\="caConfigurationSupport"]
# ${sCellDeactivationTimerGNB}                    text|ms1280|//*[@name\="sCellDeactivationTimerGNB"]
# 
# *** Test Cases ***
# CB007922_case24_D_4_Multiple_UE_bufferBased_Activation_Deactivation_with_ABIL
# 
# 	step1:Set parameter and wait for onair 
#     step2:UE1/2 support CA and attach to TDD FR1 cell1
#     step3:UE3/4 support CA and attach to TDD FR1 cell3
#     step4:UE5/6 don't support CA and attach to cell1 
#     step5:UE7/8 don't support CA and attach to cell3 
#     step6:full buffer data transmission of the DRB bearer is started in DL and UL for all the Ues
#     step7:stop DL transmission for UE1/2/3/4 
#     step8:send DL transmission again for UE1/2/3/4 
#     step9:all UEs detached 
# 
# *** Keywords ***
# step1:Set parameter and wait for onair 
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
# 	change_iphy_rru_version        ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
# 	modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
# 	${scfc_path}                Set Variable           ${TEST_LOG_DIRECTORY()}${/}scfc.xml
# 	copy_file          ${CONFIG_DIR_PATH}/${SCFC_NAME}     ${scfc_path}
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=3
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=3    lcrid=1
# 	${modify_list}      create list        ${carrierAggregationSupportList}
#     ...       ${actInterNumerologyCa}
#     ...       ${flexibleCAMode}
#     ...       ${pucchModeSelect}
#     ...       ${actBeamforming}
#     ...       ${nrBtsBeamRefinementP2}
#     ...       ${numberOfTransmittedSsBlocks}
#     ...       ${basicBeamSet}
#     ...       ${cellDepType}
#     ...       ${actCDrx}
#     ...       ${frameStructureType}
#     ...       ${guardPeriodLength}
#     ...       ${lteToNrFrameShift}
#     ...       ${prachConfigurationIndex}
#     ...       ${ssBurstSetPeriod}
#     ...       ${sCellChannelEstimationPeriod}
#     ...       ${actDl256Qam}
#     ...       ${sCellAdditionMethod}
#     ...       ${maxNumScellsDl}
#     ...       ${actFdmScheduling}
#     ...       ${sCellDeactivationBadRlqCount}
#     ...       ${sCellActivationMethod}
#     ...       ${sCellGoodChannelQualityThreshold}
#     ...       ${sCellBadChannelQualityThreshold}
#     ...       ${a1MeasSCellAddEnabled}
#     ...       ${actMeasBasedSCellAddition}
#     ...       ${actCarrierAggregation}
#     ...       ${caConfigurationSupport}
#     ...       ${a1ThresholdSCellAddSsbRsrpTDD}
# 	...       ${sCellDeactivationTimerGNB}
#     modify_xml  	    ${scfc_path}        ${scfc_path}         ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair
# 	...    ${scfc_path}
# 	...    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
# 	...    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# step2:UE1/2 support CA and attach to TDD FR1 cell1
#     Start Collect GNB and AP Syslog in 'step2_ue12_attach' File
#     Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode	  
#     attach '1' to cell '1' use ue cap 'CA_disable_vonr_n78'
# 	attach '2' to cell '1' use ue cap 'CA_disable_vonr_n78'
# 	Wait Throughput Timer    10
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue12_attach    
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue12_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue12_attach${/}
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step2_ue12_attach/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue12_attach' File
# 
# step3:UE3/4 support CA and attach to TDD FR1 cell3
#     Start Collect GNB and AP Syslog in 'step3_ue34_attach' File
#     Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode	  
#     attach '3' to cell '3' use ue cap 'CA_disable_vonr_n78'
# 	attach '4' to cell '3' use ue cap 'CA_disable_vonr_n78'
# 	Wait Throughput Timer    10
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_ue34_attach
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step3_ue34_attach/output
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_ue34_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_ue34_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_ue34_attach' File
# 
# step4:UE5/6 don't support CA and attach to cell1
#     Start Collect GNB and AP Syslog in 'step4_ue56_attach' File
#     Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode	  
#     attach '5' to cell '1' use ue cap 'nr_common_cap'
# 	attach '6' to cell '1' use ue cap 'nr_common_cap'
# 	Wait Throughput Timer    10
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_ue56_attach
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step4_ue56_attach/output
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_ue56_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_ue56_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_ue56_attach' File
# 
# step5:UE7/8 don't support CA and attach to cell3 
#     Start Collect GNB and AP Syslog in 'step5_ue78_attach' File
#     Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode	  
#     attach '7' to cell '3' use ue cap 'nr_common_cap'
# 	attach '8' to cell '3' use ue cap 'nr_common_cap'
# 	Wait Throughput Timer    10
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step5_ue78_attach
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step5_ue78_attach/output
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_ue78_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_ue78_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step5_ue78_attach' File
# 	
# step6:full buffer data transmission of the DRB bearer is started in DL and UL for all the Ues
#     Start Collect GNB and AP Syslog in 'step6_send_data' File
#     Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone SA Start Data Traffic    1    DL    175M    trf_id=1    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    1    DL    175M    trf_id=2    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    2    DL    175M    trf_id=1    pdu_id=2    duration=${3600}
# 	Airphone SA Start Data Traffic    2    DL    175M    trf_id=2    pdu_id=2    duration=${3600}
# 	Airphone SA Start Data Traffic    3    DL    175M    trf_id=1    pdu_id=3    duration=${3600}
# 	Airphone SA Start Data Traffic    3    DL    175M    trf_id=2    pdu_id=3    duration=${3600}
# 	Airphone SA Start Data Traffic    4    DL    175M    trf_id=1    pdu_id=4    duration=${3600}
# 	Airphone SA Start Data Traffic    4    DL    175M    trf_id=2    pdu_id=4    duration=${3600}
# 	Airphone SA Start Data Traffic    5    DL    100M    trf_id=1    pdu_id=5    duration=${3600}
# 	Airphone SA Start Data Traffic    6    DL    100M    trf_id=1    pdu_id=6    duration=${3600}
# 	Airphone SA Start Data Traffic    7    DL    100M    trf_id=1    pdu_id=7    duration=${3600}
# 	Airphone SA Start Data Traffic    8    DL    100M    trf_id=1    pdu_id=8    duration=${3600}
#     Wait Throughput Timer    2
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step6_send_data
# 	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_send_data${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_send_data${/}
#     ${pcell_dl_tput_ue1}=    airphone_sa_get_throughput    1    DL    1
# 	${pcell_dl_tput_ue2}=    airphone_sa_get_throughput    2    DL    2
# 	${pcell_dl_tput_ue3}=    airphone_sa_get_throughput    3    DL    3
# 	${pcell_dl_tput_ue4}=    airphone_sa_get_throughput    4    DL    4
# 	${pcell_dl_tput_ue5}=    airphone_sa_get_throughput    5    DL    5
# 	${pcell_dl_tput_ue6}=    airphone_sa_get_throughput    6    DL    6
# 	${pcell_dl_tput_ue7}=    airphone_sa_get_throughput    7    DL    7
# 	${pcell_dl_tput_ue8}=    airphone_sa_get_throughput    8    DL    8
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}step6_send_data${/}
# 	${PM_counter_pcell_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55310C01006    cell_id=1
#     ${PM_counter_scell_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01006    cell_id=3
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step6_send_data/output
# 	should be true    ${PM_counter_pcell_value}>0
# 	should be true    ${PM_counter_scell_value}>0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step6_send_data' File
# 
# step7:stop DL transmission for UE1/2/3/4
# 	Start Collect GNB and AP Syslog in 'step7_stop_data' File
# 	Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
# 	airphone_sa_stop_data_traffic    1    DL    pdu_id=1
# 	airphone_sa_stop_data_traffic    2    DL    pdu_id=2
# 	airphone_sa_stop_data_traffic    3    DL    pdu_id=3
# 	airphone_sa_stop_data_traffic    4    DL    pdu_id=4
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step7_stop_data
# 	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step7_stop_data${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step7_stop_data${/}
# 	wait Throughput Timer    120
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}step7_stop_data${/}
# 	${PM_counter_pcell_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55310C01006    cell_id=1
#     ${PM_counter_scell_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01006    cell_id=3
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step7_stop_data/output
# 	should be true    ${PM_counter_pcell_value}==0
# 	should be true    ${PM_counter_scell_value}==0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step7_stop_data' File
# 
# step8:send DL transmission again for UE1/2/3/4
# 	Start Collect GNB and AP Syslog in 'step8_send_data' File
# 	Start GNB BIP Log
#     #Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
# 	Airphone SA Start Data Traffic    1    DL    175M    trf_id=1    pdu_id=1    duration=${3600}
# 	Airphone SA Start Data Traffic    1    DL    175M    trf_id=2    pdu_id=1    duration=${3600}
#     Airphone SA Start Data Traffic    2    DL    175M    trf_id=1    pdu_id=2    duration=${3600}
# 	Airphone SA Start Data Traffic    2    DL    175M    trf_id=2    pdu_id=2    duration=${3600}
# 	Airphone SA Start Data Traffic    3    DL    175M    trf_id=1    pdu_id=3    duration=${3600}
# 	Airphone SA Start Data Traffic    3    DL    175M    trf_id=2    pdu_id=3    duration=${3600}
# 	Airphone SA Start Data Traffic    4    DL    175M    trf_id=1    pdu_id=4    duration=${3600}
# 	Airphone SA Start Data Traffic    4    DL    175M    trf_id=2    pdu_id=4    duration=${3600}
# 	wait Throughput Timer    2
# 	${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step8_send_data
# 	Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step8_send_data${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step8_send_data${/}
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     Wait Throughput Timer    60
# 	${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}step8_send_data${/}
# 	${PM_counter_pcell_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55310C01006    cell_id=1
#     ${PM_counter_scell_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01006    cell_id=3
# 	Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step8_send_data/output
# 	should be true    ${PM_counter_pcell_value}>0
# 	should be true    ${PM_counter_scell_value}>0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step8_send_data' File
# 
# step9:all UEs detached 
#     Start Collect GNB and AP Syslog in 'step9_detach' File
#     airphone_sa_stop_data_traffic    1    DL    pdu_id=1
# 	airphone_sa_stop_data_traffic    2    DL    pdu_id=2
# 	airphone_sa_stop_data_traffic    3    DL    pdu_id=3
# 	airphone_sa_stop_data_traffic    4    DL    pdu_id=4
# 	airphone_sa_stop_data_traffic    5    DL    pdu_id=5
# 	airphone_sa_stop_data_traffic    6    DL    pdu_id=6
# 	airphone_sa_stop_data_traffic    7    DL    pdu_id=7
# 	airphone_sa_stop_data_traffic    8    DL    pdu_id=8
#     airphone_sa_detach    1
# 	airphone_sa_detach    2
# 	airphone_sa_detach    3
# 	airphone_sa_detach    4
# 	airphone_sa_detach    5
# 	airphone_sa_detach    6
# 	airphone_sa_detach    7
# 	airphone_sa_detach    8
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step9_detach' File
# 	
# attach '${UE_ID}' to cell '${CELL_ID}' use ue cap '${ue_cap}'
#     ${PDU_ID}    set variable     ${UE_ID}
# 	${GW_ID}    set variable     ${UE_ID}
# 	airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
# 	Airphone Location Change    id=${UE_ID}    cell_id=${CELL_ID}
# 	${ue_ability}    Obtain Ue Capability    ${ue_cap}
#     Airphone SA Attach    ue_id=${UE_ID}       ue_capability=${ue_ability}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
