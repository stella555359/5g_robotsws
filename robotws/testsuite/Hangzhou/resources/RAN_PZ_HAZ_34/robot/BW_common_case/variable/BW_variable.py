ALLOWED_FAULT = [
    {'faultId': 61652},
    {'faultId': 61524},
    {'faultId': 61649},
    {'faultId': 9000},
    {'faultId': 4592},
    {'faultId': 4527},
    {'faultId': 1932},
    {'faultId': 4334},
    {'faultId': 61074},
    {'faultId': 61618},
]

ALLOWED_HISTORY_FAULT = [
    {'faultId': 61652},
    {'faultId': 61524},
    {'faultId': 61649},
    {'faultId': 9000},
    {'faultId': 4592},
    {'faultId': 4527},
    {'faultId': 1932},
    {'faultId': 4334},
    {'faultId': 61074},
    {'faultId': 61618},
    {'faultId': 7319},
    {'faultId': 7300},
]

NR_Frequencies = {
    # Frequencie_band_width_scs_ssb
    'n78_100_30_30': {
        'NRB': 273,
        'Min_guard': 845,  # unit kHz
        'NrarfcnStep_3gpp': 2
    },
    'n78_80_30_30': {
        'NRB': 217,
        'Min_guard': 925,  # unit kHz
        'NrarfcnStep_3gpp': 2
    },
    'n78_60_30_30': {
        'NRB': 162,
        'Min_guard': 825,  # unit kHz
        'NrarfcnStep_3gpp': 2
    },
    'n78_40_30_30': {
        'NRB': 106,
        'Min_guard': 905,  # unit kHz
        'NrarfcnStep_3gpp': 2
    },
    'n78_20_30_30': {
        'NRB': 51,
        'Min_guard': 805,  # unit kHz
        'NrarfcnStep_3gpp': 2
    },
    'n41_20_30_30': {
        'NRB': 51,
        'Min_guard': 805,  # unit kHz
        'NrarfcnStep_3gpp': 6
    },
    'n40_20_30_30': {
        'NRB': 51,
        'Min_guard': 805,  # unit kHz
        'NrarfcnStep_3gpp': 20
    }
}

Old_SW_version_for_stream = {
    '7.3800': '7.3800.166',
    '9.1800': '9.1800.958',
    '0.800': '0.800.1697'
}
