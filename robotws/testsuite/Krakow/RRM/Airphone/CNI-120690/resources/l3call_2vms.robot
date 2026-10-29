*** Settings ***
Documentation
...            author:       Hubert Chrzan, hubert.chrzan@nokia.com
...            maintainer:   Hubert Chrzan, hubert.chrzan@nokia.com

Library     String
Library     ute_wtssim
Library     Collections

*** Variables ***
${START_TRF_ID}        1
${END_TRF_ID}          15

*** Keywords ***
Register For SA UEs
    [Arguments]    ${alias}    ${ue_id}    ${pdu_id}=1
    Ensure Set PDU Param Is Successful    ue_id=${ue_id}    pdu_id=${pdu_id}   alias=${alias}
    Sleep   5s    reason=Wait for all data
    Ensure UE Register Is Successful    ue_id=${ue_id}   alias=${alias}
    Sleep   5s    reason=Wait for all data
    Ensure UE PDU Session Setup Is Successful    ue_id=${ue_id}    pdu_id=${pdu_id}   alias=${alias}
    Sleep   5s    reason=Wait for all data

Detach SA UEs
    [Arguments]    ${alias}    ${ue_id}=1    ${pdu_id}=1
    Log To Console    -----Going To release SA UE:${ue_id} on ${alias}-----
    Ensure UE PDU Session Release Is Successful    ue_id=${ue_id}    pdu_id=${pdu_id}    alias=${alias}
    Sleep    5s    reason=Wait for all data
    Ensure UE Deregister Is Successful    ue_id=${ue_id}    alias=${alias}

Start Traffic For SA UEs
    [Arguments]    ${ue_id}    ${alias}    ${dir}
    Log To Console
    ...    -----Starting Internal ${dir} Traffic TRF-ID: ${START_TRF_ID} to ${END_TRF_ID} on SA UE:${ue_id} for WTS:${alias}-----
    FOR    ${id}    IN RANGE    ${START_TRF_ID}    ${END_TRF_ID}
        Start Internal SA Traffic CNI-120690    ue_id=${ue_id}    dir=${dir}    tput=100mbps    trf_id=${id}    protocol=tcp
        ...    alias=${alias}
        Sleep    1s
    END

Start Generic Internal Traffic CNI-120690
    [Documentation]    Starts generic internal traffic for UE with specified parameters via ``trf_data_start`` command.
    ...                Some parameters are required as mandatory, refer to egate documentation. Returns egate print.
    ...                - ``ue_id``: UE ID
    ...                - ``pass_regexp``: Pass regexp, Default: None
    ...                - ``fail_regexp``: Fail regexp, Default: None
    ...                - ``timeout``: Timeout for confirmation, Default: 10s
    ...                - ``should_contain``: List or single regexp pattern that command output should contain,\
    ...                Default: None
    ...                - ``log_msg``: Console log message, Default: Executed command
    ...                - ``params``: Parameters and their values for command
    ...                Example:
    ...                | Start Generic Internal Traffic CNI-120690 | ue_id=1 | pass_regexp=Started Downlink |
    ...                |    | pdu=1 | qfi=1 | dir=dl | mbps=10 |
    [Arguments]    ${ue_id}    ${alias}    ${pass_regexp}=${None}    ${fail_regexp}=${None}    ${timeout}=10s
    ...    ${should_contain}=@{Empty}    ${log_msg}=${Empty}    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Set Variable    trf_data_start ue=${ue_id}
    ${output}    Execute Egate Command Ext CNI-120690
    ...    cmd=${cmd}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}    timeout=${timeout}
    ...    should_contain=${should_contain}    log_msg=${log_msg}    alias=${alias}    &{params}
    [Return]    ${output}

