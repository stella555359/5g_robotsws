*** Settings ***
Force Tags    PY36
Documentation
...   author: jia-rebecca.liu@nokia-sbell.com
...   contact: Liu Jia-Rebecca

Suite Setup        Qos TL suite setup
Suite Teardown     Qos TL suite teardown

Resource       ../Resources/Qos_Latency_comm_keyword.robot




*** Variables ***
${E500_SCRIPTS_BASE}    ${CURDIR}/../TestData/E500_scripts
${E500_SCRIPTS_CA}    ${CURDIR}/../TestData/E500_scripts_CA
${E500_SCRIPTS_50UE}    ${CURDIR}/../TestData/E500_scripts_50UEs
${E500_SCRIPTS_Handover}    ${CURDIR}/../TestData/E500_scripts_Handover
${TMA_APP_ALIAS}    e500
#${testcenter_tclfile_208M_80}    /opt/workspace/tester_center_script/start_dlul_traffic_for_208M_80.tcl
${options}    -i any -p sctp -s 0
${wiresharklog_210}     wiresharklog_210
${wiresharklog_208}     wiresharklog_208
${wiresharklog_100}     wiresharklog_100
${wiresharklog_CA}     wiresharklog_CA
${wiresharklog_Handover}     wiresharklog_Handover
${wiresharklog_11123}     wiresharklog_11123
@{ALLOWED_FAULT_qos}    4655    4654    61652    61524    4592    7311    7300    61649    61618
${template_name}      ${CURDIR}/../TestData/kpi_report_releated_parameters.yml

*** Test Cases ***
[1]CB010764-B#3_001_PRACH_noise_power_real_estimate_reported_with_pegging_of_CB008021_PM_counters
    [Documentation]    CB010764-B
    [Tags]    CB010764-B    CRT_TRUNK
    [Timeout]    1 hour
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    sleep    5s
    ${time2_start}=    Get current date    result_format=%Y%m%d%H%M%S    time_zone=UTC
    Get record time      label=start
    [Teardown]    Run Keywords
    ...    robot_common_operations.Common Case Teardown
    ...    AND    Run Keyword And Ignore Error    CI_interface.Common Case Teardown



[1]E2E_latency_and_Robustness_Testing_208M
    [Documentation]
    [Tags]    qos_208
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    log to console     \n*** start viavi preparation and attach ***\n
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    Precondition for VAIVI with TM500
    ${time2_start}=    Get current date    result_format=%Y%m%d%H%M%S    time_zone=UTC
    Get record time      label=start
    Prepare with QoS counter time caculate    period=start
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog_208}    options=${options}
    ${cpif_02}    Cobham retry 30ues attach if failed    e500_script_path=${E500_SCRIPTS_BASE}    wiresharklog=${wiresharklog_208}
    Start Traffic with TC    testcenter_tclfile=${testcenter_tclfile_208M}
    Cobham 30UE detach and kill the TMA    e500_script_path=${E500_SCRIPTS_BASE}
    Prepare with QoS counter time caculate    period=end
    Get record time      label=end
    ${time2_end}=    Get current date    result_format=%Y%m%d%H%M%S    time_zone=UTC
    Get counter and write into csv
    ...    test_start=${time2_start}    test_end=${time2_end}    folder_name=208M_PM    excel_name=data_record_208M.csv
#    Get counter and write into csv
#    ...    test_start=20240921035500    test_end=20240921061000   folder_name=208M_PM    excel_name=data_record_208M.csv
    [Teardown]    Run keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Run Keyword And Ignore Error     Cobham 30UE detach and kill the TMA    e500_script_path=${E500_SCRIPTS_BASE}
    ...    AND    QoS Case Teardown for COAM
    ...    AND    sleep    15min
    ...    AND    generate new report and get report id     file_path=${template_name}     #template file path,download from SG3/kpi_
    ...                                                     report_name=E2E_208M      #zidingyi name
    ...                                                     tl_id=234
    ...                                                     package_version=${package_version}
    ...                                                     start_time=${start_time}
    ...                                                     end_time=${end_time}
#    ...    AND     Crawling and download kpi data           file_path=${epc_log_path}
#    ...                                                     report_id=${report_id}
#    ...                                                     file_name=qos_208M
#    ...                                                     tl_id=234
    ...    AND    download_kpi_file    report_id=${report_id}
    ...                                path=${epc_log_path}




