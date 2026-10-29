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
${CONFIG_DIR_PATH}    ${CURDIR}/../../CB009363/Airphone/config
${SCFC_NAME}   SCF_E_1cell_MP_LO.xml
${AIRPHONE_NAME}    iphy_D_1cell_AEQE.xml
${WTS_NAME}    wts_D_1cell.cfg
@{LOG_NAME_LIST}        egatelog    gnb_snapshot
${cellDepType}                             text|SA+NSA|//*[@name\="cellDepType"]
${chBw}                                    text|100MHz|//*[@name\="chBw"]
${dlMimoMode}                              text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${actDlSrsBm}                              text|true|//*[@name\="actDlSrsBm"]
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
${miNrSrsQuality}                          text|5min|//*[@name\="miNrSrsQuality"]
${miNrBeamforming2}                        text|5min|//*[@name\="miNrBeamforming2"]
${miNrDlHarq}                              text|5min|//*[@name\="miNrDlHarq"]
${miNrUlHarq}                              text|5min|//*[@name\="miNrUlHarq"]
${miNrDlHarqLowSEMCS}                      text|5min|//*[@name\="miNrDlHarqLowSEMCS"]
${miNrUlHarqLowSEMCS}                      text|5min|//*[@name\="miNrUlHarqLowSEMCS"]
${miNrUlHarqOne}                           text|5min|//*[@name\="miNrUlHarqOne"]
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
${filter_2}    uldata_pucchreceivereql1sw
@{title_2}     3gpp.rnti    UlData_pucchReceiveReqPucchResourceL1sw_t.pucchFormat    UlData_pucchReceiveReqPucchResourceL1sw_t.patternId_item
...       UlData_pucchReceiveReqPucchResourceL1sw_t.numCeAxCIndex    UlData_pucchReceiveReqPucchResourceL1sw_t.ceAxCIndex_item

*** Test Cases ***
CNI_113494_Case10_PDSCH_and_PUSCH_iBLER_counters_interworking_with_CB009363
    Step1:Commission the above configuration on WebUI
    Step2:Attach UE and start buffer

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
	...      ${miNrSrsQuality}    ${miNrBeamforming2}    ${miNrDlHarq}    ${miNrUlHarq}    ${miNrDlHarqLowSEMCS}    ${miNrUlHarqLowSEMCS}
	...      ${miNrUlHarqOne}
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
	add_txt_node    0x9D0000:1         #as PM counter period update to 15/15=1min
#	add_txt_node    0x580627:1
#	add_txt_node    0x580117:3
	add_txt_node    0x59017D:10
	add_txt_node    0x580759:0
	add_txt_node    0x590200:1
	add_txt_node    0x580710:1
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

	#	check patternid,For F1 ,using two half sector beam ,for F3 using SSB0 + SSB1,PUSCH using DFT
    run keyword and continue on failure   Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${save_log}/bip_pucch.csv    ${filter_2}    ${title_2}
	#run keyword and continue on failure    check_log_with_au2anlysis
    #...    ini_path=${CURDIR}/../../CB009363/Airphone/log_check/E_case06_bip.ini    log_need_to_check=i    save_log_directory=${save_log}
	#run keyword and continue on failure    check_log_with_au2anlysis
    #...    ini_path=${CURDIR}/../../CB009363/Airphone/log_check/E_case06_tti.ini    log_need_to_check=i    save_log_directory=${save_log}
    Get And Validate Counters    ${save_log}
	run keyword and continue on failure    should be true    ${PDSCH_INI_TX} == ${legacy_counter_PDSCH_INITX}
	run keyword and continue on failure    should be true    ${PDSCH_SUC_INI_TX} == ${legacy_counter_PDSCH_SUCC_INI}
	run keyword and continue on failure    should be true    ${PUSCH_INI_TX} == ${legacy_counter_PUSCH_INITX}
	run keyword and continue on failure    should be true    ${PUSCH_SUC_INI_TX} == ${legacy_counter_PUSCH_SUCC_INI}

	Airphone Execute Egate Command    bler_testmode_nr profile_id\=13 dl_bler\=300
    Airphone Execute Egate Command    ue_testmode_set_nr id\=1 scell\=0 testmode\=bler profile_id\=13 action\=activate
	airphone_execute_egate_command	  ul_sinr_testmode_nr profile_id\=11 pathloss\=105
    airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_sinr profile_id\=11 scell\=0 action\=activate
	Get And Validate Counters    ${save_log}
	run keyword and continue on failure    should be true    ${PDSCH_INI_TX} == ${legacy_counter_PDSCH_INITX}
	run keyword and continue on failure    should be true    ${PDSCH_SUC_INI_TX} == ${legacy_counter_PDSCH_SUCC_INI}
	run keyword and continue on failure    should be true    ${PUSCH_INI_TX} == ${legacy_counter_PUSCH_INITX}
	run keyword and continue on failure    should be true    ${PUSCH_SUC_INI_TX} == ${legacy_counter_PUSCH_SUCC_INI}
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File

