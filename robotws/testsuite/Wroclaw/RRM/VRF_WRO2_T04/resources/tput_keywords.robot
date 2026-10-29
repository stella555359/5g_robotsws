*** Settings ***
Documentation    Generic keyword to run data transfer

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T04/resources/common_keywords.robot
Library         ute_ue


*** Keywords ***
Start Data Transfer In Given Direction
    [Documentation]   Start data transfer for list of UEs for given direction 'DL' or 'UL' or in both directions 'DLUL'
    ...               with given protocol 'TCP' (default value) or 'UDP' through duration in Robot time string format (60 sec default value)
    ...               Other arguments:
    ...                - dl_tput_in_mbits and ul_tput_in_mbits for UDP traffic
    ...                - dt in case when more than one tput session is started
    ...                - offset - time to wait for tput stabilization
    ...                - wait_for_finish - wait until tput finished after 'duration' time
    ...                - packet_size, max_segment_size, parallel - iperf arguments
    ...               Usage samples:
    ...                - Start Data Transfer In Given Direction   @{ues}  direction=DLUL
    ...                - Start Data Transfer In Given Direction   UE_1  UE_2  direction=DLUL  duration=1h  dt=2
    ...                - Start Data Transfer In Given Direction   UE_1  direction=DLUL  protocol=UDP
    [Arguments]   @{ue_list}   ${direction}   ${protocol}=TCP   ${duration}=60s   ${dl_tput_in_mbits}=${None}   ${ul_tput_in_mbits}=${None}
    ...           ${dt}=${EMPTY}   ${offset}=10s   ${wait_for_finish}=${False}
    ...           ${packet_size}=1400   ${max_segment_size}=1360   ${parallel}=1   ${interface_name}=default

    ${tput_udp_kwargs_dict}  Create Dictionary  protocol=${protocol.lower()}  packet_size=${packet_size}
    ${tput_tcp_kwargs_dict}  Create Dictionary  protocol=${protocol.lower()}  max_segment_size=${max_segment_size}  parallel=${parallel}
    ${dt_kwargs}  Set Variable If  '${protocol.lower()}' == 'udp'  ${tput_udp_kwargs_dict}  ${tput_tcp_kwargs_dict}
    IF  '${interface_name}' != 'default'
        Set To Dictionary   ${dt_kwargs}   interface_name=${interface_name}
    END
    ${dl_tput}  Set Variable If  '${protocol.lower()}' == 'udp'  ${dl_tput_in_mbits}Mbits/sec  100Kbits/sec
    ${ul_tput}  Set Variable If  '${protocol.lower()}' == 'udp'  ${ul_tput_in_mbits}Mbits/sec  100Kbits/sec

    Show Text on Console   Run ${protocol.upper()} ${direction} traffic through ${duration}

    FOR   ${ue}   IN   @{ue_list}
        IF   '${direction}' == 'DL' or '${direction}' == 'DLUL'
            Start Data Transfer   dt_name=DT_DL${dt}_${ue}  ue_alias=${ue}  direction=dl  duration=${duration}  throughput=${dl_tput}
            ...   &{dt_kwargs}
            ${tput_on_console}   Set Variable If  '${protocol.lower()}' == 'udp'   ${SPACE}${dl_tput_in_mbits}Mbits/sec   ${EMPTY}
            Log To Console   ${SPACE} DL${dt} ${protocol.upper()} tput${tput_on_console} for ${ue} started
        END
        IF   '${direction}' == 'UL' or '${direction}' == 'DLUL'
            Start Data Transfer   dt_name=DT_UL${dt}_${ue}  ue_alias=${ue}  direction=ul  duration=${duration}  throughput=${ul_tput}
            ...   &{dt_kwargs}
            ${tput_on_console}   Set Variable If  '${protocol.lower()}' == 'udp'   ${SPACE}${ul_tput_in_mbits}Mbits/sec   ${EMPTY}
            Log To Console   ${SPACE} UL${dt} ${protocol.upper()} tput${tput_on_console} for ${ue} started
        END
    END

    BuiltIn.Sleep   ${offset}  wait traffic started and stabilized

    FOR   ${ue}   IN   @{ue_list}
        Run Keyword If   '${direction}' == 'DL' or '${direction}' == 'DLUL'
        ...   Check Data Transfer Is Alive   DT_DL${dt}_${ue}
        Run Keyword If   '${direction}' == 'UL' or '${direction}' == 'DLUL'
        ...   Check Data Transfer Is Alive   DT_UL${dt}_${ue}
    END

    FOR   ${ue}   IN   @{ue_list}
        Run Keyword If   ('${direction}' == 'DL' or '${direction}' == 'DLUL') and ${wait_for_finish}
        ...   Run Keywords   Await Data Transfer Finish   DT_DL${dt}_${ue}
        ...   AND            Log To Console   ${SPACE} DL${dt} ${protocol.upper()} tput for ${ue} finished
        Run Keyword If   ('${direction}' == 'UL' or '${direction}' == 'DLUL') and ${wait_for_finish}
        ...   Run Keywords   Await Data Transfer Finish   DT_UL${dt}_${ue}
        ...   AND            Log To Console   ${SPACE} UL${dt} ${protocol.upper()} tput for ${ue} finished
    END
