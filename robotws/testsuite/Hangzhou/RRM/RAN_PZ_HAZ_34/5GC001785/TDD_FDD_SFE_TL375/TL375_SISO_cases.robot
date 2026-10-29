*** Settings ***
Documentation    Author: Ming Shi
...              Contact: ming.shi@nokia-sbell.com
...    This is a test suite for the login page
...    RF block/unblock , cell block/unblock , BBU reset,gNB reset,cell reset, gnb block/unblock, reset, RF reset

Suite Setup    get_test_info

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/SiSo_common_keywords.robot


*** Variables ***
${connection_name}    GNB_OAM
${epc_log_path}    /tmp/
${scf_file_path}    /opt/workspace/CRT/Master/SCF_file/
${tl_scf_file}    gNB1_Golden_SCF.xml
${test_info_path}    /opt/workspace/SCF/
${test_info_file}    SiSo_test_info.yml


*** Test Cases ***
[1]block_unblock_required_cells_case
    [Timeout]    20 hours
    FOR    ${i}    IN RANGE    ${test_round}
        Log To Console    This is ${i} round
        block unblock required cells action    gnb_index=${gnb_index}
    END
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    recover required cells via unblock    gnb_index=${gnb_index}
    ...    AND    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect and get snapshot    gnb_index=${gnb_index}

[1]reset_per_cell_case
    [Timeout]    20 hours
    FOR    ${i}    IN RANGE    ${test_round}
        Log To Console    This is ${i} round
        reset per cell via admin cli    gnb_index=${gnb_index}
    END
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect and get snapshot    gnb_index=${gnb_index}

[1]lock_unlock_RMOD_case
    [Timeout]    20 hours
    FOR    ${i}    IN RANGE    ${test_round}
        Log To Console    This is ${i} round
        lock unlock RMOD action    gnb_index=${gnb_index}
    END
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    recover lock unlock RMOD    gnb_index=${gnb_index}
    ...    AND    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect and get snapshot    gnb_index=${gnb_index}

[1]reset_RMOD_case
    [Timeout]    20 hours
    FOR    ${i}    IN RANGE    ${test_round}
        Log To Console    This is ${i} round
        reset RMOD action    gnb_index=${gnb_index}
    END
    [Teardown]    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect and get snapshot    gnb_index=${gnb_index}

*** Keywords ***
get_test_info
    ${test_info}=    SiSo_common_keywords.get_info_from_file    file_path=${test_info_path}${test_info_file}
    Set Suite Variable    ${test_round}    ${test_info}[test_round]
    Set Suite Variable    ${gnb_index}    ${test_info}[gnb_index]
    Set Suite Variable    ${check_alarms_times}    ${test_info}[check_alarms_times]
    Set Suite Variable    ${configuration_cells}    ${test_info}[configuration_cells]
    Set Suite Variable    ${internal_cells}    ${test_info}[internal_cells]
    Set Suite Variable    ${configuration_rmods}    ${test_info}[configuration_rmods]
    Set Suite Variable    ${runtime_rmods}    ${test_info}[runtime_rmods]


block unblock required cells action
    [Timeout]    2 hours
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    FOR    ${cell}    IN    @{configuration_cells}
        Block cell with BTS    dist_name=${cell}
        Sleep    10s
        Unblock cell with BTS    dist_name=${cell}
        Check X2 link status from GNB
        Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=nr
    END
    loop check alarms
#    ${cell_list}=    Get cell list info
#    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
#    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    [Teardown]    Disconnect With BTS    connection=${connection_name}

recover required cells via unblock
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell}    IN    @{configuration_cells}
        Unblock cell with BTS    dist_name=${cell}
        Check X2 link status from GNB
        Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=nr
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

reset per cell via admin cli
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    FOR    ${cell}    IN    @{internal_cells}
        Reset cell with BTS    cell_id=${cell}
        Check X2 link status from GNB
        Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=nr
    END
    loop check alarms
    [Teardown]    Disconnect With BTS    connection=${connection_name}

lock unlock RMOD action
    [Timeout]    2 hours
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}
#    ${bts_info}=    Get info with BTS
#    ${radioModules}    set variable    ${bts_info}[radioModules][rmod]
    FOR    ${RMOD}    IN    @{configuration_rmods}
        Lock required dist_name with BTS    dist_name=${RMOD}
        SLeep    5s
        Unlock required dist_name with BTS    dist_name=${RMOD}
        Sleep    2m
        Wait Until Keyword Succeeds    10min    10s    Check radioModule status
        ${cell_list}=    Get cell list info
        ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
        ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
        FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
            ${Length}=    Get Length    ${cells_info}[${cell_index}]
            IF    '${Length}' != '0'
                IF    '${cell_type}' == 'nr'
                    Check X2 link status from GNB
                END
                Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=nr
            ELSE
                Continue For Loop
            END
        END
    END
    loop check alarms
    [Teardown]    Disconnect With BTS    connection=${connection_name}

recover lock unlock RMOD
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}
    FOR    ${rmod}    IN    @{configuration_rmods}
        Unlock required dist_name with BTS    dist_name=${RMOD}
    END
    Sleep    2m
    Wait Until Keyword Succeeds    10min    10s    Check radioModule status
    Check X2 link status from GNB
    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=nr
    loop check alarms
    [Teardown]    Disconnect With BTS    connection=${connection_name}

reset RMOD action
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    FOR    ${rmod}    IN    @{runtime_rmods}
        Reset Unit with BTS    dist_name=${RMOD}
    END
    Sleep    2m
    Wait Until Keyword Succeeds    10min    10s    Check radioModule status
    Check X2 link status from GNB
    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=nr
    loop check alarms
    [Teardown]    Disconnect With BTS    connection=${connection_name}

collect and get snapshot
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Save snapshot with BTS    connection=${connection_name}
    [Teardown]    Disconnect With BTS    connection=${connection_name}
