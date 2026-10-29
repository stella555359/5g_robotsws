delta_2mme = [
    {
        'distName': 'MRBTS-{}/LNBTS-{}/LNMME-0',
        'operation': 'update',
        'parameters': [
            {
                'operation': 'update',
                'parameterName': 'ipAddrPrim',
                'value': '10.255.4.127'
            },
        ]
    },
    {
        'distName': 'MRBTS-{}/LNBTS-{}/LNMME-1',
        'operation': 'create',
        'parameters': [
            {
                'operation': 'update',
                'parameterName': 'administrativeState',
                'value': 'unlocked'
            },
            {
                'operation': 'update',
                'parameterName': 'ipAddrPrim',
                'value': '10.255.4.25'
            },
            {
                'operation': 'update',
                'parameterName': 'mmeRatSupport',
                'value': 'Wideband-LTE'
            },
            {
                'operation': 'update',
                'parameterName': 'transportNwId',
                'value': '0'
            },
        ]
    }
]

delta_1mme = [
    {
        'distName': 'MRBTS-{}/LNBTS-{}/LNMME-0',
        'operation': 'update',
        'parameters': [
            {
                'operation': 'update',
                'parameterName': 'ipAddrPrim',
                'value': '10.55.192.6'
            },
        ]
    },
    {
        'distName': 'MRBTS-{}/LNBTS-{}/LNMME-1',
        'operation': 'delete',
        'parameters': []
    }
]

delta_b66_b2 = [
    {
        'distName': 'MRBTS-{}/LNBTS-{}/LNCEL-1/LNCEL_FDD-0',
        'operation': 'update',
        'parameters': [
            {
                'operation': 'update',
                'parameterName': 'earfcnDL',
                'value': '800'
            },
            {
                'operation': 'update',
                'parameterName': 'earfcnUL',
                'value': '18800'
            },
        ]
    },
]

delta_b2_b66 = [
    {
        'distName': 'MRBTS-{}/LNBTS-{}/LNCEL-1/LNCEL_FDD-0',
        'operation': 'update',
        'parameters': [
            {
                'operation': 'update',
                'parameterName': 'earfcnDL',
                'value': '66826'
            },
            {
                'operation': 'update',
                'parameterName': 'earfcnUL',
                'value': '132362'
            },
        ]
    },
]

# ASIR
delta_cell_1_b66 = [
    {
        'distName': 'ASI-1/BTS-1/CELL-1/CHANNELGROUP-1/CHANNEL-1',
        'parameters': [
            {'parameterName': 'antAntlPrDN', 'value': 'ASI-1/ANTMODPR-1/ANTRFSMPR-3/ANTANTLPR-1',
             'operation': 'update', 'index': 0
             },
        ]
    },
    {
        'distName': 'ASI-1/BTS-1/CELL-1/CHANNELGROUP-1/CHANNEL-2',
        'parameters': [
            {'parameterName': 'antAntlPrDN', 'value': 'ASI-1/ANTMODPR-1/ANTRFSMPR-3/ANTANTLPR-1',
             'operation': 'update', 'index': 0
             },
        ]
    },
    {
        'distName': 'ASI-1/BTS-1/CELL-1/CHANNELGROUP-1/CHANNEL-3',
        'parameters': [
            {'parameterName': 'antAntlPrDN', 'value': 'ASI-1/ANTMODPR-1/ANTRFSMPR-3/ANTANTLPR-2',
             'operation': 'update', 'index': 0
             },
        ]
    },
    {
        'distName': 'ASI-1/BTS-1/CELL-1/CHANNELGROUP-1/CHANNEL-4',
        'parameters': [
            {'parameterName': 'antAntlPrDN', 'value': 'ASI-1/ANTMODPR-1/ANTRFSMPR-3/ANTANTLPR-2',
             'operation': 'update', 'index': 0
             },
        ]
    },
]

