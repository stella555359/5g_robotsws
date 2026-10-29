*** Settings ***
Documentation     Author: zhaona.jiang@nokia-sbell.com...
...               QC case full name:
...               CB008360_D_B1a_case_140_Retransmission UEs paired with initTx Ues PM counter update    ...    for reTX UE counters
#
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_BOO_AP_KLLL_SANSA_L1B_ECPRI_CMWV_TDD    AP    CRT    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    owner_jiangzhaona
Test Timeout      90 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
#
*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/../../resources/sg11/internal_resource/config/
${SCFC_NAME}      8360_112_8d8u.xml
#${SCFC_NAME}      new_gNB_scf_ASIB_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.xml
${AIRPHONE_NAME}    AP_iphy_AEQE_LO_AP_LO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC_srs_B.xml
${WTS_NAME}       wts_config_ASIL_ABIO_TDD_eCPRI_cmwv_SANSA_L1b_1S_1CC.cfg
${COMAVALUE}          ${CURDIR}/../../resources/sg11/internal_resource/config/AP/ap_coma.txt
@{LOG_NAME_LIST}      egatelog\
#
${cellDepType}                              text|SA+NSA|//*[@name\="cellDepType"]
${chBw}                                     text|60MHz|//*[@name\="chBw"]
${cSRS}                                     text|42|//*[@name\="cSRS"]
${dlMimoMode}                               text|8x4 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${nrCellType}                               text|8DL8UL|//*[@name\="nrCellType"]
${actUlMuMimo}                              text|true|//*[@name\="actUlMuMimo"]
${ulMaxMuMimoLayer}                         text|4|//*[@name\="ulMaxMuMimoLayer"]
${actUlMuMimoTapering}                      text|false|//*[@name\="actUlMuMimoTapering"]
${ulMuMimoTaperingH}                        text|20dB|//*[@name\="ulMuMimoTaperingH"]
${ulMuMimoTaperingV}                        text|25dB|//*[@name\="ulMuMimoTaperingV"]
${frameStructureType}                       text|semiStatic|//*[@name\="frameStructureType"]
${ulDlDataSlotRatio}                        text|1/4|//*[@name\="ulDlDataSlotRatio"]
${guardPeriodLength}                        text|2Symbols|//*[@name\="guardPeriodLength"]
${prachConfigurationIndex}                  text|98|//*[@name\="prachConfigurationIndex"]
${ulMuMimoCorrThd2}                              text|45|//*[@name\="ulMuMimoCorrThd2"]
#
${bwpDN1}                                   text|MRBTS-1/NRBTS-2/BWP_PROFILE-7|//*[contains(@name,'cellBwpList')]//item[1]/*[@name\='bwpDN']
${bwpDN2}                                   text|MRBTS-1/NRBTS-2/BWP_PROFILE-77|//*[contains(@name,'cellBwpList')]//item[2]/*[@name\='bwpDN']
${bwp_duration1}                            text|3|//*[contains(@distName, 'BWP_PROFILE-7')]//item[1]/*[@name\='duration']
${bwp_duration3}                            text|3|//*[contains(@distName, 'BWP_PROFILE-7')]//item[3]/*[@name\='duration']
${dur_dedi}                                 
   ...    text|1|//*[contains(@distName, 'BWP_PROFILE-77/PDCCH-1/PDCCH_CONFIG_DEDICATED-1')]//*[@name\='duration']
${bwp_periodicity_1}                        text|sl5|//*[contains(@distName, 'BWP_PROFILE-7')]//item[1]/*[@name\='periodicity']
${bwp_periodicity_3}                        text|sl5|//*[contains(@distName, 'BWP_PROFILE-7')]//item[3]/*[@name\='periodicity']
${slotOffset}                               text|0|//*[contains(@distName, 'BWP_PROFILE-7')]//*[@name\='slotOffset']
${size}                                     text|162|//*[contains(@distName, 'BWP_PROFILE-77')]//*[@name\='size']
${ullaDeltaSinrMax}                             text|5|//*[@name\="ullaDeltaSinrMax"]
${ullaDeltaSinrMin}                             text|-5|//*[@name\="ullaDeltaSinrMin"]
${ulMuMimoCorrThd}                              text|50|//*[@name\="ulMuMimoCorrThd"]
${tiltOffset}                          text|0|//*[@name\="tiltOffset"]
${ulSinrDiffThreshold}                          text|30|//*[@name\="ulSinrDiffThreshold"]
${ulMuMimoLinkAdaptionSwitch}                   text|MCS compensation|//*[@name\="ulMuMimoLinkAdaptionSwitch"]
#
${pattern}    CA_P2_8x4_t2r4_n2_pusch_1layer
#
*** Test Cases ***
CB008360_D_B1a_case_140_Retransmission UEs paired with initTx Ues PM counter update for reTX UE counters
    Step1:Commission the above configuration on WebUI
    Step2:Attach 4 sa ue with rank1
	Step3:Send nack to UE1 to trigger retransmission
	Step4:Send nack to UE2 to trigger retransmission
	Step5:Send nack to UE3 to trigger retransmission
