# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MRBTS_ID = 'MRBTS-' + str(tl.gnbs[0].instance_id)
NRCELL_3 = MRBTS_ID + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-3'
NRCELL_2 = MRBTS_ID + '/NRBTS-' + str(tl.gnbs[0].global_bts_id) + '/NRCELL-2'
NRCELL_2_REL_1 = NRCELL_2 + '/NRREL-1'
NRCELL_3_REL_1 = NRCELL_3 + '/NRREL-1'

BWP_30M_PARA = [
    {
        'actPdcchCceFragmentControl': 'false',
        'actUpperThrAckNackFiltering': 'false',
        'actUpperThrAckNackHrFiltering': 'false',
        'bwpDN': 'MRBTS-37484/NRBTS-37484/BWP_PROFILE-4',
        'cellBwpId': '0',
        'pdcchResourcePreference': 'peakRate',
    },
    {
        'actPdcchCceFragmentControl': 'false',
        'actUpperThrAckNackFiltering': 'false',
        'actUpperThrAckNackHrFiltering': 'false',
        'bwpDN': 'MRBTS-37484/NRBTS-37484/BWP_PROFILE-9',
        'cellBwpId': '1',
        'pdcchResourcePreference': 'peakRate',
    },
]

CB009102_PARA = [dict(dist_name=NRCELL_3, parameter='chBw', value='30MHz', operation='update'),
                 dict(dist_name=NRCELL_3, parameter='ssPbchBlockPower', value='-6', operation='update'),
                 dict(dist_name=NRCELL_3, parameter='cellBwpList', value=BWP_30M_PARA, operation='update'),
                 dict(dist_name=NRCELL_3, parameter='actDl256Qam', value='false', operation='update'),
                 dict(dist_name=NRCELL_3, parameter='actDlLaDynBlerTarget', value='false', operation='update'),
                 dict(dist_name=NRCELL_3, parameter='pMax', value='270', operation='update'),
                 dict(dist_name=NRCELL_2, parameter='chBw', value='30MHz', operation='update'),
                 dict(dist_name=NRCELL_2, parameter='ssPbchBlockPower', value='-6', operation='update'),
                 dict(dist_name=NRCELL_2, parameter='cellBwpList', value=BWP_30M_PARA, operation='update'),
                 dict(dist_name=NRCELL_2, parameter='actDl256Qam', value='false', operation='update'),
                 dict(dist_name=NRCELL_2, parameter='actDlLaDynBlerTarget', value='false', operation='update'),
                 dict(dist_name=NRCELL_2, parameter='pMax', value='270', operation='update'),
                 dict(dist_name=NRCELL_2_REL_1, parameter='sCellAdditionMethod', value='blind',
                      operation='update'),
                 dict(dist_name=NRCELL_2_REL_1, parameter='sCellOperationalMode', value='dlOnly',
                      operation='update'),
                 dict(dist_name=NRCELL_3_REL_1, parameter='sCellAdditionMethod', value='blind',
                      operation='update'),
                 dict(dist_name=NRCELL_3_REL_1, parameter='sCellOperationalMode', value='dlOnly',
                      operation='update')]

Config_9102_UE = {"0": {"dl": {"target_throughput": "800Mbits/sec", "duration": "600"},
                        "ul": {"target_throughput": "50Mbits/sec", "duration": "600"}}, }

CB011088_AWHQV_UE = {"0": {"dl": {"target_throughput": "500Mbits/sec", "duration": "600"},
                           "ul": {"target_throughput": "50Mbits/sec", "duration": "600"}}, }
