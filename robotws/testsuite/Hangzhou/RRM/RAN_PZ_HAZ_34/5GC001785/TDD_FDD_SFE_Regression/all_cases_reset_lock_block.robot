*** Settings ***
Documentation    Author: Ming Shi
...              Contact: ming.shi@nokia-sbell.com
...    This is a test suite for the login page
...    RF block/unblock , cell block/unblock , BBU reset,gNB reset,cell reset, gnb block/unblock, reset, RF reset

Suite Setup            Run Keywords
...    get_test_info
...    AND    Wait Until Keyword Succeeds    30m    10s    check firmware upgrade ongoing fid 4420    gnb_index=${gnb_index}
Suite Teardown
Test Setup    Test start for siso cases

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/SiSo_common_keywords.robot

*** Variables ***
${connection_name}    GNB_OAM
${epc_log_path}    /tmp/
${scf_file_path}    /opt/workspace/CRT/Master/SCF_file/
${tl_scf_file}    gNB1_Golden_SCF.xml
${test_info_path}    /opt/workspace/SCF/
${test_info_file}    SiSo_test_info.yml

*** Test Cases ***
[1]block_unblock_all_cells_case
    [Timeout]    10 hours
    [Tags]    block_all_cells
    FOR    ${i}    IN RANGE    ${block_all_cells_test_round}
        Log To Console    This is ${i} round
        block unblock all cells action    gnb_index=${gnb_index}    index=${i}
    END
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    recover all cells via unblock    gnb_index=${gnb_index}
    ...    AND    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect and get snapshot
    ...    AND    Common teardown for siso case

[1]block_unblock_per_cell_case
    [Timeout]    10 hours
    [Tags]    block_per_cell
    FOR    ${i}    IN RANGE    ${block_per_cell_test_round}
        Log To Console    This is ${i} round
        block unblock per cell action    gnb_index=${gnb_index}    index=${i}
    END
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    recover all cells via unblock    gnb_index=${gnb_index}
    ...    AND    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect and get snapshot
    ...    AND    Common teardown for siso case

[1]block_unblock_bts_case
    [Timeout]    20 hours
    [Tags]    block_bts
    FOR    ${i}    IN RANGE    ${block_bts_test_round}
        Log To Console    This is ${i} round
        block unblock bts action    gnb_index=${gnb_index}    index=${i}
    END
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    recover bts via unblock bts    gnb_index=${gnb_index}
    ...    AND    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect and get snapshot
    ...    AND    Common teardown for siso case

[1]lock_unlock_per_cell_case
    [Timeout]    10 hours
    [Tags]    lock_per_cell
    FOR    ${i}    IN RANGE    ${lock_per_cell_test_round}
        Log To Console    This is ${i} round
        lock unlock per cell action    gnb_index=${gnb_index}    index=${i}
    END
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    recover all cells via unlock    gnb_index=${gnb_index}
    ...    AND    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect and get snapshot
    ...    AND    Common teardown for siso case

[1]block_unblock_rat_case
    [Timeout]    20 hours
    [Tags]    block_rat
    FOR    ${i}    IN RANGE    ${block_rat_test_round}
        Log To Console    This is ${i} round
        block unblock rat action    gnb_index=${gnb_index}    index=${i}
    END
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    recover rat via unblock rat    gnb_index=${gnb_index}
    ...    AND    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect and get snapshot
    ...    AND    Common teardown for siso case

[1]lock_unlock_BBMOD_case
    [Timeout]    20 hours
    [Tags]    lock_bbmod
    FOR    ${i}    IN RANGE    ${lock_bbmod_test_round}
        Log To Console    This is ${i} round
        lock unlock BBMOD action    gnb_index=${gnb_index}    index=${i}
    END
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    recover lock unlock BBMOD    gnb_index=${gnb_index}
    ...    AND    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect and get snapshot
    ...    AND    Common teardown for siso case

[1]lock_unlock_RMOD_case
    [Timeout]    20 hours
    [Tags]    lock_rmod
    FOR    ${i}    IN RANGE    ${lock_rmod_test_round}
        Log To Console    This is ${i} round
        lock unlock RMOD action    gnb_index=${gnb_index}    index=${i}
    END
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    recover lock unlock RMOD    gnb_index=${gnb_index}
    ...    AND    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect and get snapshot
    ...    AND    Common teardown for siso case

[1]power_reset_case
    [Timeout]    20 hours
    [Tags]    power_reset
    [Teardown]     Common teardown for siso case
    [Template]    power reset keyword
    gnb_index=${gnb_index}    graceful_cell_shutdown=${False}
    gnb_index=${gnb_index}    graceful_cell_shutdown=${True}

[1]site_reset_case
    [Timeout]    20 hours
    [Tags]    site_reset
    FOR    ${i}    IN RANGE    ${site_reset_test_round}
        Log To Console    This is ${i} round
        site reset action    gnb_index=${gnb_index}    index=${i}
    END
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect snapshot after reset site    gnb_index=${gnb_index}
    ...    AND    Common teardown for siso case

[1]reset_all_cells_case
    [Timeout]    10 hours
    [Tags]    reset_all_cells
    FOR    ${i}    IN RANGE    ${reset_all_cells_test_round}
        Log To Console    This is ${i} round
        reset all cells action    gnb_index=${gnb_index}    index=${i}
    END
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect snapshot after reset site    gnb_index=${gnb_index}
    ...    AND    Common teardown for siso case

[1]reset_per_cell_case
    [Documentation]    This is a test case for reset per cell, about 3m 30s per loop
    [Timeout]    10 hours
    [Tags]    reset_per_cell
    [Teardown]    Common teardown for siso case
    [Template]    reset per cell keyword
    gnb_index=${gnb_index}    graceful_cell_shutdown=${False}
    gnb_index=${gnb_index}    graceful_cell_shutdown=${True}

