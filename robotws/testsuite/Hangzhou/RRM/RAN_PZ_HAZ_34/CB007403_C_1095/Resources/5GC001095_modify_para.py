from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

# ##gnb1###
GNB_BTS_NAME1 = 'MRBTS-' + str(tl.gnbs[0].instance_id)
GNB_NR_BTS_NAME1 = GNB_BTS_NAME1 + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
GNB_NRCELL_NAME1 = GNB_NR_BTS_NAME1 + '/NRCELL-1'
GNB_NRHOIF1_NAME1 = GNB_NR_BTS_NAME1 + '/NRCELL-1/NRHOIF-1'
GNB_NRADJNRCELL_NAME1 = GNB_NR_BTS_NAME1 + '/NRADJNRCELL-1'

# ##gnb2###
GNB_BTS_NAME2 = 'MRBTS-' + str(tl.gnbs[1].instance_id)
GNB_NR_BTS_NAME2 = GNB_BTS_NAME2 + '/NRBTS-' + str(tl.gnbs[1].global_bts_id)
GNB_NRCELL_NAME2 = GNB_NR_BTS_NAME2 + '/NRCELL-1'
GNB_NRHOIF1_NAME2 = GNB_NRCELL_NAME2 + '/NRHOIF-1'

# ##enb1###
LTE_BTS_NAME = 'MRBTS-' + str(tl.enbs[0].instance_id)
LTE_LNBTS_NAME = LTE_BTS_NAME + '/LNBTS-' + str(tl.enbs[0].global_bts_id)
LTE_LNCEL1_NAME = LTE_LNBTS_NAME + '/LNCEL-1'
LTE_LNCEL2_NAME = LTE_LNBTS_NAME + '/LNCEL-2'


enb1_para1 = [dict(dist_name=LTE_LNCEL1_NAME, parameter='defaultLnRelGnbCellId', value='3')]

gnb1_modify_para1 = [dict(dist_name=GNB_NRCELL_NAME1, parameter='a1MeashoEnabled', value='rsrpCombined')]

gnb1_modify_para = [dict(dist_name=GNB_NRADJNRCELL_NAME1, p_name='nrarfcn', value='2073799'),
                    dict(dist_name=GNB_NR_BTS_NAME1, p_name='actInterFreqInterGnbMobilityNSA', value='true'),
                    dict(dist_name=GNB_NR_BTS_NAME1, p_name='srb3SupportEnabled', value='true')]

gnb2_modify_para = [dict(dist_name=GNB_NRCELL_NAME2, p_name='gscnOrSsPbchArfcn', value='22454'),
                    dict(dist_name=GNB_NRCELL_NAME2, p_name='nrarfcn', value='2073799'),
                    dict(dist_name=GNB_NR_BTS_NAME2, p_name='actInterFreqInterGnbMobilityNSA', value='true'),
                    dict(dist_name=GNB_NR_BTS_NAME2, p_name='srb3SupportEnabled', value='true')]

gnb1_para1 = [dict(dist_name=GNB_NRHOIF1_NAME1, parameter='a3MeasEnabled', value='rsrpAndRsrq'),
              dict(dist_name=GNB_NR_BTS_NAME1, parameter='srb3SupportEnabled', value='false'),
              dict(dist_name=GNB_NRCELL_NAME1, parameter='a1MeashoEnabled', value='rsrp')]

gnb2_para1 = [dict(dist_name=GNB_NRHOIF1_NAME2, parameter='a3MeasEnabled', value='rsrpAndRsrq'),
              dict(dist_name=GNB_NR_BTS_NAME2, parameter='srb3SupportEnabled', value='false')]

case4_message_list = ['1 0 0 0 1{8 [50] [[64] [53] [35]] [] [[1{0[[64] [53] []]}] []] [] []} [0(1{[52] '
                      '[[66] [57] [44]] [][ [1{0[[66] [57] []]}] [] ] })]',
                      '3 0 0 0 1{8 [50] [[50] [55] [30]] [] [[1{0[[50] [55] [30]]}] []] [] []} [0(1{[52] '
                      '[[71] [77] [30]] [][ [1{0[[71] [77] [30]]}] [] ] })]',
                      '4 0 0 0 1{8 [52] [[64] [53] [35]] [] [[1{0[[64] [53] []]}] []] [] []} [0(1{[50] '
                      '[[66] [57] [44]] [][ [1{0[[66] [57] []]}] [] ] })]',
                      '6 0 0 0 1{8 [52] [[50] [55] [30]] [] [[1{0[[50] [55] [30]]}] []] [] []} '
                      '[0(1{[50] [[71] [77] [30]] [][ [1{0[[71] [77] [30]]}] [] ] })]']

