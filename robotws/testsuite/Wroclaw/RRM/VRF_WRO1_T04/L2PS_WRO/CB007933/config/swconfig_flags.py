# https://bts.inside.nsn.com/twiki/bin/view/LTEeNB/EnablingDebugLogs
ENABLE_CELLC_DEBUG_LOGS = [
    "0xF000E = 1 # TCellcRadDebugLogEnabledGlobal",
    "0xF000F = 1 # TCellcRadDebugLogEnabledCellc",
    "0xF0010 = 1 # TCellcRadDebugLogEnabledCommon",
    "0xF0011 = 1 # TCellcRadDebugLogEnabledCommonCodec",
]
DISABLE_TCellCRADCOMMON = "0xF0010 = 0 # TCellcRadDebugLogEnabledCommon"

ENABLE_UEC_DEBUG_LOGS = [
    "0x130020 = 1 # TUecRadDebugLogEnabledGlobal",
    "0x130021 = 1 # TUecRadDebugLogEnabledUec",
    "0x13001E = 1 # TUecRadDebugLogEnabledCommon",
    "0x13001F = 1 # TUecRadDebugLogEnabledCommonCodec",
]

ENABLE_ENBC_DEBUG_LOGS = [
    "0x110001 = 1 # TEnbcRadDebugLogEnabledGlobal",
    "0x110002 = 1 # TEnbcRadDebugLogEnabledEnbc",
    "0x110003 = 1 # TEnbcRadDebugLogEnabledCommon",
    "0x110004 = 1 # TEnbcRadDebugLogEnabledCommonCodec",
]

ENABLE_RROM_DEBUG_LOGS = [
    "0x120004 = 1 # TRromRadDebugLogEnabledGlobal",
    "0x120005 = 1 # TRromRadDebugLogEnabledRrom",
    "0x120006 = 1 # TRromRadDebugLogEnabledCommon",
]

ENABLE_TUPC_DEBUG_LOGS = [
    "0x00150001 = 1 # TTupcRadDebugLogEnabledGlobal",
    "0x00150002 = 1 # TTupcRadDebugLogEnabledTupc",
    "0x00150004 = 1 # TTupcRadDebugLogEnabledCommon",
    "0x00150003 = 1 # TTupcRadDebugLogEnabledCommonCodec",
]

ENABLE_MCEC_DEBUG_LOGS = [
    "0x380001 = 1 # TMcecRadDebugLogEnabledGlobal",
    "0x380002 = 1 # TMcecRadDebugLogEnabledMcec",
    "0x380003 = 1 # TMcecRadDebugLogEnabledCommon",
    "0x380011 = 1 # TMcecRadDebugLogEnabledCommonCodec",
]

ENABLE_MAC_DATA_FID_MAC_COMMON_2_LOG_LEVEL = "0xA0165 = 0xFFFFFFFF # TRdLogLevelMacDataFidMacCommon2"

SET_CCS_SYSLOG_IO_LEVEL_DBG = ["0x10040 = 1 # ERadCcs_AaSysLogOutputLevel", "0x1003F = 1 # ERadCcs_AaSysLogInputLevel"]

SET_CCS_SYSLOG_IO_LEVEL = ["0x10040 = 2 # ERadCcs_AaSysLogOutputLevel", "0x1003F = 2 # ERadCcs_AaSysLogInputLevel"]

SET_CCS_SYSLOG_IO_LEVEL_WRN = ["0x10040 = 3 # ERadCcs_AaSysLogOutputLevel", "0x1003F = 3 # ERadCcs_AaSysLogInputLevel"]

SET_CCS_SYSLOG_O_MODE = ["0x10041 = 5 # ERadCcs_AaSysLogOutputMode 5 = local "]

# https://bts.inside.nsn.com/twiki/bin/view/Main/TatAasyslogConfiguration

