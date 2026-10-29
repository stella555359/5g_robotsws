*** Settings ***
Documentation    Keywords for attenuator channels variations or viewing
...              Author : Annie WOng     annie.wong@nokia.com
...
...              update 03.08.2020:   add keywords dedicated for source and target channels manips
...                     09.08.2021:   add note : remind that the usage of this resource file requires that you
...                                   define testsuite variables :
...                                         ${source_attenuator_id}
...                                         ${target_attenuator_id}
...                                         ${source_channels}
...                                         ${target_channels}
...                                         ${attenuations_min}
...                                         ${attenuations_max}
...                                         ${source_attenuations_a2}
...                                         ${target_attenuations_a2}
...                                         ${source_attenuations_ho_trigger}
...                                         ${target_attenuations_ho_trigger}
...                                         ${source_attenuations_attach}
...                                         ${target_attenuations_attach}
...                     12.08.2021:   align with taf.hw.rf-attenuator-0.11.1


Library         String
Library         ../python/hytem_handler.py


*** Keywords ***
View Attenuator all channels
    [Arguments]     ${attenuator_id}=${0}
    Log        Attenuator vendor: ${tl.attenuators[${attenuator_id}].vendor}   console=${DEBUG_MODE_CONSOLE}
    log        Attenuator ip_addr: ${tl.attenuators[${attenuator_id}].ip_addr}    console=${DEBUG_MODE_CONSOLE}
    Log        Attenuator port (mgt): ${tl.attenuators[${attenuator_id}].port}     console=${DEBUG_MODE_CONSOLE}
    Log        Attenuator attenuator_ports: ${tl.attenuators[${attenuator_id}].attenuator_ports}    console=${DEBUG_MODE_CONSOLE}
    ${all_attenuator_ports}    set variable     ${tl.attenuators[${attenuator_id}].attenuator_ports}
    hytem_handler.read_channels_attenuation    channels=${all_attenuator_ports}      attenuator_id=${attenuator_id}


View Source channels
    Log        Viewing Source Channels:${source_channels}      console=${DEBUG_MODE_CONSOLE}
    View Channels      input_channels=${source_channels}      attenuator_id=${source_attenuator_id}


View Target channels
    Log        Viewing Target Channels:${target_channels}      console=${DEBUG_MODE_CONSOLE}
    View Channels      input_channels=${target_channels}      attenuator_id=${target_attenuator_id}


Increment Source Channels To Final Values through Steps
    [Documentation]    increment attenuation for ports connected to source cell of requested step db in loop
    ...                until final signals is reached (exple final_signals=17,17)
    [Arguments]        ${final_signals}    ${step}=1     ${verify}=${True}
    Increment Channels To Final Values through Steps
    ...        input_channels=${source_channels}
    ...         final_signals=${final_signals}
    ...                  step=${step}
    ...         attenuator_id=${source_attenuator_id}
    ...                verify=${verify}


Decrement Source Channels To Final Values through Steps
    [Documentation]    decrement attenuation for ports connected to source cell of requested step db in loop
    ...                until final signals is reached (exple final_signals=5,5)
    [Arguments]        ${final_signals}    ${step}=1     ${verify}=${True}
    Decrement Channels To Final Values through Steps
    ...        input_channels=${source_channels}
    ...         final_signals=${final_signals}
    ...                  step=${step}
    ...         attenuator_id=${source_attenuator_id}
    ...                verify=${verify}


Increment Target Channels To Final Values through Steps
    [Documentation]    increment attenuation for ports connected to target cell of requested step db in loop
    ...                until final signals is reached (exple final_signals=90,90)
    [Arguments]        ${final_signals}    ${step}=1     ${verify}=${True}
    Increment Channels To Final Values through Steps
    ...        input_channels=${target_channels}
    ...         final_signals=${final_signals}
    ...                  step=${step}
    ...         attenuator_id=${target_attenuator_id}
    ...                verify=${verify}


Decrement Target Channels To Final Values through Steps
    [Documentation]    decrement attenuation for ports connected to target cell of requested step db in loop
    ...                until final signals is reached (exple final_signals=75,75)
    [Arguments]        ${final_signals}    ${step}=1     ${verify}=${True}
    Decrement Channels To Final Values through Steps
    ...        input_channels=${target_channels}
    ...         final_signals=${final_signals}
    ...                  step=${step}
    ...         attenuator_id=${target_attenuator_id}
    ...                verify=${verify}


Set Source Attenuations
    [Documentation]    set attenuation for ports connected to source cell to some value; example: signals=14.5,14.5
    [Arguments]         ${signals}     ${verify}=${True}
    Set Attenuation Channels    input_channels=${source_channels}
    ...                                signals=${signals}
    ...                          attenuator_id=${source_attenuator_id}
    ...                                 verify=${verify}


