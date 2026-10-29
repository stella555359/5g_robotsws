# # #*** Settings ***
# # #Force Tags    PY36
# # #Suite Setup
# # #Suite Teardown
# # #Documentation
# # #...   author: xiaofeng.1.zhu@nokia-sbell.com
# # #...   contact: xiaofeng.1.zhu@nokia-sbell.com
# # #Resource          ./Resources/common_keyword.robot
# # #Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
# # #Resource          testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/container_log_capturing.robot
# # #Library           ./Resources/common_keyword.py
# # #Library           taf/rfrl/utilities/parsers/check_cap.py
# # #Library           check_cap.CapPacket    WITH NAME    cap
# # #Library           ute_syslog
# # #
# # #*** Variables ***
# # #
# # #${filename}         FRIps.txt
# # #${epc_log_path}     /tmp
# # #${epc_log_path_1}     /ffs/run/config/
# # #${TS_CASE_LOG_PATH}    ${output_dir}
# # #${container_alias}   Container
# # #${ru_alias}   RU
# # #${startup_BTSOM}   startup_BTSOM.log
# # #${alarm_4383}    FaultId: 4383
# # #${alarm_7101}    larmNumber: 7101
# # #${listen_port}    br1
# # #${filename_tcp}    tcpdump_dI.pcap
# # #${log_dir}    /tmp
# # #${connection}    cu_conn
# # #${ul_throughput}    20M
# # #${test_ute}                      ${tl.test_pc.default_ssh_connection_details.addr}
# # #${ute_name}                      ${tl.test_pc.default_ssh_connection_details.username}
# # #${test_password}                 ${tl.test_pc.default_ssh_connection_details.password}
# # #${list}         50011
# # #
# # #
# # #*** Test Cases ***
# # #[1]5GC002238_QA_3_5GC000170_ASOD_recovery_scenarios_for_SMOD_failure_with_L3_call
# # #    [Documentation]    this case is to verify asod recovery function after smod failure with l3 call
# # #    [Tags]     CRT_22R2
# # #    [Setup]   Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
# # #    Reboot DU and Check cell onAir
# # #    Connection to Du making alarm
# # #    Reboot DU and Check cell onAir
# # #    attach multi power ue    ue_num=${1}
# # #    start power ue traffic       ue_num=${1}    ul_throughput=${ul_throughput}
# # #    stop multi power ue traffic     ue_num=${1}
# # #    [Teardown]    CI_interface.Common Case Teardown
# # #
# # #[1]5GC002238_QA_4_5GC000170_RMOD_unit_recovery_with_L3_call
# # #    [Documentation]    this case is to verify Rmod recovery function with l3 call
# # #    [Tags]     5GC002238-QA    CRT_20B
# # #    [Setup]   Set test variable    ${LOG_PATH}    ${TS_CASE_LOG_PATH}
# # #    RMOD_unit_recovery
# # #    Login ssh du and capture wireshark    listen_port=${listen_port}     log_dir=${log_dir}    filename_tcp=${filename_tcp}
# # #    ...    connection=${connection}
# # #    attach multi power ue    ue_num=${1}
# # #    start power ue traffic       ue_num=${1}    ul_throughput=${ul_throughput}
# # #    Stop and Download Log     filename_tcp=${filename_tcp}    connection=${connection}
# # #    stop multi power ue traffic     ue_num=${1}
# # #    [Teardown]    CI_interface.Common Case Teardown
# # #
