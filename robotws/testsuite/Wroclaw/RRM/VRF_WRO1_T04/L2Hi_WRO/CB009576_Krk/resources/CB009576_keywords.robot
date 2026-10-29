*** Settings ***
Documentation
...    author: Damian Piasecki
...    maintainer: Damian Piasecki
...    contact: damian.piasecki@nokia.com
...    Description: CB009576 common keywords

Library    OperatingSystem

Library    ta5g_enb
Library    ta5g_pm_counters
Library    taf.transport.ssh                                                     WITH NAME    ssh
Library    taf.sbts.oam.coam.admin

Library    testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_gnb            WITH NAME    common_gnb
Library    testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_wts            WITH NAME    common_wts
Library    testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.logs_collector        WITH NAME    logs_collector
Library    CB009576_keywords.py                                                     WITH NAME    CB009576_keywords
Library    CB009576_autorecovery.py                                                 WITH NAME    CB009576_autorecovery
Library    CB009576_egate.py                                                        WITH NAME    CB009576_egate
Library    CB009576_operability.py                                                  WITH NAME    CB009576_operability

Resource   taf/rfrl/common_resources/robot/libraries_instances.robot
Resource   taf/rfrl/utilities/utf_lab/utf_lab.robot

Variables    variables.py

*** Keywords ***
CB009576 Suite Setup
    [Arguments]    ${scf_file_path}    ${wts_file_path}
    Create Directory    ${OUTPUT_DIR}/${SUITE_NAME}
    common_wts.Configure IPs On Vm Interfaces
    ...    cfg_filepath=${wts_file_path}
    Set Proper Vlan Id In Base Scf    ${scf_file_path}
    common_gnb.Collect SCF File
    ...    final_path=${OUTPUT_DIR}/${SUITE_NAME}/default_scf.xml
    common_gnb.Wait For All Radio Modules To Be Online
    Wait Until Keyword Succeeds    5min    30s    common_gnb.Assert BTS In State
    ...    bts_state=configured

CB009576 Test Setup
    [Arguments]    ${wts_file_path}
    Log    \nStart setup    console=True
    Create Directory    ${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}
    logs_collector.Start Collecting Basic Logs
    ...    log_dir=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}
    ...    syslog_alias=${SYSLOG_ALIAS}
    Wait Until Keyword Succeeds    5min    30s    common_gnb.Assert BTS In State
    ...    bts_state=configured
    common_wts.Wait For Environment Prepared For Wts Ready State
    ...    wts_config_filename=${wts_file_path}
    ...    allow_first_reboot=True
    ...    wts_dir_path=/opt/iphy/latest
    ...    timeout=${300}
#    common_wts.Start Collecting Ueapp Sosreport
    Add Syscom Preferences To Wireshark Config
    CB009576_keywords.Add Ccs Decode To Wireshark


Stop Syslog Collecting
    logs_collector.Stop Collecting Basic Logs
    ...    log_dir=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}
    ...    collect_basic_logs=${True}

CB009576 Test Teardown With Gnb Commissioning
    CB009576 Test Teardown
    common_gnb.Perform GNB Commissioning                     scf_file=${SCF_H_H19}

CB009576 Test Teardown
    [Arguments]    ${stop_syslog}=${True}
    Log To Console  \nStart Teardown
    Run Keyword If    ${stop_syslog} == ${True}    Stop Syslog Collecting
#    Run Keyword If Test Passed    common_wts.Stop Collecting Ueapp Sosreport
#    ...    destination_path_for_sosreport=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}
#    ...    ue_app_options=-o
#    Run Keyword If Test Failed    common_wts.Stop Collecting Ueapp Sosreport
#    ...    destination_path_for_sosreport=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}
    common_wts.Stop WTS And Clear
    ssh.Reset Cache

Autorecovery Preparation
    common_wts.Setup X2 Link
    common_gnb.Ensure Flags Existence In Swconfig
    ...     flags=${CORE_DUMP_SWCONFIG_FLAG}
    CB009576_autorecovery.Set Rest Loop Count Value From Gnb

