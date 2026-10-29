*** Settings ***
Documentation    Suite description
...    Keywords for CB005750-5G-FBAA feature


Library    Collections
Library    String
Library    OperatingSystem
Library    taf.gnb.oam.coam.admin   WITH NAME   admin_cli
Resource    taf/rfrl/bts/robot/gnb.robot
Library    on_air_tl_preparation.testline_preparation
Library     ./snap_name_slicer.py


*** Variables ***
${LSS_IPv4}      ${tl.test_pcs[0].connections[0].v4}
${LSS_IPv6}      ${tl.test_pcs[0].connections[0].v6}
${mrbtsId}       ${tl.gnbs[0].instance_id}
${lss_user}      ${tl.test_pcs[0].default_ssh_connection_details.username}
${lss_password}  ${tl.test_pcs[0].default_ssh_connection_details.password}
${dest_name}     lss
*** Keywords ***

Set syslogSubstringTrigger param
    [Arguments]    ${StringTrigger}
    [Documentation]   changes syslogSubstringTrigger parameter value or adds a new one if it does not exist.
    ...     :param StringTrigger:    new value of syslogSubstringTrigger parameter
    Perform Configuration Parameter Recommissioning On gNB
    ...    dist_name=MRBTS-${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1
    ...    param_name=syslogSubstringTrigger
    ...    param_value=${StringTrigger}
    ...    operation=update
    ...    skip_parameter_relation_errors=${False}
    ...    timeout=300

Check if syslogSubstringTrigger occured in syslog
    [Arguments]   ${log_with_trigger_found}
    [Documentation]  checks if syslogSubstring was found in syslog and was noted as snapshot trigger.
    ...    :log_with_trigger_found:  string with syslogSubstringTrigger occurence
    ${findings}   Get matching string from syslog    ${log_with_trigger_found}   /tmp/btslog2/
    [return]  ${findings}

Check current remote snapshot on LSS and remove it
    [Documentation]  get snapshot name from syslog and check if snapshot file exists on LSS.
    ${snapshot_name}=  Acquire snapshot name from BTSlog
    Wait until keyword succeeds    10 min   1 min   Check if snapshot was collected on LSS  ${snapshot_name}  ${LSS_Ipv4}
    ...    ${lss_user}  ${lss_password}
    Remove external snapshot  ${snapshot_name}  ${LSS_Ipv4}    ${lss_user}  ${lss_password}

Acquire snapshot name from BTSlog
    ${syslog_line}    Wait until keyword succeeds    1 min    1 min     Check if syslogSubstringTrigger occured in syslog
    ...   snapshotStarted: SNAPSHOT START
    Log variables
    ${syslog_time}=     Get Regexp Matches  ${syslog_line}  <.*>
    ${soft_version}=    Get gNB Sw Version
    ${snapshot_name}  Slice snap timestamp  ${syslog_time}  ${soft_version}
    Log Variables
    [return]  ${snapshot_name}
