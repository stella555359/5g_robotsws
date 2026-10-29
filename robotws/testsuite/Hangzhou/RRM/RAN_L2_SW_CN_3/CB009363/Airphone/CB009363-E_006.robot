*** Settings ***
Documentation
...

Suite Setup       Common Suite Setup
#Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_MP_AP_LO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_xueminm
Test Timeout      90 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
Library     taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}   SCF_E_1cell_MP_LO.xml
${AIRPHONE_NAME}    iphy_D_1cell_AEQE.xml
${WTS_NAME}    wts_D_1cell.cfg
@{LOG_NAME_LIST}        egatelog    gnb_snapshot
${cellDepType}                             text|SA+NSA|//*[@name\="cellDepType"]
${chBw}                                    text|100MHz|//*[@name\="chBw"]
${dlMimoMode}                              text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${actDlSrsBm}                              text|false|//*[@name\="actDlSrsBm"]
${actUlSrsBm}                              text|true|//*[@name\="actUlSrsBm"]
${pucchModeSelect}                         text|longPucch|//*[@name\="pucchModeSelect"]
${numberOfRxBeamforming}                   text|8Rx|//*[@name\="numberOfRxBeamforming"]
${numberOfRxPucch}                         text|4Rx|//*[@name\="numberOfRxPucch"]
${actFdmScheduling}                        text|true|//*[@name\="actFdmScheduling"]
${actBeamforming}                          text|true|//*[@name\="actBeamforming"]
${nrBtsBeamRefinementP2}                   text|false|//*[@name\="nrBtsBeamRefinementP2"]
${actBbPoolTddFr1}                         text|true|//*[@name\="actBbPoolTddFr1"]
${actBbPoolTddFr1Enh}                      text|true|//*[@name\="actBbPoolTddFr1Enh"]
${basicBeamSet}                            text|beamSet_6|//*[@name\="basicBeamSet"]
${actUlDftSOfdm}                           text|false|//*[@name\="actUlDftSOfdm"]

${PROFILE1}    beam_control_testmode_nr profile_id=1 ueBeamIndexInitial=0,1,2,3 ssbeam_bestbeam=0 ssbeam_rsrp_best=-45 ssbeam_rsrp_avg=-120
${SET_PROFILE1}    ue_testmode_set_nr id=1 testmode=beam_control action=activate profile_id=1 beamaction=attach

${PROFILE2}    ue_srs_beam_pos_nr profile_id=1 init_pos=0 srsMode=fixed
${SET_PROFILE2}    ue_testmode_set_nr id=1 testmode=ue_srs_beam_pos profile_id=1 action=activate


${filter_1}    (uldata_puschreceiverespps)||(uldata_srsreceivereq)||(uldata_puschreceiverespps)
@{title_1}     3gpp.rnti    UlData_UePuschReceiveRespPs_t.ulRank    UlData_UePuschReceiveRespPs_t.dtx
...       UlData_UePuschReceiveRespPs_t.ulPmiRank1    UlData_UePuschReceiveRespPs_t.ulPmiRank1Sinr
...       UlData_UePuschReceiveRespPs_t.ulPmiRank2    UlData_UePuschReceiveRespPs_t.ulPmiRank2Sinr_item
...       UlData_srsReceiveReqUes_t.numCeAxCIndex    UlData_srsReceiveReqUes_t.patternId_item
...       UlData_srsReceiveRespPsUes_t.ulRank    UlData_srsReceiveRespPsUes_t.ulPmiRank1
...       UlData_srsReceiveRespPsUes_t.ulPmiRank1Sinr    UlData_srsReceiveRespPsUes_t.ulPmiRank2
...       UlData_srsReceiveRespPsUes_t.ulPmiRank2Sinr_item
${filter_2}    uldata_pucchreceivereq
@{title_2}     3gpp.rnti    UlData_pucchReceiveReqPucchResource_t.pucchFormat    UlData_pucchReceiveReqPucchResource_t.patternId_item
...       UlData_pucchReceiveReqPucchResource_t.numCeAxCIndex    UlData_pucchReceiveReqPucchResource_t.ceAxCIndex_item

