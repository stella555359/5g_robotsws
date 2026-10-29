*** Settings ***
Documentation
...            Keywords for scenario procedures
...            author:       Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com
...            maintainer:   Jacek Bohdanowicz, jacek.bohdanowicz@nokia.com

Library    OperatingSystem
Library    Process
Library    String
Library    Collections

Resource    configurators.robot
Resource    verificators.robot
Resource    wts.robot
Resource    traffic.robot

*** Variables ***
${STD_UE_ATTACH_FAIL}    Failure.*while applying|L2.*Timer has expired|T.* expiration|No response from proxy

*** Keywords ***
Start SA L3 Call
    [Documentation]    Starts full L3 Call for specified SA UE.
    ...                Procedure: UE Register -> PDU Session Setup -> DL + UL Traffic Start
    ...                Default traffic speed for UE is 20 mbps (10/10 between DL/UL).
    ...                Traffic speed for the specified direction set to 0 will not be started.
    ...                - ``ue_id``: SA UE ID
    ...                - ``pdu_id``: PDU Session ID, Default: same as UE ID
    ...                - ``gw_id``: SA Gateway ID, Default: Not used
    ...                - ``nwslice``: Requested Network Slice ID, Default: 1
    ...                - ``dl_tput``: Downlink throughput with unit (bps/kbps/mbps) or OFF, Default: 10mbps
    ...                - ``ul_tput``: Uplink throughput with unit (bps/kbps/mbps) or OFF, Default: 10mbps
    [Arguments]    ${ue_id}    ${pdu_id}=${ue_id}    ${gw_id}=${Empty}    ${nwslice}=1    ${dl_tput}=10mbps    ${ul_tput}=10mbps
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${pdu_id}) is int    msg=Invalid KW parameter: pdu_id
    Should Be True    '${gw_id}' == '' or type(${gw_id}) is int    msg=Invalid KW parameter: gw_id
    Should Be True    type(${nwslice}) is int    msg=Invalid KW parameter: nwslice
    Should Match Regexp    ${dl_tput}    ^OFF$|^[1-9][0-9]*[km]?bps$    msg=Invalid KW parameter: dl_tput
    Should Match Regexp    ${ul_tput}    ^OFF$|^[1-9][0-9]*[km]?bps$    msg=Invalid KW parameter: ul_tput
    #---------------------------------------------------------------------------------------------------------------
    SA UE Register    ue_id=${ue_id}
    PDU Session Setup    ue_id=${ue_id}    pdu_id=${pdu_id}    gw_id=${gw_id}    nwslice=${nwslice}
    Run Keyword If    '${dl_tput}' != 'OFF'    Start Internal SA Downlink Traffic    ue_id=${ue_id}    tput=${dl_tput}    pdu_id=${pdu_id}
    Run Keyword If    '${ul_tput}' != 'OFF'    Start Internal SA Uplink Traffic    ue_id=${ue_id}    tput=${ul_tput}    pdu_id=${pdu_id}

Start NSA L3 Call
    [Documentation]    Starts full L3 Call for specified NSA UE.
    ...                Procedure: UE Attach to ENB -> LTE-NR Dual Connectivity to GNB -> DL + UL Traffic Start
    ...                Default traffic speed for UE is 20 mbps (10/10 between DL/UL).
    ...                Traffic speed for the specified direction set to 0 will not be started.
    ...                - ``ue_id``: SA UE ID
    ...                - ``target_gnb``: Target GNB ID, Default: 2
    ...                - ``target_gnb_cell``: Target cell in GNB, Default: 1
    ...                - ``dl_tput``: Downlink throughput with unit (bps/kbps/mbps) or OFF, Default: 10mbps
    ...                - ``ul_tput``: Uplink throughput with unit (bps/kbps/mbps) or OFF, Default: 10mbps
    [Arguments]    ${ue_id}    ${target_gnb}=2    ${target_gnb_cell}=1    ${dl_tput}=10mbps    ${ul_tput}=10mbps
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${target_gnb}) is int    msg=Invalid KW parameter: target_gnb
    Should Be True    type(${target_gnb_cell}) is int    msg=Invalid KW parameter: target_gnb_cell
    Should Match Regexp    ${dl_tput}    ^OFF$|^[1-9][0-9]*[km]?bps$    msg=Invalid KW parameter: dl_tput
    Should Match Regexp    ${ul_tput}    ^OFF$|^[1-9][0-9]*[km]?bps$    msg=Invalid KW parameter: ul_tput
    #---------------------------------------------------------------------------------------------------------------
    NSA UE Attach    ue_id=${ue_id}
    NSA LTE-NR Dual Connectivity    ue_id=${ue_id}    target_gnb=${target_gnb}    target_cell=${target_gnb_cell}
    Run Keyword If    '${dl_tput}' != 'OFF'    Start Internal NSA Downlink Traffic    ue_id=${ue_id}    tput=${dl_tput}
    Run Keyword If    '${ul_tput}' != 'OFF'    Start Internal NSA Uplink Traffic    ue_id=${ue_id}    tput=${ul_tput}

