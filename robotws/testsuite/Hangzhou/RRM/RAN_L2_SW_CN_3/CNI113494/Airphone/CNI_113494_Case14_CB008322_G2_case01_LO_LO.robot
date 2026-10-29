# *** Settings ***
# Documentation     Author: xuemin.ma@nokia-sbell.com
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_MP_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_xueminm
# Test Timeout      120 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library           taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U.xml
# ${AIRPHONE_NAME}      AP_iphy_AQQL_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U_9496.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.cfg
# @{LOG_NAME_LIST}      egatelog    gnb_snapshot
# ${cellDepType}                    text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                           text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                     text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                     text|8DL4UL|//*[@name\="nrCellType"]
# ${actUeCsirsCoexistCellCsirs}     text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${actCsirsMultiplexing}           text|true|//*[@name\="actCsirsMultiplexing"]
# ${actDlSrsBm}                     text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                     text|false|//*[@name\="actUlSrsBm"]
# ${actDlSrsSubbandBm}              text|true|//*[@name\="actDlSrsSubbandBm"]
# ${actSrsBeamFallbackByRetrx}      text|true|//*[@name\="actSrsBeamFallbackByRetrx"]
# ${actUlClosedLoopPwrCtrl}         text|disabled|//*[@name\="actUlClosedLoopPwrCtrl"]
# ${actCDrx}                        text|false|//*[@name\="actCDrx"]
# ${actFdmScheduling}               text|true|//*[@name\="actFdmScheduling"]
# ${actDlMuMimoEnh}                 text|false|//*[@name\="actDlMuMimoEnh"]
# ${actDl256Qam}                    text|false|//*[@name\="actDl256Qam"]
# ${actUl256Qam}                    text|false|//*[@name\="actUl256Qam"]
# ${actIncreasedFdmUsersPerSlot}    text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
# ${frameStructureType}             text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}              text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}              text|3ms|//*[@name\="lteToNrFrameShift"]
# ${tdLteUlDlConfig}                text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ulDlDataSlotRatio}              text|3/7|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}        text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}               text|slots40|//*[@name\="srsUePeriodicity"]
# ${cSRS}                           text|62|//*[@name\="cSRS"]
# ${bSRS}                           text|2|//*[@name\="bSRS"]
# ${srsPowerThresholdForDlBm}       text|-1200|//*[@name\="srsPowerThresholdForDlBm"]
# ${srsTypeAllocForDlBm}            text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
# ${bfSubbandSize}                  text|16 PRBs|//*[@name\="bfSubbandSize"]
# ${maxNumUeSrs}                    text|4|//*[@name\="maxNumUeSrs"]
# ${srsQualityThreshold}            text|-1150|//*[@name\="srsQualityThreshold"]
# ${seHysteresis}                   text|60|//*[@name\="seHysteresis"]
# ${srsSinrThreshold}                text|-400|//*[@name\="srsSinrThreshold"]
# ${actCustomBsr}                   text|true|//*[@name\="actCustomBsr"]
# ${customBeamSetName}              text|BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001|//*[@name\="customBeamSetName"]
# ${tiltOffset}                     text|0|//*[@name\="tiltOffset"]
# ${nrBtsBeamRefinementP2}          text|true|//*[@name\="nrBtsBeamRefinementP2"]
# ${maxCsirsNumber}                 text|2|//*[@name\="maxCsirsNumber"]
# ${csirsPower}                     text|3|//*[@name\="csirsPower"]
# ${miNrSrsQuality}                 text|5min|//*[@name\="miNrSrsQuality"]
# ${miNrBeamforming2}               text|5min|//*[@name\="miNrBeamforming2"]
# ${miNrDlHarq}                     text|5min|//*[@name\="miNrDlHarq"]
# ${miNrUlHarq}                     text|5min|//*[@name\="miNrUlHarq"]
# ${miNrDlHarqLowSEMCS}             text|5min|//*[@name\="miNrDlHarqLowSEMCS"]
# ${miNrUlHarqLowSEMCS}             text|5min|//*[@name\="miNrUlHarqLowSEMCS"]
# ${miNrUlHarqOne}                  text|5min|//*[@name\="miNrUlHarqOne"]
# ${csirsNumberWithinReportPeriod_Set1}                     text|2|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# ${bwp_profile7}                   text|MRBTS-1/NRBTS-1/BWP_PROFILE-7|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile77}                  text|MRBTS-1/NRBTS-1/BWP_PROFILE-77|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# 
# ${par_of_bsr_name}                BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-300,-300,-300,-300
# 
# *** Test Cases ***
# CNI_113494_Case14_PDSCH_iBLER_counters_SRS_based_beam_change_to_PMI_beam
#     Step1:Commission the above configuration on WebUI
#     Step2:Attach UE and start full buffer
#     Step3:Trigger Continues bler
#     Step4:Clear bler
#     Step5:Trigger bler higher than rdRtBeamHarqNackPercentage
#     Step6:higher bler than step5
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start capture GNB and AP Syslog in 'Step1_before_onair' File
# 	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     Wts Execute Aashell Command
# 	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
#     modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
# 	add_xml_element     ${scfc_path}    ${scfc_path}     <p name="lteToNrFrameShift">3ms</p>|//*[@name\='tddFrameStructure']/item
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tdLteUlDlConfig">tdLteConfig2</p>|//*[@name\='tddFrameStructure']/item
#     add_periodicCsiAcquisition_list_in_cells    ${scfc_path}
#     ${modify_list}    create list
#     ...    ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUeCsirsCoexistCellCsirs}    ${actCsirsMultiplexing}
#     ...    ${actDlSrsBm}    ${actUlSrsBm}    ${actDlSrsSubbandBm}    ${actUlClosedLoopPwrCtrl}    ${actCDrx}    ${actFdmScheduling}
#     ...    ${actDlMuMimoEnh}    ${actDl256Qam}    ${actUl256Qam}    ${actIncreasedFdmUsersPerSlot}    ${frameStructureType}
#     ...    ${guardPeriodLength}    ${lteToNrFrameShift}    ${tdLteUlDlConfig}    ${ulDlDataSlotRatio}    ${prachConfigurationIndex}
#     ...    ${srsUePeriodicity}    ${cSRS}    ${bSRS}    ${srsPowerThresholdForDlBm}    ${srsTypeAllocForDlBm}    ${bfSubbandSize}
#     ...    ${maxNumUeSrs}    ${srsQualityThreshold}    ${actCustomBsr}    ${customBeamSetName}    ${actSrsBeamFallbackByRetrx}
#     ...    ${tiltOffset}    ${nrBtsBeamRefinementP2}    ${maxCsirsNumber}    ${csirsPower}     ${csirsNumberWithinReportPeriod_Set1}
#     ...    ${bwp_profile7}    ${bwp_profile77}    ${seHysteresis}   ${srsSinrThreshold}
#     ...    ${miNrSrsQuality}    ${miNrBeamforming2}    ${miNrDlHarq}    ${miNrUlHarq}    ${miNrDlHarqLowSEMCS}    ${miNrUlHarqLowSEMCS}
# 	...    ${miNrUlHarqOne}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    ${par_of_bsr_name}
# 	Add L2PS Deubg Logs
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
# 	[Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Add L2PS Deubg Logs
#     ${debuglogs}    create list    level=DBG\n    L2.L2_PS.DEBUG=1\n    L2.L2_PS.DL.SUBBAND_BEAMFORMING=1\n    L2.L2_PS.SRS_BASED_BM=1\n
# 	Active L2ps Feature Debug Traces    ${debuglogs}
# 	TAF_SSH.connect to    192.168.255.1   toor4nsn    oZPS0POrRieRtu   alias=bsh
# 	TAF_SSH.execute    rm /ffs/run/HashContainer*    connection=bsh
# 
# modify_swconfig_by_CB008322
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}
# 	${local_save_path}=     Download All Common Config Files From Golden Server
# 	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
# 	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
# 	add_txt_node    0x9D0000:1        #as PM counter period update to 15/15=1min
# 	add_txt_node    0x580477:1       #The UL CoMa log enabling flag(rdUlSrsCoMaLogEnabled)
#     add_txt_node    0x580264:1          #The DL CoMa log enabling flag(rdDlSrsLogControl, bit0)
# 	add_txt_node    0x5805bf:0x20         #rdRtBeamHarqNackPercent
#     teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Step2:Attach UE and start full buffer
#     Start Collect GNB and AP Syslog in 'Step2_attach' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Attach SA ue with capability    1    CA_P2_8x4_t2r4_n2
#     airphone_set_traffic_type    ue_id=1    pdu_id=1
#     airphone_pdu_session_setup    ue_id=1    pdu_id=1
#     Wait '3s' for stable running
#     SA send multiple trf data    1    DL    175M    8
#     SA send multiple trf data    1    UL    175M    2
#     Set UE'1' to UE'1' position
#     Wait Throughput Timer    15
#     ${Dl_throughput} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Ul_throughput} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     Start GNB Ttitrace With Streaming Mode
#     Wait '2s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
# 	Get And Validate Counters    ${save_log}
# 	run keyword and continue on failure    should be true    ${PDSCH_INI_TX} == ${legacy_counter_PDSCH_INITX}
# 	run keyword and continue on failure    should be true    ${PDSCH_SUC_INI_TX} == ${legacy_counter_PDSCH_SUCC_INI}
# 	run keyword and continue on failure    should be true    ${PUSCH_INI_TX} == ${legacy_counter_PUSCH_INITX}
# 	run keyword and continue on failure    should be true    ${PUSCH_SUC_INI_TX} == ${legacy_counter_PUSCH_SUCC_INI}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
# 
# Set UE'${ue_id}' to UE'${ue_id_end}' position
#     : FOR    ${u_id}    IN RANGE    ${ue_id}    ${ue_id_end}+1
#     \    Airphone Execute Egate Command    ${PROFILE1}
#     \    Airphone Execute Egate Command    ue_testmode_set_nr id\=${u_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     \    Wait '2s' for stable running
# 
# Step3:Trigger Continues bler
#     Start Collect GNB and AP Syslog in 'Step3_bler' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_bler
#     Airphone Execute Egate Command    bler_testmode_nr profile_id\=2 dl_bler\=100,100,100
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=2 action\=activate
#     Start GNB Ttitrace With Streaming Mode
#     Wait '2s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_bler
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_bler_dl.csv    ${save_log}/target_tti_bler_dl.csv
# 	#check beam fallback to PMI due to Continues bler,wb srs not release
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/../../CB008322/Airphone/log_check/G2_case01_wb_bler.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     Get And Validate Counters    ${save_log}
# 	run keyword and continue on failure    should be true    ${PDSCH_INI_TX} == ${legacy_counter_PDSCH_INITX}
# 	run keyword and continue on failure    should be true    ${PDSCH_SUC_INI_TX} == ${legacy_counter_PDSCH_SUCC_INI}
# 	run keyword and continue on failure    should be true    ${PUSCH_INI_TX} == ${legacy_counter_PUSCH_INITX}
# 	run keyword and continue on failure    should be true    ${PUSCH_SUC_INI_TX} == ${legacy_counter_PUSCH_SUCC_INI}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step3_bler' File
# 
# Step4:Clear bler
#     Start Collect GNB and AP Syslog in 'Step4_clear_bler' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_clear_bler
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=2 action\=deactivate
#     Start GNB Ttitrace With Streaming Mode
#     Wait '2s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
#     #check RT beam works
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/../../CB008322/Airphone/log_check/G2_case01_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
# 	Get And Validate Counters    ${save_log}
# 	run keyword and continue on failure    should be true    ${PDSCH_INI_TX} == ${legacy_counter_PDSCH_INITX}
# 	run keyword and continue on failure    should be true    ${PDSCH_SUC_INI_TX} == ${legacy_counter_PDSCH_SUCC_INI}
# 	run keyword and continue on failure    should be true    ${PUSCH_INI_TX} == ${legacy_counter_PUSCH_INITX}
# 	run keyword and continue on failure    should be true    ${PUSCH_SUC_INI_TX} == ${legacy_counter_PUSCH_SUCC_INI}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step4_clear_bler' File
# 
# Step5:Trigger bler higher than rdRtBeamHarqNackPercentage
#     Start Collect GNB and AP Syslog in 'Step5_high_bler' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_high_bler
#     Start GNB Ttitrace With Streaming Mode
#     Airphone Execute Egate Command    bler_testmode_nr profile_id\=3 dl_bler\=400,100,100
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=3 action\=activate
#     Wait '1s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_bler
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_bler_dl.csv    ${save_log}/target_tti_bler_dl.csv
# 	#check wb srs release
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/../../CB008322/Airphone/log_check/G2_case01_wb_release.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     Get And Validate Counters    ${save_log}
# 	run keyword and continue on failure    should be true    ${PDSCH_INI_TX} == ${legacy_counter_PDSCH_INITX}
# 	run keyword and continue on failure    should be true    ${PDSCH_SUC_INI_TX} == ${legacy_counter_PDSCH_SUCC_INI}
# 	run keyword and continue on failure    should be true    ${PUSCH_INI_TX} == ${legacy_counter_PUSCH_INITX}
# 	run keyword and continue on failure    should be true    ${PUSCH_SUC_INI_TX} == ${legacy_counter_PUSCH_SUCC_INI}
#     [Teardown]    Stop Collect GNB and AP Syslog in 'Step5_high_bler' File
# 
# Step6:higher bler than step5
#     Start Collect GNB and AP Syslog in 'Step6_higher_bler' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6_higher_bler
#     Start GNB Ttitrace With Streaming Mode
#     Airphone Execute Egate Command    bler_testmode_nr profile_id\=3 dl_bler\=700,100,100
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=3 action\=activate
#     Wait '1s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_bler
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_bler_dl.csv    ${save_log}/target_tti_bler_dl.csv
#     Get And Validate Counters    ${save_log}
# 	run keyword and continue on failure    should be true    ${PDSCH_INI_TX} == ${legacy_counter_PDSCH_INITX}
# 	run keyword and continue on failure    should be true    ${PDSCH_SUC_INI_TX} == ${legacy_counter_PDSCH_SUCC_INI}
# 	run keyword and continue on failure    should be true    ${PUSCH_INI_TX} == ${legacy_counter_PUSCH_INITX}
# 	run keyword and continue on failure    should be true    ${PUSCH_SUC_INI_TX} == ${legacy_counter_PUSCH_SUCC_INI}
# 	[Teardown]    Stop Collect GNB and AP Syslog in 'Step6_higher_bler' File
# 
# Get And Validate Counters
#     [Arguments]    ${save_log}
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${save_log}${/}
#     ${PDSCH_INI_TX_SSB_BEAM}
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00043     cell_id=1
#     ${PDSCH_SUC_INI_TX_SSB_BEAM}
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00044     cell_id=1
#     ${PUSCH_INI_TX_SSB_BEAM}
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00045     cell_id=1
#     ${PUSCH_SUC_INI_TX_SSB_BEAM}
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00046     cell_id=1
#     ${PDSCH_INI_TX_REFINED_BEAM}
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00047     cell_id=1
#     ${PDSCH_SUC_INI_TX_REFINED_BEAM}
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00048     cell_id=1
#     ${PUSCH_INI_TX_REFINED_BEAM}
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00028     cell_id=1
#     ${PUSCH_SUC_INI_TX_REFINED_BEAM}
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00029     cell_id=1
#     ${PDSCH_INI_TX_PMI_BEAM}
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00030     cell_id=1
#     ${PDSCH_SUC_INI_TX_PMI_BEAM}
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00031     cell_id=1
#     ${PDSCH_INI_TX_DFTTAP_BEAM}
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00032     cell_id=1
#     ${PDSCH_SUC_INI_TX_DFTTAP_BEAM}
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00033     cell_id=1
#     ${PUSCH_INI_TX_DFTTAP_BEAM}
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00034     cell_id=1
#     ${PUSCH_SUC_INI_TX_DFTTAP_BEAM}
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00035     cell_id=1
#     ${PDSCH_INI_TX_DFTNTAP_BEAM}
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00036     cell_id=1
#     ${PDSCH_SUC_INI_TX_DFTNTAP_BEAM}
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00037     cell_id=1
#     ${PUSCH_INI_TX_DFTNTAP_BEAM}
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00038     cell_id=1
#     ${PUSCH_SUC_INI_TX_DFTNTAP_BEAM}
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00039     cell_id=1
#     ${PDSCH_INI_TX_SUBBAND_BEAM}
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00040     cell_id=1
#     ${PDSCH_SUC_INI_TX_SUBBAND_BEAM}
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00041     cell_id=1
# 
# 	
# 	${tmp_1}    Evaluate    (${PDSCH_INI_TX_SSB_BEAM}+${PDSCH_INI_TX_REFINED_BEAM}+${PDSCH_INI_TX_PMI_BEAM})
# 	${PDSCH_INI_TX}     Evaluate    (${tmp_1}+ ${PDSCH_INI_TX_DFTTAP_BEAM}+${PDSCH_INI_TX_DFTNTAP_BEAM}+${PDSCH_INI_TX_SUBBAND_BEAM})
# 	${tmp_2}     Evaluate    (${PDSCH_SUC_INI_TX_SSB_BEAM}+${PDSCH_SUC_INI_TX_REFINED_BEAM}+${PDSCH_SUC_INI_TX_PMI_BEAM})
# 	${PDSCH_SUC_INI_TX}     Evaluate    (${tmp_2}++${PDSCH_SUC_INI_TX_DFTTAP_BEAM}+${PDSCH_SUC_INI_TX_DFTNTAP_BEAM}+${PDSCH_SUC_INI_TX_SUBBAND_BEAM})
# 
# 	${PUSCH_INI_TX}     Evaluate    (${PUSCH_INI_TX_SSB_BEAM}+${PUSCH_INI_TX_REFINED_BEAM}+${PUSCH_INI_TX_DFTTAP_BEAM}+${PUSCH_INI_TX_DFTNTAP_BEAM})
# 	${tmp_3}     Evaluate    (${PUSCH_SUC_INI_TX_SSB_BEAM}+${PUSCH_SUC_INI_TX_REFINED_BEAM})
# 	${PUSCH_SUC_INI_TX}     Evaluate    (${tmp_3}+${PUSCH_SUC_INI_TX_DFTTAP_BEAM}+${PUSCH_SUC_INI_TX_DFTNTAP_BEAM})
# 	
# 	@{value_list_PDSCH_INITX_64TBL_MCS_XX}        Create List
# 	@{value_list_PDSCH_INITX_LOWSE_MCS_XX}        Create List
# 	@{value_list_PDSCH_SUCC_INI_64TBL_MCS_XX}     Create List
# 	@{value_list_PDSCH_SUCC_INI_LOWSE_MCS_XX}     Create List
# 	@{value_list_PDSCH_INI_256TBL_MCS_XX}         Create List
# 	@{value_list_PDSCH_SUCC_INI_256TBL_MCS_XX}    Create List
# 	@{value_list_PUSCH_CP_INITX_64TBL_MCS_XX}     Create List
# 	@{value_list_PUSCH_CP_INI_LOWSE_MCS_XX}       Create List
# 	@{value_list_PUSCH_DFT_INI_64TBL_MCS_XX}      Create List
# 	@{value_list_PUSCH_CP_INI_256TBL_MCS_XX}      Create List
# 	@{value_list_PUSCH_CP_SUCC_INI_64TBL_MCS_XX}      Create List
# 	@{value_list_PUSCH_CP_SUCC_INI_256TBL_MCS_XX}      Create List
# 	@{value_list_PUSCH_DFT_SUCC_INI_64TBL_MCS_XX}      Create List
# 	@{value_list_PUSCH_CP_SUCC_INI_LOWSE_MCS_XX}      Create List
# 
# 	:FOR    ${i}    IN RANGE     00     29
# 	\    ${index}     evaluate     "${i}".zfill(2)
# 	\    ${value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=1
# 	\    append to list     ${value_list_PDSCH_INITX_64TBL_MCS_XX}   ${value}
# 	\    ${value_2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=1
# 	\    append to list     ${value_list_PDSCH_INITX_LOWSE_MCS_XX}   ${value_2}
# 	\    ${value_3}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=1
# 	\    append to list     ${value_list_PDSCH_SUCC_INI_64TBL_MCS_XX}   ${value_3}
# 	\    ${value_4}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=1
# 	\    append to list     ${value_list_PDSCH_SUCC_INI_LOWSE_MCS_XX}   ${value_4}
# 	\    ${value_7}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=1
# 	\    append to list     ${value_list_PUSCH_CP_INITX_64TBL_MCS_XX}   ${value_7}
# 	\    ${value_8}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=1
# 	\    append to list     ${value_list_PUSCH_CP_INI_LOWSE_MCS_XX}   ${value_8}
# 	\    ${value_11}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=1
# 	\    append to list     ${value_list_PUSCH_CP_SUCC_INI_64TBL_MCS_XX}   ${value_11}
# 	\    ${value_14}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=1
# 	\     append to list     ${value_list_PUSCH_CP_SUCC_INI_LOWSE_MCS_XX}   ${value_14}
# 	${PDSCH_INITX_64TBL_MCS_XX}        Evaluate    sum(${value_list_PDSCH_INITX_64TBL_MCS_XX})
# 	${PDSCH_INITX_LOWSE_MCS_XX}        Evaluate    sum(${value_list_PDSCH_INITX_LOWSE_MCS_XX})
# 	${PDSCH_SUCC_INI_64TBL_MCS_XX}     Evaluate    sum(${value_list_PDSCH_SUCC_INI_64TBL_MCS_XX})
# 	${PDSCH_SUCC_INI_LOWSE_MCS_XX}     Evaluate    sum(${value_list_PDSCH_SUCC_INI_LOWSE_MCS_XX})
# 	${PUSCH_CP_INITX_64TBL_MCS_XX}     Evaluate    sum(${value_list_PUSCH_CP_INITX_64TBL_MCS_XX})
# 	${PUSCH_CP_INI_LOWSE_MCS_XX}       Evaluate    sum(${value_list_PUSCH_CP_INI_LOWSE_MCS_XX})
# 	${PUSCH_CP_SUCC_INI_64TBL_MCS_XX}     Evaluate    sum(${value_list_PUSCH_CP_SUCC_INI_64TBL_MCS_XX})
# 	${PUSCH_PUSCH_CP_SUCC_INI_LOWSE_MCS_XX}       Evaluate    sum(${value_list_PUSCH_CP_SUCC_INI_LOWSE_MCS_XX})
# 
# 	:FOR    ${i}    IN RANGE     00     28
# 	\    ${index}     evaluate     "${i}".zfill(2)
# 	\    ${value_5}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=1
# 	\     append to list     ${value_list_PDSCH_INI_256TBL_MCS_XX}   ${value_5}
# 	\    ${value_6}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=1
# 	\     append to list     ${value_list_PDSCH_SUCC_INI_256TBL_MCS_XX}   ${value_6}
# 	\    ${value_9}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=1
# 	\     append to list     ${value_list_PUSCH_DFT_INI_64TBL_MCS_XX}   ${value_9}
# 	\    ${value_10}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=1
# 	\     append to list     ${value_list_PUSCH_CP_INI_256TBL_MCS_XX}   ${value_10}
# 	\    ${value_13}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=1
# 	\     append to list     ${value_list_PUSCH_DFT_SUCC_INI_64TBL_MCS_XX}   ${value_13}
# 	\    ${value_12}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=1
# 	\    append to list     ${value_list_PUSCH_CP_SUCC_INI_256TBL_MCS_XX}   ${value_12}
# 	${PDSCH_INI_256TBL_MCS_XX}          Evaluate    sum(${value_list_PDSCH_INI_256TBL_MCS_XX})
# 	${PDSCH_SUCC_INI_256TBL_MCS_XX}     Evaluate    sum(${value_list_PDSCH_SUCC_INI_256TBL_MCS_XX})
# 	${PUSCH_DFT_INI_64TBL_MCS_XX}       Evaluate    sum(${value_list_PUSCH_DFT_INI_64TBL_MCS_XX})
# 	${PUSCH_CP_INI_256TBL_MCS_XX}       Evaluate    sum(${value_list_PUSCH_CP_INI_256TBL_MCS_XX})
# 	${PUSCH_DFT_SUCC_INI_64TBL_MC_XX}       Evaluate    sum(${value_list_PUSCH_DFT_SUCC_INI_64TBL_MCS_XX})
# 	${PUSCH_CP_SUCC_INI_256TBL_MCS_XX}       Evaluate    sum(${value_list_PUSCH_CP_SUCC_INI_256TBL_MCS_XX})
# 
#     ${legacy_counter_PDSCH_INITX}        Evaluate    (${PDSCH_INITX_64TBL_MCS_XX}+${PDSCH_INI_256TBL_MCS_XX}+${PDSCH_INITX_LOWSE_MCS_XX})
# 	${legacy_counter_PDSCH_SUCC_INI}     Evaluate   (${PDSCH_SUCC_INI_64TBL_MCS_XX}+${PDSCH_SUCC_INI_256TBL_MCS_XX}+${PDSCH_SUCC_INI_LOWSE_MCS_XX})
# 	
# 	${PUSCH_DFT_INI_64TBL_SAG_R2}          
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007     cell_id=1
#     ${PUSCH_DFT_INI_64TBL_SAG_R4}          
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013     cell_id=1
# 	${PUSCH_DFT_SUC_INI_64TBL_SAG_R2}      
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009     cell_id=1
#     ${PUSCH_DFT_SUC_INI_64TBL_SAG_R4}      
# 	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015     cell_id=1
# 	
# 	${tmp_00}        Evaluate    (${PUSCH_CP_INITX_64TBL_MCS_XX}+${PUSCH_DFT_INI_64TBL_MCS_XX}+${PUSCH_CP_INI_256TBL_MCS_XX})
# 	${legacy_counter_PUSCH_INITX}    Evaluate    (${tmp_00}+${PUSCH_CP_INI_LOWSE_MCS_XX}+${PUSCH_DFT_INI_64TBL_SAG_R2}+${PUSCH_DFT_INI_64TBL_SAG_R4})
# 	
# 	${tmp_01}        Evaluate    (${PUSCH_CP_SUCC_INI_64TBL_MCS_XX}+${PUSCH_DFT_SUCC_INI_64TBL_MC_XX}+${PUSCH_CP_SUCC_INI_256TBL_MCS_XX})
# 	${tmp_02}        Evaluate    (${tmp_01}+${PUSCH_PUSCH_CP_SUCC_INI_LOWSE_MCS_XX})
# 	${legacy_counter_PUSCH_SUCC_INI}     Evaluate   (${tmp_02}+${PUSCH_DFT_SUC_INI_64TBL_SAG_R2}+${PUSCH_DFT_SUC_INI_64TBL_SAG_R4})
# 
# 	Set test Variable    ${PDSCH_INI_TX}
# 	Set test Variable    ${PDSCH_SUC_INI_TX}
# 	Set test Variable    ${legacy_counter_PDSCH_INITX}
# 	Set test Variable    ${legacy_counter_PDSCH_SUCC_INI}
# 	Set test Variable    ${PUSCH_INI_TX}     
# 	Set test Variable    ${PUSCH_SUC_INI_TX} 
# 	Set test Variable    ${legacy_counter_PUSCH_INITX}
# 	Set test Variable    ${legacy_counter_PUSCH_SUCC_INI}
# 
# 	#    Calculate PDSCH ibler
#     #iBLER for PDSCH (Initial BLER =100 * (initial transmissions sent - initial transmissions success) / (initial transmissions sent))
#     ${iBler_pdsch_ssb}          Run Keyword If    ${PDSCH_INI_TX_SSB_BEAM}!= 0        
# 	...    Evaluate    100*(${PDSCH_INI_TX_SSB_BEAM}-${PDSCH_SUC_INI_TX_SSB_BEAM})/${PDSCH_INI_TX_SSB_BEAM}
# 	${iBler_pdsch_refine}       Run Keyword If    ${PDSCH_INI_TX_REFINED_BEAM}!= 0     
# 	...    Evaluate    100*(${PDSCH_INI_TX_REFINED_BEAM}-${PDSCH_SUC_INI_TX_REFINED_BEAM})/${PDSCH_INI_TX_REFINED_BEAM}
# 	${iBler_pdsch_pmi}          Run Keyword If    ${PDSCH_INI_TX_PMI_BEAM}!= 0
# 	...    Evaluate    100*(${PDSCH_INI_TX_PMI_BEAM}-${PDSCH_SUC_INI_TX_PMI_BEAM})/${PDSCH_INI_TX_PMI_BEAM}
# 	${iBler_pdsch_dftNtap}      Run Keyword If    ${PDSCH_INI_TX_DFTNTAP_BEAM}!= 0
# 	...    Evaluate    100*(${PDSCH_INI_TX_DFTNTAP_BEAM}-${PDSCH_SUC_INI_TX_DFTNTAP_BEAM})/${PDSCH_INI_TX_DFTNTAP_BEAM}
# 	${iBler_pdsch_rt}           Run Keyword If    ${PDSCH_INI_TX_SUBBAND_BEAM}!= 0
# 	...    Evaluate    100*(${PDSCH_INI_TX_SUBBAND_BEAM}-${PDSCH_SUC_INI_TX_SUBBAND_BEAM})/${PDSCH_INI_TX_SUBBAND_BEAM}
#     
# 	Log To Console    \n----------PDSCH All Beam Type iBler counter--------
# 	Log To Console    iBler_pdsch_ssb:${iBler_pdsch_ssb}    
# 	Log To Console    iBler_pdsch_refine:${iBler_pdsch_refine} 
# 	Log To Console    iBler_pdsch_pmi:${iBler_pdsch_pmi}    
# 	Log To Console    iBler_pdsch_dftNtap:${iBler_pdsch_dftNtap}
#     Log To Console    iBler_pdsch_rt: ${iBler_pdsch_rt}     
# 	Log To Console    \n----------PUSCH All Beam Type counter--------
# 	Log To Console    PUSCH_INI_TX:${PUSCH_INI_TX}     
#     Log To Console    PUSCH_SUC_INI_TX:${PUSCH_SUC_INI_TX} 
#     Log To Console    legacy_counter_PUSCH_INITX:${legacy_counter_PUSCH_INITX}
#     Log To Console    legacy_counter_PUSCH_SUCC_INI:${legacy_counter_PUSCH_SUCC_INI}
