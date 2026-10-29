*** Settings ***
Documentation   This is a keyword file for 5GC00071-A traffic
...             Team: 'MN RAN L3 SW ULM L3NRT 07 SG 60'
...             Author: Sylvia Schneider
#-------------------------------------------------------------------------------------------------------------

*** Variables ***


#t5
${expected_average data rate_100kbps}       90000
${expected_Average packet rate_100kbps}     9
${expected_average data rate_1Mbps}         980000
${expected_Average packet rate_1Mbps}       98
${expected_average data rate_30Mbps}        29000000
${expected_Average packet rate_30Mbps}      2650
${expected_average data rate_10Mbps}        9800000
${expected_Average packet rate_10Mbps}      980

#t6
${expected_average data rate_5Mbps}        4900000
${expected_Average packet rate_5Mbps}      490


*** Keywords ***


start UDP traffic voice for 8731 t5 ue1 and get bearer statistics
    [Documentation]    [PRIVATE]    start UDP traffic for 8731 t5 ue1
    ...       :Autor: Sylvia Schneider
    FOR   ${dir}  ${mbps}  ${qfi}  IN
    ...   dl      1        1
    ...   ul      1        1
    ...   dl      30       3
    ...   ul      30       3
        Log To Console    start ${dir} traffic for ue1 with mbps=${mbps} qfi=${qfi}
        Start data traffic in egate
        ...    ue_id=1    direction=${dir}    protocol=udp    ack_mode=off    trf_id=1   cl_trf_stats=on    mbps=${mbps}   pdu=1   qfi=${qfi}
    END

    Log To Console    start downlink and uplink traffic for kbps=100  qfi=2
    Start data traffic in egate   ue_id=1   direction=dl   protocol=udp   ack_mode=off   trf_id=1   cl_trf_stats=on   kbps=100   pdu=1   qfi=2
    Start data traffic in egate   ue_id=1   direction=ul   protocol=udp   ack_mode=off   trf_id=1   cl_trf_stats=on   kbps=100   pdu=1   qfi=2

    sleep     10s
    get 8731 t5 u1 voice bearer statistics    run=start


start UDP traffic voice for 8731 t5 ue2 and get bearer statistics
    [Documentation]    [PRIVATE]    start UDP traffic for 8731 t5 ue2
    ...       :Autor: Sylvia Schneider
    FOR   ${dir}  ${mbps}  ${qfi}  IN
    ...   dl      10        2
    ...   ul      10        2
        Log To Console    start ${dir} traffic for ue1 with mbps=${mbps} qfi=${qfi}
        Start data traffic in egate
        ...    ue_id=2    direction=${dir}    protocol=udp    ack_mode=off    trf_id=1   cl_trf_stats=on    mbps=${mbps}   pdu=1   qfi=${qfi}
    END
    sleep     10s
    get 8731 t5 u2 voice bearer statistics    run=start


get 8731 t5 u1 voice bearer statistics
    [Documentation]    [PRIVATE]    get voicebearer statistics for uplink and downlink traffic 8731 t5
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${run}
    FOR     ${direction}   ${qfi}    IN
    ...     dl             1
    ...     ul             1
    ...     dl             2
    ...     ul             2
    ...     dl             3
    ...     ul             3
        get bearer statistics in one direction      ue_id=1       direction=${direction}    qfi=${qfi}    run=${run}
    END


get 8731 t5 u2 voice bearer statistics
    [Documentation]    [PRIVATE]    get voicebearer statistics for uplink and downlink traffic 8731 t5
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${run}
    FOR    ${direction}   ${qfi}    IN
    ...    dl             2
    ...    ul             2
        get bearer statistics in one direction      ue_id=2       direction=${direction}    qfi=${qfi}    run=${run}
    END


verify traffic statistics t5
    [Documentation]    [PRIVATE]    verify in egate log containing traffic t5
    ...       :Autor: Sylvia Schneider
    FOR   ${direction}   ${ue_id}   ${qfi}   ${mbps}   ${run}               ${verify}    IN
    ...   dl             1          1        1         start                no
    ...   ul             1          1        1         start                no
    ...   dl             1          3        30        start                no
    ...   ul             1          3        30        start                no
    ...   dl             2          2        10        start                no
    ...   ul             2          2        10        start                no
    ...   dl             1          1        1         end                  yes
    ...   ul             1          1        1         end                  yes
    ...   dl             1          3        30        end                  yes
    ...   ul             1          3        30        end                  yes
    ...   dl             2          2        10        end                  yes
    ...   ul             2          2        10        end                  yes
       Log To Console    \nverify traffic statistics file egate_${direction}_ue${ue_id}_qfi${qfi}_${run}.txt
       get values from egate traffic file
       ...    direction=${direction}   ue_id=${ue_id}   run=${run}    verify=${verify}   qfi=${qfi}    mbps=${mbps}
    END
    FOR   ${direction}   ${ue_id}   ${qfi}   ${kbps}   ${run}               ${verify}    IN
    ...   dl             1          2        100       start                no
    ...   ul             1          2        100       start                no
    ...   dl             1          2        100       end                  yes
    ...   ul             1          2        100       end                  yes
       Log To Console    \nverify traffic statistics file egate_${direction}_ue${ue_id}_qfi${qfi}_${run}.txt
       get values from egate traffic file kbps
       ...    direction=${direction}   ue_id=${ue_id}   run=${run}    verify=${verify}   qfi=${qfi}    kbps=${kbps}
    END


start UDP traffic t6 and get bearer statistics
    [Documentation]    [PRIVATE]    start UDP traffic for 8731 t6
    ...       :Autor: Sylvia Schneider
    FOR   ${dir}  ${mbps}  ${qfi}  IN
    ...   dl      5        1
    ...   ul      5        1
        Log To Console    start ${dir} traffic for ue1 with mbps=${mbps} qfi=${qfi}
        Start data traffic in egate
        ...    ue_id=1    direction=${dir}    protocol=udp    ack_mode=off    trf_id=1   cl_trf_stats=on    mbps=${mbps}   pdu=1   qfi=${qfi}
    END
    sleep     10s
    get 8731 t6 bearer statistics    run=start


get 8731 t6 bearer statistics
    [Documentation]    [PRIVATE]    get bearer statistics for uplink and downlink traffic 8731 t6
    ...       :Autor: Sylvia Schneider
    [Arguments]    ${run}
    FOR    ${direction}   ${qfi}    IN
    ...    dl             1
    ...    ul             1
        get bearer statistics in one direction      ue_id=1       direction=${direction}    qfi=${qfi}    run=${run}
    END


verify traffic statistics t6
    [Documentation]    [PRIVATE]    verify in egate log containing traffic t6
    ...       :Autor: Sylvia Schneider
    FOR   ${direction}   ${run}               ${verify}    IN
    ...   dl             start                no
    ...   ul             start                no
    ...   dl             end                  yes
    ...   ul             end                  yes
       Log To Console    \nverify traffic statistics file egate_${direction}_ue1_qfi1_${run}.txt
       get values from egate traffic file
       ...    direction=${direction}   ue_id=1   run=${run}    verify=${verify}   qfi=1    mbps=5
    END