ENABLE_CPLANE_DEBUG_LOGS = (
    SET_CCS_SYSLOG_IO_LEVEL_DBG
    + ENABLE_CELLC_DEBUG_LOGS
    + ENABLE_UEC_DEBUG_LOGS
    + ENABLE_ENBC_DEBUG_LOGS
    + ENABLE_RROM_DEBUG_LOGS
    + ENABLE_TUPC_DEBUG_LOGS
)

DISABLE_CELLC_DEBUG_LOGS = [
    "0xF000E = 0 # TCellcRadDebugLogEnabledGlobal",
    "0xF000F = 0 # TCellcRadDebugLogEnabledCellc",
    "0xF0010 = 0 # TCellcRadDebugLogEnabledCommon",
    "0xF0011 = 0 # TCellcRadDebugLogEnabledCommonCodec",
]

DISABLE_UEC_DEBUG_LOGS = [
    "0x130020 = 0 # TUecRadDebugLogEnabledGlobal",
    "0x130021 = 0 # TUecRadDebugLogEnabledUec",
    "0x13001E = 0 # TUecRadDebugLogEnabledCommon",
    "0x13001F = 0 # TUecRadDebugLogEnabledCommonCodec",
]

DISABLE_ENBC_DEBUG_LOGS = [
    "0x110001 = 0 # TEnbcRadDebugLogEnabledGlobal",
    "0x110002 = 0 # TEnbcRadDebugLogEnabledEnbc",
    "0x110003 = 0 # TEnbcRadDebugLogEnabledCommon",
    "0x110004 = 0 # TEnbcRadDebugLogEnabledCommonCodec",
]

DISABLE_RROM_DEBUG_LOGS = [
    "0x120004 = 0 # TRromRadDebugLogEnabledGlobal",
    "0x120005 = 0 # TRromRadDebugLogEnabledRrom",
    "0x120006 = 0 # TRromRadDebugLogEnabledCommon",
]

DISABLE_MCEC_DEBUG_LOGS = [
    "0x380001 = 0 # TMcecRadDebugLogEnabledGlobal",
    "0x380002 = 0 # TMcecRadDebugLogEnabledMcec",
    "0x380003 = 0 # TMcecRadDebugLogEnabledCommon",
    "0x380011 = 0 # TMcecRadDebugLogEnabledCommonCodec",
]

DISABLE_HWAPI_DEBUG_LOGS = [
    "0x210000 = 0 # BM debug prints",
    "0x20041 = 0 # HWAPI startup service debug print",
    "0x20040 = 0 # HWAPI SRIO service debug print",
    "0x20001 = 0 # Autodetection Task debug print",
    "0x20063 = 0 # HWAPI Autodetection Task additional info print",
    "0x20070 = 0 # Autodetection hotplug event debug prints",
    "0x20003 = 0 # HWAPI SW DL Task debug print",
    "0x2006B = 0 # HWAPI TIME service debug prints",
    "0x20068 = 0 # HWAGNSS service debug prints",
    "0x2008F = 0 # HWAPI Ip Service debug prints",
    "0x20051 = 0 # HWAPI Routing Service debug print",
    "0x20008 = 0 # HWAPI SUM Service task print",
    "312 = 0 # SPMAG debug prints",
    "9 = 0 # BTSOM ADET debug prints",
]

DISABLE_TUPC_DEBUG_LOGS = [
    "0x00150001 = 0 # TTupcRadDebugLogEnabledGlobal",
    "0x00150002 = 0 # TTupcRadDebugLogEnabledTupc",
    "0x00150004 = 0 # TTupcRadDebugLogEnabledCommon",
    "0x00150003 = 0 # TTupcRadDebugLogEnabledCommonCodec",
]

DISABLE_CPLANE_DEBUG_LOGS = (
    DISABLE_CELLC_DEBUG_LOGS + DISABLE_UEC_DEBUG_LOGS + DISABLE_ENBC_DEBUG_LOGS + DISABLE_RROM_DEBUG_LOGS
)

