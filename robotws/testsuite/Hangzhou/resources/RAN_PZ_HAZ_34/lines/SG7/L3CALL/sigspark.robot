*** Settings ***
Documentation    spark Call Temp solution, han ruiyu added spark L3 CALL
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/at_ue_common_keyword.robot
Resource    testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/l3call.robot

*** Variables ***
#${ue_index}   0
${ue_required}   ${false}
${ue_0_required}   ${false}
${ue_1_required}   ${false}

*** Keywords ***
Start Spark L3CALL
    [Arguments]    ${ue_index}=${ue_index}    ${traffic_stop}=${true}    ${duration}=90    ${ue_reboot}=${False}
    ...    ${ue_type}=nokia_fastmile    ${Send_Tput}=200M     ${Expect_Tput}=50
    ...    ${peak_ul}=120   ${ul_expect}=${peak_ul}    ${method}=normal    ${Technology}=NR
    ...    ${direction}=DL    ${dl_deviation}=0.95    ${ul_deviation}=0.95   ${actCarrierAggregation}=${False}    ${process_num}=1
    ...    ${min_percent}=0.85     ${power_reset}=False
    ...    ${apn_address}=dxdata1
    LOG    ${direction}
    Set Suite Variable   ${ue_${ue_index}_type}   ${ue_type}
    wait until keyword succeeds    5x    10s    Spark Attach and Verify   ue_index=${ue_index}    ue_type=${ue_type}    method=${method}
    ...   ue_reboot=${ue_reboot}
    ...   power_reset=${power_reset}
    ${nr_cellid}   Get Attached Cell Indentity
    ${cell_id_list}    Create List    ${nr_cellid}
    ${cell_id_list}   set variable if  ${actCarrierAggregation}    ${nrcellid_list}    ${cell_id_list}
    _Start_Peak_Traffic_Testing_Spark
    ...   ue_type=${ue_${ue_index}_type}   dl_throughput=${Send_Tput}   ul_throughput=${peak_ul}   ue_index=${ue_index}
    ...   dl_expect=${Expect_Tput}   ul_expect=${ul_expect}   cell_list=${cell_id_list}    duration=${duration}
    ...    dl_deviation=${dl_deviation}    ul_deviation=${ul_deviation}    min_percent=${min_percent}
    ...    actCarrierAggregation=${actCarrierAggregation}    traffic_stop=${traffic_stop}    apn_address=${apn_address}
    ...   process_num=${process_num}    Technology==${Technology}
    [Return]   ${cell_id_list}
    [Teardown]  Run Keyword If   ${traffic_stop}   Spark L3CALL Teardown    ue_index=${ue_index}
    ...    power_reset=${power_reset}


Spark L3CALL Teardown
    [Arguments]   ${ue_index}    ${power_reset}=False
    run keyword and ignore error   power_ue.UE Detach    ue_type=${ue_${ue_index}_type}    power_reset=${power_reset}


Spark Attach and Verify
    [Arguments]    ${ue_index}=${ue_index}    ${ue_type}=spark    ${method}=normal    ${ue_reboot}=${False}
    ...  ${power_reset}=False    ${log_type}=aasyslog    ${gnb_index}=${0}    ${du_index}=0
    UE precondition Spark   ue_index=${ue_index}   ue_type=${ue_type}   method=${method}    ue_reboot=${ue_reboot}
    ...    power_reset=${power_reset}
    Log To Console    ....UE attach
    run keyword if    '${log_type.lower()}'=='aasyslog'    run keywords
    ...    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    AND
    ...    Aasyslog precondition    gnb_index=${gnb_index}    du_index=${du_index}    AND
    ...    Start the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}    filter=L2   log_name=5Grach.txt
    power_ue.UE Attach
    ...   ue_index=${ue_index}    ue_type=${ue_${ue_index}_type}    power_reset=${power_reset}
    run keyword if    '${log_type.lower()}'=='aasyslog'
    ...    Teardown the Aasyslog save progress    gnb_index=${gnb_index}    du_index=${du_index}
    [Teardown]     run keyword if  not ${KEYWORD STATUS.count('PASS')}>0
    ...    Spark L3CALL Teardown     ue_index=${ue_index}    power_reset=${power_reset}


UE precondition Spark
    [Documentation]   Require UE precondition, and avoid the duplicated require_ue actions same UE
    [Arguments]    ${ue_index}    ${ue_type}    ${method}=normal    ${ue_reboot}=${False}    ${power_reset}=False
    LOG    ${method}
#    ${reboot_flag}    set Variable    true
#    _Prepare Variables    ue_index=${ue_index}
#    Run Keyword If   '${method}'=='PEAK'    Reboot UE control PC ASEKY
#    wait until keyword succeeds    5 min    20 sec   csn.Connect to   hostname=${cpc_ip}  username=${cpc_username}
#    ...   password=${cpc_password}    alias=cpc_${ue_index}
    run keyword if  ${ue_type.count('mtk')}>0    run keyword if  not ${ue_${ue_index}_required}
    ...   run keyword and ignore error   Kill ELT process on ue control pc if exists
    Log To Console    ....UE precondition Spark
    run keyword if  not ${ue_${ue_index}_required}
    ...   Wait Until Keyword Succeeds   2 min   10 s     power_ue.Prepare UE   ue_type=${ue_type}   ue_index=${ue_index}
    ...   power_reset=${power_reset}
    sleep  20s
    Run keyword if   ${ue_reboot}     UTE Reboot UE    ue_index=${ue_index}
    log to console    ....UE detach
    ${status}   run keyword and return status    power_ue.UE Detach   ue_type=${ue_type}   ue_index=${ue_index}
    ...   power_reset=${power_reset}
    ${location_level}   Run Keyword and Return Status   Log   ${TEST_NAME}
    Run Keyword If   ${location_level}   Set Test Variable   ${ue_${ue_index}_required}   ${status}
    ...   ELSE   Set Suite Variable   ${ue_${ue_index}_required}   ${status}
    Run Keyword If   ${location_level}   Set Test Variable   ${ue_${ue_index}_nrCellId}   None
    ...   ELSE   Set Suite Variable   ${ue_${ue_index}_nrCellId}   None



