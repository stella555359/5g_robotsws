*** Settings ***
Documentation
...    Author:  Kong Liang
...    Contact: liang.kong@nokia-sbell.com
...    Feature: Robustness
Suite Setup    Common Suite Setup And Setup Airphone Env
Suite Teardown    Common Suite Teardown And Restore BTS Configuration Parameters
Test Setup    Common Test Setup And Start To Capture Logs
Test Teardown    Common Test Teardown And Stop Capture Logs
Force Tags    5G_RAN_TDD    RAN_5G    CLOUD_5G_I_LO_AP_LOOO
...    SBTS00    CRT    QL3    QCD_MN_RAN    QCP_RAN_RF
Resource    ../../resources/Airphone/Airphone_resource.robot

*** Variables ***
@{ALLOWED_FAULT}
${repeat_number}    12
${tp_per_trf}    100
${TP_check_period}    10

*** Test Cases ***
Robustness_TC29_NR_FR1_FDD_eCPRI_ABIO_WMP_ORAN_L3_Call_Stability_Testing
    [Tags]    ABIO    SMAwave    Robustness    Stability    Trunk    QL3
    Wait Until Keyword Succeeds    10 min    30 sec    Check If All Cells Are OnAir
    Log To Console     \start L3 call stability testing
    Airphone L3 Call For A Long Hours    TP_check_period=${TP_check_period}

*** Keywords ***
Common Suite Setup And Setup Airphone Env
    Common Suite Setup for Airphone
    Setup Airphone Env    tl_type=AP_LOOO/fdd_sansa_cmwv/FS/CB008205_2cells_ecpri    cfg=wts.cfg    withCommission=True

Airphone L3 Call For A Long Hours
    [Arguments]
    ...    ${TP_check_period}=5
    ue attach    call_type=sa    cell_id=1    ue_id=1
    ue send dl and ul traffic    call_type=sa    ue_id=1    dl_mbps=400    ul_mbps=200
    ue attach    call_type=sa    cell_id=2    ue_id=2
    ue send dl and ul traffic    call_type=sa    ue_id=2    dl_mbps=200    ul_mbps=200
    FOR    ${round}    IN RANGE    ${repeat_number}
        Log To Console    [INFO] Verify throughput for DL and UL after ${TP_check_period} min ...\n
        Sleep    ${TP_check_period}min
        Airphone verify throughput for DL and UL    call_type=sa    ue_id=1    dl_mbps=400
        ...    ul_mbps=200    thresh=0.9
        Airphone verify throughput for DL and UL    call_type=sa    ue_id=2    dl_mbps=200
        ...    ul_mbps=200    thresh=0.9
    END
    [Teardown]    Release UEs    ue_type=all

ue attach
    [Arguments]    ${call_type}    ${cell_id}    ${ue_id}
    Should Be True    '${call_type.lower()}' in ('sa', 'nsa')    [ ERROR ] ${call_type} should be sa | SA | nsa | NSA.
    Run Keyword If    '${call_type.lower()}' == 'nsa'    nsa ue attach    ${ue_id}    ${cell_id}
    ...    ELSE IF    '${call_type.lower()}' == 'sa'    sa ue attach    ${ue_id}    ${cell_id}
    ...    ELSE    Log To Console    [ ERROR ]only [ sa | nsa ] ue is supported: [ ${call_type.lower()} ].

sa ue attach
    [Arguments]    ${ue_id}    ${cell_id}
    Perform Egate Command    command=ue_change_location id\=${ue_id} enb\=2 cell\=${cell_id}
    ...    pass_regexp=None    fail_regexp=None    timeout=20    sleep_time=0.2    padding_buffer=50000
    Perform Egate Command    command=ue_register id\=${ue_id}     pass_regexp=UE now in NG RM Registered
    ...    fail_regexp=None    timeout=20    sleep_time=0.2    padding_buffer=50000
    Perform Egate Command    command=set_pdu_param ue\=${ue_id} pdu\=1 trf_type\=internal
    Perform Egate Command    command=ue_pdu_session_setup ue\=${ue_id} pdu\=1 gw\=1    pass_regexp=QoS Routing Table
    ...    fail_regexp=None    timeout=20    sleep_time=0.2    padding_buffer=50000

