ca_msgs = [
    "DBG/cplibs/CplibsLogger.hpp:16..* PCell: {832798720, .*Band.*: 41",
    "DBG/cplibs/CplibsLogger.hpp:16..* SCell: {832798721, .*Band.*: 41",
    r"ue::bandList.*: \[\[1\]:CA_n41C, \[2\]:CA_n41.*, \[3\]:CA_n41A-n78A, \[4\]:CA_n41A-n78A, \[5\]:CA_n78.*2A",
    "41, with nrArfcn1:.*<LOG_SCRAM_11>511002</LOG_SCRAM_11>, nrArfcn2:.*<LOG_SCRAM_11>528984</LOG_SCRAM_11> "
    "is contiguous",
    r".*2CC solution: \[n41.*?\{832798721.*?\{832798720.*",
    "ScellUeSchedulingReq coming from.* PCell. PCell.*832798720 - "
    "SCell.*832798721"
]

intra_du_msgs = [
    "Intra DU Handover triggered from cellId:832798720 to cellId:832798721",
    "Admit.*SA UE on nrCellIdentity:832798721",
    "Sending IntraGnbHandover trigger",
    "Starting Intra gNB Intra DU Handover",
    "UeContextSetup done for intra-DU handover for.*Id",
    "Update UE context after intra-DU handover"
]

inter_du_msgs = {
    "source": [
        "Triggering inter gNB HO for ueIdCu",
        "ActiveProcedure set to xnInterGnbHandoverOnSource",
        "Send Xn Status Transfer Message"
    ],
    "target": [
        "1 is found in XnHandOver",
        "Triggering sa Mode Inter DU/gnb Handover",
        "Handling HandoverRequest from CpUeRecvFromGnb",
        "ActiveProcedure reset from xnInterGnbHandoverOnTarget"
    ]
}

multi_ue_sa_msgs = [
    "UE setup: for cellId:832798720",
    "Check bandwidth \\(or dedicated profile) with 70Mhz in downlink",
    "Check bandwidth \\(or dedicated profile) with 50Mhz in downlink",
    "ueAddCause:INITIALACCESS, numOfSrbs:1,numOfDrbs:0"
]

intra_du_ho_nsa_msgs = [
    "Intra DU Handover triggered from cellId:832782356 to cellId:832782357",
    "Admit.*UE.*832782357.*ueAddCause:nsaInterDUorInterGnbHO, sourceUeAddCause:intraDuHandover",
    "NrCellMatched! NrRel pci = PhyCellId",
    "Target cell with.*832782357 is INTRA-GNB cell",
    "IntraGnbIntraDuPSCellChange - HoExecution: leaving WaitForInfoDURRCReconfigurationCompleteFinish state"
]

ca_nsa_msgs = [
    "PCell: {.*832782357, .*Band.*: 41, CaConfig: dlAndUl",
    "SCell: {.*832782356, .*Band.*: 41, CaConfig: dlOnly",
    "ue::bandList.*CA_n41A.*CA_n41.*2A",
    "DBG/cplibs/CplibsLogger.hpp:[0-9]{2} ConcreteBandCombinationMatcher.cpp.*\\[n41\\[A\\].*832782356.*832782357",
    "ScellUeSchedulingReq coming from.* PCell. PCell.*832782357 - SCell.*832782356"
]

multi_ue_ls_nsa_msgs = [
    "Check bandwidth \\(or dedicated profile) with 70Mhz in downlink",
    "Check bandwidth \\(or dedicated profile) with 60Mhz in downlink",
    "UE supportedBandNr BW&SCS is eligible for band 41"
]

multi_ue_ss_nsa_msgs = [
    "Check bandwidth \\(or dedicated profile) with 70Mhz in downlink",
    "Check bandwidth \\(or dedicated profile) with 60Mhz in downlink",
    "UE supportedBandNr BW&SCS is eligible for band 41"
]

all_messages = {
    'ca_msgs': ca_msgs,
    'intra_du_msgs': intra_du_msgs,
    'inter_du_msgs': inter_du_msgs,
    'multi_ue_sa_msgs': multi_ue_sa_msgs,
    'intra_du_ho_nsa_msgs': intra_du_ho_nsa_msgs,
    'ca_nsa_msgs': ca_nsa_msgs,
    'multi_ue_ls_nsa_msgs': multi_ue_ls_nsa_msgs,
    'multi_ue_ss_nsa_msgs': multi_ue_ss_nsa_msgs
}

source_gNB_interHO_filters = [
    "f1ap.procedureCode == 13 and nr-rrc.physCellId == 40 and nr-rrc.physCellId == 81",
    "xnap.procedureCode == 0 and ip.src==10.44.224.85 and ip.dst==10.44.224.84",
    "xnap.procedureCode == 0 and ip.src==10.44.224.84 and ip.dst==10.44.224.85",
    "xnap.procedureCode == 1 and ip.src==10.44.224.85 and ip.dst==10.44.224.84",
    "xnap.procedureCode == 6 and ip.src==10.44.224.84 and ip.dst==10.44.224.85",
]

target_gNB_interHO_filters = [
    "xnap.procedureCode == 0 and xnap.radioNetwork == 1 and ip.src==10.44.224.85 and ip.dst==10.44.224.84",
    "e1ap.procedureCode == 8 and e1ap.System_BearerContextSetupRequest == 1",
    "xnap.procedureCode == 0 and xnap.id == 77 and ip.src==10.44.224.84 and ip.dst==10.44.224.85",
    "ngap.procedureCode == 25 and ip.src==10.44.225.84 and ip.dst==10.94.232.6",
    "ngap.procedureCode == 25 and ip.src==10.94.232.6 and ip.dst==10.44.225.84",
    "xnap.procedureCode == 6 and ip.src==10.44.224.84 and ip.dst==10.44.224.85",
]

