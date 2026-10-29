*** Settings ***

Library    testsuite.Bangalore.ORAN.resources.python.Macro.Python.bts.common.alarm.GnbAlarm    WITH NAME      gnbalarm



*** Keywords ***
Verify Alarm is Active on gNB
    [Arguments]    ${fault_name}    ${gnb_id}=0    ${du_id}=${0}
    [Documentation]    Verify alarm is active.
    ...     :param alarm_id:   Name of fault.
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbalarm.verify_alarm_is_active    fault_name=${fault_name}    bts_id=${gnb_id}    du_id=${du_id}

Verify Alarm is not Active on gNB
    [Arguments]    ${fault_name}    ${gnb_id}=0    ${du_id}=${0}
    [Documentation]    Verify alarm is not active.
    ...     :param alarm_id:   Name of fault.
    ...     :param gnb_id:    GNB id - related to Test Line configuration.
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbalarm.verify_alarm_is_not_active    fault_name=${fault_name}    bts_id=${gnb_id}    du_id=${du_id}

Verify Allowed Alarms on gNB
    [Arguments]    ${allowed_alarms}    ${gnb_id}=0    ${du_id}=${0}
    [Documentation]     Verify all alarms present on BTS are allowed
    ...     :param allowed_alarms:   List of allowed alarms
    ...     :param gnb_id:           GNB id - related to Test Line configuration
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbalarm.verify_allowed_alarms    allowed_alarms=@{allowed_alarms}    bts_id=${gnb_id}    du_id=${du_id}

Verify Mandatory Alarms on gNB
    [Arguments]     ${mandatory_alarms}   ${gnb_id}=0    ${du_id}=${0}
    [Documentation]     Verify is all alatms on BTS verify mandatory alarms
    ...     :param mandatory_alarms:   List of names of mandatory alarms
    ...     :param gnb_id:           GNB id - related to Test Line configuration
    ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    gnbalarm.verify_mandatory_alarms    mandatory_alarms=@{mandatory_alarms}    bts_id=${gnb_id}    du_id=${du_id}

Start watching alarms
    [Arguments]    ${allowed_alarms}    ${gnb_id}=${0}    ${du_id}=${0}
    [Documentation]    Start running alarms watcher.
   ...     :param allowed_alarms: list of allowed faults' names
   ...     :param interval: time interval between consecutive requests to BTS for active alarms
   ...     :param gnb_id: ID of gNB. Default 0.
   ...     :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]. Default 0.
    gnbalarm.start_watching_alarms    allowed_alarms=@{allowed_alarms}    bts_id=${gnb_id}    du_id=${du_id}

Stop watching alarms
    [Arguments]    ${gnb_id}=${0}    ${du_id}=${0}
    [Documentation]    Close watcher thread. Mandatory at the end of test where watcher was started.
    ...    :param gnb_id: ID of gNB. Default 0.
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]. Default 0.
    gnbalarm.stop_watching_alarms    bts_id=${gnb_id}    du_id=${du_id}

Allow Alarm
    [Arguments]    ${alarm}    ${gnb_id}=${0}    ${du_id}=${0}
    [Documentation]    Add alarm to allowed alarms for alarms watcher. Run start_watching_alarms beforehand.
    ...    :param alarm: alarm fault name
    ...    :param gnb_id: ID of gNB. Default 0.
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]. Default 0.
    gnbalarm.allow_alarm    alarm=${alarm}    bts_id=${gnb_id}    du_id=${du_id}

Disallow Alarm
    [Arguments]    ${alarm}    ${gnb_id}=${0}    ${du_id}=${0}
    [Documentation]    Remove alarm from allowed alarms for alarms watcher. Run start_watching_alarms beforehand.
    ...    :param alarm: alarm fault name
    ...    :param gnb_id: ID of gNB. Default 0.
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]. Default 0.
    gnbalarm.disallow_alarm    alarm=${alarm}    bts_id=${gnb_id}    du_id=${du_id}

Watch Active Alarms and Collect Logs on Unexpected Alarm
    [Arguments]    ${trigger_alarms}=${None}    ${gnb_id}=${0}    ${du_id}=${0}
    [Documentation]    Start watcher running in background and collecting logs if trigger alarm alarm was detected.
    ...    :param trigger_alarms: alarm that triggers logs collection. If None then logs are collected on any disallowed alarm. Default None.
    ...    :param gnb_id: ID of gNB. Default 0.
    ...    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]. Default 0.
    gnbalarm.watch_active_alarms_and_collect_logs_on_unexpected    trigger_alarms=${trigger_alarms}
    ...    bts_id=${gnb_id}    du_id=${du_id}

Check If Critical Alarm Exists
    [Documentation]  Checking if any critical alarms exists on gNB
    gnbalarm.check_if_critical_alarm_exist

Verify Severity Of Given Alarm
   [Arguments]    ${fault_id}    ${fault_severity}
   [Documentation]  Checking if specified alarm exists on gNB.
    ...    :param fault_id: ID of the fault
    ...    :param fault_severity: severity of the fault
   gnbalarm.verify_severity_of_given_alarm    alarm_id=${fault_id}    alarm_severity=${fault_severity}
