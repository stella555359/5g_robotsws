*** Settings ***
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/common_other.robot
Library     PA.py


*** Keywords ***
Generate RRE params for update if on trunk branch
    [Documentation]    Author: Ding Binmei
    ...    If on trunk, will return RRE related params for update; otherwise, return None
    ...    RESTAPI_RRE_PARAMS: Defined in file ../TestData/NIDD_modify_rest_api_scellSwap_iwk_RRE.py
    ${param_to_upd}    create dictionary  param_to_upd=${RESTAPI_RRE_PARAMS}
    Return From Keyword If    "${PROGRAM}"!="master"    ${None}
    [Return]    ${param_to_upd}

Adjust PA to trigger scell swap and RRE together
    [Documentation]    Author: Ding Binmei
    ...    Adjust PA to trigger scell swap and RRE together
    ...    ru_index_pcell/ru_index_scell_swap_source/ru_index_scell_swap_target: ru indexs defined in test line config file
    ...    max_retry_time: max time to trigger scell swap and RRE
    ...    wait_time: wait time between each trigger
    [Arguments]    ${ru_index_pcell}    ${ru_index_scell_swap_source}    ${ru_index_scell_swap_target}    ${pa_trigger_rre}=60
    ...    ${pa_trigger_scell_swap}=30    ${max_retry_time}=100    ${wait_time}=5s
    ${ru_index_pcell}    Evaluate    int(${ru_index_pcell})
    ${ru_index_scell_swap_source}    Evaluate    int(${ru_index_scell_swap_source})
    ${ru_index_scell_swap_target}    Evaluate    int(${ru_index_scell_swap_target})
    ${pa_info_before_trigger_rre_scell_swap}    Create Dictionary    ${ru_index_pcell}=${pa_trigger_rre}
    ...    ${ru_index_scell_swap_target}=0
    ${pa_before_trigger_rre_scell_swap}    generate_pa_ports_and_values_for_update
    ...    dict_pa_for_ru=${pa_info_before_trigger_rre_scell_swap}

    ${pa_info_to_trigger_rre_scell_swap}    Create Dictionary    ${ru_index_pcell}=0
    ...    ${ru_index_scell_swap_source}=${pa_trigger_scell_swap}
    ${pa_to_trigger_rre_scell_swap}    generate_pa_ports_and_values_for_update
    ...    dict_pa_for_ru=${pa_info_to_trigger_rre_scell_swap}

    ${pa_info_before_trigger_rre_scell_swap_back}    Create Dictionary    ${ru_index_pcell}=${pa_trigger_rre}
    ...    ${ru_index_scell_swap_source}=0
    ${pa_before_trigger_scell_swap_back}    generate_pa_ports_and_values_for_update
    ...    dict_pa_for_ru=${pa_info_before_trigger_rre_scell_swap_back}

    ${pa_info_to_trigger_rre_scell_swap_back}    Create Dictionary    ${ru_index_pcell}=0
    ...    ${ru_index_scell_swap_target}=${pa_trigger_scell_swap}
    ${pa_to_trigger_scell_swap_back}    generate_pa_ports_and_values_for_update
    ...    dict_pa_for_ru=${pa_info_to_trigger_rre_scell_swap_back}
    Connect to Attenuator    alias=ATTEN_0
    FOR    ${retry}    IN RANGE    ${max_retry_time}
        Log to console    ------------Retry time: ${retry}----------------
        wait until keyword succeeds    5    1s    attenuator.set_ports_attenuation   ports=${pa_before_trigger_rre_scell_swap['pa_ports']}
        ...    values=${pa_before_trigger_rre_scell_swap['pa_values']}   confirm=${True}   attenuator_device=ATTEN_0
        ${log_message}    Catenate    Adjust pcell RU: ${ru_index_pcell} to ${pa_trigger_rre} dB and
        ...    scell swap target RU: ${ru_index_scell_swap_target} to 0 dB
        ...    to prepare for RRE and scell swap. PA info for update: ${pa_before_trigger_rre_scell_swap}
        Log to console    ${log_message}
        wait until keyword succeeds    5    1s    attenuator.set_ports_attenuation   ports=${pa_to_trigger_rre_scell_swap['pa_ports']}
        ...    values=${pa_to_trigger_rre_scell_swap['pa_values']}   confirm=${True}   attenuator_device=ATTEN_0
        ${log_message_trigger_rre_scell_swap}    Catenate    Adjust pcell RU: ${ru_index_pcell} to 0 dB and
        ...    scell swap source RU: ${ru_index_scell_swap_source} to ${pa_trigger_scell_swap} dB
        ...    to trigger for RRE and scell swap. PA info for update: ${pa_to_trigger_rre_scell_swap}
        Log to console    ${log_message_trigger_rre_scell_swap}
        Sleep    ${wait_time}    reason=Wait for RRE and scell swap
        ${log_message_before_swap_back}    Catenate    Adjust pcell RU: ${ru_index_pcell} to ${pa_trigger_rre} dB and
        ...    scell swap target RU: ${ru_index_scell_swap_source} to 0 dB
        ...    to prepare for RRE and scell swap back. PA info for update: ${pa_before_trigger_scell_swap_back}
        Log to console    ${log_message_before_swap_back}
        wait until keyword succeeds    5    1s    attenuator.set_ports_attenuation   ports=${pa_before_trigger_scell_swap_back['pa_ports']}
        ...    values=${pa_before_trigger_scell_swap_back['pa_values']}   confirm=${True}   attenuator_device=ATTEN_0
        ${log_message_trigger_rre_scell_swap_back}    Catenate    Adjust pcell RU: ${ru_index_pcell} to 0 dB and
        ...    scell swap source RU: ${ru_index_scell_swap_target} to ${pa_trigger_scell_swap} dB
        ...    to trigger for RRE and scell swap back. PA info for update: ${pa_to_trigger_scell_swap_back}
        Log to console    ${log_message_trigger_rre_scell_swap_back}
        wait until keyword succeeds    5    1s    attenuator.set_ports_attenuation   ports=${pa_to_trigger_scell_swap_back['pa_ports']}
        ...    values=${pa_to_trigger_scell_swap_back['pa_values']}   confirm=${True}   attenuator_device=ATTEN_0
        Sleep    ${wait_time}    reason=Wait for RRE and scell swap back
    END

