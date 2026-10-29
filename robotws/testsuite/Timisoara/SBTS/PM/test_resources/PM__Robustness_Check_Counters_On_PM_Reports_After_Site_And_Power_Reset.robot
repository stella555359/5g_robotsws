*** Settings ***
Documentation
...  First, TC is setting reportingIntervalPM on 60 min in case it is not and waits after new PM report. Initial values are
...  set for the number of all counters and the number of counters set on 0 for each technology: NR, LTE, WCDMA and TNL.
...  Site reset is performed. TC waits for new PM report and compares the new values with the ones mentioned above.
...  Site power reset is performed and after generating a new PM report, the new values for counters numbers are compared to the initial ones.
...  For both reset cases, after SBTS is up the number of all counters must be the same and the number of counters set on 0 can be different.
...  Additional check for DN reported on counters before and after reset operations is implemented using python resource.
...  DN changes for selected counters are reported as WARN only for BBPOOL-x to BBPOOL-y transitions. Added detailed logging and improved report.

Resource  ../../common_resources/ca_PM_general.robot
Library  ../../common_resources/python_resources/PM/check_PM_reports.py


*** Variables ***
${RESTORE_TIMEOUT}  30m  # Timeout for BTS to startup after reset, default value 30 min
${COUNTER_EXCEPTION}  ${EMPTY}  # eg.: M8092C0,M8092C1,M8092C2,M8092C3 ,allowed only for BBPOOL-x -> BBPOOL-y DN changes


*** Keywords ***
TC__PM__Robustness_Check_Counters_On_PM_Reports_After_Site_And_Power_Reset
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-28693
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 03.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28693 - Initial TAT creation
    ...  - 25.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28825 - Remove additional sleeps
    ...  - 27.02.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-28847 - Add TC to watchdog
    ...  - 21.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29561 - CPU overload print check in snapshot and syslog
    ...  - 25.08.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29769 - Change pattern for PMSTAT process
    ...  - 22.12.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-30359 - Set test failed if printOverload appeared
    ...  - 30.01.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30460 - Check DN differencies and counter numbers with python resource
    ...  - 04.03.2026 - https://jiradc.ext.net.nokia.com/browse/TAT-30590 - Add counter_exception support for PM DN comparison.

    Set Tags  CA-PM  OWNER-mohamad.al_hamwi@nokia.com  AUTHOR-andrada-lavinia.baleti@nokia.com  MAINTAINER-andrada-lavinia.baleti@nokia.com
    ...  GROUP_IN_CHARGE-TIM_1_Vrf

    Step0: TC Precondition
    Step1: Get Initial PM Report
    Step2: Perform Site Reset
    Step3: Check Counters Number And DN After Site Reset
    Step4: Perform Site Power Reset
    Step5: Check Counters Number And DN After Site Power Reset


Step0: TC Precondition
    ${param_list}  Create List  reportingIntervalPm
    ${parameter}  Get Parameter By Distname  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  ${param_list}
    ${reporting_interval}  Set Variable  ${parameter}[0][parameters][reportingIntervalPm]
    IF  '${reporting_interval}'!='60min'
        Perform Parameter Recommissioning  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/PMCADM-1  reportingIntervalPm  update  60min
        ...  skip_parameter_relation_errors=True
        Sleep Until New Cycle  minutes_for_cycle=60min
        Sleep  1min  TC will wait until PM report is loaded.
        RETURN
    END

    SSHLibrary.Open Connection  ${OAM_BTS_IP}  prompt=:~ >  alias=pm_statistics
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]

    ${pm_gz_files}  SSHLibrary.List Files In Directory  /rom/uri/PERFMON_FILES  PM.*\.xml\.gz
    ${list_is_empty}  Run Keyword And Return Status  Should Be Empty  ${pm_gz_files}
    IF  ${list_is_empty}
        Sleep Until New Cycle  minutes_for_cycle=60min
        Sleep  1min  TC will wait until PM report is loaded.
    END

    [Teardown]  Run Keyword And Ignore Error  SSHLibrary.Close Connection


Step1: Get Initial PM Report
    Log  \nStep1: Get Initial PM Report  console=true
    SSHLibrary.Open Connection  ${OAM_BTS_IP}  prompt=:~ >  alias=pm_statistics
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]

    ${xml_file}  Extract Last Gz File From SBTS AND Get XML File Name
    SSHLibrary.Get File  /rom/uri/PERFMON_FILES/${xml_file}  ${BTS_FILES}/Initial_PM_Report.xml
    SSHLibrary.Execute Command  rm /rom/uri/PERFMON_FILES/${xml_file}

    Collect Snapshot  target_file_name=${BTS_FILES}/initial_snapshot.zip  timeout=1200

    [Teardown]  SSHLibrary.Close Connection


Step2: Perform Site Reset
    Log  \nStep2: Perform site reset  console=true
    coam.Reset Site  timeout=600
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  1m
    ...  Admin Check All Required State
    Collect All Syslogs
    Start Syslog  alias=test_syslog  log_dir=${TEMP_LOGS_DIR}  log_name=SYSLOG_SITE_RESET  ip=192.168.255.126  ports=@{UDP_PORTS}  file_limit=0


