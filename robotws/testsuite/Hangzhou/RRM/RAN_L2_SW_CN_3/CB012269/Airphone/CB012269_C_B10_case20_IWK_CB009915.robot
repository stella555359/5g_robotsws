*** Settings ***
Documentation

Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CLOUD_5G_I_MP_AP_LOOO    AP    CRT    SBTS00    RAN_5G_TDD    RAN_5G    owner_wpf
Test Timeout      90 minutes
Resource          ../../resources/sg11/internal_resource/robot/modify_configuration.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_ap_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_gnb_operate.robot
Resource          ../../resources/sg11/internal_resource/robot/internal_capture_log.robot
Library     taf.transport.ssh    WITH NAME    TAF_SSH
Library           ta_a2a

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${SCFC_NAME}   SCF_case20.xml
${AIRPHONE_NAME}    iphy_case20.xml
${WTS_NAME}    wts_CB008360_UL_MU_100UE_3cell_CB012269.lua
@{LOG_NAME_LIST}        gnb_snapshot    egatelog

${actPdcchSharingWithPdsch}                    text|false|//*[@name\="actPdcchSharingWithPdsch"]
${actTddCsiRsOpt}                              text|true|//*[@name\="actTddCsiRsOpt"]
${pattern}    CA_P2_8x4_t2r4_n2

*** Test Cases ***
CB012269_C_B10_case20_IWK_CB009915_blanking
    Step1:Commission the above configuration on WebUI
	Step2:Attach 2UE in blanking enable cell1 and start buffer
	Step3:Attach 1UE in cell2 and 1UE in cell3,then start buffer
	Step4:Detach UE