*** Test Cases ***
CB009363-E_006_4Rx_reception_for_PUCCH_F1_F3_in_C8
    Step1:Commission the above configuration on WebUI
	Step2:Attach UE and start buffer
	Step3:Change configuration to beamset_8 with rdRestrictedBeamSetPucchUsed=true
	Step4:Re-Attach UE and start buffer

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Capture GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    ${modify_list}    create list
	...      ${cellDepType}
	...      ${chBw}    ${dlMimoMode}    ${actDlSrsBm}    ${actUlSrsBm}    ${pucchModeSelect}
	...      ${numberOfRxBeamforming}    ${numberOfRxPucch}    ${actFdmScheduling}    ${actBeamforming}    ${nrBtsBeamRefinementP2}
	...      ${actBbPoolTddFr1}     ${actBbPoolTddFr1Enh}    ${basicBeamSet}    ${actUlDftSOfdm}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
	Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
	Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step1_before_onair
    [Teardown]    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File

modify_swconfig
    comment     https://confluence.ext.net.nokia.com/pages/viewpage.action?spaceKey=AirPhoneWTS&title=AirPhone+Alignment+to+gNB+L1L2+Interface
    [Arguments]    ${scfc_file}
	${local_save_path}=     Download All Common Config Files From Golden Server
	${path_gnb}=            Find Match GNB swconfig Golden Files    ${scfc_file}    ${local_save_path}
	${path_ap}=             Find Match AP swconfig Golden Files    ${scfc_file}     ${local_save_path}
    setup_txt    src_file=${path_gnb}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
	add_txt_node    0x9D0000:5         #as PM counter period update to 15/15=1min
#	add_txt_node    0x580627:1
#	add_txt_node    0x580117:3
	add_txt_node    0x59017D:10
	add_txt_node    0x580759:0
	add_txt_node    0x590200:1
	add_txt_node    0x580710:1
#	add_txt_node    0x600018:0        #RdUlUpFragmentationEnable,Flag for enabling UL UserPlane dynamic fragmentation (CB008941)
#	add_txt_node    0x59017D:10       #rdSrsBwFraction
#	add_txt_node    0x59012C:0       #rdLongPucchF3BeamformingEnable,1-PUCCH Format 3 is received over at least one SSB beam
    teardown_txt
	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    #add_txt_node    0x70690:1         #enable 1086 and 8247
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt

Step2:Attach UE and start buffer
    Start Collect GNB and AP Syslog in 'Step2_attach' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
	Start GNB BIP Log
	Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=3 sinr_target_pucch\=-300
    Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=3
    Airphone Execute Egate Command    ue_srs_beam_pos_nr profile_id\=1 init_pos\=0 srsMode\=fixed
    Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ue_srs_beam_pos action\=activate profile_id\=1

    airphone_sa_attach    ue_id=1
    airphone_set_traffic_type    ue_id=1    pdu_id=1
    airphone_pdu_session_setup    ue_id=1    pdu_id=1
    Wait '5s' for stable running
    SA send multiple trf data    1    DL    10M    2
    SA send multiple trf data    1    UL    15M    2
	Stop Gnb BIP Log    log_dir=${save_log}
    Wait Throughput Timer    15
    Capture ttitrace    3s    ${save_log}    step2
