*** Settings ***
Documentation       copyright:nokia
Library          OperatingSystem
Library          Process
Library          Collections
Library          DateTime
Library          String
Library          Telnet
Library          XML
Library          json
Library          taf.collectors.core    WITH NAME    CORE
Library          taf.collectors.tcpdump    WITH NAME    TCPDUMP
Library          taf.collectors.tshark    WITH NAME    TSHARK
Library          taf.collectors.journal    WITH NAME    JOURNAL
Library          taf.collectors.btslog    WITH NAME    BTSLOG
Library          taf.collectors.pmcounters    WITH NAME    PMCOUNTER
Library          taf.collectors.snapshot    WITH NAME    SNAPSHOT
Library          taf.collectors.l2stream3    WITH NAME    L2STREAM3
Library          taf.converters.sherpa    WITH NAME    SHERPA
Library          taf.analyzer.sherpa    WITH NAME    SHERPAREADER
Library          taf.ul.parser.pcap    WITH NAME    PCAP
Library          taf.transport.ssh    WITH NAME    ssh
Library          taf.ul.oam.selenium_coam    WITH NAME    SELENIUM
Library          taf.pdu    WITH NAME    PDU
Library          taf.converters.eventdecoder  WITH NAME  EVENTDECODER
#Library          ./../../../QTPH1/AirPhone/resources/ute/yaml_parser.py   WITH NAME    YAMLPARSER
Library          ../python/yaml_parser.py   WITH NAME    YAMLPARSER
Library          ute_wtssim
Library         taf.sw.syslog
Library          ute_fsmaccess
#Library          ute_admin
#Library          taf.gnb.oam.coam.admin    WITH NAME    coam
Library          taf.sbts.oam.coam.admin    WITH NAME    coam
Library          ta5g_egate
Library          ta5g_iperf_traffic
Library          ta_a2a
Library          taf.wts.config
Library          taf.config.wts
Library          ../python/analyze_attach_issue.py    WITH NAME    ATTACH_ISSUE_ANALYZER
Library          ../python/streaming_ttitrace_analyzer.py    WITH NAME    TTITRACEANALYZER
Library          ../python/tti_convert.py    WITH NAME    TtiConvert
Library          ../python/tti_stream_mode_convert.py    WITH NAME    TtiSMConvert