[1]rat_reset_case
    [Documentation]    This is a test case for RAT reset, [“Soft”|”Hard”] about 25:26 per loop
    [Timeout]    40 hours
    [Tags]    rat_reset
    [Teardown]    Common teardown for siso case
    [Template]    rat reset keyword
    reset_type=Soft    gnb_index=${gnb_index}    graceful_cell_shutdown=${False}
    reset_type=Soft    gnb_index=${gnb_index}    graceful_cell_shutdown=${True}
    reset_type=Hard    gnb_index=${gnb_index}    graceful_cell_shutdown=${False}
    reset_type=Hard    gnb_index=${gnb_index}    graceful_cell_shutdown=${True}

[1]reset_site_case
    [Documentation]    This is a test case for reset site, about 13:52 per loop
    [Timeout]    20 hours
    [Tags]    reset_site
    [Teardown]    Common teardown for siso case
    [Template]    reset site keyword
    gnb_index=${gnb_index}    graceful_cell_shutdown=${False}    reset_without_ru=${True}
    gnb_index=${gnb_index}    graceful_cell_shutdown=${True}    reset_without_ru=${True}
    gnb_index=${gnb_index}    graceful_cell_shutdown=${False}    reset_without_ru=${False}
    gnb_index=${gnb_index}    graceful_cell_shutdown=${True}    reset_without_ru=${False}

[1]reset_BBMOD_case
    [Timeout]    24 hours
    [Tags]    reset_bbmod
    [Teardown]    Common teardown for siso case
    [Template]    reset BBMOD keyword
    reset_type=Warm    gnb_index=${gnb_index}    force_radio_reset=${False}    graceful_cell_shutdown=${False}
    reset_type=Warm    gnb_index=${gnb_index}    force_radio_reset=${False}    graceful_cell_shutdown=${True}
    reset_type=Warm    gnb_index=${gnb_index}    force_radio_reset=${True}    graceful_cell_shutdown=${False}
    reset_type=Warm    gnb_index=${gnb_index}    force_radio_reset=${True}    graceful_cell_shutdown=${True}
    reset_type=PowerReset    gnb_index=${gnb_index}    force_radio_reset=${False}    graceful_cell_shutdown=${False}
    reset_type=PowerReset    gnb_index=${gnb_index}    force_radio_reset=${False}    graceful_cell_shutdown=${True}
    reset_type=PowerReset    gnb_index=${gnb_index}    force_radio_reset=${True}    graceful_cell_shutdown=${False}
    reset_type=PowerReset    gnb_index=${gnb_index}    force_radio_reset=${True}    graceful_cell_shutdown=${True}

[1]reset_RMOD_case
    [Timeout]    30 hours
    [Tags]    reset_rmod
    [Teardown]    Common teardown for siso case
    [Template]    reset RMOD keyword
    reset_type=Soft    gnb_index=${gnb_index}    force_radio_reset=${True}    graceful_cell_shutdown=${False}
    reset_type=Soft    gnb_index=${gnb_index}    force_radio_reset=${True}    graceful_cell_shutdown=${True}
    reset_type=Hard    gnb_index=${gnb_index}    force_radio_reset=${True}    graceful_cell_shutdown=${False}
    reset_type=Hard    gnb_index=${gnb_index}    force_radio_reset=${True}    graceful_cell_shutdown=${True}
    reset_type=Warm    gnb_index=${gnb_index}    force_radio_reset=${True}    graceful_cell_shutdown=${False}
    reset_type=Warm    gnb_index=${gnb_index}    force_radio_reset=${True}    graceful_cell_shutdown=${True}

[1]commissioning_reset_case
    [Timeout]    20 hours
    [Tags]    commissioning_reset
    FOR    ${i}    IN RANGE    ${commissioning_reset_test_round}
        Log To Console    This is ${i} round
        commissioning reset action    gnb_index=${gnb_index}    index=${i}
    END
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect snapshot after reset site    gnb_index=${gnb_index}
    ...    AND    Common teardown for siso case

#[1]configuration_reset_commissioning_reset_case
#    [Timeout]    20 hours
#    FOR    ${i}    IN RANGE    ${test_round}
#        Log To Console    This is ${i} round
##        configuration reset action    gnb_index=${gnb_index}
#        commissioning reset action    gnb_index=${gnb_index}
#    END
#    [Teardown]    Run Keywords
#    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect snapshot after reset site    gnb_index=${gnb_index}
#    ...    AND    Common teardown for siso case

[1]x2_slice_amf_block_lock_concurrency_case
    [Timeout]    20 hours
    [Tags]    x2_slice_amf_block_lock_concurrency
    FOR    ${i}    IN RANGE    ${x2_slice_amf_block_lock_concurrency_test_round}
        Log To Console    This is ${i} round
        x2_slice_amf_block_lock_concurrency_action    gnb_index=${gnb_index}    index=${i}
    END
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    recover x2_slice_amf_block_lock_concurrency_action    gnb_index=${gnb_index}
    ...    AND    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect and get snapshot
    ...    AND    Common teardown for siso case

[1]lock_ng_link_case
    [Timeout]    10 hours
    [Tags]    lock_ng
    FOR    ${i}    IN RANGE    ${lock_ng_test_round}
        Log To Console    This is ${i} round
        lock unlock ng link action    gnb_index=${gnb_index}    index=${i}
    END
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    recover lock unlock ng link action    gnb_index=${gnb_index}
    ...    AND    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect and get snapshot
    ...    AND    Common teardown for siso case

[1]loop_collect_snapshot
    [Timeout]    10 hours
    [Tags]    collect_snapshot
    FOR    ${i}    IN RANGE    ${collect_snapshot_test_round}
        Log To Console    This is ${i} round
        snapshot collected and remove    gnb_index=${gnb_index}    index=${i}
    END
    [Teardown]    Run Keywords
    ...    Run Keyword If    '${TEST STATUS}' == 'FAIL'    collect and get snapshot
    ...    AND    Common teardown for siso case



