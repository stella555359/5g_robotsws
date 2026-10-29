# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MRBTS_ID = 'MRBTS-' + str(tl.gnbs[0].instance_id)
NRBTS_ID = MRBTS_ID + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
NRCELL_1 = NRBTS_ID + '/NRCELL-1'
NRCELL_2 = NRBTS_ID + '/NRCELL-2'
NRCELL_3 = NRBTS_ID + '/NRCELL-3'
NRCELL_4 = NRBTS_ID + '/NRCELL-4'
NRCELL_5 = NRBTS_ID + '/NRCELL-5'
NRCELL_6 = NRBTS_ID + '/NRCELL-6'
NRCELL_7 = NRBTS_ID + '/NRCELL-7'
NRCELL_8 = NRBTS_ID + '/NRCELL-8'
NRPMRNL_1 = NRBTS_ID + '/NRPMRNL-1'
NRDRB_ID = NRBTS_ID + '/NRDRB-'

# modify parameter
case1_common = [dict(dist_name=NRCELL_1, parameter='actCDrx', value='true'),
                dict(dist_name=NRCELL_2, parameter='actCDrx', value='true'),
                dict(dist_name=NRCELL_3, parameter='actCDrx', value='true'),
                dict(dist_name=NRCELL_4, parameter='actCDrx', value='true'),
                dict(dist_name=NRCELL_5, parameter='actCDrx', value='true'),
                dict(dist_name=NRCELL_6, parameter='actCDrx', value='true'),
                dict(dist_name=NRCELL_7, parameter='actCDrx', value='true'),
                dict(dist_name=NRCELL_8, parameter='actCDrx', value='true'),
                dict(dist_name=NRPMRNL_1, parameter='miNrCellUtilization', value='5min'),
                dict(dist_name=NRPMRNL_1, parameter='miNrMacSduReport', value='5min')]

case1_structure = [dict(dist_name=NRCELL_1, parameter='drxProfile1',
                        value={'drxOnDurationTimer': '10ms', 'drxInactivityTimer': '80ms'}),
                   dict(dist_name=NRCELL_2, parameter='drxProfile1',
                        value={'drxOnDurationTimer': '10ms', 'drxInactivityTimer': '80ms'}),
                   dict(dist_name=NRCELL_3, parameter='drxProfile1',
                        value={'drxOnDurationTimer': '10ms', 'drxInactivityTimer': '80ms'}),
                   dict(dist_name=NRCELL_4, parameter='drxProfile1',
                        value={'drxOnDurationTimer': '10ms', 'drxInactivityTimer': '80ms'}),
                   dict(dist_name=NRCELL_5, parameter='drxProfile1',
                        value={'drxOnDurationTimer': '10ms', 'drxInactivityTimer': '80ms'}),
                   dict(dist_name=NRCELL_6, parameter='drxProfile1',
                        value={'drxOnDurationTimer': '10ms', 'drxInactivityTimer': '80ms'}),
                   dict(dist_name=NRCELL_7, parameter='drxProfile1',
                        value={'drxOnDurationTimer': '10ms', 'drxInactivityTimer': '80ms'}),
                   dict(dist_name=NRCELL_8, parameter='drxProfile1',
                        value={'drxOnDurationTimer': '10ms', 'drxInactivityTimer': '80ms'})
                   ]

case1_keywords_list = ['NRCELL_A-1', 'NRCELL_A-2', 'NRCELL_A-3', 'NRCELL_A-4',
                       'NRCELL_A-5', 'NRCELL_A-6', 'NRCELL_A-7', 'NRCELL_A-8']

