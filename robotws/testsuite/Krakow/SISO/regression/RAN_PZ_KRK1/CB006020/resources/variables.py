extension_cells_parameters = {
    5: {
        'nrarfcn': '2071675',
        'gscn': '22446',
        'coreset': '0',
        'physCellId': None,
        'freq_band': '257',
        'channel_ids': [1, 2, 3, 4]
    },
    6: {
        'nrarfcn': '2073339',
        'gscn': '22452',
        'coreset': '0',
        'physCellId': None,
        'freq_band': '257',
        'channel_ids': [1, 2, 3, 4]
    },
    7: {
        'nrarfcn': '2075003',
        'gscn': '22458',
        'coreset': '0',
        'physCellId': None,
        'freq_band': '257',
        'channel_ids': [1, 3]
    },
    8: {
        'nrarfcn': '2076667',
        'gscn': '22464',
        'coreset': '0',
        'physCellId': None,
        'freq_band': '257',
        'channel_ids': [1, 3]
    }
}

cells_to_delete_params_for_4x4_config = [
    {
        'cell_id_to_delete': '4',
        'cell_id_to_copy_from': '3',
        'cell_group_id_to_delete': '0',
        'capabilities': 'REAL_UE',
        'require_ue': 'True',
        'tput_dl_without_cell': '2170 Mbits/sec',
        'tput_ul_without_cell': '135 Mbits/sec',
        'tput_dl': '2170 Mbits/sec',
        'tput_ul': '255 Mbits/sec',
        'tput_duration': '30s',
        'tput_deviation': '85%',
        'protocol': 'udp',
        'parallel_streams_dl': '2',
        'ue_alias': 'main'
    },
    {
        'cell_id_to_delete': '1',
        'cell_id_to_copy_from': '2',
        'cell_group_id_to_delete': '0',
        'capabilities': 'REAL_UE',
        'require_ue': 'False',
        'tput_dl_without_cell': '1670 Mbits/sec',
        'tput_ul_without_cell': '135 Mbits/sec',
        'tput_dl': '2170 Mbits/sec',
        'tput_ul': '255 Mbits/sec',
        'tput_duration': '30s',
        'tput_deviation': '85%',
        'protocol': 'udp',
        'parallel_streams_dl': '2',
        'ue_alias': 'main'
    },
    {
        'cell_id_to_delete': '8',
        'cell_id_to_copy_from': '7',
        'cell_group_id_to_delete': '1',
        'capabilities': 'REAL_UE_EXT',
        'require_ue': 'True',
        'tput_dl_without_cell': '2170 Mbits/sec',
        'tput_ul_without_cell': '135 Mbits/sec',
        'tput_dl': '2170 Mbits/sec',
        'tput_ul': '255 Mbits/sec',
        'tput_duration': '30s',
        'tput_deviation': '85%',
        'protocol': 'udp',
        'parallel_streams_dl': '2',
        'ue_alias': 'extension'
    },
    {
        'cell_id_to_delete': '5',
        'cell_id_to_copy_from': '6',
        'cell_group_id_to_delete': '1',
        'capabilities': 'REAL_UE_EXT',
        'require_ue': 'False',
        'tput_dl_without_cell': '1670 Mbits/sec',
        'tput_ul_without_cell': '135 Mbits/sec',
        'tput_dl': '2170 Mbits/sec',
        'tput_ul': '255 Mbits/sec',
        'tput_duration': '30s',
        'tput_deviation': '85%',
        'protocol': 'udp',
        'parallel_streams_dl': '2',
        'ue_alias': 'extension'
    }
]


alarms_allowed_during_preparation = [
    {
        'alarm_id': 7115,
        'fault_id': 2915,
        'fault_name': 'Antenna module lost',
        'severity':  'Minor',
        'reason':   'Extension antenna module is unused'
    }
]
