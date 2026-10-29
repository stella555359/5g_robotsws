# *** Settings ***
# Documentation     Author:zhaoyang.xu@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               base on CB008322_E7_case01_Power_Saving
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO    AP    SBTS00    OPTION_RELATED_ARTIFACTS_5G    VARIANT_SANSA_FS_ECPRI_CMWV_TDD_TEMP
# Test Timeout      120 minutes
# Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
# Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
# Library           taf.transport.ssh    WITH NAME    TAF_SSH
# Library           ta_a2a
# Library           taf.sbts.oam.coam.admin
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U.xml
# ${AIRPHONE_NAME}      AP_iphy_AQQL_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U_9496.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_UEs.cfg
# @{LOG_NAME_LIST}      egatelog\    gnb_snapshot    ap_snapshot
# #    sosreport
# #8322
# ${actDlSrsSubbandBm}              text|true|//*[@name\="actDlSrsSubbandBm"]
# ${bfSubbandSize}                  text|32 PRBs|//*[@name\="bfSubbandSize"]
# #${srsQualityThreshold}            text|-1200|//*[@name\="srsQualityThreshold"]
# ${maxNumUeSrs}                    text|2|//*[@name\="maxNumUeSrs"]
# ${srsPowerThreshold}                  text|-1200|//*[@name\="srsPowerThreshold"]
# ${seThreshold}                        text|80|//*[@name\="seThreshold"]
# ${seHysteresis}                       text|50|//*[@name\="seHysteresis"]
# ${rankThreshold}                      text|2|//*[@name\="rankThreshold"]
# ${channelStabilityThreshold}          text|20|//*[@name\="channelStabilityThreshold"]
# ${channelStabilityHysteresis}         text|10|//*[@name\="channelStabilityHysteresis"]
# ${prbRatioThreshold}                  text|5|//*[@name\="prbRatioThreshold"]
# ${prbSampleHighLowPercentage}         text|5|//*[@name\="prbSampleHighLowPercentage"]
# ${rlqGoodPercentage}                  text|80|//*[@name\="rlqGoodPercentage"]
# ${rlqBadPercentage}                   text|50|//*[@name\="rlqBadPercentage"]
# ${numWbSrsConfigSample}               text|60|//*[@name\="numWbSrsConfigSample"]
# 
# #8247
# ${srsPowerThresholdForDlBm}       text|-1000|//*[@name\="srsPowerThresholdForDlBm"]
# 
# #E7
# ${actDlSrsBm}                     text|true|//*[@name\="actDlSrsBm"]
# ${actMicroDTX}                    text|true|//*[@name\="actMicroDTX"]
# ${actNrLBmMimoRTXPowerSaving}     text|true|//*[@name\="actNrLBmMimoRTXPowerSaving"]
# 
# #NRPGRP
# ${lbpsSOMethod}                     text|TX switch off|//*[@name\="lbpsSOMethod"]
# ${lbpsDuration}                     text|30|//*[@name\="lbpsDuration"]
# 
# ${lbpsSuspended}                    text|notSuspended|//*[@name\="lbpsSuspended"]
# ${lbpsRTXSOffTime}                  text|30|//*[@name\="lbpsRTXSOffTime"]
# ${lbpsRTXSOnTime}                   text|30|//*[@name\="lbpsRTXSOnTime"]
# ${lbpsRTXMaxLoad}                   text|90|//*[@name\="lbpsRTXMaxLoad"]
# ${lbpsRTXMinLoad}                   text|60|//*[@name\="lbpsRTXMinLoad"]
# ${lbpsCellSOOrder}                  text|1|//*[@name\="lbpsCellSOOrder"]
# ${lbpsLastCellSOEnabled}            text|true|//*[@name\="lbpsLastCellSOEnabled"]
# ${lbpsLastCellRTXMinLoad}           text|70|//*[@name\="lbpsLastCellRTXMinLoad"]
# 
# ${cellDepType}                    text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                           text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                     text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                     text|8DL4UL|//*[@name\="nrCellType"]
# ${actUeCsirsCoexistCellCsirs}     text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${actCsirsMultiplexing}           text|true|//*[@name\="actCsirsMultiplexing"]
# ${actUlSrsBm}                     text|true|//*[@name\="actUlSrsBm"]
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
# ${srsTypeAllocForDlBm}            text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
# ${bfSubbandSize}                  text|32 PRBs|//*[@name\="bfSubbandSize"]
# ${maxNumUeSrs}                    text|2|//*[@name\="maxNumUeSrs"]
# ${actIncreasedFdmUsersPerSlot}    text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
# ${actDlMuMimoEnh}                 text|false|//*[@name\="actDlMuMimoEnh"]
# #${miNrMacSduReport}               text|5min|//*[@name\="miNrMacSduReport"]
# ${tiltOffset}                     text|0|//*[@name\="tiltOffset"]
# ${bwp_profile8}                   text|MRBTS-1/NRBTS-1/BWP_PROFILE-8|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile85}                  text|MRBTS-1/NRBTS-1/BWP_PROFILE-85|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# 
# ${actCustomBsr}                   text|true|//*[@name\="actCustomBsr"]
# ${customBeamSetName}              text|BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001|//*[@name\="customBeamSetName"]
# ${par_of_bsr_name}                BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001_CB008133
# ${pattern}                        CA_P2_8x4_t2r4_n2
# 
# ${miNrBeamforming2}    text|15min|//*[@name\="miNrBeamforming2"]
# ${miNrDlHarq}    text|15min|//*[@name\="miNrDlHarq"]
# ${miNrUlHarq}    text|15min|//*[@name\="miNrUlHarq"]
# ${miNrDlHarqLowSEMCS}    text|15min|//*[@name\="miNrDlHarqLowSEMCS"]
# ${miNrUlHarqLowSEMCS}    text|15min|//*[@name\="miNrUlHarqLowSEMCS"]
# ${miNrUlHarqOne}    text|15min|//*[@name\="miNrUlHarqOne"]
# 
# 
# 
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-150,-150,-150,-150
# ${SET_PROFILE1}    ue_testmode_set_nr id=11 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
# *** Test Cases ***
# CNI_113494_Case9_PDSCH_and_PUSCH_iBLER_counters_interworking_with_EnergySaving
#     Step1:Commission the above configuration on WebUI
#     Step2:3 UEs attach to cell-1, Send DL full buffer to UE1-3
#     Step3:gNB enters into Powersaving mode
#     Step4:UE-4 attach to Cell-1
#     Step5:UE2 release
#     Step6:PowerSaving off
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start capture GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="lteToNrFrameShift">3ms</p>|//*[@name\='tddFrameStructure']/item
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tdLteUlDlConfig">tdLteConfig2</p>|//*[@name\='tddFrameStructure']/item
#     add_nrpgrp_obj_on_nrbts    ${scfc_path}    0
# 
# 	${time_info}    get_enb_delta_time    15m
# 	log    week:${time_info['week']} hour:${time_info['hour']} minute:${time_info['minute']}
#     ${lbpsDayOfWeek}    Set Variable    ${time_info['week']}
#     ${lbpsStartTimeHour}    Set Variable      ${time_info['hour']}
#     ${lbpsStartTimeMinute}    Set Variable    ${time_info['minute']}
#     ${modify_list1}    create list    text|${lbpsDayOfWeek}|//*[@name\='lbpsDayOfWeek']
#     ...    text|${lbpsStartTimeHour}|//*[@name\='lbpsStartTimeHour']
#     ...    text|${lbpsStartTimeMinute}|//*[@name\='lbpsStartTimeMinute']
#     modify_xml    ${scfc_path}     ${scfc_path}    ${modify_list1}
# 
#     ${modify_list}    create list
#     ...    ${actDlSrsSubbandBm}             ${bfSubbandSize}           ${maxNumUeSrs}
#     ...    ${srsPowerThreshold}    ${seThreshold}    ${seHysteresis}    ${rankThreshold}    ${channelStabilityThreshold}   
#     ...    ${channelStabilityHysteresis}    ${prbRatioThreshold}    ${prbSampleHighLowPercentage}    ${rlqGoodPercentage}           
#     ...    ${rlqBadPercentage}              ${numWbSrsConfigSample}    ${srsPowerThresholdForDlBm}
#     ...    ${actDlSrsBm}                    ${actMicroDTX}             ${actNrLBmMimoRTXPowerSaving}
#     ...    ${lbpsSOMethod}                  
#     ...    ${lbpsDuration}                  ${lbpsSuspended}           ${lbpsRTXSOffTime}             ${lbpsRTXSOnTime}
#     ...    ${lbpsRTXMaxLoad}                ${lbpsRTXMinLoad}          ${lbpsCellSOOrder}             ${lbpsLastCellSOEnabled}
#     ...    ${lbpsLastCellRTXMinLoad}
#     ...    ${cellDepType}                   ${chBw}                    ${dlMimoMode}                  ${nrCellType}
#     ...    ${actUeCsirsCoexistCellCsirs}    ${actCsirsMultiplexing}    ${actUlSrsBm}
#     ...    ${actFdmScheduling}              ${frameStructureType}      ${guardPeriodLength}           ${lteToNrFrameShift}
#     ...    ${tdLteUlDlConfig}               ${ulDlDataSlotRatio}       ${prachConfigurationIndex}     ${srsUePeriodicity}
#     ...    ${cSRS}                          ${bSRS}                    ${srsTypeAllocForDlBm}
#     ...    ${actCustomBsr}                  ${customBeamSetName}       ${actIncreasedFdmUsersPerSlot}
#     ...    ${actDlMuMimoEnh}
#     ...    ${bfSubbandSize}                 ${maxNumUeSrs}             ${tiltOffset}
# 	...    ${miNrBeamforming2}    ${miNrDlHarq}    ${miNrUlHarq}    ${miNrDlHarqLowSEMCS}    ${miNrUlHarqLowSEMCS}   ${miNrUlHarqOne}	
#     ...    ${bwp_profile8}                  ${bwp_profile85}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File     ${par_of_bsr_name}
#     Add L2PS Deubg Logs
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
# 
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:3 UEs attach to cell-1, Send DL full buffer to UE1-3
#     Start capture GNB and AP Syslog in 'Step2_attach' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}/Step2_attach
#     Attach SA ue with capability to 5g cell    2    ${pattern}
#     : FOR    ${i}    IN RANGE    1    3
#     \    Set UEi position    ${i}
#     Override UEi to DL RANKj and CQIk    1    2    15
#     Override UEi to DL RANKj and CQIk    2    2    15
#     Wait '3s' for stable running
#     SA send multiple trf data    1    DL    100M    1
#     SA send multiple trf data    2    DL    100M    1
# 
#     UE_'3' Attach
#     SA send multiple trf data    3    DL    100M    1
# 
#     Start GNB Ttitrace With Streaming Mode
#     Wait '3s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
#     Set test Variable     ${rnti_1}     ${rnti_list[0]}
#     Set test Variable     ${rnti_2}     ${rnti_list[1]}
#     Set test Variable     ${rnti_3}     ${rnti_list[2]}
# 	
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/Step2_attach${/}
#     Check_CNI113494_iBler_match_Legacy_counters    ${PM_counter_file}	
# 	
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:gNB enters into Powersaving mode
#     Start capture GNB and AP Syslog in 'Step3' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}/Step3
# 
#     Wait '360s' for stable running
#     Start GNB Ttitrace With Streaming Mode
#     Wait '2s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/Step3${/}
#     Check_CNI113494_iBler_match_Legacy_counters    ${PM_counter_file}			
# 	
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step3' File
#     
# Step4:UE-4 attach to Cell-1
#     Start capture GNB and AP Syslog in 'Step4' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}/Step4
#     UE_'4' Attach
#     SA send multiple trf data    4    DL    100M    1
#     Start GNB Ttitrace With Streaming Mode
#     Wait '1s' for stable running
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}/Step4
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step4${/}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step4${/}/egate_console.log.001   crnti: (\\d+)
#     Set test Variable     ${rnti_4}     ${rnti_list[3]}
# 	
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step4' File
# 
# Step5:UE2 release
#     Start capture GNB and AP Syslog in 'Step5' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}/Step5
#     Start GNB Ttitrace With Streaming Mode
#     Airphone SA Detach    2
#     Wait '2s' for stable running
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}/Step5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/Step5${/}
#     Check_CNI113494_iBler_match_Legacy_counters    ${PM_counter_file}	
# 		
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step5' File
# 
# Step6:PowerSaving off
#     Start capture GNB and AP Syslog in 'Step6' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}/Step6
#     Wait '1500s' for stable running
#     Start GNB Ttitrace With Streaming Mode
#     Wait '2s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
# 	
# 	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}/Step6${/}
#     Check_CNI113494_iBler_match_Legacy_counters    ${PM_counter_file}	
# 		
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step6' File
#     
# UE_'${ue_id}' Attach
#     Airphone SA Attach    ue_id=${ue_id}
#     airphone_set_traffic_type    ${ue_id}    1    internal
#     Airphone Pdu Session Setup    ${ue_id}    1    1    ${ue_id}
#     Set UEi position    ${ue_id}
#     Override UEi to DL RANKj and CQIk    ${ue_id}    2    15
# 
# Stop UE DL Traffic
#     [Arguments]    ${ue_id}
#     airphone_sa_stop_data_traffic    ${ue_id}    DL
# 
# Override UEi to DL RANKj and CQIk
#     [Arguments]    ${ue_id}    ${ranki}    ${cqii}
#     airphone_execute_egate_command
#     ...    csi_override_testmode_nr profile_id\=${ue_id} ri_mode\=fixed ri\=${ranki} cqi_mode\=fixed cqi\=${cqii}
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${ue_id} testmode\=csi_override action\=activate profile_id\=${ue_id}
#     
# Set UE SRS power
#     [Arguments]    ${ue_id}    ${srspower}
#     airphone_execute_egate_command
#     ...    ul_sinr_testmode_nr profile_id\=${ue_id} sinr_target_srs\=${srspower}
#     airphone_execute_egate_command
#     ...    ue_testmode_set_nr id\=${ue_id} testmode\=ul_sinr action\=activate profile_id\=${ue_id}
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
#     [Arguments]    ${scfc_file}
#     ${local_save_path}=     Download All Common Config Files From Golden Server
#     ${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
#     ${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     add_txt_node    0x9D0000:0x0F             #as PM counter period update to 15/15=1min
#     #add_txt_node    0x5901EB:1             #rdForceEnablingWidebandTasSrs use for  itf_l2_ps_user_usermodifyreq.isWBTasConfigured_item_0=1
#     #add_txt_node    0x5805ae:1             #Flag to enable or disable dynamic Wb/Sb Srs Switch
#     #add_txt_node    0x580556:2100          #rdStartPatternId=2100(Default Value is 5000)
#     #add_txt_node    0x5901E6:160           #rdMinSrsUePeriodicity=slots80(Default Value is 80slots)
#     #add_txt_node    0x580762:80            #rdWbSrsSeTresh(100,Default Value is 9.1)
#     #add_txt_node    0x580766:50            #rdWbSrsSeProh(100,Default Value is 30)
#     #add_txt_node    0x580764:0xfffffc18    #rdWbSrsQualTresh=-1000(Defalut Value is -1200)
#     #add_txt_node    0x580768:0x64          #rdWbSrsQualProh=10(10,Defalut Value is 5)
#     #add_txt_node    0x580763:2             #rdWbSrsRankTresh(Defalut Value is 3)
#     #add_txt_node    0x580767:0              #rdWbSrsRankProh(Defalut Value is 0)
#     #add_txt_node    0x58076b:0x64          #rdNumWbSrsCorrExpiry=100(Defalut Value is 60)
#     #add_txt_node    0x580765:0x14          #rdWbSrsCorrTresh=0.2(100,Defalut Value is 0.3)
#     #add_txt_node    0x580769:0xa           #rdWbSrsCorrProh=0.1(100,Defalut Value is 0.1)
#     #add_txt_node    0x5805b0:20           #rdSrsBufPercent=100(Defalut Value is 20)
#     #add_txt_node    0x5805b1:80           #rdSrsRlqGoodPercent(100,Defalut Value is 100) 
#     #add_txt_node    0x5805b2:50            #rdSrsRlqBadPercent=50(100,Defalut Value is 50)
#     #add_txt_node    0x5805b4:20            #rdPeriodSrsCheck(Defalut Value is 20)
#     #add_txt_node    0x5805b5:60              #rdNumSrsCheck(Defalut Value is 1)
#     #add_txt_node    0x58076c:20            #rdWbSrsPrbTresh(Defalut Value is 45)
# #    add_txt_node    0x5901EA:1             #fake DRX
# #    add_txt_node    0x5901E8:1     #CPRT rdActCB009496
# #    add_txt_node    0x600013:1     # BOAM_RAT_ADAPT
# #    add_txt_node    0x19040F:1     # BOAM_FRONTHAUL
# #    add_txt_node    0x42008E:1     # BOAM DCS
# #    add_txt_node    0x88004B:0             # L1 FH, rdEnableSktMvp
# #    add_txt_node    0x880x31:14            # L1 FH, rdBwvTxOpportunities (symbols/slot for sending BWV)
# #    add_txt_node    0x580556:65535          #rdStartPatternId
# #    add_txt_node    0x580789:1        #rdEnableNiddFor8322
#     teardown_txt
#     setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Wait ${timeout}s for cells [${cells_ids}] ${cellState:energySavingState|availabilityStatus} change to ${expected_states}
#     Wait Until Keyword Succeeds  ${timeout}s  10s
#     ...  Check for cells [${cells_ids}] if ${cellState} equals ${expected_states}
# 
# 
# Check_CNI113494_iBler_match_Legacy_counters
#     [Arguments]    ${PM_counter_file}	
# 	Log To Console    \n---------CNI_113494_PDSCH_initial_counter----------
# 	Log To Console    SSB_BEAM:M55330C00043,REFINED_BEAM:M55330C00047,PMI_BEAM:M55330C00030
# 	Log To Console    DFTNTAP_BEAM:M55330C00036,DFTTAP_BEAM:M55330C00032,SUBBAND_BEAM:M55330C00040
# 	${PDSCH_INI_Counter_list}    create list   M55330C00043    M55330C00047     M55330C00030   M55330C00036    M55330C00032    M55330C00040 
#     ${PDSCH_INI_All_Beam_counter_cell1}    	create list
#     FOR    ${counter_id}    IN    @{PDSCH_INI_Counter_list}
#     ${PDSCH_INI_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
#     append to list    ${PDSCH_INI_All_Beam_counter_cell1}    ${PDSCH_INI_cell1}
# 	END
# 	Log To Console    PDSCH_INI_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell1:${PDSCH_INI_All_Beam_counter_cell1}
# 	${PDSCH_INI_counter_Sum_cell1}    Evaluate    sum(${PDSCH_INI_All_Beam_counter_cell1})	
#     Log To Console    \n----------------------end-------------------------
# 
# 
# 	Log To Console    \n---------CNI_113494_PDSCH_initial_Successful_counter----------
# 	Log To Console    SSB_BEAM:M55330C00044,REFINED_BEAM:M55330C00048,PMI_BEAM:M55330C00031
# 	Log To Console    DFTNTAP_BEAM:M55330C00037,DFTTAP_BEAM:M55330C00033,SUBBAND_BEAM:M55330C00041
# 	${PDSCH_SUC_Counter_list}    create list   M55330C00044    M55330C00048     M55330C00031   M55330C00037    M55330C00033    M55330C00041 
#     ${PDSCH_SUC_All_Beam_counter_cell1}    	create list
#     FOR    ${counter_id}    IN    @{PDSCH_SUC_Counter_list}
#     ${PDSCH_SUC_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
#     append to list    ${PDSCH_SUC_All_Beam_counter_cell1}    ${PDSCH_SUC_cell1}
# 	END
# 	Log To Console    PDSCH_SUC_SSB_refined_PMI_DFTN_DFT_SUB_beam_counter_cell1:${PDSCH_SUC_All_Beam_counter_cell1}
# 	${PDSCH_SUC_counter_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_All_Beam_counter_cell1})	
# 	Log To Console    \n----------------------end-------------------------
# 	
# 
# 			
#     Log To Console    \n---------CNI_113494_PUSCH_initial_counter------------------
# 	Log To Console    SSB_BEAM:M55330C00045,REFINED_BEAM:M55330C00028,DFTNTAP_BEAM:M55330C00038,DFTTAP_BEAM:M55330C00034
# 	${PUSCH_INI_Counter_list}    create list   M55330C00045    M55330C00028     M55330C00038   M55330C00034
#     ${PUSCH_INI_All_Beam_counter_cell1}    	create list
#     FOR    ${counter_id}    IN    @{PUSCH_INI_Counter_list}
#     ${PUSCH_INI_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
#     append to list    ${PUSCH_INI_All_Beam_counter_cell1}    ${PUSCH_INI_cell1}
# 	END	
# 	Log To Console    PUSCH_INI_SSB_refined_DFTN_DFT_beam_counter_cell1:${PUSCH_INI_All_Beam_counter_cell1}
# 	${PUSCH_INI_counter_Sum_cell1}    Evaluate    sum(${PUSCH_INI_All_Beam_counter_cell1})
#     Log To Console    \n----------------------end-------------------------
# 	
# 	Log To Console    \n---------CNI_113494_PUSCH_Successful_initial_counter------------------
# 	Log To Console    SSB_BEAM:M55330C00046,REFINED_BEAM:M55330C00029,DFTNTAP_BEAM:M55330C00039,DFTTAP_BEAM:M55330C00035
# 	${PUSCH_SUC_Counter_list}    create list   M55330C00046    M55330C00029     M55330C00039   M55330C00035
#     ${PUSCH_SUC_All_Beam_counter_cell1}    	create list
#     FOR    ${counter_id}    IN    @{PUSCH_SUC_Counter_list}
#     ${PUSCH_SUC_cell1}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=${counter_id}    cell_id=1    
#     append to list    ${PUSCH_SUC_All_Beam_counter_cell1}    ${PUSCH_SUC_cell1}
# 	END		
# 	Log To Console    PUSCH_SUC_SSB_refined_DFTN_DFT_beam_counter_cell1:${PUSCH_SUC_All_Beam_counter_cell1}	
# 	${PUSCH_SUC_counter_Sum_cell1}    Evaluate    sum(${PUSCH_SUC_All_Beam_counter_cell1})
#     Log To Console    \n----------------------end-------------------------
# 
# 	
# 	Log To Console    \n----Legacy_PDSCH_INITX_64TBL_MCS_00-28_and_256TBL_MCS_00-27_and_LOWSE_MCS_00-28----------
# 	Log To Console    PDSCH_INITX_64TBL_MCS_00-28:M55300C00000----M55300C00028
# 	Log To Console    PDSCH_INITX_256TBL_MCS_00-27:M55300C04000---M55300C04027
# 	Log To Console    PDSCH_INITX_LOWSE_MCS_00-28:M55366C01000----M55366C01028
#     ${PDSCH_INITX_64TBL_MCS_00_28_cell1}    	create list
#     ${PDSCH_INITX_256TBL_MCS_00_27_cell1}    	create list
#     ${PDSCH_INITX_LOWSE_MCS_00_28_cell1}    	create list
# 	
# 	FOR    ${i}    IN RANGE     0     29
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=1
# 	append to list     ${PDSCH_INITX_64TBL_MCS_00_28_cell1}   ${64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=1
# 	append to list     ${PDSCH_INITX_LOWSE_MCS_00_28_cell1}   ${LOW_value}
# 	END
# 
# 	FOR    ${i}    IN RANGE     0     28
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=1
# 	append to list     ${PDSCH_INITX_256TBL_MCS_00_27_cell1}   ${256_value}
# 	END	
# 	Log To Console    PDSCH_INITX_64TBL_MCS_00_28_cell1:${PDSCH_INITX_64TBL_MCS_00_28_cell1}
#     Log To Console    PDSCH_INITX_256TBL_MCS_00_27_cell1:${PDSCH_INITX_256TBL_MCS_00_27_cell1}
#     Log To Console    PDSCH_INITX_LOWSE_MCS_00_28_cell1:${PDSCH_INITX_LOWSE_MCS_00_28_cell1}
# 	${PDSCH_INITX_64TBL_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_64TBL_MCS_00_28_cell1})
# 	${PDSCH_INITX_256TBL_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_256TBL_MCS_00_27_cell1})		
# 	${PDSCH_INITX_LOWSE_Sum_cell1}    Evaluate    sum(${PDSCH_INITX_LOWSE_MCS_00_28_cell1})
#     ${PDSCH_LG_INITX_Sum_cell1}    Evaluate    ${PDSCH_INITX_64TBL_Sum_cell1}+${PDSCH_INITX_256TBL_Sum_cell1}+${PDSCH_INITX_LOWSE_Sum_cell1}		
#     Log To Console    \n----------------------end-------------------------
# 
# 	Log To Console    \n----Legacy_PDSCH_SUCC_64TBL_MCS_00-28_and_256TBL_MCS_00-27_and_LOWSE_MCS_00-28----------
# 	Log To Console    PDSCH_SUC_64TBL_MCS_00-28:M55300C01000-----M55300C01028
# 	Log To Console    PDSCH_SUC_256TBL_MCS_00-27:M55300C05000---M55300C05027
# 	Log To Console    PDSCH_SUC_LOWSE_MCS_00-28:M55366C02000----M55366C02028
#     ${PDSCH_SUC_64TBL_MCS_00_28_cell1}    	create list
#     ${PDSCH_SUC_256TBL_MCS_00_27_cell1}    	create list
#     ${PDSCH_SUC_LOWSE_MCS_00_28_cell1}    	create list
# 	
# 	FOR    ${i}    IN RANGE     0     29
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=1
# 	append to list     ${PDSCH_SUC_64TBL_MCS_00_28_cell1}   ${64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=1
# 	append to list     ${PDSCH_SUC_LOWSE_MCS_00_28_cell1}   ${LOW_value}		
# 	END
# 
# 	FOR    ${i}    IN RANGE     0     28
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=1
# 	append to list     ${PDSCH_SUC_256TBL_MCS_00_27_cell1}   ${256_value}
# 	END	
# 	Log To Console    PDSCH_SUC_64TBL_MCS_00_28_cell1:${PDSCH_SUC_64TBL_MCS_00_28_cell1}
#     Log To Console    PDSCH_SUC_256TBL_MCS_00_27_cell1:${PDSCH_SUC_256TBL_MCS_00_27_cell1}
#     Log To Console    PDSCH_SUC_LOWSE_MCS_00_28_cell1:${PDSCH_SUC_LOWSE_MCS_00_28_cell1}
# 	${PDSCH_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_64TBL_MCS_00_28_cell1})
# 	${PDSCH_SUC_256TBL_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_256TBL_MCS_00_27_cell1})		
# 	${PDSCH_SUC_LOWSE_Sum_cell1}    Evaluate    sum(${PDSCH_SUC_LOWSE_MCS_00_28_cell1})		
#     ${PDSCH_LG_SUC_Sum_cell1}    Evaluate    ${PDSCH_SUC_64TBL_Sum_cell1}+${PDSCH_SUC_256TBL_Sum_cell1}+${PDSCH_SUC_LOWSE_Sum_cell1}	
#     Log To Console    \n----------------------end-------------------------
# 
# 
# 	Log To Console    \n----Legacy_PUSCH_CP_INI_64TBL_MCS_00-28_and_PUSCH_DFT_INI_64TBL_MCS_00-27------
# 	Log To Console    \n----Legacy_PUSCH_CP_INI_256TBL_MCS_00-27_and_PUSCH_CP_INI_LOWSE_MCS_00-28------
# 	Log To Console    \n----Legacy_PUSCH_DFT_INI_64TBL_SAG_R2_and_PUSCH_DFT_INI_64TBL_SAG_R4------	
# 	Log To Console    PUSCH_CP_INI_64TBL_MCS_00-28:M55302C00000----M55302C00028
# 	Log To Console    PUSCH_DFT_INI_64TBL_MCS_00-27:M55302C06000----M55302C06027
# 	Log To Console    PUSCH_CP_INI_256TBL_MCS_00-27:M55302C11000-----M55302C11027
# 	Log To Console    PUSCH_CP_INI_LOWSE_MCS_00-28:M55367C01000----M55367C01028
# 	Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2:M55370C00007
# 	Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4:M55370C00013	
# 	
# 	
#     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}    	create list
#     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}    	create list
#     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}    	create list	
#     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}    	create list
# 	
# 	FOR    ${i}    IN RANGE     0     29
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=1
# 	append to list     ${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}   ${CP_64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=1
# 	append to list     ${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}   ${LOW_value}		
# 	END
# 
# 	FOR    ${i}    IN RANGE     0     28
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=1
# 	append to list     ${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}   ${DFT_64}	
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=1
# 	append to list     ${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}   ${256_value}
# 	END	
# 	
# 	${INI_SAG_R2_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007    cell_id=1	
# 	${INI_SAG_R4_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013    cell_id=1
# 
#     Log To Console    PUSCH_CP_INI_64TBL_MCS_00_28_cell1:${PUSCH_CP_INI_64TBL_MCS_00_28_cell1}
#     Log To Console    PUSCH_DFT_INI_64TBL_MCS_00_27_cell1:${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1}
#     Log To Console    PUSCH_CP_INI_256TBL_MCS_00_27_cell1:${PUSCH_CP_INI_256TBL_MCS_00_27_cell1}		
#     Log To Console    PUSCH_CP_INI_LOWSE_MCS_00_28_cell1:${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1}
#     Log To Console    PUSCH_DFT_INI_64TBL_SAG_R2_cell1:${INI_SAG_R2_C1}
#     Log To Console    PUSCH_DFT_INI_64TBL_SAG_R4_cell1:${INI_SAG_R4_C1}
# 	${CP_INI_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_64TBL_MCS_00_28_cell1})
# 	${DFT_INI_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_DFT_INI_64TBL_MCS_00_27_cell1})	
# 	${CP_INI_256TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_256TBL_MCS_00_27_cell1})	
# 	${CP_INI_LOWSE_Sum_cell1}    Evaluate    sum(${PUSCH_CP_INI_LOWSE_MCS_00_28_cell1})
# 	
#     ${PUSCH_LG_INI_Sum_cell1_tmp}    Evaluate    ${CP_INI_64TBL_Sum_cell1}+${DFT_INI_64TBL_Sum_cell1}+${CP_INI_256TBL_Sum_cell1}
#     ${PUSCH_LG_INI_Sum_cell1}    Evaluate    ${PUSCH_LG_INI_Sum_cell1_tmp}+${CP_INI_LOWSE_Sum_cell1}+${INI_SAG_R2_C1}+${INI_SAG_R4_C1}
# 
#     Log To Console    \n----------------------end-------------------------	
# 	
# 
# 	Log To Console    \n----Legacy_PUSCH_CP_SUCC_64TBL_MCS_00-28_and_PUSCH_DFT_SUCC_64TBL_MCS_00-27------
# 	Log To Console    \n----Legacy_PUSCH_CP_SUCC_256TBL_MCS_00-27_and_PUSCH_CP_SUCC_LOWSE_MCS_00-28------
# 	Log To Console    \n----Legacy_PUSCH_DFT_SUCC_64TBL_SAG_R2_and_PUSCH_DFT_SUCC_64TBL_SAG_R4------	
# 	Log To Console    PUSCH_CP_SUCC_64TBL_MCS_00-28:M55302C04000----M55302C04028
# 	Log To Console    PUSCH_DFT_SUCC_64TBL_MCS_00-27:M55302C08000----M55302C08027
# 	Log To Console    PUSCH_CP_SUCC_256TBL_MCS_00-27:M55302C13000---M55302C13027
# 	Log To Console    PUSCH_CP_SUCC_LOWSE_MCS_00-28:M55367C02000---M55367C02028
# 	Log To Console    PUSCH_DFT_SUCC_64TBL_SAG_R2:M55370C00009
# 	Log To Console    PUSCH_DFT_SUCC_64TBL_SAG_R4:M55370C00015
# 	
# 	
#     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}    	create list
#     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}    	create list
#     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}    	create list	
#     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}    	create list
# 
# 	
# 	FOR    ${i}    IN RANGE     0     29
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${CP_64_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=1
# 	append to list     ${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}   ${CP_64_value}
# 	${LOW_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=1
# 	append to list     ${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}   ${LOW_value}
# 		
# 	END
# 
# 	FOR    ${i}    IN RANGE     0     28
# 	${index}     evaluate     "${i}".zfill(2)                     #1bit change to 2bit,0 change to 00
# 	${DFT_64}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=1
# 	append to list     ${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}   ${DFT_64}	
# 	${256_value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=1
# 	append to list     ${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}   ${256_value}
# 	END	
# 	
# 	${SUC_SAG_R2_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009    cell_id=1	
# 	${SUC_SAG_R4_C1}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015    cell_id=1
# 
# 
#     Log To Console    PUSCH_CP_SUC_64TBL_MCS_00_28_cell1:${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1}
#     Log To Console    PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1:${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1}
#     Log To Console    PUSCH_CP_SUC_256TBL_MCS_00_27_cell1:${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1}		
#     Log To Console    PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1:${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1}
# 
#     Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R2_cell1:${SUC_SAG_R2_C1}
#     Log To Console    PUSCH_DFT_SUC_64TBL_SAG_R4_cell1:${SUC_SAG_R4_C1}
# 	${CP_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_64TBL_MCS_00_28_cell1})
# 	${DFT_SUC_64TBL_Sum_cell1}    Evaluate    sum(${PUSCH_DFT_SUC_64TBL_MCS_00_27_cell1})	
# 	${CP_SUC_256TBL_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_256TBL_MCS_00_27_cell1})	
# 	${CP_SUC_LOWSE_Sum_cell1}    Evaluate    sum(${PUSCH_CP_SUC_LOWSE_MCS_00_28_cell1})
# 
# 	
#     ${PUSCH_LG_SUC_Sum_cell1_tmp}    Evaluate    ${CP_SUC_64TBL_Sum_cell1}+${DFT_SUC_64TBL_Sum_cell1}+${CP_SUC_256TBL_Sum_cell1}
#     ${PUSCH_LG_SUC_Sum_cell1}    Evaluate    ${PUSCH_LG_SUC_Sum_cell1_tmp}+${CP_SUC_LOWSE_Sum_cell1}+${SUC_SAG_R2_C1}+${SUC_SAG_R4_C1}	
#     Log To Console    \n----------------------end-------------------------	
# 	
#     Log To Console    \n----------------------All Counter Summary-------------------------
# 	Log To Console    \n----------Check PDSCH All Beam Type iBler counter in Cell1--------
# 	Log To Console    PDSCH_INI_All_beam_type_counter_Sum_cell1:${PDSCH_INI_counter_Sum_cell1}
# 	Log To Console    PDSCH_SUC_All_beam_type_counter_Sum_cell1:${PDSCH_SUC_counter_Sum_cell1}
#     Log To Console    PDSCH_INI_64TBL_256TBL_LOWSE_legacy_counter_cell1:${PDSCH_LG_INITX_Sum_cell1}
#     Log To Console    PDSCH_SUC_64TBL_256TBL_LOWSE_legacy_counter_cell1:${PDSCH_LG_SUC_Sum_cell1}
#     run keyword and continue on failure    should_be_true    ${PDSCH_INI_counter_Sum_cell1}==${PDSCH_LG_INITX_Sum_cell1}   
#     run keyword and continue on failure    should_be_true    ${PDSCH_SUC_counter_Sum_cell1}==${PDSCH_LG_SUC_Sum_cell1}   
# 
# 	
# 	Log To Console    \n----------Check PUSCH All Beam Type iBler counter in Cell1--------	
#     Log To Console    PUSCH_INI_All_beam_type_counter_Sum_cell1:${PUSCH_INI_counter_Sum_cell1}
#     Log To Console    PUSCH_SUC_All_beam_type_counter_Sum_cell1:${PUSCH_SUC_counter_Sum_cell1}		
#     Log To Console    PUSCH_INI_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell1:${PUSCH_LG_INI_Sum_cell1}	
#     Log To Console    PUSCH_SUC_CP_DFT_64TBL_256TBL_LOWSE_SAG_legacy_counter_cell1:${PUSCH_LG_SUC_Sum_cell1}
#     run keyword and continue on failure    should_be_true    ${PUSCH_INI_counter_Sum_cell1}==${PUSCH_LG_INI_Sum_cell1}   
#     run keyword and continue on failure    should_be_true    ${PUSCH_SUC_counter_Sum_cell1}==${PUSCH_LG_SUC_Sum_cell1} 	
# 	