*** Settings ***
Library     OperatingSystem
Library     Process
Library     Collections
Library     DateTime
Library     String
Library     Telnet
Library     XML
Library     json
Library     taf.collectors.core    WITH NAME    core
Library     taf.collectors.tcpdump    WITH NAME    tcpdump
Library     taf.collectors.tshark    WITH NAME    TSHARK
Library     taf.collectors.journal    WITH NAME    JOURNAL
Library     taf.collectors.btslog    WITH NAME    BTSLOG
Library     taf.collectors.pmcounters    WITH NAME    PMCOUNTER
Library     taf.collectors.snapshot    WITH NAME    SNAPSHOT
Library     taf.collectors.l2stream3    WITH NAME    L2STREAM3
Library     taf.converters.sherpa    WITH NAME    SHERPA
Library     taf.analyzer.sherpa    WITH NAME    SHERPAREADER
Library     taf.ul.parser.pcap    WITH NAME    PCAP
Library     taf.transport.ssh    WITH NAME    ssh
Library     taf.ul.oam.selenium_coam    WITH NAME    SELENIUM
Library     taf.hw.pdu    WITH NAME    pdu
Library     taf.converters.eventdecoder    WITH NAME    EVENTDECODER
Library     taf.sw.scout    WITH NAME    scout
#Library    testsuite/QTPH1/AirPhone/resources/ute/yaml_parser.py    WITH NAME    YAMLPARSER_AP
Library     ./scripts/python/yaml_parser.py    WITH NAME    YAMLPARSER
Library     ./scripts/python/parse_testconfig_yaml.py    WITH NAME    YAMLPARSER_CN1
Library     ute_wtssim
Library     ute_syslog
Library     ute_fsmaccess
Library     ute_reporting_portal
#Library    ute_admin
#Library    taf.gnb.oam.coam.admin    WITH NAME    COAM
Library     taf.sbts.oam.coam.admin    WITH NAME    COAM
Library     ta5g_egate
Library     ta5g_iperf_traffic
Library     ta_a2a
Library     taf.wts.config
Library     taf.config.wts
Library     ./scripts/python/analyze_attach_issue.py    WITH NAME    ATTACH_ISSUE_ANALYZER
Library     ./scripts/python/streaming_ttitrace_analyzer.py    WITH NAME    TTITRACEANALYZER
Library     ./scripts/python/tti_convert.py    WITH NAME    TtiConvert
Library     ./scripts/python/tti_stream_mode_convert.py    WITH NAME    TtiSMConvert
Library     ./scripts/python/pre_deal_csv.py    WITH NAME    CSV_PRE_DEAL
Library     ./scripts/python/get_tp_from_syslog.py    WITH NAME    Analyze_syslog
Library     ${CURDIR}/scripts/python/tak_xml/
Library     ${CURDIR}/scripts/python/tak_files/
Library     ${CURDIR}/scripts/python/ta_kiss_gnb/
Library     ./scripts/python/handle_csv_pandas.py    WITH NAME    handle_csv_pandas