Stop Generic Internal Traffic CNI-120690
    [Documentation]    Stops generic internal traffic for UE with specified parameters via ``trf_data_stop`` command.
    ...                Some parameters are required as mandatory, refer to egate documentation. Returns egate print.
    ...                - ``ue_id``: UE ID
    ...                - ``pass_regexp``: Pass regexp, Default: None
    ...                - ``fail_regexp``: Fail regexp, Default: None
    ...                - ``timeout``: Timeout for confirmation, Default: 10s
    ...                - ``should_contain``: List or single regexp pattern that command output should contain,\
    ...                Default: None
    ...                - ``log_msg``: Console log message, Default: Executed command
    ...                - ``params``: Parameters and their values for command
    ...                Example:
    ...                | Stop Generic Internal Traffic CNI-120690 | ue_id=1 | pass_regexp=Stopped.*Internal | pdu=1 |
    [Arguments]    ${ue_id}    ${alias}    ${pass_regexp}=${None}    ${fail_regexp}=${None}    ${timeout}=10s
    ...    ${should_contain}=@{Empty}    ${log_msg}=${Empty}    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Set Variable    trf_data_stop ue=${ue_id}
    ${output}    Execute Egate Command Ext CNI-120690
    ...    cmd=${cmd}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}    timeout=${timeout}
    ...    should_contain=${should_contain}    log_msg=${log_msg}    alias=${alias}    &{params}
    [Return]    ${output}

Start Internal SA Traffic CNI-120690
    [Documentation]    Starts internal downlink or uplink traffic for SA UE via ``trf_data_start`` command.
    ...                Returns egate print.
    ...                - ``ue_id``: SA UE ID
    ...                - ``pdu_id``: PDU Session ID, Default: same as UE ID
    ...                - ``qfi``: QoS Flow ID, Default: 1
    ...                - ``tput``: Throughput with unit (bps/kbps/mbps), Default: 10mbps
    ...                - ``dir``: Traffic direction ('dl' for downlink or 'ul' for uplink), Default: 'dl'
    ...                - ``pass_regexp``: Pass regexp, Default: standard
    ...                - ``should_contain``: List or single regexp pattern that command output should contain, Default: None
    ...                - ``params``: Optional parameters and their values for command
    [Arguments]    ${ue_id}    ${alias}    ${pdu_id}=${ue_id}    ${qfi}=1    ${tput}=10mbps    ${dir}=dl
    ...    ${pass_regexp}=    ${should_contain}=@{Empty}    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${pdu_id}) is int   msg=Invalid KW parameter: pdu_id
    Should Be True    type(${qfi}) is int    msg=Invalid KW parameter: qfi
    Should Match Regexp    ${tput}    ^[1-9][0-9]*[km]?bps$    msg=Invalid KW parameter: tput
    #---------------------------------------------------------------------------------------------------------------
    ${pass_regexp}    Set Variable If    '${dir}' == 'dl'    Started Downlink Internal traffic.*Ue:${ue_id}    ${pass_regexp}
    ${pass_regexp}    Set Variable If    '${dir}' == 'ul'    Started Uplink Internal traffic.*Ue:${ue_id}    ${pass_regexp}

    ${output}    Start Generic Internal Traffic CNI-120690
    ...    ue_id=${ue_id}    pass_regexp=${pass_regexp}    pdu=${pdu_id}    qfi=${qfi}
    ...    dir=${dir}    bps=${tput}    should_contain=${should_contain}    alias=${alias}    &{params}
    [Return]    ${output}

Stop Internal SA Traffic CNI-120690
    [Documentation]    Stops internal traffic for SA UE with specified parameters via ``trf_data_stop`` command.
    ...                Returns egate print.
    ...                - ``ue_id``: SA UE ID
    ...                - ``pdu_id``: PDU Session ID, Default: same as UE ID
    ...                - ``pass_regexp``: Pass regexp, Default: standard
    ...                - ``should_contain``: List or single regexp pattern that command output should contain,\
    ...                Default: None
    ...                - ``params``: Optional parameters and their values for command
    [Arguments]    ${ue_id}    ${alias}    ${pdu_id}=${ue_id}
    ...    ${pass_regexp}=UE ${ue_id}: Traffic was stopped
    ...    ${should_contain}=@{Empty}    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${pdu_id}) is int   msg=Invalid KW parameter: pdu_id
    #---------------------------------------------------------------------------------------------------------------
    log to console    -----Stopping Internal Traffic on SA UE:${ue_id} PDU:${pdu_id} on ${alias}-----
    ${output}    Stop Generic Internal Traffic CNI-120690
    ...    ue_id=${ue_id}    pass_regexp=${pass_regexp}    pdu=${pdu_id}
    ...    should_contain=${should_contain}    alias=${alias}    &{params}
    [Return]    ${output}