[1]E2E_Rep_010_03962758_Slicing_PMQAP_counter_Monitoring
    [Documentation]
    [Tags]    Slicing_PMQAP
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
#    Common Case TestLine Setup    ModifySCF_Aftercommission=True
#    ...                           Modify_Para_Online=${Modify_Para_Online_010}
    log to console     \n*** start viavi preparation and attach ***\n
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    Adjust the TL Topyoung attenuation value    PA_values=${13}
    Precondition for VAIVI with TM500    e500_script_path=${E500_SCRIPTS_50UE}
    ${time1_start}=    Get current date    result_format=%Y%m%d%H%M%S    time_zone=UTC
    Get record time      label=start
    Prepare with QoS counter time caculate    period=start
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog_11123}    options=${options}
    ${cpif_01}    Cobham retry 50ues attach if failed    e500_script_path=${E500_SCRIPTS_50UE}    wiresharklog=${wiresharklog_11123}
    Start Traffic with TC    testcenter_tclfile=${testcenter_tclfile_slice}
    sleep    5s
    Cobham 30UE detach and kill the TMA    e500_script_path=${E500_SCRIPTS_50UE}
    Prepare with QoS counter time caculate    period=end
    Get record time      label=end
    ${time1_end}=    Get current date    result_format=%Y%m%d%H%M%S    time_zone=UTC
    Get cell2 counter and write into csv    test_start=${time1_start}    test_end=${time1_end}
    [Teardown]    Run keywords
    ...    robot_common_operations.Common Case Teardown    AND
    ...    Adjust the TL Topyoung attenuation value    PA_values=${20}    AND
#    ...    Common Case TestLine Setup    ModifySCF_Aftercommission=True
#    ...                                  Modify_Para_Online=${Modify_Para_recovery_010}      AND
    ...    Run Keyword And Ignore Error     Cobham 30UE detach and kill the TMA    e500_script_path=${E500_SCRIPTS_50UE}
    ...    AND    QoS Case Teardown for COAM
    ...    AND    sleep    15min
    ...    AND    generate new report and get report id     file_path=${template_name}     #template file path,download from SG3/kpi_
    ...                                                     report_name=E2E_slice      #zidingyi name
    ...                                                     tl_id=234
    ...                                                     package_version=${package_version}
    ...                                                     start_time=${start_time}
    ...                                                     end_time=${end_time}
    ...    AND    download_kpi_file    report_id=${report_id}
    ...                                path=${epc_log_path}


[1]E2E_latency_and_Robustness_Testing_for_CA
    [Documentation]
    [Tags]     CA
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    log to console     \n*** start viavi preparation and attach ***\n
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    Adjust the TL Topyoung attenuation value    PA_values=${20}    PA_values_FDD=${20}
    #Common Case TestLine Setup    ModifySCF_Aftercommission=True
    #...                           Modify_Para_Online=${Modify_Para_Online_CA}
    log to console     \n*** start viavi preparation and attach ***\n
    Precondition for VAIVI with TM500    e500_script_path=${E500_SCRIPTS_CA}
    ...                                  init_config=Init_Config_CA.txt    cell_config=SA_5G_Cell_Config_CA.txt
    ${time_CA_start}=    Get current date    result_format=%Y%m%d%H%M%S    time_zone=UTC
    Get record time      label=start
    Prepare with QoS counter time caculate    period=start
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog_CA}    options=${options}
    ${cpif_CA}    Cobham retry 30ues attach if failed    e500_script_path=${E500_SCRIPTS_CA}    wiresharklog=${wiresharklog_CA}
    ...                                                  UE_attach=SA_5G_UEattach_CA.txt
    ...                                                  UE_detach=SA_5G_UEdetach_CA.txt
    Start Traffic with TC    testcenter_tclfile=${testcenter_tclfile_CA}
    sleep    30s
    Cobham 30UE detach and kill the TMA    e500_script_path=${E500_SCRIPTS_BASE}
    Prepare with QoS counter time caculate    period=end
    Get record time      label=end
    ${time_CA_end}=    Get current date    result_format=%Y%m%d%H%M%S    time_zone=UTC
    Get counter and write into csv    test_start=${time_CA_start}    test_end=${time_CA_end}   folder_name=CA_CELL1_BTS
    ...                               excel_name=data_record_CA_cell1.csv
    Get cell2 counter and write into csv    cellindex=${3}
    ...         test_start=${time_CA_start}    test_end=${time_CA_end}    excel_name=data_record_CA_cell3.csv
    [Teardown]    Run keywords
    ...    robot_common_operations.Common Case Teardown    AND
    #...    Common Case TestLine Setup    ModifySCF_Aftercommission=True
    #...                                  Modify_Para_Online=${Modify_Para_recovery_CA}      AND
    ...    Run Keyword And Ignore Error     Cobham 30UE detach and kill the TMA    e500_script_path=${E500_SCRIPTS_CA}
    ...    AND    QoS Case Teardown for COAM
    ...    AND    sleep    15min
    ...    AND    generate new report and get report id     file_path=${template_name}     #template file path,download from SG3/kpi_
    ...                                                     report_name=E2E_CA      #zidingyi name
    ...                                                     tl_id=234
    ...                                                     package_version=${package_version}
    ...                                                     start_time=${start_time}
    ...                                                     end_time=${end_time}
    ...    AND    download_kpi_file    report_id=${report_id}
    ...                                path=${epc_log_path}


