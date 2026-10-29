*** Settings ***
Documentation  Test Suite for EE4ALL in TSR
Resource    taf/rfrl/procedures/SISO/ESM/resources/ESM.robot
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    OperatingSystem
Library    Collections
Library    Process
Library    taf.collectors.core   WITH NAME   core
Library    taf.collectors.btslog  WITH NAME   btslog
Suite Setup    Library Update


*** Variables ***
${tl_path}    /home/ute/MN/UTE/robotws/testsuite/Timisoara/RFS/RFS_SOAM/test_line_specific/Timisoara
${config_file_ESM}    ${tl_path}/RFS_623126_MTNRL126v1/esm_configuration.yaml
${bts_mplane_ip}=    10.0.67.126

*** Test Cases ***
[3.0] EE4ALL_KPI_MEASUREMENT_TEST
    [Setup]    Particular Setup
    # Remember to connect to ADMIN CLI and then pass the connection to the keyword
    Get Active SW Version
    Get Alarms Ids And Names
    Get Bts State
    Get SCF with timestamp  before_test
    Run ESM Measurement Procedure
    ...    connection=admin_connect_master
    ...    configuration_yaml_file=${config_file_ESM}
    Get SCF with timestamp  after_test
    Collect BTS Snapshot with timestamp
    [Teardown]  Particular Teardown

*** Keywords ***
Library Update
    ${result_bts}=  Run Process  python  -m  pip  install  -U  taf.rfrl.bts  requests  shell=True
    ...  stdout=/home/ute/test_results/stdout_bts.txt  stderr=/home/ute/test_results/stderr_bts.txt
    Run Keyword If  ${result_bts.rc} != 0  Log To Console  WARNING: pip install taf.rfrl.bts failed with code ${result_bts.rc}
    Run Keyword If  ${result_bts.rc} == 0  Log To Console  SUCCESS: pip install taf.rfrl.bts completed successfully

    ${result_procedures}=  Run Process  python  -m  pip  install  -U  taf.rfrl.procedures  requests  shell=True
    ...  stdout=/home/ute/test_results/stdout_procedures.txt  stderr=/home/ute/test_results/stderr_procedures.txt
    Run Keyword If  ${result_procedures.rc} != 0  Log To Console  WARNING: pip install taf.rfrl.procedures failed with code ${result_procedures.rc}
    Run Keyword If  ${result_procedures.rc} == 0  Log To Console  SUCCESS: pip install taf.rfrl.procedures completed successfully

Particular Setup
    ${setup_status}=  Run Keyword And Return Status  coam.setup admin
    ...  bts_host=${bts_mplane_ip}
    ...  bts_port=443
    ...  admin_api_log_dir=/home/ute/admin_logs/
    ...  name=admin_connect_master
    Log                       Admin Setup Status: ${setup_status}

    Run Keyword If    not ${setup_status}    Fail    Setup Admin Failed
    &{bts_info}               coam.get_bts_info  connection=admin_connect_master  timeout=60
    Log                       ${bts_info}
    Start Syslogs on Local machine

Particular Teardown
    Run Keywords       coam.teardown_admin  connection=admin_connect_master
    ...    AND        Stop Syslogs on Local machine

Collect BTS Snapshot with timestamp
    Log    Collecting Snapshot   console=True
    ${timestamp}=  Get Time  format=timestamp  time_=NOW
    coam.Collect Snapshot  target_file_name=/home/ute/test_results/${timestamp}_snapshot.zip    connection=admin_connect_master
    Log    Snapshot collected: ${timestamp}_snapshot.zip    console=True

Get SCF with timestamp
    [Arguments]    ${stage}
    ${timestamp}=  Get Time  format=timestamp  time_=NOW
    coam.Get Current Scf File  local_dir_path=/home/ute/test_results  file_name=${timestamp}_${stage}_scf.xml    connection=admin_connect_master
    Log    SCF file created: ${timestamp}_${stage}_scf.xml    console=True

Get Active SW Version
    ${software_info_raw}=    coam.Get Software Info    connection=admin_connect_master
    ${active_sw}=    Get From Dictionary    ${software_info_raw}    Active SW version
    Log    \n --> Active SW version on BTS ${active_sw}    console=True
    [Return]    ${active_sw}

Get Alarms Ids And Names
    ${alarms_raw}=    coam.Get Active Alarms    connection=admin_connect_master
    ${active_alarms}=    Create List
    FOR    ${item}    IN    @{alarms_raw}
        ${fid}=    Get From Dictionary    ${item}    faultId
        ${fname}=  Get From Dictionary    ${item}    faultName
        ${pair}=   Create List    ${fid}    ${fname}
        Append To List    ${active_alarms}    ${pair}
    END
    Log    \n --> Active alarms on BTS: ${active_alarms}    console=True

Get Bts State
    ${status_rat}=  coam.Get Bts Statuses    connection=admin_connect_master
    ${bts_state}=    Get From Dictionary    ${status_rat}    proceduralState
    Log    \n --> BTS state: ${bts_state}    console=True

Start Syslogs on Local machine
    Log    Start Syslog on local machine    console=True
    Create_Btslog_log_collection_on_testvm    name=btslog
    core.setup_collectors      names=btslog
    core.start_collectors      names=btslog
    BuiltIn.sleep    2s

Stop Syslogs on Local machine
    Log    Stop Syslog on local machine    console=True
    BuiltIn.sleep    2s
    core.stop_collectors      names=btslog
    core.collect_collectors    names=btslog
    core.teardown_collectors    names=btslog

Create_Btslog_log_collection_on_testvm
    [Arguments]      ${name}=btslog
    ...    ${btslog_path}=/opt/btslog/btslog
    ...    ${btslog_launcher_path}=/opt/btslog/btslog_launcher
    ...    ${log_dir}=/tmp/btslog2
    [Documentation]    create btslog log collector on testvm.
    ...     name: name of the collector. Ex: btslog
    ...     btslog_path: (optional) path of the ‘btslog’ executable default value:”/opt/btslog/btslog”
    ...     btslog_launcher_path: (optional) path of ‘btslog_launcher’
    ...                           executable default value:”/opt/btslog/btslog_launcher”
    ...     log_dir: path from where to get btslog files default value: “/tmp/btslog2”
    ${timestamp_start_test}=  Get Time  format=timestamp  time_=NOW
    ${parameters}=    Create Dictionary    MaxTraceFileSize=1    MaxSysLogFileSize=10000
    ${btslog_configuration}=    Create Dictionary    LOG_CONFIGURATION=${parameters}
    btslog.create_btslog_collector
    ...   name=${name}
    ...   btslog_path=${btslog_path}
    ...   btslog_launcher_path=${btslog_launcher_path}
    ...   log_dir=${log_dir}
    btslog.Set Suite Alias     ${name}