_Start_Peak_Traffic_Testing_spark
    [Documentation]   Use this keyword if drx open
    [Arguments]   ${ue_type}   ${dl_throughput}   ${ul_throughput}   ${cell_list}   ${ue_index}=${0}
    ...   ${dl_expect}=${dl_throughput}   ${ul_expect}=${ul_throughput}    ${duration}=600   ${process_num}=1
    ...   ${dl_deviation}=0.95   ${ul_deviation}=0.95     ${actCarrierAggregation}=${False}    ${traffic_stop}=${True}
    ...    ${Technology}=NR   ${min_percent}=0.85    ${apn_address}=dxdata1
    LOG    ${ul_deviation}
    LOG    ${Technology}
    ${duration_output}    run keyword if  ${duration.count('s')}>0    Fetch From Left    ${duration}    s
    ...   ELSE    set variable   ${duration}
    ${duration_traffic}   evaluate   ${duration_output}+${300}
    ${duration_traffic}    set variable   ${duration_traffic}s
    ${dl_tput}   Evaluate   int(${dl_throughput}*1.1)
    ${ul_tput}   Evaluate   int(${ul_throughput}*1.5)
    Start traffic Spark    ue_index=${ue_index}    ue_type=${ue_${ue_index}_type}    Send_Tput=${dl_tput}M
    ...    duration=${duration_traffic}    direction=dl     apn_address=${apn_address}
    ...    iperf_port=${tl.ues[${ue_index}].iperf_details.ssh_connection_details.port}
    Run Keyword and Continue on Failure   Start traffic Spark   ue_index=${ue_index}    ue_type=${ue_${ue_index}_type}
    ...    Send_Tput=${ul_tput}M  duration=${duration_traffic}   direction=ul    process_num=${process_num}
    ...    iperf_port=${tl.ues[${ue_index}].iperf_details.port}     apn_address=${apn_address}
    ${duration}    set variable if  ${traffic_stop}   ${duration}    30s
    ${tput_log}   power_ue.Collect Tput   ue_index=${ue_index}   ue_type=${ue_type}    duration=${duration}
    ...   check_source=aasyslog     ignore_time=30s
    power_ue.Check Bi Tput   ue_index=${ue_index}   ue_type=${ue_type}   log=${tput_log}   cells=${cell_list}
    ...   dltarget_throughput=${dl_expect}   ultarget_throughput=${ul_expect}
    ...   target_avg_percent=${dl_deviation}     actCarrierAggregation=${actCarrierAggregation}
    ...   min_percent=${min_percent}    check_source=aasyslog
    [Teardown]   run keyword if  ${traffic_stop}    Run Keywords   Run Keyword and Ignore Error
    ...   Stop DL traffic Spark    ue_index=${ue_index}    ue_type=${ue_${ue_index}_type}    apn_address=${apn_address}
    ...   AND   Run Keyword and Ignore Error    Stop UL traffic Spark    ue_index=${ue_index}    ue_type=${ue_${ue_index}_type}
    ...   apn_address=${apn_address}

Start traffic Spark
    [Arguments]    ${ue_index}=${0}    ${ue_type}=huawei_sigspark    ${Send_Tput}=200M    ${duration}=90
    ...   ${direction}=dl    ${ul_length}=1400    ${process_num}=1     ${apn_address}=dxdata1
    ...   ${iperf_port}=${tl.ues[${ue_index}].iperf_details.port}
    LOG    ${ul_length}
    LOG TO CONSOLE    ....START TRAFFIC Start!
    ${duration_output}    run keyword if  ${duration.count('s')}>0    Fetch From Left    ${duration}    s
    ...   ELSE    set variable   ${duration}
    ${Send_Tput}   Fetch from left    ${Send_Tput}   M
    ${throughput}    evaluate    int(float(${Send_Tput})/float(${process_num}))
     power_ue.Start traffic   ue_index=${ue_index}    ue_type=${ue_type}    direction=${direction}
    ...    throughput=${throughput}MKbits/sec  duration=${duration_output}    process_num=${process_num}
    ...    dt_name=${direction}_${ue_index}    apn_address=${apn_address}
    ...    iperf_port=${iperf_port}
#    LOG TO CONSOLE    ....START TRAFFIC FINISHED!


Stop DL traffic Spark
    [Arguments]  ${ue_index}=${0}   ${ue_type}=huawei_sigspark    ${apn_address}=dxdata1
    power_ue.Stop traffic    ue_index=${ue_index}        ue_type=${ue_type}    direction=dl   dt_name=dl_${ue_index}
    ...    apn_address=${apn_address}

Stop UL traffic Spark
    [Arguments]  ${ue_index}=${0}   ${ue_type}=huawei_sigspark    ${apn_address}=dxdata1
    power_ue.Stop traffic    ue_index=${ue_index}    ue_type=${ue_type}    direction=ul   dt_name=ul_${ue_index}
    ...    apn_address=${apn_address}