Stop SA L3 Call
    [Documentation]    Stops L3 Call for specified SA UE.
    ...                - ``ue_id``: SA UE ID
    ...                - ``pdu_id``:  PDU Session ID, Default: same as UE ID
    [Arguments]    ${ue_id}    ${pdu_id}=${ue_id}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${pdu_id}) is int    msg=Invalid KW parameter: pdu_id
    #---------------------------------------------------------------------------------------------------------------
    Stop Internal SA Traffic    ue_id=${ue_id}    pdu_id=${pdu_id}
    SA UE Deregister    ue_id=${ue_id}

Stop NSA L3 Call
    [Documentation]    Stops L3 Call for specified NSA UE.
    ...                - ``ue_id``: NSA UE ID
    [Arguments]    ${ue_id}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    #---------------------------------------------------------------------------------------------------------------
    Stop Internal NSA Traffic    ue_id=${ue_id}
    NSA UE Detach    ue_id=${ue_id}

Setup SA UE and Expect Measurement Event Config
    [Documentation]    Setups SA UE expecting specified Measurement Event in rrcReconfiguration message.
    ...                - ``ue_id``: SA UE ID
    ...                - ``event``: Measurement Event
    [Arguments]    ${ue_id}    ${event}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Match Regexp    ${event}    ^(A[1-6]|B[12])$    msg=Invalid KW parameter: event
    #---------------------------------------------------------------------------------------------------------------
    SA UE Register    ue_id=${ue_id}
    PDU Session Setup    ue_id=${ue_id}    should_contain=eventId event${event}

SA UE Register
    [Documentation]    Performs ``ue_register`` egate procedure for SA UE and adds UE ID for tracking in test scope.
    ...                Returns egate print.
    ...                - ``ue_id``: SA UE ID
    ...                - ``pass_regexp``: Alternative pass regexp, Default: standard
    ...                - ``fail_regexp``: Alternative fail regexp, Default: standard
    ...                - ``timeout``: Timeout for confirmation, Default: 30s
    ...                - ``should_contain``: List or single regexp pattern that command output should contain,\
    ...                Default: None
    ...                - ``params``: Extra parameters for egate command
    [Arguments]    ${ue_id}    ${fail_regexp}=${STD_UE_ATTACH_FAIL}    ${timeout}=30s
    ...    ${pass_regexp}=Received REGISTRATION COMPLETE from UE
    ...    ${should_contain}=@{Empty}    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Set Variable    ue_register id=${ue_id}
    ${log_msg}    Set Variable    Registering UE-${ue_id}
    ${ue_id}    Convert To String    ${ue_id}
    Run Keyword If    not '${ue_id}' in ${TEST_SA_UEs}    Append To List    ${TEST_SA_UEs}    ${ue_id}
    ${output}    Execute Egate Command Ext
    ...    cmd=${cmd}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}    timeout=${timeout}
    ...    should_contain=${should_contain}    log_msg=${log_msg}    &{params}
    [Return]    ${output}

