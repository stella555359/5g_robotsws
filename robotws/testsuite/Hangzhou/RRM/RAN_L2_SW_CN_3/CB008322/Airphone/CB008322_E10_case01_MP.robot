# *** Settings ***
# Documentation     Author: jing.pan@nokia-sbell.com
# ...
# ...          QC case full name:
# ...          CB008322_E10_case001_Interworking with RIM_RI_detection_and_mitigation
# ...          This case will verify interworking with remote interference mitigation (RIM)
# ...          When the cell enters RIM, the beams used for PDSCH and UE specific CSI-RS is legacy SSB/refined beams.
# ...          No UE will be configured with WB SRS after cell enters RIM.
# ...          When the cell stops RIM, the beams used for PDSCH and UE specific CSI-RS is SRS based beam depending WB/SB SRS.
# ...          UE can be configured with WB SRS if the criteria meets after cell stops RIM.
# 
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_mqin
# Test Timeout      90 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library           taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# Library           ta5g_enb
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIM_ABIP_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U.xml
# ${AIRPHONE_NAME}      AP_iphy_AQQL_ASIM_ABIP_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U.xml
# ${WTS_NAME}           wts_config_ASIM_ABIP_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_UEs.cfg
# @{LOG_NAME_LIST}      egatelog\    gnb_snapshot    ap_snapshot
# #    sosreport
# #8322
# ${actDlSrsSubbandBm}              text|true|//*[@name\="actDlSrsSubbandBm"]
# ${bfSubbandSize}                  text|32 PRBs|//*[@name\="bfSubbandSize"]
# #${srsQualityThreshold}            text|-1200|//*[@name\="srsQualityThreshold"]
# ${maxNumUeSrs}                    text|4|//*[@name\="maxNumUeSrs"]
# ${srsPowerThreshold}                  text|-1200|//*[@name\="srsPowerThreshold"]
# ${seThreshold}                        text|80|//*[@name\="seThreshold"]
# ${seHysteresis}                       text|50|//*[@name\="seHysteresis"]
# ${rankThreshold}                      text|2|//*[@name\="rankThreshold"]
# ${prbSampleHighLowPercentage}         text|60|//*[@name\="prbSampleHighLowPercentage"]
# ${rlqGoodPercentage}                  text|60|//*[@name\="rlqGoodPercentage"]
# ${numWbSrsConfigSample}               text|20|//*[@name\="numWbSrsConfigSample"]
# ${prbRatioHysteresis}                 text|10|//*[@name\="prbRatioHysteresis"]
# ${prbRatioThreshold}                  text|10|//*[@name\="prbRatioThreshold"]
# ${srsSinrThreshold}                text|-400|//*[@name\="srsSinrThreshold"]
# 
# #E10
# ${actNrRim}                       text|RI detection and mitigation|//*[@name\="actNrRim"]
# ${nrRiThresDropHeight}            text|3|//*[@name\="nrRiThresDropHeight"]
# ${nrRiThresDurationRatio}         text|60|//*[@name\="nrRiThresDurationRatio"]
# ${nrRimRarTpcCommand}             text|2dB|//*[@name\="nrRimRarTpcCommand"]
# 
# ${cellDepType}                    text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                           text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                     text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                     text|8DL4UL|//*[@name\="nrCellType"]
# ${actUeCsirsCoexistCellCsirs}     text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${actCsirsMultiplexing}           text|true|//*[@name\="actCsirsMultiplexing"]
# ${actDlSrsBm}                     text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                     text|false|//*[@name\="actUlSrsBm"]
# ${actFdmScheduling}               text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}             text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}              text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}              text|3ms|//*[@name\="lteToNrFrameShift"]
# ${tdLteUlDlConfig}                text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ulDlDataSlotRatio}              text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}        text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}               text|slots160|//*[@name\="srsUePeriodicity"]
# ${cSRS}                           text|63|//*[@name\="cSRS"]
# ${bSRS}                           text|2|//*[@name\="bSRS"]
# ${srsPowerThresholdForDlBm}       text|-1000|//*[@name\="srsPowerThresholdForDlBm"]
# ${srsTypeAllocForDlBm}            text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
# ${bfSubbandSize}                  text|32 PRBs|//*[@name\="bfSubbandSize"]
# ${maxNumUeSrs}                    text|4|//*[@name\="maxNumUeSrs"]
# ${actCustomBsr}                   text|true|//*[@name\="actCustomBsr"]
# ${customBeamSetName}              text|BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001|//*[@name\="customBeamSetName"]
# ${actIncreasedFdmUsersPerSlot}    text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
# ${actDlMuMimoEnh}                 text|false|//*[@name\="actDlMuMimoEnh"]
# ${actDl256Qam}                    text|true|//*[@name\="actDl256Qam"]
# ${actUl256Qam}                    text|true|//*[@name\="actUl256Qam"]
# ${dllaDeltaCqiMax}                text|0|//*[@name\="dllaDeltaCqiMax"]
# #${miNrMacSduReport}               text|15min|//*[@name\="miNrMacSduReport"]
# ${par_of_bsr_name}                BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
# ${bwp_profile8}                   text|MRBTS-1/NRBTS-1/BWP_PROFILE-8|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile85}                  text|MRBTS-1/NRBTS-1/BWP_PROFILE-85|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# 
# ${pattern}                        CA_P2_8x4_t2r4_n2
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-150,-150,-150,-150
# 
# ${SET_PROFILE1}    ue_testmode_set_nr id=11 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
# 
# ${NOISE_POWER_FOR_RI}=     SEPARATOR=
# ...                        -63,-65,-67,-69,-71,-73,-75,-79,-81,-83,-85,-87,-89,-93,-95,-98,-101,-104,
# ...                        -105,-99,-95,-90,-85,-80,-75,-71,-67,-64,-60,-55,-50,-47
# 
# *** Test Cases ***
# CB008322_E10_case01_Interworking with RIM_RI_detection_and_mitigation
#     Step1:Commission the above configuration on WebUI
#     Step2:5 UEs with t2r4 capability attach to cell-1
#     Step3:Send DL full buffer to UE1-5
#     Step4:Trigger RI mitigation
#     Step5:UE2-4 release, UE-6 attach to Cell-1
#     Step6:Stop RI mitigation
#     Step7:UE-7 attach to Cell-1
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start capture GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     ${iphy_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}iphy.xml
#     copy_file    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}    ${iphy_path}
#     ${mod_iphy}    create list     text|pmiBeams|//dlFeatures
#     remove_xml_element     ${iphy_path}      ${iphy_path}    ${mod_iphy}
#     change_iphy_rru_version    ${iphy_path}
#     #remove_xml_element     ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}      ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}    ${mod_iphy}
#     #change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="lteToNrFrameShift">3ms</p>|//*[@name\='tddFrameStructure']/item
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tdLteUlDlConfig">tdLteConfig2</p>|//*[@name\='tddFrameStructure']/item
# #    add_bwplist_list_in_cells_new    ${scfc_path}    key_3
#     add_nrrim_profile_obj_on_cell    ${scfc_path}    1    1
#     ${modify_list}    create list
#     ...    ${actDlSrsSubbandBm}             ${bfSubbandSize}           ${maxNumUeSrs}
#     ...    ${srsPowerThreshold}    ${seThreshold}    ${seHysteresis}    ${rankThreshold}               
#     ...    ${prbSampleHighLowPercentage}    ${rlqGoodPercentage}    ${numWbSrsConfigSample}        
#     ...    ${prbRatioHysteresis}    ${prbRatioThreshold}    ${srsSinrThreshold}
#     ...    ${actNrRim}                      
#     ...    ${cellDepType}                   ${chBw}                    ${dlMimoMode}                  ${nrCellType}
#     ...    ${actUeCsirsCoexistCellCsirs}    ${actCsirsMultiplexing}    ${actDlSrsBm}                  ${actUlSrsBm}
#     ...    ${actFdmScheduling}              ${frameStructureType}      ${guardPeriodLength}           ${lteToNrFrameShift}
#     ...    ${tdLteUlDlConfig}               ${ulDlDataSlotRatio}       ${prachConfigurationIndex}     ${srsUePeriodicity}
#     ...    ${cSRS}                          ${bSRS}                    ${srsPowerThresholdForDlBm}    ${srsTypeAllocForDlBm}
#     ...    ${actCustomBsr}                  ${customBeamSetName}       ${actIncreasedFdmUsersPerSlot}
#     ...    ${bfSubbandSize}                 ${maxNumUeSrs}
#     ...    ${nrRiThresDropHeight}           ${nrRiThresDurationRatio}         ${nrRimRarTpcCommand}
#     ...    ${bwp_profile8}                  ${bwp_profile85}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File     ${par_of_bsr_name}
#     Add L2PS Deubg Logs
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:5 UEs with t2r4 capability attach to cell-1
#     Start capture GNB and AP Syslog in 'Step2_attach' File
# #    Start GNB BIP Log
#     Attach SA ue with capability to 5g cell    5    ${pattern}
#     : FOR    ${i}    IN RANGE    1    6
#     \	Set UEi position    ${i}
#     Override UEi to DL RANKj and CQIk    1    1    15
#     Override UEi to DL RANKj and CQIk    2    1    15
#     Override UEi to DL RANKj and CQIk    3    2    15
#     Override UEi to DL RANKj and CQIk    4    2    15
#     Override UEi to DL RANKj and CQIk    5    3    15
# #    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Start GNB Ttitrace With Streaming Mode
#     Wait '3s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
#     Set test Variable	 ${rnti_1} 	${rnti_list[0]}
#     Set test Variable	 ${rnti_2} 	${rnti_list[1]}
#     Set test Variable	 ${rnti_3} 	${rnti_list[2]}
#     Set test Variable	 ${rnti_4} 	${rnti_list[3]}
#     Set test Variable	 ${rnti_5} 	${rnti_list[4]}
# 
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Send DL full buffer to UE1-5
#     Start capture GNB and AP Syslog in 'Step3' File
# #    Start GNB BIP Log
#     SA send multiple trf data    1    DL    150M    2
#     SA send multiple trf data    2    DL    150M    2
#     SA send multiple trf data    3    DL    150M    2
#     SA send multiple trf data    4    DL    150M    2
#     SA send multiple trf data    5    DL    150M    2
# #    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3${/}
#     ${dl_tpt_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tpt_ue2} =    Airphone Get Throughput On Specific Scell    ue_id=2   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tpt_ue3} =    Airphone Get Throughput On Specific Scell    ue_id=3   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tpt_ue4} =    Airphone Get Throughput On Specific Scell    ue_id=4   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tpt_ue5} =    Airphone Get Throughput On Specific Scell    ue_id=5   scell_id=0    type=pdsch    tput_type=ave
# 
#     Start GNB Ttitrace With Streaming Mode
#     Wait '1s' for stable running
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
# 
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
# 
# 	run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/E10_01_step3_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step3' File
# 
# Step4:Trigger RI mitigation
#     Start capture GNB and AP Syslog in 'Step4' File
# #    Start GNB BIP Log
#     #Generate RI
#     airphone_execute_egate_command
#     ...    remote_interference_testmode_nr profile_id\=1 start_symbol_position\=0 num_of_symbols\=32 noise_power_values\=${NOISE_POWER_FOR_RI}
#     airphone_execute_egate_command
#     ...    cell_testmode_set_nr gnb\=1 cell_id\=1 testmode\=remote_interference profile_id\=1 action\=activate
# #    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4${/}
# 
#     Wait For Fault To Be Up     fault_id=7525   timeout=900
# 
#     ${dl_tpt_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tpt_ue2} =    Airphone Get Throughput On Specific Scell    ue_id=2   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tpt_ue3} =    Airphone Get Throughput On Specific Scell    ue_id=3   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tpt_ue4} =    Airphone Get Throughput On Specific Scell    ue_id=4   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tpt_ue5} =    Airphone Get Throughput On Specific Scell    ue_id=5   scell_id=0    type=pdsch    tput_type=ave
# 
#     Start GNB Ttitrace With Streaming Mode
#     Wait '1s' for stable running
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
# 
#     run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/E10_01_step4_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
# 	[Teardown]    Stop capture GNB and AP Syslog in 'Step4' File
# 
# Step5:UE2-4 release, UE-6 attach to Cell-1
#     Start capture GNB and AP Syslog in 'Step5' File
# #    Start GNB BIP Log
#     Airphone SA Detach    2
#     Airphone SA Detach    3
#     Airphone SA Detach    4
#     
#     Airphone SA Attach    ue_id=6
#     airphone_set_traffic_type    6    1    internal
#     Airphone Pdu Session Setup    6    1    1    6
#     Set UEi position    6
#     Override UEi to DL RANKj and CQIk    6    1    15
#     SA send multiple trf data    6    DL    150M    2
# #    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5${/}
# 
#     ${dl_tpt_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tpt_ue5} =    Airphone Get Throughput On Specific Scell    ue_id=5   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tpt_ue6} =    Airphone Get Throughput On Specific Scell    ue_id=6   scell_id=0    type=pdsch    tput_type=ave
# 
#     Start GNB Ttitrace With Streaming Mode
#     Wait '1s' for stable running
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
# 
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step5${/}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step5${/}/egate_console.log.001   crnti: (\\d+)
#     Set test Variable	 ${rnti_6} 	${rnti_list[5]}
# 
#     run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/E10_01_step5_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step5' File
# 
# Step6:Stop RI mitigation
#     Start capture GNB and AP Syslog in 'Step6' File
# #    Start GNB BIP Log
#     #stop RIM
#     airphone_execute_egate_command
#     ...    cell_testmode_set_nr testmode\=remote_interference gnb\=1 cell_id\=1 profile_id\=1 action\=deactivate
# #    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step6${/}
# 
#     Wait For Fault To Be Down     fault_id=7525   timeout=900
# 
#     ${dl_tpt_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tpt_ue5} =    Airphone Get Throughput On Specific Scell    ue_id=5   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tpt_ue6} =    Airphone Get Throughput On Specific Scell    ue_id=6   scell_id=0    type=pdsch    tput_type=ave
# 
#     Start GNB Ttitrace With Streaming Mode
#     Wait '1s' for stable running
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
#     run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/E10_01_step6_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step6' File
# 
# Step7:UE-7 attach to Cell-1
#     Start capture GNB and AP Syslog in 'Step7' File
# #    Start GNB BIP Log
#     Airphone SA Attach    ue_id=7
#     airphone_set_traffic_type    7    1    internal
#     Airphone Pdu Session Setup    7    1    1    7
#     Set UEi position    7
#     Override UEi to DL RANKj and CQIk    7    3    15
#     SA send multiple trf data    7    DL    150M    2
# #    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step7${/}
# 
#     ${dl_tpt_ue1} =    Airphone Get Throughput On Specific Scell    ue_id=1   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tpt_ue5} =    Airphone Get Throughput On Specific Scell    ue_id=5   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tpt_ue6} =    Airphone Get Throughput On Specific Scell    ue_id=6   scell_id=0    type=pdsch    tput_type=ave
#     ${dl_tpt_ue7} =    Airphone Get Throughput On Specific Scell    ue_id=7   scell_id=0    type=pdsch    tput_type=ave
# 
#     Start GNB Ttitrace With Streaming Mode
#     Wait '1s' for stable running
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step7
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
# 
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step7${/}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step7${/}/egate_console.log.001   crnti: (\\d+)
#     Set test Variable	 ${rnti_7} 	${rnti_list[6]}
# 
#     run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/E10_01_step7_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step7' File
# 
# Override UEi to DL RANKj and CQIk
#     [Arguments]    ${ue_id}    ${ranki}    ${cqii}
#     airphone_execute_egate_command
#    	...    csi_override_testmode_nr profile_id\=${ue_id} ri_mode\=fixed ri\=${ranki} cqi_mode\=fixed cqi\=${cqii}
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=${ue_id}
# 
# Set UEi position
#     [Arguments]    ${ue_id}
#     airphone_execute_egate_command    ${PROFILE1}
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     
# Add L2PS Deubg Logs	
#     ${debuglogs}    create list    level=DBG\n    L2.L2_PS.DEBUG=1\n    L2.L2_PS.DL.SUBBAND_BEAMFORMING=1\n    L2.L2_PS.SRS_BASED_BM=1\n 
#     Active L2ps Feature Debug Traces    ${debuglogs}
#     TAF_SSH.connect to    192.168.255.1   toor4nsn    oZPS0POrRieRtu   alias=bsh
#     TAF_SSH.execute    rm /ffs/run/HashContainer*    connection=bsh
# 
# modify_swconfig_by_CB008322
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}
#     ${local_save_path}=     Download All Common Config Files From Golden Server
#     ${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
#     ${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     add_txt_node    0x58076b:0x64          #rdNumWbSrsCorrExpiry=100(Defalut Value is 60)
# 	add_txt_node    0x580717:0         #disable PDCCH split
#     teardown_txt
#     setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