*** Keywords ***
get_test_info
    ${test_info}=    SiSo_common_keywords.get_info_from_file    file_path=${test_info_path}${test_info_file}
    Set Suite Variable    ${test_round}    ${test_info}[test_round]
    Set Suite Variable    ${block_all_cells_test_round}    ${test_info}[block_all_cells_test_round]
    Set Suite Variable    ${block_per_cell_test_round}    ${test_info}[block_per_cell_test_round]
    Set Suite Variable    ${block_bts_test_round}    ${test_info}[block_bts_test_round]
    Set Suite Variable    ${lock_per_cell_test_round}    ${test_info}[lock_per_cell_test_round]
    Set Suite Variable    ${block_rat_test_round}    ${test_info}[block_rat_test_round]
    Set Suite Variable    ${lock_bbmod_test_round}    ${test_info}[lock_bbmod_test_round]
    Set Suite Variable    ${lock_rmod_test_round}    ${test_info}[lock_rmod_test_round]
    Set Suite Variable    ${power_reset_test_round}    ${test_info}[power_reset_test_round]
    Set Suite Variable    ${site_reset_test_round}    ${test_info}[site_reset_test_round]
    Set Suite Variable    ${reset_all_cells_test_round}    ${test_info}[reset_all_cells_test_round]
    Set Suite Variable    ${reset_per_cell_test_round}    ${test_info}[reset_per_cell_test_round]
    Set Suite Variable    ${rat_reset_test_round}    ${test_info}[rat_reset_test_round]
    Set Suite Variable    ${reset_site_test_round}    ${test_info}[reset_site_test_round]
    Set Suite Variable    ${reset_bbmod_test_round}    ${test_info}[reset_bbmod_test_round]
    Set Suite Variable    ${reset_rmod_test_round}    ${test_info}[reset_rmod_test_round]
    Set Suite Variable    ${commissioning_reset_test_round}    ${test_info}[commissioning_reset_test_round]
    Set Suite Variable    ${x2_slice_amf_block_lock_concurrency_test_round}    ${test_info}[x2_slice_amf_block_lock_concurrency_test_round]
    Set Suite Variable    ${lock_ng_test_round}    ${test_info}[lock_ng_test_round]
    Set Suite Variable    ${collect_snapshot_test_round}    ${test_info}[collect_snapshot_test_round]
    Set Suite Variable    ${gnb_index}    ${test_info}[gnb_index]
    Set Suite Variable    ${allowed_faults_ids}    ${test_info}[allowed_faults_ids]
    Set Suite Variable    ${check_alarms_times}    ${test_info}[check_alarms_times]


power reset keyword
    [Arguments]    ${gnb_index}=${0}    ${graceful_cell_shutdown}=${None}    ${cold_reset_secondary_core_via_backplane}=${None}
    FOR    ${i}    IN RANGE    ${power_reset_test_round}
        Log To Console    This is ${i} round
        power reset action    gnb_index=${gnb_index}    graceful_cell_shutdown=${graceful_cell_shutdown}
        ...    cold_reset_secondary_core_via_backplane=${cold_reset_secondary_core_via_backplane}
        ...    index=${graceful_cell_shutdown}_${i}
    END
    [Teardown]    Run Keyword If    '${KEYWORD STATUS}' == 'FAIL'    collect snapshot after reset site    gnb_index=${gnb_index}

reset per cell keyword
    [Arguments]    ${gnb_index}=${0}    ${graceful_cell_shutdown}=${None}
    FOR    ${i}    IN RANGE    ${reset_per_cell_test_round}
        Log To Console    This is ${i} round
        reset per cell action    gnb_index=${gnb_index}    graceful_cell_shutdown=${graceful_cell_shutdown}
        ...    index=${graceful_cell_shutdown}_${i}
    END
    [Teardown]    Run Keyword If    '${KEYWORD STATUS}' == 'FAIL'    collect snapshot after reset site    gnb_index=${gnb_index}

rat reset keyword
    [Arguments]    ${reset_type}=Soft    ${gnb_index}=${0}    ${graceful_cell_shutdown}=${None}
    FOR    ${i}    IN RANGE    ${rat_reset_test_round}
        Log To Console    This is ${i} round
        rat reset action    reset_type=${reset_type}    gnb_index=${gnb_index}    graceful_cell_shutdown=${graceful_cell_shutdown}
        ...    index=${reset_type}_${graceful_cell_shutdown}_${i}
    END
    [Teardown]    Run Keyword If    '${KEYWORD STATUS}' == 'FAIL'    collect snapshot after reset site    gnb_index=${gnb_index}

rat reset tmp keyword
    [Arguments]    ${reset_type}=Soft    ${gnb_index}=${0}    ${graceful_cell_shutdown}=${None}
    restart_fpga_on_ir_of_pr808181
    ...    bts_ip=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    bts_user=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...    bts_password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    check cell x2 and alarm status    gnb_index=${gnb_index}
    FOR    ${i}    IN RANGE    ${test_round}
        Log To Console    This is ${i} round
        rat reset action    reset_type=${reset_type}    gnb_index=${gnb_index}    graceful_cell_shutdown=${graceful_cell_shutdown}
    END
    [Teardown]    Run Keyword If    '${KEYWORD STATUS}' == 'FAIL'    Run Keywords
    ...    upload the tmp file    gnb_index=${gnb_index}
    ...    AND    collect_required_logs_on_ir_of_pr808181
    ...    bts_ip=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.addr}
    ...    bts_user=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.username}
    ...    bts_password=${tl.gnbs[${gnb_index}].cu.oam_ssh_connection_details.password}
    ...    AND    collect snapshot after reset site    gnb_index=${gnb_index}

check cell x2 and alarm status
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        ${upper_cell_type}    Run Keyword If    '${Length}' != '0'    Convert To Upper Case    ${cell_type}
        IF    '${Length}' != '0'
            check per module status    gnb_index=${gnb_index}
            IF    '${cell_type}' == 'nr'
                Check X2 link status from GNB
            END
            Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ELSE
            Continue For Loop
        END
    END
    loop check alarms
    [Teardown]    Disconnect With BTS    connection=${connection_name}