Capture ttitrace
    [Arguments]    ${time}    ${save_log}     ${file_tag}
    Start GNB Ttitrace With Streaming Mode
    sleep    ${time}
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/${file_tag}

Get And Validate Counters
    [Arguments]    ${save_log}
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${save_log}${/}
    ${PDSCH_INI_TX_SSB_BEAM}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00043     cell_id=1
    ${PDSCH_SUC_INI_TX_SSB_BEAM}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00044     cell_id=1
    ${PUSCH_INI_TX_SSB_BEAM}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00045     cell_id=1
    ${PUSCH_SUC_INI_TX_SSB_BEAM}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00046     cell_id=1
    ${PDSCH_INI_TX_REFINED_BEAM}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00047     cell_id=1
    ${PDSCH_SUC_INI_TX_REFINED_BEAM}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00048     cell_id=1
    ${PUSCH_INI_TX_REFINED_BEAM}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00028     cell_id=1
    ${PUSCH_SUC_INI_TX_REFINED_BEAM}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00029     cell_id=1
    ${PDSCH_INI_TX_PMI_BEAM}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00030     cell_id=1
    ${PDSCH_SUC_INI_TX_PMI_BEAM}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00031     cell_id=1
    ${PDSCH_INI_TX_DFTTAP_BEAM}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00032     cell_id=1
    ${PDSCH_SUC_INI_TX_DFTTAP_BEAM}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00033     cell_id=1
    ${PUSCH_INI_TX_DFTTAP_BEAM}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00034     cell_id=1
    ${PUSCH_SUC_INI_TX_DFTTAP_BEAM}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00035     cell_id=1
    ${PDSCH_INI_TX_DFTNTAP_BEAM}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00036     cell_id=1
    ${PDSCH_SUC_INI_TX_DFTNTAP_BEAM}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00037     cell_id=1
    ${PUSCH_INI_TX_DFTNTAP_BEAM}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00038     cell_id=1
    ${PUSCH_SUC_INI_TX_DFTNTAP_BEAM}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00039     cell_id=1
    ${PDSCH_INI_TX_SUBBAND_BEAM}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00040     cell_id=1
    ${PDSCH_SUC_INI_TX_SUBBAND_BEAM}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55330C00041     cell_id=1


	${tmp_1}    Evaluate    (${PDSCH_INI_TX_SSB_BEAM}+${PDSCH_INI_TX_REFINED_BEAM}+${PDSCH_INI_TX_PMI_BEAM})
	${PDSCH_INI_TX}     Evaluate    (${tmp_1}+ ${PDSCH_INI_TX_DFTTAP_BEAM}+${PDSCH_INI_TX_DFTNTAP_BEAM}+${PDSCH_INI_TX_SUBBAND_BEAM})
	${tmp_2}     Evaluate    (${PDSCH_SUC_INI_TX_SSB_BEAM}+${PDSCH_SUC_INI_TX_REFINED_BEAM}+${PDSCH_SUC_INI_TX_PMI_BEAM})
	${PDSCH_SUC_INI_TX}     Evaluate    (${tmp_2}++${PDSCH_SUC_INI_TX_DFTTAP_BEAM}+${PDSCH_SUC_INI_TX_DFTNTAP_BEAM}+${PDSCH_SUC_INI_TX_SUBBAND_BEAM})

	${PUSCH_INI_TX}     Evaluate    (${PUSCH_INI_TX_SSB_BEAM}+${PUSCH_INI_TX_REFINED_BEAM}+${PUSCH_INI_TX_DFTTAP_BEAM}+${PUSCH_INI_TX_DFTNTAP_BEAM})
	${tmp_3}     Evaluate    (${PUSCH_SUC_INI_TX_SSB_BEAM}+${PUSCH_SUC_INI_TX_REFINED_BEAM})
	${PUSCH_SUC_INI_TX}     Evaluate    (${tmp_3}+${PUSCH_SUC_INI_TX_DFTTAP_BEAM}+${PUSCH_SUC_INI_TX_DFTNTAP_BEAM})

	@{value_list_PDSCH_INITX_64TBL_MCS_XX}        Create List
	@{value_list_PDSCH_INITX_LOWSE_MCS_XX}        Create List
	@{value_list_PDSCH_SUCC_INI_64TBL_MCS_XX}     Create List
	@{value_list_PDSCH_SUCC_INI_LOWSE_MCS_XX}     Create List
	@{value_list_PDSCH_INI_256TBL_MCS_XX}         Create List
	@{value_list_PDSCH_SUCC_INI_256TBL_MCS_XX}    Create List
	@{value_list_PUSCH_CP_INITX_64TBL_MCS_XX}     Create List
	@{value_list_PUSCH_CP_INI_LOWSE_MCS_XX}       Create List
	@{value_list_PUSCH_DFT_INI_64TBL_MCS_XX}      Create List
	@{value_list_PUSCH_CP_INI_256TBL_MCS_XX}      Create List
	@{value_list_PUSCH_CP_SUCC_INI_64TBL_MCS_XX}      Create List
	@{value_list_PUSCH_CP_SUCC_INI_256TBL_MCS_XX}      Create List
	@{value_list_PUSCH_DFT_SUCC_INI_64TBL_MCS_XX}      Create List
	@{value_list_PUSCH_CP_SUCC_INI_LOWSE_MCS_XX}      Create List

	FOR    ${i}    IN RANGE     00     29
	    ${index}     evaluate     "${i}".zfill(2)
	    ${value}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C000${index}    cell_id=1
	    append to list     ${value_list_PDSCH_INITX_64TBL_MCS_XX}   ${value}
	    ${value_2}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C010${index}    cell_id=1
	    append to list     ${value_list_PDSCH_INITX_LOWSE_MCS_XX}   ${value_2}
	    ${value_3}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C010${index}    cell_id=1
	    append to list     ${value_list_PDSCH_SUCC_INI_64TBL_MCS_XX}   ${value_3}
	    ${value_4}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55366C020${index}    cell_id=1
	    append to list     ${value_list_PDSCH_SUCC_INI_LOWSE_MCS_XX}   ${value_4}
	    ${value_7}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C000${index}    cell_id=1
	    append to list     ${value_list_PUSCH_CP_INITX_64TBL_MCS_XX}   ${value_7}
	    ${value_8}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C010${index}    cell_id=1
	    append to list     ${value_list_PUSCH_CP_INI_LOWSE_MCS_XX}   ${value_8}
	    ${value_11}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C040${index}    cell_id=1
	    append to list     ${value_list_PUSCH_CP_SUCC_INI_64TBL_MCS_XX}   ${value_11}
	    ${value_14}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55367C020${index}    cell_id=1
	     append to list     ${value_list_PUSCH_CP_SUCC_INI_LOWSE_MCS_XX}   ${value_14}
	END

	${PDSCH_INITX_64TBL_MCS_XX}        Evaluate    sum(${value_list_PDSCH_INITX_64TBL_MCS_XX})
	${PDSCH_INITX_LOWSE_MCS_XX}        Evaluate    sum(${value_list_PDSCH_INITX_LOWSE_MCS_XX})
	${PDSCH_SUCC_INI_64TBL_MCS_XX}     Evaluate    sum(${value_list_PDSCH_SUCC_INI_64TBL_MCS_XX})
	${PDSCH_SUCC_INI_LOWSE_MCS_XX}     Evaluate    sum(${value_list_PDSCH_SUCC_INI_LOWSE_MCS_XX})
	${PUSCH_CP_INITX_64TBL_MCS_XX}     Evaluate    sum(${value_list_PUSCH_CP_INITX_64TBL_MCS_XX})
	${PUSCH_CP_INI_LOWSE_MCS_XX}       Evaluate    sum(${value_list_PUSCH_CP_INI_LOWSE_MCS_XX})
	${PUSCH_CP_SUCC_INI_64TBL_MCS_XX}     Evaluate    sum(${value_list_PUSCH_CP_SUCC_INI_64TBL_MCS_XX})
	${PUSCH_PUSCH_CP_SUCC_INI_LOWSE_MCS_XX}       Evaluate    sum(${value_list_PUSCH_CP_SUCC_INI_LOWSE_MCS_XX})

	FOR    ${i}    IN RANGE     00     28
	    ${index}     evaluate     "${i}".zfill(2)
	    ${value_5}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C040${index}    cell_id=1
	     append to list     ${value_list_PDSCH_INI_256TBL_MCS_XX}   ${value_5}
	    ${value_6}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55300C050${index}    cell_id=1
	     append to list     ${value_list_PDSCH_SUCC_INI_256TBL_MCS_XX}   ${value_6}
	    ${value_9}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C060${index}    cell_id=1
	     append to list     ${value_list_PUSCH_DFT_INI_64TBL_MCS_XX}   ${value_9}
	    ${value_10}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C110${index}    cell_id=1
	     append to list     ${value_list_PUSCH_CP_INI_256TBL_MCS_XX}   ${value_10}
	    ${value_13}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C080${index}    cell_id=1
	     append to list     ${value_list_PUSCH_DFT_SUCC_INI_64TBL_MCS_XX}   ${value_13}
	    ${value_12}    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C130${index}    cell_id=1
	    append to list     ${value_list_PUSCH_CP_SUCC_INI_256TBL_MCS_XX}   ${value_12}
	END

	${PDSCH_INI_256TBL_MCS_XX}          Evaluate    sum(${value_list_PDSCH_INI_256TBL_MCS_XX})
	${PDSCH_SUCC_INI_256TBL_MCS_XX}     Evaluate    sum(${value_list_PDSCH_SUCC_INI_256TBL_MCS_XX})
	${PUSCH_DFT_INI_64TBL_MCS_XX}       Evaluate    sum(${value_list_PUSCH_DFT_INI_64TBL_MCS_XX})
	${PUSCH_CP_INI_256TBL_MCS_XX}       Evaluate    sum(${value_list_PUSCH_CP_INI_256TBL_MCS_XX})
	${PUSCH_DFT_SUCC_INI_64TBL_MC_XX}       Evaluate    sum(${value_list_PUSCH_DFT_SUCC_INI_64TBL_MCS_XX})
	${PUSCH_CP_SUCC_INI_256TBL_MCS_XX}       Evaluate    sum(${value_list_PUSCH_CP_SUCC_INI_256TBL_MCS_XX})

    ${legacy_counter_PDSCH_INITX}        Evaluate    (${PDSCH_INITX_64TBL_MCS_XX}+${PDSCH_INI_256TBL_MCS_XX}+${PDSCH_INITX_LOWSE_MCS_XX})
	${legacy_counter_PDSCH_SUCC_INI}     Evaluate   (${PDSCH_SUCC_INI_64TBL_MCS_XX}+${PDSCH_SUCC_INI_256TBL_MCS_XX}+${PDSCH_SUCC_INI_LOWSE_MCS_XX})

	${PUSCH_DFT_INI_64TBL_SAG_R2}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00007     cell_id=1
    ${PUSCH_DFT_INI_64TBL_SAG_R4}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00013     cell_id=1
	${PUSCH_DFT_SUC_INI_64TBL_SAG_R2}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00009     cell_id=1
    ${PUSCH_DFT_SUC_INI_64TBL_SAG_R4}
	...    get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55370C00015     cell_id=1

	${tmp_00}        Evaluate    (${PUSCH_CP_INITX_64TBL_MCS_XX}+${PUSCH_DFT_INI_64TBL_MCS_XX}+${PUSCH_CP_INI_256TBL_MCS_XX})
	${legacy_counter_PUSCH_INITX}    Evaluate    (${tmp_00}+${PUSCH_CP_INI_LOWSE_MCS_XX}+${PUSCH_DFT_INI_64TBL_SAG_R2}+${PUSCH_DFT_INI_64TBL_SAG_R4})

	${tmp_01}        Evaluate    (${PUSCH_CP_SUCC_INI_64TBL_MCS_XX}+${PUSCH_DFT_SUCC_INI_64TBL_MC_XX}+${PUSCH_CP_SUCC_INI_256TBL_MCS_XX})
	${tmp_02}        Evaluate    (${tmp_01}+${PUSCH_PUSCH_CP_SUCC_INI_LOWSE_MCS_XX})
	${legacy_counter_PUSCH_SUCC_INI}     Evaluate   (${tmp_02}+${PUSCH_DFT_SUC_INI_64TBL_SAG_R2}+${PUSCH_DFT_SUC_INI_64TBL_SAG_R4})

	Set test Variable    ${PDSCH_INI_TX}
	Set test Variable    ${PDSCH_SUC_INI_TX}
	Set test Variable    ${legacy_counter_PDSCH_INITX}
	Set test Variable    ${legacy_counter_PDSCH_SUCC_INI}
	Set test Variable    ${PUSCH_INI_TX}
	Set test Variable    ${PUSCH_SUC_INI_TX}
	Set test Variable    ${legacy_counter_PUSCH_INITX}
	Set test Variable    ${legacy_counter_PUSCH_SUCC_INI}

	#    Calculate PDSCH ibler
    #iBLER for PDSCH (Initial BLER =100 * (initial transmissions sent - initial transmissions success) / (initial transmissions sent))
    ${iBler_pdsch_ssb}          Run Keyword If    ${PDSCH_INI_TX_SSB_BEAM}!= 0
	...    Evaluate    100*(${PDSCH_INI_TX_SSB_BEAM}-${PDSCH_SUC_INI_TX_SSB_BEAM})/${PDSCH_INI_TX_SSB_BEAM}
	${iBler_pdsch_refine}       Run Keyword If    ${PDSCH_INI_TX_REFINED_BEAM}!= 0
	...    Evaluate    100*(${PDSCH_INI_TX_REFINED_BEAM}-${PDSCH_SUC_INI_TX_REFINED_BEAM})/${PDSCH_INI_TX_REFINED_BEAM}
	${iBler_pdsch_pmi}          Run Keyword If    ${PDSCH_INI_TX_PMI_BEAM}!= 0
	...    Evaluate    100*(${PDSCH_INI_TX_PMI_BEAM}-${PDSCH_SUC_INI_TX_PMI_BEAM})/${PDSCH_INI_TX_PMI_BEAM}
	${iBler_pdsch_dftNtap}      Run Keyword If    ${PDSCH_INI_TX_DFTNTAP_BEAM}!= 0
	...    Evaluate    100*(${PDSCH_INI_TX_DFTNTAP_BEAM}-${PDSCH_SUC_INI_TX_DFTNTAP_BEAM})/${PDSCH_INI_TX_DFTNTAP_BEAM}
	${iBler_pdsch_rt}           Run Keyword If    ${PDSCH_INI_TX_SUBBAND_BEAM}!= 0
	...    Evaluate    100*(${PDSCH_INI_TX_SUBBAND_BEAM}-${PDSCH_SUC_INI_TX_SUBBAND_BEAM})/${PDSCH_INI_TX_SUBBAND_BEAM}

	Log To Console    \n----------PDSCH All Beam Type iBler counter--------
	Log To Console    iBler_pdsch_ssb:${iBler_pdsch_ssb}
	Log To Console    iBler_pdsch_refine:${iBler_pdsch_refine}
	Log To Console    iBler_pdsch_pmi:${iBler_pdsch_pmi}
	Log To Console    iBler_pdsch_dftNtap:${iBler_pdsch_dftNtap}
    Log To Console    iBler_pdsch_rt: ${iBler_pdsch_rt}
	Log To Console    \n----------PUSCH All Beam Type counter--------
	Log To Console    PUSCH_INI_TX:${PUSCH_INI_TX}
    Log To Console    PUSCH_SUC_INI_TX:${PUSCH_SUC_INI_TX}
    Log To Console    legacy_counter_PUSCH_INITX:${legacy_counter_PUSCH_INITX}
    Log To Console    legacy_counter_PUSCH_SUCC_INI:${legacy_counter_PUSCH_SUCC_INI}
