*** Settings ***
Documentation
...            This resource file is for keeping the common keywords for testsuites, that are
...            designed to collect traces for AIML procedures

Library        taf.ul.log_collection
Library        taf.collectors.core            WITH NAME    core
Resource       ../../resources/Common/wts_ue.robot
Resource       ../../resources/Common/ute_workarounds.robot

*** Keywords ***
Bring Airphone to on Air status
    UTE Cloud Workaround

    ${connected}=   Connect To Running Egate   ap_egate
    IF   ${connected}   RETURN

    ${wts_status}=    Run Keyword and Return Status    Bring Airphone TL to on Air status without reboot
    IF    ${wts_status} == False             Bring Airphone TL to on Air status

Prepare Syslogs

    ${syslog_alias}   Set Variable   LongTimeLogs

    ${config_string}=    Catenate    {"SyslogLog"     : {"type": "syslog"},
    ...                               "LongTimeLogs"  : {"type": "group",
    ...                                                  "members": "SyslogLog"}}
    ${log_configuration}=    Evaluate   ${config_string}

    Create Collectors Using Testline Information    names=${syslog_alias}
    ...                                             configuration=${log_configuration}
    ...                                             network_elements=gnb_0

    core.Set Suite Alias   LongTimeLogs

    RETURN   LongTimeLogs