reset site keyword
    [Arguments]    ${gnb_index}=${0}    ${graceful_cell_shutdown}=${None}    ${reset_without_ru}=${None}
    FOR    ${i}    IN RANGE    ${reset_site_test_round}
        Log To Console    This is ${i} round
        reset site action    gnb_index=${gnb_index}    graceful_cell_shutdown=${graceful_cell_shutdown}
        ...    reset_without_ru=${reset_without_ru}
        ...    index=${graceful_cell_shutdown}_${reset_without_ru}_${i}
    END
    [Teardown]    Run Keyword If    '${KEYWORD STATUS}' == 'FAIL'    collect snapshot after reset site    gnb_index=${gnb_index}

reset BBMOD keyword
    [Arguments]    ${reset_type}=Warm    ${gnb_index}=${0}    ${force_radio_reset}=${False}    ${graceful_cell_shutdown}=${None}
    FOR    ${i}    IN RANGE    ${reset_bbmod_test_round}
        Log To Console    This is ${i} round
        reset BBMOD action    reset_type=${reset_type}    gnb_index=${gnb_index}
        ...    force_radio_reset=${force_radio_reset}    graceful_cell_shutdown=${graceful_cell_shutdown}
        ...    index=${reset_type}_${force_radio_reset}_${graceful_cell_shutdown}_${i}
    END
    [Teardown]    Run Keyword If    '${KEYWORD STATUS}' == 'FAIL'    collect snapshot after reset site    gnb_index=${gnb_index}

reset RMOD keyword
    [Arguments]    ${reset_type}=Soft    ${gnb_index}=${0}    ${force_radio_reset}=${False}    ${graceful_cell_shutdown}=${None}
    FOR    ${i}    IN RANGE    ${reset_rmod_test_round}
        Log To Console    This is ${i} round
        reset RMOD action    reset_type=${reset_type}    gnb_index=${gnb_index}
        ...    force_radio_reset=${force_radio_reset}    graceful_cell_shutdown=${graceful_cell_shutdown}
        ...    index=${reset_type}_${force_radio_reset}_${graceful_cell_shutdown}_${i}
    END
    [Teardown]    Run Keyword If    '${KEYWORD STATUS}' == 'FAIL'    collect snapshot after reset site    gnb_index=${gnb_index}

block unblock all cells action
    [Timeout]    2 hours
    [Arguments]    ${gnb_index}=${0}    ${index}=${0}
    Start capture syslog via btslog on ute
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        ${upper_cell_type}    Run Keyword If    '${Length}' != '0'    Convert To Upper Case    ${cell_type}
        IF    '${Length}' != '0'
            Block all cells with BTS    rat=${upper_cell_type}
            Wait Until Keyword Succeeds    5min    10s    Check cell failed status    cell_type=${cell_type}
            Sleep    5s
            Unblock all cells with BTS    rat=${upper_cell_type}
            IF    '${cell_type}' == 'nr'
                Check X2 link status from GNB
            END
            Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ELSE
            Continue For Loop
        END
    END
    loop check alarms
    [Teardown]    Run Keywords
    ...    Disconnect With BTS    connection=${connection_name}
    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Continue On Failure    syslog analysis via regex file    index=${index}

reset all cells action
    [Timeout]    2 hours
    [Arguments]    ${gnb_index}=${0}    ${index}=${0}
    Start capture syslog via btslog on ute
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Reset all cells with BTS
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        IF    '${Length}' != '0'
            IF    '${cell_type}' == 'nr'
                Check X2 link status from GNB
            END
            Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ELSE
            Continue For Loop
        END
    END
    loop check alarms
    [Teardown]    Run Keywords
    ...    Disconnect With BTS    connection=${connection_name}
    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Continue On Failure    syslog analysis via regex file    index=${index}

block unblock per cell action
    [Timeout]    2 hours
    [Arguments]    ${gnb_index}=${0}    ${index}=${0}
    Start capture syslog via btslog on ute
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        IF    '${Length}' != '0'
            block unblock per cell    action=block    cells_info=${cell_list}[cells]    cell_type=${cell_type}
            Wait Until Keyword Succeeds    5min    10s    Check cell failed status    cell_type=${cell_type}
            Sleep    5s
            block unblock per cell    action=unblock    cells_info=${cell_list}[cells]   cell_type=${cell_type}
            IF    '${cell_type}' == 'nr'
                Check X2 link status from GNB
            END
            Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ELSE
            Continue For Loop
        END
    END
    loop check alarms
    [Teardown]    Run Keywords
    ...    Disconnect With BTS    connection=${connection_name}
    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Continue On Failure    syslog analysis via regex file    index=${index}

#block unblock per cell
#    [Arguments]    ${action}    ${cells_info}    ${cell_type}
#    ${cell_length}=    Get Length    ${cells_info}[${cell_type}]
#    FOR    ${cell_index}    IN RANGE    ${cell_length}
#    Run Keyword If    '${action}' == 'block'
#    ...    Block cell with BTS    dist_name=${cells_info}[${cell_type}][${cell_index}][id][configuration]
#    ...    ELSE IF    '${action}' == 'unblock'
#    ...    Unblock cell with BTS    dist_name=${cells_info}[${cell_type}][${cell_index}][id][configuration]
#    END

block unblock per cell
    [Arguments]    ${action}    ${cells_info}    ${cell_type}
    ${cell_length}=    Get Length    ${cells_info}[${cell_type}]
    FOR    ${cell_index}    IN RANGE    ${cell_length}
        IF    '${action}' == 'block'
            IF    '${cell_type}' == 'lte'
                IF    '${cells_info}[${cell_type}][${cell_index}][technology]' != 'NB-IoT-FDD'
                    Block cell with BTS    dist_name=${cells_info}[${cell_type}][${cell_index}][id][configuration]
                END
            ELSE
                Block cell with BTS    dist_name=${cells_info}[${cell_type}][${cell_index}][id][configuration]
            END
        ELSE IF    '${action}' == 'unblock'
            IF    '${cell_type}' == 'lte'
                IF    '${cells_info}[${cell_type}][${cell_index}][technology]' != 'NB-IoT-FDD'
                    Unblock cell with BTS    dist_name=${cells_info}[${cell_type}][${cell_index}][id][configuration]
                END
            ELSE
                Unblock cell with BTS    dist_name=${cells_info}[${cell_type}][${cell_index}][id][configuration]
            END
        END
    END