*** Variables ***
${SUITE_LOG_DIRECTORY}             ${EMPTY}
${TEST_LOG_DIRECTORY}              ${EMPTY}
${SW_BRANCH}                       ${EMPTY}    # SBTS22R2
${SW_VERSION}                      ${EMPTY}    # SBTS00    SBTS23R1
${SW_VERSION_TOTAL}                ${EMPTY}    # SBTS00    SBTS23R1_ENB_9999_211111_000006
${WTS_VERSION}                     ${EMPTY}    # 4.0.13303
${SOFTWARE_INFO}                   ${EMPTY}    #SBTS22R2_ENB_9999_211111_000006
${IS_SOFTWARE_KNIFE}               ${False}
${MRBTS_DISTNAME}                  ${EMPTY}    # MRBTS-1
${NRBTS_DISTNAME}                  ${EMPTY}    # MRBTS-1/NRBTS-1
${GNBCUTYPE}                       ${EMPTY}    # NSA/SA
${GNB_FRAME}                       ${EMPTY}    #right_side/left_side
${CELLTECHNOLOGY}                  ${EMPTY}    # TDD/FDD
${FR}                              ${EMPTY}    # mmwv/cmwv
${FCT_BOARD_TYPE}                  ${EMPTY}    # ASIK/ASIB/ASIL
${ASP_BOARD_TYPE}                  ${EMPTY}    # ABIL/ABIO
@{ASP_BOARDS_TYPE}
${RRU_TYPE}                        ${EMPTY}    # AEQA/AHLOA
${RRU_TYPE_LIST}                   # [u'AAHF', u'AHLOA']
${RF_TYPE}                         ${EMPTY}    #CPRI/ECPRI
${L1_TYPE}                         ${EMPTY}    #FS/L1b
@{NR_PHY_CELL_IDS}
${AP_FCT_BOARD_TYPE}               ${EMPTY}
${AP_ASP_BOARD_TYPE}               ${EMPTY}
@{AP_ASP_BOARDS_TYPE}
${COMPONENT_CARRIER}               ${EMPTY}    #1/2
${WTS_CFG}                         ${EMPTY}    # basic_fullstack_nsa_call_tdd_cmwv.cfg
${WTS_AP_XML}                      ${EMPTY}    # AirPhoneConfig_fullstack_tdd_nsa_cmwv.xml
${SCRIPT_PATH}                     ${CURDIR}/scripts
${SIB_DECODE_TIMEOUT}              600s
${TL_INIT_DIR}                     /home/ute/testline_update_results/logs
@{LOG_NAME_LIST}                   btslog    x2pcap    apl3l1    snapshot    egatelog
@{LOG_NAME_SUITE_SETUP}            btslog    x2pcap
@{LOG_NAME_SUITE_TEARDOWN}         snapshot    utefiles    egatelog
&{AP_ASIK}                         ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
&{AP_ABIL}                         ip=192.168.253.85    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAbil
&{GNB_ASIK}                        ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{GNB_ASIK_SLAVE}                  ip=192.168.253.17    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsikSlave
&{GNB_ASP}                         ip=192.168.253.21    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsp
&{AP_SYSLOG}                       ip=192.168.200.126    file_limit=209715200    log_name=AP_syslog    alias=AP_syslog
&{GNB_SYSLOG}                      ip=192.168.255.126    file_limit=209715200    log_name=Gnb_syslog    alias=Gnb_syslog
&{GNB}                             ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu
&{AP}                              ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu
${MAX_WAITTIME_CONFIGURED}         15min
${MAX_WAITTIME_CELL_SETUP}         3min
${MAX_WAITTIME_SOSREPORT}          10min
${MAX_REBOOT_TIME}                 3
${UEC_REACTION_TIME}               1000
@{BTS_PROCEDURAL_STATES}           Configured    OnAir    IntegratedToRan
${WTS_DIR}                         /opt/iphy/latest
${WTS_CONFIG_PATH}                 /home/ute/Auto5G/testsuite/QTPH1/AirPhone/resources
@{NR_CELL_DNS}                     /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
&{SHERPA_CONFIG_L2PS}              up_sw=L2Ps    trace_type=Sherpa
&{SHERPA_CONFIG_L2LO}              up_sw=L2Lo    trace_type=Sherpa
&{SHERPA_CONFIG_L2HIPDCP}          up_sw=L2HiPdcp    trace_type=Sherpa
&{SHERPA_CONFIG_L2HIRLC}           up_sw=L2HiRlc    trace_type=Sherpa
@{L2STREAM_CONFIG}                 &{SHERPA_CONFIG_L2HIPDCP}    &{SHERPA_CONFIG_L2HIRLC}    &{SHERPA_CONFIG_L2PS}    &{SHERPA_CONFIG_L2LO}
&{TTITRACE_CONFIG_L2PS}            up_sw=L2Ps    trace_type=Component
&{TTITRACE_CONFIG_L2LO}            up_sw=L2Lo    trace_type=Component
&{TTITRACE_CONFIG_L2HIPDCP}        up_sw=L2HiPdcp    trace_type=Component
&{TTITRACE_CONFIG_L2HIRLC}         up_sw=L2HiRlc    trace_type=Component
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2HIPDCP}    &{TTITRACE_CONFIG_L2HIRLC}    &{TTITRACE_CONFIG_L2PS}    &{TTITRACE_CONFIG_L2LO}
@{L2STREAM_COMPONENT_L2PS_CONFIG}       &{TTITRACE_CONFIG_L2PS}
${TCPDUMP_CMD}                     tcpdump -i eth3 -v -w /tmp/tcpdump_testVM_Tcpdump.pcap
${X2AP_CMD}                        tcpdump -i any -s 2000 -w /ffs/run/logs/x2.pcap
${APBIP_CMD}                       tcpdump -i ethbp1 -s 65535 -w /tmp/apL1L2.pcap
${APL3L1_CMD}                      tcpdump -i etha01 -s 65535 -w /tmp/apL3L1.pcap
${GNBCELLSETUP_CMD}                tcpdump -i any -w /ffs/run/logs/cellsetup_gnb.pcap
${GNB_WIRESHARK_CMD}               tcpdump -i any -w /ffs/run/logs/wireshark_gnb.pcap
${UL_PORT}                         7071    # SA iperf port for UL
${DL_PORT}                         7070    # SA iperf port for DL
${IPERF_EGREP}                     egrep -o '[[:digit:]]*.?[[:digit:]]*[[:space:]]Mbits/sec'
${NR_CAPBAILITIES}                 01800000010900000004D0100209A001E0000000000000454000000000000054000004008010
@{UE_NR_CAPABILITIES_PATT}         ue_nr_capabilities=[0-9a-zA-Z]+
@{UE_NR_CAPABILITIES_VAL}          ue_nr_capabilities=${NR_CAPBAILITIES}
${RESERVATION_FILE_PATH}           /opt/ute/reservation.json
${SSH_CMD}                         sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
${NG_LINK_PATTERN}                 NG link is Up
${ADDRESS_DISTRIBUTION_PATTERN}    Address Distribution is complete
${UE_SIB_DECODING_PATTERN}         SystemInformationBlockType2-NR    #SystemInformationBlockType1
${GNB_MIRRORING_TOOL_LINK}         https://gitlabe2.ext.net.nokia.com/juhakang/tools.git
${PACKAGE_FTP_URL}                 http://files.ute.nsn-rdnet.net/builds/enb/base/
#${PACKAGE_FTP_URL_WFT_SBTS}        https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build
${PACKAGE_FTP_URL_WFT_SBTS}        https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build
${PACKAGE_FTP_URL_WFT_5G}          https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release
${MCSHARK_URL}                     https://artifactory-hz1.int.net.nokia.com/artifactory/wslte5g_plugins-local/MCShark
${FLAG_CATCH_SUITE_LOG}            ${False}
${REORDERING_WINDOW_SIZE}          500
${REORDERING_TIMER}                300
${ALARM_MESSAGE}                   ${EMPTY}
${EMIL_DOCKER_COMPOSE_FILE}        ${CURDIR}/scripts/emil/docker-compose.yml
${EMIL_START_CMD}                  ${CURDIR}/scripts/emil/emil_start_cmd.txt
${MPLANE_IP}                       ${EMPTY}
${NR_NON_SIMULATED_CELL_NUM}       ${EMPTY}
${KLL_CMD}                         getResourcesUsage -f cp_rt_all_info_0 -l @Cprt #0x2524
${BOO_CMD}                         getResourcesUsage -f cp_rt_all_info_0 -l @Cprt #0x2515
${CPRT_INFO_LOG_PATH}              /tmp/node_CPRT00/tmp/5gcp_GetResourceUsage/
${MCSHARK_PLUGIN}                  /home/ute/.local/lib/wireshark/plugins/
${ROOT_TYPE}                       hard_reboot
${AP_PDU_IP}                       ${EMPTY}    #${tl.ues[0].l1.common_units[0].pdu_port.pdu.addr}
${AP_PDU_PORT}                     ${EMPTY}    #${tl.ues[0].l1.common_units[0].pdu_port.port_no}
${GNB_PDU_IP}                      ${EMPTY}    #${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${GNB_PDU_PORT}                    ${EMPTY}    #${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
${AP_PDU}                          ${EMPTY}    #${tl.ues[0].l1.common_units[0].pdu_port.pdu}
${GNB_PDU}                         ${EMPTY}    #${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu}
${TLPC_IP}                         ${EMPTY}    #${tl.test_pc.default_ssh_connection_details.addr}
${TLPC_SSH_UE}                     ${EMPTY}    #${tl.test_pc.default_ssh_connection_details.username}
${TLPC_SSH_PWD}                    ${EMPTY}    #${tl.test_pc.default_ssh_connection_details.password}
${VLAN_ID}                         ${EMPTY}    #${tl.gnbs[0].cu.x2c.vlan_id}
${SKIP_ADMIN_CLI}                  ${TRUE}
${BASELINE}                        ${EMPTY}
${CUDU_L2_GOLDEN_FILE_ADDRESS}     https://gitlabe1.ext.net.nokia.com/5gl2cn1/cudu_l2_golden_files.git
${LOCAL_GOLDEN_FILE_PATH}          /home/ute/CUDU_L2_GOLDEN_FILE