*** Keywords ***
Step1:Commission the above configuration on WebUI
    Start Capture GNB and AP Syslog in 'Step1_before_onair' File
    ${CONFIG_DIR_PATH}    Set Variable    ${CONFIG_DIR_PATH}/${SW_BRANCH}
    change_iphy_rru_version    ${CONFIG_DIR_PATH}${/}WTS${/}${AIRPHONE_NAME}
    modify_swconfig    ${CONFIG_DIR_PATH}${/}SCF${/}${SCFC_NAME}
    ${scfc_path}    Set Variable    ${TEST_LOG_DIRECTORY()}${/}SCF${/}scfc.xml
    copy_file    ${CONFIG_DIR_PATH}${/}SCF${/}${SCFC_NAME}    ${scfc_path}
    ${modify_list}    create list
	...      ${actTddCsiRsOpt}    ${actPdcchSharingWithPdsch}
    modify_xml    ${scfc_path}    ${scfc_path}    ${modify_list}
    Modify TL VM And AP SCTP Configuration
	Get and Update BSR File    par_of_bsr_name=BSR_AQQL_6_H6_ALN60_ARP60_P00_COVERAGE_00424_00001
	Perform Full Commission And Reach Onair With Log    ${scfc_path}    ${CONFIG_DIR_PATH}${/}WTS${/}${WTS_NAME}    reset_after_commission=${False}
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
    teardown_txt
	setup_txt    src_file=${path_ap}    save_path=${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt
    teardown_txt
    GNB Upload Swconfig           ${TEST_LOG_DIRECTORY()}${/}swconfig_gnb_ini.txt
    airphone_upload_swconfig      ${TEST_LOG_DIRECTORY()}${/}swconfig_ap_ini.txt

Step2:Attach 2UE in blanking enable cell1 and start buffer
    Start Capture GNB and AP Syslog in 'Step2_attach_cell1' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step2_attach_cell1
	Start GNB BIP Log
	Attach SA ue with capability to 5g cell    2    CA_P2_8x4_t2r4_n2
    Wait '5s' for stable running
    FOR    ${u_id}    IN RANGE    1    3
        Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=1    duration=7200
        Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=2    duration=7200
	    Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=3    duration=7200
	    Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=4    duration=7200
	    Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=5    duration=7200
        Airphone Sa Start Data Traffic    ue_id=${u_id}    direction=ul    throughput=175M    trf_id=1    duration=7200
	    Wait Throughput Timer    10
	    ${Dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${u_id}    scell_id=0    type=pdsch    tput_type=ave
        ${Ul_throughput} =    Airphone Sa Get Throughput    ue_id=${u_id}    direction=ul
    END
    
    Capture ttitrace    3s    ${save_log}    tti
    Stop Gnb BIP Log    log_dir=${save_log}

	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/tti_dl_no_bler.ini    log_need_to_check=i    save_log_directory=${save_log}
	[Teardown]    Stop Capture GNB and AP Syslog in 'Step2_attach_cell1' File

Step3:Attach 1UE in cell2 and 1UE in cell3,then start buffer
    Start Capture GNB and AP Syslog in 'Step3_attach_cell23' File
	${save_log}=    Set Variable    ${TEST_LOG_DIRECTORY()}Step3_attach_cell23
	Start GNB BIP Log
	
    Airphone Execute Egate Command    ue_change_location id\=3 enb\=2 cell\=2
	${ue_cap}    Obtain Ue Capability    ${pattern}
    airphone_sa_attach    ue_id=3    ue_capability=${ue_cap}
    airphone_set_traffic_type    ue_id=3    pdu_id=1
    airphone_pdu_session_setup    ue_id=3    pdu_id=1    gw_id=3
	Wait '3s' for stable running

	Airphone Execute Egate Command    ue_change_location id\=4 enb\=2 cell\=3
	${ue_cap}    Obtain Ue Capability    ${pattern}
    airphone_sa_attach    ue_id=4    ue_capability=${ue_cap}
    airphone_set_traffic_type    ue_id=4    pdu_id=1
    airphone_pdu_session_setup    ue_id=4    pdu_id=1    gw_id=4
	Wait '3s' for stable running
	
	FOR    ${u_id}    IN RANGE    3    5
        Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=1    duration=7200
        Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=2    duration=7200
	    Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=3    duration=7200
	    Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=4    duration=7200
	    Airphone SA Start Data Traffic    ue_id=${u_id}    direction=dl    throughput=175M    trf_id=5    duration=7200
        Airphone Sa Start Data Traffic    ue_id=${u_id}    direction=ul    throughput=175M    trf_id=1    duration=7200
	    Wait Throughput Timer    10
	    ${Dl_throughput} =    Airphone Get Throughput On Specific Scell    ue_id=${u_id}    scell_id=0    type=pdsch    tput_type=ave
        ${Ul_throughput} =    Airphone Sa Get Throughput    ue_id=${u_id}    direction=ul
    END

    Capture ttitrace    3s    ${save_log}    tti
	Stop Gnb BIP Log    log_dir=${save_log}
	run keyword and continue on failure    check_log_with_au2anlysis
    ...    ini_path=${CURDIR}/ini/tti_dl_no_bler.ini    log_need_to_check=i    save_log_directory=${save_log}
	
	#get tput from PM counter
    ${remaining_time}=    get_counter_file_remaining_time    counter_refresh_period=5min
    Wait Throughput Timer    ${remaining_time}
    ${PM_counter_file}=    download_latest_pmcounter    local_path=${TEST_LOG_DIRECTORY()}Step3_attach_cell23${/}
    ${PM_counter_DL_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=1
    ${DL_throughput}    evaluate    ${PM_counter_DL_value}*8/1024/1024
	${PM_counter_UL_value}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12002     cell_id=1
    ${UL_throughput}    evaluate    ${PM_counter_UL_value}*8/1024/1024

    ${PM_counter_DL_value_2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=2
    ${DL_throughput_2}    evaluate    ${PM_counter_DL_value_2}*8/1024/1024
	${PM_counter_UL_value_2}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12002     cell_id=2
    ${UL_throughput_2}    evaluate    ${PM_counter_UL_value_2}*8/1024/1024
	
    ${PM_counter_DL_value_3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12001    cell_id=3
    ${DL_throughput_3}    evaluate    ${PM_counter_DL_value_3}*8/1024/1024
	${PM_counter_UL_value_3}=    get_counter_value_from_counter_file    counter_file=${PM_counter_file}    counter_id=M55309C12002     cell_id=3
    ${UL_throughput_3}    evaluate    ${PM_counter_UL_value_3}*8/1024/1024
	
	should be true    ${DL_throughput} > 600
	should be true    ${DL_throughput_2} > 500
	#should be true    ${DL_throughput_3} > 690
	[Teardown]    Stop Capture GNB and AP Syslog in 'Step3_attach_cell23' File

Step4:Detach UE	
    Start Capture GNB and AP Syslog in 'Step4_detach' File
    FOR    ${num}    IN RANGE    1    5
       airphone_sa_detach    ue_id=${num}    timeout=5
       Wait '3s' for stable running
    END
	[Teardown]    Stop Capture GNB and AP Syslog in 'Step4_detach' File

Capture ttitrace
    [Arguments]    ${time}    ${save_log}     ${file_tag}
    Start GNB Ttitrace With Streaming Mode
    sleep    ${time}
    ${pacp}=    Stop GNB Ttitrace With Streaming Mode    save_path=${save_log}
    Decoder Tttirace From Pcap To Csv    ${pacp}    ${save_log}/${file_tag}
