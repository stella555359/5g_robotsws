# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MRBTS_ID = 'MRBTS-' + str(tl.gnbs[0].instance_id)
NRBTS_ID = MRBTS_ID + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
ENB_MRBTS_ID = 'MRBTS-' + str(tl.ues[3].instance_id)
ENB_LNBTS_ID = ENB_MRBTS_ID + '/LNBTS-' + str(tl.ues[3].global_bts_id)
ENB_CELL_ID = ENB_LNBTS_ID + '/LNCEL-2'


# modify parameter
gnb_para1 = [dict(dist_name=NRBTS_ID, parameter='sCellActivationMethod', value='bufferBased', operation='update'),
             dict(dist_name=NRBTS_ID, parameter='maxNumScellsDl', value='7', operation='update'),
             dict(dist_name=NRBTS_ID, parameter='maxNumScellsUl', value='3', operation='update')
             ]

gnb_para2 = [dict(dist_name=NRBTS_ID, parameter='sCellActivationMethod', value='blind', operation='update'),
             dict(dist_name=NRBTS_ID, parameter='maxNumScellsDl', value='7', operation='update'),
             dict(dist_name=NRBTS_ID, parameter='maxNumScellsUl', value='3', operation='update')
             ]

enb_para = [dict(dist_name=ENB_CELL_ID, parameter='defaultLnRelGnbCellId', value='3', operation='update')]

# Counter List
case6_counter = {'M55118C02005': [['BTS', 'CELLS', 'NRCELL-21', 'NCAC']],
                 'M55118C03005': [['BTS', 'CELLS', 'NRCELL-21', 'NCAC']],
                 'M55118C04005': [['BTS', 'CELLS', 'NRCELL-21', 'NCAC']],
                 'M55118C05005': [['BTS', 'CELLS', 'NRCELL-22', 'NCAC'], ['BTS', 'CELLS', 'NRCELL-23', 'NCAC'],
                                  ['BTS', 'CELLS', 'NRCELL-24', 'NCAC']],
                 'M55316C02001': [['BTS', 'CELLS', 'NRCELL-21', 'NCADU']],
                 'M55316C04003': [['BTS', 'CELLS', 'NRCELL-21', 'NCADU']],
                 'M55316C06003': [['BTS', 'CELLS', 'NRCELL-21', 'NCADU']]
                 }

case6_check_counter = {'attach': ['M55118C02005', 'M55118C03005'],
                       'ul_attach_counter': ['M55118C04005', 'M55316C02001'],
                       'dl_attach_counter': [],
                       'ul_scell_counter': 'M55118C05005',
                       'dl_scell_counter': ' ',
                       'ul_tp_counter': 'M55316C04003',
                       'dl_tp_counter': ' '}

case7_counter = {'M55118C02012': [['BTS', 'CELLS', 'NRCELL-21', 'NCAC']],
                 'M55118C03012': [['BTS', 'CELLS', 'NRCELL-21', 'NCAC']],
                 'M55118C04012': [['BTS', 'CELLS', 'NRCELL-21', 'NCAC']],
                 'M55118C05012': [['BTS', 'CELLS', 'NRCELL-22', 'NCAC'], ['BTS', 'CELLS', 'NRCELL-23', 'NCAC'],
                                  ['BTS', 'CELLS', 'NRCELL-24', 'NCAC'], ['BTS', 'CELLS', 'NRCELL-25', 'NCAC'],
                                  ['BTS', 'CELLS', 'NRCELL-26', 'NCAC'], ['BTS', 'CELLS', 'NRCELL-27', 'NCAC']],
                 'M55316C02000': [['BTS', 'CELLS', 'NRCELL-21', 'NCADU']],
                 'M55316C03007': [['BTS', 'CELLS', 'NRCELL-21', 'NCADU']],
                 'M55316C05007': [['BTS', 'CELLS', 'NRCELL-21', 'NCADU']]
                 }

case7_check_counter = {'attach': ['M55118C02012', 'M55118C03012'],
                       'ul_attach_counter': [],
                       'dl_attach_counter': ['M55118C04012', 'M55316C02000'],
                       'ul_scell_counter': '',
                       'dl_scell_counter': 'M55118C05012',
                       'ul_tp_counter': '',
                       'dl_tp_counter': 'M55316C03007'}

case9_counter = {'M55118C04005': [['BTS', 'CELLS', 'NRCELL-21', 'NCAC']],
                 'M55118C05005': [['BTS', 'CELLS', 'NRCELL-22', 'NCAC'], ['BTS', 'CELLS', 'NRCELL-23', 'NCAC'],
                                  ['BTS', 'CELLS', 'NRCELL-24', 'NCAC']],
                 'M55316C04003': [['BTS', 'CELLS', 'NRCELL-21', 'NCADU']],
                 'M55118C04012': [['BTS', 'CELLS', 'NRCELL-21', 'NCAC']],
                 'M55118C05012': [['BTS', 'CELLS', 'NRCELL-22', 'NCAC'], ['BTS', 'CELLS', 'NRCELL-23', 'NCAC'],
                                  ['BTS', 'CELLS', 'NRCELL-24', 'NCAC'], ['BTS', 'CELLS', 'NRCELL-25', 'NCAC'],
                                  ['BTS', 'CELLS', 'NRCELL-26', 'NCAC'], ['BTS', 'CELLS', 'NRCELL-27', 'NCAC']],
                 'M55316C03007': [['BTS', 'CELLS', 'NRCELL-21', 'NCADU']]
                 }

case9_check_counter = {'attach': [],
                       'ul_attach_counter': ['M55118C04005', 'M55316C04003'],
                       'dl_attach_counter': ['M55118C04012', 'M55316C03007'],
                       'ul_scell_counter': 'M55118C05005',
                       'dl_scell_counter': 'M55118C05012',
                       'ul_tp_counter': '',
                       'dl_tp_counter': ''}
