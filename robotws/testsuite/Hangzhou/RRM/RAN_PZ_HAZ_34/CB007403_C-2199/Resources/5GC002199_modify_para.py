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

DefaultLnRelGnbCellId_enb = MR_NR_ENB_NAME + '/LNCEL-1'
PUCCH_ENB = DefaultLnRelGnbCellId_enb + '/LNCEL_FDD-0'
A3MeasEnabled_DistName_GNB1 = MR_NR_BTS_NAME + '/NRCELL-1'
A3MeasEnabled_DistName_GNB1_2 = MR_NR_BTS_NAME + '/NRCELL-1/NRHOIF-1'
A3MeasEnabled_DistName_GNB1_cell2 = MR_NR_BTS_NAME + '/NRCELL-2'
A3MeasEnabled_DistName_GNB1_cell2_2 = MR_NR_BTS_NAME + '/NRCELL-2/NRHOIF-1'
A3MeasEnabled_DistName_GNB2 = MR_NR_BTS2_NAME + '/NRCELL-1'
A3MeasEnabled_DistName_GNB2_2 = MR_NR_BTS2_NAME + '/NRCELL-1/NRHOIF-1'
MiNrX2cc_para = MR_NR_BTS_NAME + '/NRPMRNL-1'
MiNrX2cc_para_GNB2 = MR_NR_BTS2_NAME + '/NRPMRNL-1'
Nrarfcn_para = MR_NR_BTS_NAME + '/NRADJNRCELL-1'

ENB_MODIFY_Parameter = [
     dict(dist_name=MR_NR_ENB_NAME, parameter='actDynTrigLteNrDualConnectivity', value='true'),
     dict(dist_name=MR_NR_ENB_NAME, parameter='actMeasGapCoordEnDc', value='eNB and SgNB initiated'),
     dict(dist_name=MR_NR_ENB_NAME, parameter='actDrxCoordEnDc', value='basic DRX and SgNB initiated'),
     dict(dist_name=MR_NR_ENB_NAME, parameter='actMeasGapIfEnDc', value='true'),
     dict(dist_name=DefaultLnRelGnbCellId_enb, parameter='actDrxDuringMeasGap', value='true'),
     dict(dist_name=PUCCH_ENB, parameter='actAutoPucchAlloc', value='true'),
     dict(dist_name=MR_NR_ENB_NAME, parameter='actSnChangeSnInit', value='true'),
     dict(dist_name=DefaultLnRelGnbCellId_enb, parameter='defaultLnRelGnbCellId', value='3')
]

GNB1_MODIFY_Parameter = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='actInterFreqInterGnbMobilityNSA', value='true'),
     dict(dist_name=MiNrX2cc_para, parameter='miNrX2CC', value='15min'),
     dict(dist_name=A3MeasEnabled_DistName_GNB1, parameter='actCDrx', value='true'),
     dict(dist_name=A3MeasEnabled_DistName_GNB1_cell2, parameter='actCDrx', value='true'),
     dict(dist_name=A3MeasEnabled_DistName_GNB1, parameter='a3MeasEnabled', value='none'),
     dict(dist_name=A3MeasEnabled_DistName_GNB1_2, parameter='a3MeasEnabled', value='rsrp'),
     dict(dist_name=A3MeasEnabled_DistName_GNB1_cell2, parameter='a3MeasEnabled', value='none'),
     dict(dist_name=A3MeasEnabled_DistName_GNB1, parameter='a5MeasEnabled', value='none'),
     dict(dist_name=A3MeasEnabled_DistName_GNB1_2, parameter='a5MeasEnabled', value='none'),
     dict(dist_name=A3MeasEnabled_DistName_GNB1, parameter='a2MeashoEnabled', value='rsrp'),
     dict(dist_name=A3MeasEnabled_DistName_GNB1, parameter='a1MeashoEnabled', value='rsrp'),
     dict(dist_name=Nrarfcn_para, parameter='nrarfcn', value='2073799')
]