case4_signalling_list = ['SgNBAdditionRequest',
                         'SgNBAdditionRequestAcknowledge',
                         'RRCReconfigurationComplete',
                         'drx-Config: setup (1)',
                         'rrcReconfigurationComplete',
                         'measurementReport',
                         'rrcReconfiguration',
                         'rrcReconfigurationComplete',
                         'measurementReport',
                         'UEContextModificationRequest',
                         'rrcReconfiguration',
                         'rrcReconfigurationComplete']

case4_measId_list = [1, 3]

case4_counter_id_list = ['M55151C00014', 'M55151C00022', 'M55151C00024']

case5_message_list = ['1 0 0 0 1{8 [50] [[64] [53] [35]] [] [[1{0[[64] [53] []]}] []] [] []} [0(1{[52] '
                      '[[66] [57] [44]] [][ [1{0[[66] [57] []]}] [] ] })]',
                      '2 0 0 0 1{8 [50] [[107] [53] [35]] [] [[1{0[[107] [53] []]}] []] [] []} [0(1{[52] '
                      '[[66] [57] [44]] [][ [1{0[[66] [] []]}] [] ] })]',
                      '2 0 0 0 1{8 [50] [[107] [71] [35]] [] [[1{0[[107] [71] []]}] []] [] []} [0(1{[52] '
                      '[[66] [57] [44]] [][ [1{0[[66] [] []]}] [] ] })]']

case5_signalling_list = ['SgNBAdditionRequest',
                         'SgNBAdditionRequestAcknowledge',
                         'RRCReconfigurationComplete',
                         'drx-Config: setup (1)',
                         'rrcReconfigurationComplete',
                         'measurementReport',
                         'rrcReconfiguration',
                         'rrcReconfigurationComplete',
                         'measurementReport',
                         'measurementReport',
                         'UEContextModificationRequest',
                         'rrcReconfiguration',
                         'rrcReconfigurationComplete']

case5_check_message_list = ['measIdToRemoveList:', 'MeasId:', 'measIdToAddModList:', 'measId:']

case5_measId_Id1 = [['1'], ['2', '3']]
case5_measId_Id2 = [['2', '3'], ['4']]

case7_message_list = ['1 0 0 0 1{8 [50] [[64] [53] [35]] [] [[1{0[[64] [53] []]}] []] [] []} [0(1{[52] '
                      '[[66] [57] [44]] [][ [1{0[[66] [57] []]}] [] ] })]',
                      '3 0 0 0 1{8 [50] [[50] [55] [30]] [] [[1{0[[50] [55] [30]]}] []] [] []} [0(1{[52] '
                      '[[71] [77] [30]] [][ [1{0[[71] [77] [30]]}] [] ] })]',
                      '5 0 0 0 1{8 [52] [[64] [53] [35]] [] [[1{0[[64] [53] []]}] []] [] []} [0(1{[50] '
                      '[[66] [57] [44]] [][ [1{0[[66] [57] []]}] [] ] })]',
                      '7 0 0 0 1{8 [52] [[50] [55] [30]] [] [[1{0[[50] [55] [30]]}] []] [] []} '
                      '[0(1{[50] [[71] [77] [30]] [][ [1{0[[71] [77] [30]]}] [] ] })]']

case7_measId_Id1 = [['1'], ['2', '3', '4']]
case7_measId_Id2 = [['2', '3', '4'], ['5']]
case7_measId_Id3 = [['5'], ['6', '7', '8']]
case7_measId_Id4 = [['6', '7', '8'], ['9']]

case7_signalling_list = ['SgNBAdditionRequest',
                         'SgNBAdditionRequestAcknowledge',
                         'RRCReconfigurationComplete',
                         'drx-Config: setup (1)',
                         'rrcReconfigurationComplete',
                         'measurementReport',
                         'SgNBModificationRequired',
                         'rrcReconfigurationComplete',
                         'measurementReport',
                         'SgNBChangeRequired',
                         'SgNBAdditionRequest',
                         'SgNBAdditionRequestAcknowledge',
                         'SgNBReconfigurationComplete',
                         'SgNBModificationRequired',
                         'rrcReconfigurationComplete',
                         'measurementReport',
                         'SgNBModificationRequired',
                         'rrcReconfigurationComplete',
                         'measurementReport',
                         'SgNBChangeRequired',
                         'SgNBAdditionRequest',
                         'SgNBAdditionRequestAcknowledge',
                         'SgNBReconfigurationComplete',
                         'SgNBModificationRequired',
                         'rrcReconfigurationComplete']
