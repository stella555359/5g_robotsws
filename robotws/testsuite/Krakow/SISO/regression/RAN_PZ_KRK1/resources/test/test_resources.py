# -*- coding: utf-8 -*-
"""
Unit tests for functions parsing RF matrix configuration files.

:copyright: Nokia Networks
:contact: agnieszka.bylica@nokia.com
"""
import pytest
from ..python.common import prepare_cells_setup_for_tput


def test_prepare_cells_setup_for_tput_with_all_ports_under_radio(rf_matrix_ports_under_radio):
    assert prepare_cells_setup_for_tput(rf_matrix_ports_under_radio[0]) == rf_matrix_ports_under_radio[1]


def test_prepare_cells_setup_for_tput_with_some_ports_under_cells(rf_matrix_part_ports_under_cells):
    assert prepare_cells_setup_for_tput(rf_matrix_part_ports_under_cells[0]) == rf_matrix_part_ports_under_cells[1]


@pytest.fixture
def rf_matrix_ports_under_radio():
    input = [
        {
            'ru_id': 1,
            'product_name': 'AVQC',
            'serial_number': '1M242008659',
            'ant_ids': ['13', '14', '15', '16'],
            'cells': [
                {'cell_id': 0, 'exp_dl_tput': '1428 Mbits/sec', 'exp_ul_tput': '225 Mbits/sec'},
                {'cell_id': 3, 'exp_dl_tput': '380 Mbits/sec', 'exp_ul_tput': '55 Mbits/sec'}
            ]},
        {
            'ru_id': 2,
            'product_name': 'AVQC',
            'serial_number': '1M242008661',
            'ant_ids': ['17', '18', '19', '20'],
            'cells': [
                {'cell_id': 1, 'exp_dl_tput': '1428 Mbits/sec', 'exp_ul_tput': '225 Mbits/sec'},
                {'cell_id': 4, 'exp_dl_tput': '380 Mbits/sec', 'exp_ul_tput': '55 Mbits/sec'}
            ]},
        {
            'ru_id': 3,
            'product_name': 'AVQC',
            'serial_number': '1M242008670',
            'ant_ids': ['21', '22', '23', '24'],
            'cells': [
                {'cell_id': 2, 'exp_dl_tput': '1428 Mbits/sec', 'exp_ul_tput': '225 Mbits/sec'},
                {'cell_id': 5, 'exp_dl_tput': '380 Mbits/sec', 'exp_ul_tput': '55 Mbits/sec'}
            ]},
        {
            'ru_id': 4,
            'product_name': 'AHPB',
            'serial_number': 'K9194245990',
            'ant_ids': ['25', '26', '27', '28'],
            'cells': [
                {'cell_id': 16, 'exp_dl_tput': '96 Mbits/sec', 'exp_ul_tput': '44 Mbits/sec'},
                {'cell_id': 19, 'exp_dl_tput': '96 Mbits/sec', 'exp_ul_tput': '44 Mbits/sec'}
            ]},
        {
            'ru_id': 5,
            'product_name': 'AHPB',
            'serial_number': 'EA220150576',
            'ant_ids': ['29', '30', '31', '32'],
            'cells': [
                {'cell_id': 17, 'exp_dl_tput': '96 Mbits/sec', 'exp_ul_tput': '44 Mbits/sec'},
                {'cell_id': 20, 'exp_dl_tput': '96 Mbits/sec', 'exp_ul_tput': '44 Mbits/sec'}
            ]},
        {
            'ru_id': 6,
            'product_name': 'AHPB',
            'serial_number': 'EA220150553',
            'ant_ids': ['57', '58', '59', '60'],
            'cells': [
                {'cell_id': 18, 'exp_dl_tput': '96 Mbits/sec', 'exp_ul_tput': '44 Mbits/sec'},
                {'cell_id': 21, 'exp_dl_tput': '96 Mbits/sec', 'exp_ul_tput': '44 Mbits/sec'}
            ]}
    ]
    result = [
        {
            'active_cell': {
                'exp_dl_tput': '1428 Mbits/sec',
                'exp_ul_tput': '225 Mbits/sec',
                'id': 0,
                'ports': '13:14:15:16',
            },
            'cells_to_block': [
                3,
            ],
            'ru_id': 1,
        },
        {
            'active_cell': {
                'exp_dl_tput': '380 Mbits/sec',
                'exp_ul_tput': '55 Mbits/sec',
                'id': 3,
                'ports': '13:14:15:16',
            },
            'cells_to_block': [
                0,
            ],
            'ru_id': 1,
        },
        {
            'active_cell': {
                'exp_dl_tput': '1428 Mbits/sec',
                'exp_ul_tput': '225 Mbits/sec',
                'id': 1,
                'ports': '17:18:19:20',
            },
            'cells_to_block': [
                4,
            ],
            'ru_id': 2,
        },
        {
            'active_cell': {
                'exp_dl_tput': '380 Mbits/sec',
                'exp_ul_tput': '55 Mbits/sec',
                'id': 4,
                'ports': '17:18:19:20',
            },
            'cells_to_block': [
                1,
            ],
            'ru_id': 2,
        },
        {
            'active_cell': {
                'exp_dl_tput': '1428 Mbits/sec',
                'exp_ul_tput': '225 Mbits/sec',
                'id': 2,
                'ports': '21:22:23:24',
            },
            'cells_to_block': [
                5,
            ],
            'ru_id': 3,
        },
        {
            'active_cell': {
                'exp_dl_tput': '380 Mbits/sec',
                'exp_ul_tput': '55 Mbits/sec',
                'id': 5,
                'ports': '21:22:23:24',
            },
            'cells_to_block': [
                2,
            ],
            'ru_id': 3,
        },
        {
            'active_cell': {
                'exp_dl_tput': '96 Mbits/sec',
                'exp_ul_tput': '44 Mbits/sec',
                'id': 16,
                'ports': '25:26:27:28',
            },
            'cells_to_block': [
                19,
            ],
            'ru_id': 4,
        },
        {
            'active_cell': {
                'exp_dl_tput': '96 Mbits/sec',
                'exp_ul_tput': '44 Mbits/sec',
                'id': 19,
                'ports': '25:26:27:28',
            },
            'cells_to_block': [
                16,
            ],
            'ru_id': 4,
        },
        {
            'active_cell': {
                'exp_dl_tput': '96 Mbits/sec',
                'exp_ul_tput': '44 Mbits/sec',
                'id': 17,
                'ports': '29:30:31:32',
            },
            'cells_to_block': [
                20,
            ],
            'ru_id': 5,
        },
        {
            'active_cell': {
                'exp_dl_tput': '96 Mbits/sec',
                'exp_ul_tput': '44 Mbits/sec',
                'id': 20,
                'ports': '29:30:31:32',
            },
            'cells_to_block': [
                17,
            ],
            'ru_id': 5,
        },
        {
            'active_cell': {
                'exp_dl_tput': '96 Mbits/sec',
                'exp_ul_tput': '44 Mbits/sec',
                'id': 18,
                'ports': '57:58:59:60',
            },
            'cells_to_block': [
                21,
            ],
            'ru_id': 6,
        },
        {
            'active_cell': {
                'exp_dl_tput': '96 Mbits/sec',
                'exp_ul_tput': '44 Mbits/sec',
                'id': 21,
                'ports': '57:58:59:60',
            },
            'cells_to_block': [
                18,
            ],
            'ru_id': 6,
        },
    ]
    return input, result


