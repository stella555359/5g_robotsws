*** Settings ***
Documentation    ...
#Library           testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
#Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
#Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG11/Resources/SG11_Common_setup_teardown.robot
#Suite Setup       SG11 Common Suite Setup
#Suite Teardown    SG11 Common Suite Teardown
#Test Setup        SG11 Common Case Setup
#Test Teardown     SG11 Common Case Teardown
#
#*** Variables ***
#${UL_THROUGHPUT}         25Mbits/sec
#${UL_THROUGHPUT_2}       15Mbits/sec
#${DL_THROUGHPUT}         55Mbits/sec
#${DL_THROUGHPUT_2}       55Mbits/sec
#${UL_EXPECT}             30
#${DL_EXPECT}             105
#${target_avg_percent}    0.98
#${apn1}                  ${tl.core.pdns[0].apn}
#${apn2}                  ${tl.core.pdns[1].apn}
#
#*** Test Cases ***
#Spark_L3Call
#    ${ue_type}    ue.Translate Power Ue Type From Testline    ue_index=0
#    Set Test Variable    ${ue_type}
#    Log    ${tl.ues[0].ssh_connection_details.addr}
#    Log To Console    ${tl.ues[0].ssh_connection_details.username}
#    Log To Console    ${tl.ues[0].ssh_connection_details.password}
#    @{ue_ip_list}    Create List
#    Set Test Variable    ${ue_ip_list}
#    All Spark UEs Attach And Start Multi DLUL Traffic    ${apn1}    ${apn2}    SA    5G_SA    2    ${DL_THROUGHPUT}    ${UL_THROUGHPUT}
#    Sleep    5s
##    Start Ttitrace With Streaming Mode
##    Sleep    2s
##    Stop Ttitrace    l2stream3_ttitrace    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/
#    Check Spark UEs THP    ${DL_EXPECT}    ${UL_EXPECT}    2
#    Stop Spark UEs Traffic    ${apn2}    2
##    Convert Ttitrace From Pcap To Excelcsv    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/
##    Format Tti In Stream Mode    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/output_dl.csv
##    ...    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/format_output_dl.csv
##    Format Tti In Stream Mode    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/output_ul.csv
##    ...    ${TEST_LOG_DIRECTORY}/ttitrace_streaming/format_output_ul.csv
#
#*** Keywords ***
#Spark Attach And Start Multi DLUL Traffic
#    [Arguments]    ${dl_data}    ${ul_data}    ${n}
#    ...    ${apn_address}    ${apn_address_2}    ${ue_mode}    ${attach_mode}
#    [Documentation]    Attach_start_DL_UL_tput
#    ...    :param    n: The ue_index of Spark
#    ...    :param    ue_mode: start traffic for NSA or SA
#    ...    :param    attach_mode: attach for 5G_NSA or 5G_SA
#    ...    :param    apn_address: DNN or APN
#    Run Keyword And Ignore Error    power_ue.Prepare UE    ue_index=${n}    ue_type=${ue_type}    power_reset=true    get_spark_license=${true}
#    Sleep    2s
#    Run Keyword And Ignore Error    power_ue.UE Attach    ue_index=${n}    ue_type=${ue_type}    power_reset=true    attach_mode=${attach_mode}
#    power_ue.Verify Attach    ue_type=${ue_type}
#    power_ue.Start Traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_data}    duration=1000
#    ...    ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address}
#    Sleep    5s
#    power_ue.Start Traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_data}    duration=1000
#    ...    ue_index=${n}    ue_mode=${ue_mode}    apn_address=${apn_address_2}
#    Sleep    5s
#    ${UE_IP_1}    Run Keyword And Continue On Failure    spark.Create Pdu Session    ue_alias=UE_${n}    id=1    apn=${apn_address}    verify=True
#    Append To List    ${ue_ip_list}    ${ue_ip_1}
#    ${UE_IP_2}    Run Keyword And Continue On Failure    spark.Create Pdu Session    ue_alias=UE_${n}    id=2    apn=${apn_address_2}    verify=True
#    Append To List    ${ue_ip_list}    ${ue_ip_2}
#    Connect To EPC APP    ue_index=${n}
#    ...    hostname=10.57.162.6    username=vrf4_sg11    password=vrf4@11
#    csn.Send Command    command=iperf -c ${UE_IP_2} -u -t 1000 -i 1 -p 21001 -P 1 -f m -b ${DL_THROUGHPUT_2} -l 1400B -T 64 &    connection=EPCAPP
#    Sleep    10s
#    Connect To Control Pc Via Cygwin    ue_index=${n}
#    csn.Send Command    command=/Bin/iperf -c 10.57.162.6 -p 50001 -i 1 -u -B ${UE_IP_1} -b ${UL_THROUGHPUT_2} -t 600 -w 2048k &
#    ...    connection=cygwin
#    Sleep    20s
#
#All Spark UEs Attach And Start Multi DLUL Traffic
#    [Arguments]    ${apn_address}=${apn1}    ${apn_address_2}=${apn2}    ${ue_mode}=SA    ${attach_mode}=5G_SA    ${k}=1
#    ...    ${data_transfer_dl}=1Mbits/sec    ${data_transfer_ul}=1Mbits/sec
#    FOR    ${i}    IN RANGE    ${k}
#    Spark Attach And Start Multi DLUL Traffic    ${data_transfer_dl}    ${data_transfer_ul}    ${i}    ${apn_address}    ${apn_address_2}
#    ...    ${ue_mode}    ${attach_mode}
#    END
#
#Check Spark UEs THP
#    [Arguments]    ${DLthroughput}=0    ${ULthroughput}=0    ${k}=1
#    FOR    ${l}    IN RANGE    ${k}
#    power_ue.Check Throughput    ue_type=${ue_type}    ue_index=${l}    throughput=${DLthroughput}    direction=dl
#    power_ue.Check Throughput    ue_type=${ue_type}    ue_index=${l}    throughput=${ULthroughput}    direction=ul
#    END
#
#Stop Spark UEs Traffic
#    [Arguments]    ${apn_address}=${apn1}    ${k}=1
#    FOR    ${m}    IN RANGE    ${k}
#    power_ue.Stop Traffic    direction=ul    ue_index=${m}    ue_type=${ue_type}    ue_mode=SA    apn_address=${apn_address}
#    END
#    Connect To Control Pc Via Cygwin    ue_index=0
#    csn.Send Command    ps -ef|grep iperf|awk '{print $2}'| xargs kill -9    connection=cygwin
#    FOR    ${ue_ip}    IN    @{ue_ip_list}
#    Connect To EPC APP    ue_index=0
#    ...    hostname=10.57.162.6    username=vrf4_sg11    password=vrf4@11
#    csn.Send Command    command=ps -ef|grep ${UE_IP}|awk '{print $2}'|xargs kill -9    connection=EPCAPP
#    END
