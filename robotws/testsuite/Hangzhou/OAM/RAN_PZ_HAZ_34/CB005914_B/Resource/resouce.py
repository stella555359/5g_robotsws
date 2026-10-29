# copyright: Nokia 5G RAN
# Contact: I_MN_5G_RAN_IV4_LINE_HZG_8_IV@internal.nsn.com

DICT__radio_configuration = {
    "RMOD-1/RMOD_R-1(AKQJ)": {
        "Antenna list": "Group4(-45 polarization)",
        "-45 Polarization": ['ANT4'],
        "capture_activity_timer": 4
    },
    "RMOD-2/RMOD_R-2(AQQK)": {
        "Antenna list": "Group1(-45 polarization, +45 polarization)",
        "-45 Polarization": [0, 6],
        "+45 Polarization": [2, 16],
        "capture_activity_timer": 3
    },
    "RMOD-1/RMOD_R-1(AWHQN)": {
        "Antenna list": "Set4(+45 polarization)",
        "+45 Polarization": ['ANT4'],
        "capture_activity_timer": 4
    },
    "RMOD-2/RMOD_R-2(AWHQN)": {
        "Antenna list": "Set4(+45 polarization)",
        "+45 Polarization": ['ANT4'],
        "capture_activity_timer": 4
    },
}

DICT__radio_configuration_before24R3 = {
    "RMOD-1/RMOD_R-1(AKQJ)": {
        "Antenna list": "Group4(-45 polarization)",
        "-45 Polarization": ['ANT4'],
        "capture_activity_timer": 4
    },
    "RMOD-2/RMOD_R-2(AQQK)": {
        "Antenna list": "Group1(-45 polarization, +45 polarization)",
        "-45 Polarization": [0, 6],
        "+45 Polarization": [2, 16],
        "capture_activity_timer": 3
    },
    "RMOD-1/RMOD_R-1(AWHQN)": {
        "Antenna list": "Group4(+45 polarization)",
        "+45 Polarization": ['ANT4'],
        "capture_activity_timer": 4
    },
    "RMOD-2/RMOD_R-2(AWHQN)": {
        "Antenna list": "Group4(+45 polarization)",
        "+45 Polarization": ['ANT4'],
        "capture_activity_timer": 4
    },
}

# 23R3 and before
DICT__rmod_snapshot_23R3 = {
    "AKQJ": "gandalf_logs",
    "AQQK": "bfw"
}

# between 23R4 and 24R3
DICT__rmod_snapshot_24R3 = {
    "AKQJ": "gandalf_logs",
    "AQQK": "gandalf_logs",
    "AWHQN": "gandalf_logs",
}

# 25R1 and later
DICT__rmod_snapshot = {
    "AKQJ": "fcpTriggeredCapture",
    "AQQK": "fcpTriggeredCapture",
    "AWHQN": "fcpTriggeredCapture",
    "AVQC": "fcpTriggeredCapture",
}


L3CALL_TL = {'846': {
    '31': {'ue_index': '0', 'dl_tp_ratio': '1', 'ul_tp_ratio': '1', 'peak_tp_dl': '100', 'peak_tp_ul': '30',
           'duration': '60'},
    '32': {'ue_index': '0', 'dl_tp_ratio': '1', 'ul_tp_ratio': '1', 'peak_tp_dl': '100', 'peak_tp_ul': '60',
           'duration': '60'},
    '33': {'ue_index': '0', 'dl_tp_ratio': '1', 'ul_tp_ratio': '1', 'peak_tp_dl': '100', 'peak_tp_ul': '30',
           'duration': '60'}
   }
}
