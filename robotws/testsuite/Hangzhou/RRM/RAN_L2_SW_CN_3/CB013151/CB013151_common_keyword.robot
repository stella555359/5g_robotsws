*** Settings ***
Documentation     author: yayun.zhang
...                 contact: yayun.zhang@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB013151

Resource    testsuite/Hangzhou/RRM/RAN_L2_SW_CN_3/resources/VRF3_T05/internal_resource/internal_resource.robot
Resource    testsuite/Hangzhou/RRM/RAN_L2_SW_CN_3/resources/sg10/internal_resource/internal_resource.robot
Library     taf.analyzer.pcap    WITH NAME    cap

*** Variables ***
${CONFIG_DIR_PATH}    ${CURDIR}/config
${gnb_path}    /tmp/

*** Keywords ***
detach all DL traffic
    [Arguments]    ${ue_id_start}=1    ${ue_id_end_before}=101
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Log To Console    the ${ue_id} DL traffic stop
        ${pdu_id}    Evaluate    (${ue_id} - 1) // 10 + 1
        Airphone SA Stop Data Traffic    ${ue_id}    direction=DL    pdu_id=${pdu_id}
    END

detach all UL traffic
    [Arguments]    ${ue_id_start}=1    ${ue_id_end_before}=101
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Log To Console    the ${ue_id} UL traffic stop
        ${pdu_id}    Evaluate    (${ue_id} - 1) // 10 + 1
        Airphone SA Stop Data Traffic    ${ue_id}    direction=UL    pdu_id=${pdu_id}
    END

setp3 mutiUEs UL traffic
    [Arguments]    ${ue_id_start}=1    ${ue_id_end_before}=101    ${tput}=1    ${ul_data}=1M
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Log To Console    the ${ue_id} UL traffic
        ${pdu_id}    Evaluate    (${ue_id} - 1) // 10 + 1
	    run keyword and continue on failure    Airphone SA Start Data Traffic    ${ue_id}   UL   ${ul_data}   pdu_id=${pdu_id}
	    ...    duration=3600   trf_id=${pdu_id}
    END
    Sleep    30s
    Log To Console    check all UE UL TTraffic
	run keyword and continue on failure
	...   Wait Until Keyword Succeeds    150s    2s  check UL throughput from SA UE '${ue_id_start}' to '${ue_id_end_before}' with tp '${tput}'

