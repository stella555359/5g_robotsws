# *** Settings ***
# Documentation     Author: xuemin.ma@nokia-sbell.com
# ...
# ...               QC case full name:
# ...               CB008322_E11_case01_Coexistence_with_low_PAPR
# ...
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_mqin
# Test Timeout      360 minutes
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
# ${WTS_NAME}           wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_FS_1S_1CC_UEs.cfg
# @{LOG_NAME_LIST}      egatelog    gnb_snapshot
# ${cellDepType}                    text|SA+NSA|//*[@name\="cellDepType"]
# ${chBw}                           text|100MHz|//*[@name\="chBw"]
# ${dlMimoMode}                     text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
# ${nrCellType}                     text|8DL4UL|//*[@name\="nrCellType"]
# ${actUeCsirsCoexistCellCsirs}     text|false|//*[@name\="actUeCsirsCoexistCellCsirs"]
# ${actCsirsMultiplexing}           text|true|//*[@name\="actCsirsMultiplexing"]
# ${actDlSrsBm}                     text|true|//*[@name\="actDlSrsBm"]
# ${actUlSrsBm}                     text|true|//*[@name\="actUlSrsBm"]
# ${actDlSrsSubbandBm}              text|true|//*[@name\="actDlSrsSubbandBm"]
# ${actUlClosedLoopPwrCtrl}         text|disabled|//*[@name\="actUlClosedLoopPwrCtrl"]
# ${actCDrx}                        text|false|//*[@name\="actCDrx"]
# ${actFdmScheduling}               text|true|//*[@name\="actFdmScheduling"]
# ${frameStructureType}             text|tdLte|//*[@name\="frameStructureType"]
# ${guardPeriodLength}              text|6Symbols|//*[@name\="guardPeriodLength"]
# ${lteToNrFrameShift}              text|3ms|//*[@name\="lteToNrFrameShift"]
# ${tdLteUlDlConfig}                text|tdLteConfig2|//*[@name\="tdLteUlDlConfig"]
# ${ulDlDataSlotRatio}              text|1/4|//*[@name\="ulDlDataSlotRatio"]
# ${prachConfigurationIndex}        text|98|//*[@name\="prachConfigurationIndex"]
# ${srsUePeriodicity}               text|slots80|//*[@name\="srsUePeriodicity"]
# ${cSRS}                           text|63|//*[@name\="cSRS"]
# ${bSRS}                           text|0|//*[@name\="bSRS"]
# ${srsPowerThresholdForDlBm}       text|-1200|//*[@name\="srsPowerThresholdForDlBm"]
# ${srsTypeAllocForDlBm}            text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
# ${bfSubbandSize}                  text|8 PRBs|//*[@name\="bfSubbandSize"]
# ${maxNumUeSrs}                    text|2|//*[@name\="maxNumUeSrs"]
# #${srsQualityThreshold}            text|-1050|//*[@name\="srsQualityThreshold"]
# ${srsPowerThreshold}                 text|-1050|//*[@name\="srsPowerThreshold"]
# ${prbSampleHighLowPercentage}        text|100|//*[@name\="prbSampleHighLowPercentage"]
# ${rlqGoodPercentage}                 text|100|//*[@name\="rlqGoodPercentage"]
# ${rlqBadPercentage}                text|90|//*[@name\="rlqBadPercentage"]
# ${prbRatioThreshold}                 text|2|//*[@name\="prbRatioThreshold"]
# ${prbRatioHysteresis}                text|90|//*[@name\="prbRatioHysteresis"]
# ${actDlLowPAPRoptimizedPrecoding}            text|true|//*[@name\="actDlLowPAPRoptimizedPrecoding"]
# ${openLoopScheme}                 text|Disabled|//*[@name\="openLoopScheme"]
# ${dlQam256PowerBackoffSub6}       text|15|//*[@name\="dlQam256PowerBackoffSub6"]
# ${actDl256Qam}                    text|true|//*[@name\="actDl256Qam"]
# ${actUl256Qam}                    text|true|//*[@name\="actUl256Qam"]
# ${maxCsirsNumber}                 text|2|//*[@name\="maxCsirsNumber"]
# ${csirsPower}                     text|3|//*[@name\="csirsPower"]
# ${ssPbchBlockPower}               text|3|//*[@name\="ssPbchBlockPower"]
# ${actCustomBsr}                   text|true|//*[@name\="actCustomBsr"]
# ${customBeamSetName}              text|BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001|//*[@name\="customBeamSetName"]
# ${actIncreasedFdmUsersPerSlot}    text|true|//*[@name\="actIncreasedFdmUsersPerSlot"]
# ${actDlMuMimoEnh}                 text|false|//*[@name\="actDlMuMimoEnh"]
# #${miNrMacSduReport}               text|15min|//*[@name\="miNrMacSduReport"]
# ${tiltOffset}                 text|0|//*[@name\="tiltOffset"]
# ${par_of_bsr_name}                BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
# ${bwp_profile8}      text|MRBTS-1/NRBTS-1/BWP_PROFILE-8|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile85}     text|MRBTS-1/NRBTS-1/BWP_PROFILE-85|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# 
# ${FILTER1}    dldata_pdschsendreq
# @{title1}     3gpp.rnti    DlData_PdschGrant.isLowPaprOptimizedPrecoding     DlData_PdschGrant.pdschBundleSize
# ...        DlData_PdschGrant.closedLoop3gppCodebook
# ...        DlData_PdschGrant.pdschPrecodingOption4x4    DlData_PdschGrant.i1Codebook4AntPorts_item
# ...        DlData_PdschGrant.i2Codebook4AntPorts
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-250,-250,-250,-250
# ${profile_2}    csi_override_testmode_nr profile_id=2 cqi_mode=fixed cqi=15 ri_mode=fixed ri=0
# ${Act_profile_2}    ue_testmode_set_nr id=1 testmode=csi_override profile_id=2 action=activate
# *** Test Cases ***
# CB008322_E11_case01_Coexistence_with_low_PAPR
#     Step1:Commission the above configuration on WebUI
# 	Step2:Attach UE1
#     Step3:Start full buffer
# #    Step3_2:overrride ri
#     Step3_3:trigger back to sb srs
#     Step4:Online modify actDlLowPAPRoptimizedPrecoding to false
#     Step5:Reattach ue and start full buffer
# 	Step6:Detach UE
# 
# *** Keywords ***
# Step1:Commission the above configuration on WebUI
#     Start capture GNB and AP Syslog in 'Step1_before_onair' File
#     ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
#     ${iphy_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}iphy.xml
#     copy_file    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}    ${iphy_path}
#     ${mod_iphy}    create list     text|2|//NumberOfSubCellsDL
#     modify xml     ${iphy_path}      ${iphy_path}    ${mod_iphy}
#     change_iphy_rru_version    ${iphy_path}
#     Wts Execute Aashell Command   
# 	...   confmgmtdefscli set --domain NrUeDlPhy --name radPdcchApplyToSeparateStreams_AP --value 1 --change-type persistent --timeout 5
#     modify_swconfig_by_CB008322    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
#     ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
#     copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="lteToNrFrameShift">3ms</p>|//*[@name\='tddFrameStructure']/item
#     add_xml_element     ${scfc_path}    ${scfc_path}     <p name="tdLteUlDlConfig">tdLteConfig2</p>|//*[@name\='tddFrameStructure']/item
#     add_periodicCsiAcquisition_list_in_cells    ${scfc_path}
# #    add_bwplist_list_in_cells_new    ${scfc_path}    key_3
#     ${modify_list}    create list
#     ...    ${cellDepType}                   ${chBw}                    ${dlMimoMode}                     ${nrCellType}
#     ...    ${actUeCsirsCoexistCellCsirs}    ${actCsirsMultiplexing}    ${actDlSrsBm}                     ${actUlSrsBm}
#     ...    ${actUlClosedLoopPwrCtrl}        ${actCDrx}                 ${actFdmScheduling}               ${frameStructureType}
#     ...    ${guardPeriodLength}             ${ulDlDataSlotRatio}       ${prachConfigurationIndex}        ${srsUePeriodicity}
#     ...    ${cSRS}                          ${bSRS}                    ${srsPowerThresholdForDlBm}       ${srsTypeAllocForDlBm}
#     ...    ${actDlSrsSubbandBm}             ${bfSubbandSize}           ${maxNumUeSrs}                    
#     ...    ${actCustomBsr}                  ${customBeamSetName}       ${actIncreasedFdmUsersPerSlot}
#     ...    ${actDlMuMimoEnh}                ${actDl256Qam}             ${actUl256Qam}
#     ...    ${lteToNrFrameShift}             ${tdLteUlDlConfig}         ${tiltOffset}
#     ...    ${actDlLowPAPRoptimizedPrecoding}    ${openLoopScheme}    ${dlQam256PowerBackoffSub6}
# 	...    ${srsPowerThreshold}    ${prbSampleHighLowPercentage}    ${rlqGoodPercentage}    ${rlqBadPercentage}
#     ...    ${prbRatioThreshold}    ${prbRatioHysteresis}
#     ...    ${maxCsirsNumber}     ${csirsPower}    ${ssPbchBlockPower}
#     ...    ${bwp_profile8}    ${bwp_profile85}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    ${par_of_bsr_name}
#     Add L2PS Deubg Logs
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Step2:Attach UE1
#     Start capture GNB and AP Syslog in 'Step2_attach' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
#     Start GNB BIP Log
#     Attach SA ue with capability    1    CA_P2_8x4_t2r4_n2
#     airphone_set_traffic_type    ue_id=1    pdu_id=1
#     airphone_pdu_session_setup    ue_id=1    pdu_id=1
#     Wait '2s' for stable running
# 	Stop Gnb BIP Log    log_dir=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step2_attach' File
# 
# Step3:Start full buffer
#     Start capture GNB and AP Syslog in 'Step3_send_data' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_send_data
#     Start GNB BIP Log
#     SA send multiple trf data    1    DL    175M    8
#     SA send multiple trf data    1    UL    175M    2
#     set UE1 position with profile1
#     Start GNB Ttitrace With Streaming Mode
#     Wait '2s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
# 
#     #check RT beam works
#     run keyword and continue on failure
#     ...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/E11_case01_tti.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     #check bundlesize=4 and lowPAPR works
#     Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap1    ${save_log}/E11_case01_bip.csv    ${FILTER1}    ${title1}
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/E11_case01_bip.ini    log_need_to_check=i    save_log_directory=${save_log}
#     #get tput
#     ${Dl_throughput_1} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${DL_throughput}    ${UL_throughput}    get tput from PM counter
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step3_send_data' File
# 
# Step3_3:trigger back to sb srs
#     Start capture GNB and AP Syslog in 'Step33_sb_srs' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step33_sb_srs
#     Start GNB BIP Log
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=deactivate profile_id\=1
#     Start GNB Ttitrace With Streaming Mode
#     Wait '2s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti_sb
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_sb_dl.csv    ${save_log}/target_dl_sb.csv
#     Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap1    ${save_log}/E11_case01_bip.csv    ${FILTER1}    ${title1}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step33_sb_srs' File
# 
# set UE${u_id} position with profile${PROFILE_id}
#     Airphone Execute Egate Command    ${PROFILE1}
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=${u_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=${PROFILE_id}
#     Wait '2s' for stable running
# 
# Step3_2:overrride ri
#     Start capture GNB and AP Syslog in 'Step3_2_RI' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_2_RI
#     FOR     ${i}    IN RANGE    1    4
#     \    airphone_execute_egate_command
#    	\    ...    csi_override_testmode_nr profile_id\=${i} ri_mode\=fixed ri\=${i} cqi_mode\=fixed cqi\=15
#     \    airphone_execute_egate_command
#     \    ...    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=${i}
#     \    Wait '5s' for stable running
#     \    Start GNB BIP Log
#     \    Wait '2s' for stable running
#     \    Stop Gnb BIP Log    log_dir=${save_log}/${i}
#     \    Convert BIP To CSV    ${save_log}/${i}/tcpdump_L2L1_bip_filtering_off.pcap1    
#     \    ...    ${save_log}/${i}/E11_case01_bip_rank.csv    ${FILTER1}    ${title1}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step3_2_RI' File
# 
# Step4:Online modify actDlLowPAPRoptimizedPrecoding to false
#     Start capture GNB and AP Syslog in 'Step4_change_parameters' File
#     COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
#     COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=actDlLowPAPRoptimizedPrecoding
#     ...    operation=update    value=false    skip_parameter_relation_errors=True    should_activate=True    connection=online
#     Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
#     COAM.teardown admin    connection=online
#     Wait '10s' for stable running
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step4_change_parameters' File
# 
# Step5:Reattach ue and start full buffer
#     Start capture GNB and AP Syslog in 'Step5_re_attach' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_re_attach
#     Start GNB BIP Log
#     Attach SA ue with capability    1    CA_P2_8x4_t2r4_n2
#     airphone_set_traffic_type    ue_id=1    pdu_id=1
#     airphone_pdu_session_setup    ue_id=1    pdu_id=1
#     SA send multiple trf data    1    DL    175M    8
#     SA send multiple trf data    1    UL    175M    2
#     set UE1 position with profile1
#     Start GNB Ttitrace With Streaming Mode
#     Wait '2s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Stop Gnb BIP Log    log_dir=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
#     Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap1    ${save_log}/E11_case01_false_bip.csv    ${FILTER1}    ${title1}
#     run keyword and continue on failure    check_log_with_au2anlysis
#     ...    ini_path=${CURDIR}/log_check/E11_case01_bip_false.ini    log_need_to_check=i    save_log_directory=${save_log}
#     ${Dl_throughput_2} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${DL_throughput}    ${UL_throughput}    get tput from PM counter
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step5_re_attach' File
# 
# Step6:Detach UE
#     Start capture GNB and AP Syslog in 'Step6_detach' File
#     Detach '1'UE
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step6_detach' File
# 
# Add L2PS Deubg Logs
#     ${debuglogs}    create list    level=DBG\n    L2.L2_PS.DEBUG=1\n    L2.L2_PS.DL.SUBBAND_BEAMFORMING=1\n    L2.L2_PS.SRS_BASED_BM=1\n
#     Active L2ps Feature Debug Traces    ${debuglogs}
#     TAF_SSH.connect to    192.168.255.1   toor4nsn    oZPS0POrRieRtu   alias=bsh
#     TAF_SSH.execute    rm /ffs/run/HashContainer*    connection=bsh
# 
# get tput from PM counter
#     ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
#     ${remaining_time}     evaluate    ${remaining_time}+300
#     Wait Throughput Timer    ${remaining_time}
#     ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}conter_files${/}
#     ${PM_counter_DL_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55309C12001
#     ...   cell_id=1
#     ${DL_throughput}    evaluate    ${PM_counter_DL_value}*8/1024/1024
# 	${PM_counter_UL_value}=    get_counter_value_from_counter_file
#     ...   counter_file=${PM_counter_file}
#     ...   counter_id=M55309C12002
#     ...   cell_id=1
#     ${UL_throughput}    evaluate    ${PM_counter_UL_value}*8/1024/1024
#     [Return]    ${DL_throughput}    ${UL_throughput}
# 
# modify_swconfig_by_CB008322
#     comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
#     [Arguments]    ${scfc_file}
#     ${local_save_path}=     Download All Common Config Files From Golden Server
#     ${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
#     ${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
#     setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     add_txt_node    0x340000:1             #as PM counter period update to 15/15=1min
#     add_txt_node    0x58076b:100           #rdNumWbSrsCorrExpiry=100(Defalut Value is 60)
#     teardown_txt
#     setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
