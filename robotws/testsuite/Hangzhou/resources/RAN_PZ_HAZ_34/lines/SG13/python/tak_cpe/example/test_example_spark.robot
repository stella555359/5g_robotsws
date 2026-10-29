*** Settings ***
Resource     ../../../robot/common_resource.robot
Variables      var.py
*** Variables ***
@{attach_list}
@{TASK_NAME}    Bandwidth Test
&{TASK_PARA}    TaskName=@{task_name}

*** Test Cases ***
Test    
    log     ${test_content}
    ${ue_info}     create dictionary    type=SPARK_CPE    address=10.68.152.11         
    cpe setup    ${ue_info}    log_path=C:\\\\Logfiles\\\\ 

    cpe attach	    fGSACTR=0    GTACT=17    ue_index=1,2      
    cpe start log    ue_index=1,2     
    Sleep      30
    
    ${ip1}    cpe_get_attach_ip      ue_index=1,2     start_test=${True} 
    ${server_info}     create list    10.68.152.11     spark    spark      22

    ${pc_info}    create list    10.106.164.180    ute    %EjvHVvvkQD6    22
    run keyword if    '${ip1[0]}'!='None'    start_udp_iperf_client    ${pc_info}     ${ip1[0]}     5001     160 
	...   packet_size=1400    conn_num=1    ttl=64    output_format=m    alias=client
    Start spark ul traffic    1
    Start spark ul traffic    2
    sleep      20
    
    run keyword if    '${ip1[0]}'!='None'    stop_iperf_client     ${ip1}     5001      alias=client    

    run keyword if    '${ip1[0]}'!='None'    cpe_detach     ue_no=1
    run keyword if    '${ip1[1]}'!='None'    cpe_detach     ue_no=2
    cpe stop log    ue_index=1,2
    ${log_name}    cpe_collect_log      log_save_folder=${CURDIR}     ue_index=1,2
    

    FOR     ${file}    IN     @{log_name}
        ${ul}    get tp      ${file}       NR PDCP Thr. UL [Mbps]
        ${dl}    get tp      ${file}       NR PDCP Thr. DL [Mbps]
        should be true     ${ul}>1
        should be true     ${dl}>1
    END

    
*** keywords ***
Start spark ul traffic
    [Arguments]    ${ue_index}    ${bandwidth}=100000
    ${bandwidth}     evaluate     int(${bandwidth})
    Set To Dictionary     ${test_content}     UDPBandwidth     ${bandwidth}
    cpe_execute_at_command    UpdateTask     para=${TestPlans}    index=${ue_index}
    cpe_execute_at_command    StartTestByName     para=&{task_para}    index=${ue_index}
    
get tp
    [Arguments]      ${name}     ${col}
    ${ret}    Read Csv Columns      ${name}       ${col}  
    ${value}     create list   
    
    FOR       ${i}     IN     @{ret}
              run keyword if      '${i}'!=''     append to list        ${value}     ${i}
    END
    ${max}      evaluate      max(${value}) 
    [return]     ${max}

    