check UL throughput from SA UE '${ue_id_start}' to '${ue_id_end_before}' with tp '${ul_cell_tp}'
	${cell_tp_ul}	  evaluate	0
    FOR    ${num}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
       Log To Console    Check throughput UE${num}
          ${ul_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pusch    tput_type=ave
          ${ul_tput_Mb}    evaluate    ${ul_tput_kb}/1000
          Log To Console		ul ${ul_tput_Mb}
          ${cell_tp_ul}    evaluate    ${cell_tp_ul}+${ul_tput_Mb}
    END
    Log To Console		=====ul_cell_tp ${cell_tp_ul}=====
    run keyword and continue on failure    should be true    ${cell_tp_ul}>=${ul_cell_tp}

setp3 mutiUEs traffic
    [Arguments]    ${ue_id_start}=1    ${ue_id_end_before}=101
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Log To Console    the ${ue_id} DL traffic
        ${pdu_id}    Evaluate    (${ue_id} - 1) // 10 + 1
	    run keyword and continue on failure    Airphone SA Start Data Traffic    ${ue_id}   UL   1M   pdu_id=${pdu_id}
	    ...    duration=3600   trf_id=${pdu_id}
    END
    Sleep    5s
    Log To Console    check all UE UL TTraffic
	run keyword and continue on failure
	...   Wait Until Keyword Succeeds    150s    2s  check throughput from SA UE '${ue_id_start}' to '${ue_id_end_before}' with tp '90'

check throughput from SA UE '${ue_id_start}' to '${ue_id_end_before}' with tp '${dl_cell_tp}'
	${cell_tp_dl}	  evaluate	0
    FOR    ${num}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
       Log To Console    Check throughput UE${num}
          ${dl_tput_kb}=    airphone_get_throughput_on_specific_scell    ${num}    0    type=pdsch    tput_type=ave
          ${dl_tput_Mb}    evaluate    ${dl_tput_kb}/1000
          Log To Console		dl ${dl_tput_Mb}
          ${cell_tp_dl}    evaluate    ${cell_tp_dl}+${dl_tput_Mb}
    END
    Log To Console		=====dl_cell_tp ${cell_tp_dl}=====
    run keyword and continue on failure    should be true    ${cell_tp_dl}>=${dl_cell_tp}

step1 prepare ENV
    Set Test Variable    ${SCFC_NAME}            SCFC_B3_01.xml
    Set Test Variable    ${AIRPHONE_NAME}        iphy.xml
    Set Test Variable    ${WTS_NAME}             wts.cfg
#    Set Test Variable    ${GNBCUTYPE}    NSA
    Set Test Variable    ${GNBCUTYPE}    SA
#    ADD RD
    Prepare gnb onair    multi_cells=True
    Comment    sleep 20s for stable
    sleep    20s

step2 100UEs attach
    [Arguments]    ${filename}    ${ue_id_start}=${1}    ${ue_id_end_before}=${101}
    Start capture gNB log on master    filename=${filename}    gNB_index=${0}
    Airphone Multi-UE SA Attach    ue_id_start=${ue_id_start}    ue_id_end_before=${ue_id_end_before}   trf_type=internal     #pdu_id=1
    Stop and download the Logs   filename=${filename}    gNB_index=${0}

Start capture gNB log on master
    [Arguments]    ${filename}    ${gNB_index}=${0}    ${interface}=any
    wait until keyword succeeds    1min   10s    Connect gNB    gNB_index=${gNB_index}
    sleep    3s
    csn.send command    command=tcpdump -i ${interface} -p sctp -w ${gnb_path}${filename}    connection=gNB${gNB_index}
	sleep    3s
    [Teardown]    csn.disconnect    connection=gNB${gNB_index}


Stop and download the Logs
    [Arguments]    ${filename}    ${gNB_index}=${0}
    wait until keyword succeeds    1min   10s    Connect gNB    gNB_index=${gNB_index}
    csn.send command    command=killall tcpdump     connection=gNB${gNB_index}
    sleep    3
    csn.download_file   remote_path=${gnb_path}${filename}   local_path=${CONFIG_DIR_PATH}/${filename}   connection=gNB${gNB_index}
    sleep    3
    [Teardown]    csn.disconnect    connection=gNB${gNB_index}

Connect gNB
    [Arguments]    ${gNB_index}
    csn.Connect to    hostname=${tl.gnbs[${gNB_index}].dus[0].airscale.common_units[0].lmp_connection.addr}
    ...    username=${tl.gnbs[${gNB_index}].dus[0].airscale.common_units[0].lmp_connection.username}
    ...    password=${tl.gnbs[${gNB_index}].dus[0].airscale.common_units[0].lmp_connection.password}
    ...    alias=gNB${gNB_index}

Airphone Multi-UE SA Attach
    [Documentation]    Author: jian.1.chen@nokia-sbell.com
    ...    Init Define: 2025/05/16 15:47
    [Arguments]    ${ue_id_start}    ${ue_id_end_before}        ${trf_type}=internal    ${sleep_time}=1s    #${pdu_id}=1
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Log To Console    the ${ue_id} attach
        ${pdu_id}    Evaluate    (${ue_id} - 1) // 10 + 1
        Airphone SA Attach    ue_id=${ue_id}
        airphone_execute_egate_command    set_pdu_param ue\=${ue_id} pdu\=${pdu_id} trf_type\=${trf_type}
        airphone_execute_egate_command    ue_pdu_session_setup pdu\=${pdu_id} ue\=${ue_id}
        Sleep    ${sleep_time}
    END

detach all UEs
    [Arguments]    ${ue_id_start}    ${ue_id_end_before}
    Log To Console    detach all UEs
    FOR    ${ue_id}    IN RANGE    ${ue_id_start}    ${ue_id_end_before}
        Log To Console    the ${ue_id} detach
        airphone_execute_egate_command    ue_deregister id\=${ue_id} ue_deregister_type\=switch_off
        sleep    1s
    END
