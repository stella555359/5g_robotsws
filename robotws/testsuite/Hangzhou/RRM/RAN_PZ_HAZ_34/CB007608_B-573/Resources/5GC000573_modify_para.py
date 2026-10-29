# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)

MR_BTS2_NAME = 'MRBTS-' + str(tl.gnbs[1].instance_id)
MR_NR_BTS2_NAME = MR_BTS2_NAME + '/NRBTS-' + str(tl.gnbs[1].global_bts_id)

ENB_MR_BTS_NAME = 'MRBTS-' + str(tl.enbs[0].instance_id)
MR_NR_ENB_NAME = ENB_MR_BTS_NAME + '/LNBTS-' + str(tl.enbs[0].global_bts_id)

DefaultLnRelGnbCellId_enb = MR_NR_ENB_NAME + '/LNCEL-2'
DefaultLnRelGnbCellId_enb_7403 = MR_NR_ENB_NAME + '/LNCEL-1'
A3MeasEnabled_DistName_GNB1 = MR_NR_BTS_NAME + '/NRCELL-1'
A3MeasEnabled_DistName_GNB2 = MR_NR_BTS2_NAME + '/NRCELL-1'
MiNrX2cc_para = MR_NR_BTS_NAME + '/NRPMRNL-1'
MiNrX2cc_para_GNB2 = MR_NR_BTS2_NAME + '/NRPMRNL-1'

ENB_MODIFY_Parameter = [dict(dist_name=MR_NR_ENB_NAME, parameter='actSnChangeSnInit', value='true'),
                        dict(dist_name=DefaultLnRelGnbCellId_enb, parameter='defaultLnRelGnbCellId', value='0'),
                        dict(dist_name=MR_NR_ENB_NAME, parameter='actDynTrigLteNrDualConnectivity', value='false')]

ENB_MODIFY_Parameter_004 = [dict(dist_name=MR_NR_ENB_NAME, parameter='actSnChangeSnInit', value='false'),
                            dict(dist_name=DefaultLnRelGnbCellId_enb, parameter='defaultLnRelGnbCellId', value='0'),
                            dict(dist_name=MR_NR_ENB_NAME, parameter='actDynTrigLteNrDualConnectivity', value='false')]

GNB1_MODIFY_Parameter = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='actIntraFreqInterGnbMobilityNSA3x', value='true'),
     dict(dist_name=A3MeasEnabled_DistName_GNB1, parameter='a3MeasEnabled', value='rsrp'),
     dict(dist_name=A3MeasEnabled_DistName_GNB1, parameter='a5MeasEnabled', value='none'),
     dict(dist_name=MiNrX2cc_para, parameter='miNrX2CC', value='5min')]

GNB2_MODIFY_Parameter = [
     dict(dist_name=MR_NR_BTS2_NAME, parameter='actIntraFreqInterGnbMobilityNSA3x', value='true'),
     dict(dist_name=A3MeasEnabled_DistName_GNB2, parameter='a3MeasEnabled', value='rsrp'),
     dict(dist_name=A3MeasEnabled_DistName_GNB2, parameter='a5MeasEnabled', value='none'),
     dict(dist_name=MiNrX2cc_para_GNB2, parameter='miNrX2CC', value='5min')]

GNB2_MODIFY_Parameter_007 = [dict(dist_name=A3MeasEnabled_DistName_GNB2, parameter='actCDrx', value='true')]

ENB_MODIFY_Parameter_7403 = [
    dict(dist_name=MR_NR_ENB_NAME, parameter='actSnChangeSnInit', value='true'),
    dict(dist_name=DefaultLnRelGnbCellId_enb_7403, parameter='defaultLnRelGnbCellId', value='3'),
    dict(dist_name=MR_NR_ENB_NAME, parameter='actDynTrigLteNrDualConnectivity', value='false')]

ENB_MODIFY_Parameter_7403_004 = [
    dict(dist_name=MR_NR_ENB_NAME, parameter='actSnChangeSnInit', value='false'),
    dict(dist_name=DefaultLnRelGnbCellId_enb_7403, parameter='defaultLnRelGnbCellId', value='3'),
    dict(dist_name=MR_NR_ENB_NAME, parameter='actDynTrigLteNrDualConnectivity', value='false')]
