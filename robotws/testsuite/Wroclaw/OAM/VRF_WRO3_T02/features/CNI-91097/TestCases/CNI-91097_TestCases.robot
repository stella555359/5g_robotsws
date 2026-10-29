*** Settings ***
Documentation           TC's execution time: 29m
Resource                ../Resources/CNI-91097_Keywords.robot
Resource                ../../../common_resources/snapshot_collector/snapshot_collector.robot
Resource                ../../../common_resources/dcap/keywords.robot
Library                 taf.sbts.oam.coam.admin    WITH NAME    coam_admin

*** Variables ***
${NTP_SERVER_FID}=            4297
${LOCAL_ACCOUNT_LOCK_FID}=    61642
${TARGET_SNAPSHOT_IPV4}=      snapshot_ipv4.zip
${TARGET_SNAPSHOT_IPV6}=      snapshot_ipv6.zip
${TARGET_SNAPSHOT_BTSNAME}=   snapshot_btsname.zip

*** Keywords ***
CNI-91097_01_Prepare_BTS_Snapshot_with_alarm_for_Ims_Scrambling_Verification_Ipv4
    ${conn}=    Connect to ADMIN
    Change Parameter on BTS    dist_name=${NTP_DN}    param_name=ntpAlarmingThreshold
    ...                        param_value=${NTP_ALARMING_THRESHOLD}    connection=${conn}
    set_ntp_server_ip_address  ip_addr=${NTP_DUMMY_SERVER_IPV4}  dist_name=${NTP_DN}   connection=${conn}
    Log    Wait for alarm NTP Server ${NTP_DUMMY_SERVER_IPV4} unavailable    console=yes
    Sleep    300s
    Alarm Should be Active In BTS    ${NTP_SERVER_FID}
    coam_admin.get_snapshot    target_file_name=${TARGET_SNAPSHOT_IPV4}    coverage=HealthCheck    connection=${conn}
    Run keyword and ignore error
    ...         Check and Send Snapshot to Server CLASSICAL TRSSEC    snapshot_path=${TARGET_SNAPSHOT_IPV4}
    [Teardown]     Run keywords    Run keyword and ignore error    Disconnect from ADMIN    ${conn}    AND
    ...                            NTP server teardown

CNI-91097_02_Prepare_BTS_Snapshot_with_alarm_for_Ims_Scrambling_Verification_Ipv6
    ${conn}=    Connect to ADMIN
    Change Parameter on BTS    dist_name=${NTP_DN}    param_name=ntpAlarmingThreshold
    ...                        param_value=${NTP_ALARMING_THRESHOLD}    connection=${conn}
    set_ntp_server_ip_address  ip_addr=${NTP_DUMMY_SERVER_IPV6}  dist_name=${NTP_DN}   connection=${conn}
    Log    Wait for alarm NTP Server ${NTP_DUMMY_SERVER_IPV6} unavailable    console=yes
    Sleep    300s
    Alarm Should be Active In BTS    ${NTP_SERVER_FID}
    coam_admin.get_snapshot    target_file_name=${TARGET_SNAPSHOT_IPV6}    coverage=HealthCheck    connection=${conn}
    Run keyword and ignore error
    ...         Check and Send Snapshot to Server CLASSICAL TRSSEC    snapshot_path=${TARGET_SNAPSHOT_IPV6}
    [Teardown]     Run keywords    Run keyword and ignore error    Disconnect from ADMIN    ${conn}    AND
    ...                            NTP server teardown

CNI-91097_03_Prepare_BTS_Snapshot_with_alarm_for_Ims_Scrambling_Verification_Btsname
    ${conn}=    Connect to ADMIN
    Change Parameter on BTS    dist_name=${LUAC_DN}    param_name=btsMaxFailedLoginAttempts
    ...                        param_value=3    connection=${conn}
    Change Parameter on BTS    dist_name=${LUAC_DN}    param_name=btsAccountLockoutDuration
    ...                        param_value=2    connection=${conn}      # value in minutes
    Run keyword and ignore error    Connect to ADMIN    password=somewrongpassword
    Sleep    5s
    Run keyword and ignore error    Connect to ADMIN    password=somewrongpassword
    Sleep    5s
    Run keyword and ignore error    Connect to ADMIN    password=somewrongpassword
    Sleep    5s
    Run keyword and ignore error    Connect to ADMIN    password=somewrongpassword
    Log    Wait for alarm BTS account locked    console=yes
    Sleep    45s
    ${active_alarms}=   coam_admin.get_active_alarms   connection=${conn}
    ${is_alarm_present}=   alarm.check_fault_in_alarm_list   ${active_alarms}   ${LOCAL_ACCOUNT_LOCK_FID}
    Should be True   ${is_alarm_present}   msg=Alarm with Fault Id ${LOCAL_ACCOUNT_LOCK_FID} not present in gnb.
    Sleep    90s
    coam_admin.get_snapshot    target_file_name=${TARGET_SNAPSHOT_BTSNAME}    coverage=HealthCheck    connection=${conn}
    Run keyword and ignore error
    ...         Check and Send Snapshot to Server CLASSICAL TRSSEC    snapshot_path=${TARGET_SNAPSHOT_BTSNAME}
    Wait Until Keyword Succeeds  15 min  20 sec   Alarm Should Not Be Active in BTS  ${LOCAL_ACCOUNT_LOCK_FID}
    [Teardown]     Run keywords    Run keyword and ignore error    Disconnect from ADMIN    ${conn}    AND
    ...                                                            Account Lockout teardown