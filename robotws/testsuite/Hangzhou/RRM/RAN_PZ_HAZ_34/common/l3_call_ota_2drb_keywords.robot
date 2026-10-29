*** Settings ***
Documentation    L3 Call keywords about 2drb
...   author: JIAYI TANG
...   contact: jiayi.tang@nokia-sbell.com

Resource    ../5GC001937_OTA/resources/5GC001937_AEWB.robot


*** Keywords ***
Check 2DRB in Log
    [Arguments]    ${log_name}=data_dl.txt
    ...    ${host}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    ${username}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    ${password}=${tl.gnbs[${gnb_index}].dus[0].airscale.common_units[0].lmp_connection.password}
    csn.Connect To    hostname=${host}    username=${username}    password=${password}    alias=ASIK_Master
    ${result}    csn.Execute    command=cat /tmp/${log_name}|grep 'numOfBearers 2'    connection=ASIK_Master
    should contain    ${result}    numOfBearers 2
       
L3_Call_ULDL_UDP_2DRB
    [Documentation]     Description: L3 call( 2drb/udp/ul_dl)
    ...     :para ul_throughput: desired data transfer tput in iperf string format
    ...     :para dl_throughput: desired data transfer tput in iperf string format
    ...     :para protocol: 'udp' or 'tcp'
    ...     :para traffic_time: Data transfer duration
    ...     :para ul_drb2_port: configured drb2 port
    ...     :para dl_drb2_port: configured drb2 port
    [Arguments]    ${ul_throughput}=140M    ${dl_throughput}=2300M    ${protocol}=udp    ${traffic_time}=90s
    step3: Prepare UE
    Step4: UE Attach
    Step5: Start traffic    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}    protocol=${protocol}
    Step5: Start traffic UL DRB2    protocol=${protocol}
    Step5: Start traffic DL DRB2    protocol=${protocol}
    ${all_tp}    Step6: Check throughput trunk    traffic_time=${traffic_time}
    Check 2DRB in Log
    Run keyword and continue on failure    should be true    ${all_tp[1]}>${dltp}
    Run keyword and continue on failure    should be true    ${all_tp[4]}>${ultp}
    [Teardown]    Stop L3 call
    
L3_Call_ULDL_TCP_2DRB
    [Documentation]     Description: L3 call( 2drb/tcp/ul_dl)
    ...     :para ul_throughput: desired data transfer tput in iperf string format
    ...     :para dl_throughput: desired data transfer tput in iperf string format
    ...     :para protocol: 'udp' or 'tcp'
    ...     :para traffic_time: Data transfer duration
    ...     :para ul_drb2_port: configured drb2 port
    ...     :para dl_drb2_port: configured drb2 port
    [Arguments]    ${ul_throughput}=140M    ${dl_throughput}=2300M    ${protocol}=tcp    ${traffic_time}=90s
    step3: Prepare UE
    Step4: UE Attach
    Step5: Start traffic    ul_throughput=${ul_throughput}    dl_throughput=${dl_throughput}    protocol=${protocol}
    Step5: Start traffic UL DRB2    protocol=${protocol}
    Step5: Start traffic DL DRB2    protocol=${protocol}
    ${all_tp}    Step6: Check throughput trunk    traffic_time=${traffic_time}
    Check 2DRB in Log
    Run keyword and continue on failure    should be true    ${all_tp[1]}>${dltp}
    Run keyword and continue on failure    should be true    ${all_tp[4]}>${ultp}
    [Teardown]    Stop L3 call

Stop L3 call
    [Documentation]     Description: teardown
    Run Keyword And Ignore Error    Step7: Stop traffic
    Run Keyword And Ignore Error    Step8: UE Detach
    Run Keyword And Ignore Error    Teardown the Aasyslog save progress
    