reset per cell action
    [Timeout]    2 hours
    [Arguments]    ${gnb_index}=${0}    ${graceful_cell_shutdown}=${None}    ${index}=${0}
    Start capture syslog via btslog on ute
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        IF    '${Length}' != '0'
            reset per cell    cells_info=${cell_list}[cells]   cell_type=${cell_type}    graceful_cell_shutdown=${graceful_cell_shutdown}
            IF    '${cell_type}' == 'nr'
                Check X2 link status from GNB
            END
            Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ELSE
            Continue For Loop
        END
    END
    loop check alarms
    [Teardown]    Run Keywords
    ...    Disconnect With BTS    connection=${connection_name}
    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Continue On Failure    syslog analysis via regex file    index=${index}

reset per cell
    [Arguments]    ${cells_info}    ${cell_type}    ${graceful_cell_shutdown}=${None}
    ${cell_length}=    Get Length    ${cells_info}[${cell_type}]
    FOR    ${cell_index}    IN RANGE    ${cell_length}
        Reset cell with BTS    cell_id=${cells_info}[${cell_type}][${cell_index}][id][internal]    graceful_cell_shutdown=${graceful_cell_shutdown}
    END

reset per cell with graceful_cell_shutdown
    [Arguments]    ${cells_info}    ${cell_type}
    ${cell_length}=    Get Length    ${cells_info}[${cell_type}]
    FOR    ${cell_index}    IN RANGE    ${cell_length}
        Reset cell with BTS    cell_id=${cells_info}[${cell_type}][${cell_index}][id][internal]    graceful_cell_shutdown=${True}
    END

block unblock bts action
    [Timeout]    2 hours
    [Arguments]    ${gnb_index}=${0}    ${index}=${0}
    Start capture syslog via btslog on ute
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Block BTS
    Sleep    5s
    Unblock BTS    timeout=${300}
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        IF    '${Length}' != '0'
            IF    '${cell_type}' == 'nr'
                Check X2 link status from GNB
            END
            Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ELSE
            Continue For Loop
        END
    END
    loop check alarms
    [Teardown]    Run Keywords
    ...    Disconnect With BTS    connection=${connection_name}
    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Continue On Failure    syslog analysis via regex file    index=${index}

block unblock rat action
    [Timeout]    2 hours
    [Arguments]    ${gnb_index}=${0}    ${index}=${0}
    Start capture syslog via btslog on ute
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        ${upper_cell_type}    Run Keyword If    '${Length}' != '0'    Convert To Upper Case    ${cell_type}
        IF    '${Length}' != '0'
            Block RAT with BTS    rat=${upper_cell_type}
            Sleep    5s
            Unblock RAT with BTS    rat=${upper_cell_type}
            IF    '${cell_type}' == 'nr'
                Check X2 link status from GNB
            END
            Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ELSE
            Continue For Loop
        END
    END
    loop check alarms
    [Teardown]    Run Keywords
    ...    Disconnect With BTS    connection=${connection_name}
    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Continue On Failure    syslog analysis via regex file    index=${index}

lock unlock BBMOD action
    [Timeout]    2 hours
    [Arguments]    ${gnb_index}=${0}    ${index}=${0}
    Start capture syslog via btslog on ute
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
        IF    '${Length}' != '0'
            IF    '${cell_type}' == 'nr'
                Check X2 link status from GNB
            END
            Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ELSE
            Continue For Loop
        END
    END
    loop check alarms
    [Teardown]    Run Keywords
    ...    Disconnect With BTS    connection=${connection_name}
    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Continue On Failure    syslog analysis via regex file    index=${index}

lock unlock RMOD action
    [Timeout]    2 hours
    [Arguments]    ${gnb_index}=${0}    ${index}=${0}
    Start capture syslog via btslog on ute
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
        IF    '${Length}' != '0'
            IF    '${cell_type}' == 'nr'
                Check X2 link status from GNB
            END
            Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ELSE
            Continue For Loop
        END
    END
    loop check alarms
    [Teardown]    Run Keywords
    ...    Disconnect With BTS    connection=${connection_name}
    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Continue On Failure    syslog analysis via regex file    index=${index}

power reset action
    [Timeout]    2 hours
    [Arguments]    ${gnb_index}=${0}    ${graceful_cell_shutdown}=${None}    ${cold_reset_secondary_core_via_backplane}=${None}
    ...    ${index}=${0}
    Start capture syslog via btslog on ute
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Power reset with BTS    connection=${connection_name}    graceful_cell_shutdown=${graceful_cell_shutdown}
    ...    cold_reset_secondary_core_via_backplane=${cold_reset_secondary_core_via_backplane}
    Sleep    2m
    Wait Until Keyword Succeeds    5min    10s    Check systemModule status
    ${check_result}=    check if ASOD or ASOE or ASOF or ASOG or ASOH testline    gnb_index=${gnb_index}
    Run Keyword If    ${check_result} == ${False}
    ...    Wait Until Keyword Succeeds    10min    10s    Check basebandModule status
    ...    ELSE    Log to console    Skip the status checking for ABIL as the blade type is ASOD or ASOE or ASOF or ASOG or ASOH
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    10min    10s    Check radioModule status
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        IF    '${Length}' != '0'
            IF    '${cell_type}' == 'nr'
                Check X2 link status from GNB
            END
            Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ELSE
            Continue For Loop
        END
    END
    loop check alarms
    [Teardown]    Run Keywords
    ...    Disconnect With BTS    connection=${connection_name}
    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Continue On Failure    syslog analysis via regex file    index=${index}

