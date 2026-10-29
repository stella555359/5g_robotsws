

COMMON_DICTIONARY = {    # accessed externally to generate docs
    "Jenkins Parameters": {
        "JOB_NAME": {
            'default': 'undefined',
            'description': "for grafana",
            'modifiable': False
        },
        "JOB_URL": {
            'default': 'undefined',
            'description': "for grafana",
            'modifiable': False
        },
        "BUILD_ID": {
            'default': 'undefined',
            'description': "for grafana",
            'modifiable': False
        },
        "P_TURANDOT_DIR": {
            'default': '/tmp/',
            'description': "path to store logs",
        },
        "CFG_ENABLE_REMOTE_LOG_UPLOAD": {
            'default': 'true',
            'description': """enable or disable remote log upload,
  > if storage node is getting full. we need to stop and fix""",
        },
        "P_TURANDOT_LINK": {
            'default': 'http://turandot.dynamic.nsn-net.net/share/Performance_Logs',
            'description': "description to be added",
            'modifiable': False
        },
        "P_TESTLINE_NAME": {
            'default': 'undefined',
            'description': "auto fetch",
            'modifiable': False
        },
        "P_TOPOLOGY": {
            'default': 'undefined',
            'description': "Topology of the testline",
        },
        "P_VARIANT": {
            'default': 'undefined',
            'description': "the name of a topology configs variant. Agent uses the default variant if not passed.",
        },
        "P_JOB_DESCRIPTION": {
            'default': 'undefined',
            'description': "write a proper description for easy tracking",
        }
    },

    'Testcase Execution Manipulation': {
        "ENABLE_F1_STATUS": {
            'default': 'true',
            'description': "description to be added",
        },
        "RESET_WTS_ON_TC_TEARDOWN": {
            'default': 'false',
            'description': "description to be added",
        },
        "KILL_WTS_ON_TS_TEARDOWN": {
            'default': 'false',
            'description': "description to be added",
        },
        "SET_TRAFFIC_SLEEP": {
            'default': '0',
            'description': "only for endurance, since pmcounter is set to 5 minutes by default",
        },
        "ASSERT_ONLY_SIB_ON_ACTIVE_CELLS": {
            'default': 'false',
            'description': "TC will only assert SIB on active cells\nsee `TC_active_cells`",
        },
        "ASSERT_ONLY_AP_CELL_ON_ACTIVE_CELLS": {
            'default': 'false',
            'description': "TC will only assert AP Cell On Air on active cells\nsee `TC_active_cells 111`",
        },
        "ENABLE_TS_TEARDOWN": {
            'default': 'true',
            'description': "disable testsuite teardown",
        },
        "ENABLE_TC_TEARDOWN": {
            'default': 'true',
            'description': "disable testcase teardown",
        },
        "HALT_EXECUTION_ON_AIR": {
            'default': 'false',
            'description': "stops script execution when TL reach on Air",
        },
        "TC_DISABLE_TAGS": {
            'default': 'false',
            'description': "deprecated",
        }
    },

    'Logging Manipulation': {
        "ENABLE_PM_COUNTER": {
            'default': 'true',
            'description': "[true, false]",
        },
        "ENABLE_SYSLOG": {
            'default': 'true',
            'description': "[true, false]",
        },
        "ENABLE_SNAPSHOT": {
            'default': 'true',
            'description': "[true, false]",
        },
        "ENABLE_LOG_DCAP": {
            'default': 'false',
            'description': "[true, false]",
        },
        "ENABLE_LOG_TCPDUMP_ALL": {
            'default': 'false',
            'description': "[true, false]",
        },
        "ENABLE_LOG_TCPDUMP_ON_AIR": {
            'default': 'false',
            'description': "[true, false]",
        },
        "ENABLE_LOG_TCPDUMP_COMMON_LOG": {
            'default': 'false',
            'description': "[true, false]",
        },
        "ENABLE_LOG_TCPDUMP_TRAFFIC": {
            'default': 'false',
            'description': "[true, false]",
        },
        "CFG_LOG_TCPDUMP_TESTPC": {
            'default': '-i eth3 -i eth4',
            'description': """we usually use `-i any sctp or icmp`, `-i any`
  - `-i eth3` : for backhaul
  - `-i eth4` : for wts
  - `-i eth3 -i eth4` : for both backhaul and wts
  - `-i any` : for overall traffic""",
        },
        "CFG_LOG_TCPDUMP_GNB": {
            'default': '-i any sctp or icmp',
            'description': "we usually use `-i any sctp or icmp`, `-i any`",
        },
        "ENABLE_LOG_QUICK_BIP": {
            'default': 'false',
            'description': "[true, false]",
        },
        "ENABLE_LOG_QUICK_BIP_TEST_SCRIPT": {
            'default': 'false',
            'description': "[true, false]",
        },
        "CFG_LOG_QUICK_BIP_DURATION": {
            'default': '5',
            'description': "seconds (0..*)",
        },
        "CFG_START_DCAP_CONTAINER": {
            'default': 'true',
            'description': "[true, false]",
        },
        "CFG_DCAP_SLEEP": {
            'default': '0',
            'description': "seconds (0..*)",
        },
        "ENABLE_SNAPSHOT_PCAP_EXTRACT": {
            'default': 'false',
            'description': "[true, false]",
        },
        "ENABLE_SNAPSHOT_CRASH_EXTRACT": {
            'default': 'true',
            'description': "[true, false]",
        },
        "ENABLE_SNAPSHOT_L2TTITRACE_EXTRACT": {
            'default': 'false',
            'description': "[true, false]",
        },
        "ENABLE_SNAPSHOT_L2TRACELO_EXTRACT": {
            'default': 'true',
            'description': "[true, false]",
        },
        "ENABLE_SNAPSHOT_RDCOUNTER_TO_CSV": {
            'default': ','.join([
                "AVG_DL_UE_SLOT_LIM_UE_POOL",
                "AVG_UL_UE_SLOT_LIM_UE_POOL",
                "AVG_DL_UE_SLOT_LIM_OLC",
                "AVG_UL_UE_SLOT_LIM_OLC",
                "AVG_DL_UE_SLOT_LIM_RRM",
                "AVG_UL_UE_SLOT_LIM_RRM",
                "AVG_DL_UE_SLOT_LIM_FDM_SKIP",
                "AVG_UL_UE_SLOT_LIM_FDM_SKIP",
                "AVG_UL_UE_SLOT_LIM_SHORT_CS1",
                "AVG_DL_UE_SLOT_LIM_SHORT_CS1",
            ]),
            'description': "null to disable or csv string",
        },
        "ENABLE_LOG_ARCHIVE": {
            'default': 'true',
            'description': "save to turandot, [true. false]",
        },
        "ENABLE_LOG_ARCHIVE_COMPRESSION": {
            'default': 'true',
            'description': "[true, false]",
        },
        "ENABLE_SOS_REPORT": {
            'default': 'onfail',
            'description': "[onfail, false, true]",
        },
        "ENABLE_TTI_TRACE_TEST_SCRIPT": {
            'default': 'false',
            'description': "[true, false]",
        },
        "ENABLE_TTI_TRACE_QUICK": {
            'default': 'false',
            'description': "[true, false]",
        },
        "CFG_TTI_TRACE_QUICK_DURATION": {
            'default': '3',
            'description': "seconds (0..*)",
        },
        "ENABLE_TTI_TRACE_CSV": {
            'default': 'false',
            'description': "[true, false]",
        },
        "ENABLE_TIMEMARKER": {
            'default': 'false',
            'description': "[true, false]",
        },
        "ENABLE_L2PERF": {
            'default': 'false',
            'description': "[true, false]",
        },
        "CFG_L2PERF_LXC": {
            'default': 'null',
            'description': r"""[VRFULMPERF-77]\n
  ex. `CFG_L2PERF_LXC:0x1730`, for multi lxc seperated the values with %  \n
  ex. `CFG_L2PERF_LXC:0x1518%0x151A`  \n
  > script does not execute if null""",
        },
        "CFG_L2PERF_CPU": {
            'default': 'null',
            'description': """[VRFULMPERF-77]  \n
  The CPU type. Currently supported values: sm6-snowfish, sm7-marlin. Default: null  \n
  > script does not execute if null""",
        },
        "ENABLE_RESOUCE_USAGE": {
            'default': 'true',
            'description': "[true, false]",
        },
        "ENABLE_RESOUCE_USAGE_VERIFY": {
            'default': 'false',
            'description': "[true, false]",
        },
        "CFG_RESOUCE_USAGE_EXCLUDE": {
            'default': '//l2loPoolId',
            'description': "comma separated",
        },
        "ENABLE_EMPERF_default": {
            'default': 'null',
            'description': """ex.: 0x1730,0x1731,0x1732,0x1733  \n
  > script does not execute if null""",
        },
        "ENABLE_LXC_gnb_top_default": {
            'default': 'null',
            'description': """ex.: 0x1734,0x1735  \n
  > script does not execute if null""",
        },
        "ENABLE_FLAME_GRAPH_gnb_default": {
            'default': 'null',
            'description': """ex.: 0x1734,0x1735  \n
  > script does not execute if null""",
        },
        "ENABLE_LTEPAT": {
            'default': 'true',
            'description': """[true, false]  \n
  Soon to be deprecated, it needs manual installation on the testline now  \n
  added workaround to download from local server as fallback""",
        },
        "ENABLE_NETCAT": {
            'default': 'false',
            'description': "[true, false]",
        },
        "ENABLE_TSHARK": {
            'default': 'false',
            'description': "[true, false]",
        },
        "ENABLE_DB_CONSOLE_OUTPUT": {
            'default': 'true',
            'description': "[true, false]",
        },
        "ENABLE_BEARER_STATS_COLLECTION": {
            'default': 'false',
            'description': "[true, false]",
        },
        "CFG_EMPERF_TOLERANCE": {
            'default': '1',
            'description': "float : { 0 .. 1}",
        },
        "CFG_KPI_TOLERANCE": {
            'default': 'null',
            'description': "{ 0 .. 1 } , null = disable, 1 = ignore",
        },
        "CFG_PMCOUNTERS_TOLERANCE": {
            'default': 'null',
            'description': "{ 0 .. 1 } , null = disable, 1 = ignore",
        },
        "CFG_DELAY_SNAPSHOT_CAPTURE": {
            'default': '0',
            'description': "seconds (0..*)",
        },
        "ENABLE_PERFSHOT": {
            'default': 'false',
            'description': "[true, false]",
        },
        "CFG_PERFSHOT_ARG": {
            'default': '--pet',
            'description': "[--pet, --all]",
        },
        "CFG_PERFSHOT_HW": {
            'default': '1:0',
            'description': "comma separated if multiple, `smod` if system module",
        },
        "ENABLE_SYSLOG_PARSER": {
            'default': 'true',
            'description': """[true, false]  \n
  > It takes huge disk space if enabled!""",
        },
        "CFG_BIP_TRF_GNB_DURATION": {
            'default': 'null',
            'description': """seconds (0..*)  \n
  > script does not execute if null""",
        },
        "CFG_BIP_CELLSETUP_GNB_DURATION": {
            'default': 'null',
            'description': """seconds (0..*)  \n
  > script does not execute if null""",
        },
        "CFG_BIP_CELLSETUP_AP_DURATION": {
            'default': 'null',
            'description': """seconds (0..*)  \n
  > script does not execute if null""",
        }
    },

    'Debugging': {
        "ENABLE_MARVIN": {
            'default': 'false',
            'description': "[true, false]",
        },
        "CFG_MARVIN_ID_MODE": {
            'default': 'mrbts_only',
            'description': "[mrbts_only, mrbts_nrbts]",
        },
        "CFG_MARVIN_ID_TYPE": {
            'default': 'ipaddr',
            'description': "[ipaddr, hostname]",
        },
        "CFG_MARVIN_ONLY_TEST_RUN": {
            'default': 'false',
            'description': "[true, false]",
        },
        "CFG_MARVIN_FETCH_SNAPSHOT": {
            'default': 'true',
            'description': """[true, false]  \n
  If True, fetches the snapshot from Marvin before stopping it.""",
        },
        "CFG_MARVIN_WAIT_AFTER_RUN": {
            'default': 'true',
            'description': """[true, false]  \n
  If True, waits for marvin analysis to complete after the test run to prevent overlaps.""",
        },
        "CFG_MARVIN_ADAPTER_LIST": {
            'default': None,
            'description': "no documentation available",
        },
        "CFG_MARVIN_ORGANIZATION": {
            'default': 'VRF_ULM_5',
            'description': "organization to send to Marvin",
        },
        "CFG_MARVIN_SIDE": {
            'default': 'prod',
            'description': """[dev, prod]"\n
  > dev side needs a separate firewall rule to allow access to Marvin server""",
        },
        "CFG_MARVIN_FOLDER": {
            'default': '/home/ute/DEVELOPMENT/marvin',
            'description': "directory to save Marvin",
        },
        "CFG_MARVIN_CT": {
            'default': '',
            'description': """Templates for Marvin.  \n
  If not set, it uses the default common templates from the library""",
        },
        "ENABLE_CONSOLE_OUTPUT": {
            'default': 'false',
            'description': "[true, false]",
        },
        "ENABLE_SCF_CHANGE_CONSOLE_OUTPUT": {
            'default': 'true',
            'description': "[true, false]",
        },
        "ENABLE_SRS_INFO": {
            'default': 'false',
            'description': "[true, false]",
        },
        "ENABLE_EGATE_ERROR_CHECK": {
            'default': 'true',
            'description': "[true, false]",
        },
        "ENABLE_SWCONFIG_CONSOLE_OUTPUT": {
            'default': 'false',
            'description': "[true, false]",
        },
        "ENABLE_ROBOT_VARIABLES_LOGGING": {
            'default': 'true',
            'description': "[true, false]",
        },
        "ENABLE_CELL_STATS": {
            'default': 'false',
            'description': "> needs fixing",
        },
        "DISABLE_EVENTS_ON_TELNET_SESSION": {
            'default': 'null',
            'description': "do not  set to true, unless special requirements!",
        },
        "ENABLE_CPU_USAGE": {
            'default': '95',
            'description': "percent (0 .. 100), raise a warning if CPU usage is above the value",
        },
        "ENABLE_GNB_ALARM_CHECK": {
            'default': 'true',
            'description': "[true, false]",
        },
        "CFG_EXCLUDE_ACTIVE_ALARMS": {
            'default': 'faultId:4655 faultId:4654 faultId:61652 faultId:61524',
            'description': """space-separated key:value filters for alarms to exclude from active alarm check,  \n
  - faultId:4655 Service account root access is enabled  \n
  - faultId:4654 Ethernet port security is disabled  \n
  - faultId:61652 R&D Service Port enabled  \n
  - faultId:61524 SSH enabled""",
        }
    },

    'Reporting to Tools': {
        "ENABLE_ONLINE_REPORTING": {
            'default': 'false',
            'description': "[true, false]",
        },
        "ONLINE_REPORTING_DEBUGGING": {
            'default': 'no',
            'description': "[yes, no]",
        },
        "REPORT_TO_GRAFANA": {
            'default': 'false',
            'description': "[true, false]",
        },
        "GRAFANA_DATABASE": {
            'default': 'db_L2_ET_PGO_KPI',
            'description': "[db_AP_PET_target, db_L2_ET_PGO_KPI]",
        },
        "ENABLE_REPORT_TO_DB": {
            'default': 'true',
            'description': "[true, false]",
        },
        "DB_SQLITE3_DATABASE": {
            'default': '/mnt/etlogs/logs/performance/02_database/performance.sqlite3',
            'description': "path to the performance data base",
        }
    },

    'Testline Setup': {
        "ENABLE_RESTORE_SCF_ON_TC_TEARDOWN": {
            'default': 'false',
            'description': "[true, false]",
        },
        "ENABLE_RESTORE_SCF_ON_SUITE_TEARDOWN": {
            'default': 'true',
            'description': "[true, false]",
        },
        "ENABLE_SWCONFIG_REVERT": {
            'default': 'true',
            'description': "[true, false]",
        },
        "ENABLE_ACT_BSR": {
            'default': 'null',
            'description': """[auto, str : <bsr_package_name.zip> ]  \n
  e.x. `BSR_AQQL_6_H3H3_ALN60_ARP60_P00_COVERAGE_00444_00002.zip`  \n
  > script does not execute if null""",
        },
    },
    'Database': {
        "DB_TCID_FILTER_TCFLAG_NAME": {
            'default': 'null',
            'description': "compare current testcase to a specific named filter",
        },
        "DB_TCID_FILTER_TCFLAG_VALUE": {
            'default': 'null',
            'description': "compare current testcase to a specific value filter",
        },
        "DB_TCID_FILTER": {
            'default': 'null',
            'description': "compare current testcase to a specific testcase execution ID",
        },
    },
}


