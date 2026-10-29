*** Settings ***
Documentation   This is a keyword file for 5GC00071-A traffic
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***



${expected_average data rate_5Mbps}        4980000
${expected_Average packet rate_5Mbps}      498
${expected_average data rate_1Mbps}        980000
${expected_Average packet rate_1Mbps}      98
${expected_average data rate_100Kbps}      98000
${expected_Average packet rate_100Kbps}    8
${expected_Total packets dropped}    5
${expected_Packets corrupted}        5
${expected_Total packets lost}       10

${filter_downlink_traffic_5G}       gtp && ip.src==10.0.1.1 && ip.dst==10.0.1.2
${filter_uplink_traffic_5G}         gtp && ip.src==10.0.1.2 && ip.dst==10.0.1.1

*** Keywords ***


record traffic with wireshark
    [Documentation]    [PRIVATE]    record traffic with wireshark
    ...       :Autor: Sylvia Schneider
    Start Tcpdump on TestPc
    ...  options=-i eth3
    ...  collector=dump_testpc
    sleep     2s
    ${tcpdump_file}    Stop Tcpdump on TestPc
    ...  collector=dump_testpc
    ...  target_dir=${resultDir}
    sleep     2s
    Move File    ${tcpdump_file}    ${resultDir}/wireshark_traffic.pcap


register UE and prepare traffic and start PDU session
    [Documentation]    [PRIVATE]    register UE, prepare traffic, start PDU
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=1    ${pdu_id}=1
    register UE                        ${ue_id}
    Set traffic type                   ue_id=${ue_id}    pdu_id=${pdu_id}    trf_type=internal   log_traffic_stats=off
    start PDU session                  ${ue_id}


start UDP traffic
    [Documentation]    [PRIVATE]    start UDP traffic t1
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=1   ${pdu}=1
     Log To Console    start uplink traffic for ue ${ue_id}
     Start data traffic in egate
     ...    ue_id=${ue_id}    direction=ul    protocol=udp    ack_mode=off    trf_id=1   cl_trf_stats=on    mbps=5   pdu=${pdu}   qfi=1
     Log To Console    start downlink traffic for ue ${ue_id}
     Start data traffic in egate
     ...    ue_id=${ue_id}    direction=dl    protocol=udp    ack_mode=off    trf_id=1   cl_trf_stats=on    mbps=5   pdu=${pdu}   qfi=1


start UDP traffic force HO
    [Documentation]    [PRIVATE]    start UDP traffic force HO
    ...       :Autor: Sylvia Schneider
     Log To Console    \nstart downlink and uplink traffic for mbps=5 qfi=1
     Start data traffic in egate   ue_id=1   direction=dl   protocol=udp   ack_mode=off   trf_id=1   cl_trf_stats=on   mbps=5   pdu=1   qfi=1
     Start data traffic in egate   ue_id=1   direction=ul   protocol=udp   ack_mode=off   trf_id=1   cl_trf_stats=on   mbps=5   pdu=1   qfi=1

     Log To Console    start downlink and uplink traffic for mbps=1 qfi=2
     Start data traffic in egate   ue_id=1   direction=dl   protocol=udp   ack_mode=off   trf_id=1   cl_trf_stats=on   mbps=1   pdu=1   qfi=2
     Start data traffic in egate   ue_id=1   direction=ul   protocol=udp   ack_mode=off   trf_id=1   cl_trf_stats=on   mbps=1   pdu=1   qfi=2

     Log To Console    start downlink and uplink traffic for kbps=100  qfi=3
     Start data traffic in egate   ue_id=1   direction=dl   protocol=udp   ack_mode=off   trf_id=1   cl_trf_stats=on   kbps=100   pdu=1   qfi=3
     Start data traffic in egate   ue_id=1   direction=ul   protocol=udp   ack_mode=off   trf_id=1   cl_trf_stats=on   kbps=100   pdu=1   qfi=3


get bearer statistics force HO
    [Documentation]    [PRIVATE]    get bearer statistics force HO
    ...       :Autor: Sylvia Schneider
    sleep     34s   wait 34 secs
    Log To Console    \nstart get bearer statistics
    FOR    ${direction}   ${qfi}    IN
    ...    dl             1
    ...    ul             1
    ...    dl             2
    ...    ul             2
    ...    dl             3
    ...    ul             3
       get bearer statistics in one direction      ue_id=1       direction=${direction}    qfi=${qfi}     run=1
    END





