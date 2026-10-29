*** Settings ***
Variables    ../../../CB008247/Spark/var.py

*** Variables ***
${LOG_PATH}    C:\\Logfiles\\
@{DLUL_PARAMETER}     NR PDCP Thr. DL [Mbps]    NR PDCP Thr. UL [Mbps]    NR RLC Thr. UL [Mbps]    NR MAC Thr. UL [Mbps]    NR PHY Thr. UL [Mbps]
&{lockcell}    EARFCN=525960    PCI=61
&{lockband}    BandStr=41
@{TASK_NAME}    Bandwidth Test
&{TASK_PARA}    TaskName=@{task_name}

*** Keywords ***
Spark Common Suite Setup
    Clean ue log
    Common Suite Setup


Spark Common Suite Teardown
    Common Suite Teardown

Spark Common Test Setup
    Common Test Setup
    Obtain iperf Info

Spark Common Test Teardown
    Common Test Teardown

Clean ue log
    TAF_SSH.connect_to    hostname=${tl.ues[0]['addr']}    username=${tl.ues[0]['username']}
    ...                   password=${tl.ues[0]['password']}    alias=conn
    TAF_SSH.Execute    command=rm -rf ${LOG_PATH}*    connection=conn    timeout=10s

#Lock spark
#    Lock cell    1    &{lockcell}
#    Wait '3s' for stabible
#    Lock band    1    &{lockband}
#
#Lock cell
#    [Arguments]    ${ue_index}    &{lockcell}
#    cpe_execute_at_command    LockCell    index=${ue_index}    para=&{lockcell}
#
#Lock band
#    [Arguments]    ${ue_index}    &{lockband}
#    cpe_execute_at_command    LockBand    index=${ue_index}    para=&{lockband}

Obtain iperf Info
    @{iperf_related_info}    get_iperf_pc_info    ${CONFIG_FILE}
    Set Suite variable    ${iperf_related_info}

Attach NSA ue
    [Arguments]    ${ue_index}
    cpe attach	    fGSACTR=0    GTACT=17    ue_index=${ue_index}           
    Wait '30s' for stabible   
    ${ip}   cpe_get_attach_ip      ue_index=${ue_index}
    Log To Console    ${ip}         
    run keyword if    '${ip[0]}'=='None'     fail   
    [Return]    ${ip}

Attach SA ue
    [Arguments]    ${ue_index}
    cpe attach	    fGSACTR=1    GTACT=14    ue_index=${ue_index}           
    Wait '30s' for stabible   
    ${ip}   cpe_get_attach_ip      ue_index=${ue_index}     start_test=${True} 
    Log To Console    ${ip}         
    run keyword if    '${ip[0]}'=='None'     fail   
    [Return]    ${ip}

Start spark ul traffic
    [Arguments]    ${ue_index}    ${bandwidth}=100000
    ${bandwidth}     evaluate     int(${bandwidth})
    Set To Dictionary     ${test_content}     UDPBandwidth     ${bandwidth}
    cpe_execute_at_command    UpdateTask     para=${TestPlans}    index=${ue_index}
    cpe_execute_at_command    StartTestByName     para=&{task_para}    index=${ue_index}

Start spark dl traffic
    [Arguments]    ${ip}    ${port}    ${band_width}    ${packet_size}
    ${len}    evaluate     len(${ip})
    FOR    ${i}     IN RANGE      0    ${len}
        ${p}    evaluate     5001+${i}
        ${alias}    catenate    ${ip}[${i}]    ${i}
        start_udp_iperf_client    ${iperf_related_info}    ${ip[${i}]}    port=${p}    band_width=${band_width}     
        ...    packet_size=${packet_size}   conn_num=1    ttl=64    output_format=m    alias=${alias}
    END

Stop spark ul traffic
    [Arguments]    ${ue_index}
    cpe_execute_at_command    StopTest      index=${ue_index}

Stop spark dl traffic
    [Arguments]    ${ip}    ${port}   
    ${len}    evaluate     len(${ip})
    FOR    ${i}     IN RANGE      0    ${len}
        ${alias}    catenate    ${ip}[${i}]    ${i}
        ${p}    evaluate     ${port}+${i}
        stop_iperf_client     ${ip[${i}]}     ${p}      alias=${alias}
    END

Start spark dl and ul traffic
    [Arguments]    ${ip}    ${port}    ${duration}    ${packet_size}    ${ue_index}    ${ul_bandwidth}=100000
    Start spark dl traffic    ${ip}    ${port}    ${duration}    ${packet_size}
    Start spark ul traffic    ${ue_index}
    Wait '5s' for stabible