Execute Egate Command Ext CNI-120690
    [Documentation]    Wrapper KW for ``ute_wtssim.execute_egate_command`` with extended functionality.
    ...                - ``cmd``: Egate command to execute
    ...                - ``pass_regexp``: Regexp indicating that the command passed, Default: None
    ...                - ``fail_regexp``: Regexp indicating that the command failed, Default: None
    ...                - ``timeout``: Timeout for finding ``pass_regexp``, Default: 10s
    ...                - ``should_contain``: List or single regexp pattern that command output should contain,\
    ...                Default: None
    ...                - ``should_not_contain``: List or single regexp pattern that command output should not contain,\
    ...                Default: None
    ...                - ``log_msg``: Console log message, Default: Executed command
    ...                - ``cmd_params``: Extra egate command parameters
    [Arguments]    ${cmd}    ${alias}    ${pass_regexp}=${None}    ${fail_regexp}=${None}    ${timeout}=10s
    ...    ${should_contain}=@{Empty}    ${should_not_contain}=@{Empty}    ${log_msg}=${Empty}    &{cmd_params}
    FOR    ${param}    IN    @{cmd_params}
        ${cmd}    Set Variable    ${cmd} ${param}\=${cmd_params}[${param}]
    END
    ${log_msg}    Set Variable If    '${log_msg}' == ''    Executing egate command: ${cmd}    ${log_msg}
    Log    ${log_msg}
    ${output}    ute_wtssim.execute_egate_command
    ...    cmd=${cmd}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}    timeout=${timeout}
    ...    alias=${alias}
    ${is_string}    Run Keyword And Return Status    Should Be String    ${should_contain}
    ${should_contain}    Run Keyword If    ${is_string}
    ...    Create List    ${should_contain}    ELSE    Set Variable    ${should_contain}
    ${is_string}    Run Keyword And Return Status    Should Be String    ${should_not_contain}
    ${should_not_contain}    Run Keyword If    ${is_string}
    ...    Create List    ${should_not_contain}    ELSE    Set Variable    ${should_not_contain}
    FOR    ${pattern}    IN    @{should_contain}
      Should Match Regexp    ${output}    ${pattern}    values=${False}
      ...    msg=Output of egate command does not contain pattern: ${pattern}${\n}cmd: ${cmd}${\n}output:${\n}${output}
    END
    FOR    ${pattern}    IN    @{should_not_contain}
      Should Not Match Regexp    ${output}    ${pattern}    values=${False}
      ...    msg=Output of egate command contains forbidden pattern: ${pattern}${\n}cmd: ${cmd}${\n}output:${\n}${output}
    END
    [Return]    ${output}

Ensure UE Register Is Successful
    [Arguments]    ${ue_id}   ${alias}
    Log To Console    -----Registering UE:${ue_id} for ${alias}-----
    Execute Egate Command And Wait For Data    cmd=ue_register id=${ue_id}    timeout=180s
    ...    pass_regexp=.*REGISTRATION COMPLETE.*
    ...    alias=${alias}

Ensure Set PDU Param Is Successful
    [Arguments]    ${ue_id}    ${pdu_id}   ${alias}    ${trf_type}=internal
    Log To Console    -----Setting parameters for PDU:${pdu_id} for ${alias}-----
    Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=${trf_type}
    ...    alias=${alias}