case1_modify_para1 = [dict(dist_name=NRCELL_1, p_name='actCDrx', value='true', list_name=None),
                      dict(dist_name=NRCELL_2, p_name='actCDrx', value='true', list_name=None),
                      dict(dist_name=NRCELL_3, p_name='actCDrx', value='true', list_name=None),
                      dict(dist_name=NRCELL_4, p_name='actCDrx', value='true', list_name=None),
                      dict(dist_name=NRCELL_5, p_name='actCDrx', value='true', list_name=None),
                      dict(dist_name=NRCELL_6, p_name='actCDrx', value='true', list_name=None),
                      dict(dist_name=NRCELL_7, p_name='actCDrx', value='true', list_name=None),
                      dict(dist_name=NRCELL_8, p_name='actCDrx', value='true', list_name=None),
                      dict(dist_name=NRPMRNL_1, p_name='miNrCellUtilization', value='5min', list_name=None),
                      dict(dist_name=NRPMRNL_1, p_name='miNrMacSduReport', value='5min', list_name=None),
                      dict(dist_name=NRCELL_1, p_name='drxOnDurationTimer', value='10ms', list_name='drxProfile1'),
                      dict(dist_name=NRCELL_1, p_name='drxInactivityTimer', value='80ms', list_name='drxProfile1'),
                      dict(dist_name=NRCELL_2, p_name='drxOnDurationTimer', value='10ms', list_name='drxProfile1'),
                      dict(dist_name=NRCELL_2, p_name='drxInactivityTimer', value='80ms', list_name='drxProfile1'),
                      dict(dist_name=NRCELL_3, p_name='drxOnDurationTimer', value='10ms', list_name='drxProfile1'),
                      dict(dist_name=NRCELL_3, p_name='drxInactivityTimer', value='80ms', list_name='drxProfile1'),
                      dict(dist_name=NRCELL_4, p_name='drxOnDurationTimer', value='10ms', list_name='drxProfile1'),
                      dict(dist_name=NRCELL_4, p_name='drxInactivityTimer', value='80ms', list_name='drxProfile1'),
                      dict(dist_name=NRCELL_5, p_name='drxOnDurationTimer', value='10ms', list_name='drxProfile1'),
                      dict(dist_name=NRCELL_5, p_name='drxInactivityTimer', value='80ms', list_name='drxProfile1'),
                      dict(dist_name=NRCELL_6, p_name='drxOnDurationTimer', value='10ms', list_name='drxProfile1'),
                      dict(dist_name=NRCELL_6, p_name='drxInactivityTimer', value='80ms', list_name='drxProfile1'),
                      dict(dist_name=NRCELL_7, p_name='drxOnDurationTimer', value='10ms', list_name='drxProfile1'),
                      dict(dist_name=NRCELL_7, p_name='drxInactivityTimer', value='80ms', list_name='drxProfile1'),
                      dict(dist_name=NRCELL_8, p_name='drxOnDurationTimer', value='10ms', list_name='drxProfile1'),
                      dict(dist_name=NRCELL_8, p_name='drxInactivityTimer', value='80ms', list_name='drxProfile1')
                      ]

case3_modify_para1 = [dict(dist_name=NRBTS_ID, p_name='actIpThpt', value='true', list_name=None),
                      dict(dist_name=NRPMRNL_1, p_name='miNrPDCPCell', value='5min', list_name=None),
                      dict(dist_name=NRPMRNL_1, p_name='miNrHighRlcCell', value='5min', list_name=None),
                      dict(dist_name=NRDRB_ID + '1', p_name='dlDataSplitMode', value='dlOverF1UX2U',
                           list_name='nsaDrbParam'),
                      dict(dist_name=NRDRB_ID + '2', p_name='dlDataSplitMode', value='dlOverF1UX2U',
                           list_name='nsaDrbParam'),
                      dict(dist_name=NRDRB_ID + '3', p_name='dlDataSplitMode', value='dlOverF1UX2U',
                           list_name='nsaDrbParam'),
                      dict(dist_name=NRDRB_ID + '4', p_name='dlDataSplitMode', value='dlOverF1UX2U',
                           list_name='nsaDrbParam'),
                      dict(dist_name=NRDRB_ID + '5', p_name='dlDataSplitMode', value='dlOverF1UX2U',
                           list_name='nsaDrbParam'),
                      dict(dist_name=NRDRB_ID + '6', p_name='dlDataSplitMode', value='dlOverF1UX2U',
                           list_name='nsaDrbParam'),
                      dict(dist_name=NRDRB_ID + '7', p_name='dlDataSplitMode', value='dlOverF1UX2U',
                           list_name='nsaDrbParam'),
                      dict(dist_name=NRDRB_ID + '8', p_name='dlDataSplitMode', value='dlOverF1UX2U',
                           list_name='nsaDrbParam'),
                      dict(dist_name=NRDRB_ID + '9', p_name='dlDataSplitMode', value='dlOverF1UX2U',
                           list_name='nsaDrbParam'),
                      dict(dist_name=NRDRB_ID + '10', p_name='dlDataSplitMode', value='dlOverF1UX2U',
                           list_name='nsaDrbParam'),
                      dict(dist_name=NRDRB_ID + '11', p_name='dlDataSplitMode', value='dlOverF1UX2U',
                           list_name='nsaDrbParam'),
                      dict(dist_name=NRDRB_ID + '12', p_name='dlDataSplitMode', value='dlOverF1UX2U',
                           list_name='nsaDrbParam'),
                      dict(dist_name=NRDRB_ID + '13', p_name='dlDataSplitMode', value='dlOverF1UX2U',
                           list_name='nsaDrbParam'),
                      dict(dist_name=NRDRB_ID + '14', p_name='dlDataSplitMode', value='dlOverF1UX2U',
                           list_name='nsaDrbParam')]