SCF_DICTIONARY = {    # accessed externally to generate docs
    'SCF Full features': {
        "SCF_ENABLE_COMMISSIONING": {
            'default': 'true',
            'description': "[true, false]",
        },
        "SCF_skip_parameter_relation_errors": {
            'default': 'False',
            'description': "[true, false]",
        },
        "SCF_ENABLE_BEAMFORMING": {
            'default': 'false',
            'description': "[true, false]",
        },
        "SCF_ENABLE_CB008246": {
            'default': 'false',
            'description': "[true, false]",
        },
        "SCF_ENABLE_CB008246_STATIC": {
            'default': 'false',
            'description': "[true, false]",
        },
        "SCF_ENABLE_BB_POOLING": {
            'default': 'false',
            'description': "[true, false]",
        },
        "SCF_CONFIGURE_PDCCH_RESOURCE_INCREASE": {
            'default': 'false',
            'description': "[true, false]",
        },
        "SCF_CONFIGURE_CA_RAMP": {
            'default': 'false',
            'description': "[true, false]",
        },
        "SCF_CONFIGURE_SRS": {
            'default': 'false',
            'description': "[true, false]",
        },
        "SCF_VENDOR_DEFAULT_PERF_VALUES": {
            'default': 'true',
            'description': """[true, false]  \n
  miNrL2OvldRlcMac : 5min, miNrL2PsOvldNrCellGrp : 5min""",
        },
    },
    'SCF PCMD': {
        "SCF_CONFIGURE_PCMD": {
            'default': 'false',
            'description': "[true, false]",
        },
        "SCF_SET_CELL_TRACEALL": {
            'default': ','.join([
                'traceE1Setting',
                'traceF1Setting',
                'traceNGAPSetting',
                'traceNRRRCSetting',
                'traceX2Setting',
                'traceXNSetting'
            ]),
            'description': "comma separated",
        },
    },
    'SCF single values': {
        "SCF_SET_VAR_dist_pname": {
            'doc_only': True,
            'default': 'null',
            'description': """set `pname` accordingly,  \n
  ex. **-v SCF_SET_VAR_NRCELL_`actUlSrsBm`:true** will set `all NRCELL` values to for actUlSrsBm to true""",
        },
        "SCF_SET_VAR_dist_i#_pname": {
            'doc_only': True,
            'default': 'null',
            'description': """set `pname` and i`#` accordingly,  \n
  set index to set only specific target  \n
  ex. **-v SCF_SET_VAR_NRCELL_`i3`_actUlSrsBm:true** will set `NRCELL-3` values to for actUlSrsBm to true""",
        },
        "SCF_SET_LIST_dist_listname_pname": {
            'doc_only': True,
            'default': 'null',
            'description': """ex. -v SCF_SET_LIST_NRCELL_`srsForBeamMgmt`_`srsUePeriodicity`:`slot5`  \n
  will set **All NRCELLs** /srsForBeamMgmt/srsUePeriodicity to `slots5`""",
        },
        "SCF_SET_LIST_dist_i#_listname_pname": {
            'doc_only': True,
            'default': 'null',
            'description': """set index to set only specific target,  \n
  ex. **-v SCF_SET_LIST_NRCELL_`i3`_srsForBeamMgmt_srsUePeriodicity:`slot5`**  \n
  will set `NRCELL-3`/srsForBeamMgmt/srsUePeriodicity to `slots5`""",
        },
        "SCF_SET_VAR_dist_pname2": {
            'doc_only': True,
            'default': '\\__remove__',
            'description': """remove `pname` accordingly,  \n
  ex. **-v SCF_SET_VAR_NRDRB_`actLostPduFastRetx`:\\__remove__  \n
  will remove `all NRDRB` values to for actLostPduFastRetx""",
        },
        "SCF_SET_LIST_dist_listname_pname2": {
            'doc_only': True,
            'default': '\\__remove__',
            'description': """ex. -v SCF_SET_LIST_NRCELL_`srsForBeamMgmt`_`srsUePeriodicity`:`\\__remove__`  \n
  will remove **All NRCELLs** /srsForBeamMgmt/srsUePeriodicity""",
        },
        "SCF_SET_VENDOR_dist_pname": {
            'doc_only': True,
            'default': 'null',
            'description': """set `pname` accordingly,  \n
  ex. -v SCF_SET_VENDOR_NRCELL_`CsReductionFactorOlc`:60  \n
  will set **All NRCELLs** values to for CsReductionFactorOlc to 60  \n
  To check if modification is correct: go to Element Manager > Info Model Viewer  \n
  - `/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-1/SCF-1/MRBTS_A-1/NRBTS_A-1`""",
        },
        "SCF_SET_VENDOR_dist_i#_pname": {
            'doc_only': True,
            'default': 'null',
            'description': """set index to set only specific target,  \n
  ex. -v SCF_SET_VENDOR_NRCELL_`i50`_CsReductionFactorOlc:60  \n
  will set nrcell CsReductionFactorOlc `with values 50` to 60  \n
  To check if modification is correct: go to Element Manager > Info Model Viewer  \n
  - `/MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1/NP-1/SCF-1/MRBTS_A-1/NRBTS_A-1`""",
        },
        "SCF_SET_BBMODBOARDCONFIGTYPE": {
            'default': 'null',
            'description': """ex. `LTEFDD_NRTDD`  \n
  > script does not execute if null""",
        },
        "SCF_SET_VAR_NRBTS_actFlowControlLoadBalance": {
            'default': 'null',
            'description': """[true, false]  \n
  > script does not execute if null""",

        },
    },
    'PM Counters': {
        "SCF_SET_reportingIntervalPm": {
            'default': '5min',
            'description': "[5min, 15min, 30min]",
        },
        "PM_COUNTER_INTERVAL": {
            'default': '300',
            'description': "[300, 900, 1800]",
        },
        "SCF_SET_VAR_NRPMRNL_miNrPDCPCell": {
            'default': '5min',
            'description': "[5min, 15min, 30min]",
        },
        "SCF_SET_VAR_NRPMRNL_miNrPdcpLatNrpmqap": {
            'default': '5min',
            'description': "[5min, 15min, 30min]",
        },
        "SCF_SET_VAR_NRPMRNL_miNrCellUtilization": {
            'default': '5min',
            'description': "[5min, 15min, 30min]",
        },
        "SCF_SET_VAR_NRPMRNL_miNrDlHarqLowSEMCS": {
            'default': '5min',
            'description': "[5min, 15min, 30min]",
        },
        "SCF_SET_VAR_NRPMRNL_miNrUlHarqLowSEMCS": {
            'default': '5min',
            'description': "[5min, 15min, 30min]",
        },
        "SCF_SET_VAR_NRPMRNL_miNrRSUP": {
            'default': '5min',
            'description': "[5min, 15min, 30min]",
        },
    },
    'Vendor File': {
        "SCF_SET_VENDOR_csReductionFactorOlc": {
            'default': 'null',
            'description': " _script does not execute if null_",
        },
    },
    'GNB SWCONFIG': {
        "RDCFG_0xFFF123": {
            'doc_only': True,
            'default': 'null',
            'description': """add / modify gnb swconfig ex. `-v RDCFG_0x58057A:4`""",
        },
        "RDCFG_ACT_ADAPTIVE_SCHEDULER_BUDGET": {
            'default': 'false',
            'description': "[true, false]",
        },
        "RDCFG_CsReductionFactorOlc": {
            'default': 'null',
            'description': " _script does not execute if null_",
        },
        "RDCFG_PM_INTERVAL": {
            'default': 'null',
            'description': "description to be added",
        },
        "RDCFG_admin_mode_enable": {
            'default': 'null',
            'description': "description to be added",
        },
        "RDCFG_EnableUserDeleteInternalBundleMessage": {
            'default': 'null',
            'description': "description to be added",
        },
        "RDCFG_debug_level": {
            'default': 'null',
            'description': """set all debug params,  \n
  see <https://gitlabe2.ext.net.nokia.com/nvaldez/docman/-/blob/main/docs/manual.md#enable-debug-logs---confluence>""",
        },
    },
    'Airphone AP SWCONFIG': {
        "RDCFG_AP_0xFFF123": {
            'doc_only': True,
            'default': 'null',
            'description': """add / modify ap swconfig ex. `-v RDCFG_0xFFF123:1`""",
        },
        "RDCFG_AP_fix_for_peak_capacity": {
            'default': '2',
            'description': "description to be added",
        },
        "RDCFG_AP_debug_level": {
            'default': 'null',
            'description': "description to be added",
        },
    }}