[1]E2E_latency_and_Robustness_Testing_for_Handover
    [Documentation]
    [Tags]     handover
    [Setup]
    robot_common_operations.Common Case Setup    allowed_faults_ids=8000
    log to console     \n*** start viavi preparation and attach ***\n
    AlarmWatchdog.add_allow_alarms    fault_id=8000
    Adjust the TL Topyoung attenuation value    PA_values=${20}    PA_values_FDD=${20}
    #Common Case TestLine Setup    ModifySCF_Aftercommission=True
    #...                           Modify_Para_Online=${Modify_Para_Online_CA}
    log to console     \n*** start viavi preparation and attach ***\n
    Precondition for VAIVI with TM500    e500_script_path=${E500_SCRIPTS_Handover}
    ...                                  init_config=Init_Config_Handover.txt    cell_config=SA_5G_Cell_Config_Handover.txt
    ${time_CA_start}=    Get current date    result_format=%Y%m%d%H%M%S    time_zone=UTC
    Get record time      label=start
    Prepare with QoS counter time caculate    period=start
    Start Capture CP-IF logs from Container     tcpdump_collector_name=${wiresharklog_Handover}    options=${options}
    ${cpif_CA}    Cobham retry 30ues attach if failed    e500_script_path=${E500_SCRIPTS_Handover}    wiresharklog=${wiresharklog_Handover}
    ...                                                  UE_attach=SA_5G_UEattach_Handover.txt
    ...                                                  UE_detach=SA_5G_UEdetach_Handover.txt
    Start Traffic with TC    testcenter_tclfile=${testcenter_tclfile_208M}
    sleep    30s
    Cobham 30UE detach and kill the TMA    e500_script_path=${E500_SCRIPTS_BASE}
    Prepare with QoS counter time caculate    period=end
    Get record time      label=end
    ${time_CA_end}=    Get current date    result_format=%Y%m%d%H%M%S    time_zone=UTC
    Get counter and write into csv    test_start=${time_CA_start}    test_end=${time_CA_end}   folder_name=CA_CELL1_BTS
    ...                               excel_name=data_record_CA_cell1.csv
    Get cell2 counter and write into csv    cellindex=${3}
    ...         test_start=${time_CA_start}    test_end=${time_CA_end}    excel_name=data_record_CA_cell3.csv
    [Teardown]    Run keywords
    ...    robot_common_operations.Common Case Teardown    AND
    #...    Common Case TestLine Setup    ModifySCF_Aftercommission=True
    #...                                  Modify_Para_Online=${Modify_Para_recovery_CA}      AND
    ...    Run Keyword And Ignore Error     Cobham 30UE detach and kill the TMA    e500_script_path=${E500_SCRIPTS_Handover}
    ...    AND    QoS Case Teardown for COAM
    ...    AND    sleep    15min
    ...    AND    generate new report and get report id     file_path=${template_name}     #template file path,download from SG3/kpi_
    ...                                                     report_name=E2E_Handover      #zidingyi name
    ...                                                     tl_id=234
    ...                                                     package_version=${package_version}
    ...                                                     start_time=${start_time}
    ...                                                     end_time=${end_time}
    ...    AND    download_kpi_file    report_id=${report_id}
    ...                                path=${epc_log_path}


*** Keywords ***
Set excel name
    ${test_name}=    set variable    ${TEST_NAME}
    @{name}    String.split string    string=${test_name}    separator=]
    Set Suite Variable    ${excel_name}    ${name}[1]