WRITE_PM_COUNTERS_EVERY_MINUTE = "0x340000 = 15 # ERadLteBSTAT_PmIntervalShrinkRatio, PM counter interval"
WRITE_PM_COUNTERS_EVERY_THREE_MINUTES = "0x340000 = 5 # ERadLteBSTAT_PmIntervalShrinkRatio, PM counter interval"
WRITE_PM_COUNTERS_EVERY_FIVE_MINUTES = "0x340000 = 3 # ERadLteBSTAT_PmIntervalShrinkRatio, PM counter interval"

SKIP_HWF_CHECKING = "0x190030 = 0 # disable HWF"

REDUCE_TOBSERVE_VALUE_FOR_ANR_REMOVAL = (
    "0x0012000B = 1 " "# Set tObserve value (timer for automatic X2 link removal procedure) " "to 5 minutes"
)

REDUCE_S1_RECONNECTION_TIME = (
    "0x15001B = 1 " "# TTupcRadSctpWaitTimeInitSeqRetryOverride, TUPC waiting time for S1 reconnect"
)

DISABLE_LINK_REESTABLISHMENT_TIMER_RANDOMIZATION = "0x15001E = 1"

ENABLE_SIP_MONITORING = "0x410000 = 1 # TTupRadEnableSipMonitoring"

ENABLE_TUPU_GTP_MONITORING = "0x410001 = 28 # Enable_TUPu_GTP_message_monitoring (28 bytes payload)"

DESCRIPTORS_DL_OVERLOAD_PROTECTION_DISABLED_THRESHOLD1 = [
    "0xE0010 = 100 # RDPARAM_TTUP_DL_OLP_DESCRIPTORS_THRESHOLD1",
    "0xE0011 = 100 # RDPARAM_TTUP_DL_OLP_DESCRIPTORS_THRESHOLD2",
    "0xE0012 = 100 # RDPARAM_TTUP_DL_OLP_DESCRIPTORS_THRESHOLD3",
]

DESCRIPTORS_DL_OVERLOAD_PROTECTION_ENABLED_THRESHOLD1 = [
    "0xE0010 = 0 # RDPARAM_TTUP_DL_OLP_DESCRIPTORS_THRESHOLD1",
    "0xE0011 = 1 # RDPARAM_TTUP_DL_OLP_DESCRIPTORS_THRESHOLD2",
    "0xE0012 = 100 # RDPARAM_TTUP_DL_OLP_DESCRIPTORS_THRESHOLD3",
]

DESCRIPTORS_DL_OVERLOAD_PROTECTION_ENABLED_THRESHOLD2 = [
    "0xE0010 = 0 # RDPARAM_TTUP_DL_OLP_DESCRIPTORS_THRESHOLD1",
    "0xE0011 = 0 # RDPARAM_TTUP_DL_OLP_DESCRIPTORS_THRESHOLD2",
    "0xE0012 = 100 # RDPARAM_TTUP_DL_OLP_DESCRIPTORS_THRESHOLD3",
]

DESCRIPTORS_DL_OVERLOAD_PROTECTION_ENABLED_THRESHOLD3 = [
    "0xE0010 = 0 # RDPARAM_TTUP_DL_OLP_DESCRIPTORS_THRESHOLD1",
    "0xE0011 = 0 # RDPARAM_TTUP_DL_OLP_DESCRIPTORS_THRESHOLD2",
    "0xE0012 = 0 # RDPARAM_TTUP_DL_OLP_DESCRIPTORS_THRESHOLD3",
]

CPU_DL_OVERLOAD_PROTECTION_DISABLED_THRESHOLD1 = [
    "0xE0013 = 100 # RDPARAM_TTUP_DL_OLP_CPU_THRESHOLD1",
    "0xE0014 = 100 # RDPARAM_TTUP_DL_OLP_CPU_THRESHOLD2",
    "0xE0015 = 100 # RDPARAM_TTUP_DL_OLP_CPU_THRESHOLD3",
]

