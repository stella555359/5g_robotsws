*** Settings ***
Library    testsuite.Hangzhou.TRS.RAN_PZ_HAZ_34.None_feature_CI.scf_scout.ScfScout    WITH NAME    tss
Library    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Library    testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.gnb_alarm.AlarmWatchdog    WITH NAME    AlarmWatchdog
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
Resource    testsuite/Hangzhou/TRS/RAN_PZ_HAZ_34/None_feature_CI/auto_commssion.robot
Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot

Documentation
...    Author:tingting zhong
...    contact:tingting.zhong@nokia-sbell.com
...    squad group:SG_04

Force Tags            5G_RAN    5G_RAN_TDD    RAN_5G_TDD    RAN_5G
...    PY36

*** Variables ***
${check_l3_call}    ${True}
${check_pass}    ${True}
&{scf_results}
&{FAS_scf_id}
&{fas_results}

*** Test Cases ***
AUTO Check
    [Setup]    Prepare FAS check
    Check SCFs
    [Teardown]    tss.teardown_scout_api

*** Keywords ***
Check SCFs
    @{scf_list}    String.Split String    ${customed_scf_list}    ,
    FOR    ${scf_file}    IN    @{scf_list}
        set test variable    ${customed_scf_name}    ${scf_file}
        ${scf_result}    run keyword and return status    Check SCF
        set to dictionary    ${scf_results}    ${scf_file}    ${scf_result}
        log to console    SCF ${scf_file} L3 call check result:${scf_result}
        ${check_pass}    Evaluate    ${scf_result} and ${check_pass}
    END
    run keyword if    ${FAS_scf_id}    Loop SCF FAS
    ...    ELSE    Log    None SCF commissioned, ignore FAS check.    WARN
    tss.log_results    ${scf_results}    ${fas_results}
    Run Keyword if    ${check_pass}
    ...    log to console    All SCF passed.
    ...    ELSE    Fail    Some SCF failed.

Check SCF
    [Arguments]
    AlarmWatchdog.init_watchdog    interval=5 sec    bts_config=${tl.gnbs[0]}
    Log to console    Commissioning ${customed_scf_name}
    ${customed_scf_name}    CI_commssion.common commissioning
    FETCH SCF by FAS    ${customed_scf_name}
    run keyword if    ${check_l3_call}    log to console    Checking L3 call
    run keyword if    ${check_l3_call}    test l3 call
    [Teardown]    Teardown Steps

test l3 call
    [Arguments]    ${ue_index}=${0}    ${dl_tp}=100    ${ul_tp}=10    ${duration}=30    ${target_avg_percent}=0.5
    ...    ${log_type}=Aasyslog    ${cell_id}=1    ${connection}=GNB_OAM
    ${ue_type}    translate_power_ue_type_from_testline    ue_index=${ue_index}
    power_ue.Prepare UE    ue_type=${ue_type}    ue_index=${ue_index}
    ${5Grach_ed}    power_ue.UE Attach    ue_type=${ue_type}    ue_index=${ue_index}     log_type=${log_type}
	sleep    30s
    ${start_traffic_duration}    evaluate    ${duration}+${120}
    power_ue.Start traffic    ue_type=${ue_type}    direction=dl    throughput=${dl_tp}M
    ...    duration=${start_traffic_duration}    ue_index=${ue_index}
    power_ue.Start traffic    ue_type=${ue_type}    direction=ul    throughput=${ul_tp}M
    ...    duration=${start_traffic_duration}    ue_index=${ue_index}
    ${log}    power_ue.Collect Tput    ue_type=${ue_type}    duration=${duration}    check_source=${log_type}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=dl    ue_index=${ue_index}
    power_ue.Stop traffic    ue_type=${ue_type}    direction=ul    ue_index=${ue_index}
    ${cells}    Get Cells    cell_id=${cell_id}
    power_ue.Check Tput    ue_type=${ue_type}    direction=dl    target_throughput=${dl_tp}
    ...    target_avg_percent=${target_avg_percent}    ue_index=${ue_index}    min_percent=0.1
    ...    cells=${cells}    log=${log}
    power_ue.Check Tput    ue_type=${ue_type}    direction=ul    target_throughput=${ul_tp}
    ...    target_avg_percent=${target_avg_percent}    ue_index=${ue_index}    min_percent=0.1
    ...    cells=${cells}    log=${log}
    [Teardown]    power_ue.UE Detach  ue_type=${ue_type}    ue_index=${ue_index}

Teardown Steps
    run keyword and ignore error    AlarmWatchdog.teardown_watchdog

Prepare FAS check
    ${scout_tl_name}    tss.get_testline_id    tl=${tl}
    tss.setup_scout    scout_testline_name=${scout_tl_name}

FETCH SCF by FAS
    [Arguments]    ${scf_name}
    ${scf_id}    tss.request_scf
    set to dictionary    ${FAS_scf_id}    ${scf_name}    ${scf_id}

Loop SCF FAS
    Sleep    5m
    FOR    ${scf_file}    IN    @{FAS_scf_id.keys()}
        ${scf_result}    run keyword and return status    Check FAS    ${scf_file}
        set to dictionary    ${fas_results}    ${scf_file}    ${scf_result}
        log to console    SCF ${scf_file} FAS check result:${scf_result}
        ${check_pass}    Evaluate    ${scf_result} and ${check_pass}
    END

Check FAS
    [Arguments]    ${scf_name}
    ${fas_id}    tss.get_fas_id    ${FAS_scf_id["${scf_name}"]}    timeout=600
    tss.check_features    ${feature_list}    ${fas_id}    ${testline_name}    ${scf_name}

Get Cells
    [Arguments]  ${cell_id}    ${connection}=GNB_OAM
    Connect to gnb coam via ssl    connection=${connection}
    ${cell_mapping}    get_relation_mapping_between_cell_index_and_nrCellIdentity    connection_alias=${connection}
    ${nrCellIdentity}    Convert To String    ${cell_mapping[${cell_id}]['nrCellIdentity']}
    ${cells}    Create List    ${nrCellIdentity}
    [Return]  ${cells}
    [Teardown]    COAM Teardown gnb connections    connection=${connection}