Set Target Attenuations
    [Documentation]    set attenuation for ports connected to source cell to some value : example signals=85,85
    [Arguments]         ${signals}     ${verify}=${True}
    Set Attenuation Channels    input_channels=${target_channels}
    ...                                signals=${signals}
    ...                          attenuator_id=${target_attenuator_id}
    ...                                 verify=${verify}


Set Source Channels Min Attenuations
    [Documentation]    set attenuation for ports connected to source cell to min value.
    [Arguments]        ${verify}=${False}
    Set Attenuation Channels
    ...   input_channels=${source_channels}
    ...          signals=${attenuations_min}
    ...    attenuator_id=${source_attenuator_id}
    ...           verify=${verify}


Set Source Channels Max Attenuations
    [Documentation]    set attenuation for ports connected to source cell to max value.
    [Arguments]        ${verify}=${False}
    Set Attenuation Channels
    ...   input_channels=${source_channels}
    ...          signals=${attenuations_max}
    ...    attenuator_id=${source_attenuator_id}
    ...           verify=${verify}


Set Target Channels Min Attenuations
    [Documentation]    set attenuation for ports connected to target cell to min.
    [Arguments]        ${verify}=${False}
    Set Attenuation Channels
    ...   input_channels=${target_channels}
    ...          signals=${attenuations_min}
    ...    attenuator_id=${target_attenuator_id}
    ...           verify=${verify}


Set Target Channels Max Attenuations
    [Documentation]    set attenuation for ports connected to target cell to max.
    [Arguments]        ${verify}=${False}
    Set Attenuation Channels
    ...   input_channels=${target_channels}
    ...          signals=${attenuations_max}
    ...    attenuator_id=${target_attenuator_id}
    ...           verify=${verify}


