import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

# #gnb###
GNB_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
GNB_NR_BTS_NAME = GNB_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
GNB_CELL_NAME = GNB_NR_BTS_NAME + '/NRCELL-4'
CELL4_NAME = GNB_CELL_NAME + '/NRCELL_FDD-1'
GNB_BWP_NAME = GNB_NR_BTS_NAME + '/BWP_PROFILE-'

D_case1_para = [dict(dist_name=CELL4_NAME, parameter='chBwDl', value='40MHz', operation='update'),
                dict(dist_name=CELL4_NAME, parameter='chBwUl', value='40MHz', operation='update'),
                dict(dist_name=GNB_CELL_NAME, parameter='cellBwpList',
                     value=[{'bwpDN': GNB_BWP_NAME + '14', 'cellBwpId': 0, 'actPdcchCceFragmentControl': 'false',
                             'actUpperThrAckNackFiltering': 'false', 'actUpperThrAckNackHrFiltering': 'false',
                             'pdcchResourcePreference': 'peakRate'},
                            {'bwpDN': GNB_BWP_NAME + '157', 'cellBwpId': 1, 'actPdcchCceFragmentControl': 'false',
                             'actUpperThrAckNackFiltering': 'true', 'actUpperThrAckNackHrFiltering': 'true',
                             'pdcchResourcePreference': 'peakRate'}],
                     operation='update')]