CPU_DL_OVERLOAD_PROTECTION_ENABLED_THRESHOLD1 = [
    "0xE0013 = 0 # RDPARAM_TTUP_DL_OLP_CPU_THRESHOLD1",
    "0xE0014 = 17 # RDPARAM_TTUP_DL_OLP_CPU_THRESHOLD2",
    "0xE0015 = 100 # RDPARAM_TTUP_DL_OLP_CPU_THRESHOLD3",
]

CPU_DL_OVERLOAD_PROTECTION_ENABLED_THRESHOLD2 = [
    "0xE0013 = 0 # RDPARAM_TTUP_DL_OLP_CPU_THRESHOLD1",
    "0xE0014 = 0 # RDPARAM_TTUP_DL_OLP_CPU_THRESHOLD2",
    "0xE0015 = 100 # RDPARAM_TTUP_DL_OLP_CPU_THRESHOLD3",
]

CPU_DL_OVERLOAD_PROTECTION_ENABLED_THRESHOLD3 = [
    "0xE0013 = 0 # RDPARAM_TTUP_DL_OLP_CPU_THRESHOLD1",
    "0xE0014 = 0 # RDPARAM_TTUP_DL_OLP_CPU_THRESHOLD2",
    "0xE0015 = 0 # RDPARAM_TTUP_DL_OLP_CPU_THRESHOLD3",
]

SET_CODEBOOK_SUBSET_RESTRICTION_8 = "0x000F0015 = 8  # RAD_SW_DOMAIN(ERadSwDomain_LteCellC,0x0015) "
SET_CODEBOOK_SUBSET_RESTRICTION_15 = "0x000F0015 = 15  # RAD_SW_DOMAIN(ERadSwDomain_LteCellC,0x0015) "

SET_ECQIQUALITYRESULT_TX_1 = "0x1E0148 = 0x80800000 "
SET_ECQIQUALITYRESULT_TX_2 = "0x1E0149 = 0x84000000 "
SET_CQI_UL_TRACES = "0x1E0149 = 0x84000040 "

REDUCE_IDLE_TIME_THRESHOLD_FOR_XRTT_ANR_TO_1_MINUTE = "0x12000B = 1 # TRromRadParamAutoNeighRemovalTimerPeriod"

L2_MAC_DATA_TUPU = ["0x1003F = 1 # MacDataDebugLogEnabled", "0x10040 = 1 # TupuDebugLogEnabled"]

MAC_PS_LTE3597 = ["0x1E0146 = 0x80008000", "0x1E0147 = 0x80008000"]

MAC_PS_LTE1092 = ["0x1E0148 = 0x80400000", "0x1E0149 = 0xA0000800"]

MAC_PS_LTE2582 = ["0x1E0148 = 0x80400803", "0x1E0146 = 0x80000080", "0x1E0149 = 0xA0000800"]

MAC_PS_LTE2445 = "0x1E0147 = 0x80000100"

MAC_PS_NB_IOT = "0x1E0146 = 0x80000010"
MAC_PS_SI_UE_PAGING = "0x1e0146 = 0x80080030"
MAC_PS_VIP_FOR_NB_IOT_SCHEDULING = ["0x1E0146 = 0x80000030", "0x1E0147 = 0x80000090", "0x1E0148 = 0x80000002"]

UL_OVLD_LBT4859 = ["0x0A179 = 100", "0x0A17A = 10"]  # seuil en % de cpu   &  duration of maxUe/tti reduction


MAX_NUM_RRC_EMCY = "0x0F0044 = 99    # TCellcRadCplanePoolMaxNumRrcEmergencyRatio"
MAX_NUM_RRC_EMCY_2 = "0x0F0044 = 2    # TCellcRadCplanePoolMaxNumRrcEmergencyRatio"
MAX_NUM_UE_CONTEXTS_50 = "0x12003A = 50    # TRromRadMaxNumOfUeContexts"
MAX_NUM_UE_CONTEXTS_100 = "0x12003A = 100    # TRromRadMaxNumOfUeContexts"

