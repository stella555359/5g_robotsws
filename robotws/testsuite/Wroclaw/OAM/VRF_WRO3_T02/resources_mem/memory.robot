*** Settings ***
Library         taf.sbts.oam.coam.admin  WITH NAME  admin
Library         taf.transport.ssh  WITH NAME  ssh
Library         ../resources_mem/python_lib/LogFilesLibrary.py
Resource        ./onap.robot


Documentation
...  AUTHORS:       artur.lebek@nokia.com, tomasz.marchewka@nokia.com
...  MAINTAINER:    RAN_PZ_WRO_3_SG01
...  *****************
...  Basic information
...  *****************
...  Internal WRO1 resource library repetitive keywords in multiple tests.
...  ******************
...  History of changes
...  ******************
...  30.04.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-576 - Add new KWs: "Create Log Directory For Suite Results", "Suite Setup For Memory
...                                                                 Testing", "Suite Teardown For Memory Testing" and "Collect Suite Logs";
...                                                                 rework KWs: "Setup ONAP For Memory Testing" and "Teardown ONAP For Memory Testing"
...  10.10.2024 - https://jiradc.ext.net.nokia.com/browse/TAW-609 - Update "Suite Setup For Memory Testing" and Teardown.
...                                                                 Turn off/on deepsleep for MRBTS 8036
...  06.08.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-23345 - Adapt keywords for Memory with NetAct integration; remove keywords:
...                 "Setup ONAP For Memory Testing" and "Teardown ONAP For Memory Testing"; modify keywords: "Suite Setup For Memory Testing"
...                 and "Suite Teardown For Memory Testing"
...  xx.xx.2023 - https://jiradc.ext.net.nokia.com/browse/TAW-xxx - xxx
...  *******************
...  RAN PZ3 WRO1 TEMPLATE

*** Variables ***
${SKIP_PARAMETER_RELATION_ERRORS}=  True
${SHOULD_ACTIVATE}=  True

*** Keywords ***
Set Radio Memory Threshold
    [Arguments]  ${threshold_value}=40%    ${PLANS_DIR}=${RESULTS}/plans
    ${threshold_value}  Evaluate  re.search(r'\\d+','''${threshold_value}''').group(0)  re
    ${current_date}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    ${delta}  Set Variable  radioMemAbnormalThreshold
    admin.create delta  ${delta}
    ${bts_info}  admin.get bts info
    FOR  ${rmod}  IN  @{bts_info['radioModules']['rmod']}
        admin.append parameter update to delta  ${rmod['id']['configuration']}  radioMemAbnormalThreshold  ${threshold_value}  ${delta}
    END
    admin.get delta  ${delta}
    ${json_path}  Set Variable  ${PLANS_DIR}/radioMemAbnormalThreshold_${threshold_value}%_${current_date}.json
    admin.save delta  ${json_path}  ${delta}
    Log To Console    Changing radioMemAbnormalThreshold parameter to ${threshold_value}% on all RMs
    admin.perform delta recommissioning  ${json_path}  ${SKIP_PARAMETER_RELATION_ERRORS}  ${SHOULD_ACTIVATE}

Collect Runtime Sysinfo
    [Arguments]  ${ip}=192.168.255.129  ${login}=toor4nsn  ${password}=oZPS0POrRieRtu  ${destination}=${RESULTS}/runtime_aasysinfo
    Run  sudo mkdir ${destination} ; sudo chmod -R 777 ${destination}
    ssh.connect to  hostname=${ip}  username=${login}  password=${password}  alias=aasysinfo
    ssh.execute   command=echo log -l runtime_sysinfo -f | nc localhost 15007  connection=aasysinfo
    ${output}  ssh.execute   command=find /tmp/trblserver_logs -name "*011_part*" -type f  connection=aasysinfo
    ${zips}  Evaluate  re.findall(r'_\\d+_part_\\d+.zip','''${output}''')  re
    FOR  ${zip}  IN  @{zips}
        Log To Console    Collecting /tmp/trblserver_logs/${zip} to ${destination}/${zip}
        ssh.download file  /tmp/trblserver_logs/${zip}  ${destination}/${zip}  connection=aasysinfo
    END
    ssh.disconnect  connection=aasysinfo

