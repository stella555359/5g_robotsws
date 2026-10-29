# *** Settings ***
# Documentation
# ...         author: yingying.li
# ...         contact: yingying.li@nokia-sbell.com
# ...         squad group: 5G_PZ_MMW_HZ_3_SG
# ...         5GC000829-D_5GC000508_Snapshot_triggered_to_LSS
# 
# Force Tags      CRT_21A    CRT_TRUNK    CRT_21B
# ...    PY36
# Library    taf.sbts.oam.coam.admin   WITH NAME   admin_cli
# Library    taf.transport.ssh		WITH NAME	ssh
# Library    SSHLibrary    WITH NAME    ssh_lib
# 
# 
# Resource      ./resources/5GC000508_Common_Keywords.robot
# 
# 
# Suite Setup        robot_common_operations.Common Suite Setup
# Suite Teardown     robot_common_operations.Common Suite Teardown
# 
# *** Variables ***
# ${lssIPaddress}    10.57.150.41
# ${lssPortNo}       22
# ${bts_logs_dir}    /tmp/btslog2/
# 
# *** Test Cases ***
# [1]5GC000829-D_5GC000508_Snapshot_triggered_to_LSS
#     [Documentation]    The purpose of this test case is to check if defined substring
#     ...                in syslog stream will trigger snapshot collection and it is sent
#     ...                to remote destination: LSS server
#     [Tags]             CRT_21A    CRT_TRUNK    CRT_21B
#     [Setup]     Run keywords    start BTSLOG collection
# 	...    AND     robot_common_operations.Common Case Setup
#     delete snapshot files in LSS
#     Connect to gnb coam via ssl
#     Set mrbtsId variable
#     set syslogSubstringTrigger parameter   active 4459
#     Change Parameter    ${mrbtsId}/MNL-1/MNLENT-1/TRBLCADM-1   diagSnapDestination    update    lss
#     Perform lssConfig complex parameter activation    lssIPaddress=${lssIPaddress}    lssPortNo=${lssPortNo}
#     #Admin Lock Cell for snapshot
#     #Wait until keyword succeeds    1 min    1 min    Check if snapshot trigger occured in syslog
#     Change Parameter    ${mrbtsId}/MNL-1/AMGR-1    enableDefaultPasswdAlarm     update    true
#     sleep    2min
#     Wait until keyword succeeds    1 min    1 min    Check existence of remote snapshot    ${lssIPaddress}    coam
#     ...    zO&n1W*ktp7    /home/coam
#     Make empty BTS logs dir     ${bts_logs_dir}
#     [Teardown]    Run keywords    BTSLOG Collect log
#     #...    AND    Admin Unlock Cell after execution
#     ...    AND    Clear syslogSubstringTrugger parameter
#    ...    AND    Change Parameter    ${mrbtsId}/MNL-1/AMGR-1    enableDefaultPasswdAlarm     update    false
#     ...    AND    ADMIN CLI disconnection
# 	...    AND    robot_common_operations.Common Case Teardown
# 
# 
