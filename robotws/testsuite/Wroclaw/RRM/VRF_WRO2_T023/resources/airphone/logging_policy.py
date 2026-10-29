SET_CCS_SYSLOG_IO_LEVEL_DBG = [
    "0x1003F = 1 # ERadCcs_AaSysLogInputLevel, 1 = debug",
    "0x10040 = 1 # ERadCcs_AaSysLogOutputLevel, 1 = debug",
    "0x10041 = 5 # ERadCcs_AaSysLogOutputMode, 5 = local"]

ENABLE_CP_DEBUG_LOGS = [
    "0x590072 = 1 # CP-RT log level, 1 = debug",
    "0x66001B = 1 # CP-NRT log level, 1 = debug",
    "0x890001 = 0 # CP-NB log level, 0 = trace",
    "0x890002 = 0 # CP-SB log level, 0 = trace",
    "0x890003 = 0 # CP-UE log level, 0 = trace",
    "0x890004 = 0 # CP-CL log level, 0 = trace",
    "0x890005 = 0 # CP-IF log level, 0 = trace",
    "0x890006 = 0 # CP-SCTP log level, 0 = trace",
    "0x890008 = 0 # CP-E2 log level, 0 = trace",
    "0x890009 = 0 # CP-VEMC log level, 0 = trace",
]

ENABLE_CPLANE_DEBUG_LOGS = (
    SET_CCS_SYSLOG_IO_LEVEL_DBG
    + ENABLE_CP_DEBUG_LOGS
)
