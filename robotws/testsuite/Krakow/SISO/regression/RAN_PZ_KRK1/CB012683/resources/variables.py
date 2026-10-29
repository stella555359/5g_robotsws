from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations


sectors_to_call_config = [
    {
        'sector_id': '1',
        'sector_name': 'AWKUC SN: AH250301403',
        'defaultLnRelGnbCellId_value': '31',
        'duration': '240s',
        'tput_dl': '4480 Mbits/sec',
        'tput_ul': '510 Mbits/sec',
        'protocol': 'tcp',
        'deviation_dl': '25%',
        'deviation_ul': '50%',
        'parallel_streams_dl': '8',
        'parallel_streams_ul': '4',
        'size_packet_dl': '1400B',
        'size_packet_ul': '1320B',
        'linux_congestion_dl': 'reno',
    },
    {
        'sector_id': '2',
        'sector_name': 'AWEUA SN: AH204600548',
        'defaultLnRelGnbCellId_value': '1',
        'duration': '120s',
        'tput_dl': '2240 Mbits/sec',
        'tput_ul': '255 Mbits/sec',
        'protocol': 'tcp',
        'deviation_dl': '25%',
        'deviation_ul': '25%',
        'parallel_streams_dl': '8',
        'parallel_streams_ul': '4',
        'size_packet_dl': '1400B',
        'size_packet_ul': '1320B',
        'linux_congestion_dl': 'reno',
    },
    {
        'sector_id': '3',
        'sector_name': 'AWEUA SN: AH204200494',
        'defaultLnRelGnbCellId_value': '2',
        'duration': '120s',
        'tput_dl': '2240 Mbits/sec',
        'tput_ul': '255 Mbits/sec',
        'protocol': 'tcp',
        'deviation_dl': '25%',
        'deviation_ul': '25%',
        'parallel_streams_dl': '8',
        'parallel_streams_ul': '4',
        'size_packet_dl': '1400B',
        'size_packet_ul': '1320B',
        'linux_congestion_dl': 'reno',
    },
]

delta_deactivate_rat_reset_enh = [{
    'distName': 'MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1',
    'operation': 'update',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': 'actRatResetEnhancement',
            'value': 'false'},
        {
            'operation': 'update',
            'parameterName': 'actL1ReconfigImprovement',
            'value': 'false'},
        {
            'operation': 'update',
            'parameterName': 'actBbReconfigImprovement',
            'value': 'false'},
    ]
}]

delta_activate_rat_reset_enh = [{
    'distName': 'MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1',
    'operation': 'update',
    'parameters': [
        {
            'operation': 'update',
            'parameterName': 'actRatResetEnhancement',
            'value': 'true'},
        {
            'operation': 'update',
            'parameterName': 'actL1ReconfigImprovement',
            'value': 'true'},
        {
            'operation': 'update',
            'parameterName': 'actBbReconfigImprovement',
            'value': 'true'},
    ]
}]


parameters_to_change = [
    [
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}',
            'parameter': 'Activate Paging',
            'value': 'true',
            'verification_value': 'true'
        },
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRPMRNL-1',
            'parameter': 'NR Paging',
            'value': '5min',
            'verification_value': '5min'
        },
    ],
    [
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-11',
            'parameter': 'PRACH configuration index',
            'value': '182',
            'verification_value': '182'
        },
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-12',
            'parameter': 'PRACH configuration index',
            'value': '182',
            'verification_value': '182'
        },
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-13',
            'parameter': 'PRACH configuration index',
            'value': '182',
            'verification_value': '182'
        },
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-14',
            'parameter': 'PRACH configuration index',
            'value': '182',
            'verification_value': '182'
        },
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-15',
            'parameter': 'PRACH configuration index',
            'value': '182',
            'verification_value': '182'
        },
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-16',
            'parameter': 'PRACH configuration index',
            'value': '182',
            'verification_value': '182'
        },
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-17',
            'parameter': 'PRACH configuration index',
            'value': '182',
            'verification_value': '182'
        },
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-18',
            'parameter': 'PRACH configuration index',
            'value': '182',
            'verification_value': '182'
        },
    ],
    [
        {
            'dist_name': 'MRBTS-{}/MNL-1/MNLENT-1/SYNC-1',
            'parameter': 'Manual frame timing adjustment',
            'value': '1',
            'verification_value': '1 µs'
        },
    ],
    [
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-11',
            'parameter': 'Start RB',
            'value': '8',
            'verification_value': '8'
        },
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-12',
            'parameter': 'Start RB',
            'value': '8',
            'verification_value': '8'
        },
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-13',
            'parameter': 'Start RB',
            'value': '8',
            'verification_value': '8'
        },
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-14',
            'parameter': 'Start RB',
            'value': '8',
            'verification_value': '8'
        },
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-15',
            'parameter': 'Start RB',
            'value': '8',
            'verification_value': '8'
        },
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-16',
            'parameter': 'Start RB',
            'value': '8',
            'verification_value': '8'
        },
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-17',
            'parameter': 'Start RB',
            'value': '8',
            'verification_value': '8'
        },
        {
            'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-18',
            'parameter': 'Start RB',
            'value': '8',
            'verification_value': '8'
        },
    ],
]


incorrect_parameters = [
    {
        'dist_name': 'MRBTS-{}/NRBTS-{}/NRCELL-11',
        'parameter': 'Start RB',
        'value': '221',
        'verification_value': '8'
    },
]

main_deltas = {
    "delta_remove_cell": [
        {
            "distName": "MRBTS-76004/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-18",
            "operation": "delete",
            "parameters": []
        },
        {
            "distName": "MRBTS-76004/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-18/CHANNELGROUP-1",
            "operation": "delete",
            "parameters": []
        },
        {
            "distName": "MRBTS-76004/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-18/CHANNELGROUP-1/CHANNEL-1",
            "operation": "delete",
            "parameters": []
        },
        {
            "distName": "MRBTS-76004/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-18/CHANNELGROUP-1/CHANNEL-2",
            "operation": "delete",
            "parameters": []
        },
        {
            "distName": "MRBTS-76004/NRBTS-76004/NRCELL-18",
            "operation": "delete",
            "parameters": []
        },
        {
            "distName": "MRBTS-76004/NRBTS-76004/NRCELLGRP-1",
            "operation": "update",
            "parameters": [
                {
                    "parameterName": "nrCellList",
                    "value": ["11", "12", "13", "14", "15", "16", "17"],
                    "operation": "update"
                }
            ]
        }
    ]
}
