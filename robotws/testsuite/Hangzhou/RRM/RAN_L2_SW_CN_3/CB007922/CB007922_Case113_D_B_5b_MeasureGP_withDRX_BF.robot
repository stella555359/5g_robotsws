# *** Settings ***
# Documentation     example case for RAN HZ L2 SW11. test step description in QC as below:
# ...
# ...               QC case full name:
# ...               CB007922_Case113_D_B_5b_MeasureGP_withDRX_BF
# ...
# ...               Verify Measurement gap with DRX function.
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown    Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    SBTS22R3    ownerbylilyu    SBTS23R1
# Test Timeout      60 minutes
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${UE_ID}          1
# ${PDU_ID}         1
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${carrierAggregationSupportList}    text|ca_Fr1Tdd_Sa|//list[@name\="carrierAggregationSupportList"]/p
# ${actInterNumerologyCa}    text|false|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}    text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}    text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}    text|true|//*[@name\="actBeamforming"]
# ${nrBtsBeamRefinementP2}    text|false|//*[@name\="nrBtsBeamRefinementP2"]
# ${nrCellType}     text|4DL2UL|//*[@name\="nrCellType"]
# ${cellDepType}    text|SA+NSA|//*[@name\="cellDepType"]
# ${actCDrx}        text|true|//*[@name\="actCDrx"]
# ${drxOnDurationTimer}    text|10ms|//*[@name\="drxOnDurationTimer"]
# ${drxRetransTimerDl}    text|0slot|//*[@name\="drxRetransTimerDl"]
# ${drxRetransTimerUl}    text|0slot|//*[@name\="drxRetransTimerUl"]
# ${drxLongCycle}    text|40ms|//*[@name\="drxLongCycle"]
# ${drxInactivityTimer}    text|10ms|//*[@name\="drxInactivityTimer"]
# ${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}    text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}    text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}    text|97|//*[@name\="prachConfigurationIndex"]
# ${ssBurstSetPeriod}    text|20|//*[@name\="ssBurstSetPeriod"]
# ${sCellChannelEstimationPeriod}    text|2000|//*[@name\="sCellChannelEstimationPeriod"]
# ${sCellAdditionMethod}    text|covBasedA1|//*[@name\="sCellAdditionMethod"]
# ${maxNumScellsDl}    text|1|//*[@name\="maxNumScellsDl"]
# ${actFdmScheduling}    text|true|//*[@name\="actFdmScheduling"]
# ${sCellDeactivationBadRlqCount}    text|0|//*[@name\="sCellDeactivationBadRlqCount"]
# ${sCellActivationMethod}    text|blind|//*[@name\="sCellActivationMethod"]
# ${a1MeasSCellAddEnabled}    text|rsrp|//*[@name\="a1MeasSCellAddEnabled"]
# ${a1ThresholdSCellAddSsbRsrpTDD}    text|60|//*[@name\="a1ThresholdSCellAddSsbRsrpTDD"]
# ${sCellDeactivationTimerGNB}    text|infinity|//*[@name\="sCellDeactivationTimerGNB"]
# 
# *** Test Cases ***
# CB007922_Case113_D_B_5b_MeasureGP_withDRX_BF
#     Step1:Commission the above configuration on WebUI
#     Step2:UE1 attach to cell2 , send A1 report to add scell
#     Step3:do full buffer dl data transfer to active scell
#     Step4:UE1 do dl discontinuous data transfer
#     Step5:send A2 report and do dl discontinuous data transfer
#     Step6:send A1 report and do dl discontinuous data transfer to trigger drx
#     Step7:Detach UE
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start Collect GNB and AP Syslog in 'step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB007922    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_ca_relation_CB7922    ${scfc_path}
#     ${modify_list}    create list    ${carrierAggregationSupportList}    ${actInterNumerologyCa}    ${flexibleCAMode}    ${pucchModeSelect}
#     ...    ${actBeamforming}    ${nrBtsBeamRefinementP2}    ${cellDepType}    ${actCDrx}    ${frameStructureType}    ${guardPeriodLength}
#     ...    ${lteToNrFrameShift}    ${prachConfigurationIndex}    ${ssBurstSetPeriod}    ${sCellChannelEstimationPeriod}    ${sCellAdditionMethod}
#     ...    ${maxNumScellsDl}    ${actFdmScheduling}    ${sCellActivationMethod}    ${a1MeasSCellAddEnabled}    ${a1ThresholdSCellAddSsbRsrpTDD}
#     ...    ${nrCellType}    ${sCellDeactivationTimerGNB}    ${actCDrx}    ${drxRetransTimerDl}    ${drxRetransTimerUl}    ${drxLongCycle}
#     ...    ${drxInactivityTimer}    ${drxOnDurationTimer}
#     #${chBw}    ${actInterNumerologyCa}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2:UE1 attach to cell2 , send A1 report to add scell
#     Start Collect GNB and AP Syslog in 'step2_ue_attach' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     Airphone Location Change    id=${UE_ID}    cell_id=2
#     #open beaforming
#     airphone_execute_egate_command
#     ...    beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=5,0,1,2,3,4,6,7 ssbeam_bestbeam\=5 ssbeam_rsrp_best\=-65 ssbeam_rsrp_avg\=-98
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=0,1
#     #ue attach
#     Airphone Sa Attach    ue_id=${UE_ID}
#     airphone_set_traffic_type    ${UE_ID}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ${UE_ID}    ${PDU_ID}    ${SLICE_ID}    ${GW_ID}
#     #send A1
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=1 meas_obj_type\=nr
#     airphone_execute_egate_command    ue_measurement\_send\_nr id\=1 meas_id\=1 event\=A1 srsrp_nr\=80    pass_regexp=sCellToAddModList
#     # Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach${/}
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step2_ue_attach/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach' File
# 
# Step3:do full buffer dl data transfer to active scell
#     Start Collect GNB and AP Syslog in 'step3_UL_DL_data' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=4    pdu_id=${PDU_ID}    duration=${3600}
#     #Airphone SA Start Data Traffic    ${UE_ID}    DL    175M    trf_id=5    pdu_id=${PDU_ID}    duration=${3600}
#     #Airphone SA Start Data Traffic    ${UE_ID}    UL    50M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     #Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_UL_DL_data${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_UL_DL_data${/}
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_UL_DL_data
#     Comment    Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step3_UL_DL_data
#     Wait Throughput Timer    20
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID}    scell_id=1    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 400000
#     should be true    ${Scell_dl_throughput} > 60000
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_UL_DL_data' File
# 
# Step4:UE1 do dl discontinuous data transfer
#     Start Collect GNB and AP Syslog in 'step4_discontinuous_data' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     airphone_sa_stop_data_traffic    ${UE_ID}    DL    pdu_id=${PDU_ID}
#     #Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_discontinuous_data${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_discontinuous_data${/}
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_discontinuous_data
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step4_discontinuous_data/output
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    180
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}step4_discontinuous_data/
#     ${PM_counter_pcell_value_sleep}=
#     ...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C11002    cell_id=2
#     ${PM_counter_scell_value_sleep}=
#     ...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C11002    cell_id=3
#     ${PM_counter_pcell_value_active}=
#     ...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C11001    cell_id=2
#     ${PM_counter_scell_value_active}=
#     ...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C11001    cell_id=3
#     should be true    2.8<float(${PM_counter_pcell_value_sleep})/float(${PM_counter_pcell_value_active})<3.2
#     should be true    2.8<float(${PM_counter_scell_value_sleep})/float(${PM_counter_scell_value_active})<3.2
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_discontinuous_data' File
# 
# Step5:send A2 report and do dl discontinuous data transfer
#     Start Collect GNB and AP Syslog in 'step5_send_A2' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     #send A2
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=1 meas_obj_type\=nr
#     airphone_execute_egate_command
#     ...    ue_measurement_send_nr event\=A2 id\=1 meas_id\=2 rs_type\=ssb scell\=1 scell_rsrp\=30    pass_regexp=sCellToReleaseList
#     #Airphone SA Start Data Traffic    ${UE_ID}    DL    1k    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     #Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_send_A2${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_send_A2${/}
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step5_send_A2
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step5_send_A2/output
#     Wait Throughput Timer    180
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}step5_send_A2/
#     ${PM_counter_pcell_value_sleep}=
#     ...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C11002    cell_id=2
#     ${PM_counter_scell_value_sleep}=
#     ...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C11002    cell_id=3
#     ${PM_counter_pcell_value_active}=
#     ...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C11001    cell_id=2
#     ${PM_counter_scell_value_active}=
#     ...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C11001    cell_id=3
#     should be true    2.8<float(${PM_counter_pcell_value_sleep})/float(${PM_counter_pcell_value_active})<3.2
#     should be true    ${PM_counter_scell_value_sleep}==0
#     should be true    ${PM_counter_scell_value_active}==0
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step5_send_A2' File
# 
# Step6:send A1 report and do dl discontinuous data transfer to trigger drx
#     #Start Collect GNB and AP Syslog in 'step6_send_A1' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     #send A1
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=1 meas_obj_type\=nr
#     airphone_execute_egate_command    ue_measurement\_send\_nr id\=1 meas_id\=3 event\=A1 srsrp_nr\=80    pass_regexp=sCellToAddModList
#     #Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_send_A1${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_send_A1${/}
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step6_send_A1
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step6_send_A1/output
#     Wait Throughput Timer    120
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}step6_send_A1/
#     ${PM_counter_pcell_value_sleep}=
#     ...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C11002    cell_id=2
#     ${PM_counter_scell_value_sleep}=
#     ...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C11002    cell_id=3
#     ${PM_counter_pcell_value_active}=
#     ...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C11001    cell_id=2
#     ${PM_counter_scell_value_active}=
#     ...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55308C11001    cell_id=3
#     should be true    2.8<float(${PM_counter_pcell_value_sleep})/float(${PM_counter_pcell_value_active})<3.2
#     should be true    2.8<float(${PM_counter_scell_value_sleep})/float(${PM_counter_scell_value_active})<3.2
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step6_send_A1' File
# 
# Step7:Detach UE
#     Start Collect GNB and AP Syslog in 'Step7_Detach_UE' File
#     airphone_sa_stop_data_traffic    ${UE_ID}    DL    pdu_id=${PDU_ID}
#     airphone_sa_detach    ${UE_ID}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step7_Detach_UE' File
# 
# add_ca_relation_CB7922
#     [Arguments]    ${scfc_path}
#     #L2RT intra band CA Cell2&Cell3 Inter L2RT inter band CA Cell4&Cell1 Intra L2RT intra band CA Cell1&Cell2 Intra L2RT inter band CA Cell3&Cell4
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=3
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=3    lcrid=4
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=4    lcrid=1