start UDP traffic voice and get bearer statistics
    [Documentation]    [PRIVATE]    start UDP traffic and get bearer statistics t7
    ...       :Autor: Sylvia Schneider
    FOR   ${dir}  ${mbps}  ${qfi}  IN
    ...   dl      5        1
    ...   ul      5        1
        Log To Console    start ${dir} traffic for ue1 with mbps=${mbps} qfi=${qfi}
        Start data traffic in egate
        ...    ue_id=1    direction=${dir}    protocol=udp    ack_mode=off    trf_id=1   cl_trf_stats=on    mbps=${mbps}   pdu=1   qfi=${qfi}
    END
    FOR   ${dir}  ${kbps}  ${qfi}  IN
    ...   dl      100        2
    ...   ul      100        2
        Log To Console    start ${dir} traffic for ue1 with kbps=${kbps} qfi=${qfi}
        Start data traffic in egate
        ...    ue_id=1    direction=${dir}    protocol=udp    ack_mode=off    trf_id=1   cl_trf_stats=on    kbps=${kbps}   pdu=1   qfi=${qfi}
    END
    get voice bearer statistics after_pdu_setup


reset bearer statistics and get bearer statistics
    [Documentation]    [PRIVATE]    reset bearer statistics and get bearer statistics t7
    ...       :Autor: Sylvia Schneider
    reset bearer statistics
    get voice bearer statistics after_handover_5G


reset bearer statistics
    [Documentation]    [PRIVATE]    reset bearer statistics
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=1
    Log To Console    execute on wts: qfi_stats_clear ue=${ue_id} pdu=1
    sleep     2s
    ute_wtssim.execute egate command    cmd=qfi_stats_clear ue=${ue_id} pdu=1
    ...    alias=ap_egate


get voice bearer statistics ${run}
    [Documentation]    [PRIVATE]    get voicebearer statistics for uplink and downlink traffic
    ...       :Autor: Sylvia Schneider
    get bearer statistics     ${run}
    FOR    ${direction}   ${qfi}    IN
    ...    dl             2
    ...    ul             2
        get bearer statistics in one direction      ue_id=1       direction=${direction}    qfi=${qfi}    run=${run}
    END


get bearer statistics
    [Documentation]    [PRIVATE]    get bearer statistics for uplink and downlink traffic
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${run}     ${ue_id}=1
    sleep     10s
    get bearer statistics in one direction      ue_id=${ue_id}       direction=dl    qfi=1     run=${run}
    get bearer statistics in one direction      ue_id=${ue_id}       direction=ul    qfi=1     run=${run}


get bearer statistics in one direction
    [Documentation]    [PRIVATE]    get bearer statistics in one direction
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}    ${direction}   ${qfi}     ${run}
    ${wts_cmd}  set variable
    ...      bearer_stats ue=${ue_id} dir=${direction} type=l3 scell=0 format=short size_unit=auto trf_id=1 pdu=1 qfi=${qfi}

    Log To Console    execute on wts: ${wts_cmd}
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${wts_cmd}
    ...    return_output=True
    ...    alias=ap_egate
    sleep     2s   wait for all data sent
    Create File    ${resultDir}/egate_${direction}_ue${ue_id}_qfi${qfi}_${run}.txt    ${output_egate}


stop UDP traffic
    [Documentation]    [PRIVATE]    stop UDP traffic
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${ue_id}=1    ${pdu}=1
     Log To Console    stop uplink and downlink traffic for ue ${ue_id}
     Stop data traffic in egate    ue_id=${ue_id}    direction=bi    trf_id=1    pdu=${pdu}


verify traffic statistics voice
    [Documentation]    [PRIVATE]    verify in egate log containing traffic t7
    ...       :Autor: Sylvia Schneider
    FOR   ${direction}   ${ue_id}   ${qfi}   ${mbps}   ${run}               ${verify}    IN
    ...   dl             1          1        5         after_pdu_setup      no
    ...   ul             1          1        5         after_pdu_setup      no
    ...   dl             1          1        5         after_handover_5G    yes
    ...   ul             1          1        5         after_handover_5G    yes
       Log To Console    \nverify traffic statistics file egate_${direction}_ue${ue_id}_qfi${qfi}_${run}.txt
       get values from egate traffic file
       ...    direction=${direction}   ue_id=${ue_id}   run=${run}    verify=${verify}   qfi=${qfi}    mbps=${mbps}
    END
    FOR   ${direction}   ${ue_id}   ${qfi}   ${kbps}   ${run}               ${verify}    IN
    ...   dl             1          2        100       after_pdu_setup      no
    ...   ul             1          2        100       after_pdu_setup      no
    ...   dl             1          2        100       after_handover_5G    yes
    ...   ul             1          2        100       after_handover_5G    yes
       Log To Console    \nverify traffic statistics file egate_${direction}_ue${ue_id}_qfi${qfi}_${run}.txt
       get values from egate traffic file kbps
       ...    direction=${direction}   ue_id=${ue_id}   run=${run}    verify=${verify}   qfi=${qfi}    kbps=${kbps}
    END


