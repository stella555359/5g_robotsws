"""
Author: Du Ning
Contacts: ning.du@nokia-sbell.com
Description: This file is for the release temprary NIDD parameter definiton.
"""

data_temp = {
    'MRBTS-1/MNL-1': {
        'tmpParam2': '22222',
        'tmpParam3': '22222',
        'tmpParam4': '22222'
        },
    'MRBTS-1/NRBTS-1': {
        'tmpParam1': '22222',
        'tmpParam2': '22222',
        'tmpParam17': '10',
        'tmpParam18': '10',
        'tmpParam19': '10',
        'tmpParam20': '1',
        'tmpActFeat2': '59'    # 32 bit: 0b 0000 0000 0000 0000 0000 0000 0011 1011
        },
    'MRBTS-1/NRBTS-1/NRCELL-1': {
        'tmpParam11': '6',
        'tmpParam12': '6',
        'tmpParam13': '6',
        'tmpParam16': '20',
        'tmpParam17': '10',
        'tmpParam18': '10',
        'tmpParam19': '10',
        'tmpActFeat2': '261504'    # 32 bit: 0b 0000 0000 0000 0011 1111 1101 1000 0000
        }
}

temp_nidd_23R2 = {
    'MRBTS-1/NRBTS-1/NRCELL-1': {
        'tmpParam13': '22222',
        'tmpActFeat2': '4352'    # 32 bit: 0b 0000 0000 0000 0000 0001 0001 0000 0000
        }
}

temp_nidd_23R3 = {
    'MRBTS-1/NRBTS-1': {
        'actBbPoolTddFr1': 'true',
        'tmpParam17': '22222',
        'tmpActFeat2': '9'    # 32 bit: 0b 0000 0000 0000 0000 0000 0000 0000 1001
        },
    'MRBTS-1/NRBTS-1/NRCELL-1': {
        'actShortBsrLimitAdaptation': 'true',
        'tmpParam11': '22222',
        'tmpParam12': '22222',
        'tmpParam13': '22222',
        'tmpActFeat2': '22912'    # 32 bit: 0b 0000 0000 0000 0000 0101 1001 1000 0000
        },
    'MRBTS-1/NRBTS-1/NRCELL-2': {
        'actShortBsrLimitAdaptation': 'true',
        }
}

temp_nidd_23R4 = {
    'MRBTS-1/NRBTS-1': {
        'actBbPoolExtensionTddFr1': 'true',
        'actBbPoolTddFr1': 'true',
        'actRedirect': 'true',
        'tmpParam17': '22222',
        'tmpParam18': '10',
        'tmpParam19': '10',
        'tmpParam20': '1',
        'tmpActFeat2': '11'    # 32 bit: 0b 0000 0000 0000 0000 0000 0000 0000 1011
        },
    'MRBTS-1/NRBTS-1/NRCELL-1': {
        'actShortBsrLimitAdaptation': 'true',
        'tmpParam11': '22222',
        'tmpParam12': '22222',
        'tmpParam13': '22222',
        'tmpParam16': '20',
        'tmpParam17': '10',
        'tmpParam18': '10',
        'tmpParam19': '10',
        'tmpActFeat2': '261504'    # 32 bit: 0b 0000 0000 0000 0011 1111 1101 1000 0000
        },
    'MRBTS-1/NRBTS-1/NRCELL-2': {
        'actShortBsrLimitAdaptation': 'true',
        }
}

temp_nidd_24R1 = {
    'MRBTS-1/MNL-1': {
        'tmpParam2': '22222',
        },
    'MRBTS-1/NRBTS-1': {
        'actBbPoolExtensionTddFr1': 'true',
        'actBbPoolTddFr1': 'true',
        'actRedirect': 'true',
        'tmpParam1': '22222',
        'tmpParam2': '22222',
        'tmpParam20': '1',
        'tmpActFeat2': '48'    # 32 bit: 0b 0000 0000 0000 0000 0000 0000 0011 0000
        },
    'MRBTS-1/NRBTS-1/NRCELL-1': {
        'actShortBsrLimitAdaptation': 'true',
        'tmpActFeat2': '131072'    # 32 bit: 0b 0000 0000 0000 0010 0000 0000 0000 0000
        },
    'MRBTS-1/NRBTS-1/NRCELL-2': {
        'actShortBsrLimitAdaptation': 'true',
        }
}

temp_nidd_24R2 = {
}

temp_nidd_24R3 = {
    'MRBTS-1/MNL-1': {
        'tmpParam3': '22222',
        'tmpParam4': '22222'
        }
}

