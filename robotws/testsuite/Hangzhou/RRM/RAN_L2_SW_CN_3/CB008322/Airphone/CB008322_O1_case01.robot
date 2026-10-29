# *** Settings ***
# Documentation     Author: xuemin.ma@nokia-sbell.com
# ...         The robot contain 2 part:
# ...         1.CB008322_O1_case001_More_frequent_BWV_calculations_when_less_than_2_RT_beam_UE
# ...         2.CB008322_O1_case002_Interworking with rank switch blocking
# 
# Suite Setup       Common Suite Setup
# #Suite Teardown    Common Suite Teardown
# Test Setup        Common Test Setup
# Test Teardown     Common Test Teardown
# Force Tags        CLOUD_5G_I_LO_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_xueminm
# Test Timeout      90 minutes
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
# ${actUlSrsBm}                     text|true|//*[@name\="actUlSrsBm"]
# ${actDlSrsSubbandBm}              text|true|//*[@name\="actDlSrsSubbandBm"]
# ${actInterRankSwitchBlock}        text|true|//*[@name\="actInterRankSwitchBlock"]
# ${rankSwitchBlockBlerHighThres}        text|8|//*[@name\="rankSwitchBlockBlerHighThres"]
# ${rankSwitchBlockBlerLowThres}         text|5|//*[@name\="rankSwitchBlockBlerLowThres"]
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
# ${srsUePeriodicity}               text|slots80|//*[@name\="srsUePeriodicity"]
# ${cSRS}                           text|62|//*[@name\="cSRS"]
# ${bSRS}                           text|2|//*[@name\="bSRS"]
# ${srsPowerThresholdForDlBm}       text|-1200|//*[@name\="srsPowerThresholdForDlBm"]
# ${srsTypeAllocForDlBm}            text|antenna switching or codebook|//*[@name\="srsTypeAllocForDlBm"]
# ${bfSubbandSize}                  text|16 PRBs|//*[@name\="bfSubbandSize"]
# ${maxNumUeSrs}                    text|4|//*[@name\="maxNumUeSrs"]
# ${seHysteresis}                   text|60|//*[@name\="seHysteresis"]
# ${actCustomBsr}                   text|true|//*[@name\="actCustomBsr"]
# ${customBeamSetName}              text|BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001|//*[@name\="customBeamSetName"]
# ${tiltOffset}                     text|0|//*[@name\="tiltOffset"]
# ${nrBtsBeamRefinementP2}          text|true|//*[@name\="nrBtsBeamRefinementP2"]
# ${maxCsirsNumber}                 text|2|//*[@name\="maxCsirsNumber"]
# ${csirsPower}                     text|3|//*[@name\="csirsPower"]
# ${miNrSrsQuality}                 text|5min|//*[@name\="miNrSrsQuality"]
# ${miNrBeamforming2}               text|5min|//*[@name\="miNrBeamforming2"]
# ${csirsNumberWithinReportPeriod_Set1}                     text|2|//*[@name\="csirsNumberWithinReportPeriod_Set1"]
# ${bwp_profile7}                   text|MRBTS-1/NRBTS-1/BWP_PROFILE-7|//*[@name\="cellBwpList"]/item[1]/*[@name\="bwpDN"]
# ${bwp_profile77}                  text|MRBTS-1/NRBTS-1/BWP_PROFILE-77|//*[@name\="cellBwpList"]/item[2]/*[@name\="bwpDN"]
# ${dllaDeltaCqiMax}                text|0|//*[@name="dllaDeltaCqiMax"]
# ${par_of_bsr_name}                BSR_AQQL_6_H6_ALN60_ARP60_P11_COVERAGE_00776_00001
# 
# ${FILTER1}    itf_l2_ps_cell_cellsetupreq
# @{title1}    itf_l2_ps_cell_BfSetup.actDlSrsSubbandBm    itf_l2_ps_cell_DlSubbandBmConfig.bfSubbandSize
# ...    itf_l2_ps_cell_DlSubbandBmConfig.rtBeamStartPid    itf_l2_ps_cell_DlSubbandBmConfig.numOfRtBeamPid
# ${PROFILE1}    ul_mimo_srs_beam_pos_nr profile_id=1 mode=fixed init_quad_pos=1 init_sub_quad_pos=1 test_type=SRS
# ...        multi_path_config=true num_of_nlos_paths=1 azimuth=15 zenith=0 srs_transmit_power_per_port=-300,-300,-300,-300
# 
# *** Test Cases ***
# CB008322_O1_case001_More_frequent_BWV_calculations_when_less_than_2_RT_beam_UE
#     Step1:Commission the above configuration on WebUI
#     Step2:UE1 attach to cell and send DL and UL full buffer
#     Step3:trigger UE1 report rank=3, MCS>22, bler<8%
#     Step4:tigger bler bigger>8%
#     Step5:tigger UE1 switch back to RT beam
#     Step6:trigger UE1 report rank=3, 18<MCS<22, bler<5%
#     Step7:Detach UE1
#     Step8:Attach 4 NSA UE and start full buffer
#     Step9:Detach NSA UEs
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
#     ...    ${maxNumUeSrs}    ${actCustomBsr}    ${customBeamSetName}    ${actInterRankSwitchBlock}
#     ...    ${tiltOffset}    ${nrBtsBeamRefinementP2}    ${maxCsirsNumber}    ${csirsPower}     ${csirsNumberWithinReportPeriod_Set1}
#     ...    ${bwp_profile7}    ${bwp_profile77}    ${seHysteresis}
#     ...    ${miNrSrsQuality}    ${miNrBeamforming2}    ${rankSwitchBlockBlerHighThres}    ${rankSwitchBlockBlerLowThres}
#     modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
#     Modify TL VM And AP SCTP Configuration
#     Get and Update BSR File    ${par_of_bsr_name}
# 	Add L2PS Deubg Logs
#     Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
# 	[Teardown]    Stop capture GNB and AP Syslog in 'Step1_before_onair' File
# 
# Add L2PS Deubg Logs
#     ${debuglogs}    create list    level=DBG\n    L2.L2_PS.DEBUG=1\n    L2.L2_PS.DL.SUBBAND_BEAMFORMING=1\n    L2.L2_PS.SRS_BASED_BM=1\n
#     ...    L2.L2_PS.LINK_ADAPTATION=1\n
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
#     teardown_txt
# 	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
#     teardown_txt
#     GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
#     airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
# 
# Step2:UE1 attach to cell and send DL and UL full buffer
#     Start capture GNB and AP Syslog in 'Step2_attach' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
# #    Start GNB BIP Log
#     Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
#     Wait '3s' for stable running
#     : FOR    ${trf_id}    IN RANGE    1    9
#     \    Airphone SA Start Data Traffic    ue_id=1    direction=dl    throughput=175M    trf_id=${trf_id}    duration=7200
#     Airphone Sa Start Data Traffic    ue_id=1    direction=ul    throughput=175M    trf_id=1    duration=7200
#     Set UE'1' to UE'1' position
#     Wait '10s' for stable running
#     ${Dl_throughput} =    Airphone Sa Get Throughput    ue_id=1    direction=dl
#     ${Ul_throughput} =    Airphone Sa Get Throughput    ue_id=1    direction=ul
#     Capture ttitrace    ${save_log}
# #    Stop Gnb BIP Log    log_dir=${save_log}
#     run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/O1_case01_tti_step2.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step2_attach' File
# 
# Set UE'${ue_id}' to UE'${ue_id_end}' position
#     : FOR    ${u_id}    IN RANGE    ${ue_id}    ${ue_id_end}+1
#     \    Airphone Execute Egate Command    ${PROFILE1}
#     \    Airphone Execute Egate Command    ue_testmode_set_nr id\=${u_id} testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1
#     \    Wait '2s' for stable running
# 
# Capture ttitrace
#     [Arguments]    ${save_log}
#     Start GNB Ttitrace With Streaming Mode
#     Wait '2s' for stable running
#     ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
#     Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#     run keyword and continue on failure    spill_value_of_srsswitchmeas    ${save_log}/tti_dl.csv    ${save_log}/target_dl.csv
# 
# Step3:trigger UE1 report rank=3, MCS>22, bler<8%
#     Start capture GNB and AP Syslog in 'Step3_low_rish_mcs' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_low_rish_mcs
# #    Start GNB BIP Log
#     Airphone Execute Egate Command    csi_override_testmode_nr profile_id\=11 cqi\=15 cqi_mode\=fixed cqi_min\=1 cqi_max\=15 ri\=2
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=11
#     Airphone Execute Egate Command    bler_testmode_nr profile_id\=2 dl_bler\=60,0,0,0,0,0,0,0
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=bler action\=activate profile_id\=2
#     Capture ttitrace    ${save_log}
# #    Stop Gnb BIP Log    log_dir=${save_log}
# 
#     #check rankswitch blocking works
#     run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/O1_case01_tti_step3.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step3_low_rish_mcs' File
# 
# Step4:tigger bler bigger>8%
#     Start capture GNB and AP Syslog in 'Step4_high_bler' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_high_bler
#     Airphone Execute Egate Command    bler_testmode_nr profile_id\=12 dl_bler\=150,0,0,0,0,0,0,0
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=bler action\=activate profile_id\=12
#     Capture ttitrace    ${save_log}
# 
#     #check rankswitch to rank3 and later switch to dft
#     run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/O1_case01_tti_step4.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step4_high_bler' File
# 
# Step5:tigger UE1 switch back to RT beam
#     Start capture GNB and AP Syslog in 'Step5_clear_bler' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_clear_bler
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=bler action\=deactivate profile_id\=2
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=bler action\=deactivate profile_id\=12
#     Airphone Execute Egate Command    csi_override_testmode_nr profile_id\=11 cqi\=15 cqi_mode\=fixed cqi_min\=1 cqi_max\=15 ri\=3
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=11
#     Capture ttitrace    ${save_log}
#     #check switch to rt
#     run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/O1_case01_tti_step2.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step5_clear_bler' File
# 
# Step6:trigger UE1 report rank=3, 18<MCS<22, bler<5%
#     Start capture GNB and AP Syslog in 'Step6_high_risk_mcs' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step6_high_risk_mcs
# #    Start GNB BIP Log
#     Airphone Execute Egate Command    csi_override_testmode_nr profile_id\=11 cqi\=10 cqi_mode\=fixed cqi_min\=1 cqi_max\=15 ri\=2
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=11
#     Airphone Execute Egate Command    bler_testmode_nr profile_id\=2 dl_bler\=50,0,0,0,0,0,0,0
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=bler action\=activate profile_id\=2
#     Capture ttitrace    ${save_log}
# #    Stop Gnb BIP Log    log_dir=${save_log}
#     #check rankswitch blocking works
#     run keyword and continue on failure
# 	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/O1_case01_tti_step3.ini    log_need_to_check=i
#     ...    save_log_directory=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step6_high_risk_mcs' File
# 
# Step7:Detach UE1
#     Start capture GNB and AP Syslog in 'Step7_detach_ue1' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step7_detach_ue1
#     Detach '1'UE
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=bler action\=deactivate profile_id\=2
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=bler action\=deactivate profile_id\=12
#     Airphone Execute Egate Command    csi_override_testmode_nr profile_id\=11 cqi\=15 cqi_mode\=fixed cqi_min\=1 cqi_max\=15 ri\=3
#     Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=csi_override action\=activate profile_id\=11
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step7_detach_ue1' File
# 
# Step8:Attach 4 NSA UE and start full buffer
#     Start capture GNB and AP Syslog in 'Step7_attach_4_nsaUE' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step7_attach_4_nsaUE
# #    Start GNB BIP Log
#     : FOR    ${u_id}    IN RANGE    11    15
#     \    Airphone Nsa Attach    ue_id=${u_id}
# 	\    Wait '5s' for stable running
#     \    Airphone NSA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=1    duration=7200
#     \    Airphone NSA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=2    duration=7200
# 	\    Airphone NSA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=3    duration=7200
# 	\    Airphone NSA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=4    duration=7200
#     \    Airphone NSa Start Data Traffic    ue_id=${u_id}    direction=ul    throughput=175M    trf_id=1    duration=7200
#     Set UE'11' to UE'14' position
#     Wait '10s' for stable running
#     Capture ttitrace    ${save_log}
# #    Stop Gnb BIP Log    log_dir=${save_log}
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step7_attach_4_nsaUE' File
# 
# Step9:Detach NSA UEs
#     Start capture GNB and AP Syslog in 'Step9_detach_4ue' File
#     ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step9_detach_4ue
#     Airphone Nsa Detach All
#     [Teardown]    Stop capture GNB and AP Syslog in 'Step9_detach_4ue' File
