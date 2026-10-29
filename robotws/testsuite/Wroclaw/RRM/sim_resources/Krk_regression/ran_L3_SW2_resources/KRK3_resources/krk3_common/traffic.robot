*** Settings ***
Documentation
...            Keywords for UE traffic management
...            author:       Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...            maintainer:   Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com

Resource    wts.robot

*** Keywords ***
Start Generic Internal Traffic
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
    ...                | Start Generic Internal Traffic | ue_id=1 | pass_regexp=Started Downlink |
    ...                |    | pdu=1 | qfi=1 | dir=dl | mbps=10 |
    [Arguments]    ${ue_id}    ${pass_regexp}=${None}    ${fail_regexp}=${None}    ${timeout}=10s
    ...    ${should_contain}=@{Empty}    ${log_msg}=${Empty}    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Set Variable    trf_data_start ue=${ue_id}
    ${output}    Execute Egate Command Ext
    ...    cmd=${cmd}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}    timeout=${timeout}
    ...    should_contain=${should_contain}    log_msg=${log_msg}    &{params}
    [Return]    ${output}

Stop Generic Internal Traffic
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
    ...                | Stop Generic Internal Traffic | ue_id=1 | pass_regexp=Stopped.*Internal | pdu=1 |
    [Arguments]    ${ue_id}    ${pass_regexp}=${None}    ${fail_regexp}=${None}    ${timeout}=10s
    ...    ${should_contain}=@{Empty}    ${log_msg}=${Empty}    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Set Variable    trf_data_stop ue=${ue_id}
    ${output}    Execute Egate Command Ext
    ...    cmd=${cmd}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}    timeout=${timeout}
    ...    should_contain=${should_contain}    log_msg=${log_msg}    &{params}
    [Return]    ${output}

Start Internal SA Bidirectional Traffic
    [Documentation]    Starts internal downlink and uplink traffic for SA UE.
    ...                - ``ue_id``: SA UE ID
    ...                - ``pdu_id``: PDU Session ID, Default: same as UE ID
    ...                - ``qfi``: QoS Flow ID, Default: 1
    ...                - ``dl_tput``: Downlink throughput with unit (bps/kbps/mbps), Default: 10mbps
    ...                - ``ul_tput``: Uplink throughput with unit (bps/kbps/mbps), Default: 10mbps
    [Arguments]    ${ue_id}    ${pdu_id}=${ue_id}    ${qfi}=1    ${dl_tput}=10mbps    ${ul_tput}=10mbps
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${pdu_id}) is int    msg=Invalid KW parameter: pdu_id
    Should Be True    type(${qfi}) is int    msg=Invalid KW parameter: qfi
    Should Match Regexp    ${dl_tput}    ^[1-9][0-9]*[km]?bps$    msg=Invalid KW parameter: dl_tput
    Should Match Regexp    ${ul_tput}    ^[1-9][0-9]*[km]?bps$    msg=Invalid KW parameter: ul_tput
    #---------------------------------------------------------------------------------------------------------------
    Start Internal SA Downlink Traffic    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi=${qfi}    tput=${dl_tput}
    Start Internal SA Uplink Traffic    ue_id=${ue_id}    pdu_id=${pdu_id}    qfi=${qfi}    tput=${ul_tput}

Start Internal SA Downlink Traffic
    [Documentation]    Starts internal downlink traffic for SA UE via ``trf_data_start`` command.
    ...                Returns egate print.
    ...                - ``ue_id``: SA UE ID
    ...                - ``pdu_id``: PDU Session ID, Default: same as UE ID
    ...                - ``qfi``: QoS Flow ID, Default: 1
    ...                - ``tput``: Downlink throughput with unit (bps/kbps/mbps), Default: 10mbps
    ...                - ``pass_regexp``: Pass regexp, Default: standard
    ...                - ``should_contain``: List or single regexp pattern that command output should contain,\
    ...                Default: None
    ...                - ``params``: Optional parameters and their values for command
    [Arguments]    ${ue_id}    ${pdu_id}=${ue_id}    ${qfi}=1    ${tput}=10mbps
    ...    ${pass_regexp}=Started Downlink Internal traffic.*Ue:${ue_id}
    ...    ${should_contain}=@{Empty}    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${pdu_id}) is int   msg=Invalid KW parameter: pdu_id
    Should Be True    type(${qfi}) is int    msg=Invalid KW parameter: qfi
    Should Match Regexp    ${tput}    ^[1-9][0-9]*[km]?bps$    msg=Invalid KW parameter: tput
    #---------------------------------------------------------------------------------------------------------------
    ${log_msg}    Set Variable    Starting Internal Downlink Traffic on SA UE:${ue_id} PDU:${pdu_id} QFI:${qfi}
    ${output}    Start Generic Internal Traffic
    ...    ue_id=${ue_id}    pass_regexp=${pass_regexp}    pdu=${pdu_id}    qfi=${qfi}
    ...    dir=dl    bps=${tput}    should_contain=${should_contain}    log_msg=${log_msg}    &{params}
    [Return]    ${output}