SA UE Deregister
    [Documentation]    Performs ``ue_deregister`` egate procedure for SA UE.
    ...                Returns egate print.
    ...                - ``ue_id``: SA UE ID
    ...                - ``ue_deregister_type``: Type of UE initiated deregister procedure, Default: switch_off
    ...                - ``pass_regexp``: Alternative pass regexp, Default: standard
    ...                - ``fail_regexp``: Alternative fail regexp, Default: None
    ...                - ``timeout``: Timeout for confirmation, Default: 30s
    ...                - ``should_contain``: List or single regexp pattern that command output should contain,\
    ...                Default: None
    ...                - ``params``: Extra parameters for egate command
    [Arguments]    ${ue_id}    ${ue_deregister_type}=switch_off    ${fail_regexp}=${None}    ${timeout}=30s
    ...    ${pass_regexp}=UE${ue_id}: detached
    ...    ${should_contain}=@{Empty}    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Set Variable    ue_deregister id=${ue_id} ue_deregister_type=${ue_deregister_type}
    ${log_msg}    Set Variable    Deregistering UE-${ue_id}
    ${output}    Execute Egate Command Ext
    ...    cmd=${cmd}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}    timeout=${timeout}
    ...    should_contain=${should_contain}    log_msg=${log_msg}    &{params}
    ${ue_id}    Convert To String    ${ue_id}
    Remove Values From List    ${TEST_SA_UEs}    ${ue_id}
    [Return]    ${output}

PDU Session Setup
    [Documentation]    Performs ``ue_pdu_session_setup`` egate procedure for SA UE.
    ...                If PDU Gateway ID is not specified traffic type is set to internal.
    ...                Returns egate print.
    ...                - ``ue_id``: SA UE ID
    ...                - ``pdu_id``: Optional PDU Session ID, Default: same as UE ID
    ...                - ``gw_id``: Optional PDU Gateway ID, Default: not used
    ...                - ``nwslice``: Requested Network Slice ID, Default: 1
    ...                - ``pass_regexp``: Alternative pass regexp, Default: standard
    ...                - ``fail_regexp``: Alternative fail regexp, Default: None
    ...                - ``timeout``: Timeout for confirmation, Default: 30s
    ...                - ``should_contain``: List or single regexp pattern that command output should contain,\
    ...                Default: None
    ...                - ``params``: Extra parameters for egate command
    [Arguments]    ${ue_id}    ${pdu_id}=${ue_id}    ${gw_id}=${Empty}    ${nwslice}=1
    ...    ${fail_regexp}=${None}    ${timeout}=30s
    ...    ${pass_regexp}=QoS Routing Table
    ...    ${should_contain}=@{Empty}    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${nwslice}) is int    msg=Invalid KW parameter: nwslice
    Should Be True    type(${pdu_id}) is int   msg=Invalid KW parameter: pdu_id
    Should Be True    '${gw_id}' == '' or type(${gw_id}) is int    msg=Invalid KW parameter: gw_id
    #---------------------------------------------------------------------------------------------------------------
    Run Keyword If    '${gw_id}' == ''
    ...    Execute Egate Command Ext    cmd=set_pdu_param ue=${ue_id} pdu=${pdu_id} trf_type=internal
    ...    log_msg=Setting UE-${ue_id} PDU-${pdu_id} Session traffic to internal
    ${gw}    Set Variable If    '${gw_id}' == ''    ${Empty}    gw=${gw_id}
    ${cmd}    Set Variable    ue_pdu_session_setup ue=${ue_id} pdu=${pdu_id} ${gw} nwslice=${nwslice}
    ${log_msg}    Set Variable    Establishing PDU-${pdu_id} Session for UE-${ue_id}
    ${output}    Execute Egate Command Ext
    ...    cmd=${cmd}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}    timeout=${timeout}
    ...    should_contain=${should_contain}    log_msg=${log_msg}    &{params}
    [Return]    ${output}

NSA UE Attach
    [Documentation]    Performs ``ue_attach`` egate procedure for NSA UE.
    ...                Returns egate print.
    ...                - ``ue_id``: NSA UE ID
    ...                - ``pass_regexp``: Alternative pass regexp, Default: standard
    ...                - ``fail_regexp``: Alternative fail regexp, Default: standard
    ...                - ``timeout``: Timeout for confirmation, Default: 30s
    ...                - ``should_contain``: List or single regexp pattern that command output should contain,\
    ...                Default: None
    ...                - ``params``: Extra parameters for egate command
    [Arguments]    ${ue_id}    ${fail_regexp}=${STD_UE_ATTACH_FAIL}    ${timeout}=30s
    ...    ${pass_regexp}=UE${ue_id}:.*UE IS ACTIVE
    ...    ${should_contain}=@{Empty}    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Set Variable    ue_attach id=${ue_id}
    ${log_msg}    Set Variable    Attaching UE-${ue_id}
    ${ue_id}    Convert To String    ${ue_id}
    Run Keyword If    not '${ue_id}' in ${TEST_NSA_UEs}    Append To List    ${TEST_NSA_UEs}    ${ue_id}
    ${output}    Execute Egate Command Ext
    ...    cmd=${cmd}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}    timeout=${timeout}
    ...    should_contain=${should_contain}    log_msg=${log_msg}    &{params}
    [Return]    ${output}

