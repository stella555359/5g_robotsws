*** Settings ***
Library       String
Library       OperatingSystem
Library       Collections
Library       BuiltIn
Library       taf.collectors.core    WITH NAME    core
Library       taf.collectors.tcpdump    WITH NAME    tcpdump
Library       taf.collectors.tshark    WITH NAME    tshark
Library       taf.collectors.journal    WITH NAME    journal
Library       taf.collectors.btslog    WITH NAME    btslog
Library       taf.collectors.pmcounters    WITH NAME    pmcounter
Library       taf.collectors.snapshot    WITH NAME    snapshot
Library       taf.collectors.l2stream3    WITH NAME    l2stream3
Library       taf.converters.sherpa    WITH NAME    sherpa
Library       taf.analyzer.sherpa    WITH NAME    sherpareader
Library       taf.ul.parser.pcap    WITH NAME    pcap
Library       taf.transport.ssh    WITH NAME    ssh
Library       taf.hw.pdu    WITH NAME    pdu
Library       taf.converters.eventdecoder    WITH NAME    eventdecoder
Library       taf.selenium.sbts    WITH NAME    selenium_coam
Library       taf.sbts.oam.coam.admin    WITH NAME    coam
Library       taf.hw.rf_attenuator    WITH NAME    PA
Library       ute_syslog
Library       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/python/ue.py
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/power_ue/power_ue.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
# Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/coam.robot

*** Variables ***
${SUITE_LOG_DIRECTORY}          ${empty}
${TEST_LOG_DIRECTORY}           ${empty}
${SW_BRANCH}                    ${empty}    # SBTS22R2
${GNB_INDEX}                    ${0}
${NRBTSID}                      ${tl.gnbs[0].global_bts_id}
${MRBTSID}                      ${tl.gnbs[0].instance_id}
&{GNB}                          ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu
&{GNB_SYSLOG}                   ip=192.168.255.126    file_limit=209715200    log_name=Gnb_syslog    alias=Gnb_syslog
&{TTITRACE_CONFIG_L2PS}         up_sw=L2Ps    trace_type=Component
&{TTITRACE_CONFIG_L2LO}         up_sw=L2Lo    trace_type=Component
&{TTITRACE_CONFIG_L2HIPDCP}     up_sw=L2HiPdcp    trace_type=Component
&{TTITRACE_CONFIG_L2HIRLC}      up_sw=L2HiRlc    trace_type=Component
@{L2STREAM_COMPONENT_CONFIG}    &{TTITRACE_CONFIG_L2HIPDCP}    &{TTITRACE_CONFIG_L2HIRLC}    &{TTITRACE_CONFIG_L2PS}    &{TTITRACE_CONFIG_L2LO}
