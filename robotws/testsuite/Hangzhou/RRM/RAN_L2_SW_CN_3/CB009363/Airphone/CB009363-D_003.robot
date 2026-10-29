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
${SCFC_NAME}   SCF_D_1cell_MP_LO.xml
${AIRPHONE_NAME}    iphy_D_1cell_AEQE.xml
${WTS_NAME}    wts_D_1cell.cfg
@{LOG_NAME_LIST}        egatelog
#gnb_snapshot
${cellDepType}                             text|SA+NSA|//*[@name\="cellDepType"]
${chBw}                                    text|100MHz|//*[@name\="chBw"]
${dlMimoMode}                              text|4x4 or 4x2 Closed Loop Spatial Multiplexing|//*[@name\="dlMimoMode"]
${actDlSrsBm}                              text|false|//*[@name\="actDlSrsBm"]
${actUlSrsBm}                              text|false|//*[@name\="actUlSrsBm"]
${pucchModeSelect}                         text|longPucch|//*[@name\="pucchModeSelect"]
${numberOfRxBeamforming}                   text|8Rx|//*[@name\="numberOfRxBeamforming"]
${numberOfRxPucch}                         text|8Rx|//*[@name\="numberOfRxPucch"]
${actFdmScheduling}                        text|true|//*[@name\="actFdmScheduling"]
${actBeamforming}                          text|true|//*[@name\="actBeamforming"]
${nrBtsBeamRefinementP2}                   text|false|//*[@name\="nrBtsBeamRefinementP2"]
${actBbPoolTddFr1}                         text|true|//*[@name\="actBbPoolTddFr1"]
${actBbPoolTddFr1Enh}                      text|true|//*[@name\="actBbPoolTddFr1Enh"]
${basicBeamSet}                            text|beamSet_4|//*[@name\="basicBeamSet"]
${actUlDftSOfdm}                           text|false|//*[@name\="actUlDftSOfdm"]

${filter_1}    (uldata_puschreceiverespps)||(uldata_srsreceivereq)||(uldata_puschreceiverespps)
@{title_1}     3gpp.rnti    UlData_UePuschReceiveRespPs_t.ulRank    UlData_UePuschReceiveRespPs_t.dtx
...       UlData_UePuschReceiveRespPs_t.ulPmiRank1    UlData_UePuschReceiveRespPs_t.ulPmiRank1Sinr
...       UlData_UePuschReceiveRespPs_t.ulPmiRank2    UlData_UePuschReceiveRespPs_t.ulPmiRank2Sinr_item
...       UlData_srsReceiveReqUes_t.numCeAxCIndex    UlData_srsReceiveReqUes_t.patternId_item
...       UlData_srsReceiveRespPsUes_t.ulRank    UlData_srsReceiveRespPsUes_t.ulPmiRank1
...       UlData_srsReceiveRespPsUes_t.ulPmiRank1Sinr    UlData_srsReceiveRespPsUes_t.ulPmiRank2
...       UlData_srsReceiveRespPsUes_t.ulPmiRank2Sinr_item

*** Test Cases ***
CB009363-D_003_rank2_rank1_rank2_and_TPMI_measurement_on_8Rx_SRS_and_8Rx_PUSCH
    Step1:Commission the above configuration on WebUI
	Step2:Attach UE and start buffer
	Step3:Degrade radio condition to allow only rank1 transmission
	Step4:Upgrade radio conditions

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Capture GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig    ${CONFIG_DIR_PATH}${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    ${modify_list}    create list
	...      ${cellDepType}    ${chBw}    ${dlMimoMode}    ${actDlSrsBm}    ${actUlSrsBm}    ${pucchModeSelect}
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
	add_txt_node    0x580627:1
	add_txt_node    0x580117:3
	add_txt_node    0x600018:0        #RdUlUpFragmentationEnable,Flag for enabling UL UserPlane dynamic fragmentation (CB008941)
	add_txt_node    0x59017D:10       #rdSrsBwFraction
	add_txt_node    0x59012C:0       #rdLongPucchF3BeamformingEnable,1-PUCCH Format 3 is received over at least one SSB beam
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
	Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
    Wait '5s' for stable running
    SA send multiple trf data    1    DL    175M    2
    SA send multiple trf data    1    UL    175M    2
    Wait Throughput Timer    15
    Capture ttitrace    3s    ${save_log}    step2
    Stop Gnb BIP Log    log_dir=${save_log}
    run keyword and continue on failure   Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${save_log}/rank2_bip.csv    ${filter_1}    ${title_1}
#	Validation RANK2
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File

Step3:Degrade radio condition to allow only rank1 transmission
    Start Collect GNB and AP Syslog in 'Step3_rank1' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_rank1
	Start GNB BIP Log
    Airphone Execute Egate Command    ul_mimo_switch_nr profile_id\=1 pusch_tx_mix_ratio\=80 srs_tx_mix_ratio\=80
    Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_switch_nr action\=activate profile_id\=1
    Airphone Execute Egate Command    ul_cell_noise_testmode_nr profile_id\=2 noise_pusch\=-450 noise_srs\=-450
    Airphone Execute Egate Command    cell_testmode_set_nr cell_id\=1 gnb\=1 testmode\=ul_cell_noise profile_id\=2 action\=activate
    Wait Throughput Timer    15
    Capture ttitrace    3s    ${save_log}    step3
    Stop Gnb BIP Log    log_dir=${save_log}
    run keyword and continue on failure   Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${save_log}/rank1_bip.csv    ${filter_1}    ${title_1}
#	Validation RANK1
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step3_rank1' File

Step4:Upgrade radio conditions
    Start Collect GNB and AP Syslog in 'Step4_rank2' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_rank2
	Start GNB BIP Log
    Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_switch_nr action\=deactivate profile_id\=1
    Airphone Execute Egate Command    cell_testmode_set_nr cell_id\=1 gnb\=1 testmode\=ul_cell_noise profile_id\=2 action\=deactivate
    Wait Throughput Timer    15
    Capture ttitrace    3s    ${save_log}    step4
    Stop Gnb BIP Log    log_dir=${save_log}
    run keyword and continue on failure   Convert BIP To CSV    ${save_log}/tcpdump_L2L1_bip_filtering_off.pcap0
	...    ${save_log}/rank2_bip.csv    ${filter_1}    ${title_1}
#	Validation RANK2
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step4_rank2' File

Capture ttitrace
    [Arguments]    ${time}    ${save_log}     ${file_tag}
    Start GNB Ttitrace With Streaming Mode
    sleep    ${time}
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/${file_tag}

Validation RANK2
    run keyword and continue on failure
	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/D_case03_bip_rank2.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}

Validation RANK1
    run keyword and continue on failure
	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/D_case03_bip_rank1.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
