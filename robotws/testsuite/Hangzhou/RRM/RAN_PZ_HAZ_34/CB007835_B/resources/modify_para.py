# -*- coding: utf-8 -*
import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
GNB_NRDRB4 = MR_NR_BTS_NAME + '/NRDRB-4'

MODIFY_Parameter_729 = [
     dict(dist_name=GNB_NRDRB4, parameter='nsaDrbParam',
          value=[{"dlDataSplitMode": 'dlOverX2U',
                  "ulDataPath": 'ulOverLte',
                  "actPrioritizeX2AfterInactivity": 'true',
                  "actX2DuplicateTxNSA3x": 'false',
                  "dlDataSplitBufferBuildUpThreshold": '5',
                  "dlDataSplitBufferBuildUpThresholdPrioritizeX2": '5',
                  "dlDataSplitGainThreshold": '5',
                  "dlNumOfCongOrGainDdds": '2',
                  "inactivityThresholdForPrioritizeX2": '300',
                  "inactivityThresholdForRestartPrioritizeX2": '100',
                  "initialDLTrafficRouting": 'initDLoverX2U',
                  "nsa3xBearerAllowed": 'true',
                  "prioritizeX2Period": '500',
                  "ulDataSplitThreshold": 'infinity'}])]

Reconver_Parameter_729 = [
     dict(dist_name=GNB_NRDRB4, parameter='nsaDrbParam',
          value=[{"dlDataSplitMode": 'dlOverF1U',
                  "ulDataPath": 'ulOverNr',
                  "actPrioritizeX2AfterInactivity": 'true',
                  "actX2DuplicateTxNSA3x": 'false',
                  "dlDataSplitBufferBuildUpThreshold": '5',
                  "dlDataSplitBufferBuildUpThresholdPrioritizeX2": '5',
                  "dlDataSplitGainThreshold": '5',
                  "dlNumOfCongOrGainDdds": '2',
                  "inactivityThresholdForPrioritizeX2": '300',
                  "inactivityThresholdForRestartPrioritizeX2": '100',
                  "initialDLTrafficRouting": 'initDLoverX2U',
                  "nsa3xBearerAllowed": 'true',
                  "prioritizeX2Period": '500',
                  "ulDataSplitThreshold": 'infinity'}])]

MODIFY_Parameter_738 = [
     dict(dist_name=GNB_NRDRB4, parameter='nsaDrbParam',
          value=[{"dlDataSplitMode": 'dlOverX2U',
                  "ulDataPath": 'ulOverLte',
                  "actPrioritizeX2AfterInactivity": 'true',
                  "actX2DuplicateTxNSA3x": 'false',
                  "dlDataSplitBufferBuildUpThreshold": '5',
                  "dlDataSplitBufferBuildUpThresholdPrioritizeX2": '5',
                  "dlDataSplitGainThreshold": '5',
                  "dlNumOfCongOrGainDdds": '2',
                  "inactivityThresholdForPrioritizeX2": '300',
                  "inactivityThresholdForRestartPrioritizeX2": '100',
                  "initialDLTrafficRouting": 'initDLoverX2U',
                  "nsa3xBearerAllowed": 'true',
                  "prioritizeX2Period": '500',
                  "ulDataSplitThreshold": 'infinity'}])]

Reconver_Parameter_738 = [
     dict(dist_name=GNB_NRDRB4, parameter='nsaDrbParam',
          value=[{"dlDataSplitMode": 'dlOverF1U',
                  "ulDataPath": 'ulOverNr',
                  "actPrioritizeX2AfterInactivity": 'true',
                  "actX2DuplicateTxNSA3x": 'false',
                  "dlDataSplitBufferBuildUpThreshold": '5',
                  "dlDataSplitBufferBuildUpThresholdPrioritizeX2": '5',
                  "dlDataSplitGainThreshold": '5',
                  "dlNumOfCongOrGainDdds": '2',
                  "inactivityThresholdForPrioritizeX2": '300',
                  "inactivityThresholdForRestartPrioritizeX2": '100',
                  "initialDLTrafficRouting": 'initDLoverX2U',
                  "nsa3xBearerAllowed": 'true',
                  "prioritizeX2Period": '500',
                  "ulDataSplitThreshold": 'infinity'}])]

MODIFY_Parameter_disable_GnbInitRlf = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='actGnbInitRlf', value='false')]

MODIFY_Parameter_enable_GnbInitRlf = [
     dict(dist_name=MR_NR_BTS_NAME, parameter='actGnbInitRlf', value='true')]
