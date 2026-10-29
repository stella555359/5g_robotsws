*** Settings ***
Documentation    Author: Ming Shi
...              Contact: ming.shi@nokia-sbell.com
...    This is a test suite for the login page
...    RF block/unblock , cell block/unblock , BBU reset,gNB reset,cell reset, gnb block/unblock, reset, RF reset

Suite Setup            get_test_info

Suite Teardown

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/SiSo_common_keywords.robot
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/SiSo_common_keywords.py

*** Variables ***
${connection_name}    GNB_OAM
${epc_log_path}    /tmp/
${scf_file_path}    /opt/workspace/CRT/Master/SCF_file/
${tl_scf_file}    gNB1_Golden_SCF.xml
${test_info_path}    /opt/workspace/SCF/
${test_info_file}    SiSo_test_info.yml

*** Test Cases ***
[1]block_unblock_all_cells_case
    [Timeout]    1 hour
    [Setup]
    FOR    ${i}    IN RANGE    ${test_round}
        block unblock all cells action    gnb_index=${gnb_index}
    END
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    recover all cells via unblock    gnb_index=${gnb_index}

[1]lock_unlock_RMOD_case
    [Timeout]    2 hours
    [Setup]
    FOR    ${i}    IN RANGE    ${test_round}
       lock unlock RMOD action    gnb_index=${gnb_index}
    END
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    recover lock unlock RMOD    gnb_index=${gnb_index}

[1]site_reset_case
    [Timeout]    5 hours
    [Setup]
    FOR    ${i}    IN RANGE    ${test_round}
        site reset action    gnb_index=${gnb_index}
    END
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect snapshot after reset site    gnb_index=${gnb_index}

[1]soft_rat_reset_case
    [Timeout]    5 hours
    [Setup]
    FOR    ${i}    IN RANGE    ${test_round}
        rat reset action    reset_type=Soft    gnb_index=${gnb_index}
    END
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect snapshot after reset site    gnb_index=${gnb_index}




*** Keywords ***
get_test_info
    ${test_info}=    SiSo_common_keywords.get_info_from_file    file_path=${test_info_path}${test_info_file}
    Set Suite Variable    ${test_round}    ${test_info}[test_round]
    Set Suite Variable    ${gnb_index}    ${test_info}[gnb_index]