Step${index}: Check Counters Number And DN After ${operation}
    Log  \nStep${index}: Check Counters Number And DN After ${operation}  console=true
    Sleep Until New Cycle  minutes_for_cycle=60min
    Sleep  1min  TC will wait until PM report is loaded.

    SSHLibrary.Open Connection  ${OAM_BTS_IP}  prompt=:~ >  alias=pm_statistics
    SSHLibrary.Login  ${SMOD1}[USERNAME]  ${SMOD1}[PASSWORD]

    ${xml_file}  Extract Last Gz File From SBTS AND Get XML File Name
    ${operation}  Replace String  ${operation}  ${SPACE}  _
    SSHLibrary.Get File  /rom/uri/PERFMON_FILES/${xml_file}  ${BTS_FILES}/PM_Report_After_${operation}.xml

    ${check_counters_passed}  Run Keyword And Return Status  Check Counters Differences In PM Files  ${BTS_FILES}/Initial_PM_Report.xml
    ...  ${BTS_FILES}/PM_Report_After_${operation}.xml  ${BTS_FILES}/PM_Reports_Differences_After_${operation}.txt
    ...  counter_exception=${COUNTER_EXCEPTION}
    IF  not ${check_counters_passed}  Set Test Failed  There are differencies in PM files after ${operation}.

    Collect Snapshot  target_file_name=${BTS_FILES}/${operation}_snapshot.zip  timeout=1200
    Check PMSTAT Errors Print In Snapshot And Syslogs  ${operation}

    [Teardown]  Run Keywords  SSHLibrary.Execute Command  rm /rom/uri/PERFMON_FILES/${xml_file}  AND  SSHLibrary.Close Connection


Step4: Perform Site Power Reset
    Log  \n\nStep4: Perform site power reset  console=true
    coam.Power Reset  timeout=600
    Wait Until Keyword Succeeds  ${RESTORE_TIMEOUT}  1m
    ...  Admin Check All Required State
    Start Syslog  alias=test_syslog  log_dir=${TEMP_LOGS_DIR}  log_name=SYSLOG_POWER_RESET  ip=192.168.255.126  ports=@{UDP_PORTS}  file_limit=0


Check PMSTAT Errors Print In Snapshot And Syslogs
    [Arguments]  ${operation}

    ${snapshot_path}  Set variable  ${BTS_FILES}/${operation}_snapshot.zip
    ${files_matches}   Get Files From Snapshot By Name Pattern  ${snapshot_path}  runtime_SYSTEM_AaSysInfoMcu\.log\.xz
    ${status}  Run Keyword And Return Status  Should Be Empty  ${files_matches}
    IF  ${status}  Fail  File runtime_SYSTEM_AaSysInfoMcu.log.xz not exist in snapshot![NOK]
    ${lines}  Find All Lines In Files Matching Pattern  ${files_matches}  printOverload
    ${status}  Run Keyword And Return Status  Should Not Be Empty  ${lines}
    IF  ${status}
        Log  \nCPU overload:  console=true
        FOR  ${line}  IN  @{lines.keys()}
           Log  \nFound in ${line} \n${lines}[${line}]  console=true
        END
        Fail  Error 'printOverload' exists in runtime_SYSTEM_AaSysInfoMcu.log.xz file![NOK]
    ELSE
        Log  Error 'printOverload' not exists in runtime_SYSTEM_AaSysInfoMcu.log.xz file![OK]  console=true
    END
    ${syslog_folder_name}  Convert To Lower Case  ${operation}
    ${syslog_collected}  Run Keyword And Return Status
    ...  Collect Syslog Results  alias=test_syslog  destination=${UDP_LOGS}/syslog_${syslog_folder_name}  unzip=true
    IF  ${syslog_collected}
        Log  Syslog file is collected.  console=true
    ELSE
        Log  Syslog file is not collected. [NOK]
    END
    ${syslog_file}  Convert To Upper Case  syslog_${syslog_folder_name}
    ${syslog_path}  Set Variable  ${UDP_LOGS}/syslog_${syslog_folder_name}/${syslog_file}
    Check PMSTAT In Syslog File  ${syslog_path}  ERR/PMStat:  PMSTAT process error
    Check PMSTAT In Syslog File  ${syslog_path}  PMStat+[ 0-9-a-zA-Z:.]*/CCS/AaError, AaErrorIsCoreDumpEnabled  PMSTAT process crash
    Check PMSTAT In Syslog File  ${syslog_path}  ERR/PMStat/PM, \\[PmCounterValuesReportMsgHandler]  PMSTAT error print
    Remove Directory  ${UDP_LOGS}/syslog_${syslog_folder_name}  recursive=True


Check PMSTAT In Syslog File
    [Arguments]  ${syslog_path}  ${pattern}  ${message}

    ${lines}  Parse Syslog From Archive  ${syslog_path}  ${pattern}
    ${status}  Run Keyword And Return Status  Should Not Be Empty  ${lines}
    IF  ${status}
        Log  ${message} found in syslog!  console=true
        FOR  ${line}  IN  @{lines}
            Log  \nFound ${line}  console=true
        END
        Fail  ${message} exist in syslog![NOK]
    END
    Log  ${message} not exist in syslog![OK]  console=true


TC Setup
    Common Test Setup  tc_name=PM__Robustness_Check_Counters_On_PM_Reports


TC Teardown
    Common Test Teardown