#	check patternid,For F1 ,using two half sector beam ,for F3 using SSB0 + SSB1,PUSCH dusing DFT
    run keyword and continue on failure   Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${save_log}/bip_pucch.csv    ${filter_2}    ${title_2}
	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/log_check/E_case06_bip.ini    log_need_to_check=i    save_log_directory=${save_log}
	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/log_check/E_case06_tti.ini    log_need_to_check=i    save_log_directory=${save_log}
	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${save_log}${/}
    ${PUCCH_FORMAT1_DTX}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55303C13001    cell_id=1
	${PUCCH_FORMAT1_NON_DTX}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55303C14001    cell_id=1
    ${PUCCH_FORMAT3_DTX}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55303C17001    cell_id=1
	${PUCCH_FORMAT3_NON_DTX}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55303C18001    cell_id=1
	${foramt1_dtx_ratio}    Evaluate      ${PUCCH_FORMAT1_DTX}/(${PUCCH_FORMAT1_DTX}+${PUCCH_FORMAT1_NON_DTX})
	${foramt3_dtx_ratio}    Evaluate      ${PUCCH_FORMAT3_DTX}/(${PUCCH_FORMAT3_DTX}+${PUCCH_FORMAT3_NON_DTX})
	run keyword and continue on failure    should be true    ${foramt1_dtx_ratio} < 0.5
	run keyword and continue on failure    should be true    ${foramt3_dtx_ratio} < 0.5
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File

Step3:Change configuration to beamset_8 with rdRestrictedBeamSetPucchUsed=true
    Start Collect GNB and AP Syslog in 'Step3_beamset8' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_beamset8
    Online recommissioning with delta json file    ${CURDIR}/JSON/delta_beam8.json
    Wait Throughput Timer    150
	Block Cell1
    Wait '10s' for stable running
	Start GNB BIP Log
    Unlock Cell1
    Stop Gnb BIP Log    log_dir=${save_log}
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step3_beamset8' File

Step4:Re-Attach UE and start buffer
    Start Collect GNB and AP Syslog in 'Step4_reAttach' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_reAttach
	Start GNB BIP Log
	#------- Prepare SSB Beam Attach-----#
    Airphone Execute Egate Command    ${PROFILE1}
    Airphone Execute Egate Command    ${SET_PROFILE1}
	#------- Define Ssb Beam-----#
    Airphone Execute Egate Command    ${PROFILE2}
    Airphone Execute Egate Command    ${SET_PROFILE2}
    airphone_sa_attach    ue_id=1
    airphone_set_traffic_type    ue_id=1    pdu_id=1
    airphone_pdu_session_setup    ue_id=1    pdu_id=1
    Wait '5s' for stable running
    SA send multiple trf data    1    DL    10M    2
    SA send multiple trf data    1    UL    15M    2
	Stop Gnb BIP Log    log_dir=${save_log}
    Wait Throughput Timer    15
    Capture ttitrace    3s    ${save_log}    step4
#	check patternid,For F1 ,using two half sector beam ,for F3 using SSB0 + fullsectorBeamPatternId,PUSCH dusing DFT
    run keyword and continue on failure   Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${save_log}/bip_pucch_beamset8.csv    ${filter_2}    ${title_2}
	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/log_check/E_case06_bip_beamset8.ini    log_need_to_check=i    save_log_directory=${save_log}
	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/log_check/E_case06_tti_beamset8.ini    log_need_to_check=i    save_log_directory=${save_log}
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step4_reAttach' File

Capture ttitrace
    [Arguments]    ${time}    ${save_log}     ${file_tag}
    Start GNB Ttitrace With Streaming Mode
    sleep    ${time}
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/${file_tag}

Block Cell1
    COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=administrativeState
    ...    operation=update    value=Locked    skip_parameter_relation_errors=True    should_activate=True    connection=online
    #Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    COAM.teardown admin    connection=online
	
Unlock Cell1
    COAM.Connect To    bts_host=192.168.255.129    bts_port=443    use_ssl=True    name=online
    COAM.perform_parameter_recommissioning    dist_name=MRBTS-1/NRBTS-1/NRCELL-1    parameter=administrativeState
    ...    operation=update    value=Unlocked    skip_parameter_relation_errors=True    should_activate=True    connection=online
    Wait until keyword succeeds    600s    30s    Verify BTS Is Onair
    COAM.teardown admin    connection=online
