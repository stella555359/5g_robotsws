CELL_581 = "GNB_2_CELL_581"
CELL_582 = "GNB_2_CELL_582"
CELL_591 = "GNB_1_CELL_591"
CELL_592 = "GNB_1_CELL_592"
CELL_593 = "GNB_1_CELL_593"
CELL_58 = "LTE_CELL_58"

H_B1 = {
    "srbinactivity": 60,
    "reportamount": "r4",
    "a4threshold": 25,
}
H_B2_3 = {
    "srbinactivity": 147,
    "reportamount": "r1",
    "a4threshold": 127,
}
I_B2 = {
    "srbinactivity": 10,
    "reportamount": "r4",
    "a4threshold": 25,
}
EA = {
    "srbinactivity": 5,
    "reportamount": "r4",
    "a4threshold": 25,
}
HA = {
    "srbinactivity": 600,
    "reportamount": "r4",
    "a4threshold": 25,
}
BTS_50859_HO_PCAP_FLOW = ["HandoverRequest.*", "BearerContextSetupRequest.*", "HandoverRequestAcknowledge.*",
                          "DLRRCMessageTransfer.*", "ULRRCMessageTransfer"]
BTS_50859_HO_via_NG_PCAP_FLOW = ["HandoverRequest.*", "BearerContextSetupRequest.*", "HandoverRequestAcknowledge.*",
                                 "HandoverNotify.*", "UEContextSetupRequest.*", "UEContextSetupResponse"]
INACTIVITY_STATE = ["rrcSetupRequest.*", "rrcSetup.*", "rrcSetupComplete.*", "BearerContextSetupRequest.*",
                    "UEContextSetupRequest.*", "UEContextSetupResponse.*", "BearerContextModificationRequest.*",
                    "BearerContextModificationResponse.*", "BearerContextInactivityNotification.*",
                    "BearerContextModificationRequest.*", "UEContextReleaseCommand.*",
                    "BearerContextModificationResponse.*", "UEContextReleaseComplete.*", "InitialULRRCMessageTransfer.",
                    "UEContextSetupRequest.*", "UEContextSetupResponse.*", "BearerContextModificationRequest.*",
                    "BearerContextModificationResponse.*", "UEContextModificationRequest.*",
                    "UEContextModificationResponse.*", "ULRRCMessageTransfer.*", "UEContextModificationRequest.*",
                    "UEContextModificationResponse.*", "ULRRCMessageTransfer.*", "UEContextReleaseComplete"]
PS_CELL_ADDITION = ["rrcSetupRequest.*", "rrcSetup.*", "rrcSetupComplete.*", "UEContextSetupRequest.*",
                    "UEContextSetupResponse.*", "UEContextModificationRequest.*", "UEContextModificationResponse.*",
                    "BearerContextModificationRequest.*", "BearerContextModificationResponse.*",
                    "UEContextSetupRequest.*", "UEContextSetupResponse.*", "UEContextModificationRequest.*",
                    "UEContextModificationResponse.*", "DLRRCMessageTransfer.*", "ULRRCMessageTransfer"]
SET_FOR_I = {
    "a4MeasNrDcEnabled": ["NRBTS-50859/NRCELL-592/NRHOIF-3", "none"],
    "nrDcAllowed": ["NRBTS-50859/NRCELL-592/NRREL-4", "false"],
    "actCDrx": ["NRBTS-50859/NRCELL-592", "true"]
}
SET_FOR_B4_ENABLE = {
    "a4MeasNrDcEnabled": ["NRBTS-50859/NRCELL-592/NRHOIF-1", "rsrp"]
}
SET_FOR_B4_DISABLE = {
    "a4MeasNrDcEnabled": ["NRBTS-50859/NRCELL-592/NRHOIF-1", "none"]
}

SET_FOR_EA = {
    "drbInactivityTimerSA": ["NRBTS-50859", "5"],
    "drbRrcInactInactivityTimerSA": ["NRBTS-50859", "10"]
}
DISABLE_RRC_INACTIVE = {
    "drbRrcInactInactivityTimerSA": ["NRBTS-50859", "7200"]
}
PARAMS_WITH_RELATION_ERRORS = {
    "caConfigurationSupport": ["NRBTS-50859", "none"],
    "actCarrierAggregation": ["NRBTS-50859", "false"]
}
SYSLOG_HA = {
    "Retry Timer": "RetryTimer started.",
    "Supervision Timer": "SupervisionTimer.",
    "Rfsp exist": "UE has indexToRFSP: 99 and is FWA: true",
    "NRDC UE profile creation": "Adding NrdcUeMnProfile",
    "NRDC Addition procedure": "NrdcMnSideSnodeAddition",
    "PDCP check - tput": r'INF/L2HiCu.*?STATS-DL-PDCP.*?inB:(\d[1-9]+)',
}
SYSLOG_B2A = {
    "Retry Timer": "RetryTimer started.",
    "Supervision Timer": "SupervisionTimer.",
    "Rfsp exist": "UE has indexToRFSP: 99 and is FWA: true",
    "NRDC UE profile creation": "Adding NrdcUeMnProfile",
    "NRDC Addition procedure": "NrdcMnSideSnodeAddition",
    "PDCP check - tput": r'INF/L2HiCu.*?STATS-DL-PDCP.*?inB:(\d[1-9]+)',
}