site reset action
    [Timeout]    2 hours
    [Arguments]    ${gnb_index}=${0}    ${index}=${0}
    Start capture syslog via btslog on ute
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Reset with BTS    connection=${connection_name}
    Sleep    2m
    Wait Until Keyword Succeeds    5min    10s    Check systemModule status
    ${check_result}=    check if ASOD or ASOE or ASOF or ASOG or ASOH testline    gnb_index=${gnb_index}
    Run Keyword If    ${check_result} == ${False}
    ...    Wait Until Keyword Succeeds    10min    10s    Check basebandModule status
    ...    ELSE    Log to console    Skip the status checking for ABIL as the blade type is ASOD or ASOE or ASOF or ASOG or ASOH
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    10min    10s    Check radioModule status
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        IF    '${Length}' != '0'
            IF    '${cell_type}' == 'nr'
                Check X2 link status from GNB
            END
            Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ELSE
            Continue For Loop
        END
    END
    loop check alarms
    [Teardown]    Run Keywords
    ...    Disconnect With BTS    connection=${connection_name}
    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Continue On Failure    syslog analysis via regex file    index=${index}

reset site action
    [Arguments]    ${gnb_index}=${0}    ${graceful_cell_shutdown}=${None}    ${reset_without_ru}=${None}    ${index}=${0}
    Start capture syslog via btslog on ute
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Reset site with BTS    connection=${connection_name}    graceful_cell_shutdown=${graceful_cell_shutdown}
    ...    reset_without_ru=${reset_without_ru}
    Sleep    2m
    Wait Until Keyword Succeeds    5min    10s    Check systemModule status
    ${check_result}=    check if ASOD or ASOE or ASOF or ASOG or ASOH testline    gnb_index=${gnb_index}
    Run Keyword If    ${check_result} == ${False}
    ...    Wait Until Keyword Succeeds    10min    10s    Check basebandModule status
    ...    ELSE    Log to console    Skip the status checking for ABIL as the blade type is ASOD or ASOE or ASOF or ASOG or ASOH
    Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    10min    10s    Check radioModule status
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        IF    '${Length}' != '0'
            IF    '${cell_type}' == 'nr'
                Check X2 link status from GNB
            END
            Run Keyword And Continue On Failure    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ELSE
            Continue For Loop
        END
    END
    loop check alarms
    [Teardown]    Run Keywords
    ...    Disconnect With BTS    connection=${connection_name}
    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Continue On Failure    syslog analysis via regex file    index=${index}

reset BBMOD action
    [Arguments]    ${reset_type}    ${gnb_index}=${0}    ${force_radio_reset}=${False}    ${graceful_cell_shutdown}=${None}    ${index}=${0}
    Start capture syslog via btslog on ute
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${bts_info}=    Get info with BTS
    ${basebandModules}    set variable    ${bts_info}[basebandModules]
    FOR    ${baseband}    IN    @{basebandModules}
        Reset Unit with BTS    dist_name=${baseband}[id][runtime]    reset_type=${reset_type}    connection=${connection_name}
        ...    force_radio_reset=${force_radio_reset}    graceful_cell_shutdown=${graceful_cell_shutdown}
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
        IF    '${Length}' != '0'
            IF    '${cell_type}' == 'nr'
                Check X2 link status from GNB
            END
            Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ELSE
            Continue For Loop
        END
    END
    loop check alarms
    [Teardown]    Run Keywords
    ...    Disconnect With BTS    connection=${connection_name}
    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Continue On Failure    syslog analysis via regex file    index=${index}

reset RMOD action
    [Arguments]    ${reset_type}    ${gnb_index}=${0}    ${force_radio_reset}=${True}    ${graceful_cell_shutdown}=${None}    ${index}=${0}
    Start capture syslog via btslog on ute
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${bts_info}=    Get info with BTS
    ${radioModules}    set variable    ${bts_info}[radioModules][rmod]
    FOR    ${rmod}    IN    @{radioModules}
        Reset Unit with BTS    dist_name=${rmod}[id][runtime]    reset_type=${reset_type}    connection=${connection_name}
        ...    force_radio_reset=${force_radio_reset}    graceful_cell_shutdown=${graceful_cell_shutdown}
    END
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
            Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ELSE
            Continue For Loop
        END
    END
    loop check alarms
    [Teardown]    Run Keywords
    ...    Disconnect With BTS    connection=${connection_name}
    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Continue On Failure    syslog analysis via regex file    index=${index}

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
        ...    AND    loop check alarms
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

rat reset action
    [Arguments]    ${reset_type}    ${gnb_index}=${0}    ${graceful_cell_shutdown}=${None}    ${index}=${0}
    Start capture syslog via btslog on ute
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        ${upper_cell_type}    Run Keyword If    '${Length}' != '0'    Convert To Upper Case    ${cell_type}
        IF    '${Length}' != '0'
            RAT reset with BTS    rat_type=${upper_cell_type}    reset_type=${reset_type}    connection=${connection_name}
            ...    graceful_cell_shutdown=${graceful_cell_shutdown}
            Sleep    2m
            check per module status    gnb_index=${gnb_index}
            IF    '${cell_type}' == 'nr'
                Check X2 link status from GNB
            END
            Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ELSE
            Continue For Loop
        END
    END
    loop check alarms
    [Teardown]    Run Keywords
    ...    Disconnect With BTS    connection=${connection_name}
    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Continue On Failure    syslog analysis via regex file    index=${index}

configuration reset action
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    coam.reset_configuration    remove_operator_certificates=${False}    remove_user_account_credentials=${False}
    ...    timeout=${500}    connection=${connection_name}    reset_type=configurationReset
    Sleep    2m
#    Wait Until Keyword Succeeds    5min    10s    Check systemModule status
#    ${check_result}=    check if ASOD or ASOE or ASOF or ASOG or ASOH testline    gnb_index=${gnb_index}
#    Run Keyword If    ${check_result} == ${False}
#    ...    Wait Until Keyword Succeeds    10min    10s    Check basebandModule status
#    ...    ELSE    Log to console    Skip the status checking for ABIL as the blade type is ASOD or ASOE or ASOF or ASOG or ASOH
#    Wait Until Keyword Succeeds    10min    10s    Check radioModule status
#    ${cell_list}=    Get cell list info
#    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
#    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
#    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
#        ${Length}=    Get Length    ${cells_info}[${cell_index}]
#        Run Keyword If    '${Length}' != '0'    Run keywords
#        ...    Check X2 link status from GNB
#        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
#        ...    AND    loop check alarms
#        ...    ELSE    Continue For Loop
#    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

