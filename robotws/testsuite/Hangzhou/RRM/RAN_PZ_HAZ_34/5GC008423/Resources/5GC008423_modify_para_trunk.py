# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_BTS_NRCELL = MR_NR_BTS_NAME + '/NRCELL-1'
MR_NR_BTS1_NRCELL = 'MRBTS-' + str(tl.enbs[1].instance_id) + '/NRBTS-' + str(tl.enbs[1].global_bts_id) + '/NRCELL-1'
MR_NR_BTS_NRHOIF = MR_NR_BTS_NRCELL + '/NRHOIF-1'
# MR_NR_BTS_NRCELLGRP = MR_NR_BTS_NAME + '/NRCELLGRP-0'
MR_NR_BTS_NRHOIF = MR_NR_BTS_NRCELL + '/NRHOIF-1'


swconfig_modify_10 = ['0x580164=0', '0x580163=0']

swconfig_modify_14 = ['0x580011=0', '0x5800015=-100', '0x5800023=50', '0x580024=0']

swconfig_modify_15 = ['0x580012=0', '0x580016=-100', '0x58010F=0', '0x580032=0']

GNB_Common_Parameter = [
    dict(dist_name=MR_NR_BTS_NAME, parameter='actCarrierAggregation', value='false'),
    dict(dist_name=MR_NR_BTS_NRHOIF, parameter='numberOfTransmittedSsBlocks', value='1 beam'),
    dict(dist_name=MR_NR_BTS_NRCELL, parameter='beamSet',
         value=[{"basicBeamSet": 'beamSet_1',
                 "beamSetInUse": 'beamSet_1',
                 "leftEdgeAngle": '60',
                 "lowerEdgeAngle": '120',
                 "nrBtsBeamRefinementP2": 'false',
                 "rightEdgeAngle": '60',
                 "upperEdgeAngle": '60'}])
    ]

GNB_MODIFY_Parameter_01 = [
    dict(dist_name=MR_NR_BTS_NRCELL, parameter='actBeamforming', value='false'),
    dict(dist_name=MR_NR_BTS_NRCELL, parameter='prachConfigurationIndex', value='149'),
    dict(dist_name=MR_NR_BTS_NRHOIF, parameter='ssBurstSetPeriod', value='10'),
    dict(dist_name=MR_NR_BTS_NRCELL, parameter='tddFrameStructure',
         value=[{"frameStructureType": 'semiStatic',
                 "guardPeriodLength": '2Symbols',
                 "ulDlDataSlotRatio": '3/7'}])
    ]

GNB_MODIFY_Parameter_02 = [
    dict(dist_name=MR_NR_BTS_NRCELL, parameter='actBeamforming', value='false'),
    dict(dist_name=MR_NR_BTS_NRCELL, parameter='prachConfigurationIndex', value='160'),
    dict(dist_name=MR_NR_BTS_NRHOIF, parameter='ssBurstSetPeriod', value='20'),
    dict(dist_name=MR_NR_BTS_NRCELL, parameter='tddFrameStructure',
         value=[{"frameStructureType": 'tdLte',
                 "guardPeriodLength": '4Symbols',
                 "ulDlDataSlotRatio": '3/7',
                 "lteToNrFrameShift": '3ms',
                 "tdLteUlDlConfig": 'tdLteConfig2'}])
    ]

GNB_MODIFY_Parameter_03 = [
    dict(dist_name=MR_NR_BTS_NRCELL, parameter='actBeamforming', value='false'),
    dict(dist_name=MR_NR_BTS_NRCELL, parameter='prachConfigurationIndex', value='98'),
    dict(dist_name=MR_NR_BTS_NRHOIF, parameter='ssBurstSetPeriod', value='20'),
    dict(dist_name=MR_NR_BTS_NRCELL, parameter='tddFrameStructure',
         value=[{"frameStructureType": 'semiStatic',
                 "guardPeriodLength": '2Symbols',
                 "ulDlDataSlotRatio": '1/4'}])
    ]

GNB_MODIFY_Parameter_04 = [
    dict(dist_name=MR_NR_BTS_NRCELL, parameter='actBeamforming', value='false'),
    dict(dist_name=MR_NR_BTS_NRCELL, parameter='prachConfigurationIndex', value='190'),
    dict(dist_name=MR_NR_BTS_NRHOIF, parameter='ssBurstSetPeriod', value='20'),
    dict(dist_name=MR_NR_BTS_NRCELL, parameter='tddFrameStructure',
         value=[{"frameStructureType": 'semiStatic',
                 "guardPeriodLength": '2Symbols',
                 "ulDlDataSlotRatio": '1/4'}])
    ]

GNB_MODIFY_Parameter_05_A2 = [dict(dist_name=MR_NR_BTS_NRCELL, parameter='prachConfigurationIndex', value='98')]

GNB_MODIFY_Parameter_05_B4 = [dict(dist_name=MR_NR_BTS_NRCELL, parameter='prachConfigurationIndex', value='160')]

GNB_MODIFY_Parameter_05_B4_2 = [dict(dist_name=MR_NR_BTS_NRCELL, parameter='prachConfigurationIndex', value='148')]

GNB_MODIFY_Parameter_10 = [dict(dist_name=MR_NR_BTS_NAME, parameter='actTimeAlignExtension', value='true'),
                           dict(dist_name=MR_NR_BTS_NAME, parameter='actUeInitRlf', value='false')]

GNB_MODIFY_Parameter_14 = [dict(dist_name=MR_NR_BTS_NAME, parameter='actEnhancedLinkAdaptation', value='false'),
                           dict(dist_name=MR_NR_BTS_NRCELL, parameter='dllaIniMcs', value='3'),
                           dict(dist_name=MR_NR_BTS_NRCELL, parameter='actDl256Qam', value='true'),
                           dict(dist_name=MR_NR_BTS_NRCELL, parameter='dllaDeltaCqiStepdown', value='10')]

GNB_MODIFY_Parameter_14_1 = [dict(dist_name=MR_NR_BTS_NAME, parameter='actEnhancedLinkAdaptation', value='true')]

GNB_MODIFY_Parameter_15 = [dict(dist_name=MR_NR_BTS_NAME, parameter='actEnhancedLinkAdaptation', value='false'),
                           dict(dist_name=MR_NR_BTS_NRCELL, parameter='ullaDeltaSinrMax', value='10'),
                           dict(dist_name=MR_NR_BTS_NRCELL, parameter='ullaDeltaSinrStepdown', value='10'),
                           dict(dist_name=MR_NR_BTS_NRCELL, parameter='ullaBlerTarget', value='50')]
