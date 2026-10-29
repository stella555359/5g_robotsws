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
Library     taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}        SCFC_9363_ASOH_G_002_1CELL.xml
${AIRPHONE_NAME}    iphy_ASOH_1CELL.xml
${WTS_NAME}         wts_ASOH_1cell.cfg

@{LOG_NAME_LIST}        egatelog    gnb_snapshot

*** Test Cases ***
CB009363-G_002_aperiadic_CSI_handling_for_single_UE_with_bursty_UL_DL_data
    Step1:Commission the above configuration on WebUI
	Step2:Attach UE and Start burst DL+UL Traffic (High Traffic after long-period)

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Capture GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}
    modify_swconfig    ${CONFIG_DIR_PATH}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}
    Modify TL VM And AP SCTP Configuration
	Get and Update BSR File    par_of_bsr_name=BSR_AQQL_4_H3H1_ALN60_ARP60_P00_COVERAGE_00442_00002
	Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}    reset_after_commission=${False}
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step1_before_onair
    [Teardown]    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File


modify_swconfig
	[Arguments]    ${config_path}
    setup_txt    src_file=${config_path}/swconfig_gnb_ini.txt    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
	add_txt_node    0x9D0000:5         #as PM counter period update to 15/15=1min
	add_txt_node    0x580627:1
	add_txt_node    0x580117:3
	add_txt_node    0x600018:0        #RdUlUpFragmentationEnable,Flag for enabling UL UserPlane dynamic fragmentation (CB008941)
	add_txt_node    0x59017D:10       #rdSrsBwFraction
	add_txt_node    0x59012C:0       #rdLongPucchF3BeamformingEnable,1-PUCCH Format 3 is received over at least one SSB beam
    teardown_txt
	setup_txt    src_file=${config_path}/swconfig_ap_ini.txt    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    #add_txt_node    0x70690:1         #enable 1086 and 8247
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt


Step2:Attach UE and Start burst DL+UL Traffic (High Traffic after long-period)
    Start Collect GNB and AP Syslog in 'Step2_attach' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
	Start GNB BIP Log    bip_use_admin_api=true
	Attach SA ue with capability to 5g cell    1    SA_UE_NR_CAPA_FULL_7220_2200_9363
    Wait '5s' for stable running
    Airphone Execute Egate Command    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=ul trf_id\=1 protocol\=udp mbps\=100 burst\=5
    Airphone Execute Egate Command    trf_data_start ue\=1 pdu\=1 qfi\=1 dir\=dl trf_id\=1 protocol\=udp mbps\=100 burst\=5
    Wait Throughput Timer    15
    Capture ttitrace    10s    ${save_log}    step2
    Stop Gnb BIP Log    log_dir=${save_log}
    Merge pcaps    ${save_log}
	run keyword and continue on failure
	...    check_log_with_au2anlysis    ini_path=${CURDIR}/log_check/G_case02_tti.ini    log_need_to_check=i
    ...    save_log_directory=${save_log}
	[Teardown]    Stop Collect GNB and AP Syslog in 'Step2_attach' File

Capture ttitrace
    [Arguments]    ${time}    ${save_log}     ${file_tag}
    Start GNB Ttitrace With Streaming Mode
    sleep    ${time}
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/${file_tag}
Merge pcaps
    [Arguments]     ${log_path}
	TAF_SSH.Connect To    127.0.0.1    ute    ute    alias=bsh
	TAF_SSH.Execute    cd    connection=bsh
	TAF_SSH.Send Command    cd ${log_path};mergecap -w bip_merge.pcap *.pcap    connection=bsh