#
*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Collect GNB and AP Syslog in 'Step1_before_onair' File
	${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    #Airphone Download L1ByPTestModeConfiguration from ABIL    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
    #Set Pos By Modify L1ByPTestModeConfiguration    12    0    12    0    12    0    12    0
    #Set Pos By Modify L1ByPTestModeConfiguration    6    0    6    0    6    0    6    0    1
    #Set Pos By Modify L1ByPTestModeConfiguration    0    0    0    0    0    0    0    0    2
    #Set Pos By Modify L1ByPTestModeConfiguration    21    0    21    0    21    0    21    0    3
    #Set Pos By Modify L1ByPTestModeConfiguration    15    0    15    0    15    0    15    0    4    0    0    0    0    0
    #...     0    0    0    1    1
    #...    ulPmiRank1Sinr1=33    ulPmiRank1Sinr2=33    ulPmiRank1Sinr3=33    ulPmiRank1Sinr4=33
    #Airphone Upload L1ByPTestModeConfiguration to ASIK    ${test_log_directory()}/L1ByPTestModeConfiguration.xml
    modify_swconfig_by_CB008360    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    #add_xml_element     ${scfc_path}    ${scfc_path}     <p name="ulMuMimoCorrThd2">5</p>|//*[contains(@distName, 'NRULMUMIMO-0')]
	#del_elements_from_xml    xml_path=${scfc_path}    parameter=lteToNrFrameShift
	#del_elements_from_xml    xml_path=${scfc_path}    parameter=tdLteUlDlConfig
    #${modify_list}    create list
    #...    ${cellDepType}    ${chBw}    ${dlMimoMode}    ${nrCellType}    ${actUlMuMimo}    ${ulMaxMuMimoLayer}    ${actUlMuMimoTapering}
    #...    ${actUlMuMimoTapering}    ${ulMuMimoTaperingH}    ${ulMuMimoTaperingV}    ${frameStructureType}    ${guardPeriodLength}
    #...    ${ulDlDataSlotRatio}    ${prachConfigurationIndex}    ${bwpDN1}    ${bwpDN2}    ${bwp_duration1}    ${size}    ${dur_dedi}
    #...    ${bwp_duration3}    ${cSRS}    ${bwp_periodicity_1}    ${bwp_periodicity_3}   ${slotOffset}    ${ullaDeltaSinrMax}    
    #...    ${ullaDeltaSinrMin}
    #...    ${ulMuMimoCorrThd}    ${tiltOffset}    ${ulSinrDiffThreshold}    ${ulMuMimoCorrThd2}    ${ulMuMimoLinkAdaptionSwitch}
    #modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
	Get and Update BSR File    par_of_bsr_name=AEQE_6_H6_ALN60_ARP60_P00_COVERAGE_00424_000
    Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step1_before_onair' File
#
Step2:Attach 4 sa ue with rank1
    Start Collect GNB and AP Syslog in 'Step2_attach' File
    Attach SA ue with capability to 5g cell    4    CA_P2_8x4_t2r4_n2_pusch_1layer
    airphone_execute_egate_command
    ...    ul_mimo_srs_beam_pos_nr profile_id\=1 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
	airphone_execute_egate_command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=1 scell\=0
    airphone_execute_egate_command
    ...    ul_mimo_srs_beam_pos_nr profile_id\=2 mode\=fixed init_quad_pos\=2 init_sub_quad_pos\=2 step\=10 trigger_puxch_update\=0
	airphone_execute_egate_command    ue_testmode_set_nr id\=2 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=2 scell\=0
	airphone_execute_egate_command
    ...    ul_mimo_srs_beam_pos_nr profile_id\=5 mode\=fixed init_quad_pos\=0 init_sub_quad_pos\=0 step\=10 trigger_puxch_update\=0
	airphone_execute_egate_command    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=5 scell\=0
	airphone_execute_egate_command
    ...    ul_mimo_srs_beam_pos_nr profile_id\=10 mode\=fixed init_quad_pos\=1 init_sub_quad_pos\=0 step\=10 trigger_puxch_update\=0
	airphone_execute_egate_command    ue_testmode_set_nr id\=3 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=10 scell\=0
    Airphone SA Start Data Traffic    1    UL    150M    trf_id=1    pdu_id=1    duration=${7200}
    Airphone SA Start Data Traffic    2    UL    150M    trf_id=1    pdu_id=1    duration=${7200}
    Airphone SA Start Data Traffic    3    UL    150M    trf_id=1    pdu_id=1    duration=${7200}
    Airphone SA Start Data Traffic    4    UL    150M    trf_id=1    pdu_id=1    duration=${7200}
    ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch
    ${ue2_ul_tput}=    Airphone Get Throughput On Specific Scell    2    0    pusch
    ${ue3_ul_tput}=    Airphone Get Throughput On Specific Scell    3    0    pusch
    ${ue4_ul_tput}=    Airphone Get Throughput On Specific Scell    4    0    pusch
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    3
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}${/}tti
	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case140_tti_step2_FS.ini    log_need_to_check=i    save_log_directory=${save_log}
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
	Wait Throughput Timer    90
	Wait Until Keyword Succeeds    120s    10s    check counter    Step2_attach
    [Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File
#
#
Step3:Send nack to UE1 to trigger retransmission
    Start Collect GNB and AP Syslog in 'Step3_ue1_retx' File
    #Start GNB BIP Log
    Trigger ul bler    1    0
    Wait Throughput Timer    3
    ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch
    ${ue2_ul_tput}=    Airphone Get Throughput On Specific Scell    2    0    pusch
    ${ue3_ul_tput}=    Airphone Get Throughput On Specific Scell    3    0    pusch
    ${ue4_ul_tput}=    Airphone Get Throughput On Specific Scell    4    0    pusch
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_ue1_retx
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    3
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case140_tti_step3_FS.ini    log_need_to_check=i    save_log_directory=${save_log}
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
	Wait Throughput Timer    90
	Wait Until Keyword Succeeds    120s    10s    check counter    Step3_ue1_retx
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step3_ue1_retx' File
#
Step4:Send nack to UE2 to trigger retransmission
    Start Collect GNB and AP Syslog in 'Step4_ue2_retx' File
    #Start GNB BIP Log
    Trigger ul bler    2    0
    Wait Throughput Timer    3
    ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch
    ${ue2_ul_tput}=    Airphone Get Throughput On Specific Scell    2    0    pusch
    ${ue3_ul_tput}=    Airphone Get Throughput On Specific Scell    3    0    pusch
    ${ue4_ul_tput}=    Airphone Get Throughput On Specific Scell    4    0    pusch
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_ue2_retx
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    3
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
	run keyword and continue on failure
	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case140_tti_step4_FS.ini    log_need_to_check=i
   ...    save_log_directory=${save_log}
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
	Wait Throughput Timer    90
	Wait Until Keyword Succeeds    120s    10s    check counter    Step4_ue2_retx
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step4_ue2_retx' File
#
Step5:Send nack to UE3 to trigger retransmission
    Start Collect GNB and AP Syslog in 'Step5_ue3_retx' File
    #Start GNB BIP Log
    Trigger ul bler    3    0
    Wait Throughput Timer    3
    ${ue1_ul_tput}=    Airphone Get Throughput On Specific Scell    1    0    pusch
    ${ue2_ul_tput}=    Airphone Get Throughput On Specific Scell    2    0    pusch
    ${ue3_ul_tput}=    Airphone Get Throughput On Specific Scell    3    0    pusch
    ${ue4_ul_tput}=    Airphone Get Throughput On Specific Scell    4    0    pusch
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step5_ue3_retx
    Start GNB Ttitrace With Streaming Mode
    Wait Throughput Timer    3
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
	Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/tti
#	check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/case140_tti_step5_FS.ini    log_need_to_check=i    save_log_directory=${save_log}
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=1min
	Wait Throughput Timer    90
	Wait Until Keyword Succeeds    120s    10s    check counter    Step5_ue3_retx
#	should be true    int(${ELIG_UE_PUSCH}/${PAIR_UE_PUSCH})==1
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step5_ue3_retx' File
#
Step6:Detach all ues
    Airphone SA Stop Data Traffic     1    UL
    Airphone SA Stop Data Traffic     2    UL
    Airphone SA Stop Data Traffic     3    UL
    Airphone SA Stop Data Traffic     4    UL
    Detach '4'UE
#
#
check counter
    [Arguments]    ${log_dir}
    ${counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}${log_dir}/
	${UL_thp_counter}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55309C12002   cell_id=1
	${PAIR_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35010   cell_id=1
	${ELIG_UE_PUSCH}=    get_counter_value_from_counter_file    counter_file=${counter_file}   counter_id=M55308C35011   cell_id=1
	run keyword and continue on failure    should be true    ${UL_thp_counter} > 10000000
	run keyword and continue on failure    should be true    ${PAIR_UE_PUSCH} > 70000
	run keyword and continue on failure    should be true    ${ELIG_UE_PUSCH} > 85000
	run keyword and continue on failure    should be true    int(${ELIG_UE_PUSCH}/${PAIR_UE_PUSCH})==1
