*** Settings ***
Documentation    This resource file contains common keywords for DCM scenarios

Resource        ../../Resources/robot/suite_common_keywords.robot
Resource        ../../Resources/robot/ue_operations.robot
Resource        ../../Resources/robot/gnb.robot
Resource        ../../Resources/robot/oam_operations.robot
Library         ../../Resources/Python/AdminHelper.py    WITH NAME    admin_helper


*** Variables ***
${simmode_active}    SimMode is ready now
${NSA_CONFIGURATION}    False
${NEW_CFG_FORMAT}    False

${success_ng_link_pattern}         AMF Found
${success_cell_setup_pattern}      Cell Setup Found
${nsa_x2_connections_script_complete}    NSA_x2_connections script completed
${start_cell}                      1
${SIB_Timeout}    60
${SCRIPT_COMPLETE_WAIT_TIME}       120min

${X2LINK_SEQ_FUNC}    x2_connections

*** Keyword ***
Test Setup for DCM
    [Arguments]     ${TC_dictionary}    ${feature}    &{kwargs}
    Set Suite Variable    ${IS_ORAN}    True
    Fetch Dictionary items    ${TC_dictionary}
    Wait Until Keyword Succeeds     3min     1min     admin_helper.Configure Default Netconf Account
    Configure IPs needed for FR2
    Basic Test Setup    ${feature}    &{kwargs}
    Start WTS
    Check for Cell Setup SIB and Ng Link

Configure IPs needed for FR2
    Run and return rc and output     sudo ip addr add 10.0.2.102/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.2.102/24 dev eth4
    Run and return rc and output     sudo ip addr add 10.0.2.100/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.2.100/24 dev eth4
    Run and return rc and output     sudo ip addr add 10.0.2.101/24 dev eth3
    Run and return rc and output     sudo ip addr add 10.0.2.101/24 dev eth4

Fetch Dictionary items
    [Arguments]    ${dictionary_name}
    ${status}   ${items}=     Run Keyword And Ignore Error    Get Dictionary Items   ${dictionary_name}
    Log To Console    ${status}
    FOR    ${key}    ${value}    IN    @{items}
        Set Suite Variable    ${${key}}    ${value}
    END

