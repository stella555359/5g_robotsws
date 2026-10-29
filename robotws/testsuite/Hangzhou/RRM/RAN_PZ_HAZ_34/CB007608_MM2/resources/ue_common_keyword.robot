*** Settings ***
Documentation    author: Deng xueqin
...              Group: 5G_PZ_MMW_HZ_2_SG
...              contact: xueqin.deng@nokia-sbell.com


Library    taf.transport.ssh    WITH NAME    ssh
#Library     ../../../../../../testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/python/ue.py
#Resource     ../testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot 
#Resource     ../../../../../testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/android_common_keyword.robot
#Resource     ../../../../../testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/traffic_via_iperf.robot

*** Variables ***
${ue_index}    0   
${dl_throughput}    5M
${dl_expect}    1
${dl_port}    ${tl.ues[${ue_index}].iperf_details.port}
${ul_throughput}    5M
${ul_expect}    1
${throughput_time}    40


*** Keywords ***
Get UE type
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    [Return]    ${ue_type}
    
Common UE Attach
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    Get UE type    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}    log_type=Aasyslog
    power_ue.Verify attach    ue_type=${ue_type}    5Grach_ed=${5Grach_ed}    4G_check=False

Common UE Detach
    [Arguments]    ${ue_index}=${0}
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.UE Detach    ue_type=${ue_type}


Common UL Traffic and Check Tput
    [Arguments]    ${ue_index}=${0}    ${send_traffic}=${ul_throughput}    ${send_duration}=${throughput_time}
    ...    ${check_traffic}=${ul_expect}    ${iperf_port}=${${dl_port}+300}    ${sample}=${5}
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul
    ...    throughput=${send_traffic}    duration=${send_duration}    iperf_port=${iperf_port}
    sleep    10s
    Run Keyword And Ignore Error
    ...    power_ue.Check throughput    ue_type=${ue_type}    direction=ul    throughput=${check_traffic}    sample=${sample}

Common DL Traffic and Check Tput
    [Arguments]    ${ue_index}=${0}    ${send_traffic}=${dl_throughput}    ${send_duration}=${throughput_time}
    ...    ${check_traffic}=${dl_expect}    ${iperf_port}=${dl_port}    ${sample}=${5}
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl
    ...    throughput=${send_traffic}    duration=${send_duration}    iperf_port=${iperf_port}
    #sleep    10s
    #Run Keyword And Ignore Error
    #...    power_ue.Check throughput    ue_type=${ue_type}    direction=dl    throughput=${check_traffic}    sample=${sample}

Common Stop traffic
    [Arguments]    ${direction}    ${iperf_port}    ${ue_index}=${0}
    ${ue_type}    Get UE type    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=${direction}    iperf_port=${iperf_port}

Common UE Recover
    Run Keyword And Ignore Error
    ...    Common Stop traffic    direction=ul    iperf_port=${${dl_port}+300}
    Run Keyword And Ignore Error
    ...    Common Stop traffic    direction=dl    iperf_port=${dl_port}
    #Run Keyword And Ignore Error
    #...    Common UE Detach