block unblock all cells action
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        ${upper_cell_type}    Run Keyword If    '${Length}' != '0'    Convert To Upper Case    ${cell_type}
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    Block all cells with BTS    rat=${upper_cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Check cell failed status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    AND    Sleep    5s
        ...    AND    Unblock all cells with BTS    rat=${upper_cell_type}
        ...    AND    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

reset all cells action
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Reset all cells with BTS
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

block unblock per cell action
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    block unblock per cell    action=block    cells_info=${cell_list}[cells]    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Check cell failed status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    AND    Sleep    5s
        ...    AND    block unblock per cell    action=unblock    cells_info=${cell_list}[cells]   cell_type=${cell_type}
        ...    AND    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

block unblock per cell
    [Arguments]    ${action}    ${cells_info}    ${cell_type}
    ${cell_length}=    Get Length    ${cells_info}[${cell_type}]
    FOR    ${cell_index}    IN RANGE    ${cell_length}
    Run Keyword If    '${action}' == 'block'
    ...    Block cell with BTS    dist_name=${cells_info}[${cell_type}][${cell_index}][id][configuration]
    ...    ELSE IF    '${action}' == 'unblock'
    ...    Unblock cell with BTS    dist_name=${cells_info}[${cell_type}][${cell_index}][id][configuration]
    END

reset per cell action
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    reset per cell    cells_info=${cell_list}[cells]   cell_type=${cell_type}
        ...    AND    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

reset per cell
    [Arguments]    ${cells_info}    ${cell_type}
    ${cell_length}=    Get Length    ${cells_info}[${cell_type}]
    FOR    ${cell_index}    IN RANGE    ${cell_length}
        Reset cell with BTS    cell_id=${cells_info}[${cell_type}][${cell_index}][id][internal]
    END

block unblock bts action
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Block BTS
    Sleep    5s
    Unblock BTS    timeout=${300}
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

block unblock rat action
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
   Block RAT with BTS    rat=NR
   Sleep    5s
   Unblock RAT with BTS    rat=NR
   ${cell_list}=    Get cell list info
   ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
   ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
   FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
       ${Length}=    Get Length    ${cells_info}[${cell_index}]
       Run Keyword If    '${Length}' != '0'    Run keywords
       ...    Check X2 link status from GNB
       ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
       ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
       ...    ELSE    Continue For Loop
   END
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        ${upper_cell_type}    Run Keyword If    '${Length}' != '0'    Convert To Upper Case    ${cell_type}
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    Block RAT with BTS    rat=${upper_cell_type}
        ...    AND    Sleep    5s
        ...    AND    Unblock RAT with BTS    rat=${upper_cell_type}
        ...    AND    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

lock unlock BBMOD action
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${bts_info}=    Get info with BTS
    ${basebandModules}    set variable    ${bts_info}[basebandModules]
    FOR    ${baseband}    IN    @{basebandModules}
        Lock required dist_name with BTS    dist_name=${baseband}[id][configuration]    connection=${connection_name}
    END
    Sleep    5s
    FOR    ${baseband}    IN    @{basebandModules}
        Unlock required dist_name with BTS    dist_name=${baseband}[id][configuration]    connection=${connection_name}
    END
    Sleep    2m
    ${check_result}=    check if ASOD or ASOE or ASOF or ASOG or ASOH testline    gnb_index=${gnb_index}
    Run Keyword If    ${check_result} == ${False}
    ...    Wait Until Keyword Succeeds    10min    10s    Check basebandModule status
    ...    ELSE    Log to console    Skip the status checking for ABIL as the blade type is ASOD or ASOE or ASOF or ASOG or ASOH
    Wait Until Keyword Succeeds    10min    10s    Check radioModule status
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

lock unlock RMOD action
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${bts_info}=    Get info with BTS
    ${radioModules}    set variable    ${bts_info}[radioModules][rmod]
    FOR    ${rmod}    IN    @{radioModules}
        Lock required dist_name with BTS    dist_name=${rmod}[id][configuration]    connection=${connection_name}
    END
    SLeep    5s
    FOR    ${rmod}    IN    @{radioModules}
        Unlock required dist_name with BTS    dist_name=${rmod}[id][configuration]    connection=${connection_name}
    END
    Sleep    2m
    Wait Until Keyword Succeeds    10min    10s    Check radioModule status
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

power reset action
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Power reset with BTS    connection=${connection_name}
    Sleep    2m
    Wait Until Keyword Succeeds    5min    10s    Check systemModule status
    ${check_result}=    check if ASOD or ASOE or ASOF or ASOG or ASOH testline    gnb_index=${gnb_index}
    Run Keyword If    ${check_result} == ${False}
    ...    Wait Until Keyword Succeeds    10min    10s    Check basebandModule status
    ...    ELSE    Log to console    Skip the status checking for ABIL as the blade type is ASOD or ASOE or ASOF or ASOG or ASOH
    Wait Until Keyword Succeeds    10min    10s    Check radioModule status
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

site reset action
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Reset with BTS    connection=${connection_name}
    Sleep    2m
    Wait Until Keyword Succeeds    5min    10s    Check systemModule status
    ${check_result}=    check if ASOD or ASOE or ASOF or ASOG or ASOH testline    gnb_index=${gnb_index}
    Run Keyword If    ${check_result} == ${False}
    ...    Wait Until Keyword Succeeds    10min    10s    Check basebandModule status
    ...    ELSE    Log to console    Skip the status checking for ABIL as the blade type is ASOD or ASOE or ASOF or ASOG or ASOH
    Wait Until Keyword Succeeds    10min    10s    Check radioModule status
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

reset site action
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Reset site with BTS    connection=${connection_name}
    Sleep    2m
    Wait Until Keyword Succeeds    5min    10s    Check systemModule status
    ${check_result}=    check if ASOD or ASOE or ASOF or ASOG or ASOH testline    gnb_index=${gnb_index}
    Run Keyword If    ${check_result} == ${False}
    ...    Wait Until Keyword Succeeds    10min    10s    Check basebandModule status
    ...    ELSE    Log to console    Skip the status checking for ABIL as the blade type is ASOD or ASOE or ASOF or ASOG or ASOH
    Wait Until Keyword Succeeds    10min    10s    Check radioModule status
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

reset BBMOD action
    [Arguments]    ${reset_type}    ${gnb_index}=${0}    ${force_radio_reset}=${False}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${bts_info}=    Get info with BTS
    ${basebandModules}    set variable    ${bts_info}[basebandModules]
    FOR    ${baseband}    IN    @{basebandModules}
        Reset Unit with BTS    dist_name=${baseband}[id][runtime]    reset_type=${reset_type}    connection=${connection_name}
        ...    force_radio_reset=${force_radio_reset}
    END
    Sleep    2m
    ${check_result}=    check if ASOD or ASOE or ASOF or ASOG or ASOH testline    gnb_index=${gnb_index}
    Run Keyword If    ${check_result} == ${False}
    ...    Wait Until Keyword Succeeds    10min    10s    Check basebandModule status
    ...    ELSE    Log to console    Skip the status checking for ABIL as the blade type is ASOD or ASOE or ASOF or ASOG or ASOH
    Wait Until Keyword Succeeds    10min    10s    Check radioModule status
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

reset RMOD action
    [Arguments]    ${reset_type}    ${gnb_index}=${0}    ${force_radio_reset}=${True}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${bts_info}=    Get info with BTS
    ${radioModules}    set variable    ${bts_info}[radioModules][rmod]
    FOR    ${rmod}    IN    @{radioModules}
        Reset Unit with BTS    dist_name=${rmod}[id][runtime]    reset_type=${reset_type}    connection=${connection_name}
        ...    force_radio_reset=${force_radio_reset}
    END
    Sleep    2m
    Wait Until Keyword Succeeds    10min    10s    Check radioModule status
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

reset GNSSE action
    [Arguments]    ${reset_type}    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${bts_info}=    Get info with BTS
    ${gnsses}    set variable    ${bts_info}[gnsse]
    FOR    ${gnsse}    IN    @{gnsses}
        Reset Unit with BTS    dist_name=${gnsse}[id][runtime]    reset_type=${reset_type}    connection=${connection_name}
    END
    Sleep    2m
    Wait Until Keyword Succeeds    5min    10s    Check systemModule status
    ${check_result}=    check if ASOD or ASOE or ASOF or ASOG or ASOH testline    gnb_index=${gnb_index}
    Run Keyword If    ${check_result} == ${False}
    ...    Wait Until Keyword Succeeds    10min    10s    Check basebandModule status
    ...    ELSE    Log to console    Skip the status checking for ABIL as the blade type is ASOD or ASOE or ASOF or ASOG or ASOH
    Wait Until Keyword Succeeds    10min    10s    Check radioModule status
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

rat reset action
    [Arguments]    ${reset_type}    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
   RAT reset with BTS    reset_type=${reset_type}    connection=${connection_name}
   Sleep    2m
   Wait Until Keyword Succeeds    5min    10s    Check systemModule status
   ${check_result}=    check if ASOD or ASOE or ASOF or ASOG or ASOH testline    gnb_index=${gnb_index}
   Run Keyword If    ${check_result} == ${False}
   ...    Wait Until Keyword Succeeds    10min    10s    Check basebandModule status
   ...    ELSE    Log to console    Skip the status checking for ABIL as the blade type is ASOD or ASOE or ASOF or ASOG or ASOH
   Wait Until Keyword Succeeds    10min    10s    Check radioModule status
   ${cell_list}=    Get cell list info
   ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
   ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
   FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
       ${Length}=    Get Length    ${cells_info}[${cell_index}]
       Run Keyword If    '${Length}' != '0'    Run keywords
       ...    Check X2 link status from GNB
       ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
       ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
       ...    ELSE    Continue For Loop
   END
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        ${upper_cell_type}    Run Keyword If    '${Length}' != '0'    Convert To Upper Case    ${cell_type}
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    RAT reset with BTS    rat_type=${upper_cell_type}    reset_type=${reset_type}    connection=${connection_name}
        ...    AND    Sleep    2m
        ...    AND    check per module status    gnb_index=${gnb_index}
        ...    AND    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

commissioning reset action
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    commissioning and check status    scf_file=${scf_file_path}${tl_scf_file}    timeout=${600}    connection=${connection_name}
    Sleep    2m
    Wait Until Keyword Succeeds    5min    10s    Check systemModule status
    ${check_result}=    check if ASOD or ASOE or ASOF or ASOG or ASOH testline    gnb_index=${gnb_index}
    Run Keyword If    ${check_result} == ${False}
    ...    Wait Until Keyword Succeeds    10min    10s    Check basebandModule status
    ...    ELSE    Log to console    Skip the status checking for ABIL as the blade type is ASOD or ASOE or ASOF or ASOG or ASOH
    Wait Until Keyword Succeeds    10min    10s    Check radioModule status
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}


