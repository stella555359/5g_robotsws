*** Settings ***
Documentation     5192 features.
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CRT    SBTS00    RAN_4G    RAN_4G_TDD    CLOUD_R4BANO_CUS
Resource          ../../resources/KISS/robot/4g_common_resource.robot

*** Variables ***
${scfc_path}    ${CURDIR}${/}CUS_SCFC_3F1T.xml
${yaml_config}    ${CURDIR}${/}CUS_LTE5192_3F1T.yaml
${CUS_IP}         192.168.200.1
${FCT_IP}         192.168.255.1
${FTM_IP}         192.168.255.129
${cell_onair}     ${EMPTY}
${DL_THROUGHPUT_LOWER_THRESHOLD2cc}    100000
${DL_THROUGHPUT_LOWER_THRESHOLD3cc}    200000
${UE_INDEX_1}     1
${UE_INDEX_2}     2


*** Test Cases ***
LTE5192_A_1T3F_oneshot_add_stepwise_active_config_25_64QAM
    Prepare Enb Onair   ${scfc_path}    ${yaml_config}
    Run UEx command  turbo_mode_l2 cell=4 mode=enable
    Attach UE
    Start data traffic
    run keyword and continue on failure    Verify throughput
    Stop data traffic
    Start data traffic
    run keyword and continue on failure    Verify throughput	
    #Collect ttitrace
    #Check ttitrace
    Stop data traffic
    Detach UE

*** Keywords ***

Attach UE
    Comment    CUS Attach    1,3...7,9    1
    sleep    20
    Comment    CUS Attach    1    1
    CUS Attach    ${UE_INDEX_1}    4

Start data traffic
    Comment    CUS Start UL Udp Data Traffic    4...6    30    bearer=5
    Comment    CUS Start DL Udp Data Traffic    7,9    5M
    CUS Start UL Udp Data Traffic    1    20M
    CUS Start DL Udp Data Traffic    1    300M    trf_id=1
    CUS Start DL Udp Data Traffic    1    300M    trf_id=2
    Sleep    10
	
Override PHR
    Run UEx command  ue_ul_power_control id=1 phr_operation=permanent phr_value_override=1 pathloss=115

Collect ttitrace      
	setup_enb_ttitrace  log_path=${TEST LOG DIRECTORY()}    alias=enb_ttitrace
	start_enb_ttitrace  node_type=ALL   cell_id=ALL    alias=enb_ttitrace
	sleep   5
	stop_and_decode_enb_ttitrace    alias=enb_ttitrace
	teardown_all_alias_for_enb_ttitrace

Check ttitrace        
	runkeyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_FDD_DL_cell_1.ini    log_need_to_check=i
    ...    save_log_directory=${TEST LOG DIRECTORY()}
	runkeyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_FDD_DL_cell_2.ini    log_need_to_check=i
    ...    save_log_directory=${TEST LOG DIRECTORY()}
	runkeyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_FDD_DL_cell_3.ini    log_need_to_check=i
    ...    save_log_directory=${TEST LOG DIRECTORY()}
	runkeyword and continue on failure    check_log_with_au2anlysis    ini_path=${CURDIR}/ini/tti_TDD_DL_cell_4.ini    log_need_to_check=i
    ...    save_log_directory=${TEST LOG DIRECTORY()}

Verify throughput
    ${dl_throughput_pcell}     CUS Get Throughput On Specific Scell    1    dl_mac    scell_id=0    tput_type=cur
    ${dl_throughput_scell1}    CUS Get Throughput On Specific Scell    1    dl_mac    scell_id=1    tput_type=cur
    ${dl_throughput_scell2}    CUS Get Throughput On Specific Scell    1    dl_mac    scell_id=2    tput_type=cur
    ${dl_throughput_scell3}    CUS Get Throughput On Specific Scell    1    dl_mac    scell_id=3    tput_type=cur
    should_be_true    ${dl_throughput_pcell}>80000
    should_be_true    ${dl_throughput_scell1}>140000
    should_be_true    ${dl_throughput_scell2}>140000
    should_be_true    ${dl_throughput_scell3}>140000
	
Stop data traffic
    CUS Stop UL Udp Data Traffic    1
    CUS Stop DL Udp Data Traffic    1    trf_id=1
    CUS Stop DL Udp Data Traffic    1    trf_id=2

Detach UE
    Comment    CUS Detach    1
    Comment    Sleep    1
    CUS All Detach

Set R&D parameter
    runkeyword and continue on failure    Set Rad Parameter    setlog    ALL    ALL    FID_DL_CA    DEBUG
    ...    hw_ver=fsmr4
    runkeyword and continue on failure    Set Rad Parameter    setlog    ALL    ALL    FID_UL_CA    DEBUG
    ...    hw_ver=fsmr4
    runkeyword and continue on failure    Set Rad Parameter    setlog    ALL    ALL    FID_DL_BSR    DEBUG
    ...    hw_ver=fsmr4