delta_cell_1_b2 = [
    {
        'distName': 'ASI-1/BTS-1/CELL-1/CHANNELGROUP-1/CHANNEL-1',
        'parameters': [
            {'parameterName': 'antAntlPrDN', 'value': 'ASI-1/ANTMODPR-1/ANTRFSMPR-1/ANTANTLPR-1',
             'operation': 'update', 'index': 0},
        ]
    },
    {
        'distName': 'ASI-1/BTS-1/CELL-1/CHANNELGROUP-1/CHANNEL-2',
        'parameters': [
            {'parameterName': 'antAntlPrDN', 'value': 'ASI-1/ANTMODPR-1/ANTRFSMPR-1/ANTANTLPR-1',
             'operation': 'update', 'index': 0},
        ]
    },
    {
        'distName': 'ASI-1/BTS-1/CELL-1/CHANNELGROUP-1/CHANNEL-3',
        'parameters': [
            {'parameterName': 'antAntlPrDN', 'value': 'ASI-1/ANTMODPR-1/ANTRFSMPR-1/ANTANTLPR-2',
             'operation': 'update', 'index': 0
             },
        ]
    },
    {
        'distName': 'ASI-1/BTS-1/CELL-1/CHANNELGROUP-1/CHANNEL-4',
        'parameters': [
            {'parameterName': 'antAntlPrDN', 'value': 'ASI-1/ANTMODPR-1/ANTRFSMPR-1/ANTANTLPR-2',
             'operation': 'update', 'index': 0
             },
        ]
    },
]
delta_add_RFC1_B7 = [
    {'distName': 'ASI-1', 'moc': 'RFC', 'operation': 'create'},
    {
        'distName': 'ASI-1/RFC-1',
        'parameters': [
            {'parameterName': 'rfcName', 'value': 'Operator freely assigned name for RFC', 'operation': 'create'},
            {'parameterName': 'rfcType', 'value': 'APHB', 'operation': 'create'},
            {'parameterName': 'serialNumber', 'value': 'SN7Q224500006', 'operation': 'create'},
        ]
    },
    {'distName': 'ASI-1/RFC-1', 'moc': 'RFCCELL', 'operation': 'create', 'instanceId': '1'},
    {
        'distName': 'ASI-1/RFC-1/RFCCELL-1',
        'parameters': [
            {'parameterName': 'band', 'value': 'B7', 'operation': 'create'},
            {'parameterName': 'dlBandwidth', 'value': '10 MHz', 'operation': 'update'},
            {'parameterName': 'dlCenterFreq', 'value': '2655000', 'operation': 'create'},
            {'parameterName': 'modeSelection', 'value': 'duplex', 'operation': 'create'},
            {'parameterName': 'pMax', 'value': '170', 'operation': 'create'},
            {'parameterName': 'posAxCDiv', 'value': '3', 'operation': 'create'},
            {'parameterName': 'posAxCMain', 'value': '1', 'operation': 'create'},
            {'parameterName': 'rfSwitchTxDiv', 'value': 'enabled', 'operation': 'create'},
            {'parameterName': 'rfSwitchTxMain', 'value': 'enabled', 'operation': 'create'},
            {'parameterName': 'technology', 'value': 'LTE', 'operation': 'create'},
            {'parameterName': 'ulBandwidth', 'value': '10 MHz', 'operation': 'update'},
            {'parameterName': 'ulCenterFreq', 'value': '2535000', 'operation': 'create'},
        ]
    },
    {'distName': 'ASI-1/RFC-1/RFCCELL-1', 'moc': 'RFCHUBGROUP', 'operation': 'create'},
    {
        'distName': 'ASI-1/RFC-1/RFCCELL-1/RFCHUBGROUP-1',
        'parameters': [
            {'parameterName': 'rfcPortId', 'value': '1', 'operation': 'create'},
        ]
    },
    {'distName': 'ASI-1/RFC-1/RFCCELL-1/RFCHUBGROUP-1', 'moc': 'RFCCHANNEL', 'operation': 'create'},
    {
        'distName': 'ASI-1/RFC-1/RFCCELL-1/RFCHUBGROUP-1/RFCCHANNEL-1',
        'parameters': [
            {'parameterName': 'antAntlPrDN', 'value': 'ASI-1/ANTMODPR-1/ANTRFSMPR-2/ANTANTLPR-1',
             'operation': 'create'},
            {'parameterName': 'targetDirection', 'value': 'TX', 'operation': 'create'},
        ]
    },
    {'distName': 'ASI-1/RFC-1/RFCCELL-1/RFCHUBGROUP-1', 'moc': 'RFCCHANNEL', 'operation': 'create'},
    {
        'distName': 'ASI-1/RFC-1/RFCCELL-1/RFCHUBGROUP-1/RFCCHANNEL-2',
        'parameters': [
            {'parameterName': 'antAntlPrDN', 'value': 'ASI-1/ANTMODPR-1/ANTRFSMPR-2/ANTANTLPR-1',
             'operation': 'create'},
            {'parameterName': 'targetDirection', 'value': 'RX', 'operation': 'create'},
        ]
    },
    {'distName': 'ASI-1/RFC-1/RFCCELL-1/RFCHUBGROUP-1', 'moc': 'RFCCHANNEL', 'operation': 'create'},
    {
        'distName': 'ASI-1/RFC-1/RFCCELL-1/RFCHUBGROUP-1/RFCCHANNEL-3',
        'parameters': [
            {'parameterName': 'antAntlPrDN', 'value': 'ASI-1/ANTMODPR-1/ANTRFSMPR-2/ANTANTLPR-2',
             'operation': 'create'},
            {'parameterName': 'targetDirection', 'value': 'TX', 'operation': 'create'},
        ]
    },
    {'distName': 'ASI-1/RFC-1/RFCCELL-1/RFCHUBGROUP-1', 'moc': 'RFCCHANNEL', 'operation': 'create'},
    {
        'distName': 'ASI-1/RFC-1/RFCCELL-1/RFCHUBGROUP-1/RFCCHANNEL-4',
        'parameters': [
            {'parameterName': 'antAntlPrDN', 'value': 'ASI-1/ANTMODPR-1/ANTRFSMPR-2/ANTANTLPR-2',
             'operation': 'create'},
            {'parameterName': 'targetDirection', 'value': 'RX', 'operation': 'create'},
        ]
    },
    {'distName': 'ASI-1/RFC-1', 'moc': 'RFCPORT', 'operation': 'create'},
    {
        'distName': 'ASI-1/RFC-1/RFCPORT-1',
        'parameters': [
            {'parameterName': 'sfpPortDN', 'value': 'ASI-1/HUBMOD-1/SFPPORT-3', 'operation': 'create'},
        ]
    },
]
delta_add_RFC2_B66 = [
    {'distName': 'ASI-1', 'moc': 'RFC', 'operation': 'create'},
    {
        'distName': 'ASI-1/RFC-2',
        'parameters': [
            {'parameterName': 'rfcName', 'value': 'Operator freely assigned name for RFC', 'operation': 'create'},
            {'parameterName': 'rfcType', 'value': 'APHB', 'operation': 'create'},
            {'parameterName': 'serialNumber', 'value': 'SN7Q203900021', 'operation': 'create'},
        ]
    },
    {'distName': 'ASI-1/RFC-2', 'moc': 'RFCCELL', 'operation': 'create', 'instanceId': '3'},
    {
        'distName': 'ASI-1/RFC-2/RFCCELL-3',
        'parameters': [
            {'parameterName': 'band', 'value': 'B66', 'operation': 'create'},
            {'parameterName': 'dlBandwidth', 'value': '20 MHz', 'operation': 'update'},
            {'parameterName': 'dlCenterFreq', 'value': '2130000', 'operation': 'create'},
            {'parameterName': 'modeSelection', 'value': 'duplex', 'operation': 'create'},
            {'parameterName': 'pMax', 'value': '170', 'operation': 'create'},
            {'parameterName': 'posAxCDiv', 'value': '7', 'operation': 'create'},
            {'parameterName': 'posAxCMain', 'value': '5', 'operation': 'create'},
            {'parameterName': 'rfSwitchTxDiv', 'value': 'enabled', 'operation': 'create'},
            {'parameterName': 'rfSwitchTxMain', 'value': 'enabled', 'operation': 'create'},
            {'parameterName': 'technology', 'value': 'LTE', 'operation': 'create'},
            {'parameterName': 'ulBandwidth', 'value': '20 MHz', 'operation': 'update'},
            {'parameterName': 'ulCenterFreq', 'value': '1730000', 'operation': 'create'},
        ]
    },
    {'distName': 'ASI-1/RFC-2/RFCCELL-3', 'moc': 'RFCHUBGROUP', 'operation': 'create'},
    {
        'distName': 'ASI-1/RFC-2/RFCCELL-3/RFCHUBGROUP-1',
        'parameters': [
            {'parameterName': 'rfcPortId', 'value': '1', 'operation': 'create'},
        ]
    },
    {'distName': 'ASI-1/RFC-2/RFCCELL-3/RFCHUBGROUP-1', 'moc': 'RFCCHANNEL', 'operation': 'create'},
    {
        'distName': 'ASI-1/RFC-2/RFCCELL-3/RFCHUBGROUP-1/RFCCHANNEL-1',
        'parameters': [
            {'parameterName': 'antAntlPrDN', 'value': 'ASI-1/ANTMODPR-1/ANTRFSMPR-3/ANTANTLPR-1',
             'operation': 'create'},
            {'parameterName': 'targetDirection', 'value': 'TX', 'operation': 'create'},
        ]
    },
    {'distName': 'ASI-1/RFC-2/RFCCELL-3/RFCHUBGROUP-1', 'moc': 'RFCCHANNEL', 'operation': 'create'},
    {
        'distName': 'ASI-1/RFC-2/RFCCELL-3/RFCHUBGROUP-1/RFCCHANNEL-2',
        'parameters': [
            {'parameterName': 'antAntlPrDN', 'value': 'ASI-1/ANTMODPR-1/ANTRFSMPR-3/ANTANTLPR-1',
             'operation': 'create'},
            {'parameterName': 'targetDirection', 'value': 'RX', 'operation': 'create'},
        ]
    },
    {'distName': 'ASI-1/RFC-2/RFCCELL-3/RFCHUBGROUP-1', 'moc': 'RFCCHANNEL', 'operation': 'create'},
    {
        'distName': 'ASI-1/RFC-2/RFCCELL-3/RFCHUBGROUP-1/RFCCHANNEL-3',
        'parameters': [
            {'parameterName': 'antAntlPrDN', 'value': 'ASI-1/ANTMODPR-1/ANTRFSMPR-3/ANTANTLPR-2',
             'operation': 'create'},
            {'parameterName': 'targetDirection', 'value': 'TX', 'operation': 'create'},
        ]
    },
    {'distName': 'ASI-1/RFC-2/RFCCELL-3/RFCHUBGROUP-1', 'moc': 'RFCCHANNEL', 'operation': 'create'},
    {
        'distName': 'ASI-1/RFC-2/RFCCELL-3/RFCHUBGROUP-1/RFCCHANNEL-4',
        'parameters': [
            {'parameterName': 'antAntlPrDN', 'value': 'ASI-1/ANTMODPR-1/ANTRFSMPR-3/ANTANTLPR-2',
             'operation': 'create'},
            {'parameterName': 'targetDirection', 'value': 'RX', 'operation': 'create'},
        ]
    },
    {'distName': 'ASI-1/RFC-2', 'moc': 'RFCPORT', 'operation': 'create'},
    {
        'distName': 'ASI-1/RFC-2/RFCPORT-1',
        'parameters': [
            {'parameterName': 'sfpPortDN', 'value': 'ASI-1/HUBMOD-1/SFPPORT-4', 'operation': 'create'},
        ]
    },
]
delta_delete_RFC1 = [{"distName": "ASI-1/RFC-1", "operation": "delete"}]
delta_delete_RFC2 = [{"distName": "ASI-1/RFC-2", "operation": "delete"}]

delta_add_RFC2_and_change_cell_1_to_b2 = delta_cell_1_b2 + delta_add_RFC2_B66
delta_delete_RFC2_and_delta_cell_1_b66 = delta_cell_1_b66 + delta_delete_RFC2