Start WTS
    [Documentation]    Kill running WTS binaries if any, configure ETH3, retrieve files and configure WTS SIM
    Stop Edaemon Egate
    Connect To WTS VM
    Run    cd /opt/wts/latest && ulimit -c unlimited && sudo bash -c 'echo "core_%e.%p" > /proc/sys/kernel/core_pattern'
    ute_wtssim.Setup Edaemon    edaemon_port=${EDAEMON_PORT}    tool_dir=${WTS_INSTALL_PATH}    alias=edaemon
    ute_wtssim.Start Edaemon Process    alias=edaemon
    ute_wtssim.Setup Egate    egate_port=${EGATE_PORT}    tool_dir=${WTS_INSTALL_PATH}
    ute_wtssim.Start Egate Process
    ${ls_cfg}    Run    ls ${WTS_INSTALL_PATH}/*cfg
    ${ls_lua}    Run    ls ${WTS_INSTALL_PATH}/*lua
    Log To Console    ${ls_cfg }
    Log To Console    ${ls_lua}
    ${wts_lua_command}=    Set Variable    cfg_sim file=/opt/wts/latest/sansa.lua entry=run_configuration(${timer})
    ute_wtssim.Execute Egate Command    ${wts_lua_command}    timeout=10minutes
    Wait Until Keyword Succeeds    5min    30s    Check Occurances from Egate Console    ${simmode_active}    1
    Log to console     WTS Started

Connect To WTS VM
    [Documentation]    Establish a ssh connection to the WTS machine where the simulator is present
    SSH.Connect To        127.0.0.1    ute    ute    alias=local
    ${command}        Catenate    sysctl -w net.sctp.sack_timeout=20 &&
    ...               sysctl -w net.sctp.rto_min=400 &&
    ...               sysctl -w net.sctp.rto_initial=400 &&
    ...               sysctl -w net.sctp.rto_max=800
    Run               ${command}
    Run               cat /proc/sys/net/sctp/rto_min

Stop Edaemon Egate
    [Documentation]    Kill edaemon and egate if already running.
    ${edaemon_pid}=    Run    pgrep edaemon
    ${edaemon_status}    Run Keyword and Return Status    Should Not Be Empty    ${edaemon_pid}
    Run Keyword If    ${edaemon_status}    Run    sudo pkill -9 edaemon
    ${egate_pid}=    Run    pgrep egate
    ${egate_status}    Run Keyword and Return Status    Should Not Be Empty    ${egate_pid}
    Run Keyword If    ${egate_status}    Run    sudo pkill -9 egate
    Run Keyword If    ${edaemon_status} or ${egate_status}    sleep      5s

Check Occurances from Egate Console
    [Arguments]    ${pattern}    ${expected_occurances}
    Ensure Egate Console Log Available
    ute_wtssim.Execute Egate Command    set_log flush
    ${file}=    Set Variable    egate_console.log
    ${grepArgs}    Set Variable    find /opt/wts/latest/ -iname '${file}' -exec grep -m ${expected_occurances}
    ${command}    Catenate    ${grepArgs}    '${pattern}'    {} \\;    |    wc -l
    ${result}     Run    ${command}
    Should Be Equal    ${result}     ${expected_occurances}    msg=Error Found in Egate Logs: ${pattern} Not Found

Check NgLink and Cell Setup
    ${wts_lua_command}=    Set Variable    cfg_sim file=/opt/wts/latest/sansa.lua entry=run_configuration(${timer})
    ute_wtssim.Execute Egate Command And Wait For Data    ${wts_lua_command}    pass_regexp=NG link is Up    timeout=10minutes

Ensure Egate Console Log Available
    [Documentation]    [Documentation]    Checks if Egate console log exists and is updated within the expected time.
    ${egate_found}=    Get Variable Value    ${EGATE_LOG_FOUND}    False
    Run Keyword If    ${egate_found}    Return From Keyword

    FOR    ${i}    IN RANGE    30
        ${found}=    Run    /bin/sh -c "find /opt/wts/latest/ -type f -iname 'egate_console*' -print -quit || true"
        ${found_stripped}=    Strip String    ${found}

        IF    '${found_stripped}' != ''
            Log To Console    Egate console log found: ${found_stripped}
            Set Suite Variable    ${EGATE_LOG_FOUND}    True
            Return From Keyword
        END
        Sleep    10s
    END
    Fatal Error    Egate console log not found or not updated within the expected time limit.

Check Ng link
    ${AMF_PAIR}=    Catenate    SEPARATOR=,    1    ${AMF_COUNT}
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data
    ...    script file\=/opt/wts/latest/multi_ue_sa_script_new.lua entry\=check_NgLInk(${AMF_PAIR})
    ...    pass_regexp=Ng Link Check Script Completed    timeout=600
    Log To Console    Config file loaded successfully for checking Ng Link
    Wait Until Keyword Succeeds    5mins    30secs    Check Occurances from Egate Console    ${success_ng_link_pattern}    ${AMF_COUNT}

Check Cells Setup
    ${Cell_Count}=    Catenate    SEPARATOR=,    1    ${NO_OF_CELLS}
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data
    ...    script file\=/opt/wts/latest/multi_ue_sa_script_new.lua entry\=check_CellSetup(${Cell_Count})
    ...    pass_regexp=Cell Setup Check Script Completed    timeout=600
    Log To Console    Config file loaded successfully for checking Cell Setup
    ${status}=    Run Keyword And Continue on Failure    Wait Until Keyword Succeeds    5mins    30secs
    ...    Check Occurances from Egate Console    ${success_cell_setup_pattern}    ${NO_OF_CELLS}

Check SIB Messages
    [Arguments]    ${cells}
    ...    ${command}=grep "Number of Expected SIBs" /opt/wts/latest/egate_console.log | tr "|" "\n"
    ${output}=    ute_wtssim.Execute Egate Command And Wait For Data
    ...    script file\=/opt/wts/latest/multi_ue_sa_script_new.lua entry\=check_SIBs_withUECcount(${start_cell},${cells},${UEC_COUNT})
    ...    pass_regexp=Total SIBs received    timeout=${SIB_TIMEOUT}
    ${result}     Run    ${command}
    ${result_list}=    Create List    ${result.split("\n")}
    @{expected_SIB}=    Split String    ${result_list[0][2]}    :
    @{received_SIB}=    Split String    ${result_list[0][3]}    :
    Should Be Equal As Integers    ${expected_SIB[1]}    ${received_SIB[1]}    msg=SIB not received

NSA ENBX2 Setup
    [Documentation]    Setting up of NSA ENBX2 connection
    ute_wtssim.Execute Egate Command
    ...    script file\=/opt/wts/latest/commands.lua entry\=${NSA_ENBX2_FUNC}
    ...    timeout=300

NSA ENBX2 Validate
    ${start}    ${end}=    Get NSA Enb Range From Func    ${NSA_ENBX2_FUNC}
    ${patterns}=    Generate NSA ENB Patterns    ${start}    ${end}
    FOR    ${nsa_pattern}    IN    @{patterns}
        Wait Until Keyword Succeeds    5min    10s    Check Occurances from Egate Console    ${nsa_pattern}    1
    END
    Wait Until Keyword Succeeds    3min    1min    Check Occurances from Egate Console    ${nsa_x2_connections_script_complete}    1

NSA ENBX2 Setup and Validation
    NSA ENBX2 Setup
    NSA ENBX2 Validate

Get NSA Enb Range From Func
    [Documentation]    Extracts the start and end eNB IDs from a function string like
    ...                "NSA_x2_connections(3,8)". Returns start and end as integers.
    [Arguments]    ${func}
    ${match}=    Evaluate    re.search(r"NSA_x2_connections\\((\\d+)(?:,\\s*(\\d+))?\\)", """${func}""")    re
    IF    $match is None
        Fail    Invalid function format: ${func}
    END
    ${start}=    Evaluate    int($match.group(1))    re
    ${end}=      Evaluate    int($match.group(2)) if $match.group(2) else int($match.group(1))    re
    [Return]    ${start}    ${end}

Generate NSA ENB Patterns
    [Documentation]    Generates a list of NSA ENB patterns based on the provided start and end values.
    [Arguments]    ${start}    ${end}
    ${patterns}=    Create List
    FOR    ${i}    IN RANGE    ${start}    ${end+1}
        ${pat}=    Set Variable    ENB-${i}: X2AP Link with GNB-2 \\(.*\\) is up
        Append To List    ${patterns}    ${pat}
    END
    [Return]    ${patterns}

Check for Cell Setup SIB and Ng Link
    [Documentation]    This KW is appplicable for all test cases other than DSS 2AP
    Sleep    5m
    ${ENBX2_FLAG}=    Run Keyword And Return Status    Variable Should Exist    ${NSA_ENBX2_FUNC}
    Run Keyword If    '${NSA_CONFIGURATION}' != 'True'    Check Ng link
    ${X2_LINK_UP}=    Run Keyword And Return Status    Variable Should Exist    ${X2_LINK}
    Run Keyword If    '${X2_LINK_UP}' == 'True'    NSA ENBX2 Setup
    Sleep    30s
    Check Cells Setup
    Sleep    15s
    Run Keyword If    '${NSA_CONFIGURATION}' != 'True'    Check SIB Messages    ${NO_OF_CELLS}
    Sleep    30s
    Run Keyword If    '${NSA_CONFIGURATION}' == 'True' and '${NEW_CFG_FORMAT}' == 'True'    X2 link via sim config
    ...    ELSE IF    '${ENBX2_FLAG}' == 'True' and '${NEW_CFG_FORMAT}' != 'True'   NSA ENBX2 Setup and Validation
    Sleep    30s

Initiate UE Register And Traffic
    [Arguments]    ${expected_occurances}=1
    ute_wtssim.Execute Egate Command
    ...    script file\=/opt/wts/latest/commands.lua entry\=${test_entry}
    ...    timeout=300
    ${SCRIPT_COMPLETE}=    Catenate    ${test_entry}    script completed
    Wait Until Keyword Succeeds    ${SCRIPT_COMPLETE_WAIT_TIME}    1min    Check Occurances from Egate Console
    ...    ${SCRIPT_COMPLETE}    ${expected_occurances}

X2 link via sim config
    [Documentation]    Common x2 link called via sim_config.lua file
    ute_wtssim.Execute Egate Command
    ...    script file\=/opt/wts/latest/sim_config.lua entry\=${X2LINK_SEQ_FUNC}(sim_data)
    ...    timeout=300

Check SystemInformationBlockType Updates In Egate Log
    [Documentation]    Check if SystemInformationBlockType updates are present in egate console log
    [Arguments]    ${uec_id}    ${expected_count}=${EMPTY}     ${diff_sib1_sib2_count}=False
    ute_wtssim.Execute Egate Command    set_log flush
    ${log_content}=    Run    cat /opt/wts/latest/egate_console.log
    ${original_expected_count}=    Set Variable    ${expected_count}
    FOR    ${block_type}    IN RANGE    1    6
        ${pattern}=    Set Variable    UEC-${uec_id}:.*SystemInformationBlockType${block_type}-NR updated
        ${matches}=    Get Regexp Matches    ${log_content}    ${pattern}
        ${match_count}=    Get Length    ${matches}
        ${expected_count_for_block}    Run Keyword If    '${original_expected_count}' != '${EMPTY}'
        ...    Evaluate    ${original_expected_count} - 1 if ${diff_sib1_sib2_count} and ${block_type} != 1 else ${original_expected_count}
        Run Keyword If    '${expected_count_for_block}' != '${None}'
        ...    Should Be Equal As Integers    ${match_count}    ${expected_count_for_block}
        ...    ELSE    Should Be True    ${match_count} > 0
        Log    Found ${match_count} SystemInformationBlockType${block_type} updates for UEC-${uec_id}
    END

Check All SystemInformationBlockType Updates
    [Documentation]    Check for all SystemInformationBlockType updates (Type1, Type2, Type3, Type4, Type5)
    [Arguments]    ${expected_sib_count}=${EMPTY}     ${diff_sib1_sib2_count}=False
    FOR     ${uec_id}    IN RANGE    1    7
        Check SystemInformationBlockType Updates In Egate Log    uec_id=${uec_id}    expected_count=${expected_sib_count}
        ...    diff_sib1_sib2_count=${diff_sib1_sib2_count}
    END
