*** Settings ***
Library     ta5g_throughput
Library     ta5g_egate
Library     ta5g_ue_mobility
Library     testsuite/Wroclaw/RRM/VRF_WRO1_T04/L2PS_WRO/resources/Python/traffic_management.py

Documentation
...    This file contains general keywords used for testing on Classical TL.

*** Variables ***
${BTS_ADDRESS}    192.168.255.129
${BTS_PORT}       443
${USE_SSL}        True

*** Keywords ***
Set Internal Traffic Type To UE
    [Arguments]    ${ue_id}    ${pdu_id}
    Execute Egate Command   cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal

Attach UEs
    [Arguments]    ${num_ue}
    FOR    ${id}    IN RANGE    1    ${num_ue}+1
        ${pdu_id}=    Evaluate    (${id} - 1) % 15 + 1
        Set Internal Traffic Type To UE    ue_id=${id}    pdu_id=${pdu_id}
        Attach Ue    ue_id=${id}
        Establish Pdu Session    ue_id=${id}     pdu_id=${pdu_id}     gw_id=${id}
    END

Start Dl and UL Data Traffic For All UEs
    [Arguments]    ${num_ue}    ${dl_mbps}=175    ${ul_mbps}=10    ${trf_id}=1
    FOR    ${id}    IN RANGE    1    ${num_ue}+1
        ${pdu_id}=    Evaluate    (${id} - 1) % 15 + 1
        Start Dl and UL Traffic     ue_id=${id}    pdu_id=${pdu_id}    dl_mbps=${dl_mbps}    ul_mbps=${ul_mbps}    trf_id=${trf_id}
    END
    Sleep    30s

Start Dl and UL Traffic
    [Arguments]    ${ue_id}    ${pdu_id}    ${dl_mbps}=175    ${ul_mbps}=10    ${trf_id}=1
    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} dir=dl mbps=${dl_mbps} trf_id=${trf_id}
    ...    pass_regexp=UE${ue_id}: Started Downlink Internal traffic Receiver on Ue:${ue_id} Pdu:${pdu_id} Qfi:1 TrfId:${trf_id}
    ...    timeout=10

    Execute Egate Command And Wait For Data
    ...    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} dir=ul mbps=${ul_mbps} trf_id=${trf_id}
    ...    pass_regexp=UE${ue_id}: Started Uplink Internal traffic over UDP on Ue:${ue_id} UecId:1 Pdu:${pdu_id} Qfi:1 TrfId:${trf_id}
    ...    timeout=10

Verify Tput For UE
    [Arguments]   ${ue_id}    ${dir}    ${expected_tput}    ${cc}=0
    ${avg_tput}=    Get Avg Data Traffic For Given Cc    ue_id=${ue_id}   cc=${cc}   direction=${dir}    unit=Mbps
    Should Be True    ${avg_tput} > ${expected_tput}

Stop All Data Transfers And Detach UE
    [Arguments]    ${ue_num}
    FOR    ${ue_id}    IN RANGE    1    ${ue_num}+1
        ${pdu_id}=    Evaluate    (${ue_id} - 1) % 15 + 1
        Execute Egate Command    cmd=trf_data_stop ue=${ue_id} pdu=${pdu_id}
        Sleep    5s
        Execute Egate Command    cmd=ue_deregister id=${ue_id} ue_deregister_type=switch_off
    END
