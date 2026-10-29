*** Settings ***
Documentation
...   author: PZ_2_WRO_5

Library         taf.config.scf     WITH NAME  scf
Library         taf.transport.ssh  WITH NAME  ssh
Library         taf.sbts.oam.coam.admin  WITH NAME  coam
Library         testsuite.RRM.Wroclaw.resources.webui.WebuiInterface  WITH NAME  WebUI
Library         taf.collectors.btslog  WITH NAME   btslog
Resource        testsuite/RRM/Wroclaw/resources/preconditions.robot
Library         DateTime
Library         String
Library         Collections
Library         testsuite/RRM/Wroclaw/5GC001348/resources/1348_kw.py
Library         taf.ul.alarms_watchdog    WITH NAME    watchdog
Resource        ../../../../resources/btslog_collecting.robot

*** Keywords ***
Check L1L2 dtx
    [Arguments]  ${dir}=${OUTPUT DIR}/SA_${TEST NAME}.pcap
    ${msgs}    check dtx   ${dir}
    should be true    ${msgs}

Check L1L2 sfn
    [Arguments]  ${dir}=${OUTPUT DIR}/SA_${TEST NAME}.pcap
    ${msgs}    check sfn   ${dir}
    should be true    ${msgs}
