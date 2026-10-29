*** Settings ***
Documentation  This file contains keywords which allow user to collect several logs like: Snapshot, syslog, cplane etc..

Library   DateTime
Library   ute_syslog
Library   taf.collectors.tcpdump     WITH NAME    tcpdump
Library   taf.collectors.core        WITH NAME    core
Library   taf.sbts.oam.coam.admin


*** Variables ***
${default_snapshot_alias}    snapshot
${default_syslog_alias}      test_syslog


*** Keywords ***
#       *** SNAPSHOT ***
Collect snapshot
    [Documentation]   Collects a snapshot of the system.
    ...  :param snap_coverage: Coverage level for the snapshot (default: "Full").
    ...  :param force: Whether to force snapshot collection (default: True).
    ...  :param timeout_value: Timeout value for snapshot collection (default: 1800 seconds).

    [Arguments]
    ...                 ${snap_coverage}=Full
    ...                 ${force}=${TRUE}
    ...                 ${timeout_value}=1800sec
    connect to  name=snapshot
    Log to console      Collecting snapshot....
    ${software_info}    Get software info  connection=${default_snapshot_alias}
    ${sw_version}       Set variable  ${software_info['Active SW version']}
    ${timestamp}        DateTime.Get Current Date  result_format=%Y%m%d-%H%M%S
    ${status}=   Run Keyword And Return Status   Variable should exist   ${TEST NAME}
    ${snapshot_path}=   Set variable if   ${status}==True
    ...   ${OUTPUT DIR}/${SUITE NAME}/${TEST NAME}/Snapshot_${sw_version}_${timestamp}.zip
    ...   ${OUTPUT DIR}/${SUITE NAME}/Snapshot_${sw_version}_${timestamp}.zip
    Get snapshot   ${snapshot_path}
    ...                 ${snap_coverage}
    ...                 ${force}
    ...                 ${timeout_value}
    ...                 ${default_snapshot_alias}
    [Teardown]          taf.sbts.oam.coam.admin.Teardown  connection=${default_snapshot_alias}


Collect snapshot if test failed
    [Documentation]  Use to keyword to prevent 'ifs' in setup or teardown scope.

    run keyword if    '${TEST_STATUS}'=='FAIL'    Collect snapshot


#       *** SYSLOG ***
Start syslog capture
    [Documentation]  Starts capturing syslog messages.
    ...  :param log_dir: Directory to store the syslog file (default: `${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/`).
    ...  :param log_name: Name of the syslog file (default: "SYSLOG.LOG").
    ...  :param alias: Alias for the syslog collector (default: ${default_syslog_alias}).

    [Arguments]   ${log_dir}=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/  ${log_name}=SYSLOG.LOG
    ...           ${alias}=${default_syslog_alias}
    ute_syslog.start_syslog  log_dir=${log_dir}  log_name=${log_name}  alias=${alias}

Stop syslog capture
    [Documentation]  Stops syslog capture and collects the results.
    ...  :param alias: Alias for the syslog collector (default: ${default_syslog_alias}).

    [Arguments]   ${alias}=${default_syslog_alias}
    ute_syslog.collect_syslog_results  alias=${alias}
    ute_syslog.teardown_all_aliases_for_syslog



#       *** CPLANE ***
Setup cplane tcpdump collector
    [Documentation]   Sets up a tcpdump collector for cplane traffic.

    [Arguments]
    ...    ${name}=cplane_collector
    ...    ${host}=192.168.255.129

    Set suite variable    ${cplane_collector}    ${name}
    ${sysmod_executor}    Create Dictionary
    ...     host=${host}
    ...     user=toor4nsn
    ...     password=oZPS0POrRieRtu

    tcpdump.create_tcpdump_collector
    ...     name=${cplane_collector}
    ...     options=-i any sctp
    ...     executor=${sysmod_executor}
    core.Setup collectors    ${cplane_collector}
    core.Set Suite Alias     ${cplane_collector}


Start cplane logs
    [Documentation]  It starts cplane log collecting based on sysmod tcpdump command.

    log to console    starting cplane logs
    core.Start collectors    ${cplane_collector}


Stop cplane logs
    [Documentation]  Stops and collect cplane results from sysmod's tcpdump.

    [Arguments]    ${log_dir}=${OUTPUT DIR}/${SUITE_NAME}/${TEST_NAME}/
    log to console    stopping cplane logs
    core.Stop collectors      ${cplane_collector}
    core.Collect collectors   ${cplane_collector}    target_dir=${log_dir}
    core.Teardown collectors    ${cplane_collector}