DISABLE_MAC_PS_FEATURE_TRACE = "0x1E0149 = 0"

ENABLE_PUCCH_DEBUG_LOGS = "0x1E0084 = 0x3 "

DISABLE_OUT_OF_SYNC = "0x00120001 = 1 "

ENABLE_BASE_BAND_POOLING_IN_FL17 = "0x42000A = 1"

ENABLE_UEC_PCMD_BUNDLING = "0x13001A = 1 # TUecRadPcmdRealTimeReportingEnabled"

PM_COUNTER_DEBUG = "0x340004 = 1"

REDUCE_AUTO_NEIGH_REMOVAL_PERIOD = "0x0012000B = 4"

DISTRIBUTED_ZUC_ENABLE_PACKET_SIZE_THRESHOLD = " 0xA00CA = 1465 "

ENABLE_NBIOT_MULTIPLE_COVERAGE_LEVELS = "0x00120080 = 1 # TRromRadActNbIotMultipleCoverageLevels"

ENABLE_CA_AND_MFBI_EXT_B = "0x1300A5 = 1    # CaAndMfbiInterworkingExtensionsPartBEnable"

ENABLE_LBT4777 = "0x420011 = 1    # EnableLBT4777"

CHANGE_DEFAULT_VERIZON_PLMN_IN_MAC = "0x1e007a = 244009     # ChangeDefaultVerizonPlmnInMac"

ADET_DBG = "9 = 1 # ENABLE SRIO LINK DEBUG LOGS"
DISABLE_ADET_DBG = "9 = 0 # DISABLE SRIO LINK DEBUG LOGS"

CCICORE_DBG = "0x470007 = 1 # enable CciCore logs"

SET_PR306146 = "0x1e0146 = 0x80000030 # SET_PR306146 "

WORKAROUND_FOR_NR_PDCP = "0x12008e = 1 # RromRadParamActNewRadioDualConnectivity"

DISABLE_LINK_ADAPTATION_FOR_NBIOT = "0x1e0103 = 0 # rdNBIoTLa"

BLOCK_SGNB_ADDITION = "0x001300BE = 1"

DISABLE_LTE2647 = "0x4F0031 = 0"

ENABLE_TCP_BOOSTING_DEBUG_LOGS = "0xA01BE = 65537 # Additional debug logs for TCP Service Differentiation"

ENABLE_MAC_TCP_BOOSTING_DEBUG_LOGS = ["0x1e0146 = 0x84000000", "0x1e0147 = 0x84000000"]

ULPHY_NPRACH = " 0x16000C = 1 #NPRACH snapshots RaD flag "

MAC_PS_LTE4053 = ["0x1e0147 = 0x80001000", "0x1e0148 = 0x80004000", "0x1e0149 = 0xA0000000"]

RSRP_LTE4053 = ["0x001300C7  = 1", "0x001300C8  = 60", "0x001300C9  = 60"]

SKIP_SGNB_ADDITION_AFTER_CAPABILITY_ENQUIRY = "0x1300C1 = 1 # UecRadSkipSgNBAdditionRequestAfterCapabilityEnquiry"

TRACE_LOM_MESSAGES = ["0x1002a = 1", "0x1002b = 0x37B0", "0x1002c =  0x382F", "0x1002f = 1"]

FID_5G_IWK_L2 = "0xa01c0 = 1 # enable L2 FID_5G_IWK "

DC_BUFFER_LIMIT_TO_0 = "0xa0199 = 0 # set dc buffer limit to 0 "

IWK_ENABLE_1B = ["0x410006 = 1 # L2_1b", "0x1300c6 = 1 # CPLANE_1b"]