temp_nidd_25R1 = temp_nidd_24R3

temp_nidd_25R2 = {
}

target_nidd_24R1 = {
    'MRBTS-1/NRBTS-1': {
        'sliceBasedPsBwpDeactivation/0/sst': '10',              # tmpParam18
        'sliceBasedPsBwpDeactivation/0/sd': '10',               # tmpParam19
        'includeSrbToAddModList': 'true',                       # tmpActFeat2 3
        'actExplicitCsirsPoolSolution': 'true',                 # tmpActFeat2 1
        'actBbPoolTddFr1AlgEnh': 'true'                         # tmpActFeat2 0
        },
    'MRBTS-1/NRBTS-1/NRDRB-1': {
        'queuingDelayDiscardStart': '10'                        # tmpParam17
    },
    'MRBTS-1/NRBTS-1/NRCELL-1': {
        'actBadUplinkRadioRedirect': '???',                     # tmpParam16
        'badULRedirectDeprioTimer': '???',                      # tmpParam17
        'ulBler/0/ulBlerThresholdRedirectData': '10',           # tmpParam18
        'ulBler/0/ulBlerThresholdRedirectVoNR': '10',           # tmpParam19
        'cellBwpList/0/actUpperThrAckNackFiltering': 'true',    # tmpActFeat2 7
        'actDisableMinPuschUciPrbsUpd': 'true',                 # tmpActFeat2 8
        'actRescheduleBlockedRetx': 'true',                     # tmpActFeat2 10
        'actDisableFoeProtection': 'true',                      # tmpActFeat2 11
        'actDisableCsiRsTrTruncToFitBwp': 'true',               # tmpActFeat2 13
        'actFlexGapOffset': '???'                               # tmpActFeat2 14
        },
    'MRBTS-1/NRBTS-1/NRCELL-1/NRRIM_PROFILE-1': {
        'nrRiThresDropHeightSpecialSlot': '6',                  # tmpParam11
        'maxRsDetectDurationWithoutRi': '6',                    # tmpParam12
        'nrRiMonitorInSSlotEnabled': 'true',                    # tmpActFeat2 15
        # 'nrRiMonitorPowerOfUSlotEnabled': 'true'                # tmpActFeat2 16
    },
    'MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0': {
        'ulCandidatePrbRatio': '6',                             # tmpParam13
        'actUlMuMimoGroupPairing': 'true'                       # tmpActFeat2 12
    }
}

target_nidd_24R2 = {
    # 'MRBTS-1/MNL-1/MNLENT-1/FMCADM-1': {
    #     'actEcpriUlScalingEnh': '???'                           # tmpParam2
    #     },
    'MRBTS-1/NRBTS-1': {
        'tNgRelocOverall': '22222',                             # tmpParam1
        'tNgRelocOverallIN': '22222',                           # tmpParam2
        'sliceBasedPsBwpDeactivation/0/sst': '10',              # tmpParam18
        'sliceBasedPsBwpDeactivation/0/sd': '10',               # tmpParam19
        'actTransPhaseUlPrbNonRandom': 'true',                  # tmpParam20
        'excludeInterGnbNgHoSelCauses': 'RNLradioConnectionWithUeLost/disabled???',    # tmpActFeat2 5
        'actPerCellMacUserThpt': 'true',                        # tmpActFeat2 4
        'includeSrbToAddModList': 'true',                       # tmpActFeat2 3
        'actExplicitCsirsPoolSolution': 'true',                 # tmpActFeat2 1
        'actBbPoolTddFr1AlgEnh': 'true'                         # tmpActFeat2 0
        },
    'MRBTS-1/NRBTS-1/NRDRB-1': {
        'queuingDelayDiscardStart': '10'                        # tmpParam17
    },
    'MRBTS-1/NRBTS-1/NRCELL-1': {
        'actBadUplinkRadioRedirect': '???',                     # tmpParam16
        'badULRedirectDeprioTimer': '???',                      # tmpParam17
        'ulBler/0/ulBlerThresholdRedirectData': '10',           # tmpParam18
        'ulBler/0/ulBlerThresholdRedirectVoNR': '10',           # tmpParam19
        'cellBwpList/0/actUpperThrAckNackFiltering': 'true',    # tmpActFeat2 7
        'actDisableMinPuschUciPrbsUpd': 'true',                 # tmpActFeat2 8
        'actRescheduleBlockedRetx': 'true',                     # tmpActFeat2 10
        'actDisableFoeProtection': 'true',                      # tmpActFeat2 11
        'actDisableCsiRsTrTruncToFitBwp': 'true',               # tmpActFeat2 13
        'actFlexGapOffset': '???',                              # tmpActFeat2 14
        'actAveRxAntPwr': 'true'                                # tmpActFeat2 17
        },
    'MRBTS-1/NRBTS-1/NRCELL-1/NRRIM_PROFILE-1': {
        'nrRiThresDropHeightSpecialSlot': '6',                  # tmpParam11
        'maxRsDetectDurationWithoutRi': '6',                    # tmpParam12
        'nrRiMonitorInSSlotEnabled': 'true'                     # tmpActFeat2 15
        # 'nrRiMonitorPowerOfUSlotEnabled': 'true'                # tmpActFeat2 16
    },
    'MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0': {
        'ulCandidatePrbRatio': '6',                             # tmpParam13
        'actUlMuMimoGroupPairing': 'true'                       # tmpActFeat2 12
    }
}