lock unlock per cell action
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
   ${bts_info}=    Get info with BTS
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
   ${cells_info}=    Get cells info with BTS
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    lock unlock per cell    action=lock    cells_info=${cell_list}[cells]    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Check cell failed status after lock    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    AND    Sleep    5s
        ...    AND    lock unlock per cell    action=unlock    cells_info=${cell_list}[cells]   cell_type=${cell_type}
        ...    AND    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

lock unlock per cell
    [Arguments]    ${action}    ${cells_info}    ${cell_type}
    ${cell_length}=    Get Length    ${cells_info}[${cell_type}]
    FOR    ${cell_index}    IN RANGE    ${cell_length}
    Run Keyword If    '${action}' == 'lock'
    ...    Lock required dist_name with BTS    dist_name=${cells_info}[${cell_type}][${cell_index}][id][configuration]
    ...    ELSE IF    '${action}' == 'unlock'
    ...    Unlock required dist_name with BTS    dist_name=${cells_info}[${cell_type}][${cell_index}][id][configuration]
    END

recover rat via unblock rat
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Save snapshot with BTS    connection=${connection_name}
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    Unblock RAT with BTS    rat=NR
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run Keywords
        ...    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

recover bts via unblock bts
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Save snapshot with BTS    connection=${connection_name}
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    Unblock BTS    timeout=${300}
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run Keywords
        ...    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