Start Internal SA Uplink Traffic
    [Documentation]    Starts internal uplink traffic for SA UE via ``trf_data_start`` command.
    ...                Returns egate print.
    ...                - ``ue_id``: SA UE ID
    ...                - ``pdu_id``: PDU Session ID, Default: same as UE ID
    ...                - ``qfi``: QoS Flow ID, Default: 1
    ...                - ``tput``: Uplink throughput with unit (bps/kbps/mbps), Default: 10mbps
    ...                - ``pass_regexp``: Pass regexp, Default: standard
    ...                - ``should_contain``: List or single regexp pattern that command output should contain,\
    ...                Default: None
    ...                - ``params``: Optional parameters and their values for command
    [Arguments]    ${ue_id}    ${pdu_id}=${ue_id}    ${qfi}=1    ${tput}=10mbps
    ...    ${pass_regexp}=Started Uplink Internal traffic.*Ue:${ue_id}
    ...    ${should_contain}=@{Empty}    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${pdu_id}) is int   msg=Invalid KW parameter: pdu_id
    Should Be True    type(${qfi}) is int    msg=Invalid KW parameter: qfi
    Should Match Regexp    ${tput}    ^[1-9][0-9]*[km]?bps$    msg=Invalid KW parameter: tput
    #---------------------------------------------------------------------------------------------------------------
    ${pass_regexp}    Set Variable If    '${pass_regexp}' == ''
    ...    Started Uplink Internal traffic.*Ue:${ue_id}    ${pass_regexp}
    ${log_msg}    Set Variable    Starting Internal Uplink Traffic on SA UE:${ue_id} PDU:${pdu_id} QFI:${qfi}
    ${output}    Start Generic Internal Traffic
    ...    ue_id=${ue_id}    pass_regexp=${pass_regexp}    pdu=${pdu_id}    qfi=${qfi}
    ...    dir=ul    bps=${tput}    should_contain=${should_contain}    log_msg=${log_msg}    &{params}
    [Return]    ${output}

Start Internal NSA Bidirectional Traffic
    [Documentation]    Starts internal downlink and uplink traffic for NSA UE.
    ...                - ``ue_id``: NSA UE ID
    ...                - ``drb_id``: Data Radio Bearer ID, Default: 2
    ...                - ``dl_tput``: Downlink throughput with unit (bps/kbps/mbps), Default: 10mbps
    ...                - ``ul_tput``: Uplink throughput with unit (bps/kbps/mbps), Default: 10mbps
    [Arguments]    ${ue_id}    ${drb_id}=2    ${dl_tput}=10mbps    ${ul_tput}=10mbps
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${drb_id}) is int    msg=Invalid KW parameter: drb_id
    Should Match Regexp    ${dl_tput}    ^[1-9][0-9]*[km]?bps$    msg=Invalid KW parameter: dl_tput
    Should Match Regexp    ${ul_tput}    ^[1-9][0-9]*[km]?bps$    msg=Invalid KW parameter: ul_tput
    #---------------------------------------------------------------------------------------------------------------
    Start Internal NSA Downlink Traffic    ue_id=${ue_id}    drb_id=${drb_id}    tput=${dl_tput}
    Start Internal NSA Uplink Traffic    ue_id=${ue_id}    drb_id=${drb_id}    tput=${ul_tput}

Start Internal NSA Downlink Traffic
    [Documentation]    Starts internal downlink traffic for NSA UE.
    ...                Starting standard NSA traffic does not produce any egate print.
    ...                - ``ue_id``: NSA UE ID
    ...                - ``drb_id``: Data Radio Bearer ID, Default: 2
    ...                - ``tput``: Downlink throughput with unit (bps/kbps/mbps), Default: 10mbps
    ...                - ``pass_regexp``: Pass regexp, Default: None
    ...                - ``should_contain``: List or single regexp pattern that command output should contain,\
    ...                Default: None
    ...                - ``params``: Optional parameters and their values for command
    [Arguments]    ${ue_id}    ${drb_id}=2   ${tput}=10mbps    ${pass_regexp}=${None}
    ...    ${should_contain}=@{Empty}    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${drb_id}) is int    msg=Invalid KW parameter: drb_id
    Should Match Regexp    ${tput}    ^[1-9][0-9]*[km]?bps$    msg=Invalid KW parameter: tput
    #---------------------------------------------------------------------------------------------------------------
    ${log_msg}    Set Variable    Starting Internal Downlink Traffic on NSA UE:${ue_id} DRB:${drb_id}
    ${output}    Start Generic Internal Traffic
    ...    ue_id=${ue_id}    pass_regexp=${pass_regexp}    id=${drb_id}    dir=dl    bps=${tput}
    ...    should_contain=${should_contain}    log_msg=${log_msg}    &{params}
    Run Keyword If    '${pass_regexp}' == 'None'
    ...    Sleep    1s    Wait for cmd to execute due to lack of output print
    [Return]    ${output}