@pytest.fixture
def rf_matrix_part_ports_under_cells():
    input = [{
        'ru_id': 1,
        'product_name': 'AQQJ',
        'serial_number': '1M230700989',
        'ant_ids': ['1', '2', '3', '4'],
        'cells': [
            {'cell_id': 0, 'exp_dl_tput': '1428 Mbits/sec', 'exp_ul_tput': '225 Mbits/sec'},
            {'cell_id': 3, 'exp_dl_tput': '380 Mbits/sec', 'exp_ul_tput': '55 Mbits/sec'}
        ]},
        {
        'ru_id': 2,
        'product_name': 'AQQJ',
        'serial_number': '1M230700947',
        'ant_ids': ['5', '6', '7', '8'],
        'cells': [
            {'cell_id': 1, 'exp_dl_tput': '1428 Mbits/sec', 'exp_ul_tput': '225 Mbits/sec'},
            {'cell_id': 4, 'exp_dl_tput': '380 Mbits/sec', 'exp_ul_tput': '55 Mbits/sec'}
        ]},
        {
        'ru_id': 3,
        'product_name': 'AQQJ',
        'serial_number': '1M230700980',
        'ant_ids': ['9', '10', '11', '12'],
        'cells': [
            {'cell_id': 2, 'exp_dl_tput': '1428 Mbits/sec', 'exp_ul_tput': '225 Mbits/sec'},
            {'cell_id': 5, 'exp_dl_tput': '380 Mbits/sec', 'exp_ul_tput': '55 Mbits/sec'}
        ]},
        {
        'ru_id': 4,
        'product_name': 'AHPB',
        'serial_number': 'K9182839872',
        'ant_ids': None,
        'cells': [
            {'cell_id': 16, 'exp_dl_tput': '96 Mbits/sec', 'exp_ul_tput': '44 Mbits/sec', 'ant_ids': ['33', '34']},
            {'cell_id': 19, 'exp_dl_tput': '96 Mbits/sec', 'exp_ul_tput': '44 Mbits/sec', 'ant_ids': ['35', '36']}
        ]},
        {
        'ru_id': 5,
        'product_name': 'AHPB',
        'serial_number': 'EA222355911',
        'ant_ids': None,
        'cells': [
            {'cell_id': 17, 'exp_dl_tput': '96 Mbits/sec', 'exp_ul_tput': '44 Mbits/sec', 'ant_ids': ['37', '38']},
            {'cell_id': 20, 'exp_dl_tput': '96 Mbits/sec', 'exp_ul_tput': '44 Mbits/sec', 'ant_ids': ['39', '40']}
        ]},
        {
        'ru_id': 6,
        'product_name': 'AHPB',
        'serial_number': 'EA222356194',
        'ant_ids': None,
        'cells': [
            {'cell_id': 18, 'exp_dl_tput': '96 Mbits/sec', 'exp_ul_tput': '44 Mbits/sec', 'ant_ids': ['41', '42']},
            {'cell_id': 21, 'exp_dl_tput': '96 Mbits/sec', 'exp_ul_tput': '44 Mbits/sec', 'ant_ids': ['43', '44']}
        ]}
    ]
    result = [
        {
            'active_cell': {
                'exp_dl_tput': '1428 Mbits/sec',
                'exp_ul_tput': '225 Mbits/sec',
                'id': 0,
                'ports': '1:2:3:4',
            },
            'cells_to_block': [
                3,
            ],
            'ru_id': 1,
        },
        {
            'active_cell': {
                'exp_dl_tput': '380 Mbits/sec',
                'exp_ul_tput': '55 Mbits/sec',
                'id': 3,
                'ports': '1:2:3:4',
            },
            'cells_to_block': [
                0,
            ],
            'ru_id': 1,
        },
        {
            'active_cell': {
                'exp_dl_tput': '1428 Mbits/sec',
                'exp_ul_tput': '225 Mbits/sec',
                'id': 1,
                'ports': '5:6:7:8',
            },
            'cells_to_block': [
                4,
            ],
            'ru_id': 2,
        },
        {
            'active_cell': {
                'exp_dl_tput': '380 Mbits/sec',
                'exp_ul_tput': '55 Mbits/sec',
                'id': 4,
                'ports': '5:6:7:8',
            },
            'cells_to_block': [
                1,
            ],
            'ru_id': 2,
        },
        {
            'active_cell': {
                'exp_dl_tput': '1428 Mbits/sec',
                'exp_ul_tput': '225 Mbits/sec',
                'id': 2,
                'ports': '9:10:11:12',
            },
            'cells_to_block': [
                5,
            ],
            'ru_id': 3,
        },
        {
            'active_cell': {
                'exp_dl_tput': '380 Mbits/sec',
                'exp_ul_tput': '55 Mbits/sec',
                'id': 5,
                'ports': '9:10:11:12',
            },
            'cells_to_block': [
                2,
            ],
            'ru_id': 3,
        },
        {
            'active_cell': {
                'exp_dl_tput': '96 Mbits/sec',
                'exp_ul_tput': '44 Mbits/sec',
                'id': 16,
                'ports': '33:34',
            },
            'cells_to_block': [
                19,
            ],
            'ru_id': 4,
        },
        {
            'active_cell': {
                'exp_dl_tput': '96 Mbits/sec',
                'exp_ul_tput': '44 Mbits/sec',
                'id': 19,
                'ports': '35:36',
            },
            'cells_to_block': [
                16,
            ],
            'ru_id': 4,
        },
        {
            'active_cell': {
                'exp_dl_tput': '96 Mbits/sec',
                'exp_ul_tput': '44 Mbits/sec',
                'id': 17,
                'ports': '37:38',
            },
            'cells_to_block': [
                20,
            ],
            'ru_id': 5,
        },
        {
            'active_cell': {
                'exp_dl_tput': '96 Mbits/sec',
                'exp_ul_tput': '44 Mbits/sec',
                'id': 20,
                'ports': '39:40',
            },
            'cells_to_block': [
                17,
            ],
            'ru_id': 5,
        },
        {
            'active_cell': {
                'exp_dl_tput': '96 Mbits/sec',
                'exp_ul_tput': '44 Mbits/sec',
                'id': 18,
                'ports': '41:42',
            },
            'cells_to_block': [
                21,
            ],
            'ru_id': 6,
        },
        {
            'active_cell': {
                'exp_dl_tput': '96 Mbits/sec',
                'exp_ul_tput': '44 Mbits/sec',
                'id': 21,
                'ports': '43:44',
            },
            'cells_to_block': [
                18,
            ],
            'ru_id': 6,
        },
    ]
    return input, result
