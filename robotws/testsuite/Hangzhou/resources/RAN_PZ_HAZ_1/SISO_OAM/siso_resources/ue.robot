*** Settings ***
Documentation     Author: len.lin@nokia-sbell.com
...               Maintainer: Author
Library           ute_ue
Library           ./ta_ue_custom_keywords.py

*** Variables ***
${OUT_DL_RATE_TDD}    70%
${OUT_UL_RATE_TDD}    70%

*** Keywords ***
Automated Basic Call Real_UE Config
    [Arguments]    ${bts_id}    ${eutra_id}    ${out_exp_dict_ul}    ${out_exp_dict_dl}
    Attach Real_UE To Cell TDD Config    ${bts_id}    ${eutra_id}
    Perform Real_UE Call TDD Config    ${out_exp_dict_dl}    ${out_exp_dict_ul}
    ...     ${OUT_DL_RATE_TDD}    ${OUT_UL_RATE_TDD}
    Detach Real_UE to Cell TDD Config

Reserve Real_UE for tests TDD Config
    Run Keyword And Ignore Error    ute_ue.Require Ue
    ...    UE_${MATCHED_UE_INFO["UE_ID"]}    capabilities=REAL_ANDROID_UE

Attach Real_UE To Cell TDD Config
    [Arguments]    ${bts_id}    ${eutra_id}
    FOR    ${index}    IN RANGE    10
#        Wait Until Keyword Succeeds    8 min    10 sec    Ue Detach And Attach
#        ...    UE_${MATCHED_UE_INFO["UE_ID"]}    timeout=150
        Run Keyword And Ignore Error    ta_ue_custom_keywords.UE Detach    UE_${MATCHED_UE_INFO["UE_ID"]}
        Wait Until Keyword Succeeds    8 min    10 sec    ta_ue_custom_keywords.UE Attach    UE_${MATCHED_UE_INFO["UE_ID"]}
        ${status1}    ${cellid}    Run Keyword And Ignore Error    Ue Get Cellid    UE_${MATCHED_UE_INFO["UE_ID"]}
        ${status2}=    Run Keyword And Return Status    Should Contain    ${eutra_id}    ${cellid}
        Run Keyword If    '${status1}' == 'PASS' and '${status2}' == 'True'   exit for loop
    END
    Run Keyword If    '${status2}'=='False'    Fail    attach ${cellid} failed
    ta_ue_custom_keywords.Ue Make Sure Is In Correct Cell    UE_${MATCHED_UE_INFO["UE_ID"]}    ${cellid}
    ${out_ue_ip}=    ue ensure that ip is correct    UE_${MATCHED_UE_INFO["UE_ID"]}    5
    Log    Ue attached to eNB ${bts_id} and cell ${cellid}\n    console=yes

Detach Real_UE to Cell TDD Config
    ute_ue.Detach Ue    UE_${MATCHED_UE_INFO["UE_ID"]}
    Log    UE detached    console=yes

Perform Real_UE Call TDD Config
    [Arguments]    ${cell_id_dl_th}    ${cell_id_ul_th}
    ...    ${dl_rate}=${OUT_DL_RATE_TDD}    ${ul_rate}=${OUT_UL_RATE_TDD}
    ${status}    ${cell_id}    Run Keyword And Ignore Error    Ue Get Cellid    UE_${MATCHED_UE_INFO["UE_ID"]}
    #Run Keyword And Continue On Failure    Downlink Real_UE Call TDD Config    ${cell_id_dl_th}
    #...    ${cell_id}    ${dl_rate}
    #Run Keyword And Continue On Failure    Uplink Real_UE Call TDD Config    ${cell_id_ul_th}
    #...    ${cell_id}    ${ul_rate}

    Run Keyword And Continue On Failure    Run Tput Real_UE Call TDD Config    ${cell_id}
    ...    ${cell_id_dl_th}    ${dl_rate}    ${cell_id_ul_th}     ${ul_rate}

