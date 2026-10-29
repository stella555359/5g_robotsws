*** Settings ***
Documentation
...     Set of keywords using to prepare ue and run throughput on its

Library    BuiltIn
Library    Collections
Library    taf.ue


*** Keywords ***
Prepare UEs
    [Arguments]  ${MULTI_capabilities}    ${attach}=${True}  ${expected_cell_id}=${False}    ${detach}=${False}
    Log    --- Start preparing ues ---    console=True
    ${UE_alias}=  Get required ues  ${MULTI_capabilities}
    Run Keyword If    ${attach}    Attach ues  ${UE_alias}    ${expected_cell_id}    ${detach}
    Run Keyword If    ${detach}    Detach ues  ${UE_alias}    #${detach}
    Log    --- Ues prepared ---    console=True
    [Return]    ${UE_alias}

Get required ues
    [Arguments]  ${MULTI_capabilities}
    FOR  ${key}  IN  @{MULTI_capabilities}
        Log    --- Require ue: ${MULTI_capabilities}[${key}] ${key} ---    console=True
        taf.ue.Require UE  ${MULTI_capabilities}[${key}]  capabilities=${key}
    END
    ${UE_alias}=  Get Dictionary Values  ${MULTI_capabilities}
    Log    --- UE: ${UE_alias} required ---    console=True
    [Return]  ${UE_alias}

Attach ues
    [Arguments]  ${UE_alias}    ${expected_cell_id}=${False}    ${detach}=${False}
    ${is_list}=    Evaluate     (type($UE_alias).__name__)
    ${is_list}=    Evaluate     type($UE_alias).__name__=='list'
    ${UE_alias}=    Run Keyword If    ${is_list}==${False}    Create List    ${UE_alias}    ELSE    Set Variable    ${UE_alias}
    Run Keyword If    ${detach}    Detach ues    ${UE_alias}
    FOR  ${ue}  IN  @{UE_alias}
        Log    --- Start attaching ue: ${ue} ---    console=True
        taf.ue.Attach UE  ${ue}    #timeout=20s
        Log    --- ${ue} attached ---    console=True
        ${cell_id}=    taf.ue.Get UE Info    ${ue}    CELL_ID
        Run Keyword If    ${expected_cell_id}    Sleep    1s
        Run Keyword If    ${expected_cell_id}    Run Keywords    taf.ue.Validate UE Info
        ...    ${ue}    CELL_ID    ${expected_cell_id}    AND    Log    --- Ue info validated ---    console=True
    END

Detach ues
    [Arguments]  ${UE_alias}
    ${is_list}=    Evaluate     (type($UE_alias).__name__)
    ${is_list}=    Evaluate     type($UE_alias).__name__=='list'
    ${UE_alias}=    Run Keyword If    ${is_list}==${False}    Create List    ${UE_alias}    ELSE    Set Variable    ${UE_alias}
    FOR  ${ue}  IN  @{UE_alias}
        Log    --- Start detaching ue: ${ue} ---    console=True
        taf.ue.Detach UE  ${ue}
        Log    --- ${ue} detached ---    console=True
    END

Start Tput
    [Arguments]     ${ue}     ${dt_name}    ${tput_dl}=1200    ${tput_ul}=250    ${duration}=1200s    ${direction}=both    ${apn}=None
    Log    --- Start throughput procedure: ${ue} ---    console=True
    Run Keyword If    '${direction}'=='both' or '${direction}'=='dl'    Run Keywords
    ...    Log    --- Start DL data transfer on: ${ue} ---    console=True    AND
    ...    taf.ue.Start Data Transfer  dt_name=${dt_name}_dl
    ...    ue_alias=${ue}    direction=dl  duration=${duration}    throughput=${tput_dl} Mbits/sec     protocol=udp
    ...    packet=1400    apn=${apn}    AND
    ...    Log    --- DL data transfer started on: ${ue} ---    console=True
    Run Keyword If    '${direction}'=='both' or '${direction}'=='ul'    Run Keywords
    ...    Log    --- Start UL data transfer on: ${ue} ---    console=True    AND
    ...    taf.ue.Start Data Transfer  dt_name=${dt_name}_ul
    ...    ue_alias=${ue}  direction=ul  duration=${duration}    throughput=${tput_ul} Mbits/sec    apn=${apn}    AND
    ...    Log    --- UL data transfer started on: ${ue} ---    console=True
    Log    --- Throughput started on ${ue} ---    console=True
#    Sleep    10s
#    Run Keyword If    '${direction}'=='both' or '${direction}'=='dl'    Check Data Transfer Is Alive    ${dt_name}_dl
#    Run Keyword If    '${direction}'=='both' or '${direction}'=='ul'    Check Data Transfer Is Alive    ${dt_name}_ul

Stop Specific Data Transfer
    [Arguments]    ${dt_name}
    Log    --- Stopping ${dt_name} data transfer ---    console=True
    taf.ue.Stop Data Transfer     ${dt_name}
    Log    --- Data transfers for ${dt_name} stopped ---    console=True

Stop Data Transfer For All Ues
    Log    --- Stopping data transfer for all started transfers ---    console=True
    taf.ue.Stop Data Transfers For All Ues
    Log    --- Data transfers for all ues stopped ---    console=True

