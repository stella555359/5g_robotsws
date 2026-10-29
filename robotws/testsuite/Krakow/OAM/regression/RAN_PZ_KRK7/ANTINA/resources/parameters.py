cells_mapping = [
    {
        'cell_id_to_copy_from': '1001',
        'group_id': '1',
        'cell_parameters': {'lcrId': '1111',
                            'nrarfcn': '646666',
                            'gscnOrSsPbchArfcn': '1',
                            'physCellId': '111',
                            'type0CoresetConfigurationIndex': '12'
                            }
    },
    {
        'cell_id_to_copy_from': '1002',
        'group_id': '2',
        'cell_parameters': {'lcrId': '2222',
                            'nrarfcn': '646666',
                            'gscnOrSsPbchArfcn': '1',
                            'physCellId': '222',
                            'type0CoresetConfigurationIndex': '12'
                            }
    },
    {
        'cell_id_to_copy_from': '1003',
        'group_id': '3',
        'cell_parameters': {'lcrId': '3333',
                            'nrarfcn': '646666',
                            'gscnOrSsPbchArfcn': '1',
                            'physCellId': '333',
                            'type0CoresetConfigurationIndex': '12'
                            }
    }
    ]

qc_id_mapping = {
    '7_7_T01PY074': {
        'SBTS00': {
            'qc_upgrade': 237730,
            'qc_activation': 237731,
            'qc_ru_reset': 244777,
            'qc_ru_power_reset': 244778,
            'qc_bb_reset': 244779,
            'qc_cell_lock_unlock': 244780,
            'qc_delta_reset': 244781,
            'qc_site_reset': 244783,
            'bts_power_cycle': 280508,
            },
        'SBTS26R1': {
            'qc_upgrade': 254566,
            'qc_activation': 254565,
            'qc_ru_reset': 254571,
            'qc_ru_power_reset': 254573,
            'qc_bb_reset': 254567,
            'qc_cell_lock_unlock': 254568,
            'qc_delta_reset': 254569,
            'qc_site_reset': 254572,
            'bts_power_cycle': 280506,
            }
        },
    '7_7_T01PY067': {
        'SBTS00': {
            'qc_upgrade': 229028,
            'qc_activation': 229027,
            'qc_ru_reset': 273232,
            'qc_ru_power_reset': 273231,
            'qc_bb_reset': 273234,
            'qc_cell_lock_unlock': 273230,
            'qc_delta_reset': 273229,
            'qc_site_reset': 273227,
            'bts_power_cycle': 280507,
            },
        'SBTS26R1': {
            'qc_upgrade': 254563,
            'qc_activation': 254564,
            'qc_ru_reset': 273832,
            'qc_ru_power_reset': 273826,
            'qc_bb_reset': 273828,
            'qc_cell_lock_unlock': 273827,
            'qc_delta_reset': 273831,
            'qc_site_reset': 273830,
            'bts_power_cycle': 280505,
            }
        }
    }

ue_data = {
    '7_7_T01PY067': {
        'SMAwave_1_address': '10.255.60.151',
        'SMAwave_2_address': '10.255.60.152',
        'SMAwave_1_pdu_port': '14',
        'SMAwave_2_pdu_port': '12',
        'cells_to_block_n78_plmn_001': {
            'cells': [1001, 1003, 3001, 3002, 3003],
            'ue_index': '1',
            'ue_key': 'SMAwave_1'},
        'cells_to_block_n1_plmn_001': {
            'cells': [1001, 1002, 1003, 3001, 3003],
            'ue_index': '1',
            'ue_key': 'SMAwave_1'},
        # 'cells_to_block_n78_plmn_244': {
        #     'cells': [1002, 1003, 3001, 3002, 3003],
        #     'ue_index': '2',
        #     'ue_key': 'SMAwave_2'},
        'cells_to_block_new_cell_n78': {
            'cells': [1001, 1002, 1003, 3001, 3002, 3003],
            'ue_index': '2',
            'ue_key': 'SMAwave_2'},
        },
    '7_7_T01PY074': {
        'SMAwave_1_address': '10.255.60.149',
        'SMAwave_2_address': '10.255.60.150',
        'SMAwave_1_pdu_port': '22',
        'SMAwave_2_pdu_port': '20',
        'cells_to_block_n78_plmn_001': {
            'cells': [1002, 1003, 3001, 3002, 3003],
            'ue_index': '1',
            'ue_key': 'SMAwave_1'},
        'cells_to_block_n1_plmn_001': {
            'cells': [1001, 1002, 1003, 3001, 3003],
            'ue_index': '1',
            'ue_key': 'SMAwave_1'},
        'cells_to_block_n78_plmn_244': {
            'cells': [1002, 1003, 3001, 3002, 3003],
            'ue_index': '2',
            'ue_key': 'SMAwave_2'},
        'cells_to_block_new_cell_n78': {
            'cells': [1001, 1002, 1003, 3001, 3002, 3003],
            'ue_index': '1',
            'ue_key': 'SMAwave_1'},
        }
    }