Create Log Directory For Suite Results
    [Arguments]  ${suite_phase}=setup  ${test_results}=/home/ute/test_results
    ${suite_phase}  Set Variable If  '${suite_phase}'=='setup'  setup  teardown
    ${now}  Run  date +%F_%H-%M-%S
    ${LOG_DIR}  Join Path  ${test_results}  suite_${suite_phase}_${now}
    Create Directory  ${LOG_DIR}
    Set Suite Variable  ${SUITE_RESULTS}  ${LOG_DIR}
    Log To Console  Suite ${suite_phase} results path: ${SUITE_RESULTS}

Suite Setup For Memory Testing
    ${no_unexpected_fid}  Set Variable  None
    Create Log Directory For Suite Results  suite_phase=setup
    Setup Syslog  ${SUITE_RESULTS}/syslog
    Setup Admin  admin_api_log_dir=${SUITE_RESULTS}/admin_api/suite_setup_memory
    Run Keyword If  ${MRBTS_ID}==8036    Turn off deepsleep single 5G RU
    alarms.Start Watchdog  ${skip_fault}
    Run Keyword If  ${INTEGRATE_NETACT}  Setup TAF Netact
    ...                                   ELSE  Log  Skipping NetAct integration.  WARN
    ${no_unexpected_fid}  Run Keyword And Return Status  Stop Watchdog And Check Alarms
    ${1st_checkpoint_log_files_master}    Get Log File List Master
    ${result_checkpoint_slave}    Run Keyword and Ignore Error    Get Log File List Slave
    ${1st_checkpoint_log_files_slave}    Set Variable    ${result_checkpoint_slave}[1]
    Set Suite Variable  ${1st_checkpoint_log_files_master}
    Set Suite Variable  ${1st_checkpoint_log_files_slave}
    [Teardown]  Collect Suite Logs  ${no_unexpected_fid}

Suite Teardown For Memory Testing
    ${no_critical_fault}  Run Keyword And Return Status  Variable Should Not Exist  ${CRITICAL_FAULT_DETECTED}
    Create Log Directory For Suite Results  suite_phase=teardown
    Setup Syslog  ${SUITE_RESULTS}/syslog
    Setup Admin  admin_api_log_dir=${SUITE_RESULTS}/admin_api/suite_teardown_memory
    alarms.Start Watchdog  ${skip_fault}
    Run Keyword If  ${INTEGRATE_NETACT}  Teardown TAF Netact
    Run Keyword If  ${MRBTS_ID}==8036    common.Restore parameters value on all RMODs
    ${no_unexpected_fid}  Run Keyword And Return Status  Stop Watchdog And Check Alarms
    [Teardown]  Collect Suite Logs  ${no_unexpected_fid}

Collect Suite Logs
    [Arguments]  ${no_unexpected_fid}
    ${timestamp}  DateTime.Get Current Date  result_format=%d%m%Y%H%M%S  exclude_millis=True
    Run Keyword If  '${no_unexpected_fid}'=='False'  Run Keywords
    ...         Log To Console  Snapshot collecting
    ...    AND  Run Keyword And Ignore Error
    ...         Collect Snapshot  target_file_name=${SUITE_RESULTS}/snapshot/snapshot_mrbts-${MRBTS_ID}_${timestamp}.zip  timeout=1500
    ...    AND  Collect Syslog Files  destination=${SUITE_RESULTS}/syslog/syslog.tar.gz
    ...    AND  admin.teardown admin  alias=${ute_admin_alias}
    ...    AND  Run Keyword And Ignore Error  Move Logs To Burak  source=${SUITE_RESULTS}
    ...   ELSE  Run Keywords
    ...         Collect Syslog Files  destination=${SUITE_RESULTS}/syslog/syslog.tar.gz
    ...    AND  admin.teardown admin  alias=${ute_admin_alias}
    ...    AND  Run Keyword And Ignore Error  Move Logs To Burak  source=${SUITE_RESULTS}
