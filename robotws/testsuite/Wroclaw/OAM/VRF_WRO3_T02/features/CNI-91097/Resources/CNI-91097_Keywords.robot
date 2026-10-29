*** Settings ***
Documentation
...    Provides CNI-91097 specific keywords.
...    Author: Malwina Gudas
...    Contact: bartosz.rutkowski@nokia.com

Resource         ../../../common_resources/admin/admin.robot
Resource         ../../../common_resources/alarms/alarm.robot
#Resource         ../../../common_resources/sw_operations/sw_operations.robot
Resource         ../../../common_resources/connections/connections.robot

Resource         ../../../common_resources/admin/admin.robot
Library          taf.transport.ssh            WITH NAME    ssh
Library          taf.sbts.oam.coam.admin       WITH NAME    coam_admin
Library          SSHLibrary
Library          ./CNI-91097_functions.py

*** Variables ***
${NTP_DN}=                    MRBTS-${tl.gnbs[0].global_bts_id}/MNL-1/MNLENT-1/SYNC-1/CLOCK-1/NTP-1
${LUAC_DN}=                   MRBTS-${tl.gnbs[0].global_bts_id}/MNL-1/AMGR-1/LUAC-1
${NTP_ALARMING_THRESHOLD}=    180
${NTP_DUMMY_SERVER_IPV4}=     10.43.203.132
${NTP_DUMMY_SERVER_IPV6}=     2a00:8a00:1234:607d::205

*** Keywords ***
NTP server teardown
    [Arguments]
    ${connection}=    Connect to ADMIN
    Change Parameter on BTS    dist_name=${NTP_DN}    param_name=ntpAlarmingThreshold
    ...                        param_value=300        connection=${connection}
    unset_ntp_server_ip_address    dist_name=${NTP_DN}    connection=${connection}
    [Teardown]    Run keyword and ignore error    Disconnect from ADMIN    ${connection}

Account Lockout teardown
    [Arguments]
    ${connection}=    Connect to ADMIN
    Change Parameter on BTS    dist_name=${LUAC_DN}    param_name=btsMaxFailedLoginAttempts
    ...                        param_value=5    connection=${connection}
    Change Parameter on BTS    dist_name=${LUAC_DN}    param_name=btsAccountLockoutDuration
    ...                        param_value=15    connection=${connection}
    [Teardown]    Run keyword and ignore error    Disconnect from ADMIN    ${connection}