# Counter List
case1_counter = {'M55308C26001': [['BTS', 'CELLS', 'NRCELL-1', 'NCELA'], ['BTS', 'CELLS', 'NRCELL-2', 'NCELA']],
                 'M55308C26002': [['BTS', 'CELLS', 'NRCELL-1', 'NCELA'], ['BTS', 'CELLS', 'NRCELL-2', 'NCELA']],
                 'M55309C12001': [['BTS', 'CELLS', 'NRCELL-1', 'NMSDU'], ['BTS', 'CELLS', 'NRCELL-2', 'NMSDU']],
                 'M55309C12002': [['BTS', 'CELLS', 'NRCELL-1', 'NMSDU'], ['BTS', 'CELLS', 'NRCELL-2', 'NMSDU']]}

case3_counter = {'M55350C01007': [['BTS', 'CELLS', 'NRCELL-1', 'PDCPC'], ['BTS', 'CELLS', 'NRCELL-2', 'PDCPC']],
                 'M55350C03007': [['BTS', 'CELLS', 'NRCELL-1', 'PDCPC'], ['BTS', 'CELLS', 'NRCELL-2', 'PDCPC']],
                 'M55350C05007': [['BTS', 'CELLS', 'NRCELL-1', 'PDCPC'], ['BTS', 'CELLS', 'NRCELL-2', 'PDCPC']],
                 'M55350C00007': [['BTS', 'CELLS', 'NRCELL-1', 'PDCPC'], ['BTS', 'CELLS', 'NRCELL-2', 'PDCPC']]}

case5_counter = {'M55349C01007': [['BTS', 'CELLS', 'NRCELL-1', 'NHRRC'], ['BTS', 'CELLS', 'NRCELL-2', 'NHRRC']],
                 'M55349C00007': [['BTS', 'CELLS', 'NRCELL-1', 'NHRRC'], ['BTS', 'CELLS', 'NRCELL-2', 'NHRRC']],
                 'M55349C02001': [['BTS', 'CELLS', 'NRCELL-1', 'NHRRC'], ['BTS', 'CELLS', 'NRCELL-2', 'NHRRC']]}

# row list
case1_row_list = ['NR MAC Thr. DL [Mbps]', 'NR MAC Thr. UL [Mbps]', 'NR PDSCH iBLER[%]', 'NR PUSCH iBLER[%]']

case3_row_list1 = ['NR PDCP Thr. DL [Mbps]', 'NR PDCP Thr. UL [Mbps]', 'NR PDSCH iBLER[%]', 'NR PUSCH iBLER[%]']

case3_row_list2 = ['LTE PDCP Thr. DL [Mbps]', 'LTE PDCP Thr. UL [Mbps]', 'NR PDSCH iBLER[%]', 'NR PUSCH iBLER[%]']

case5_row_list = ['NR RLC Thr. DL [Mbps]', 'NR RLC Thr. UL [Mbps]', 'NR PDSCH iBLER[%]', 'NR PUSCH iBLER[%]']
