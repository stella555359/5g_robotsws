*** Settings ***
Documentation
...    *comments*
...    run keyword and ignore error： logs for debug
...    run keyword and continue on failure: want to see the next time run result, this keyword will not affect test result;
...    Comment/#： logs for debug
...    *comments*
Suite Setup       Common Suite Setup
Suite Teardown    Common Suite Teardown
Test Setup        Common Test Setup
Test Teardown     Common Test Teardown
Force Tags        CRT    CLOUD_R4BANO_CUS     CLOUD_R4BANO_CUS_PET    SBTS00     RAN_4G    RAN_4G_TDD         
Resource          ../../resources/KISS/robot/4g_common_resource.robot
*** Variables ***
${scfc_path}    ${CURDIR}${/}cus_scfc_peak.xml
${yaml_config}    ${CURDIR}${/}CUS_LTE2500_iphy.yaml
${UE_ID_LIST}     1
${CUS_IP}         192.168.200.1
${FCT_IP}         192.168.255.1
${FTM_IP}         192.168.255.129
${UE_INDEX_1}     1
${UE_NUMBER}      1
${btslog_port}    51000
${UL_THROUGHPUT_LOWER_THRESHOLD}    3000
${DL_THROUGHPUT_LOWER_THRESHOLD}    200000
${CAPTURE_UE_LOG_TIME}    15s
${CHECK_ON_AIR_TIMEOUT}    900s
${ue_id}          1
${BTS_IP}         192.168.255.1
${WTS_IP}         192.168.200.1
${cell1_onair}    ${EMPTY}
${cell2_onair}    ${EMPTY}
${cell3_onair}    ${EMPTY}
${cell4_onair}    ${EMPTY}
${cell5_onair}    ${EMPTY}
${UE_INDEX_1}     1
${UE_INDEX_2}     2
*** Test Cases ***
LTE2500-A-c_5cc_peak_with_MIMO_20_layers
    Prepare Enb Onair   ${scfc_path}    ${yaml_config}
    Cus_Attach UE1 
    Cus Start data traffic
    Wait until keyword succeeds    60s    5s    Cus Verify throughput
    run keyword and continue on failure    Collect and decode ttitrace log
    run keyword and continue on failure	   Check ttitrace
    Cus Stop data traffic
    Cus Detach UE

*** Keywords ***      Action                Action          Action       Action
testTeardown          Iphy Get Egate Console Log      log_save_path=${TEST LOG DIRECTORY()}
                      run keyword and ignore error      Stop And Collect Aatrace File      alias=enb1_aatrace
                      run keyword and ignore error      collect_syslog_results      alias=iphy_syslog
                      run keyword and ignore error      collect_syslog_results      alias=btslog
                      Check err log
Cus_Attach UE1   
                      cus_execute_uex_command     turbo_mode_l2 cell\=11 mode\=enable   
                      CUS Attach    ${UE_INDEX_1}    11
Collect and decode ttitrace log
                      setup_enb_ttitrace     log_path=${TEST LOG DIRECTORY()}      alias=enb_ttitrace
                      start_enb_ttitrace     node_type=DL     cell_id=ALL      alias=enb_ttitrace
                      sleep      2
                      stop_and_decode_enb_ttitrace      alias=enb_ttitrace
                      teardown_all_alias_for_enb_ttitrace

Cus Start data traffic
                      CUS Start DL Udp Data Traffic     ${UE_ID_LIST}    175M    trf_id=1
                      CUS Start DL Udp Data Traffic     ${UE_ID_LIST}    175M    trf_id=2
                      CUS Start DL Udp Data Traffic     ${UE_ID_LIST}    175M    trf_id=3
                      CUS Start DL Udp Data Traffic     ${UE_ID_LIST}    175M    trf_id=4
                      CUS Start DL Udp Data Traffic     ${UE_ID_LIST}    175M    trf_id=5
                      CUS Start DL Udp Data Traffic     ${UE_ID_LIST}    175M    trf_id=6
                      #CUS Start UL Udp Data Traffic    ${UE_ID_LIST}    10M    bearer=5					  
                      Sleep    10
                                                                       
Cus Verify throughput
                      ${dl_tput_pcell}=    cus_get_throughput_on_specific_scell    1    dl_mac    scell_id=0    tput_type=cur
					  ${dl_tput_scell1}=    cus_get_throughput_on_specific_scell    1    dl_mac    scell_id=1    tput_type=cur
					  ${dl_tput_scell2}=    cus_get_throughput_on_specific_scell    1    dl_mac    scell_id=2    tput_type=cur
					  ${dl_tput_scell3}=    cus_get_throughput_on_specific_scell    1    dl_mac    scell_id=3    tput_type=cur
					  ${dl_tput_scell4}=    cus_get_throughput_on_specific_scell    1    dl_mac    scell_id=4    tput_type=cur
                      ${dl_tput_ave1}=    CUS Get DL Throughput Ave    1    dl_mac
                      should_be_true    ${dl_tput_pcell}>70000#70000
					  should_be_true    ${dl_tput_scell1}>148000#150000
                      should_be_true    ${dl_tput_scell2}>148000#150000
					  should_be_true    ${dl_tput_scell3}>148000#150000	
                      should_be_true    ${dl_tput_scell4}>148000#150000						  
Cus Stop data traffic
                      CUS Stop UL Udp Data Traffic    1    
                      CUS Stop DL Udp Data Traffic    1   
Cus Detach UE
                      CUS All Detach					  
Check err log         check_log_with_au2anlysis     ini_path=${CURDIR}/ini/err_log.ini      log_need_to_check=u      
                      ...   save_log_directory=${TEST LOG DIRECTORY()}


Check ttitrace        check_log_with_au2anlysis     ini_path=${CURDIR}/ini/TTitrace_cell1.ini      log_need_to_check=i
                      ...   save_log_directory=${TEST LOG DIRECTORY()}
                      check_log_with_au2anlysis     ini_path=${CURDIR}/ini/TTitrace_cell2.ini      log_need_to_check=i
					  ...   save_log_directory=${TEST LOG DIRECTORY()}
                      check_log_with_au2anlysis     ini_path=${CURDIR}/ini/TTitrace_cell3.ini      log_need_to_check=i
					  ...   save_log_directory=${TEST LOG DIRECTORY()}
                      check_log_with_au2anlysis     ini_path=${CURDIR}/ini/TTitrace_cell4.ini      log_need_to_check=i 
					  ...   save_log_directory=${TEST LOG DIRECTORY()}
                      check_log_with_au2anlysis     ini_path=${CURDIR}/ini/TTitrace_cell5.ini      log_need_to_check=i
					  ...   save_log_directory=${TEST LOG DIRECTORY()}

                      setup_enb_ttitrace      log_path=${TEST LOG DIRECTORY()}      alias=BTS_ttitrace
                      start_enb_ttitrace      node_type=ALL     cell_id=ALL      alias=BTS_ttitrace

Override RI to 4 layer
                      cus_execute_uex_command                              ue_cqi_param id=1 scell=0-4 rank=4