GNB2_MODIFY_Parameter = [
     dict(dist_name=MR_NR_BTS2_NAME, parameter='actInterFreqInterGnbMobilityNSA', value='true'),
     dict(dist_name=MiNrX2cc_para_GNB2, parameter='miNrX2CC', value='15min'),
     dict(dist_name=A3MeasEnabled_DistName_GNB2, parameter='actCDrx', value='true'),
     dict(dist_name=A3MeasEnabled_DistName_GNB2, parameter='a3MeasEnabled', value='none'),
     dict(dist_name=A3MeasEnabled_DistName_GNB2_2, parameter='a3MeasEnabled', value='rsrp'),
     dict(dist_name=A3MeasEnabled_DistName_GNB2, parameter='a5MeasEnabled', value='none'),
     dict(dist_name=A3MeasEnabled_DistName_GNB2_2, parameter='a5MeasEnabled', value='none'),
     dict(dist_name=A3MeasEnabled_DistName_GNB2, parameter='a2MeashoEnabled', value='rsrp'),
     dict(dist_name=A3MeasEnabled_DistName_GNB2, parameter='a1MeashoEnabled', value='rsrp'),
     dict(dist_name=A3MeasEnabled_DistName_GNB2, parameter='gscnOrSsPbchArfcn', value='22454'),
     dict(dist_name=A3MeasEnabled_DistName_GNB2, parameter='nrarfcn', value='2073799')
]

GNB1_MODIFY_Parameter_001 = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='actInterFreqIntraGnbMobilityNSA', value='true'),
     dict(dist_name=MR_NR_BTS_NAME, parameter='srb3SupportEnabled', value='true'),
     dict(dist_name=A3MeasEnabled_DistName_GNB1_2, parameter='a3MeasEnabled', value='rsrp'),
     dict(dist_name=A3MeasEnabled_DistName_GNB1_cell2_2, parameter='a3MeasEnabled', value='rsrp')
     ]

GNB1_MODIFY_Parameter_003 = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='srb3SupportEnabled', value='false')
]

GNB2_MODIFY_Parameter_003 = [
     dict(dist_name=MR_NR_BTS2_NAME, parameter='srb3SupportEnabled', value='false')
]

GNB1_MODIFY_Parameter_005 = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='actDataDuplicationForMobility', value='true'),
     dict(dist_name=MR_NR_BTS_NAME, parameter='srb3SupportEnabled', value='true'),
     dict(dist_name=A3MeasEnabled_DistName_GNB1, parameter='a1MeashoEnabled', value='rsrpCombined')
]

GNB2_MODIFY_Parameter_005 = [
     dict(dist_name=MR_NR_BTS2_NAME, parameter='actDataDuplicationForMobility', value='true'),
     dict(dist_name=MR_NR_BTS2_NAME, parameter='srb3SupportEnabled', value='true'),
     dict(dist_name=A3MeasEnabled_DistName_GNB2, parameter='a1MeashoEnabled', value='rsrpCombined')
]

GNB1_MODIFY_Parameter_007 = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='actDataDuplicationForMobility', value='true'),
     dict(dist_name=MR_NR_BTS_NAME, parameter='srb3SupportEnabled', value='false'),
     dict(dist_name=A3MeasEnabled_DistName_GNB1_2, parameter='a3MeasEnabled', value='rsrpAndRsrq')
]

GNB2_MODIFY_Parameter_007 = [
     dict(dist_name=MR_NR_BTS2_NAME, parameter='actDataDuplicationForMobility', value='true'),
     dict(dist_name=MR_NR_BTS2_NAME, parameter='srb3SupportEnabled', value='false'),
     dict(dist_name=A3MeasEnabled_DistName_GNB2_2, parameter='a3MeasEnabled', value='rsrpAndRsrq')
]

ENB_MODIFY_Parameter_recover = [
     dict(dist_name=MR_NR_ENB_NAME, parameter='actDynTrigLteNrDualConnectivity', value='false')
]