recover all cells via unblock
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Save snapshot with BTS    connection=${connection_name}
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        ${upper_cell_type}    Run Keyword If    '${Length}' != '0'    Convert To Upper Case    ${cell_type}
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    Unblock all cells with BTS    rat=${upper_cell_type}
        ...    AND    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

recover all cells via unlock
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Save snapshot with BTS    connection=${connection_name}
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    lock unlock per cell    action=unlock    cells_info=${cell_list}[cells]   cell_type=${cell_type}
        ...    AND    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

recover lock unlock BBMOD
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Save snapshot with BTS    connection=${connection_name}
    ${bts_info}=    Get info with BTS
    ${basebandModules}    set variable    ${bts_info}[basebandModules]
    FOR    ${baseband}    IN    @{basebandModules}
        Unlock required dist_name with BTS    dist_name=${baseband}[id][configuration]    connection=${connection_name}
    END
    Sleep    2m
    ${check_result}=    check if ASOD or ASOE or ASOF or ASOG or ASOH testline    gnb_index=${gnb_index}
    Run Keyword If    ${check_result} == ${False}
    ...    Wait Until Keyword Succeeds    10min    10s    Check basebandModule status
    ...    ELSE    Log to console    Skip the status checking for ABIL as the blade type is ASOD or ASOE or ASOF or ASOG or ASOH
    Wait Until Keyword Succeeds    10min    10s    Check radioModule status
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

recover lock unlock RMOD
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Save snapshot with BTS    connection=${connection_name}
    ${bts_info}=    Get info with BTS
    ${radioModules}    set variable    ${bts_info}[radioModules][rmod]
    FOR    ${rmod}    IN    @{radioModules}
        Unlock required dist_name with BTS    dist_name=${rmod}[id][configuration]    connection=${connection_name}
    END
    Sleep    2m
    Wait Until Keyword Succeeds    10min    10s    Check radioModule status
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    Wait Until Keyword Succeeds    5min    10s    Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

collect snapshot after reset site
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Save snapshot with BTS    connection=${connection_name}
    [Teardown]    Disconnect With BTS    connection=${connection_name}