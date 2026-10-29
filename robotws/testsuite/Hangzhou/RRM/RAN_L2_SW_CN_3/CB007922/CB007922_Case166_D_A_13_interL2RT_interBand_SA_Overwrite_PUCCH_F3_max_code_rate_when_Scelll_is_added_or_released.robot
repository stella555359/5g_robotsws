# *** Settings ***
# Documentation     Author: lili.1.yu@nokia-sbell.com
# ...               QC case full name:
# ...               CB007922_Case166_D_A_13_interL2RT_interBand_SA_Overwrite_PUCCH_F3_max_code_rate_when_Scelll_is_added_or_released
# 
# Suite Setup       Common Suite Setup
# Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    5G_RAN_TDD    RAN_5G    SBTS00    SBTS22R4     ownerbylilyu    SBTS23R1
# Test Timeout      60 minutes
# Resource          ../resources/sg11/internal_resource/robot/modify_configuration.robot
# Library           taf.sbts.oam.coam.admin    WITH NAME    TAF_ADMIN
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../resources/sg11/internal_resource/config/
# ${JSON_DIR_PATH}    ${CURDIR}/config
# ${UE_ID_SA}       1
# ${PDU_ID}         1
# ${BEAR_ID}        2
# ${GW_ID}          1
# ${SLICE_ID}       1
# ${pmi_cmd}        csi_override_testmode_nr profile_id=1 cqi=15 ri_mode=fixed ri=1 pmi_mode=fixed pmi=500
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
# #${frameStructureType}    text|tdLte|//*[@name\="frameStructureType"]
# #${guardPeriodLength}    text|6Symbols|//*[@name\="guardPeriodLength"]
# #${lteToNrFrameShift}    text|0ms|//*[@name\="lteToNrFrameShift"]
# #${prachConfigurationIndex}    text|97|//*[@name\="prachConfigurationIndex"]
# ${sCellAdditionMethod}    text|covBasedA1|//*[@name\="sCellAdditionMethod"]
# ${actFdmScheduling}    text|true|//*[@name\="actFdmScheduling"]
# ${sCellActivationMethod}    text|blind|//*[@name\="sCellActivationMethod"]
# ${sCellDeactivationTimerGNB}    text|infinity|//*[@name\="sCellDeactivationTimerGNB"]
# ${chBw}    text|80MHz|//*[@name\="chBw"]
# ${pucchF3ModulationScheme}    text|qpsk_4psk|//*[@name\="pucchF3ModulationScheme"]
# #${actPdschRmCsirsForTracking}    text|true|//*[@name\="actPdschRmCsirsForTracking"]
# ${actPerCsiReportBundlingTddFr1}    text|true|//*[@name\="actPerCsiReportBundlingTddFr1"]
# ${dlMimoMode1}    text|8x4 Closed Loop Spatial Multiplexing|//*[contains(@distName, 'NRCELL-1')]/*[@name='dlMimoMode']
# ${dlMimoMode2}    text|8x4 Closed Loop Spatial Multiplexing|//*[contains(@distName, 'NRCELL-2')]/*[@name='dlMimoMode']
# ${dlMimoMode3}    text|8x4 Closed Loop Spatial Multiplexing|//*[contains(@distName, 'NRCELL-3')]/*[@name='dlMimoMode']
# ${dlMimoMode4}    text|2x2 Open Loop Spatial Multiplexing|//*[contains(@distName, 'NRCELL-4')]/*[@name='dlMimoMode']
# ${pucchF3MaxCodeRate}    text|zeroDot08|//*[@name\="pucchF3MaxCodeRate"]
# ${srPeriodicity}    text|slots160|//*[@name\="srPeriodicity"]
# ${csiReportPeriodicity}    text|slots320|//*[@name\="csiReportPeriodicity"]
# ${actPdschAtSsbSlots}    text|false|//*[contains(@distName, 'NRCELL-1')]/*[@name='actPdschAtSsbSlots']
# ${nrBtsBeamRefinementP21}    text|true|//*[contains(@distName, 'NRCELL-1')]//p[@name\='nrBtsBeamRefinementP2']
# ${nrBtsBeamRefinementP22}    text|false|//*[contains(@distName, 'NRCELL-2')]//p[@name\='nrBtsBeamRefinementP2']
# ${nrBtsBeamRefinementP23}    text|false|//*[contains(@distName, 'NRCELL-3')]//p[@name\='nrBtsBeamRefinementP2']
# ${nrBtsBeamRefinementP24}    text|false|//*[contains(@distName, 'NRCELL-4')]//p[@name\='nrBtsBeamRefinementP2']
# ${maxCsirsNumber1}    text|2|//*[contains(@distName, 'NRCELL-1')]//p[@name\='maxCsirsNumber']
# ${maxCsirsNumber2}    text|2|//*[contains(@distName, 'NRCELL-2')]//p[@name\='maxCsirsNumber']
# ${maxCsirsNumber3}    text|2|//*[contains(@distName, 'NRCELL-3')]//p[@name\='maxCsirsNumber']
# ${basicBeamSet1}    text|beamSet_6|//*[contains(@distName, 'MRBTS-1/NRBTS-2/NRCELL-1')]//p[@name\='basicBeamSet']
# ${basicBeamSet2}    text|beamSet_2|//*[contains(@distName, 'NRCELL-2')]//p[@name\='basicBeamSet']
# ${basicBeamSet3}    text|beamSet_2|//*[contains(@distName, 'NRCELL-3')]//p[@name\='basicBeamSet']
# ${basicBeamSet4}    text|beamSet_2|//*[contains(@distName, 'NRCELL-4')]//p[@name\='basicBeamSet']
# ${numberOfTransmittedSsBlocks1}    text|6 beams|//*[contains(@distName, 'MRBTS-1/NRBTS-2/NRCELLGRP-0')]/*[@name='numberOfTransmittedSsBlocks']
# ${numberOfTransmittedSsBlocks2}    text|2 beams|//*[contains(@distName, 'MRBTS-1/NRBTS-2/NRCELLGRP-1')]/*[@name='numberOfTransmittedSsBlocks']
# ${numberOfTransmittedSsBlocks3}    text|2 beams|//*[contains(@distName, 'MRBTS-1/NRBTS-2/NRCELLGRP-2')]/*[@name='numberOfTransmittedSsBlocks']
# ${numberOfTransmittedSsBlocks4}    text|2 beams|//*[contains(@distName, 'MRBTS-1/NRBTS-2/NRCELLGRP-3')]/*[@name='numberOfTransmittedSsBlocks']
# @{remove_list}    //*[contains(@distName, 'NRCELL-4')]//p[@name\='csirsNumberWithinReportPeriod_Set1']
# ...           //*[contains(@distName, 'NRCELL-4')]//p[@name\='csirsPower']
# ...           //*[contains(@distName, 'NRCELL-4')]//p[@name\='maxCsirsNumber']
# 
# 
# *** Test Cases ***
# CB007922_Case166_D_A_13_interL2RT_interBand_SA_Overwrite_PUCCH_F3_max_code_rate_when_Scelll_is_added_or_released_bak
#     Step1:Commission the above configuration on WebUI
#     Step2:ue attach to cell4
#     Step3:send A1 report to add scell
#     Step4:send A2 report to release scell
#     Step5:Detach UE
# 
# CB007922_Case166_D_A_13_interL2RT_interBand_SA_Overwrite_PUCCH_F3_max_code_rate_when_Scelll_is_added_or_released
#     Step1:Commission the above configuration on WebUI
#     Step2:ue attach to cell4
#     Step3:send A1 report to add scell
#     Step4:send A2 report to release scell
#     Step5:Detach UE
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
#     Remove Xml Element     ${scfc_path}    ${scfc_path}    ${remove_list}
#     add_ca_relation_CB7922    ${scfc_path}
#     ${modify_list}    create list    ${actInterNumerologyCa}    ${flexibleCAMode}    ${pucchModeSelect}    ${actBeamforming}    ${cellDepType}
#     ...    ${actCDrx}    ${srPeriodicity}    ${csiReportPeriodicity}    ${chBw}
#     ...    ${nrBtsBeamRefinementP21}    ${nrBtsBeamRefinementP22}    ${nrBtsBeamRefinementP23}    ${nrBtsBeamRefinementP24}
#     ...    ${basicBeamSet1}    ${basicBeamSet2}    ${basicBeamSet3}    ${basicBeamSet4}    ${actPdschAtSsbSlots}
#     ...    ${numberOfTransmittedSsBlocks1}    ${numberOfTransmittedSsBlocks2}    ${numberOfTransmittedSsBlocks3}    ${numberOfTransmittedSsBlocks4}
#     ...    ${dlMimoMode1}    ${dlMimoMode2}    ${dlMimoMode3}    ${dlMimoMode4}
#     ...    ${maxCsirsNumber1}    ${maxCsirsNumber2}    ${maxCsirsNumber3}    ${pucchF3ModulationScheme}    ${actPerCsiReportBundlingTddFr1}
#     ...    ${sCellAdditionMethod}    ${actFdmScheduling}    ${sCellActivationMethod}    ${pucchF3MaxCodeRate}    ${sCellDeactivationTimerGNB}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Perform Full Commission And Reach Onair    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step1_before_onair' File
# 
# Step2:ue attach to cell4
#     Start Collect GNB and AP Syslog in 'step2_ue_attach_SA' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     airphone_execute_egate_command    ue_change_location id\=${UE_ID_SA} cell\=4
#     #open beaforming
#     airphone_execute_egate_command
#     ...    beam_control_testmode_nr profile_id\=1 ueBeamIndexInitial\=0,1,2,3,4,5,6,7 ssbeam_bestbeam\=0 ssbeam_rsrp_best\=-44 ssbeam_rsrp_avg\=-70
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=beam_control action\=activate profile_id\=1 beamaction\=attach scell\=0,1
#     Airphone Sa Attach    ue_id=${UE_ID_SA}
#     #set pmi
#     airphone_execute_egate_command    ${pmi_cmd}
#     airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=1
#     airphone_set_traffic_type    ${UE_ID_SA}    ${PDU_ID}    internal
#     Airphone Pdu Session Setup    ${UE_ID_SA}    ${PDU_ID}    ${SLICE_ID}    ${UE_ID_SA}
#     #check zerodot15
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}step2_ue_attach_SA   unzip=TRUE
#     Wait Throughput Timer    5
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/RRC_coderate_zeroDot08.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}step2_ue_attach_SA
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    5
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step2_ue_attach_SA
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach_SA${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step2_ue_attach_SA${/}
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step2_ue_attach_SA/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step2_ue_attach_SA' File
# 
# Step3:send A1 report to add scell
#     Start Collect GNB and AP Syslog in 'step3_send_A1' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    5
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=1 meas_obj_type\=nr
#     airphone_execute_egate_command    ue_measurement\_send\_nr id\=1 meas_id\=1 event\=A1 srsrp_nr\=80    pass_regexp=sCellToAddModList
#     #check zerodot25
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}step3_send_A1   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/RRC_coderate_zeroDot15.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}step3_send_A1
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_A1${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step3_send_A1${/}
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step3_send_A1
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step3_send_A1/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step3_send_A1' File
# 
# Step4:send A2 report to release scell
#     Start Collect GNB and AP Syslog in 'step4_send_A2' File
#     #Start GNB BIP Log
#     #Start AP BIP Log
#     #Start GNB Ttitrace With Streaming Mode
#     #Wait Throughput Timer    5
#     airphone_execute_egate_command    ue_meas_cfg_disp id\=1 meas_obj_type\=nr
#     airphone_execute_egate_command
#     ...    ue_measurement_send_nr event\=A2 id\=1 meas_id\=2 rs_type\=ssb scell\=1 scell_rsrp\=30    pass_regexp=sCellToReleaseList
#     #check zerodot15
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}step4_send_A2   unzip=TRUE
#     check_log_with_au2anlysis    ini_path=${CURDIR}/A2A_log_Check/RRC_coderate_zeroDot08.ini    log_need_to_check=p
#     ...    save_log_directory=${TEST_LOG_DIRECTORY()}step4_send_A2
#     #Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_send_A2${/}
#     #Stop AP BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}step4_send_A2${/}
#     #${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${TEST_LOG_DIRECTORY()}step4_send_A2
#     #Decoder Tttirace From Pcap To Csv    ${pacp}    ${TEST_LOG_DIRECTORY()}step4_send_A2/output
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step4_send_A2' File
# 
# Step5:Detach UE
#     Comment    Start Collect GNB and AP Syslog in 'step5_Detach UE' File
#     airphone_sa_stop_data_traffic    ${UE_ID_SA}   DL    pdu_id=${PDU_ID}
#     airphone_sa_detach    ${UE_ID_SA}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'step5_Detach UE' File
# 
# 
# add_ca_relation_CB7922
#     [Arguments]    ${scfc_path}
#     #L2RT intra band CA Cell2&Cell3 Inter L2RT inter band CA Cell4&Cell1 Intra L2RT intra band CA Cell1&Cell2 Intra L2RT inter band CA Cell3&Cell4
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=1    lcrid=2
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=2    lcrid=3
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=3    lcrid=4
#     add_nrrel_extend_parameter_on_cell    xml_path=${scfc_path}    cellid=4    lcrid=1
