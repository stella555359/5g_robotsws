*** Settings ***
Documentation    import py and robot library; define some common variables.

Library           OperatingSystem
Library           Process
Library           Collections
Library           DateTime
Library           String
Library           Telnet
Library           XML    lxml=True
Library           json
Library           taf.selenium.sbts  WITH NAME  selenium_coam
Library           taf.pdu    WITH NAME    pdu
Library           taf.transport.ssh    WITH NAME    ssh
Library           ute_syslog
Library           taf.sbts.oam.coam.admin    WITH NAME    sbts_admin
Library           taf.alias.store    WITH NAME    alias_store
Library           ./python/KISS/ta_kiss_gnb/
Library           ./python/status_filtering.py
Library           ./python/ta_xml/
Library           ./python/syslog_checker.py
Library           ./python/json_paser.py
Library           ./python/change_cell_degraded.py
Library           ./python/streaming_ttitrace_analyzer.py    WITH NAME    TRACEANALYZER
Library           ./python/gnb_tool.py
Library           ./python/vendor_update.py
Library           ./python/check_iq_capture.py

Library           ./python/command_execution_in_bts.py
Library           ./python/iq_data_analyzer_handler.py
Library           ./python/rotta_file_transfer.py
Library           ./python/check_5gmax_csv.py
Library           ./python/find_and_extracte_file.py

Resource          ./common_resource_bts.robot
Resource          ./common_resource_suite.robot
Resource          ./common_resource_log_capture.robot
Resource          ./common_resource_log_analysis.robot
Resource          ./common_resource_radio.robot
Resource          ./common_resource_ue.robot

*** Variables ***
${btsid}          ${tl.gnbs[0].global_bts_id}
${amfIPAddress}    10.70.255.6
${WEBUI_URL}       https://${tl.gnbs[0].dus[0].f1_m_ip_addr}
&{GNB_ASIB}       ip=192.168.255.129    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{GNB_SYSLOG}     ip=192.168.255.126    file_limit=104857600    log_name=GNB_syslog_common
...               tar_log_name=GNB_syslog_common.tar.gz    alias=GNB_syslog_common
${TEST_PC_IP}     ${tl.test_pc.default_ssh_connection_details.addr}
${TEST_PC_USERNAME}    ${tl.test_pc.default_ssh_connection_details.username}
${TEST_PC_PASSWORD}    ${tl.test_pc.default_ssh_connection_details.password}
${ASIB_IP}        ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.addr}
${ASIB_USERNAME}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.username}
${ASIB_PASSWORD}    ${tl.gnbs[0].dus[0].airscale.common_units[0].lmp_connection.password}
${PM_reporting_interval}    5
${72a_flag}    ${EMPTY}
