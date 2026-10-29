from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'liu jia'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_3_GMS <I_MN_5G_RAN_IV4_LINE_HZG_3@internal.nsn.com>'
__email__ = 'jia-rebecca.liu@nokia-sbell.com'

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

_gnb1_id = str(tl.gnbs[0].instance_id)
_global1_id = str(tl.gnbs[0].global_bts_id)
# _gnb2_id = str(tl.gnbs[1].instance_id)
# _global2_id = str(tl.gnbs[1].global_bts_id)
_MRBTS1_name = 'MRBTS-' + _global1_id
_NRBTS1_name = _MRBTS1_name + '/NRBTS-' + _gnb1_id
# _MRBTS2_name = 'MRBTS-' + _global2_id
# _NRBTS2_name = _MRBTS2_name + '/NRBTS-' + _gnb2_id
_GNB1CELL2_name = _NRBTS1_name + '/NRCELL-2'
_GNB1CELL1_name = _NRBTS1_name + '/NRCELL-1'

Online_Modify_BB1002 = [
    dict(
        value='notBarred',
        dist_name=_GNB1CELL2_name,
        parameter='cellBarred'),
    dict(
        value='false',
        dist_name=_GNB1CELL2_name,
        parameter='actPrbLimForVoNrRat1'),
    dict(
        value='true',
        dist_name=_GNB1CELL2_name,
        parameter='actRat1Alloc'),
    dict(
        value='true',
        dist_name=_GNB1CELL2_name,
        parameter='actEnhancedVoNR'),
    dict(
        value='false',
        dist_name=_GNB1CELL2_name,
        parameter='actVoipPacketAggr'),
    dict(
        value='28',
        dist_name=_GNB1CELL2_name,
        parameter='dlMcsDropLimitForVoNR'),
    dict(
        value='99',
        dist_name=_GNB1CELL2_name,
        parameter='percRedSEDlRat1VoNR'),
]

Online_Modify_enable_14474 = [
    dict(
        value='true',
        dist_name=_GNB1CELL2_name,
        parameter='actPrbLimForVoNrRat1'),
]

Online_Modify_C_B2_02 = [
    dict(
        value='true',
        dist_name=_GNB1CELL1_name,
        parameter='actDcGbrPreemption'),
    dict(
        value='true',
        dist_name=_GNB1CELL2_name,
        parameter='actDcGbrPreemption'),
    dict(
        value='true',
        dist_name=_GNB1CELL1_name,
        parameter='actDcGbrService'),
    dict(
        value='true',
        dist_name=_GNB1CELL2_name,
        parameter='actDcGbrService'),
    dict(
        value='true',
        dist_name=_GNB1CELL1_name,
        parameter='actNonVoNRGbrServiceEnh'),
    dict(
        value='true',
        dist_name=_GNB1CELL2_name,
        parameter='actNonVoNRGbrServiceEnh'),
    dict(
        value='10',
        dist_name=_GNB1CELL1_name,
        parameter='maxNumOfDcGbrBearersSA'),
    dict(
        value='10',
        dist_name=_GNB1CELL2_name,
        parameter='maxNumOfDcGbrBearersSA'),
]