commissioning reset action
    [Arguments]    ${gnb_index}=${0}    ${index}=${0}
    Start capture syslog via btslog on ute
    Get sagnb version for selenium
    Set Suite Variable    ${tl_gnb1_scf_${sw_version}}    ${sw_version}_gNB1_Golden_SCF.xml
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    commissioning and check status    scf_file=${scf_file_path}${tl_gnb1_scf_${sw_version}}    timeout=${600}    connection=${connection_name}
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
        IF    '${Length}' != '0'
            IF    '${cell_type}' == 'nr'
                Check X2 link status from GNB
            END
            Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ELSE
            Continue For Loop
        END
    END
    loop check alarms
    [Teardown]    Run Keywords
    ...    Disconnect With BTS    connection=${connection_name}
    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Continue On Failure    syslog analysis via regex file    index=${index}


lock unlock per cell action
    [Timeout]    2 hours
    [Arguments]    ${gnb_index}=${0}    ${index}=${0}
    Start capture syslog via btslog on ute
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
#    ${bts_info}=    Get info with BTS
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
#    ${cells_info}=    Get cells info with BTS
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        IF    '${Length}' != '0'
            lock unlock per cell    action=lock    cells_info=${cell_list}[cells]    cell_type=${cell_type}
            Wait Until Keyword Succeeds    5min    10s    Check cell failed status after lock    cell_type=${cell_type}
            Sleep    5s
            lock unlock per cell    action=unlock    cells_info=${cell_list}[cells]   cell_type=${cell_type}
            IF    '${cell_type}' == 'nr'
                Check X2 link status from GNB
            END
            Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ELSE
            Continue For Loop
        END
    END
    loop check alarms
    [Teardown]    Run Keywords
    ...    Disconnect With BTS    connection=${connection_name}
    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Continue On Failure    syslog analysis via regex file    index=${index}


x2_slice_amf_block_lock_concurrency_action
    [Timeout]    2 hours
    [Arguments]    ${gnb_index}=${0}    ${index}=${0}
    Start capture syslog via btslog on ute
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${scf_content}=    coam.get_scf    export_type=configurationAndRuntimeObjects    connection=${connection_name}
    ${LTEENB_distName_path_list}=    get_required_distname_path    search_str=${scf_content}    required_distname=LTEENB
    ${SNSSAI_distName_path_list}=    get_required_distname_path    search_str=${scf_content}    required_distname=SNSSAI
    ${SERVEDAMF_distName_path_list}=    get_required_distname_path    search_str=${scf_content}    required_distname=SERVEDAMF
    FOR    ${LTEENB_distName_path}    IN    @{LTEENB_distName_path_list}
        coam.perform_parameter_recommissioning
        ...    dist_name=${LTEENB_distName_path}    parameter=x2LinkLock    operation=update
        ...    value=locked    skip_parameter_relation_errors=False    should_activate=True
        ...    timeout=${600}    connection=${connection_name}
    END
    Block RAT with BTS    rat=NR    connection=${connection_name}
    Unblock RAT with BTS    rat=NR    connection=${connection_name}
    coam.perform_parameter_recommissioning
    ...    dist_name=${SNSSAI_distName_path_list}[0]    parameter=administrativeState    operation=update
    ...    value=Locked    skip_parameter_relation_errors=True    should_activate=True
    ...    timeout=${600}    connection=${connection_name}
    Comment    wait 10 mins for alarm raised 7107 7523
#    Sleep    10m    reason=wait 10 mins for alarm raised 7107 7523
    Wait Until Keyword Succeeds    10m    20s    Get required fault to check    connection=${connection_name}
    FOR    ${SERVEDAMF_distName_path}    IN    @{SERVEDAMF_distName_path_list}
        coam.perform_parameter_recommissioning
        ...    dist_name=${SERVEDAMF_distName_path}    parameter=administrativeState    operation=update
        ...    value=Locked    skip_parameter_relation_errors=True    should_activate=True
        ...    timeout=${600}    connection=${connection_name}
    END
    coam.perform_parameter_recommissioning
    ...    dist_name=${SNSSAI_distName_path_list}[0]    parameter=administrativeState    operation=update
    ...    value=Unlocked    skip_parameter_relation_errors=False    should_activate=True
    ...    timeout=${600}    connection=${connection_name}
    FOR    ${LTEENB_distName_path}    IN    @{LTEENB_distName_path_list}
        coam.perform_parameter_recommissioning
        ...    dist_name=${LTEENB_distName_path}    parameter=x2LinkLock    operation=update
        ...    value=unlocked    skip_parameter_relation_errors=False    should_activate=True
        ...    timeout=${600}    connection=${connection_name}
    END
    FOR    ${SERVEDAMF_distName_path}    IN    @{SERVEDAMF_distName_path_list}
        coam.perform_parameter_recommissioning
        ...    dist_name=${SERVEDAMF_distName_path}    parameter=administrativeState    operation=update
        ...    value=Unlocked    skip_parameter_relation_errors=False    should_activate=True
        ...    timeout=${600}    connection=${connection_name}
    END
    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=nr
    Check X2 link status from GNB
    loop check alarms
    [Teardown]    Run Keywords
    ...    Disconnect With BTS    connection=${connection_name}
    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Continue On Failure    syslog analysis via regex file    index=${index}