inter_du_HO_filters = {
    "target": target_gNB_interHO_filters,
    "source": source_gNB_interHO_filters
}

sa_ue1_attach = 'f1ap.procedureCode == 5 and nr-rrc.locationAndBandwidth == 36300'
sa_ue2_attach = 'f1ap.procedureCode == 5 and nr-rrc.locationAndBandwidth == 24199'

nsa_ue1_attach = 'f1ap.procedureCode == 5 and nr-rrc.locationAndBandwidth == 31624 and nr-rrc.carrierBandwidth == 162'
nsa_ue2_attach = 'f1ap.procedureCode == 5 and nr-rrc.locationAndBandwidth == 24199 and nr-rrc.carrierBandwidth == 189'

ca_filters = {
    "NSA": ["x2ap.procedureCode == 27 and nr-rrc.rrc_TransactionIdentifier == 0 and nr-rrc.physCellId == 21 "
            "and nr-rrc.carrierBandwidth == 106 and nr-rrc.physCellId == 20",
            "f1ap.procedureCode == 7 and nr-rrc.sCellToAddModList == 1 and nr-rrc.physCellId == 21 "
            "and nr-rrc.carrierBandwidth == 106"],
    "SA": ["f1ap.procedureCode == 12 and nr-rrc.sCellToAddModList == 1 and nr-rrc.physCellId == 61",
           "nr-rrc.carrierBandwidth == 273"],
    "CNI": ["f1ap.procedureCode == 12 and nr-rrc.sCellToAddModList == 1 and nr-rrc.physCellId == 61",
            "and nr-rrc.carrierBandwidth == 273"]
}

sa_large_and_small_bwp_dict = {
    "UE_1": {
        "tput_dl": "800Mbits/sec",
        "tput_ul": "300Mbits/sec",
        "min_tput_dl": "240Mbits/sec",
        "min_tput_ul": "30Mbits/sec",
    },
    "UE_2": {
        "tput_dl": "800Mbits/sec",
        "tput_ul": "300Mbits/sec",
        "min_tput_dl": "240Mbits/sec",
        "min_tput_ul": "30Mbits/sec",
    }
}

nsa_large_and_small_bwp_dict = {
    "UE_1": {
        "tput_dl": "800Mbits/sec",
        "tput_ul": "300Mbits/sec",
        "min_tput_dl": "180Mbits/sec",
        "min_tput_ul": "15Mbits/sec",
    },
    "UE_3": {
        "tput_dl": "800Mbits/sec",
        "tput_ul": "300Mbits/sec",
        "min_tput_dl": "180Mbits/sec",
        "min_tput_ul": "15Mbits/sec",
    }
}

nsa_small_and_small_bwp_dict = {
    "UE_3": {
        "tput_dl": "800Mbits/sec",
        "tput_ul": "300Mbits/sec",
        "min_tput_dl": "180Mbits/sec",
        "min_tput_ul": "15Mbits/sec",
    },
    "UE_4": {
        "tput_dl": "800Mbits/sec",
        "tput_ul": "300Mbits/sec",
        "min_tput_dl": "180Mbits/sec",
        "min_tput_ul": "15Mbits/sec",
    }
}

bwp_tput_params = {
    'sa_large_and_small': sa_large_and_small_bwp_dict,
    'nsa_large_and_small': nsa_large_and_small_bwp_dict,
    'nsa_small_and_small': nsa_small_and_small_bwp_dict
}

rnti_info = {
    'SA': {
        'n': 1,
        'high_rnti': {
            'bandwidth': '36300',
        },
        'low_rnti': {
            'bandwidth': '24199',
        },
        'dl_thresholds': {
            'low': {
                'low_bound': 40,
                'high_bound': 90,
                'min_ratio': 0.80
            },
            'high': {
                'low_bound': 40,
                'high_bound': 90,
                'min_ratio': 0.80
            }
        },
        'ul_thresholds': {
            'low': {
                'low_bound': 40,
                'high_bound': 80,
                'min_ratio': 0.70
            },
            'high': {
                'low_bound': 40,
                'high_bound': 80,
                'min_ratio': 0.70
            }
        }
    },
    'NSA': {
        'large-small': {
            'n': 1,
            'high_rnti': {
                'bandwidth': '31624',
                'carrier_bandwidth': '162'
            },
            'low_rnti': {
                'bandwidth': '24199',
                'carrier_bandwidth': '189'
            },
            'dl_thresholds': {
                'low': {
                    'low_bound': 0,
                    'high_bound': 90,
                    'min_ratio': 0.80
                },
                'high': {
                    'low_bound': 0,
                    'high_bound': 90,
                    'min_ratio': 0.80
                }
            },
            'ul_thresholds': {
                'low': {
                    'low_bound': 0,
                    'high_bound': 80,
                    'min_ratio': 0.80
                },
                'high': {
                    'low_bound': 0,
                    'high_bound': 80,
                    'min_ratio': 0.80
                }
            }
        },
        'small-small': {
            'n': 2,
            'high_rnti': {
                'bandwidth': '31624',
                'carrier_bandwidth': '162'
            },
            'dl_thresholds': {
                'low': {
                    'low_bound': 150,
                    'high_bound': 162,
                    'min_ratio': 0.80
                },
                'high': {
                    'low_bound': 150,
                    'high_bound': 162,
                    'min_ratio': 0.80
                }
            },
            'ul_thresholds': {
                'low': {
                    'low_bound': 100,
                    'high_bound': 142,
                    'min_ratio': 0.80
                },
                'high': {
                    'low_bound': 100,
                    'high_bound': 142,
                    'min_ratio': 0.80
                }
            }
        }
    }
}
