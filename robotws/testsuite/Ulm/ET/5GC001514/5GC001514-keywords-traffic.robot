*** Settings ***
Documentation    This is a Robot keyword File, for 5GC001514 traffic
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------


*** Keywords ***

start downlink and uplink traffic
    [Documentation]    [PRIVATE]    start downlink and uplink traffic
    ...       :Autor: Sylvia Schneider
    Start data traffic in egate  ue_id=${ue_id}   direction=dl   mbps=5   id=2
    Start data traffic in egate  ue_id=${ue_id}   direction=ul   mbps=5   id=2


stop traffic
    [Documentation]    [PRIVATE]    stop all traffic
    ...       :Autor: Sylvia Schneider
    Stop data traffic in egate    ue_id=${ue_id}   direction=bi    id=2


reset bearer statistics
    [Documentation]    [PRIVATE]    reset bearer statistics
    ...       :Autor: Sylvia Schneider
    Log To Console    execute on wts: bearer_stats_clear ue=${ue_id} id=2
    sleep     2s
    ute_wtssim.execute egate command    cmd=bearer_stats_clear ue=${ue_id} id=2
    ...    alias=ap_egate


get bearer statistics
    [Documentation]    [PRIVATE]    get bearer statistics for downlink and uplink traffic
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${run}
    sleep   10s
    get bearer statistics in one direction      direction=dl    run=${run}
    get bearer statistics in one direction      direction=ul    run=${run}


get bearer statistics in one direction
    [Documentation]    [PRIVATE]    get bearer statistics in one direction
    ...       :Autor: Sylvia Schneider
    [Arguments]     ${direction}        ${run}
    ${wts_cmd}  set variable
    ...      bearer_stats ue=${ue_id} dir=${direction} type=l3 scell=0 format=short size_unit=auto trf_id=1 id=2
    Log To Console    execute on wts: ${wts_cmd}
    ${output_egate}   ute_wtssim.execute egate command and wait for data
    ...    cmd=${wts_cmd}
    ...    return_output=True
    ...    alias=ap_egate
    sleep     2s   wait for all data sent
    Create File    ${resultDir}/egate_${direction}_${run}.txt    ${output_egate}


verify traffic statistics after crash
    [Documentation]    [PRIVATE]    verify egate log containing traffic
    ...       :Autor: Sylvia Schneider
    FOR   ${direction}   IN    dl    ul
       Log To Console    \nverify traffic statistics file ${resultDir}/egate_${direction}_after_crash.txt
       get values from egate traffic file
       ...    direction=${direction}
    END


get values from egate traffic file
    [Documentation]    [PRIVATE]    get values from egate traffic file
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${direction}
    ${contents}    Get File             ${resultDir}/egate_${direction}_after_crash.txt

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
    verify traffic values    egate_values=${egate_values}


verify traffic values
    [Documentation]    [PRIVATE]    verify_traffic values
    ...       :Autor: Sylvia Schneider
    [Arguments]      ${egate_values}
    FOR   ${item}   ${operation}    IN
    ...    Average data rate      >= 4950000
    ...    Average packet rate    >= 495
    ...    Total packets dropped  < 5
    ...    Total packets lost     < 5
    ...    Packets corrupted      < 5
       Log To Console    verify ${item} ${operation}
       ${value}   get from dictionary    ${egate_values}     ${item}
       ${result}   Set Variable If   ${value} ${operation}   Passed   Failed
       IF    '${result}'=='Failed'
       ...     Run Keyword And Continue On Failure    Fail    failed ${item}: ${value} ${operation}
   END


record traffic with tcpdump
    [Documentation]    [PRIVATE]    record traffic with tcpdump
    ...       :Autor: Sylvia Schneider
    Start Tcpdump on TestPc
    ...  options=-i any
    ...  collector=dump_testpc
    sleep     2s
    ${tcpdump_file}    Stop Tcpdump on TestPc
    ...  collector=dump_testpc
    ...  target_dir=${resultDir}
    sleep     2s
    Move File    ${tcpdump_file}    ${resultDir}/wireshark_traffic.pcap


verify wireshark traffic
    [Documentation]    [PRIVATE]    verify with wireshark that data transmission takes place via 5G
    ...       :Autor: Sylvia Schneider
    FOR    ${direction}    ${filter}    IN
    ...     downlink       gtp && ip.src==10.0.1.1 && ip.dst==10.0.1.2
    ...     uplink         gtp && ip.src==10.0.1.2 && ip.dst==10.0.1.1
       Log To Console    verify ${direction} traffic over 5G
       ${msg}     Run     tshark -r ${resultDir}/wireshark_traffic.pcap -Y "${filter}" | wc -l
       Run Keyword And Continue On Failure   Should Be True    ${msg}>${1}
       ...     no ${direction} traffic over 5G
    END