NSA UE Detach
    [Documentation]    Performs ``ue_detach`` egate procedure for NSA UE.
    ...                Returns egate print.
    ...                - ``ue_id``: NSA UE ID
    ...                - ``pass_regexp``: Alternative pass regexp, Default: standard
    ...                - ``fail_regexp``: Alternative fail regexp, Default: None
    ...                - ``timeout``: Timeout for confirmation, Default: 30s
    ...                - ``should_contain``: List or single regexp pattern that command output should contain,\
    ...                Default: None
    ...                - ``params``: Extra parameters for egate command
    [Arguments]    ${ue_id}    ${fail_regexp}=${None}    ${timeout}=30s
    ...    ${pass_regexp}=UE${ue_id}: detached
    ...    ${should_contain}=@{Empty}    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Set Variable    ue_detach id=${ue_id}
    ${log_msg}    Set Variable    Detaching UE-${ue_id}
    ${output}    Execute Egate Command Ext
    ...    cmd=${cmd}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}    timeout=${timeout}
    ...    should_contain=${should_contain}    log_msg=${log_msg}    &{params}
    ${ue_id}    Convert To String    ${ue_id}
    Remove Values From List    ${TEST_NSA_UEs}    ${ue_id}
    [Return]    ${output}

NSA LTE-NR Dual Connectivity
    [Documentation]    Performs ``enb_ue_dc_start`` egate procedure for NSA UE.
    ...                Returns egate print.
    ...                - ``ue_id``: NSA UE ID
    ...                - ``target_gnb``: Target GNB ID, Default: 2
    ...                - ``target_cell``: Target Cell ID in GNB, Default: 1
    ...                - ``bearer_id``: Bearer ID, Default: 2
    ...                - ``pass_regexp``: Alternative pass regexp, Default: standard
    ...                - ``fail_regexp``: Alternative fail regexp, Default: standard
    ...                - ``timeout``: Timeout for confirmation, Default: 30s
    ...                - ``should_contain``: List or single regexp pattern that command output should contain,\
    ...                Default: None
    ...                - ``params``: Extra parameters for egate command
    [Arguments]    ${ue_id}    ${target_gnb}=2    ${target_cell}=1    ${bearer_id}=2    ${type}=split_scg
    ...    ${fail_regexp}=${STD_UE_ATTACH_FAIL}    ${timeout}=30s
    ...    ${pass_regexp}=UE${ue_id}: Proxy \\(eNB ${target_gnb} cell ${target_cell}\\) reported successful RA
    ...    ${should_contain}=@{Empty}    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${target_gnb}) is int    msg=Invalid KW parameter: target_gnb
    Should Be True    type(${target_cell}) is int    msg=Invalid KW parameter: target_cell
    Should Be True    type(${bearer_id}) is int    msg=Invalid KW parameter: bearer_id
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Catenate
    ...    enb_ue_dc_start target_gnb=${target_gnb} target_cells=${target_cell}
    ...    ue=${ue_id} bearer=${bearer_id} type=${type}
    ${log_msg}    Set Variable    Establishing LTE-NR DC for UE-${ue_id}
    ${output}    Execute Egate Command Ext
    ...    cmd=${cmd}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}    timeout=${timeout}
    ...    should_contain=${should_contain}    log_msg=${log_msg}    &{params}
    [Return]    ${output}

