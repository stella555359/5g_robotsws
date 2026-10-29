*** Settings ***
Documentation
...    Author:  Zefang.xu
...    Contact: zefang.xu@nokia-sbell.com
...    Feature: CB009126
...    Release: 24R1
Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown
Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Force Tags    5G_RAN_TDD    CRT    SBTS00    QCD_MN_RAN    QCP_RAN_RF
Resource          ../resources/common_resources.robot
Library           ../resources/python/command_execution_in_bts.py
Library           ../resources/python/check_snapshot.py

*** Variables ***
@{ALLOWED_FAULT}    2927
${scfc_file1}      CB009126_ABIP_AVQL_NRTDD_100M_A1_gscn_639360_1xNRCELL.xml
${scfc_file2}      CB009126_ABIP_AVQL_NRTDD_40M_A8_gscn_637344_1xNRCELL.xml
${scfc_file3}      CB009126_ABIP_AVQL_NRTDD_60M_A5_gscn_638016_1xNRCELL.xml
${scfc_file4}      CB009126_ABIP_AVQL_NRTDD_80M_A1_gscn_638688_1xNRCELL.xml

*** Test Cases ***
CB009126_TC01_NR_FR1_TDD_eCPRI_ABIP_RU lock_unlock
    [Tags]    ABIP    SMAwave    CB009126    CB009126_US01    Trunk    QL3
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB009126${/}${scfc_file1}
    RU lock and unlock for gnb    ru_index=1
    SMAwave L3 call    cell_id=1    dl_tput=970M    ul_tput=155M    dl_deviation=10%    rat=5G    band=78    duration=60
    ${bfcali_output}    connect_and_execute_command_on_ru    rmod_type=AVQL    command=bfcali -stat
    check_bfcali_state    ${bfcali_output}

CB009126_TC02_NR_FR1_TDD_eCPRI_ABIP_Different cell parameters_TDD pattern A1_80M
    [Tags]    ABIP    SMAwave    CB009126    CB009126_US02    Trunk    QL3
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB009126${/}${scfc_file4}
    Site Reset Via WebUI
    Log To Console    \n[INFO] Site resetting ...
    Sleep    120s
    Wait Until Keyword Succeeds    300 min    30 sec    Check If All Cells Are OnAir
    SMAwave L3 call    cell_id=1    dl_tput=970M    ul_tput=120M    dl_deviation=10%    rat=5G    band=78    duration=60

CB009126_TC03_NR_FR1_TDD_eCPRI_ABIP_Different cell parameters_TDD pattern A5_60M
    [Tags]    ABIP    SMAwave    CB009126    CB009126_US03    Trunk    QL3
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB009126${/}${scfc_file3}
    SMAwave L3 call    cell_id=1    dl_tput=735M    ul_tput=80M    dl_deviation=10%    rat=5G    band=78    duration=60

CB009126_TC04_NR_FR1_TDD_eCPRI_ABIP_Different cell parameters_TDD pattern A8_40M
    [Tags]    ABIP    SMAwave    CB009126    CB009126_US04    Trunk    QL3
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB009126${/}${scfc_file2}
    SMAwave L3 call    cell_id=1    dl_tput=480M    ul_tput=50M    dl_deviation=10%    rat=5G    band=78    duration=60

CB009126_TC05_NR_FR1_TDD_eCPRI_ABIP_Different cell parameters_TDD pattern A1_100M
    [Tags]    ABIP    SMAwave    CB009126    CB009126_US05    Trunk    QL3    hhh
    Full Commission gNB SCFC and wait for onair    ${SCFC_path}${/}CB009126${/}${scfc_file1}
    # ADMIN Set RAD debug parameters    NrUlPhy    enableNdmSrsBfTrace    1
    # ute_syslog.Start Syslog    log_dir=${SUITE_LOG_DIRECTORY}    log_name=btslog_UpAnalyzer.LOG    ip=192.168.255.126
    # ...    ssh_username=${TEST_PC_USERNAME}    ssh_password=${TEST_PC_PASSWORD}    alias=UpAnalyzer
    SMAwave L3 call    cell_id=1    dl_tput=1200M    ul_tput=155M    dl_deviation=10%    rat=5G    band=78    duration=60
    # check UpAnalyzer is Started in syslog
    ${bfcali_output}    connect_and_execute_command_on_ru    rmod_type=AVQL    command=bfcali -stat
    check_bfcali_state    ${bfcali_output}
    [Teardown]    Run Keywords    common_resource_suite.Common Test Teardown    AND    Get Test Snapshot log
    ...    AND    check L1low and L1sw logs in snapshot    ${latest_snapshot}