Stop spark dl and ul traffic
    [Arguments]    ${ue_index}    ${ip}    ${port}
    Wait '3s' for stabible
    Stop spark dl traffic    ${ip}    ${port}
    Stop spark ul traffic    ${ue_index}
    
Detach spark ue
    [Arguments]    ${ue_index}
    cpe_detach     index=${ue_index}

Get dl and ul instant throughput
    [Arguments]    ${ue_index}
    Wait '10s' for stabible
    ${dl_tput}    Create List
    ${ul_tput}    Create List
    ${l}    evaluate     len('${ue_index}')
    ${dl}    ${ul}    Run Keyword If    ${l}>1    Get mutiple ue instant throughput    ${ue_index}    ${dl_tput}    ${ul_tput}
    ...    ELSE    Get single ue instant throughput    ${ue_index}    ${dl_tput}    ${ul_tput}
    [Return]    ${dl}    ${ul}

Get mutiple ue instant throughput
    [Arguments]    ${ue_index}    ${dl_tput}    ${ul_tput}
    ${ue_num}    evaluate    len(re.split(',','${ue_index}'))    re
    ${tput}    cpe_execute_at_command    GetParamValue    para=@{DLUL_PARAMETER}    index=${ue_index}
    FOR     ${id}    IN RANGE    0    ${ue_num}
        Append To List    ${dl_tput}    ${tput[${id}]['Param']['Values']}[0]
        Append To List    ${ul_tput}    ${tput[${id}]['Param']['Values']}[1]
    END
    [Return]    ${dl_tput}    ${ul_tput}

Get single ue instant throughput
    [Arguments]    ${ue_index}    ${dl_tput}    ${ul_tput}
    ${tput}    cpe_execute_at_command    GetParamValue    para=@{DLUL_PARAMETER}    index=${ue_index}
    Append To List    ${dl_tput}    ${tput[0]['Param']['Values']}[0]
    Append To List    ${ul_tput}    ${tput[0]['Param']['Values']}[1]
    [Return]    ${dl_tput}[0]    ${ul_tput}[0]

Start spark average log
    [Arguments]    ${ue_index}=1
    [Documentation]    This keyword has to be paired with stop spark average log; ue_index=all or ue_index=1,2,3   all:start all ue log
    cpe_start_log    ue_index=${ue_index}

Stop spark average log
    [Arguments]    ${ue_index}=1
    [Documentation]    This keyword has to be paired with start spark average log; ue_index=all or ue_index=1,2,3   all:stop all ue log
    cpe_stop_log    ue_index=${ue_index}

Get dl and ul average throughput
    [Arguments]    ${ue_index}
    ${log_name}    cpe_collect_log    log_save_folder=${test_log_directory()}    ue_index=${ue_index}    log_type=csv
    FOR     ${file}    IN     @{log_name}
        ${dl}    get tp    ${file}    NR PDCP Thr. DL [Mbps]
        ${ul}    get tp    ${file}    NR PDCP Thr. UL [Mbps]
    END
    [Return]    ${dl}    ${ul}

get tp
    [Arguments]    ${name}    ${col}
    ${ret_l}    Read Csv Columns    ${name}    ${col}
    ${length}    evaluate    len(${ret_l})-1
    ${ret}    Run Keyword If    ${length} > 10    set variable    ${ret_l}[-10:-1]
    ...    ELSE    set variable    ${ret_l}[-5:-1]
    ${avg}    evaluate    sum(${ret})/len(${ret})
    [return]    ${avg}

Upload txtmf to spark
    [Arguments]    ${ip}    ${user_name}=spark    ${user_password}=spark
    unzip_file    ${CONFIG_DIR_PATH}/mcs/test.zip    ${test_log_directory()}
    ${latest_spark}    get_latest_direcotory    ${ip}    ${user_name}    ${user_password}    C:\\Program Files (x86)    Spark
    ${spark_export_path}    catenate    SEPARATOR=    ${latest_spark}    \\Bin\\Config\\Module\\Export\\
    TAF_SSH.connect to    ${ip}    ${user_name}    ${user_password}    alias=spark
    TAF_SSH.upload file    ${test_log_directory()}/test/test.txtmf    ${spark_export_path}test.txtmf    connection=spark

Collect spark rrc log
    [Arguments]    ${ue_index}    ${log_save_folder}    ${log_type}=txt
    [Documentation]   This keyword support log_type is txt and xml, if log_type=all,can collect txt xml and csv
    Stop spark average log    ${ue_index}
    ${log_name}    cpe_collect_log    log_save_folder=${log_save_folder}    log_type=${log_type}    ue_index=${ue_index}
    Start spark average log    ${ue_index}
    [Return]    ${log_name}
