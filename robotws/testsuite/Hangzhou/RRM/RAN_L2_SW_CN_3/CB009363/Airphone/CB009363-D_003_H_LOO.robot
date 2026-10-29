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
${SCFC_NAME}        SCFC_9363_ASOH_D_003_1CELL.xml
${AIRPHONE_NAME}    iphy_ASOH_1CELL.xml
${WTS_NAME}         wts_ASOH_1cell.cfg

@{LOG_NAME_LIST}        egatelog    gnb_snapshot


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
    modify_swconfig    ${CONFIG_DIR_PATH}
#    Add RD
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    Modify TL VM And AP SCTP Configuration
	Get and Update BSR File    par_of_bsr_name=BSR_AQQL_4_H4_ALN60_ARP60_P00_COVERAGE_00422_00002
	Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step1_before_onair
    [Teardown]    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File

modify_swconfig
    [Arguments]    ${config_path}
    setup_txt    src_file=${config_path}/swconfig_gnb_ini.txt    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
	add_txt_node    0x9D0000:5         #as PM counter period update to 15/15=1min
	add_txt_node    0x580627:1          #rdSherpaAllEventActivation, This R&D parameter is used to control transition for Sherpa all event
	add_txt_node    0x580117:3         #rdSherpaBitMapvector, Bit map vector for events traces DL Extended Sherpa streaming
	add_txt_node    0x600018:0        #RdUlUpFragmentationEnable,Flag for enabling UL UserPlane dynamic fragmentation (CB008941)
	add_txt_node    0x59017D:10       #rdSrsBwFraction
	add_txt_node    0x59012C:0       #rdLongPucchF3BeamformingEnable,1-PUCCH Format 3 is received over at least one SSB beam
    teardown_txt
	setup_txt    src_file=${config_path}/swconfig_ap_ini.txt    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    #add_txt_node    0x70690:1         #enable 1086 and 8247
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt

Add RD
    Add GNB swconfig    0x9D0000:5         #as PM counter period update to 15/15=1min
	Add GNB swconfig    0x580627:1       #rdSherpaAllEventActivation, This R&D parameter is used to control transition for Sherpa all event
	Add GNB swconfig    0x580117:3      #rdSherpaBitMapvector, Bit map vector for events traces DL Extended Sherpa streaming
	Add GNB swconfig    0x600018:0        #RdUlUpFragmentationEnable,Flag for enabling UL UserPlane dynamic fragmentation (CB008941)
	Add GNB swconfig    0x59017D:10       #rdSrsBwFraction
	Add GNB swconfig    0x59012C:0       #rdLongPucchF3BeamformingEnable,1-PUCCH Format 3 is received over at least one SSB beam

Step2:Attach UE and start buffer
    Start Collect GNB and AP Syslog in 'Step2_attach' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
	Start GNB BIP Log    bip_use_admin_api=true
	Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
    Wait '5s' for stable running
    SA send multiple trf data    1    DL    175M    2
    SA send multiple trf data    1    UL    175M    2
    Wait Throughput Timer    15
    Capture ttitrace    3s    ${save_log}    step2
    Stop Gnb BIP Log    log_dir=${save_log}
    Merge pcaps    ${save_log}
    run keyword and continue on failure   Convert BIP To CSV    ${save_log}/bip_merge.pcap
	...    ${save_log}/rank2_bip.csv    ${filter_1}    ${title_1}
#	Validation RANK2
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File

Step3:Degrade radio condition to allow only rank1 transmission
    Start Collect GNB and AP Syslog in 'Step3_rank1' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_rank1
	Start GNB BIP Log    bip_use_admin_api=true
    Airphone Execute Egate Command    ul_mimo_switch_nr profile_id\=1 pusch_tx_mix_ratio\=80 srs_tx_mix_ratio\=80
    Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_switch_nr action\=activate profile_id\=1
    Airphone Execute Egate Command    ul_cell_noise_testmode_nr profile_id\=2 noise_pusch\=-450 noise_srs\=-450
    Airphone Execute Egate Command    cell_testmode_set_nr cell_id\=1 gnb\=1 testmode\=ul_cell_noise profile_id\=2 action\=activate
    Wait Throughput Timer    15
    Capture ttitrace    3s    ${save_log}    step3
    Stop Gnb BIP Log    log_dir=${save_log}
    Merge_pcaps    ${save_log}
    run keyword and continue on failure   Convert BIP To CSV    ${save_log}/bip_merge.pcap
	...    ${save_log}/rank1_bip.csv    ${filter_1}    ${title_1}
#	Validation RANK1
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step3_rank1' File

Step4:Upgrade radio conditions
    Start Collect GNB and AP Syslog in 'Step4_rank2' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step4_rank2
	Start GNB BIP Log    bip_use_admin_api=true
    Airphone Execute Egate Command    ue_testmode_set_nr id\=1 testmode\=ul_mimo_switch_nr action\=deactivate profile_id\=1
    Airphone Execute Egate Command    cell_testmode_set_nr cell_id\=1 gnb\=1 testmode\=ul_cell_noise profile_id\=2 action\=deactivate
    Wait Throughput Timer    15
    Capture ttitrace    3s    ${save_log}    step4
    Stop Gnb BIP Log    log_dir=${save_log}
    Merge_pcaps    ${save_log}
    run keyword and continue on failure   Convert BIP To CSV    ${save_log}/bip_merge.pcap
	...    ${save_log}/rank2_bip.csv    ${filter_1}    ${title_1}
#	Validation RANK2
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step4_rank2' File

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

Validation RANK2
    run keyword and continue on failure
	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/D_case03_bip_rank2.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}

Validation RANK1
    run keyword and continue on failure
	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/D_case03_bip_rank1.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
