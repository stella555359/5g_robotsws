*** Settings ***
Documentation
...

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_O_H_AP_LOO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G
Test Timeout      180 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
Resource          ../../resources/sg10/internal_resource/internal_gnb.robot
Library     taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}   SCFC_9363_ASOH_E_006_1CELL.xml
${AIRPHONE_NAME}    iphy_ASOH_1CELL.xml
${WTS_NAME}         wts_ASOH_1cell.cfg
@{LOG_NAME_LIST}        egatelog    gnb_snapshot

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

${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=18 zenith\=-2 srs_transmit_power_per_port=-280,-280,-280,-280

#${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0
#...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=50 zenith\=-15 srs_transmit_power_per_port\=-320,-320,-280,-280

${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4

*** Test Cases ***
CB009363-E_006_4Rx_reception_for_PUCCH_F1_F3_in_C8
    Step1:Commission the above configuration on WebUI
	Step2:Attach UE and start buffer
	Step3:Change configuration to beamset_8 with rdRestrictedBeamSetPucchUsed=true
	Step4:Re-Attach UE and start buffer

*** Keywords ***
Step1:Commission the above configuration on WebUI
	Log to console    Step1:Commission the above configuration on WebUI
    Start Capture GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig    ${CONFIG_DIR_PATH}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}

    Modify TL VM And AP SCTP Configuration
	Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00002
	Get and Update BSR File    par_of_bsr_name=BSR_AQQL_8_H8_ALN60_ARP60_P00_COVERAGE_00426_00002
	Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step1_before_onair
#    airphone_execute_egate_command    ${PROFILE3}
#	airphone_execute_egate_command    ${SET_PROFILE3}

    [Teardown]    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File

modify_swconfig
	[Arguments]    ${config_path}
    setup_txt    src_file=${config_path}/swconfig_gnb_ini.txt    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    add_txt_node    0x9D0000:5         #as PM counter period update to 15/15=1min
#	add_txt_node    0x580627:1
#	add_txt_node    0x580117:3
	add_txt_node    0x59017D:10    #rdSrsBwFraction
	add_txt_node    0x580759:0    #not find
	add_txt_node    0x590200:1    #rdRestrictedBeamSetPucchUsed
	add_txt_node    0x580710:1    #rdCb10708FuncTest  This R&D parameter is used to enable/disable 10708 function test.
    teardown_txt
	setup_txt    src_file=${config_path}/swconfig_ap_ini.txt    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    #add_txt_node    0x70690:1         #enable 1086 and 8247
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt



Step2:Attach UE and start buffer
	Log to console    Step2:Attach UE and start buffer
    Start Collect GNB and AP Syslog in 'Step2_attach' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
	Start GNB BIP Log    bip_use_admin_api=true

#	Airphone Execute Egate Command    ul_sinr_testmode_nr profile_id\=3 sinr_target_pucch\=-300
#    Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_sinr action\=activate profile_id\=3
#    Airphone Execute Egate Command    ue_srs_beam_pos_nr profile_id\=1 init_pos\=0 srsMode\=fixed
#    Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ue_srs_beam_pos action\=activate profile_id\=1

    airphone_sa_attach    ue_id=1
    airphone_set_traffic_type    ue_id=1    pdu_id=1
    airphone_pdu_session_setup    ue_id=1    pdu_id=1
    airphone_execute_egate_command    ${PROFILE4}
    airphone_execute_egate_command    ${SET_PROFILE4}
    Wait '5s' for stable running
    SA send multiple trf data    1    DL    10M    2
    SA send multiple trf data    1    UL    15M    2
	Stop Gnb BIP Log    log_dir=${save_log}
    Wait Throughput Timer    15
    Capture ttitrace    3s    ${save_log}    step2
#	check patternid,For F1 ,using two half sector beam ,for F3 using SSB0 + SSB1,PUSCH dusing DFT
    Merge pcaps    ${save_log}
    run keyword and continue on failure   Convert BIP To CSV    ${save_log}/bip_merge.pcap
	...    ${save_log}/bip_pucch.csv    ${filter_2}    ${title_2}
	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/log_check/E_case06_bip_asoh_25R1.ini    log_need_to_check=i    save_log_directory=${save_log}
	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/log_check/E_case06_tti_asoh_25R1.ini    log_need_to_check=i    save_log_directory=${save_log}
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
	Log to console    Step3:Change configuration to beamset_8 with rdRestrictedBeamSetPucchUsed=true
    Start Collect GNB and AP Syslog in 'Step3_beamset8' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_beamset8
    Online recommissioning with delta json file    ${CURDIR}/JSON/delta_beam8_asoh.json
    Wait Throughput Timer    150
	Block Cell1
    Wait '10s' for stable running
	Start GNB BIP Log    bip_use_admin_api=true
    Unlock Cell1
    Stop Gnb BIP Log    log_dir=${save_log}
    Merge pcaps    ${save_log}
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step3_beamset8' File

Step4:Re-Attach UE and start buffer
	Log to console   Step4:Re-Attach UE and start buffer
    Start Collect GNB and AP Syslog in 'Step4_reAttach' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_reAttach
	Start GNB BIP Log    bip_use_admin_api=true
	#------- Prepare SSB Beam Attach-----#
    Airphone Execute Egate Command    ${PROFILE1}
    Airphone Execute Egate Command    ${SET_PROFILE1}
	#------- Define Ssb Beam-----#
    Airphone Execute Egate Command    ${PROFILE2}
    Airphone Execute Egate Command    ${SET_PROFILE2}
    airphone_sa_attach    ue_id=1
    airphone_set_traffic_type    ue_id=1    pdu_id=1
    airphone_pdu_session_setup    ue_id=1    pdu_id=1
    airphone_execute_egate_command    ${PROFILE4}
    airphone_execute_egate_command    ${SET_PROFILE4}
    Wait '5s' for stable running
    SA send multiple trf data    1    DL    10M    2
    SA send multiple trf data    1    UL    15M    2
	Stop Gnb BIP Log    log_dir=${save_log}
	Merge pcaps    ${save_log}
    Wait Throughput Timer    15
    Capture ttitrace    3s    ${save_log}    step4
#	check patternid,For F1 ,using two half sector beam ,for F3 using SSB0 + fullsectorBeamPatternId,PUSCH dusing DFT
    run keyword and continue on failure   Convert BIP To CSV    ${save_log}/bip_merge.pcap
	...    ${save_log}/bip_pucch_beamset8.csv    ${filter_2}    ${title_2}
	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/log_check/E_case06_bip_beamset8_asoh_25R1.ini    log_need_to_check=i    save_log_directory=${save_log}
	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/log_check/E_case06_tti_beamset8_asoh_25R1.ini    log_need_to_check=i    save_log_directory=${save_log}
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step4_reAttach' File

Merge pcaps
    [Arguments]     ${log_path}
	TAF_SSH.Connect To    127.0.0.1    ute    ute    alias=bsh
	TAF_SSH.Execute    cd    connection=bsh
	TAF_SSH.Send Command    cd ${log_path};mergecap -w bip_merge.pcap *.pcap    connection=bsh

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
