*** Settings ***
Documentation    degrade bts from higher release to lower release

Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/SiSo_common_keywords.robot
Library     testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/TDD_FDD_SFE_Regression/SISO_Resource/SiSo_common_keywords.py
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/SG3/robot/upgrade_rollback_keywords.robot
Resource    testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/TDD_FDD_HO_common_keyword.robot
Variables   testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/5GC001785/Resources/upgrade_and_rollback_parameters.py

Suite Setup            get_test_info

*** Variables ***
${connection_name}    GNB_OAM
${epc_log_path}    /tmp/
${scf_file_paths}    /opt/workspace/CRT/Master/SCF_file/
${tl_scf_files}    gNB1_Golden_SCF.xml
${test_info_path}    /opt/workspace/SCF/
${test_info_file}    SiSo_test_info.yml

*** Test Cases ***
degrade
    modify related paras to false
    lock all rmods
    lock all cells
    upgrade
    commissioning reset action


*** Keywords ***
get_test_info
    ${test_info}=    SiSo_common_keywords.get_info_from_file    file_path=${test_info_path}${test_info_file}
    ${check_alarms_times_status}=    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    dictionary=${test_info}    key=check_alarms_times
    ${scf_file_path_status}=    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    dictionary=${test_info}    key=scf_file_path
    ${tl_scf_file_status}=    Run Keyword And Return Status
    ...    Dictionary Should Contain Key    dictionary=${test_info}    key=tl_scf_file
    Set Suite Variable    ${test_round}    ${test_info}[test_round]
    Set Suite Variable    ${gnb_index}    ${test_info}[gnb_index]
    IF    ${check_alarms_times_status} == ${True}
        Set Suite Variable    ${check_alarms_times}    ${test_info}[check_alarms_times]
    ELSE
        Set Suite Variable    ${check_alarms_times}    ${1}
    END
    IF    ${scf_file_path_status} == ${True}
        Set Suite Variable    ${scf_file_path}    ${test_info}[scf_file_path]
    ELSE
        Set Suite Variable    ${scf_file_path}    ${scf_file_paths}
    END
    IF    ${tl_scf_file_status} == ${True}
        Set Suite Variable    ${tl_scf_file}    ${test_info}[tl_scf_file]
    ELSE
        Set Suite Variable    ${tl_scf_file}    ${tl_scf_files}
    END
    Set Suite Variable    ${gnb_instance}     ${tl.gnbs[${gnb_index}].instance_id}

modify related paras to false
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    coam.perform_parameter_recommissioning
    ...    dist_name=MRBTS-${gnb_instance}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actValidationOnUpgrade
    ...    operation=update
    ...    value=false
    ...    skip_parameter_relation_errors=${False}
    ...    timeout=${600}
    ...    connection=${connection_name}
    coam.perform_parameter_recommissioning
    ...    dist_name=MRBTS-${gnb_instance}/MNL-1/MNLENT-1/FEATCADM-1
    ...    parameter=actTargetConfigPrep
    ...    operation=update
    ...    value=false
    ...    skip_parameter_relation_errors=${False}
    ...    timeout=${600}
    ...    connection=${connection_name}
    [Teardown]    Disconnect With BTS    connection=${connection_name}

lock all rmods
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${bts_info}=    Get info with BTS
    ${radioModules}    set variable    ${bts_info}[radioModules][rmod]
    FOR    ${radio}    IN    @{radioModules}
        Lock required dist_name with BTS    dist_name=${radio}[id][configuration]    connection=${connection_name}
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}

lock all cells
    lock per cell action    gnb_index=${gnb_index}

lock per cell action
    [Timeout]    2 hours
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        IF    '${Length}' != '0'
            lock unlock per cell    action=lock    cells_info=${cell_list}[cells]    cell_type=${cell_type}
            Wait Until Keyword Succeeds    5min    10s    Check cell failed status after lock    cell_type=${cell_type}
        ELSE
            Continue For Loop
        END
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

upgrade
    [Arguments]    ${node_type}=gnb    ${index}=${0}    ${connection}=${node_type}_${index}
    ...    ${node_no}=${0}
    ...    ${v_index}=${0}
    get_download_link_release_name
    get version info    index=${node_no}    v_index=${v_index}
    check_and_download_packet
    Log to console    1.check current version
    Get current version to check    connection=${connection}    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    Log to console    2.upgrade
    Wait Until Keyword Succeeds    3x    1m    upgrade build    connection=${connection}
    ...    node_type=${node_type}    gnb_index=${index}    enb_index=${index}
    sleep    1m
    Log to console    3. check version after upgrade
    wait until keyword succeeds     40min    2min    Check if Upgrade Successfully via ssh    gnb_index=${index}

for loop Get alarms to check
    FOR    ${per_time}    IN RANGE    ${check_alarms_times}
        SiSo_common_keywords.Get alarms to check
        Sleep    10s
    END

commissioning reset action
    [Arguments]    ${gnb_index}=${0}
    Connect with BTS    gnb_index=${gnb_index}    connection=${connection_name}
    commissioning and check status    scf_file=${scf_file_path}${tl_scf_file}    timeout=${600}    connection=${connection_name}
    Sleep    2m
    Wait Until Keyword Succeeds    5min    10s    SiSo_common_keywords.Check systemModule status
    ${check_result}=    check if ASOD or ASOE or ASOF or ASOG or ASOH testline    gnb_index=${gnb_index}
    Run Keyword If    ${check_result} == ${False}
    ...    Wait Until Keyword Succeeds    10min    10s    SiSo_common_keywords.Check basebandModule status
    ...    ELSE    Log to console    Skip the status checking for ABIL as the blade type is ASOD or ASOE or ASOF or ASOG or ASOH
    Wait Until Keyword Succeeds    20min    10s    SiSo_common_keywords.Check radioModule status
    ${cell_list}=    Get cell list info
    ${cells_type}=    Get Dictionary Keys    ${cell_list}[cells]
    ${cells_info}=    Get Dictionary Values    ${cell_list}[cells]
    FOR    ${cell_index}    ${cell_type}    IN ENUMERATE    @{cells_type}
        ${Length}=    Get Length    ${cells_info}[${cell_index}]
        Run Keyword If    '${Length}' != '0'    Run keywords
        ...    Check X2 link status from GNB
        ...    AND    Wait Until Keyword Succeeds    10min    10s    SiSo_common_keywords.Check cell status    cell_type=${cell_type}
        ...    AND    for loop Get alarms to check
        ...    ELSE    Continue For Loop
    END
    [Teardown]    Disconnect With BTS    connection=${connection_name}