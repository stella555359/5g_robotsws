# *** Settings ***
# Documentation     This user scenario describes the successful UE configuration of the TDD FR1-TDD FR1 CA feature for single UE
# ...               with 2 aggregated carriers in SA option 2 mode.
# ...
# ...               QC case full name:
# ...               CB007922_Case173_D_C_1a_intraL2RT_Single_UE_DL_UL_peak_NSA_with_5GC001070_guardSy_4_mixBandWidth
# ...               Successful operation of the 7922 NSA cobverA1 Scell addition
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    SBTS00    SBTS22R4     ownerbylilyu    SBTS23R1
# Test Timeout      90 minutes
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Library           taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${JSON_DIR_PATH}    ${CURDIR}/config
# ${UE_ID_NSA}       11
# ${PDU_ID}         1
# ${BEAR_ID}        2
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${pmi_cmd}        csi_override_testmode_nr profile_id=1 cqi_mode=fixed cqi=15 ri_mode=fixed ri=1 pmi_mode=fixed pmi=500
#                   ...    cri_mode=fixed cri=1 li_mode=fixed li=1
# ${SCFC_NAME}      gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${AIRPHONE_NAME}    AP_iphy_AEQE_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.xml
# ${WTS_NAME}       wts_config_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_4S_1CC.cfg
# @{LOG_NAME_LIST}    gnb_snapshot    sosreport    tshark    egatelog
# ${mo}    com.nokia.srbts.nrbts:NRCELL
# ${actInterNumerologyCa}    text|false|//*[@name\="actInterNumerologyCa"]
# ${flexibleCAMode}    text|MixedCAMode|//*[@name\="flexibleCAMode"]
# ${pucchModeSelect}    text|longPucch|//*[@name\="pucchModeSelect"]
# ${actBeamforming}    text|true|//*[@name\="actBeamforming"]
# ${cellDepType}    text|SA+NSA|//*[@name\="cellDepType"]
# ${actCDrx}        text|false|//*[@name\="actCDrx"]
# ${prachConfigurationIndex}    text|97|//*[@name\="prachConfigurationIndex"]
# ${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}    text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}    text|0ms|//*[@name\="lteToNrFrameShift"]
# ${ulDlDataSlotRatio}    text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${sCellAdditionMethod}    text|covBasedA1|//*[@name\="sCellAdditionMethod"]
# ${actFdmScheduling}    text|true|//*[@name\="actFdmScheduling"]
# ${sCellActivationMethod}    text|blind|//*[@name\="sCellActivationMethod"]
# ${sCellDeactivationTimerGNB}    text|infinity|//*[@name\="sCellDeactivationTimerGNB"]
# ${chBw}    text|80MHz|//*[@name\="chBw"]
# ${dlMimoMode}    text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${ssBurstSetPeriod}    text|20|//*[@name\="ssBurstSetPeriod"]
# *** Test Cases ***
# CB007922_Case173_D_C_1a_intraL2RT_Single_UE_DL_UL_peak_NSA_with_5GC001070_guardSy_4_mixBandWidth_bak
#     Step1:Commission the above configuration on WebUI
#     Step2:ue attach to cell1
#     Step3:send A1 report
#     Step4:push DL_data
#     Step5:push UL_data
#     Step6:send A2 report to release scell
#     Step7:Detach UE
# 
# CB007922_Case173_D_C_1a_intraL2RT_Single_UE_DL_UL_peak_NSA_with_5GC001070_guardSy_4_mixBandWidth
#     Step1:Commission the above configuration on WebUI
#     Step2:ue attach to cell1
#     Step3:send A1 report
#     Step4:push DL_data
#     Step5:push UL_data
#     Step6:send A2 report to release scell
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
#     add_periodiccsiacquisition_list_in_cells    ${scfc_path}
#     add_ca_relation_CB7922    ${scfc_path}
#     ${modify_list}    create list    ${actInterNumerologyCa}    ${flexibleCAMode}    ${pucchModeSelect}    ${actBeamforming}    ${cellDepType}
#     ...    ${actCDrx}    ${prachConfigurationIndex}    ${ssBurstSetPeriod}    ${guardPeriodLength}    ${ulDlDataSlotRatio}    ${lteToNrFrameShift}
#     ...    ${sCellAdditionMethod}    ${chBw}    ${actFdmScheduling}    ${sCellActivationMethod}    ${dlMimoMode}    ${sCellDeactivationTimerGNB}
#     ...    ${frameStructureType}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2:ue attach to cell1
#     Start Collect GNB and AP Syslog in 'step2_ue_attach_NSA' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #build X2
#     Airphone Execute Egate Command    enb_x2_link_up enb\=1 target\=2
#     #open beaforming
#     Airphone Execute Egate Command
#     ...    beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=0,1,2,3,4,5,6,7 ssbeam_bestbeam\=0 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-70
#     Airphone Execute Egate Command
#     ...    ue_testmode_set_nr id\=${UE_ID_NSA} testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=0,1
#     #Airphone Execute Egate Command    ue_dc_enb_start ue\=${UE_ID_NSA} target_gnb\=2 target_cells\=2 bearer\=${BEAR_ID} type\=split_scg
#     #ue attach to cell2
#     Airphone Nsa Attach    ue_id=${UE_ID_NSA}    cell_id=2
#     #set pmi
#     airphone_execute_egate_command    ${pmi_cmd}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    5
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach_NSA
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach_NSA${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach_NSA${/}
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step2_ue_attach_NSA/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach_NSA' File
# 
# Step3:send A1 report
#     Start Collect GNB and AP Syslog in 'step3_send_A1' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #send A1 report successful
#     #Airphone Execute Egate Command    ue_meas_cfg_disp id\=${UE_ID_NSA} meas_obj_type\=nr
#     #Airphone Execute Egate Command    ue_measurement\_send\_nr id\=${UE_ID_NSA} meas_id\=1 event\=A1 srsrp_nr\=80    pass_regexp=sCellToAddModList
#     Airphone Measurement Send Nr    id=${UE_ID_NSA}    meas_id=1    event=A1    srsrp_nr=80    pass_regexp=sCellToAddModList
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    5
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_send_A1
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_A1${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_A1${/}
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step3_send_A1/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_send_A1' File
# 
# Step4:push DL_data
#     Start Collect GNB and AP Syslog in 'step4_push_dl_data' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #start enough data
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    DL    100M    trf_id=1    bearer_id=${BEAR_ID}    duration=${3600}
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    DL    100M    trf_id=2    bearer_id=${BEAR_ID}    duration=${3600}
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    DL    100M    trf_id=3    bearer_id=${BEAR_ID}    duration=${3600}
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    DL    100M    trf_id=4    bearer_id=${BEAR_ID}    duration=${3600}
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    DL    100M    trf_id=5    bearer_id=${BEAR_ID}    duration=${3600}
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    DL    100M    trf_id=6    bearer_id=${BEAR_ID}    duration=${3600}
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    DL    100M    trf_id=7    bearer_id=${BEAR_ID}    duration=${3600}
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    DL    100M    trf_id=8    bearer_id=${BEAR_ID}    duration=${3600}
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    DL    100M    trf_id=9    bearer_id=${BEAR_ID}    duration=${3600}
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    DL    100M    trf_id=10    bearer_id=${BEAR_ID}    duration=${3600}
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    5
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_push_dl_data
#     #check peak dl thp
#     Wait Throughput Timer    20
#     ${Pcell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID_NSA}    scell_id=8    type=pdsch    tput_type=ave
#     ${Scell_dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${UE_ID_NSA}   scell_id=9    type=pdsch    tput_type=ave
#     should be true    ${Pcell_dl_throughput} > 300000
#     should be true    ${Scell_dl_throughput} > 300000
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_push_dl_data${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_push_dl_data${/}
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step4_push_dl_data$/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_push_dl_data$' File
# 
# Step5:push UL_data
#     Start Collect GNB and AP Syslog in 'step5_push_Ul_data' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #start enough data
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    UL    100M    trf_id=1    bearer_id=${BEAR_ID}    duration=${3600}
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    UL    100M    trf_id=2    bearer_id=${BEAR_ID}    duration=${3600}
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    UL    100M    trf_id=3    bearer_id=${BEAR_ID}    duration=${3600}
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    UL    100M    trf_id=4    bearer_id=${BEAR_ID}    duration=${3600}
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    UL    100M    trf_id=5    bearer_id=${BEAR_ID}    duration=${3600}
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    UL    100M    trf_id=6    bearer_id=${BEAR_ID}    duration=${3600}
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    UL    100M    trf_id=7    bearer_id=${BEAR_ID}    duration=${3600}
#     airphone_nsa_start_data_traffic    ${UE_ID_NSA}    UL    100M    trf_id=8   bearer_id=${BEAR_ID}    duration=${3600}
#     Start GNB Ttitrace With Streaming Mode
#     Wait Throughput Timer    5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step5_push_Ul_data
#     #check peak ul thp
#     Wait Throughput Timer    20
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_push_Ul_data{/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step5_push_Ul_data{/}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step5_push_Ul_data/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step5_push_Ul_data' File
# 
# Step6:send A2 report to release scell
#     Start Collect GNB and AP Syslog in 'step6_send_A2' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     #send A2
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=11 meas_obj_type\=nr
#     airphone_execute_egate_command
#     ...    ue_measurement_send_nr event\=A2 id\=11 meas_id\=2 rs_type\=ssb scell\=9 scell_rsrp\=30    pass_regexp=sCellToReleaseList
#     #Wait Throughput Timer    5
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_send_A2${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step6_send_A2${/}
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step6_send_A2
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step6_send_A2/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step6_send_A2' File
# 
# Step7:Detach UE
#     Comment    Start Collect GNB and AP Syslog in 'step7_Detach_UE' File
#     airphone_nsa_stop_data_traffic    ${UE_ID_NSA}    DL    bearer_id=${BEAR_ID}
#     airphone_nsa_detach    ${UE_ID_NSA}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step7_Detach_UE' File
# 
# add_ca_relation_CB7922
#     [Arguments]    ${scfc_path}
#     #L2RT intra band CA Cell2&Cell3 Inter L2RT inter band CA Cell4&Cell1 Intra L2RT intra band CA Cell1&Cell2 Intra L2RT inter band CA Cell3&Cell4
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=3
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=3    lcrid=4
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=4    lcrid=1