target_nidd_24R3 = target_nidd_24R2
target_nidd_25R1 = target_nidd_24R2

target_nidd_25R2 = {
    # 'MRBTS-1/MNL-1/MNLENT-1/FMCADM-1': {
    #     'actEcpriUlScalingEnh': '???'                           # tmpParam2
    #     },
    'MRBTS-1/EQM-1/HWTOP-1/CABLINK-1': {
        'iqCompression': '???'                                  # tmpParam4
    },
    # 'MRBTS-1/EQM-1/APEQM-1/CABINET-1/SMOD-1': {
    #     'enableInternalIQRouting': '???'                        # tmpParam3
    # },
    'MRBTS-1/NRBTS-1': {
        'tNgRelocOverall': '22222',                             # tmpParam1
        'tNgRelocOverallIN': '22222',                           # tmpParam2
        'sliceBasedPsBwpDeactivation/0/sst': '10',              # tmpParam18
        'sliceBasedPsBwpDeactivation/0/sd': '10',               # tmpParam19
        'actTransPhaseUlPrbNonRandom': 'true',                  # tmpParam20
        'excludeInterGnbNgHoSelCauses': 'RNLradioConnectionWithUeLost/disabled???',    # tmpActFeat2 5
        'actPerCellMacUserThpt': 'true',                        # tmpActFeat2 4
        'includeSrbToAddModList': 'true',                       # tmpActFeat2 3
        'actExplicitCsirsPoolSolution': 'true',                 # tmpActFeat2 1
        'actBbPoolTddFr1AlgEnh': 'true'                         # tmpActFeat2 0
        },
    'MRBTS-1/NRBTS-1/NRDRB-1': {
        'queuingDelayDiscardStart': '10'                        # tmpParam17
    },
    'MRBTS-1/NRBTS-1/NRCELL-1': {
        'actBadUplinkRadioRedirect': '???',                     # tmpParam16
        'badULRedirectDeprioTimer': '???',                      # tmpParam17
        'ulBler/0/ulBlerThresholdRedirectData': '10',           # tmpParam18
        'ulBler/0/ulBlerThresholdRedirectVoNR': '10',           # tmpParam19
        'cellBwpList/0/actUpperThrAckNackFiltering': 'true',    # tmpActFeat2 7
        'actDisableMinPuschUciPrbsUpd': 'true',                 # tmpActFeat2 8
        'actRescheduleBlockedRetx': 'true',                     # tmpActFeat2 10
        'actDisableFoeProtection': 'true',                      # tmpActFeat2 11
        'actDisableCsiRsTrTruncToFitBwp': 'true',               # tmpActFeat2 13
        'actFlexGapOffset': '???',                              # tmpActFeat2 14
        'actAveRxAntPwr': 'true'                                # tmpActFeat2 17
        },
    'MRBTS-1/NRBTS-1/NRCELL-1/NRRIM_PROFILE-1': {
        'nrRiThresDropHeightSpecialSlot': '6',                  # tmpParam11
        'maxRsDetectDurationWithoutRi': '6',                    # tmpParam12
        'nrRiMonitorInSSlotEnabled': 'true'                     # tmpActFeat2 15
        # 'nrRiMonitorPowerOfUSlotEnabled': 'true'                # tmpActFeat2 16
    },
    'MRBTS-1/NRBTS-1/NRCELL-1/NRULMUMIMO-0': {
        'ulCandidatePrbRatio': '6',                             # tmpParam13
        'actUlMuMimoGroupPairing': 'true'                       # tmpActFeat2 12
    }
}