Run Tput Real_UE Call TDD Config
    [Arguments]    ${cell_id}    ${cell_id_dl_th}    ${dl_rate}    ${cell_id_ul_th}    ${ul_rate}
    Log    Start UDP Data Transfer\n    console=yes
    ${out_current_dl_dt_id}=    set variable    DT_${cell_id}_dl
    ${out_current_ul_dt_id}=    set variable    DT_${cell_id}_ul
    Ue Make Sure Is Capable For Ps Service    UE_${MATCHED_UE_INFO["UE_ID"]}
    run keyword and continue on failure    ute_ue.Start Data Transfer    ${out_current_dl_dt_id}
    ...    UE_${MATCHED_UE_INFO["UE_ID"]}    dl    duration=20s    protocol=udp
    ...    throughput=${cell_id_dl_th}Mbits/sec

    run keyword and continue on failure    ute_ue.Start Data Transfer    ${out_current_ul_dt_id}
    ...    UE_${MATCHED_UE_INFO["UE_ID"]}    ul    duration=20s    protocol=udp
    ...    bandwidth=${cell_id_ul_th}Mbits/sec

    ute_ue.Await Data Transfer Finish    ${out_current_dl_dt_id}
    ute_ue.Await Data Transfer Finish    ${out_current_ul_dt_id}
    ${dl_avg_throughput}=    Ue Print Avg Throughput    ${out_current_dl_dt_id}
    ${ul_avg_throughput}=    Ue Print Avg Throughput    ${out_current_ul_dt_id}

    Ue Review Iperf Reports    ${out_current_dl_dt_id}
    Ue Review Iperf Reports    ${out_current_ul_dt_id}
    Run Keyword And Continue On Failure    ute_ue.Verify Average Throughput With Deviation
    ...    ${out_current_dl_dt_id}    ${cell_id_dl_th}Mbits/sec    ${dl_rate}

    Run Keyword And Continue On Failure    ute_ue.Verify Average Throughput With Deviation
    ...    ${out_current_ul_dt_id}    ${cell_id_ul_th}Mbits/sec    ${ul_rate}

    Log    Avarage throughput: ${ul_avg_throughput} Kbits/sec,${dl_avg_throughput} Kbits/sec    console=yes


Downlink Real_UE Call TDD Config
    [Arguments]    ${cell_id_dl_th}    ${cell_id}    ${dl_rate}
    Log    Start Downlink Data Transfer\n    console=yes
    ${out_current_dt_id}=    set variable    DT_${cell_id}_dl
    Ue Make Sure Is Capable For Ps Service    UE_${MATCHED_UE_INFO["UE_ID"]}
    run keyword and continue on failure    ute_ue.Start Data Transfer    ${out_current_dt_id}
    ...    UE_${MATCHED_UE_INFO["UE_ID"]}    dl    duration=20s    protocol=udp
    ...    throughput=${cell_id_dl_th}Mbits/sec
    ute_ue.Await Data Transfer Finish    ${out_current_dt_id}
    ${avg_throughput}=    Ue Print Avg Throughput    ${out_current_dt_id}
    Ue Review Iperf Reports    ${out_current_dt_id}
    Run Keyword And Continue On Failure    ute_ue.Verify Average Throughput With Deviation
    ...    ${out_current_dt_id}    ${cell_id_dl_th}Mbits/sec    ${dl_rate}
    Log    Avarage throughput: ${avg_throughput} Kbits/sec    console=yes

Uplink Real_UE Call TDD Config
    [Arguments]    ${cell_id_ul_th}    ${cell_id}    ${ul_rate}
    Log    Start Uplink Data Transfer\n    console=yes
    ${out_current_dt_id}=    set variable    DT_${cell_id}_ul
    Ue Make Sure Is Capable For Ps Service    UE_${MATCHED_UE_INFO["UE_ID"]}
    run keyword and continue on failure    ute_ue.Start Data Transfer    ${out_current_dt_id}
    ...    UE_${MATCHED_UE_INFO["UE_ID"]}    ul    duration=20s    protocol=udp
    ...    bandwidth=${cell_id_ul_th}Mbits/sec
    ute_ue.Await Data Transfer Finish    ${out_current_dt_id}
    ${avg_throughput}=    Ue Print Avg Throughput    ${out_current_dt_id}
    Ue Review Iperf Reports    ${out_current_dt_id}
    Run Keyword And Continue On Failure    ute_ue.Verify Average Throughput With Deviation
    ...    ${out_current_dt_id}    ${cell_id_ul_th}Mbits/sec    ${ul_rate}
    Log    Avarage throughput: ${avg_throughput} Kbits/sec    console=yes
