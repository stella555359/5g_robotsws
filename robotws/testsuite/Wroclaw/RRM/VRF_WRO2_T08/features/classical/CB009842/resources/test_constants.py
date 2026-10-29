from taf.rfrl.utilities.robot.general import get_builtin_value

DCAP_CONNECTION = {"host": "localhost", "port": "9443", "user": None, "passwd": None}
DCAP_PROFILE = {'gnb_custom_profile': ['condor5gSyslog', "cp_5g", "Tracer_5g"],
                'bts_custom_profile': ['scf', 'ipCapture', ],
                'bip_mirroring_time': 0,
                'wait_for_activation': True}
ATTENUATOR_CONFIG = get_builtin_value("tl.attenuator")
CELLS_PORTS = {"NRCEL-1": [13, 14, 19, 20],
               "NRCEL-2": [15, 16, 21, 22],
               "NRCEL-3": [17, 18, 23, 24]}
BTS_DISTNAME = "MRBTS-50824/NRBTS-50824"
CELLS = ["NRCELL-1", "NRCELL-2"]
UE = get_builtin_value("tl.ues[0]")
LMF_CONNECTION_DETAILS = {"hostname": "10.27.227.254",
                          "username": "root",
                          "password": "nls72NSN"}
LMF_FILE_PATH = r"/root/9842_Wro8/gjill-310260560003274.xml"
PCAP_FILTERS = ('(x2ap || f1ap || s1ap || xnap || ngap || e1ap || nsetapx || '
                '_ws.col.protocol == \"F1AP_18_4_0_P272/NR RRC\")')
PCAP_MSGS = {"CB009842_A_B1_Inactive": {"nrppa.NRPPA_PDU": "unsuccessfulOutcome",
                                        "nrppa.radioNetwork": "requested-item-not-supported"},
             "CB009842_A_B1_Active": {"nrppa.NRPPA_PDU": "successfulOutcome"},
             "CB009842_A_EC2": {"nrppa.NRPPA_PDU": "unsuccessfulOutcome",
                                "nrppa.radioNetwork": "requested-item-not-supported",
                                "nrppa.ReportCharacteristics": "ReportCharacteristics: periodic"},
             "CB009842_A_B6": {"nrppa.NRPPA_PDU": "successfulOutcome",
                               "nrppa.ResultSS_RSRQ": "ResultSS-RSRQ",
                               "nrppa.ResultSS_RSRP": "ResultSS-RSRP",
                               "nrppa.NR_TADV": "NR-TADV"},
             "CB009842_A_B3": {"nrppa.NRPPA_PDU": "successfulOutcome",
                               "nrppa.ResultSS_RSRQ": "ResultSS-RSRQ",
                               "nrppa.ResultSS_RSRP": "ResultSS-RSRP",
                               "nrppa.NR_TADV": "NR-TADV"}}
SYSLOG_PRINTS = {"CB009842_A_B1_Inactive": [r"\[NRPPA\] ECIDMeasurementInitiationRequest is "
                                            "invalid due to none of the Measurement Quantities "
                                            "requested are supported"],
                 "CB009842_A_EC2": [r"\[NRPPA\] ECIDMeasurementInitiationRequest is "
                                    "invalid due to ReportCharacteristics "
                                    "is not onDemand"]}
PM_COUNTERS = {
    "CB009842_A_B1": {"ids": ["M55125C00024", "M55125C00025",
                              "M55125C00026"],
                      "incrementation": {"M55125C00024": 2,
                                         "M55125C00025": 1,
                                         "M55125C00026": 1}},
    "CB009842_A_EC2": {"ids": ["M55125C00026"],
                       "incrementation": {"M55125C00026": 1}},
    "CB009842_A_B6": {"ids": ["M55125C00024", "M55125C00025",
                              "M55113C00013", "M55113C00014"],
                      "incrementation": {"M55125C00024": 1,
                                         "M55125C00025": 1,
                                         "M55113C00013": 1,
                                         "M55113C00014": 1}},
    "CB009842_A_B3": {"ids": ["M55125C00024", "M55125C00025",
                              "M55113C00013", "M55113C00014"],
                      "incrementation": {"M55125C00024": 1,
                                         "M55125C00025": 1,
                                         "M55113C00013": 1,
                                         "M55113C00014": 1}}}
RRC_INACTIVE_SEQUENCE = ("BearerContextInactivityNotification.*"
                         "BearerContextModificationRequest.*"
                         "UEContextReleaseCommand.*"
                         "UEContextReleaseComplete.*"
                         "rrcResumeRequest.*")