TESTCASE_DICTIONARY = {    # accessed externally to generate docs
    'flags': {
        "bearer_stats_collection": {"default": "true"},
    },
    'lua_args': {
        "lua": {"default": None},
        "configuration_entry": {"default": 'run_configuration()'},
        "entry": {"default": "none"},
        "entry_auto_args": {"default": "false"},
        "entry_args": {"default": "null"},
        "custom_lua_file": {"default": None},

    },
    'wts_args': {
        'uec_list': {
            "default": "1,2,3,4,5",
            "description": "comma separated UEC id as defined in egate configuration"
        }
    },
    'trf_args': {
        "trf_direction":  {"default": "both"},
        "ul_datarate":  {"default": "0"},
        "dl_datarate":  {"default": "0"},
        "rate":  {"default": "mbps"},
        "trf_protocol":  {"default": "udp"},  # udp|tcp|icmp
        "pdu_id":  {"default": "1"},
        "qfi_id":  {"default": "1"},
        "trf_id":  {"default": "1"},
        "packetsize":  {"default": "1350"},
        "period_ms":  {"default": "none"},
        "traffic_sleep":  {"default": None},

    },
    "cell_args": {
        # comma separated or 'all' e.x. 1,3
        "active_cells": {"default": "all"},
        "inactive_cells": {"default": []},
        "cell_max_ue": {"default": "null"},
        "cell_ul_throughput": {"default": "null"},
        "cell_dl_throughput": {"default": "null"},
        "cell_trf_dir": {"default": "null"},
        "num_cells_online": {"default": None},
    },
    'ue_args': {
        "start_ue":  {"default": "1"},
        "end_ue":  {"default": "auto"},
        "ue_per_cell":  {"default": "100"},
        "start_cell":  {"default": "1"},
        "end_cell":  {"default": "1"},
        "ue_nr_cap":  {"default": "UE_CAP"},
        "registration_type":  {"default": "none"},
        "deregister_type":  {"default": "switch_off"},
        "deregister_by":  {"default": "ue"},
        "deregister_range_split":  {"default": 'all'},
        "deregister_delay":  {"default": '0'},
        "deregister_retry":  {"default": 'false'},
        "expect_ue_count":  {"default": "null"},
    },
    'db_args': {
        "kpi_insert_db": {"default": "true"},
        "pmc_insert_db": {"default": "true"},
        "cellstats_insert_db": {"default": "true"},
    },
    'verification_args': {
        "verify":  {"default": "true"},
        "timeout":  {"default": "1200"},
        "pass_regexp":  {"default": None},
        "fail_regexp":  {"default": r"(Command .* is disabled currently|CHANGE STATE: CONFIGURED)"},
        "kpi_tolerance":  {"default": ''},
        "tolerance":  {"default": "0.1"},     # traffic tput
        "duplex":  {"default": ''},
    },
    'calculation_overwrite': {
        # if there are already attached UEs to the cell, increament this value
        "ue_count_in_cell": {"default": "null"},
        "cell_and_ue_mapping": {"default": "null"},
    },
    'logging': {
        "tti_trace_duration": {"default": '3'},
        "stop_log_collection": {"default": "true"},
        "delay_snapshot_capture": {"default": ''},
    },
    'flow_args': {
        "label":  {"default": "default"},
        "pmc_verification_sublabel":  {"default": "traffic"},
        "subfolder":  {"default": ""},
        "setup_on_air":  {"default": "true"},
        "workspace":  {"default": "(auto)"},
        "loop_test_count":  {"default": "1"},
    },
    'multivm': {
        'egate_script_delay_per_vm': {
            "default": "0s",
            "description": """[VRFULMPERF-21]  \n
  Add Option for MultiVM scripts to wait before executing the next vm"""
        },
        'script_files': {
            "default": "0,no_operations,no_operations",
            "description": """is a 2D List (test_pc_index, script, entry) passed as an argument,  \n
  - use semi colon to separate different VM and script  \n
  if passed as a string from Jenkins the format is  \n
  `1,script1,entry;2,script2,entry;3,script3,entry` where script1 will run on VM0, script2 on VM1 and script3 on VM2"""
        },
        'wts_manager_args': {
            "default": "1,/opt/iphy/latest/basic_attach.json,--start%1%--end%40",
            "description": """is a 2D List (test_pc_index, json, args) passed as an argument,  \n
  - use semi colon to separate different VM and script  \n
  - arg needs a % sign as spacer  \n
  if passed as a string from Jenkins the format is  \n
  `1,json1,--arg1%--arg2;2,json2,--arg1%--arg2;3,json2,--arg1%--arg2`  \n
  where json1 will run on VM0, json2 on VM1 and json3 on VM2"""
        }
    }
}


RL_PATH = {    # RF Only for generating sorted remote paths
    "f1_setup": '010_f1_setup',
    "on_air": '020_on_air',
    "common_log_setup": '030_common_log_setup',
    "common_log_after_attach": '040_common_log_after_attach',
    "traffic_logs": '050_traffic_logs',
    "common_test_teardown": '070_common_test_teardown',
    "testcase_teardown": '080_testcase_teardown',
    "gnb_alarms": '100_gnb_alarms',
    "resources_usage": '110_resources_usage',
    "grafana": '120_grafana',
    "final_config": '800_final_config',
    "jenkins_debug": '900_jenkins_debug',
}


def generate_robot_variable(arg: dict) -> dict:
    testparam = {}
    for pdict in arg.values():
        for key, value in pdict.items():
            if not value.pop('doc_only', False):
                testparam.update({
                    key: value['default']
                })
    return testparam


TP = generate_robot_variable(COMMON_DICTIONARY)
TSGNBP = generate_robot_variable(SCF_DICTIONARY)
