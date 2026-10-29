# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')

MR_BTS_NAME1 = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME1 = MR_BTS_NAME1 + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_NAME1 = 'NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_CELL_INFO = MR_BTS_NAME1 + '/NRBTS-1'
NR_CELL_INFO2 = MR_BTS_NAME1 + '/NRBTS-2'
NR_CELL_NAME1 = MR_NR_BTS_NAME1 + '/NRCELL-1'
NR1_CELL1_NRADJNRCELL = MR_NR_BTS_NAME1 + '/NRADJNRCELL-1'
NR_CELL_NAME_DELETE = MR_NR_BTS_NAME1 + '/NRMOPR_NSA-2'
NR_CELL_NAME005 = NR_CELL_NAME1 + 'NRHOIF-2.'

MR_BTS_NAME2 = 'MRBTS-' + str(tl.gnbs[1].instance_id)
MR_NR_BTS_NAME2 = MR_BTS_NAME2 + '/NRBTS-' + str(tl.gnbs[1].global_bts_id)
NR_NAME2 = 'NRBTS-' + str(tl.gnbs[1].global_bts_id)
NR_CELL_NAME2 = MR_NR_BTS_NAME2 + '/NRCELL-1'
NR2_CELL1_NRADJNRCELL = MR_NR_BTS_NAME2 + '/NRADJNRCELL-1'

MR_BTS_NAME = 'MRBTS-' + str(tl.enbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/LNBTS-' + str(tl.enbs[0].global_bts_id)
NR_NAME = 'NRBTS-' + str(tl.enbs[0].global_bts_id)
BTS_CELL_NAME = MR_NR_BTS_NAME + '/LNCEL-1'
BTS_CELL_NAME009 = MR_NR_BTS_NAME + '/LNCEL-2'

gnb1_001 = [
    dict(value='false', dist_name=NR_CELL_INFO, parameter='srb3SupportEnabled'),
    dict(value='true', dist_name=NR_CELL_INFO, parameter='actInterFreqIntraGnbMobilityNSA'),
    dict(value='true', dist_name=NR_CELL_INFO, parameter='actSPID'),
    dict(value='true', dist_name=NR_CELL_INFO, parameter='actMobilityProfile')]
gnb1_005 = [
    dict(value='true', dist_name=NR_CELL_INFO, parameter='actInterFreqIntraGnbMobilityNSA'),
    dict(value='true', dist_name=NR_CELL_INFO, parameter='actSPID'),
    dict(value='true', dist_name=NR_CELL_INFO, parameter='actMobilityProfile')]

gnb1_006 = [
    dict(value='true', dist_name=NR_CELL_INFO, parameter='actInterFreqIntraGnbMobilityNSA'),
    dict(value='false', dist_name=NR_CELL_INFO, parameter='actSPID'),
    dict(value='true', dist_name=NR_CELL_INFO, parameter='actMobilityProfile')]

gnb1_008 = [
    dict(value='true', dist_name=NR_CELL_INFO, parameter='actInterFreqIntraGnbMobilityNSA'),
    dict(value='true', dist_name=NR_CELL_INFO, parameter='actSPID'),
    dict(value='false', dist_name=NR_CELL_INFO, parameter='srb3SupportEnabled'),
    dict(value='true', dist_name=NR_CELL_INFO, parameter='actMobilityProfile')]

gnb1_009 = [
    dict(value='2073799', dist_name=NR1_CELL1_NRADJNRCELL, parameter='nrarfcn'),
    dict(value='2073691', dist_name=NR1_CELL1_NRADJNRCELL, parameter='ssbFrequency'),
    dict(value='true', dist_name=NR_CELL_INFO, parameter='actInterFreqInterGnbMobilityNSA'),
    dict(value='true', dist_name=NR_CELL_INFO, parameter='actSPID'),
    dict(value='true', dist_name=NR_CELL_INFO, parameter='srb3SupportEnabled'),
    dict(value='true', dist_name=NR_CELL_INFO, parameter='actMobilityProfile')]

gnb1_recover = [
    dict(value='2073399', dist_name=NR1_CELL1_NRADJNRCELL, parameter='nrarfcn'),
    dict(value='false', dist_name=NR_CELL_INFO, parameter='actInterFreqInterGnbMobilityNSA'),
    dict(value='false', dist_name=NR_CELL_INFO, parameter='actSPID'),
    dict(value='false', dist_name=NR_CELL_INFO, parameter='srb3SupportEnabled'),
    dict(value='false', dist_name=NR_CELL_INFO, parameter='actMobilityProfile')]

gnb2_009 = [
    dict(value='2073399', dist_name=NR2_CELL1_NRADJNRCELL, parameter='nrarfcn'),
    dict(value='2073115', dist_name=NR2_CELL1_NRADJNRCELL, parameter='ssbFrequency'),
    dict(value='true', dist_name=NR_CELL_INFO2, parameter='actInterFreqInterGnbMobilityNSA'),
    dict(value='true', dist_name=NR_CELL_INFO2, parameter='actSPID'),
    dict(value='true', dist_name=NR_CELL_INFO2, parameter='srb3SupportEnabled'),
    dict(value='true', dist_name=NR_CELL_INFO2, parameter='actMobilityProfile')]

gnb2_recover = [
    dict(value='false', dist_name=NR_CELL_INFO2, parameter='actInterFreqInterGnbMobilityNSA'),
    dict(value='false', dist_name=NR_CELL_INFO2, parameter='actSPID'),
    dict(value='false', dist_name=NR_CELL_INFO2, parameter='srb3SupportEnabled'),
    dict(value='false', dist_name=NR_CELL_INFO2, parameter='actMobilityProfile')]

enb_actEndcSpidFwd = [
    dict(value='true', dist_name=MR_NR_BTS_NAME, parameter='actEndcSpidFwd'),
    dict(value='false', dist_name=MR_NR_BTS_NAME, parameter='actDynTrigLteNrDualConnectivity'),
    dict(value='0', dist_name=BTS_CELL_NAME, parameter='defaultLnRelGnbCellId')]

enb_actEndcSpidFwd_009 = [
    dict(value='true', dist_name=MR_NR_BTS_NAME, parameter='actEndcSpidFwd'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, parameter='actSnChangeSnInit'),
    dict(value='false', dist_name=MR_NR_BTS_NAME, parameter='actDynTrigLteNrDualConnectivity'),
    dict(value='0', dist_name=BTS_CELL_NAME009, parameter='defaultLnRelGnbCellId')]
