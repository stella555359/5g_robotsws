# *** Settings ***
# Documentation    Author: jing.pan@nokia-sbell.com
# ...
# ...               example case for RAN HZ L2 SW11. test step description in QC as below:
# ...
# ...               QC case full name:
# ...               CB007922_case8_D_3_Online_modification_of_CA_Relationship
# ...
# ...               Online modification of CA Relationship does not affect already connected UE
# 
# Test Timeout      60 minutes
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags    CLOUD_5G_I_KL_AP_KL_SANSA_L1B_CPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    CRT    SBTS00    SBTS22R2    SBTS22R3    SBTS23R1
# Resource    ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Library     taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}        gNB_scf_ASIK_ABIL_TDD_CPRI_cmwv_SANSA_L1b_1S_2CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQA_ASIK_ABIL_TDD_CPRI_cmwv_SANSA_L1b_1S_2CC.xml
# ${WTS_NAME}         wts_config_ASIK_ABIL_TDD_CPRI_cmwv_SANSA_L1b_1S_2CC.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${MSG1}           itf_l2_ps_peerctrl_scellueschedulingreq
# ${MSG2}           itf_l2_ps_peerctrl_scellueschedulingresp
# ${FILTER1}        itf_l2_ps_peerctrl_ScellUeSchedulingReq.modifType.modifType_item_0
# ${FILTER2}        itf_l2_ps_peerctrl_ScellUeSchedulingResp.modifType.modifType_item_0
# ${carrierAggregationSupportList}     text|ca_Fr1Tdd_Sa|//list[@name\="carrierAggregationSupportList"]/p
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
# ${lteToNrFrameShift}                 text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}           text|97|//*[@name\="prachConfigurationIndex"]
# ${ssBurstSetPeriod}                  text|20|//*[@name\="ssBurstSetPeriod"]
# ${sCellGoodChannelQualityThreshold}  text|18|//*[@name\="sCellGoodChannelQualityThreshold"]
# ${sCellBadChannelQualityThreshold}   text|14|//*[@name\="sCellBadChannelQualityThreshold"]
# ${sCellChannelEstimationPeriod}      text|2000|//*[@name\="sCellChannelEstimationPeriod"]
# ${sCellAdditionMethod}               text|blind|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}                    text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}                  text|true|//*[@name\="actFdmScheduling"]
# ${sCellDeactivationBadRlqCount}      text|0|//*[@name\="sCellDeactivationBadRlqCount"]
# ${sCellActivationMethod}             text|bufferBased|//*[@name\="sCellActivationMethod"]
# 
# *** Test Cases ***
# CB007922_case8_D_3_Online_modification_of_CA_Relationship
#     Step1 :gNB is onair with the configuration
#     Step2 :Attach UE1 to TDD FR1 cell
#     Step3 :UE1 do UL DL data transfer
#     Step4 :Change sCellAdditionMethod from blind to covBasedA1,Move UE1 to bad coverage area
#     Step5 :Detach UE1 and Move UE1 to bad coverage area and attach
#     Step6 :Move UE1 to good coverage area
#     Step7 :UE1 do UL DL data transfer
# 
# *** Keywords ***
# Step1 :gNB is onair with the configuration
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version        ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}                Set Variable                      ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file          ${CONFIG_DIR_PATH}/${SCFC_NAME}     ${scfc_path}
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=1
#     ${modify_list}      create list        ${carrierAggregationSupportList}
#     ...    ${pucchModeSelect}
#     ...    ${actBeamforming}
#     ...    ${nrBtsBeamRefinementP2}
#     ...    ${numberOfTransmittedSsBlocks}
#     ...    ${basicBeamSet}
#     ...    ${nrCellType}
#     ...    ${cellDepType}
#     ...    ${actCDrx}
#     ...    ${frameStructureType}
#     ...    ${guardPeriodLength}
#     ...    ${lteToNrFrameShift}
#     ...    ${prachConfigurationIndex}
#     ...    ${ssBurstSetPeriod}
#     ...    ${sCellGoodChannelQualityThreshold}
#     ...    ${sCellBadChannelQualityThreshold}
#     ...    ${sCellChannelEstimationPeriod}
#     ...    ${sCellAdditionMethod}
#     ...    ${maxNumScellsDl}
#     ...    ${actFdmScheduling}
#     ...    ${sCellDeactivationBadRlqCount}
#     ...    ${sCellActivationMethod}
#     modify_xml          ${scfc_path}        ${scfc_path}         ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair
#     ...    ${scfc_path}
#     ...    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
#     ...    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2 :Attach UE1 to TDD FR1 cell
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
#     #Start GNB BIP Log
# #    Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     ${cmd}=    Set Variable    csi_override_testmode_nr profile_id=1 cqi=15
#     airphone_execute_egate_command    ${cmd}
#     ${cmd}=    Set Variable    ue_testmode_set_nr id=1 testmode=csi_override action=activate profile_id=1 scell=0,1
#     airphone_execute_egate_command    ${cmd}
#     Wait Throughput Timer    10
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step2_ue_attach/output
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
# #    Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach' File
# 
# Step3 :UE1 do UL DL data transfer
#     Start Collect GNB and AP Syslog in 'step3_send_data' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=5    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=6    pdu_id=${PDU_ID}    duration=${3600}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_data${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_data${/}
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_send_data
#     Wait Throughput Timer    10
#     ${UE1_dl_throughput_p} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=0    type=pdsch    tput_type=ave
#     ${UE1_dl_throughput_s} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=1    type=pdsch    tput_type=ave
# #    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step3_send_data/output
#     should be true    ${UE1_dl_throughput_p}>150000
#     should be true    ${UE1_dl_throughput_s}>150000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_send_data' File
# 
# Step4 :Change sCellAdditionMethod from blind to covBasedA1,Move UE1 to bad coverage area
#     Start Collect GNB and AP Syslog in 'step4_move_bad_coverage' File
#     TAF_ADMIN.connect to    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-2/NRCELL-1/NRREL-2
#     ...    parameter=sCellAdditionMethod    operation=update    value=covBasedA1
#     ...    skip_parameter_relation_errors=True    connection=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-2/NRCELL-1
#     ...    parameter=a1MeasSCellAddEnabled    operation=update    value=rsrp
#     ...    skip_parameter_relation_errors=True    connection=online
#     TAF_ADMIN.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-2
#     ...    parameter=actMeasBasedSCellAddition    operation=update    value=true
#     ...    skip_parameter_relation_errors=True    connection=online
#     TAF_ADMIN.teardown admin    connection=online
#     Wait Throughput Timer    20
#     ${UE1_dl_throughput_p1} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=0    type=pdsch    tput_type=ave
#     ${UE1_dl_throughput_s1} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=1    type=pdsch    tput_type=ave
#     #Start GNB BIP Log
# #    Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     airphone_execute_egate_command    csi_override_testmode_nr profile_id\=2 cqi\=1
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=2 scell\=1
#     ...    fail_regexp=sCellToReleaseList
#     Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_move_bad_coverage${/}
# #    Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_move_bad_coverage${/}
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_move_bad_coverage
#     #Wait Throughput Timer    10
#     ${UE1_dl_throughput_p2} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=0    type=pdsch    tput_type=ave
#     ${UE1_dl_throughput_s2} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=1    type=pdsch    tput_type=ave
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step4_move_bad_coverage/output
#     should be true    ${UE1_dl_throughput_p1}>150000
#     should be true    ${UE1_dl_throughput_s1}>150000
#     should be true    ${UE1_dl_throughput_p2}>150000
#     should be true    ${UE1_dl_throughput_s2}==0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_move_bad_coverage' File
# 
# Step5 :Detach UE1 and Move UE1 to bad coverage area and attach
#     Start Collect GNB and AP Syslog in 'step5_detach' File
#     airphone_sa_stop_data_traffic    ${UE_ID}    DL    pdu_id=${PDU_ID}
#     #Start GNB BIP Log
# #    Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     airphone_sa_detach    ${UE_ID}
#     Wait Throughput Timer    5
#     Airphone SA Attach    ue_id=${UE_ID}
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_detach${/}
# #    Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_detach${/}
#     Wait Throughput Timer    2
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step5_detach
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step5_detach/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step5_detach' File
# 
# Step6 :Move UE1 to good coverage area
#     Start Collect GNB and AP Syslog in 'step6_move_good_coverage' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override scell\=1 profile_id\=2 action\=deactivate
# 	airphone_execute_egate_command    csi_override_testmode_nr profile_id\=3 cqi\=15
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=3 scell\=0,1
#     airphone_execute_egate_command    ue_measurement\_send\_nr id\=1 meas_id\=1 event\=A1 srsrp_nr\=80
#     ...    pass_regexp=sCellToAddModList
#     Wait Throughput Timer    5
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step6_move_good_coverage
# #    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step6_move_good_coverage/output
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_move_good_coverage${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_move_good_coverage${/}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step6_move_good_coverage' File
# 
# Step7 :UE1 do UL DL data transfer
#     Start Collect GNB and AP Syslog in 'step7_data_transfer' File
# #    Start GNB BIP Log
# #    Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=5    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=6    pdu_id=${PDU_ID}    duration=${3600}
#     Wait Throughput Timer    10
# #    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step7_data_transfer${/}
# #    Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step7_data_transfer${/}
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step7_data_transfer
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step7_data_transfer/output
#     ${UE1_dl_throughput_p} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=0    type=pdsch    tput_type=ave
#     ${UE1_dl_throughput_s} =    Airphone Get Throughput On Specific Scell    ue_id=1    scell_id=1    type=pdsch    tput_type=ave
#     should be true    ${UE1_dl_throughput_p}>150000
#     should be true    ${UE1_dl_throughput_s}>150000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step7_data_transfer' File
# 
# 
