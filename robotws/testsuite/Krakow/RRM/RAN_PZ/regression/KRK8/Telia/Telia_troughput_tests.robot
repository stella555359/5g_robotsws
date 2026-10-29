*** Settings ***
Resource          taf/rfrl/ue/robot/REAL_UE.robot
Resource          taf/rfrl/procedures/resources/robot/common_setups_and_teardowns.robot
Resource          taf/rfrl/bts/robot/logs_collecting.robot
Variables         taf/rfrl/procedures/resources/python/common_allowed_alarms.py
Library           ute_syslog
Library           taf.ue
Library           resources/syslog_tput_chart.py

Test Setup        Test Setup
Test Teardown     Test Teardown
Suite Setup       Suite Setup
Suite Teardown    Suite Teardown

*** Keywords ***

Test Setup
    Log to console    \n--Test Setup started--\n
    Common preconditions
    Log to console    \n--Test Setup done--\n

Test Teardown
    Log to console    \n--Test Teardown started--\n
    Run keyword and ignore error    taf.ue.Detach UE    UE_1
    Common postconditions
    Log to console    \n--Test Teardown done--\n

Suite Setup
    Log to console    \n--Suite Setup started--\n
    Common Suite Setup
    Log to console    \n--Suite Setup done--\n

Suite Teardown
    Log to console    \n--Suite Teardown started--\n
    Common Suite Teardown
    Log to console    \n--Suite Teardown done--\n

Start syslog capture
    [Arguments]   ${log_dir}=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/  ${log_name}=SYSLOG.LOG
    ...           ${alias}=test_syslog
    ute_syslog.start_syslog  log_dir=${log_dir}  log_name=${log_name}  alias=${alias}

Stop syslog capture
    [Arguments]   ${alias}=test_syslog
    collect_syslog_results  alias=${alias}
    teardown_all_aliases_for_syslog

*** Test Cases ***

TCP_Max_Throughput_1200sec
    Start syslog capture
    Log to console    \n--Syslog capture started--\n
    taf.ue.Require Ue    UE_1    capabilities=REAL_ANDROID_UE
    Log to console    \n--UE require done--\n
    taf.ue.Attach UE    UE_1
    Log to console    \n--Attach UE done--\n

    Start Data Transfer and Verify Troughput    direction=dl    tput=2 Gbits/sec    protocol=tcp    alias=UE_1
    ...    duration=1200s    buffer_server=16M    parallel_streams=8    deviation=10%

    Log to console    \n--Data transfer and verification done--\n
    taf.ue.Detach UE    UE_1
    Log to console    \n--Detach UE done--\n
    Stop syslog capture
    Log to console    \n--Finished syslog capture--\n
    Check Tput Fluctuation    path_to_syslog=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/SYSLOG.LOG
    ...    chart_target=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/tput_chart.html    check_ul=False
    Log to console    \n--Generated Tput fluctuation graph--\n
