# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_BTS_NECELL1_DistName_GNB = MR_NR_BTS_NAME + '/NRCELL-1'

GNB_MODIFY_Parameter_ulMimoMode_2m2 = [
     dict(dist_name=MR_NR_BTS_NECELL1_DistName_GNB, parameter='ulMimoMode',
          value='Closed loop Spatial Multiplexing (2x2)')]

GNB_MODIFY_Parameter_actUlOpenLoopPwrCtrl_p0NominalSrs = [
     dict(dist_name=MR_NR_BTS_NECELL1_DistName_GNB, parameter='ulPowerControlCommon',
          value=[{"actUlOpenLoopPwrCtrl": 'true',
                  "p0NominalSrs": '-96',
                  "alpha": 'al1',
                  "alphaSrs": 'alpha1',
                  "p0NominalPucch": '-90',
                  "p0NominalPucchF1F3": '-108',
                  "p0NominalPusch": '-96',
                  "pucchF1DeltaF": '-10',
                  "pucchF3DeltaF": '0'}])]

GNB_RECOVERY_Parameter_actUlOpenLoopPwrCtrl_p0NominalSrs = [
     dict(dist_name=MR_NR_BTS_NECELL1_DistName_GNB, parameter='ulPowerControlCommon',
          value=[{"actUlOpenLoopPwrCtrl": 'true',
                  "p0NominalSrs": '-80',
                  "alpha": 'al1',
                  "alphaSrs": 'alpha1',
                  "p0NominalPucch": '-90',
                  "p0NominalPucchF1F3": '-108',
                  "p0NominalPusch": '-96',
                  "pucchF1DeltaF": '-10',
                  "pucchF3DeltaF": '0'}])]

GNB_MODIFY_Parameter_actUlOpenLoopPwrCtrl_actUlClosedLoopPwrCtrl = [
     dict(dist_name=MR_NR_BTS_NECELL1_DistName_GNB, parameter='actUlClosedLoopPwrCtrl', value='disabled'),
     dict(dist_name=MR_NR_BTS_NECELL1_DistName_GNB, parameter='ulPowerControlCommon',
          value=[{"actUlOpenLoopPwrCtrl": 'false',
                  "p0NominalSrs": '-96',
                  "alpha": 'al1',
                  "alphaSrs": 'alpha1',
                  "p0NominalPucch": '-90',
                  "p0NominalPucchF1F3": '-108',
                  "p0NominalPusch": '-96',
                  "pucchF1DeltaF": '-10',
                  "pucchF3DeltaF": '0'}])]

GNB_RECOVERY_Parameter_actUlOpenLoopPwrCtrl_actUlClosedLoopPwrCtrl = [
     dict(dist_name=MR_NR_BTS_NECELL1_DistName_GNB, parameter='actUlClosedLoopPwrCtrl', value='pucchPuschSrs'),
     dict(dist_name=MR_NR_BTS_NECELL1_DistName_GNB, parameter='ulPowerControlCommon',
          value=[{"actUlOpenLoopPwrCtrl": 'true',
                  "p0NominalSrs": '-96',
                  "alpha": 'al1',
                  "alphaSrs": 'alpha1',
                  "p0NominalPucch": '-90',
                  "p0NominalPucchF1F3": '-108',
                  "p0NominalPusch": '-96',
                  "pucchF1DeltaF": '-10',
                  "pucchF3DeltaF": '0'}])]