Start Internal NSA Uplink Traffic
    [Documentation]    Starts internal downlink traffic for NSA UE.
    ...                Starting standard NSA traffic does not produce any egate print.
    ...                - ``ue_id``: NSA UE ID
    ...                - ``drb_id``: Data Radio Bearer ID, Default: 2
    ...                - ``tput``: Downlink throughput with unit (bps/kbps/mbps), Default: 10mbps
    ...                - ``pass_regexp``: Pass regexp, Default: None
    ...                - ``should_contain``: List or single regexp pattern that command output should contain,\
    ...                Default: None
    ...                - ``params``: Optional parameters and their values for command
    [Arguments]    ${ue_id}    ${drb_id}=2   ${tput}=10mbps    ${pass_regexp}=${None}
    ...    ${should_contain}=@{Empty}    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${drb_id}) is int    msg=Invalid KW parameter: drb_id
    Should Match Regexp    ${tput}    ^[1-9][0-9]*[km]?bps$    msg=Invalid KW parameter: tput
    #---------------------------------------------------------------------------------------------------------------
    ${log_msg}    Set Variable    Starting Internal Uplink Traffic on NSA UE:${ue_id} DRB:${drb_id}
    ${output}    Start Generic Internal Traffic
    ...    ue_id=${ue_id}    pass_regexp=${pass_regexp}    id=${drb_id}    dir=ul    bps=${tput}
    ...    should_contain=${should_contain}    log_msg=${log_msg}    &{params}
    Run Keyword If    '${pass_regexp}' == 'None'
    ...    Sleep    1s    Wait for cmd to execute due to lack of output print
    [Return]    ${output}

Stop Internal SA Traffic
    [Documentation]    Stops internal traffic for SA UE with specified parameters via ``trf_data_stop`` command.
    ...                Returns egate print.
    ...                - ``ue_id``: SA UE ID
    ...                - ``pdu_id``: PDU Session ID, Default: same as UE ID
    ...                - ``pass_regexp``: Pass regexp, Default: standard
    ...                - ``should_contain``: List or single regexp pattern that command output should contain,\
    ...                Default: None
    ...                - ``params``: Optional parameters and their values for command
    [Arguments]    ${ue_id}    ${pdu_id}=${ue_id}
    ...    ${pass_regexp}=UE ${ue_id}: Traffic was stopped
    ...    ${should_contain}=@{Empty}    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${pdu_id}) is int   msg=Invalid KW parameter: pdu_id
    #---------------------------------------------------------------------------------------------------------------
    ${log_msg}    Set Variable    Stopping Internal Traffic on SA UE:${ue_id} PDU:${pdu_id}
    ${output}    Stop Generic Internal Traffic
    ...    ue_id=${ue_id}    pass_regexp=${pass_regexp}    pdu=${pdu_id}
    ...    should_contain=${should_contain}    log_msg=${log_msg}    &{params}
    [Return]    ${output}

Stop Internal NSA Traffic
    [Documentation]    Stops internal traffic for NSA UE with specified parameters via ``trf_data_stop`` command.
    ...                Returns egate print.
    ...                - ``ue_id``: NSA UE ID
    ...                - ``drb_id``: Data Radio Bearer ID, Default: 2
    ...                - ``pass_regexp``: Pass regexp, Default: standard
    ...                - ``should_contain``: List or single regexp pattern that command output should contain,\
    ...                Default: None
    ...                - ``params``: Optional parameters and their values for command
    [Arguments]    ${ue_id}    ${drb_id}=2
    ...    ${pass_regexp}=Traffic was stopped
    ...    ${should_contain}=@{Empty}    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${drb_id}) is int    msg=Invalid KW parameter: drb_id
    #---------------------------------------------------------------------------------------------------------------
    ${log_msg}    Set Variable    Stopping Internal Traffic on NSA UE:${ue_id} DRB:${drb_id}
    ${output}    Stop Generic Internal Traffic
    ...    ue_id=${ue_id}    pass_regexp=${pass_regexp}    id=${drb_id}
    ...    should_contain=${should_contain}    log_msg=${log_msg}    &{params}
    [Return]    ${output}