recover x2_slice_amf_block_lock_concurrency_action
    [Timeout]    1 hour
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Unblock RAT with BTS    rat=NR    connection=${connection_name}
    ${scf_content}=    coam.get_scf    export_type=configurationAndRuntimeObjects    connection=${connection_name}
    ${LTEENB_distName_path_list}=    get_required_distname_path    search_str=${scf_content}    required_distname=LTEENB
    ${SNSSAI_distName_path_list}=    get_required_distname_path    search_str=${scf_content}    required_distname=SNSSAI
    ${SERVEDAMF_distName_path_list}=    get_required_distname_path    search_str=${scf_content}    required_distname=SERVEDAMF
    coam.perform_parameter_recommissioning
    ...    dist_name=${SNSSAI_distName_path_list}[0]    parameter=administrativeState    operation=update
    ...    value=Unlocked    skip_parameter_relation_errors=False    should_activate=True
    ...    timeout=${600}    connection=${connection_name}
    FOR    ${LTEENB_distName_path}    IN    @{LTEENB_distName_path_list}
        coam.perform_parameter_recommissioning
        ...    dist_name=${LTEENB_distName_path}    parameter=x2LinkLock    operation=update
        ...    value=unlocked    skip_parameter_relation_errors=False    should_activate=True
        ...    timeout=${600}    connection=${connection_name}
    END
    FOR    ${SERVEDAMF_distName_path}    IN    @{SERVEDAMF_distName_path_list}
        coam.perform_parameter_recommissioning
        ...    dist_name=${SERVEDAMF_distName_path}    parameter=administrativeState    operation=update
        ...    value=Unlocked    skip_parameter_relation_errors=False    should_activate=True
        ...    timeout=${600}    connection=${connection_name}
    END
    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=nr
    Check X2 link status from GNB
    loop check alarms
    [Teardown]    Disconnect With BTS    connection=${connection_name}

lock unlock ng link action
    [Timeout]    1 hour
    [Arguments]    ${gnb_index}=${0}    ${index}=${0}
    Start capture syslog via btslog on ute
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${scf_content}=    coam.get_scf    export_type=configurationAndRuntimeObjects    connection=${connection_name}
    ${SERVEDAMF_distName_path_list}=    get_required_distname_path    search_str=${scf_content}    required_distname=SERVEDAMF
    FOR    ${i}    IN RANGE    ${test_round}
        Log To Console    This is ${i} round
        FOR    ${SERVEDAMF_distName_path}    IN    @{SERVEDAMF_distName_path_list}
            coam.lock_ng_link    dist_name=${SERVEDAMF_distName_path}    timeout=${300}    connection=${connection_name}
            coam.unlock_ng_link    dist_name=${SERVEDAMF_distName_path}    timeout=${300}    connection=${connection_name}
        END
    END
    Check X2 link status from GNB
    Wait Until Keyword Succeeds    10min    10s    Check cell failed status after ng link unlocked only
    ...    cell_type=nr    timeout=${300}    connection=${connection_name}
    loop check alarms
    FOR    ${SERVEDAMF_distName_path}    IN    @{SERVEDAMF_distName_path_list}
        coam.lock_ng_link    dist_name=${SERVEDAMF_distName_path}    timeout=${300}    connection=${connection_name}
    END
    Check X2 link status from GNB
    Wait Until Keyword Succeeds    10min    10s    Check cell failed status after ng link locked only
    ...    cell_type=nr    timeout=${300}    connection=${connection_name}
    loop check alarms
    FOR    ${SERVEDAMF_distName_path}    IN    @{SERVEDAMF_distName_path_list}
        coam.unlock_ng_link    dist_name=${SERVEDAMF_distName_path}    timeout=${300}    connection=${connection_name}
    END
    Check X2 link status from GNB
    Wait Until Keyword Succeeds    10min    10s    Check cell failed status after ng link unlocked only
    ...    cell_type=nr    timeout=${300}    connection=${connection_name}
    loop check alarms
    [Teardown]    Run Keywords
    ...    Disconnect With BTS    connection=${connection_name}
    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Continue On Failure    syslog analysis via regex file    index=${index}

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
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    lock unlock per cell    action=unlock    cells_info=${cell_list}[cells]   cell_type=${cell_type}
        ...    AND    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    Check cell status    cell_type=${cell_type}
        ...    AND    loop check alarms
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

recover lock unlock BBMOD
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
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
        ...    AND    loop check alarms
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

recover lock unlock RMOD
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
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
        ...    AND    loop check alarms
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

recover lock unlock ng link action
    [Timeout]    1 hour
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${scf_content}=    coam.get_scf    export_type=configurationAndRuntimeObjects    connection=${connection_name}
    ${SERVEDAMF_distName_path_list}=    get_required_distname_path    search_str=${scf_content}    required_distname=SERVEDAMF
    FOR    ${SERVEDAMF_distName_path}    IN    @{SERVEDAMF_distName_path_list}
        coam.unlock_ng_link    dist_name=${SERVEDAMF_distName_path}    timeout=${300}    connection=${connection_name}
    END
    Check X2 link status from GNB
    Wait Until Keyword Succeeds    10min    10s    Check cell failed status after ng link unlocked only
    ...    cell_type=nr    timeout=${300}    connection=${connection_name}
    loop check alarms
    [Teardown]    Disconnect With BTS    connection=${connection_name}

collect snapshot after reset site
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Save snapshot with BTS    connection=${connection_name}
#    Sleep    5m    reason=due to some developers need snapshot in 6-7 min after recover auto
#    Save snapshot with BTS    connection=${connection_name}
    [Teardown]    Disconnect With BTS    connection=${connection_name}

Common teardown for siso case
    robot_common_operations.Common Case Teardown
    FOR    ${fault_id}    IN    @{allowed_faults_ids}
        AlarmWatchdog.remove_allow_alarms    fault_id=${fault_id}
    END
    Run Keyword If Test Failed    CI_interface.Common Case Teardown

snapshot collected and remove
    [Arguments]    ${gnb_index}=${0}    ${index}=${0}
    Start capture syslog via btslog on ute
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${snapshot_file_path}=    Save snapshot with BTS    connection=${connection_name}
    loop check alarms
    ${rc}    ${output}=    run and return rc and output    command=rm -rf ${snapshot_file_path}
    Should Be Equal As Integers    ${rc}    ${0}
    [Teardown]    Run Keywords
    ...    Disconnect With BTS    connection=${connection_name}
    ...    AND    Stop capture syslog via btslog on ute
    ...    AND    Run Keyword And Continue On Failure    syslog analysis via regex file    index=${index}

collect and get snapshot
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    Save snapshot with BTS    connection=${connection_name}
    [Teardown]    Disconnect With BTS    connection=${connection_name}