Marlin Container Sw Critical Failure Procedures Rat Reset
    [Arguments]    ${containers_list}
    CB009576_operability.Check Barring Status For All Cells
    ${container_name}=    CB009576_autorecovery.Select Process Randomly    process_list=${containers_list}
    ${process}=    CB009576_autorecovery.Attach Prefix To Container Name    container_name=${container_name}
    ${found_pids}=    CB009576_autorecovery.Get All Pids Of Process    process=${process}
    ${pid}=    CB009576_autorecovery.Select PID Randomly    pids=${found_pids}
    CB009576_autorecovery.Send Signal For Memory Access Violation    pid=${pid}
    CB009576_operability.Check Current Alarm On Bts     alarm=${4383}   wait_time=${5}
    common_gnb.Wait For All Radio Modules To Be Online
    CB009576_autorecovery.Check If Loop Count Value Is Correct
    ...     expected_value=0
    CB009576_operability.Verify If Gnb Returned To OnAir State
    ${crash_snapshot}=    CB009576_autorecovery.Collect Crash Snapshot
    ...    process=${container_name}
    ...    pid=${pid}
    CB009576_autorecovery.Verify If Crash File Is Present In Snapshot
    ...    pid=${pid}
    ...    snapshot_zip_path=${crash_snapshot}
    ...    is_container=True

Thor L1 Application Critical Failure
    [Arguments]    ${processes_list}    ${is_non_restartable}=False
    CB009576_operability.Check Barring Status For All Cells
    ${process}=    CB009576_autorecovery.Select Process Randomly    process_list=${processes_list}
    ${process_basename}=    CB009576_autorecovery.Get Process Basename From Process Command    process_command=${process}
    ${found_pids}=    CB009576_autorecovery.Get All Pids Of Process
    ...    process=${process}
    ...    thor=True
    ${pid}=    CB009576_autorecovery.Select PID Randomly    pids=${found_pids}
    CB009576_autorecovery.Kill Process On Thor    pid=${pid}
    CB009576_operability.Check Current Alarm On Bts     alarm=${2087}   wait_time=${5}
    common_gnb.Wait For All Radio Modules To Be Online
    CB009576_autorecovery.Check If Loop Count Value Is Correct
    ...     expected_value=0
    CB009576_operability.Verify If Gnb Returned To OnAir State
    ${crash_snapshot}=    CB009576_autorecovery.Collect Crash Snapshot
    ...    process=${process_basename}
    ...    pid=${pid}
    CB009576_autorecovery.Verify If Crash File Is Present In Snapshot
    ...    process=${process_basename}
    ...    pid=${pid}
    ...    snapshot_zip_path=${crash_snapshot}
    ...    from_thor=True
    ...    is_non_restartable=${is_non_restartable}

Check If Preferences Exist
    ${preferences_file}    Set Variable    ~/.config/wireshark/preferences
    ${file_exist}=    Run Keyword And Return Status
        ...    File Should Exist    ${preferences_file}
    Run Keyword If   ${file_exist}==${False}    Create File    ${preferences_file}
    ${file_content}=    OperatingSystem.Get File   ${preferences_file}
    ${preferences_exist}=    Run Keyword And Return Status
    ...    Should Match Regexp    ${file_content}    ntrstr.port: 49151,49392
    [Return]    ${preferences_exist}

Add Syscom Preferences To Wireshark Config
    ${preferences_exist}    Check If Preferences Exist
    ${command}=    catenate  SEPARATOR=
    ...    echo "syscom.sic_tcp_ports: 15004,15003,50846" >> ~/.config/wireshark/preferences
    Run Keyword If    ${preferences_exist}==${False}
    ...    Run    ${command}
    ...    ELSE    Log    File '~/.config/wireshark/preferences' contains the required flags for syscom

Validate Syslog TCP Connection Loss Between Emil And RCPTraceController
    syslog_validation.Verify Syslog Open UDP Port Request Success
    ${supervision_id}=    syslog_validation.Verify Syslog Send Request Success And Get Value Of Supervision
    syslog_validation.Verify Syslog Syscom Trace Controller Stop Tracing    supervision_id=${supervision_id}
    syslog_validation.Verify Syslog Get All Close UDP Port Resp    supervision_id=${supervision_id}
    syslog_validation.Verify Syslog Finish Closing UDP Port For Session    supervision_id=${supervision_id}