Ensure UE PDU Session Setup Is Successful
    [Arguments]    ${ue_id}    ${pdu_id}   ${alias}    ${nwslice}=1    ${pass_regexp}=QoS Routing Table
    Log To Console    -----Setting PDU:${pdu_id} session for ${alias}-----
    ${out}   Execute Egate Command and wait for data    cmd=ue_pdu_session_setup pdu=${pdu_id} ue=${ue_id} nwslice=${nwslice}
    ...    timeout=180s    pass_regexp=${pass_regexp}   alias=${alias}
    [Return]    ${out}

Ensure UE PDU Session Release Is Successful
    [Arguments]    ${ue_id}    ${pdu_id}    ${alias}    ${pass_regexp}=Successfully released PDU Session
    Log To Console    -----Releasing PDU:${pdu_id} session-----
    Execute Egate Command    cmd=ue_pdu_session_release pdu=${pdu_id} ue=${ue_id}
    ...    pass_regexp=${pass_regexp}    alias=${alias}

Ensure UE Deregister Is Successful
    [Arguments]    ${ue_id}   ${alias}    ${pass_regexp}=UE${ue_id}: detached    ${type}=switch_off
    Log To Console    -----Detaching UE:${ue_id}-----
    Execute Egate Command and wait for data    cmd=ue_deregister id=${ue_id} ue_deregister_type=${type}
    ...    pass_regexp=${pass_regexp}   alias=${alias}

#Validation
Capture Bearer Stats
    [Arguments]    ${ue_id}    ${alias}    ${dir}    ${pdu_id}=1
    ${bearer_stats_output}    Execute Egate Command and wait for data
    ...    cmd=bearer_stats ue=${ue_id} pdu=${pdu_id} qfi=1 dir=${dir}
    ...    pass_regexp=L3 stats for internal traffic   alias=${alias}
    [Return]    ${bearer_stats_output}

Get Average Throughput from Bearer Stats For SA
    [Arguments]    ${ue_id}    ${dir}    ${alias}
    ${bearer_stats}    Capture Bearer Stats    ue_id=${ue_id}    dir=${dir}    alias=${alias}
    ${output}         Get Regexp Matches    ${bearer_stats}    Average data rate +(\\d+)    1
    [Return]    ${output}

Average Throughput Should Be as Expected
    [Arguments]    ${bearer_stats_tput}    ${expected_tput}
    ${exp_tput_bytes}    Evaluate    int(${expected_tput} * 1000000)
    ${result_stats}    Evaluate    int(${exp_tput_bytes} * 1.3) > int(${bearer_stats_tput}) > int(${exp_tput_bytes} * 0.9)
    Run Keyword If    not ${result_stats}    FAIL
    ...    msg = Total TPut is not as expected. Expected: ${exp_tput_bytes} and Achieved: ${bearer_stats_tput}

Validate Bearer Stats for UEs
    [Arguments]    ${ue_id}    ${expected_tput}    ${alias}    ${dir}=dl
    Log To Console    -----Check ${dir} bearer stats on UE-${ue_id} on host ${alias}-----
    ${iterations}    Set Variable    30
    ${interval}      Set Variable    10
    ${tput_values}    Create List
    FOR    ${i}    IN RANGE    ${iterations}
        ${tput}    Run Keyword And Continue On Failure    Get Average Throughput from Bearer Stats For SA
        ...    ue_id=${ue_id}    dir=${dir}    alias=${alias}
        Append To List    ${tput_values}    ${tput}
        Sleep    ${interval}s
    END
    ${total_tput}    Evaluate    sum([int(t[0]) for t in ${tput_values}])
    ${average_tput}    Evaluate    ${total_tput} / ${iterations}
    Log    Average ${dir.upper()} Throughput: ${average_tput} bps    console=True
    ${result}    Run Keyword And Return Status    Average Throughput Should Be as Expected    ${average_tput}    ${expected_tput}
    Run Keyword If    not ${result}    Log Iterations and Fail    ${tput_values}

Log Iterations and Fail
    [Arguments]    ${tput_values}
    Log To Console    Throughput values: ${tput_values}
    Fail    Average Throughput is not as expected. Check logged values for details.

