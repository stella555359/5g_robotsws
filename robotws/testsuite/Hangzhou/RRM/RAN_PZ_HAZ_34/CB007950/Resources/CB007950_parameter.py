# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_BTS_NRCELL = MR_NR_BTS_NAME + '/NRCELL-1'
MR_NR_BTS_NRHOIF = MR_NR_BTS_NRCELL + '/NRHOIF-1'


GNB_MODIFY_Parameter_CSI_320 = [dict(dist_name=MR_NR_BTS_NRCELL, parameter='periodicCsiAcquisition',
                                     value=[{"csiReportPeriodicity": 'slots320'}])]


GNB_MODIFY_Parameter_CSI_160 = [dict(dist_name=MR_NR_BTS_NRCELL, parameter='periodicCsiAcquisition',
                                     value=[{"csiReportPeriodicity": 'slots160'}])]


GNB_MODIFY_Parameter_CSI_80 = [dict(dist_name=MR_NR_BTS_NRCELL, parameter='periodicCsiAcquisition',
                                    value=[{"csiReportPeriodicity": 'slots80'}])]


GNB_MODIFY_Parameter_CSI_40 = [dict(dist_name=MR_NR_BTS_NRCELL, parameter='periodicCsiAcquisition',
                                    value=[{"csiReportPeriodicity": 'slots40'}])]
