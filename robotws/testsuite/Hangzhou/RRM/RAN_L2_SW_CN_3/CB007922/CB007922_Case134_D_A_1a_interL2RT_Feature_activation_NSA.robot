# *** Settings ***
# Documentation     example case for RAN HZ L2 SW11. test step description in QC as below:
# ...
# ...               QC case full name:
# ...               CB007922_Case134_D_A_1a_interL2RT_Feature_activation_NSA
# ...
# ...               Successful operation of the 7922 NSA blind Scell addition
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    SBTS22R3    ownerbylilyu    SBTS23R1
# Test Timeout      60 minutes
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Library           taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${JSON_DIR_PATH}    ${CURDIR}/config
# ${UE_ID_SA}       1
# ${UE_ID_NSA}      11
# ${PDU_ID}         1
# ${BEAR_ID}        2
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${SCFC_NAME}      gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${actInterNumerologyCa}    text|false|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}    text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}    text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}    text|true|//*[@name\="actBeamforming"]
# ${cellDepType}    text|SA+NSA|//*[@name\="cellDepType"]
# ${actCDrx}        text|false|//*[@name\="actCDrx"]
# ${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}    text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}    text|0ms|//*[@name\="lteToNrFrameShift"]
# ${prachConfigurationIndex}    text|97|//*[@name\="prachConfigurationIndex"]
# ${sCellAdditionMethod}    text|covBasedA1|//*[@name\="sCellAdditionMethod"]
# ${actFdmScheduling}    text|true|//*[@name\="actFdmScheduling"]
# ${sCellActivationMethod}    text|blind|//*[@name\="sCellActivationMethod"]
# ${sCellDeactivationTimerGNB}    text|infinity|//*[@name\="sCellDeactivationTimerGNB"]
# ${chBw}    text|80MHz|//*[@name\="chBw"]
# ${dlMimoMode}    text|2x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# 
# *** Test Cases ***
# CB007922_Case134_D_A_1a_interL2RT_Feature_activation_NSA
#     Step1:Commission the above configuration on WebUI
#     Step2:ue1 attach to cell2,send A1 report,push data and detach in SA
#     Step3:ue11 attach to cell2,send A1 report,start data and detach in NSA
#     Step4:online change carrierAggregationSupportList=sa,ue1 send A1 success in SA and ue11 send A1 fail in NSA
#     Step5:online change carrierAggregationSupportList=nsa,ue11 send A1 success in NSA and ue1 send A1 fail in SA
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
#     ${modify_list}    create list    ${actInterNumerologyCa}    ${flexibleCAMode}    ${pucchModeSelect}    ${actBeamforming}    ${cellDepType}
#     ...    ${actCDrx}    ${frameStructureType}    ${guardPeriodLength}    ${lteToNrFrameShift}    ${prachConfigurationIndex}
#     ...    ${sCellAdditionMethod}    ${chBw}    ${actFdmScheduling}    ${sCellActivationMethod}    ${dlMimoMode}    ${sCellDeactivationTimerGNB}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2:ue1 attach to cell2,send A1 report,push data and detach in SA
#     Start Collect GNB and AP Syslog in 'step2_ue_attach_SA' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #change cell to cell2
#     Airphone Location Change    id=${UE_ID_SA}    cell_id=2
#     #open beaforming
#     airphone_execute_egate_command
#     ...    beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=0,1,2,3,4,5,6,7 ssbeam_bestbeam\=0 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-70
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=0,1
#     Airphone Sa Attach    ue_id=${UE_ID_SA}
#     airphone_set_traffic_type    ${UE_ID_SA}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ${UE_ID_SA}    ${PDU_ID}    ${SLICE_ID}    ${UE_ID_SA}
#     #send A1 report
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=${UE_ID_SA} meas_obj_type\=nr
#     airphone_execute_egate_command    ue_measurement\_send\_nr id\=${UE_ID_SA} meas_id\=1 event\=A1 srsrp_nr\=80    pass_regexp=sCellToAddModList
#     #start enough data
#     Airphone SA Start Data Traffic    ${UE_ID_SA}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID_SA}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID_SA}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    5
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach_SA
#     #assert
#     Wait Throughput Timer    20
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID_SA}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID_SA}    scell_id=1    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 200000
#     should be true    ${Scell_dl_throughput} > 200000
#     #detach ue
#     airphone_sa_stop_data_traffic    ${UE_ID_SA}    DL    pdu_id=${PDU_ID}
#     airphone_sa_detach    ${UE_ID_SA}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach_SA${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach_SA${/}
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step2_ue_attach_SA/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach_SA' File
# 
# Step3:ue11 attach to cell2,send A1 report,start data and detach in NSA
#     Start Collect GNB and AP Syslog in 'step3_ue_attach_NSA' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #build X2
#     Airphone Setup X2 Connection
#     #ue attach to cell2
#     Airphone Nsa Attach    ue_id=${UE_ID_NSA}    cell_id=2
#     #open beaforming
#     airphone_execute_egate_command
#     ...    beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=0,1,2,3,4,5,6,7 ssbeam_bestbeam\=0 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-70
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${UE_ID_NSA} testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=0,1
#     #airphone_execute_egate_command    ue_dc_enb_start ue\=${UE_ID_NSA} target_gnb\=2 target_cells\=2 bearer\=${BEAR_ID} type\=split_scg
#     #send A1 report
#     #airphone_execute_egate_command    ue_meas_cfg_disp id\=${UE_ID_NSA} meas_obj_type\=nr
#     #airphone_execute_egate_command    ue_measurement\_send\_nr id\=${UE_ID_NSA} meas_id\=1 event\=A1 srsrp_nr\=80    pass_regexp=sCellToAddModList
#     Airphone Measurement Send Nr    id=${UE_ID_NSA}    meas_id=1    event=A1    srsrp_nr=80    pass_regexp=sCellToAddModList
#     #start enough data
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    DL    175M    trf_id=1    bearer_id=${BEAR_ID}    duration=${3600}
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    DL    175M    trf_id=2    bearer_id=${BEAR_ID}    duration=${3600}
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    DL    175M    trf_id=3    bearer_id=${BEAR_ID}    duration=${3600}
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    5
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_ue_attach_NSA
#     #assert
#     Wait Throughput Timer    20
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID_NSA}    scell_id=8    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID_NSA}    scell_id=9    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 200000
#     should be true    ${Scell_dl_throughput} > 200000
#     #detach ue
#     airphone_nsa_stop_data_traffic    ${UE_ID_NSA}    DL    bearer_id=${BEAR_ID}
#     airphone_nsa_detach    ${UE_ID_NSA}
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_ue_attach_NSA${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_ue_attach_NSA${/}
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step3_ue_attach_NSA/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_ue_attach_NSA' File
# 
# Step4:online change carrierAggregationSupportList=sa,ue1 send A1 success in SA and ue11 send A1 fail in NSA
#     Start Collect GNB and AP Syslog in 'step4_change_parameter_sa' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #online change parameter
#     log    ${JSON_DIR_PATH}/${SW_BRANCH}/JSON/
#     Online recommissioning with delta json file    ${JSON_DIR_PATH}/${SW_BRANCH}/JSON/delta_A_1a_case134_step4.json
#     Wait Throughput Timer    60
#     #ue1 attach cell2 in sa
#     Airphone Sa Attach    ue_id=${UE_ID_SA}
#     airphone_set_traffic_type    ${UE_ID_SA}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ${UE_ID_SA}    ${PDU_ID}    ${SLICE_ID}    ${UE_ID_SA}
#     #send A1 report successful
#     #airphone_execute_egate_command    ue_meas_cfg_disp id\=${UE_ID_SA} meas_obj_type\=nr
#     #airphone_execute_egate_command    ue_measurement\_send\_nr id\=${UE_ID_SA} meas_id\=1 event\=A1 srsrp_nr\=80    pass_regexp=sCellToAddModList
#     Airphone Measurement Send Nr    id=${UE_ID_SA}    meas_id=1    event=A1    srsrp_nr=80    pass_regexp=sCellToAddModList
#     #start enough data
#     Airphone SA Start Data Traffic    ${UE_ID_SA}    DL    175M    trf_id=1    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID_SA}    DL    175M    trf_id=2    pdu_id=${PDU_ID}    duration=${3600}
#     Airphone SA Start Data Traffic    ${UE_ID_SA}    DL    175M    trf_id=3    pdu_id=${PDU_ID}    duration=${3600}
#     #assert
#     Wait Throughput Timer    20
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID_SA}    scell_id=0    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID_SA}    scell_id=1    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 200000
#     should be true    ${Scell_dl_throughput} > 200000
#     #Start GNB Ttitrace With Streaming Mode
#     #detach ue1
#     airphone_sa_stop_data_traffic    ${UE_ID_SA}    DL    pdu_id=${PDU_ID}
#     airphone_sa_detach    ${UE_ID_SA}
#     #ue11 attach to cell2
#     Airphone Nsa Attach    ue_id=${UE_ID_NSA}    cell_id=2
#     #airphone_execute_egate_command    ue_dc_enb_start ue\=${UE_ID_NSA} target_gnb\=2 target_cells\=2 bearer\=${BEAR_ID} type\=split_scg
#     #send A1 report
#     #airphone_execute_egate_command    ue_meas_cfg_disp id\=${UE_ID_NSA} meas_obj_type\=nr
#     #airphone_execute_egate_command    ue_measurement\_send\_nr id\=${UE_ID_NSA} meas_id\=1 event\=A1 srsrp_nr\=80    fail_regexp=sCellToAddModList
#     Airphone Measurement Send Nr    id=${UE_ID_SA}    meas_id=1    event=A1    srsrp_nr=80    fail_regexp=sCellToAddModList
#     #detach ue11
#     airphone_nsa_stop_data_traffic    ${UE_ID_NSA}    DL    bearer_id=${BEAR_ID}
#     airphone_nsa_detach    ${UE_ID_NSA}
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_change_parameter_sa
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_change_parameter_sa${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_change_parameter_sa${/}
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step4_change_parameter_sa/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_change_parameter_sa' File
# 
# Step5:online change carrierAggregationSupportList=nsa,ue11 send A1 success in NSA and ue1 send A1 fail in SA
#     Start Collect GNB and AP Syslog in 'step5_change_parameter_nsa' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #online change parameter
#     Online recommissioning with delta json file    ${JSON_DIR_PATH}/${SW_BRANCH}/JSON/delta_A_1a_case134_step5.json
#     Wait Throughput Timer    60
#     #ue11 attach to cell2
#     Airphone Nsa Attach    ue_id=${UE_ID_NSA}     cell_id=2
#     #airphone_execute_egate_command    ue_dc_enb_start ue\=${UE_ID_NSA} target_gnb\=2 target_cells\=2 bearer\=${BEAR_ID} type\=split_scg
#     #send A1 report
#     #airphone_execute_egate_command    ue_meas_cfg_disp id\=${UE_ID_NSA} meas_obj_type\=nr
#     #airphone_execute_egate_command    ue_measurement\_send\_nr id\=${UE_ID_NSA} meas_id\=1 event\=A1 srsrp_nr\=80    pass_regexp=sCellToAddModList
#     Airphone Measurement Send Nr    id=${UE_ID_NSA}    meas_id=1    event=A1    srsrp_nr=80    pass_regexp=sCellToAddModList
#     #start enough data
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    DL    175M    trf_id=1    bearer_id=${BEAR_ID}    duration=${3600}
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    DL    175M    trf_id=2    bearer_id=${BEAR_ID}    duration=${3600}
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    DL    175M    trf_id=3    bearer_id=${BEAR_ID}    duration=${3600}
#     #assert
#     Wait Throughput Timer    20
#     #Start GNB Ttitrace With Streaming Mode
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID_NSA}    scell_id=8    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID_NSA}    scell_id=9    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 200000
#     should be true    ${Scell_dl_throughput} > 200000
#     #detach ue11
#     airphone_nsa_stop_data_traffic    ${UE_ID_NSA}    DL    bearer_id=${BEAR_ID}
#     airphone_nsa_detach    ${UE_ID_NSA}
#     #ue1 attach cell2 in sa
#     Airphone Sa Attach    ue_id=${UE_ID_SA}
#     airphone_set_traffic_type    ${UE_ID_SA}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ${UE_ID_SA}    ${PDU_ID}    ${SLICE_ID}    ${UE_ID_SA}
#     #send A1 report fail
#     #airphone_execute_egate_command    ue_meas_cfg_disp id\=${UE_ID_SA} meas_obj_type\=nr
#     #airphone_execute_egate_command    ue_measurement\_send\_nr id\=1 meas_id\=1 event\=A1 srsrp_nr\=80    fail_regexp=sCellToAddModList
#     Airphone Measurement Send Nr    id=${UE_ID_SA}    meas_id=1    event=A1    srsrp_nr=80    fail_regexp=sCellToAddModList
#     #detach ue1
#     airphone_sa_stop_data_traffic    ${UE_ID_SA}    DL    pdu_id=${PDU_ID}
#     airphone_sa_detach    ${UE_ID_SA}
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step5_change_parameter_nsa
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_change_parameter_nsa${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_change_parameter_nsa${/}
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step5_change_parameter_nsa/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step5_change_parameter_nsa' File
# 
# add_ca_relation_CB7922
#     [Arguments]    ${scfc_path}
#     #L2RT intra band CA Cell2&Cell3 Inter L2RT inter band CA Cell4&Cell1 Intra L2RT intra band CA Cell1&Cell2 Intra L2RT inter band CA Cell3&Cell4
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=3
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=3    lcrid=4
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=4    lcrid=1
