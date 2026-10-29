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
${SCFC_NAME}   SCFC_9363_ASOH_G_005_1CELL.xml
${AIRPHONE_NAME}    iphy_ASOH_1CELL.xml
${WTS_NAME}    wts_ASOH_1cell.cfg

@{LOG_NAME_LIST}        egatelog    gnb_snapshot

${ul_bler}          bler_testmode_nr profile_id=1 ul_bler=100,100,100,50
${Act_ul_bler}      ue_testmode_set_nr id=1 testmode=bler profile_id=1 action=activate
${Deact_ul_bler}    ue_testmode_set_nr id=1 testmode=bler profile_id=1 action=deactivate

${ul_sinr}          ul_cell_noise_testmode_nr profile_id=2 noise_pusch=-900
${Act_ul_sinr}      cell_testmode_set_nr cell_id=1 gnb=1 testmode=ul_cell_noise profile_id=2 action=activate
${Deact_ul_sinr}    cell_testmode_set_nr cell_id=1 gnb=1 testmode=ul_cell_noise profile_id=2 action=deactivate


${PROFILE4}    ul_mimo_srs_beam_pos_nr profile_id\=4 mode\=fixed init_quad_pos\=3 init_sub_quad_pos\=3 test_type\=SRS
...    multi_path_config\=true num_of_nlos_paths\=1 azimuth\=18 zenith\=-2 srs_transmit_power_per_port=-200,-200,-200,-200

${SET_PROFILE4}    ue_testmode_set_nr id\=4 testmode\=ul_mimo_srs_beam_pos action\=activate profile_id\=4

*** Test Cases ***
CB009363-G_005_adaptive_retransmission_scheme_basic_alhorithm_without_change_of_modulation_in_UL
    Step1:Commission the above configuration on WebUI
	Step2:Attach UE
	Step3:Start traffic and activate UL SINR and UL BLER

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Capture GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}${AIRPHONE_NAME}

    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${scfc_path}

    modify_swconfig    ${CONFIG_DIR_PATH}
    Modify TL VM And AP SCTP Configuration
	Get and Update BSR File    par_of_bsr_name=BSR_AQQL_4_H3H1_ALN60_ARP60_P00_COVERAGE_00442_00002
	Perform Full Commission And Reach Onair With Log    ${CONFIG_DIR_PATH}/${SCFC_NAME}    ${CONFIG_DIR_PATH}${/}${WTS_NAME}
	...    reset_after_commission=${False}
    ${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step1_before_onair
    [Teardown]    Stop Capture GNB and AP Syslog in 'Step1_before_onair' File

modify_swconfig
	[Arguments]    ${config_path}
    setup_txt    src_file=${config_path}/swconfig_gnb_ini.txt    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
	add_txt_node    0x9D0000:5          #as PM counter period update to 15/15=1min
	add_txt_node    0x420068:7    #rdTddPoolingFeaturesEnable
    add_txt_node    0x580180:0    #rdHARQDisableIncrRedundancyUl 0x580180=0 (default)
    add_txt_node    0x580678:6    # Defines the maximum number of NACKs received at gNB for a HARQ process
    teardown_txt
	setup_txt    src_file=${config_path}/swconfig_ap_ini.txt    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    #add_txt_node    0x70690:1         #enable 1086 and 8247
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt




Step2:Attach UE
    Start capture GNB and AP Syslog in 'Step2_attach' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach
	Start GNB BIP Log
	Attach SA ue with capability to 5g cell    1    CA_P2_8x4_t2r4_n2
	airphone_execute_egate_command    ${PROFILE4}
    airphone_execute_egate_command    ${SET_PROFILE4}
    Wait '5s' for stable running
    Stop Gnb BIP Log    log_dir=${save_log}
	[Teardown]    Stop capture GNB and AP Syslog in 'Step2_attach' File

Step3:Start traffic and activate UL SINR and UL BLER
    Start capture GNB and AP Syslog in 'Step3' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3
	Start GNB BIP Log    bip_use_admin_api=true
	Airphone Sa Start Data Traffic    ue_id=1    direction=ul    throughput=175M    trf_id=1    duration=7200
	Airphone Sa Start Data Traffic    ue_id=1    direction=dl    throughput=175M    trf_id=1    duration=7200
	Wait Throughput Timer    15
    Airphone Execute Egate Command    ${ul_bler}       
	Airphone Execute Egate Command    ${Act_ul_bler}   	
	Airphone Execute Egate Command    ${ul_sinr}       
	Airphone Execute Egate Command    ${Act_ul_sinr}  
    Wait '5s' for stable running	
    Capture ttitrace    3s    ${save_log}    step3
    Stop Gnb BIP Log    log_dir=${save_log}
    Merge pcaps    ${save_log}

	${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3${/}
	${UNSUCC_256TBL_MCS_31}     get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55302C12031    cell_id=1
	${Rank1_256TBL_MCS_31}      get_counter_value_from_counter_file    counter_file=${PM_counter_file}     counter_id=M55303C22031    cell_id=1
	should be true    ${UNSUCC_256TBL_MCS_31} > 0
	should be true    ${Rank1_256TBL_MCS_31} > 0
    run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/log_check/G_case05_tti.ini    log_need_to_check=i    save_log_directory=${save_log}
	[Teardown]    Stop capture GNB and AP Syslog in 'Step3' File

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