*** Variables ***
${SUITE_LOG_DIRECTORY}          ${EMPTY}
${TEST_LOG_DIRECTORY}           ${EMPTY}
${SW_BRANCH}                    ${EMPTY}    # 5G20B
${SW_VERSION}                   ${EMPTY}    # 0.800
${SW_VERSION_TOTAL}             ${EMPTY}    # 0.800.829,SBTS00_ENB_9999_210524_000005
${WTS_VERSION}                  ${EMPTY}    # 4.0.13303
${SOFTWARE_INFO}                ${EMPTY}    #5G21B_GNB_0000_000800_004261
${NRBTS_DISTNAME}               ${EMPTY}    # MRBTS-1/NRBTS-1
${GNBCUTYPE}                    ${EMPTY}    # NSA/SA
${CELLTECHNOLOGY}               ${EMPTY}    # TDD/FDD
${FR}                           ${EMPTY}    # mmwv/cmwv
${FCT_BOARD_TYPE}               ${EMPTY}    # ASIK/ASIB/ASIL
${ASP_BOARD_TYPE}               ${EMPTY}    # ABIL/ABIO
${RRU_TYPE}                      ${EMPTY}    # AEQA/AHLOA
${RRU_TYPE_LIST}                ${EMPTY}    # [u'AAHF', u'AHLOA']
${RF_TYPE}                      ${EMPTY}    #CPRI/ECPRI
${L1_TYPE}                          ${EMPTY}    #FS/L1b
${WTS_CFG}                      ${EMPTY}    # basic_fullstack_nsa_call_tdd_cmwv.cfg
${WTS_AP_XML}                   ${EMPTY}    # AirPhoneConfig_fullstack_tdd_nsa_cmwv.xml
${SCRIPT_PATH}                  ${CURDIR}/scripts
${SIB_DECODE_TIMEOUT}           600s
${TL_INIT_DIR}                  /home/ute/testline_update_results/logs
@{LOG_NAME_LIST}                btslog    x2pcap    apl3l1    snapshot    egatelog
@{LOG_NAME_SUITE_SETUP}    btslog    x2pcap
@{LOG_NAME_SUITE_TEARDOWN}      snapshot    utefiles    egatelog
&{AP_ASIK}                      ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAsik
&{AP_ABIL}                      ip=192.168.253.85    username=toor4nsn    password=oZPS0POrRieRtu    connection=APAbil
&{GNB_ASIK}                     ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsik
&{GNB_ASIK_SLAVE}               ip=192.168.253.17    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsikSlave
&{GNB_ASP}                      ip=192.168.253.21    username=toor4nsn    password=oZPS0POrRieRtu    connection=GnbAsp
&{AP_SYSLOG}                    ip=192.168.200.126    file_limit=209715200    log_name=AP_syslog    alias=AP_syslog
&{GNB_SYSLOG}                   ip=192.168.255.126    file_limit=209715200    log_name=Gnb_syslog    alias=Gnb_syslog
&{GNB}                          ip=192.168.255.1    username=toor4nsn    password=oZPS0POrRieRtu
&{AP}                           ip=192.168.200.1    username=toor4nsn    password=oZPS0POrRieRtu
${MAX_WAITTIME_CONFIGURED}      15min
${MAX_WAITTIME_CELL_SETUP}      3min
${MAX_WAITTIME_SOSREPORT}       10min
${MAX_REBOOT_TIME}              3
@{BTS_PROCEDURAL_STATES}        Configured    OnAir    IntegratedToRan
${WTS_DIR}                      /opt/wts/latest
${WTS_CONFIG_PATH}              /home/ute/Auto5G/testsuite/QTPH1/AirPhone/resources
${TLPC_IP}                      ${tl.test_pc.default_ssh_connection_details.addr}
${TLPC_SSH_UE}                  ${tl.test_pc.default_ssh_connection_details.username}
${TLPC_SSH_PWD}                 ${tl.test_pc.default_ssh_connection_details.password}
${VLAN_ID}                      ${tl.gnbs[0].cu.x2c.vlan_id}
@{NR_CELL_DNS}                  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-1/NRCELL_R-1
&{SHERPA_CONFIG_L2PS}           nr_cell_dns=${NR_CELL_DNS}    trace_type=Sherpa
&{SHERPA_CONFIG_L2LO}           nr_cell_dns=${NR_CELL_DNS}    up_sw=L2Lo    trace_type=Sherpa
&{SHERPA_CONFIG_L2HIPDCP}       up_sw=L2HiPdcp    trace_type=Sherpa
&{SHERPA_CONFIG_L2HIRLC}        nr_cell_dns=${NR_CELL_DNS}    up_sw=L2HiRlc    trace_type=Sherpa
@{L2STREAM_CONFIG}              &{SHERPA_CONFIG_L2HIPDCP}    &{SHERPA_CONFIG_L2HIRLC}    &{SHERPA_CONFIG_L2PS}    &{SHERPA_CONFIG_L2LO}
${TCPDUMP_CMD}                  tcpdump -i eth3 -v -w /tmp/tcpdump_testVM_Tcpdump.pcap
${X2AP_CMD}                     tcpdump -i any -s 2000 -w /ffs/run/logs/x2.pcap
${APBIP_CMD}                    tcpdump -i ethbp1 -s 65535 -w /tmp/apL1L2.pcap
${APL3L1_CMD}                   tcpdump -i etha01 -s 65535 -w /tmp/apL3L1.pcap
${GNBCELLSETUP_CMD}             tcpdump -i any -w /ffs/run/logs/cellsetup_gnb.pcap
${UL_PORT}                      7071  # SA iperf port for UL
${DL_PORT}                      7070  # SA iperf port for DL
${IPERF_EGREP}                  egrep -o '[[:digit:]]*.?[[:digit:]]*[[:space:]]Mbits/sec'
${NR_CAPBAILITIES}              01800000010900000004D0100209A001E0000000000000454000000000000054000004008010
@{UE_NR_CAPABILITIES_PATT}      ue_nr_capabilities=[0-9a-zA-Z]+
@{UE_NR_CAPABILITIES_VAL}       ue_nr_capabilities=${NR_CAPBAILITIES}
${RESERVATION_FILE_PATH}        /opt/ute/reservation.json
${PDU_MODEL}                    ${tl.pdus[0].__class__.__name__}
${AP_PDU_IP}                    ${tl.ues[0].l1.common_units[0].pdu_port.pdu.addr}
${AP_PDU_PORT}                  ${tl.ues[0].l1.common_units[0].pdu_port.port_no}
${GNB_PDU_IP}                   ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu.addr}
${GNB_PDU_PORT}                 ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.port_no}
${AP_PDU}                        ${tl.ues[0].l1.common_units[0].pdu_port.pdu}
${GNB_PDU}                       ${tl.gnbs[0].dus[0].airscale.common_units[0].pdu_port.pdu}
${SSH_CMD}                       sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1
${Ng_link_pattern}    NG link is Up
${Address_distribution_pattern}    Address Distribution is complete
${UE_SIB_decoding_pattern}    SystemInformationBlockType1-NR      #SystemInformationBlockType1
${GNB_MIRRORING_TOOL_LINK}      https://gitlabe2.ext.net.nokia.com/juhakang/tools.git
${PACKAGE_FTP_URL}    http://files.ute.nsn-rdnet.net/builds/enb/base/
${PACKAGE_FTP_URL_OLD}    https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/
${FLAG_CATCH_SUITE_LOG}    ${False}

#egate console log for onair process of SANSA, reboot is a must for each running time
#UEC-1 is active
#CHANGE STATE: ACTIVE - SimMode is ready now    05:09:05.637
#UEC-1: eNB 1 cell 1: MIB Updated
#UEC-1: eNB 1 cell 1: SystemInformationBlockType1 updated    05:09:05.637
#UEC-1: eNB 1 cell 1: SystemInformationBlockType2 updated    05:09:05.638
#AMF-1: AMF - IP:10.0.1.2 NG link is Up    05:09:44.229   (it's longer to wait,if no reboot,log stop here)
#UEC-1: Airphone: Address Distribution is complete    05:09:44.916
#UEC-1: eNB 2 cell 1: MasterInformationBlock-NR Updated    05:09:45.750
#UEC-1: Airphone: Cell Setup completed for [CELL_ID:1]    05:09:45.750
#UEC-1: eNB 2 cell 1: SystemInformationBlockType1-NR updated    05:09:49.977
#UEC-1: eNB 2 cell 1: SystemInformationBlockType2-NR updated
#UEC-1: eNB 2 cell 1: SystemInformationBlockType3-NR updated    05:09:50.050
#UEC-1: eNB 2 cell 1: SystemInformationBlockType4-NR updated
#UEC-1: eNB 2 cell 1: SystemInformationBlockType5-NR updated    05:09:50.051
#enb_x2_link_up enb=1 target=2
#ENB-1: X2AP Link with GNB-2 (10.0.1.2:36422[0]) is up
#ue_register id=1