MAX_DDDS_PERIOD = "0xa01aa = 0xFFFFFFFF # DDDS period "

SIBUPDATERATETHRESHOLD_DURATION = "0xf0086 = 60 # sibUpdateRateThresholdDuration"

ENABLE_NR_PDCP_OPTION_1B = "0x001300c6 = 1 #TUecRadEnableNrPdcpOption1BForDualConnectivity"

FORCE_LEGACY_5GBAND_DETECTION_IN_X2_SETUP_RESP = "0x00130060 = 1"

SPLIT_BEARER_VIA_LCID_CHANGE = "0x1300D0 = 1"
SPLIT_BEARER_VIA_LCID_CHANGE_OFF = "0x1300D0 = 0"

LCID_CHANGE_L2_OMMIT_WA = "0x130059 = 1"

ENABLE_NBIOT_COUNTER_DEBUG_LOGS = [
    "0xA0172 = 528613431 #ERadSwDomainLteMac_PmCounterIdFrom",
    "0xA0173 = 528613433 #ERadSwDomainLteMac_PmCounterIdTo",
]

ENABLE_DDDS_MAX_SKIP_TIME = "0xA0003 = 0x00012c #ERadSwDomainLteL2_DddsMaxSkipTime"

DISABLE_LOAD_BALANCING_FOR_DC_HO = "0xA0004 = 1 # Disable load balancing for DC ho "

ENABLE_OLD_UL_DELAY_VALUE = "0xd000b = 20"

DEBUG_LOGS_AAFILESICFTP = [
    "### Additional debug logs for investigating AaFileSicFtp problems",
    "0x10007 = 1 # ERadCcs_PrintAaFile",
    "0x10049 = 1 # ERadCcs_PrintAaFileSicFtp",
    "0x10003 = 1 # ERadCcs_PrintAaMem",
    "0x1000B = 1 # ERadCcs_PrintAaMemAdapter",
    "0x10000 = 1 # ERadCcs_PrintAaSysCom",
    "0x10039 = 1 # ERadCcs_PrintAaSysComControl",
    "0x10031 = 1 # ERadCcs_PrintAaSysComUser",
    "0x390000 = 1 # ERadRtHwApi_StartUpPrint",
]

DISABLE_AUTOMATIC_RECOVERY_RESET = [
    "### Disable automatic recovery reset",
    "0x200AF  = 3 # ERadHwapi_DisableResetServiceFunctions",
    "0x200DB  = 1 # ERadHwapi_PehDisableAutonomousReboot",
    "0x200DE  = 0 # ERadHwapi_PehKillRtInNrtCrash",
    "0x310001 = 0 # ERadLteFaReco_BtsResetCount",
    "0x310002 = 0 # ERadLteFaReco_BbuResetCount",
    "0x500001 = 0 # ERadLteFri_BtsResetCount",
    "0x500002 = 0 # ERadLteFri_BbuResetCount",
]

ORIGINAL_IPHY_SWCONFIG_FLAGS = [
    "#0x1A0020=1 #keeping test port open for IMViewer , aatrace client , LteBrowser etc",
    "#0x19000A=1 # enable SSH?",
    "#enable UDP logs from FCT",
    "0x1003F=1",
    "0x10040=1",
    "0x10041=5",
    "0x10042=0xC0A8C87E #ccs.service.aasyslog.udpaddress",
    "0x1007C=0 #Linux log listen -- set to 1 to dump LFS logs",
    "0x2006D=1 # IPHY CCS flag",
    "#0x20050=1 #debug CPRI service",
    "0x10057=1 # AaSysComMsgRerouteEnable",
    "0x10045=20000000 # ERadCcs_AaSysLogStartupLogSize",
]

DELAY_ENDC_TRIGGERING_UP_TO_5_SEC = "0x001300CF=5000 #TUecRadIcsEnDcTriggerPostponeTimeMs"