verify traffic statistics
    [Documentation]    [PRIVATE]    verify in egate log containing traffic
    ...       :Autor: Sylvia Schneider
    [Arguments]   ${ue_id}=1
    FOR   ${direction}   ${run}               ${verify}    IN
    ...   dl             after_pdu_setup      no
    ...   ul             after_pdu_setup      no
    ...   dl             after_handover_5G    yes
    ...   ul             after_handover_5G    yes
       Log To Console    \nverify traffic statistics file egate_${direction}_ue1_qfi1_${run}.txt
       get values from egate traffic file
       ...    direction=${direction}   ue_id=${ue_id}   run=${run}    verify=${verify}   qfi=1    mbps=5
    END


get values from egate traffic file
    [Documentation]    [PRIVATE]    get values from egate traffic file
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${direction}   ${ue_id}   ${run}    ${verify}    ${qfi}    ${mbps}
    ${contents}    Get File             ${resultDir}/egate_${direction}_ue${ue_id}_qfi${qfi}_${run}.txt

    &{egate_values}   create dictionary
    FOR    ${search_string}    ${index}     IN
    ...    Average data rate      3
    ...    Average packet rate    3
    ...    Total packets dropped  3
    ...    Total packets lost     3
    ...    Packets corrupted      2
       ${line}      Get Lines Containing String     ${contents}     ${search_string}
       @{temp}      split string                    ${line}
       set to dictionary   ${egate_values}   ${search_string}=${temp}[${index}]
       Log To Console    ${search_string}=${temp}[${index}]
    END
    Log Dictionary    ${egate_values}
    IF   '${verify}'=='yes'    Verify Traffic Values    mbps=${mbps}   egate_values=${egate_values}


get values from egate traffic file kbps
    [Documentation]    [PRIVATE]    get values from egate traffic file for kbps values
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${direction}   ${ue_id}   ${run}    ${verify}    ${qfi}    ${kbps}
    ${contents}    Get File             ${resultDir}/egate_${direction}_ue${ue_id}_qfi${qfi}_${run}.txt

    &{egate_values}   create dictionary
    FOR    ${search_string}    ${index}     IN
    ...    Average data rate      3
    ...    Average packet rate    3
    ...    Total packets dropped  3
    ...    Total packets lost     3
    ...    Packets corrupted      2
       ${line}      Get Lines Containing String     ${contents}     ${search_string}
       @{temp}      split string                    ${line}
       set to dictionary   ${egate_values}   ${search_string}=${temp}[${index}]
       Log To Console    ${search_string}=${temp}[${index}]
    END
    Log Dictionary    ${egate_values}
    IF   '${verify}'=='yes'    Verify Traffic Values kbps   kbps=${kbps}   egate_values=${egate_values}


verify traffic values
    [Documentation]    [PRIVATE]    verify_traffic values
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${mbps}    ${egate_values}
    FOR   ${item}   ${operation}   ${expectedValue}   IN
    ...    Average data rate      >=     expected_average data rate_${mbps}Mbps
    ...    Average packet rate    >=     expected_Average packet rate_${mbps}Mbps
    ...    Total packets dropped  <      expected_Total packets dropped
    ...    Total packets lost     <      expected_Packets corrupted
    ...    Packets corrupted      <      expected_Total packets lost
       Log To Console    verify ${item} ${operation} ${${expectedValue}}
       ${value}   get from dictionary    ${egate_values}     ${item}
       ${result}   Set Variable If   ${value} ${operation} ${${expectedValue}}  Passed   Failed
       IF    '${result}'=='Failed'
       ...     Run Keyword And Continue On Failure    Fail    failed ${item}: ${value} ${operation} ${${expectedValue}}
   END


verify traffic values kbps
    [Documentation]    [PRIVATE]    verify_traffic values
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${kbps}    ${egate_values}
    FOR   ${item}   ${operation}   ${expectedValue}   IN
    ...    Average data rate      >=     expected_average data rate_${kbps}Kbps
    ...    Average packet rate    >=     expected_Average packet rate_${kbps}Kbps
    ...    Total packets dropped  <      expected_Total packets dropped
    ...    Total packets lost     <      expected_Packets corrupted
    ...    Packets corrupted      <      expected_Total packets lost
       Log To Console    verify ${item} ${operation} ${${expectedValue}}
       ${value}   get from dictionary    ${egate_values}     ${item}
       ${result}   Set Variable If   ${value} ${operation} ${${expectedValue}}  Passed   Failed
       IF    '${result}'=='Failed'
       ...     Run Keyword And Continue On Failure    Fail    failed ${item}: ${value} ${operation} ${${expectedValue}}
   END


verify wireshark traffic
    [Documentation]    [PRIVATE]    verify with wireshark that data transmission takes place via 5G
    ...       :Autor: Sylvia Schneider
    FOR    ${direction}    IN     downlink    uplink
       Log To Console    verify ${direction} traffic over 5G
       ${msg}     Run     tshark -r ${resultDir}/wireshark_traffic.pcap -Y "${filter_${direction}_traffic_5G}" | wc -l
       Run Keyword And Continue On Failure   Should Be True    ${msg}>${1}
       ...     no ${direction} traffic over 5G
    END
