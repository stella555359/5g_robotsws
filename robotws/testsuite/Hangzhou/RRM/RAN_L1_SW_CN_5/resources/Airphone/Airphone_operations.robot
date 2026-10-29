*** Settings ***
Documentation    keywords for Airphone L3 call, includes SA and NSA call type.

Resource    Airphone_startup.robot

*** Keywords ***
Airphone L3 call
    [Arguments]     ${call_type}    ${cell_id}    ${ue_id}    ${bearer_id}=2    ${dl_mbps}=150    ${ul_mbps}=150    ${level}=bearer_stats
    ...    ${duration}=60    ${thresh}=0.9
    [Documentation]    This keyword is used to perform SA/NSA L3 call.
    ...    | Arguments | Man. | Default  | Description |
    ...    | call_type | Yes  | ${EMPTY} | L3 call tpye: SA or NSA. |
    ...    | cell_id   | Yes  | ${EMPTY} | the target cell id of L3 call. |
    ...    | ue_id     | Yes  | ${EMPTY} | ue id to perform L3 call |
    ...    | bearer_id | Yes  | ${EMPTY} | bearer_id for NSA L3 call |
    ...    | dl_mbps   | No   | 150      | mbps :: the dl throughput to be started :: if >100, new trf_id will be used. |
    ...    | ul_mbps   | No   | 150      | mbps :: the ul throughput to be started :: if >100, new trf_id will be used. |
    ...    | level     | No   | bearer_stats | the command to get throughput. 'bearer_stats' or 'ue_stats_nr'.|
    ...    | duration  | No   | 60s      | to define the L3 call duration.|
    ...    | thresh    | No   | 90%      | the expected throughput is 90%, it means the expected tp should be >= mbps*90%. |

    Should Be True    '${call_type.lower()}' in ('sa', 'nsa')    [ ERROR ] ${call_type} should be sa | SA | nsa | NSA.

    Run Keyword If    '${call_type.lower()}' == 'nsa'    nsa ue attach    ${ue_id}    ${cell_id}
    ...    ELSE IF    '${call_type.lower()}' == 'sa'    ue_register    ${ue_id}    ${cell_id}
    ...    ELSE    Log To Console    [ ERROR ]only [ sa | nsa ] ue is supported: [ ${call_type.lower()} ].
    traffic_start_and_throughput_verify    ue_id=${ue_id}    bearer_id=${bearer_id}    dl_mbps=${dl_mbps}    ul_mbps=${ul_mbps}
    ...    duration=${duration}    call_type=${call_type.lower()}    thresh=${thresh}    level=${level}
    [Teardown]    Run Keyword If    '${call_type.lower()}' == 'nsa'    NSA Call Stop and Ue Detach    ${ue_id}
    ...    ELSE IF    '${call_type.lower()}' == 'sa'    Run Keywords    traffic_data_stop   ue_id=${ue_id}    AND    release_ues    ue_id=${ue_id}
    ...    ELSE    Log To Console    [ ERROR ]only [ sa | nsa ] ue is supported: [ ${call_type.lower()} ].

nsa ue attach
    [Arguments]    ${ue_id}    ${cell_id}
    Perform Egate Command    command=ue_attach id\=${ue_id}     pass_regexp=UE IS ACTIVE
    Perform Egate Command    command=enb_endc_param id\=1 serving_cell_index_range_scg\=5:31
    Perform Egate Command    command=ue_dc_enb_start ue\=${ue_id} target_gnb\=2 target_cells\=${cell_id} bearer\=2 type\=split_scg
    ...    pass_regexp=reported successful RA

NSA Call Stop and Ue Detach
    [Arguments]     ${ue_id}
    Perform Egate Command    command=trf_data_stop ue\=${ue_id} id\=2 dir\=dl    pass_regexp=Traffic was stopped
    Perform Egate Command    command=trf_data_stop ue\=${ue_id} id\=2 dir\=ul    pass_regexp=Traffic was stopped
    Perform Egate Command    command=enb_ue_dc_release ue\=${ue_id} bearer\=2 by\=enb cause\=off
    ...    pass_regexp=Bearer-type change from SCG-split to MCG is successful
    Perform Egate Command    command=ue_detach id\=${ue_id}    pass_regexp=detached
