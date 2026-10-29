# *** Settings ***
# 
# Force Tags    RAN_5G    RAN_5G_TDD    STATE_SW_UPLOADED    CLOUD_5G_CLASSICAL_ASKEY_SA_ASOEB1_3xAZQJ    SBTS00    CRT_UTE    PY36
# Resource    ./Resource/Common.robot
# Variables    ../libraries/global_vars.py
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
# 
# Suite Setup   Common Suite Setup
# Suite Teardown    Common Suite Teardown
# #Test Setup     Append To List  ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
# 
# 
# *** Variables ***
# @{ALL_TEST_STATUS}
# ${IPv4address}=       ${tl.test_pcs[0].connection_details.addr}
# ${outputPathPcap}=    /home/ute/Remote.pcap
# ${path_for_syslog}    /var/log/btslog-udp.json
# ${time1}     1
# ${time2}     2
# ${DSCPvalue}    0
# ${protocol}    UDP
# ${OUT_SCF_MRBTS_IP}    ${tl.gnbs[0].dus[0].f1_m_ip_addr}
# 
# *** Test Cases ***
# 5GC000506-A_2_Syslog configuration for storing logs to remote server with use IPv4 _UDP protocol
#     [Tags]       AUTHOR_dali.wang@nokia-sbell.com
#     [Documentation]
#     ...    Checks if IPv4 address for remote server is set and syslog transmission is enabled in unsecure mode (UDP)
#     [Timeout]   1h
#     log to console   UDP RFC remote syslog on
#     Perform remoteSyslogIPaddress parameter activation
#     Enable remote syslog transmission
#     Assert that syslog server is receiving logs        ${outputPathPcap}
#     ${filtered_output}    check if pcap contains logs with filter    ip.addr == ${OUT_SCF_MRBTS_IP}    ${outputPathPcap}
#     should be true    ${filtered_output}   received proper logs from remote server
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# 5GC000506-A_3_Syslog configuration for storing logs to remote server with use IPv4 (transmission in interval time)
#     [Tags]      AUTHOR_dali.wang@nokia-sbell.com
#     [Documentation]
#     ...    Checks ability to enable transmission with new configuration of Syslog and to measure time of collecting logs
#     ...    on remote server with the use of IPv4
#     [Timeout]   1h
#     Perform remoteSyslogIPaddress parameter activation    ${time1}
#     Enable remote syslog transmission
#     Assert that syslog server is receiving logs      ${outputPathPcap}
#     ${filtered_output}    check if pcap contains logs with filter    ip.addr == ${OUT_SCF_MRBTS_IP}    ${outputPathPcap}
#     should be true    ${filtered_output}   received proper logs from remote server
# #    wait until keyword succeeds  3 min  10 sec  Assert that remote syslog status is disabled
#     ${before}  get file size   ${outputPathPcap}
#     Sleep    2 min
#     ${after}  get file size   ${outputPathPcap}
#     should be true      ${after}==${before}
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# 5GC000506-A_16_Syslog stream sending time expires
#     [Tags]       AUTHOR_dali.wang@nokia-sbell.com
#     [Documentation]
#     ...    Checks ability to verify Syslog mechanism during sending time expire
#     [Timeout]   1h
#     Perform remoteSyslogIPaddress parameter activation    ${time2}
#     Enable remote syslog transmission
#     Assert that syslog server is receiving logs         ${outputPathPcap}
#     ${filtered_output}    check if pcap contains logs with filter    ip.addr == ${OUT_SCF_MRBTS_IP}    ${outputPathPcap}
#     should be true    ${filtered_output}   received proper logs from remote server
#     COAM Reset Site
#     Wait for Cell Onair    8min   cell_index=1
#     [Teardown]   Case Teardown
# 
# 5GC000506-A_18_Remote syslog bandwith using UDP protocol
#     [Tags]       AUTHOR_dali.wang@nokia-sbell.com
#     [Documentation]
#     ...    Checks if BTS transmits syslog to the remoteserver in UDP configuration using a QoS setting
#     ...    independent from the one assigned to the M-Plane services
#     [Timeout]   1h
#     Perform remoteSyslogIPaddress parameter activation
#     Enable remote syslog transmission
#     Assert that syslog server is receiving logs         ${outputPathPcap}
#     ${filtered_output}    check if pcap contains logs with filter
#         ...    ip.addr == ${OUT_SCF_MRBTS_IP}    ${outputPathPcap}
#     should be true    ${filtered_output}   received proper logs from remote server
# #    Wait until keyword succeeds  2 min  10 sec  Assert that remote syslog status is disabled
#     Perform remoteSyslogIPaddress parameter activation    ${time1}    ${DSCPvalue}
# #    Enable remote syslog transmission
#     Assert that syslog server is receiving logs         ${outputPathPcap}
#     ${filtered_output}    check if pcap contains logs with filter
#         ...    ip.addr == ${OUT_SCF_MRBTS_IP} && ip.dsfield.dscp == 0   ${outputPathPcap}
#     should be true    ${filtered_output}    received proper logs from remote server
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# 5GC000506-A_14_Syslog stop_start recording due to outage occur
#     [Tags]      AUTHOR_dali.wang@nokia-sbell.com
#     [Documentation]
#     ...    Checks ability to verify Syslog mechanism during stopped-started transmission
#     ...    and to check if logs are being send chronological after that.
#     [Timeout]   1h
#     Perform remoteSyslogIPaddress parameter activation
#     Enable remote syslog transmission
#     Assert that syslog server is receiving logs         ${outputPathPcap}
#     ${filtered_output}    check if pcap contains logs with filter    ip.addr == ${OUT_SCF_MRBTS_IP}    ${outputPathPcap}
#     should be true    ${filtered_output}  did not received proper logs from remote server
# #    ${before_reset}  get file size   ${path_for_syslog}
#     log to console  Reset BTS
#     COAM Reset Site
#     Wait for Cell Onair    8min   cell_index=1
#     Assert that syslog server is receiving logs         ${outputPathPcap}
#     ${filtered_output}    check if pcap contains logs with filter    ip.addr == ${OUT_SCF_MRBTS_IP}    ${outputPathPcap}
#     should be true    ${filtered_output}    received proper logs from remote server
# #    ${after_reset}  get file size   ${path_for_syslog}
# #    log to console  before ${before_reset}
# #    log to console  after ${after_reset}
# #    should be true      ${after_reset}>${before_reset}
#     [Teardown]    robot_common_operations.Common Case Teardown
# 
# 5GC000506 Remote Syslog for continuous log storage
#     [Setup]    run keywords    Append To List  ${ALL_TEST_STATUS}   ${PREV_TEST_STATUS}
#     ...    AND      robot_common_operations.Common Case Setup
#     List Should Not Contain Value    ${ALL_TEST_STATUS}    FAIL
