*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

Library        ta5g_ue_measurements
Library        ta5g_pm_counters
Library        ta5g_ue_mobility
Library        ta5g_throughput

*** Keywords ***
Wait ${x:\d+}s For ${reason}
    Sleep    ${x}s    ${reason}

Send Data Traffic In UL
    [Arguments]    ${ue_id}=1    ${pdu_id}=1   ${dir}=ul    ${mbps}=100
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    Sleep    3
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 trf_id=1 dir=${dir} mbps=${mbps}
    Sleep    3
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 trf_id=2 dir=${dir} mbps=${mbps}
    Sleep    3
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 trf_id=3 dir=${dir} mbps=${mbps}
    Sleep    3
    Execute Egate Command    cmd=trf_data_start ue=${ue_id} pdu=${pdu_id} qfi=1 trf_id=4 dir=${dir} mbps=${mbps}
    Sleep    3
    Execute Egate Command    cmd=trf_data_start ue_stats_nr id=${ue_id} type=pusch

Setup PDU Session For UE#${first_UE}-UE#${last_UE}
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Establish Pdu Session    ue_id=${UE}    pdu_id=1    nwslice=1    gw_id=${UE}    check_timestamps=${False}
    Wait 2s For PDU Session Establishment
    END

Setup Traffic To Internal For UE#${first_UE}-UE#${last_UE}
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Execute Egate Command    cmd=set_pdu_param ue=${UE} pdu=1 trf_type=internal
    Wait 2s For Traffic To Establish
    END

Start Traffic For UE#${first_UE}-UE#${last_UE}
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Send Data Traffic    ue_id=${UE}    mbps=50    inactive_timer=10
    Wait 2s For Traffic To Establish
    END

Stop Traffic For UE#${first_UE}-UE#${last_UE}
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Execute Egate Cmd    cmd=trf_data_stop ue=${UE} pdu=1
    Wait 1s For Traffic To Stop
    END

Verify That ${tput}Mbps ${type} Throughput For ${dir} Is Reached On ${cell_id} Cell/s For UE#${first_UE}-UE#${last_UE}
    FOR    ${UE}     IN RANGE   ${first_UE}    ${last_UE}+1
    Expected Throughput For Ue Should Be Reached   ue_id=${UE}   scells=${cell_id}   direction=${dir}   selection_type=${type}   throughput=${tput}
    END