Change UE Location
    [Documentation]    Changes UE location to target GNB/ENB and cell.
    ...                UE needs to be in OFF state.
    ...                - ``ue_id``: UE ID
    ...                - ``node_id``: Target GNB/ENB ID
    ...                - ``cell_id``: Target cell ID
    [Arguments]    ${ue_id}    ${node_id}    ${cell_id}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    Should Be True    type(${node_id}) is int    msg=Invalid KW parameter: node_id
    Should Be True    type(${cell_id}) is int    msg=Invalid KW parameter: cell_id
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Set Variable    ue_change_location id=${ue_id} enb=${node_id} cell=${cell_id}
    ${pass_regexp}    Set Variable    already there|location updated to
    ${log_msg}    Set Variable    Changing location of UE-${ue_id} to Cell ${node_id}.${cell_id}
    Execute Egate Command Ext    cmd=${cmd}    pass_regexp=${pass_regexp}    log_msg=${log_msg}

Perform UE RRC Reestablishment
    [Documentation]    Performs ``ue_rrc_reestablish`` egate procedure for UE. Returns egate print.
    ...                - ``ue_id``: UE ID
    ...                - ``pass_regexp``: Alternative pass regexp, Default: standard
    ...                - ``fail_regexp``: Alternative fail regexp, Default: standard
    ...                - ``timeout``: Timeout for confirmation, Default: 30s
    ...                - ``should_contain``: List or single regexp pattern that command output should contain,\
    ...                Default: None
    ...                - ``params``: Extra parameters for egate command
    [Arguments]    ${ue_id}    ${fail_regexp}=${STD_UE_ATTACH_FAIL}    ${timeout}=30s
    ...    ${pass_regexp}=UE${ue_id}: NR RRC Reestablishment sucessfully completed
    ...    ${should_contain}=@{Empty}    &{params}
    #--------- Param check -----------------------------------------------------------------------------------------
    Should Be True    type(${ue_id}) is int    msg=Invalid KW parameter: ue_id
    #---------------------------------------------------------------------------------------------------------------
    ${cmd}    Set Variable    ue_rrc_reestablish id=${ue_id}
    ${log_msg}    Set Variable    Performing RRC Reestablishment with UE-${ue_id}
    ${output}    Execute Egate Command Ext
    ...    cmd=${cmd}    pass_regexp=${pass_regexp}    fail_regexp=${fail_regexp}    timeout=${timeout}
    ...    should_contain=${should_contain}    log_msg=${log_msg}    &{params}
    [Return]    ${output}

Detach All UEs
    [Documentation]    Detaches all UEs attached via Register/Attach/Start Call keywords and expects success.
    ...                Uses $\{TEST_SA_UEs\} and $\{TEST_NSA_UEs\} test variables for determining SA/NSA mode of UE.
    FOR    ${ue_id}    IN    @{TEST_SA_UEs}
      SA UE Deregister    ue_id=${ue_id}
    END
    FOR    ${ue_id}    IN    @{TEST_NSA_UEs}
      NSA UE Detach    ue_id=${ue_id}
    END

Detach Active or Idle UEs Forcefully
    [Documentation]    Detaches remaining active or idle SA and NSA UEs forcefully.
    ...                Uses $\{TEST_SA_UEs\} and $\{TEST_NSA_UEs\} test variables for determining SA/NSA mode of UE.
    ${active_ues}    Get IDs of Attached UEs From Egate
    Return From Keyword If    ${active_ues} == []
    Log    ${TEST NAME}: Active or Idle UEs remaining after test, detaching forcefully.    level=WARN
    FOR    ${ue_id}    IN    @{active_ues}
      Run Keyword If    '${ue_id}' in ${TEST_SA_UEs}
      ...    SA UE Deregister    ue_id=${ue_id}    pass_regexp=${None}
      ...    ELSE IF    '${ue_id}' in ${TEST_NSA_UEs}
      ...    NSA UE Detach    ue_id=${ue_id}    pass_regexp=${None}
      ...    ELSE
      ...    Fail
      ...    msg=Unknown UE-${ue_id} active in egate.${\n}Known SA UEs: ${TEST_SA_UEs}${\n}Known NSA UEs: ${TEST_NSA_UEs}
    END
    Sleep    2s    Wait for UEs to complete detach
    ${active_ues}    Get IDs of Attached UEs From Egate
    Should Be Empty    ${active_ues}    msg=Could not successfully detach remaining active UEs.
