# Copyright (c) 2021 Nokia. All rights reserved.

*** Settings ***
Documentation
...    Team: 'MN RAN RD VRF ULM 6'
...    Email: 'ou_mn_ran_rd_vrf_ulm_6_53244963@internal.nsn.com'
...    Description: Common tools for MN RAN RD VRF ULM 6

Library         Collections
Library         OperatingSystem
Library         taf.transport.ssh                            WITH NAME    ssh

Resource        ../../../resources/Common/wts_ue.robot

*** Keywords ***

Btslog Should Match Regexp
    [Arguments]    ${pattern}    ${bts_log_path}=/tmp/btslog2/syslog_files.tgz
    ${core_alias}     Connect To Core
    ${output}         Ssh.Execute    command=tmpfile=$(ls ${bts_log_path}); zgrep -a -e "${pattern}" "$tmpfile"
    ...                              connection=${core_alias}
    Should Match Regexp    ${output}    ${pattern}    msg=Pattern [${pattern}] is not present on Btslog!

Wait Until Btslog Pattern Appears
    [Arguments]    ${pattern}    ${bts_log_path}=/tmp/btslog2/SYSLOG_*.LOG| tail -1   ${timeout}=1 min    ${interval}=10 sec
    BuiltIn.Log    Wait until Btslog Pattern Appears:${pattern}, ${bts_log_path}    console=${False}
    Wait Until Keyword Succeeds
    ...    ${timeout}    ${interval}
    ...    Btslog Should Match Regexp    ${pattern}    bts_log_path=${bts_log_path}

Egate Console Log Should Match Regexp
    [Arguments]       ${regex}    ${msg}=${None}    ${flush}=${TRUE}
    IF    ${flush}    wts_ue.Sim Log Set Flush

    ${egate_log}      Run   grep -HniE '${regex}' ${tl.core.dir_path}/egate_console.log
    Should Match Regexp    ${egate_log}    ${regex}    msg=${msg}

Copy Files To Wts Dir Path
    [Arguments]    ${source_dir}    ${wts_cfg_filename}
    ${wts_config_path}           Catenate    /opt/iphy/latest/${wts_cfg_filename}
    ${test_wts_config_path}      Catenate    ${source_dir}${/}${wts_cfg_filename}
    OperatingSystem.Copy File    ${test_wts_config_path}     ${wts_config_path}

Initialize Dictionary Parameters
    [Documentation]     Former name: Initialize Suite Parameter
    ...                 Modifies the value of dictionary if the keys are found in the suite variables
    ...                     returns a new dictionary
    ...                 Useful for -v / --variable in robot command line
    [Arguments]    ${dictionary_name}=TSP
    ${suite_variables}=  Get Variables
    Log To Console                \nSuite Parameters:
    FOR   ${key}   IN   @{${dictionary_name}}
        ${value}   Collections.Get From Dictionary   ${${dictionary_name}}   ${key}
        ${tmp}=    Set Variable If    "\${${key}}" not in $suite_variables    ${value}    ${${key}}
        Set To Dictionary    ${${dictionary_name}}    ${key}    ${tmp}
        Log To Console    - ${key}: ${tmp}
    END
    Set Suite Variable    ${${dictionary_name}}
    Log To Console                \n