nsa ue attach
    [Arguments]    ${ue_id}    ${cell_id}
    Perform Egate Command    command=ue_attach id\=${ue_id}     pass_regexp=UE IS ACTIVE
    ...    fail_regexp=None    timeout=20    sleep_time=0.2    padding_buffer=50000
    Perform Egate Command    command=enb_endc_param id\=1 serving_cell_index_range_scg\=5:31
    ...    pass_regexp=None    fail_regexp=None    timeout=20    sleep_time=0.2    padding_buffer=50000
    Perform Egate Command
    ...    command=ue_dc_enb_start ue\=${ue_id} target_gnb\=2 target_cells\=${cell_id} bearer\=2 type\=split_scg
    ...    pass_regexp=reported successful RA        fail_regexp=None    timeout=20    sleep_time=0.2
    ...    padding_buffer=50000

ue traffic start
    [Arguments]    ${call_type}    ${ue_id}    ${dir}    ${tp_mbps}=150
    ${num_of_trf}=    Run Keyword If    ${tp_mbps} > ${tp_per_trf}    Evaluate    (${tp_mbps} // ${tp_per_trf})
    FOR    ${index}    IN RANGE    ${num_of_trf}
        ${index}=    Evaluate    ${index} + 1
        Run Keyword If    '${call_type.lower()}' == 'nsa'
        ...    nsa ue traffic    ue_id=${ue_id}    id=2    dir=${dir}    tp_mbps=${tp_per_trf}    trf_id=${index}
        ...    ELSE IF    '${call_type.lower()}' == 'sa'
        ...    sa ue traffic    ue_id=${ue_id}    pdu=1    qfi=1    dir=${dir}    tp_mbps=${tp_per_trf}
        ...    trf_id=${index}
        ...    ELSE    Log To Console    [ ERROR ]only [ sa | nsa ] ue is supported: [ ${call_type.lower()} ].
    END

nsa ue traffic
    [Arguments]    ${ue_id}    ${id}    ${dir}    ${tp_mbps}    ${trf_id}
    Perform Egate Command
    ...    command=trf_data_start ue\=${ue_id} id\=${id} dir\=${dir} mbps\=${tp_mbps} trf_id\=${trf_id}
    ...    pass_regexp=None    fail_regexp=None    timeout=20    sleep_time=0.2    padding_buffer=50000

sa ue traffic
    [Arguments]    ${ue_id}    ${pdu}    ${qfi}    ${dir}    ${tp_mbps}    ${trf_id}
    Perform Egate Command
    ...    command=trf_data_start ue\=${ue_id} pdu\=${pdu} qfi\=${qfi} dir\=${dir} mbps\=${tp_mbps} trf_id\=${trf_id}
    ...    pass_regexp=None    fail_regexp=None    timeout=20    sleep_time=0.2    padding_buffer=50000

ue send dl and ul traffic
    [Arguments]    ${call_type}    ${ue_id}    ${dl_mbps}    ${ul_mbps}
    ue traffic start    call_type=${call_type}    ue_id=${ue_id}    dir=dl    tp_mbps=${dl_mbps}
    ue traffic start    call_type=${call_type}    ue_id=${ue_id}    dir=ul    tp_mbps=${ul_mbps}

check ue throughput
    [Arguments]    ${call_type}    ${ue_id}    ${direction}    ${tp_mbps}    ${thresh}=0.9
    ${tp_stats}=    Run Keyword If    '${call_type}' == 'sa'    ap_get_sa_throughput    ue_id=${ue_id}    pdu=1
    ...    qfi=1    direction=${direction}    rate_type=ave    level=bearer_stats
    ...    ELSE    '${call_type}' == 'nsa'    ap_get_nsa_throughput    ue_id=${ue_id}
    ...    bearer_id=2    direction=${direction}    rate_type=ave    level=bearer_stats
    Log    ${direction} Throughput stats: ${tp_stats}Mbps
    ${expected_value}=    Evaluate    ${tp_mbps} * ${thresh}
    Run Keyword If    ${tp_stats} > ${expected_value}    Log    Test Passed
    ...    ELSE
    ...    Fail    Test Failed: ${direction} Throughput stats ${tp_stats}mbps is not greater than ${expected_value}mbps

Airphone verify throughput for DL and UL
    [Arguments]    ${call_type}    ${ue_id}    ${dl_mbps}    ${ul_mbps}    ${thresh}=0.9
    check ue throughput    call_type=${call_type}    ue_id=${ue_id}    direction=dl
    ...    tp_mbps=${dl_mbps}    thresh=${thresh}
    check ue throughput    call_type=${call_type}    ue_id=${ue_id}    direction=ul
    ...    tp_mbps=${ul_mbps}    thresh=${thresh}