Increment Source Channels
    [Documentation]    increment attenuation for ports connected to source cell of requested step db
    ...                 (final signals = (current signals + step)  on each port
    [Arguments]      ${step_increment}=1    ${verify}=${True}
    Increment Channels   channels=${source_channels}  step=${step_increment}
    ...                  attenuator_id=${source_attenuator_id}     verify=${verify}


Decrement Source Channels
    [Documentation]    Decrement attenuation for ports connected to source cell of requested step db
    ...                 (final signals = (current signals - step)  on each port
    [Arguments]      ${step_decrement}=1    ${verify}=${True}
    Decrement Channels   channels=${source_channels}  step=${step_decrement}
    ...                  attenuator_id=${source_attenuator_id}      verify=${verify}


Increment Target Channels
    [Documentation]    increment attenuation for ports connected to target cell of requested step db
    ...                 (final signals = (current signals + step)  on each port
    [Arguments]     ${step_increment}=1     ${verify}=${True}
    Increment Channels   channels=${target_channels}  step=${step_increment}
    ...                  attenuator_id=${target_attenuator_id}      verify=${verify}


Decrement Target Channels
    [Documentation]    decrement attenuation for ports connected to target cell of requested step db
    ...                 (final signals = (current signals - step)  on each port
    [Arguments]     ${step_decrement}=1    ${verify}=${True}
    Decrement Channels   channels=${target_channels}  step=${step_decrement}
    ...                  attenuator_id=${target_attenuator_id}     verify=${verify}


Increment Source Channels and Decrement Target Channels
    [Arguments]     ${step_increment}=1    ${step_decrement}=1    ${verify}=${True}
    Log             \n Increment Source Channels and Decrement Target Channels :
    Increment Source Channels    step_increment=${step_increment}   verify=${verify}
    Decrement Target Channels    step_decrement=${step_decrement}   verify=${verify}


### main keywords :
Increment Channels To Final Values through Steps
    [Arguments]       ${input_channels}    ${final_signals}    ${step}=1    ${attenuator_id}=${0}    ${verify}=${True}
    ${iSignal}     View Channels    input_channels=${input_channels}    attenuator_id=${attenuator_id}
    @{FSignal}     Evaluate    '${final_signals}'.split(',')
    Log      Initial signal=${iSignal[0]}     console=${DEBUG_MODE_CONSOLE}
    Log      Final signal=${FSignal[0]}    console=${DEBUG_MODE_CONSOLE}
    # old (taf.hw.rf-attenuator-0.8.0):    should be true         ${FSignal[0]}*10 >= ${iSignal[0]}
    should be true         ${FSignal[0]} >= ${iSignal[0]}
    # old (taf.hw.rf-attenuator-0.8.0):    evaluate      1+(${FSignal[0]}-${iSignal[0]}/10)/${step}
    ${number_of_times}=    evaluate      1+(${FSignal[0]}-${iSignal[0]})/${step}
    Log           NB Times FOR Loop (+1) = ${number_of_times}  console=${DEBUG_MODE_CONSOLE}
    FOR    ${item}    IN RANGE    0    ${number_of_times}
       ${current_dbs}=   Increment Channels    channels=${input_channels}  step=${step}  attenuator_id=${attenuator_id}
        ...                   verify=${verify}
        Run Keyword If    ${current_dbs[0]}>=${FSignal[0]}    Exit For Loop
    # old (taf.hw.rf-attenuator-0.8.0):
    # \   ${real_db}        evaluate   ${current_dbs[0]}/10
    # \   Run Keyword If    ${real_db}>=${FSignal[0]}    Exit For Loop
    #View Channels      input_channels=${input_channels}    attenuator_id=${attenuator_id}
    END


Decrement Channels To Final Values through Steps
    [Arguments]       ${input_channels}    ${final_signals}    ${step}=1    ${attenuator_id}=${0}     ${verify}=${True}
    ${iSignal}     View Channels    input_channels=${input_channels}    attenuator_id=${attenuator_id}
    @{FSignal}     Evaluate         '${final_signals}'.split(',')
    Log      Initial signal=${iSignal[0]}    console=${DEBUG_MODE_CONSOLE}
    Log      Final signal=${FSignal[0]}    console=${DEBUG_MODE_CONSOLE}
    # old (taf.hw.rf-attenuator-0.8.0):   should be true         ${FSignal[0]}*10 <= ${iSignal[0]}
    should be true         ${FSignal[0]} <= ${iSignal[0]}
    # old (taf.hw.rf-attenuator-0.8.0):   evaluate      1+(${iSignal[0]}/10-${FSignal[0]})/${step}
    ${number_of_times}=    evaluate      1+(${iSignal[0]}-${FSignal[0]})/${step}
    Log           NB Times FOR Loop (+1) = ${number_of_times}  console=${DEBUG_MODE_CONSOLE}
    FOR    ${item}    IN RANGE    0    ${number_of_times}
        ${current_dbs}=    Decrement Channels  channels=${input_channels}  step=${step}  attenuator_id=${attenuator_id}
        ...                    verify=${verify}
        Run Keyword If     ${current_dbs[0]}<=${FSignal[0]}    Exit For Loop
    # old (taf.hw.rf-attenuator-0.8.0):
    # \   ${real_db}         evaluate   ${current_dbs[0]}/10
    # \   Run Keyword If     ${real_db}<=${FSignal[0]}    Exit For Loop
    #View Channels      input_channels=${input_channels}    attenuator_id=${attenuator_id}
    END


Increment Channels
    [Arguments]        ${channels}      ${step}=1     ${attenuator_id}=${0}    ${verify}=${True}
    @{attn_channels}    Evaluate    '${channels}'.split(',')
    ${result}=   hytem_handler.increment_channels_attenuation
    ...               channels=${attn_channels}
    ...                   step=${step}
    ...          attenuator_id=${attenuator_id}
    ...                 verify=${verify}
    Log          Incremented Channels:[${channels}] to:${result} with step=${step}db   console=${DEBUG_MODE_CONSOLE}
    [Return]    ${result}


Decrement Channels
    [Arguments]        ${channels}      ${step}=1     ${attenuator_id}=${0}    ${verify}=${True}
    @{attn_channels}    Evaluate    '${channels}'.split(',')
    ${result}=   hytem_handler.decrement_channels_attenuation
    ...               channels=${attn_channels}
    ...                   step=${step}
    ...          attenuator_id=${attenuator_id}
    ...                 verify=${verify}
    Log          Decremented Channels:[${channels}] to:${result} with step=${step}db   console=${DEBUG_MODE_CONSOLE}
    [Return]    ${result}


Set Attenuation Channels
    [Documentation]    set attenuation for ports to some value; example: input_channel=0,1  signals=14.5,14.5
    [Arguments]        ${input_channels}      ${signals}      ${attenuator_id}=${0}    ${verify}=${True}
    @{attn_channels}    Evaluate    '${input_channels}'.split(',')
    @{attn_signals}     Evaluate    '${signals}'.split(',')
    Log         Setting attenuations on Channels:[${input_channels}] to:[${signals}] ...   console=${DEBUG_MODE_CONSOLE}
    hytem_handler.set_channels_attenuation    channels=${attn_channels}   signals=${attn_signals}
    ...                                   attenuator_id=${attenuator_id}     verify=${verify}


View Channels
    [Arguments]     ${input_channels}     ${attenuator_id}=${0}
    # channels : example '1,2'
    # return ports attenuations values db x 10
    ${result} =    create list    @{empty}
    @{attn_channels}    Evaluate    '${input_channels}'.split(',')
    ${result}=  hytem_handler.read_channels_attenuation    channels=${attn_channels}      attenuator_id=${attenuator_id}
    Log          View attenuations on Channels:[${input_channels}], Value=${result}   console=${DEBUG_MODE_CONSOLE}
    [return]   ${result}