*** Keywords ***
RU lock and unlock for gnb
    [Arguments]    ${ru_index}=1
    5G RMOD Operation via WebUI     locked     ${ru_index}
    5G RMOD Operation via WebUI     unlocked     ${ru_index}
    Wait Until Keyword Succeeds    300 min    30 sec    Check If All Cells Are OnAir

Check UpAnalyzer is Started in syslog
    ${output}=    ute_syslog.Message Should Exist In Syslog File    regexp=nrDl Stats     alias=UpAnalyzer
    Log    ${output}
    ute_syslog.Collect Syslog Results     destination=${SUITE_LOG_DIRECTORY}    alias=UpAnalyzer
    Should Not Be Empty    ${output}    "[ERROR] UpAnalyzer is not started in syslog"
    ${target_list}    Set Variable    ${output.strip().split('\n')}[-2:]
    FOR    ${item}    IN    @{target_list}
        Log To Console    ${item.split('>:')}[0]
        ${value_string}    Set Variable    ${item.split('>:')}[-1]
        Log To Console    ${value_string}
        Should Not Be Empty    ${value_string}
    END
    [Teardown]    ute_syslog.stop_syslog    alias=UpAnalyzer

Extract trbl log and copy to workspace
    [Arguments]    ${snapshot}    ${workspace}=/home/ute/python-project_new/workspace/CRT/GNB10386_ABIP/
    ${first_zip}     ${path}     Get Target Logs From Snapshot    ${snapshot}    D_l1a_up_trace.tgz
    ${second_zip}    ${path1}    Extract Target file From Compressed File     ${snapshot}    ${first_zip}
    ${third_zip}     ${path2}    Extract Target file From Compressed File     ${path1}/${second_zip}    D_l1a_up_trace.tgz
    Directory Should Exist    ${workspace}    "[ERROR]Directory NOT found on VM: ${workspace}"
    Create Directory    ${workspace}/${active_sw}
    ${cp_trbl_status}      Run    cp ${path2}/${third_zip} ${workspace}/${active_sw}
    ${cp_syslog_status}    Run    cp ${SUITE_LOG_DIRECTORY}/btslog_UpAnalyzer.LOG ${workspace}/${active_sw}
    Should Exist    ${workspace}/${active_sw}/${third_zip}    "[ERROR] ${third_zip} is NOT found in ${workspace}/${active_sw}"

Check L1low And L1sw Logs In Snapshot
    [Arguments]    ${snapshot_log}
    ${build_info_dict}    Get L3 build from TargetBD file
    ${snapshot_documentation}    Get Snapshot Documentation    ${SUITE_LOG_DIRECTORY}    ${build_info_dict['PackageName']}
    ${documentation}    ${path}    Extract Target file From Compressed File    ${snapshot_documentation}    SBTS.*_trbl_log_list.csv
    check snapshot    avql    ${snapshot_log}    ${path}/${documentation}    bbu_type=THOR

Get Test Snapshot log
    [Arguments]    ${log_path}=${TEST_LOG_DIR}
    ${snapshot_logs}    Run    find ${log_path}/../ -name Snapshot*
    ${latest_snapshot}    Set Variable    ${snapshot_logs.strip().split('\n')}[-1]
    File Should Exist    ${latest_snapshot}    [ ERROR ] Snapshot log is NOT found: ${snapshot_logs}
    Set Test Variable    ${latest_snapshot}
