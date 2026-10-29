# *** Settings ***
# Documentation     Author: jing.pan@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008322_E7_case01_Power_Saving
# ...
# ...
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
# Library           taf.sbts.oam.coam.admin
# 
# *** Variables ***
# ${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
# ${SCFC_NAME}          gNB_scf_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_8D4U.xml
# ${AIRPHONE_NAME}      AP_iphy_AQQL_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_2.xml
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC.cfg
# @{LOG_NAME_LIST}      egatelog\    gnb_snapshot    ap_snapshot
# #    sosreport
# #8322
# ${actDlSrsSubbandBm}              text|true|//*[@name\="actDlSrsSubbandBm"]
# ${bfSubbandSize}                  text|32 PRBs|//*[@name\="bfSubbandSize"]
# ${srsQualityThreshold}            text|-1200|//*[@name\="srsQualityThreshold"]
# ${maxNumUeSrs}                    text|2|//*[@name\="maxNumUeSrs"]
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
# ${lbpsDayOfWeek}                    text|Mon|//*[@name\="lbpsDayOfWeek"]
# ${lbpsStartTimeHour}                text|11|//*[@name\="lbpsStartTimeHour"]
# ${lbpsStartTimeMinute}              text|5|//*[@name\="lbpsStartTimeMinute"]
# ${lbpsDuration}                     text|20|//*[@name\="lbpsDuration"]
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
# ${srsTypeAllocForDlBm}            text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
# ${bfSubbandSize}                  text|32 PRBs|//*[@name\="bfSubbandSize"]
# ${maxNumUeSrs}                    text|4|//*[@name\="maxNumUeSrs"]
# ${actIncreasedFdmUsersPerSlot}    text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
# ${actDlMuMimoEnh}                 text|false|//*[@name\="actDlMuMimoEnh"]
# ${actDl256Qam}                    text|true|//*[@name\="actDl256Qam"]
# ${actUl256Qam}                    text|true|//*[@name\="actUl256Qam"]
# ${dllaDeltaCqiMax}                text|0|//*[@name\="dllaDeltaCqiMax"]
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
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=30 zenith=0 srs_transmit_power_per_port=-150,-150,-150,-150
# ${SET_PROFILE1}    ue_testmode_set_nr id=11 testmode=ul_mimo_srs_beam_pos action=activate profile_id=1
# *** Test Cases ***
# CB008322_E7_case001_IWK_power_saving_mode_64TRX
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
#     ${mod_iphy}    create list     text|2|//NumberOfSubCellsDL
#     modify xml     ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}      ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}    ${mod_iphy}
#     change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
#     modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="lteToNrFrameShift">3ms</p>|//*[@name\='tddFrameStructure']/item
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tdLteUlDlConfig">tdLteConfig2</p>|//*[@name\='tddFrameStructure']/item
# #    add_bwplist_list_in_cells_new    ${scfc_path}    key_3
#     add_nrpgrp_obj_on_nrbts    ${scfc_path}    0
#     ${modify_list}    create list
#     ...    ${actDlSrsSubbandBm}             ${bfSubbandSize}           ${srsQualityThreshold}         ${maxNumUeSrs}
#     ...    ${actDlSrsBm}                    ${actMicroDTX}             ${actNrLBmMimoRTXPowerSaving}
#     ...    ${lbpsSOMethod}                  ${lbpsDayOfWeek}           ${lbpsStartTimeHour}           ${lbpsStartTimeMinute}
#     ...    ${lbpsDuration}                  ${lbpsSuspended}           ${lbpsRTXSOffTime}             ${lbpsRTXSOnTime}
#     ...    ${lbpsRTXMaxLoad}                ${lbpsRTXMinLoad}          ${lbpsCellSOOrder}             ${lbpsLastCellSOEnabled}
#     ...    ${lbpsLastCellRTXMinLoad}
#     ...    ${cellDepType}                   ${chBw}                    ${dlMimoMode}                  ${nrCellType}
#     ...    ${actUeCsirsCoexistCellCsirs}    ${actCsirsMultiplexing}    ${actDlSrsBm}                  ${actUlSrsBm}
#     ...    ${actFdmScheduling}              ${frameStructureType}      ${guardPeriodLength}           ${lteToNrFrameShift}
#     ...    ${tdLteUlDlConfig}               ${ulDlDataSlotRatio}       ${prachConfigurationIndex}     ${srsUePeriodicity}
#     ...    ${cSRS}                          ${bSRS}                    ${srsPowerThresholdForDlBm}    ${srsTypeAllocForDlBm}
#     ...    ${actCustomBsr}                  ${customBeamSetName}       ${actIncreasedFdmUsersPerSlot}
#     ...    ${bfSubbandSize}                 ${maxNumUeSrs}             ${tiltOffset}
#     ...    ${bwp_profile8}                  ${bwp_profile85}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File     ${par_of_bsr_name}
#     Add L2PS Deubg Logs
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:3 UEs attach to cell-1, Send DL full buffer to UE1-3
#     Start capture GNB and AP Syslog in 'Step2_attach' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Start GNB BIP Log
#     Attach SA ue with capability to 5g cell    2    ${pattern}
#     : FOR    ${i}    IN RANGE    1    3
#     \	Set UEi position    ${i}
#     Override UEi to DL RANKj and CQIk    1    2    15
#     Override UEi to DL RANKj and CQIk    2    2    15
#     Wait '3s' for stable running
#     SA send multiple trf data    1    DL    100M    1
#     SA send multiple trf data    2    DL    100M    1
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}
# 
#     UE_'3' Attach
#     SA send multiple trf data    3    DL    100M    1
# 
#     Start GNB Ttitrace With Streaming Mode
#     Wait '3s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
# 
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step2_attach${/}/egate_console.log.001   crnti: (\\d+)
#     Set test Variable	 ${rnti_1} 	${rnti_list[0]}
#     Set test Variable	 ${rnti_2} 	${rnti_list[1]}
#     Set test Variable	 ${rnti_3} 	${rnti_list[2]}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:gNB enters into Powersaving mode
#     Start capture GNB and AP Syslog in 'Step3' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
# #    Start GNB BIP Log
# #    Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step3${/}
# 
#     Wait '600s' for stable running
#     Start GNB Ttitrace With Streaming Mode
#     Wait '2s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
# 
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step3' File
# 	
# Step4:UE-4 attach to Cell-1
#     Start capture GNB and AP Syslog in 'Step4' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4
# 
#     Start GNB BIP Log
#     UE_'4' Attach
#     SA send multiple trf data    4    DL    100M    1
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step4${/}
# 
#     Start GNB Ttitrace With Streaming Mode
#     Wait '2s' for stable running
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
# 
#     airphone_collect_egate_log_files      ${TEST_LOG_DIRECTORY()}${/}Step5${/}   unzip=TRUE
#     ${rnti_list}    file match all   ${TEST_LOG_DIRECTORY()}${/}Step5${/}/egate_console.log.001   crnti: (\\d+)
#     Set test Variable	 ${rnti_4} 	${rnti_list[3]}
# 
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step4' File
# 
# Step5:UE2 release
#     Start capture GNB and AP Syslog in 'Step5' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5
#     Start GNB BIP Log
#     Airphone SA Detach    2
#     Stop Gnb BIP Log    log_dir=${TEST_LOG_DIRECTORY()}${/}Step5${/}
# 
#     Start GNB Ttitrace With Streaming Mode
#     Wait '2s' for stable running
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step5' File
# 
# Step6:PowerSaving off
#     Start capture GNB and AP Syslog in 'Step6' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6
#     Wait '900s' for stable running
#     Start GNB Ttitrace With Streaming Mode
#     Wait '2s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
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
#    	...    csi_override_testmode_nr profile_id\=${ue_id} ri_mode\=fixed ri\=${ranki} cqi_mode\=fixed cqi\=${cqii}
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
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}
#     ${local_save_path}=     Download All Common Config Files From Golden Server
#     ${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
#     ${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     add_txt_node    0x340000:5             #as PM counter period update to 15/15=1min
#     #add_txt_node    0x5901EB:1             #rdForceEnablingWidebandTasSrs use for  itf_l2_ps_user_usermodifyreq.isWBTasConfigured_item_0=1
#     add_txt_node    0x5805ae:1             #Flag to enable or disable dynamic Wb/Sb Srs Switch
#     #add_txt_node    0x580556:2100          #rdStartPatternId=2100(Default Value is 5000)
#     #add_txt_node    0x5901E6:160           #rdMinSrsUePeriodicity=slots80(Default Value is 80slots)
#     add_txt_node    0x580762:80            #rdWbSrsSeTresh(100,Default Value is 9.1)
#     add_txt_node    0x580766:50            #rdWbSrsSeProh(100,Default Value is 30)
#     #add_txt_node    0x580764:0xfffffc18    #rdWbSrsQualTresh=-1000(Defalut Value is -1200)
#     #add_txt_node    0x580768:0x64          #rdWbSrsQualProh=10(10,Defalut Value is 5)
#     add_txt_node    0x580763:2             #rdWbSrsRankTresh(Defalut Value is 3)
#     #add_txt_node	0x580767:0              #rdWbSrsRankProh(Defalut Value is 0)
#     add_txt_node    0x58076b:0x64          #rdNumWbSrsCorrExpiry=100(Defalut Value is 60)
#     add_txt_node    0x580765:0x14          #rdWbSrsCorrTresh=0.2(100,Defalut Value is 0.3)
#     add_txt_node    0x580769:0xa           #rdWbSrsCorrProh=0.1(100,Defalut Value is 0.1)
#     add_txt_node    0x5805b0:20           #rdSrsBufPercent=100(Defalut Value is 20)
#     add_txt_node    0x5805b1:80           #rdSrsRlqGoodPercent(100,Defalut Value is 100) 
#     add_txt_node    0x5805b2:50            #rdSrsRlqBadPercent=50(100,Defalut Value is 50)
#     add_txt_node    0x5805b4:20            #rdPeriodSrsCheck(Defalut Value is 20)
#     add_txt_node    0x5805b5:60	          #rdNumSrsCheck(Defalut Value is 1)
#     add_txt_node    0x58076c:20            #rdWbSrsPrbTresh(Defalut Value is 45)
# #    add_txt_node    0x5901EA:1             #fake DRX
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
