# *** Settings ***
# Documentation     Author: wenchao.zhang@nokia-sbell.com
# ...
# ...               example case for RAN HZ L2 SW11. test step description in QC as below:
# ...
# ...               QC case full name:
# ...               CB007922_case2_D_3_Period_CSI_RS_transfermation_and_CSI_reception_on_PUSCH_mode_2_2
# ...
# ...               Period CSI-RS transmission and CSI reception for Pcell and Scell based on PUSCH
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
# ${CONFIG_DIR_PATH}    ../resources/sg11/internal_resource/config/
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      scfc_ASIK_ABIL_Cpri.xml
# ${AIRPHONE_NAME}    iphy_ASIK_ABIL_Cpri.xml
# ${WTS_NAME}       wts.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${MSG1}           itf_l2_ps_peerctrl_scellueschedulingreq
# ${MSG2}           itf_l2_ps_peerctrl_scellueschedulingresp
# ${FILTER1}        itf_l2_ps_peerctrl_ScellUeSchedulingReq.modifType.modifType_item_0
# ${FILTER2}        itf_l2_ps_peerctrl_ScellUeSchedulingResp.modifType.modifType_item_0
# ${carrierAggregationSupportList}     text|ca_Fr1Tdd_Sa|//list[@name\="carrierAggregationSupportList"]/p
# ${flexibleCAMode}                    text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}                   text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}                    text|false|//*[@name\="actBeamforming"]
# ${nrBtsBeamRefinementP2}             text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${numberOfTransmittedSsBlocks}       text|1 beam|//*[@name\="numberOfTransmittedSsBlocks"]
# ${basicBeamSet}                      text|beamSet_1|//*[@name\="basicBeamSet"]
# ${nrCellType}                        text|2DL2UL|//*[@name\="nrCellType"]
# ${cellDepType}                       text|SA+NSA|//*[@name\="cellDepType"]
# ${actCDrx}                           text|false|//*[@name\="actCDrx"]
# ${frameStructureType}                text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}                 text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}                 text|0ms|//*[@name\=""lteToNrFrameShift""]
# ${prachConfigurationIndex}           text|97|//*[@name\="prachConfigurationIndex"]
# ${ssBurstSetPeriod}                  text|20|//*[@name\="ssBurstSetPeriod"]
# ${sCellGoodChannelQualityThreshold}  text|8|//*[@name\="sCellGoodChannelQualityThreshold"]
# ${sCellBadChannelQualityThreshold}   text|4|//*[@name\="sCellBadChannelQualityThreshold"]
# ${sCellChannelEstimationPeriod}      text|2000|//*[@name\="sCellChannelEstimationPeriod"]
# ${sCellAdditionMethod}               text|blind|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}                    text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}                  text|true|//*[@name\="actFdmScheduling"]
# ${sCellDeactivationBadRlqCount}      text|0|//*[@name\="sCellDeactivationBadRlqCount"]
# ${sCellActivationMethod}             text|blind|//*[@name\="sCellActivationMethod"]
# ${actK1OptForDPA}                    text|true|//*[@name\="actK1OptForDPA"]
# ${sCellDeactivationTimerGNB}         text|infinity|//*[@name\="sCellDeactivationTimerGNB"]
# 
# 
# *** Test Cases ***
# CB007922_case2_D_3_Period_CSI_RS_transfermation_and_CSI_reception_on_PUSCH_mode_2_2
# 
#     Step1:Set parameter and wait for onair
#     Step2:UE attach to cell1
#     Step3:Push DL UL data to UE
#     Step4:Detach UE
# 
# *** Keywords ***
# Step1:Set parameter and wait for onair
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
# 	change_iphy_rru_version        ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
# 	modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
# 	${scfc_path}                Set Variable                    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
# 	copy_file          ${CONFIG_DIR_PATH}/${SCFC_NAME}     ${scfc_path}
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
# 	add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=1
# 	add_parameter_from_xml    xml_path=${scfc_path}    class_name=NRBTS     parameter=sCellActivationMethod     value=blind
# 	add_parameter_from_xml    xml_path=${scfc_path}    class_name=NRBTS     parameter=maxNumScellsDl     value=1
# 	${modify_list}      create list        ${carrierAggregationSupportList}
# 	...     ${pucchModeSelect}
# 	...     ${flexibleCAMode}
# 	...     ${actBeamforming}
#     ...     ${nrBtsBeamRefinementP2}
#     ...     ${numberOfTransmittedSsBlocks}
#     ...     ${basicBeamSet}
#     ...     ${nrCellType}
#     ...     ${cellDepType}
#     ...     ${actCDrx}
#     ...     ${frameStructureType}
#     ...     ${guardPeriodLength}
#     ...     ${prachConfigurationIndex}
#     ...     ${ssBurstSetPeriod}
#     ...     ${sCellGoodChannelQualityThreshold}
#     ...     ${sCellBadChannelQualityThreshold}
#     ...     ${sCellChannelEstimationPeriod}
#     ...     ${sCellAdditionMethod}
#     ...     ${actFdmScheduling}
#     ...     ${sCellDeactivationBadRlqCount}
# 	...     ${actK1OptForDPA} 
# 	...     ${sCellDeactivationTimerGNB} 
#     modify_xml  	    ${scfc_path}        ${scfc_path}         ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair
# 	...    ${scfc_path}
# 	...    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
# 	...    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2:UE attach to cell1
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
#     Start GNB BIP Log
#     Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     ${ue_ability}    Obtain Ue Capability    CA_disable_vonr_n78
#     Airphone SA Attach    ue_id=${UE_ID}       ue_capability=${ue_ability}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
# 	Wait Throughput Timer    10
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step2_ue_attach/output
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach' File
# 
# Step3:Push DL UL data to UE
#     Start Collect GNB and AP Syslog in 'step3_send_data' File
#     Start GNB BIP Log
#     Start AP BIP Log
#     Start GNB Ttitrace With Streaming Mode
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=5    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=6    pdu_id=${PDU_ID}    duration=${3600}
#     #Airphone SA Start Data Traffic    ${UE_ID}    UL    50M     trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Wait Throughput Timer    15
#     ${dl_tput}=    airphone_sa_get_throughput    ${UE_ID}    DL    ${PDU_ID}
#     #${ul_tput}=    airphone_sa_get_throughput    ${UE_ID}    UL    ${PDU_ID}
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_send_data
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step3_send_data/output
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}step3_send_data${/}
# 	${PM_counter_pcell_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
# 	...    counter_id=M55310C01006    cell_id=1
#     ${PM_counter_scell_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}
#     ...    counter_id=M55310C01006    cell_id=2
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_data${/}
#     Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_data${/}
# 	should be true    ${PM_counter_pcell_value}>0
# 	should be true    ${PM_counter_scell_value}>0
#     log    ${dl_tput}
#     #log    ${ul_tput}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_send_data' File
# 
# Step4:Detach UE
#     Start Collect GNB and AP Syslog in 'step4_detach' File
#     airphone_sa_stop_data_traffic    ${UE_ID}    DL    pdu_id=${PDU_ID}
# #    airphone_sa_stop_data_traffic    ${UE_ID}    UL    pdu_id=${PDU_ID}
#     airphone_sa_detach    ${UE_ID}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_detach' File
# 
# 
