import os
from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
CFG_DIR = os.path.dirname(os.path.abspath(__file__))

MR_BTS_NAME_GNB = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME_GNB = MR_BTS_NAME_GNB + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
MR_NR_BTS_NAME_NRDRB = MR_NR_BTS_NAME_GNB + '/NRDRB-4'

MR_BTS_NAME_ENB1 = 'MRBTS-' + str(tl.enbs[0].instance_id)
MR_NR_BTS_NAME_ENB1 = MR_BTS_NAME_ENB1 + '/LNBTS-' + str(tl.enbs[0].global_bts_id)

MR_BTS_NAME_ENB2 = 'MRBTS-' + str(tl.enbs[1].instance_id)
MR_NR_BTS_NAME_ENB2 = MR_BTS_NAME_ENB2 + '/LNBTS-' + str(tl.enbs[1].global_bts_id)

GNB_Common_Parameter_001 = [
    dict(dist_name=MR_NR_BTS_NAME_GNB, parameter='actInterMeNBMobility', value='false')]

ENB1_Common_Parameter_001 = [
    dict(dist_name=MR_NR_BTS_NAME_ENB1, parameter='actHoWoSnChg', value='intraEnbAndX2HoEnabled')]

ENB2_Common_Parameter_001 = [
    dict(dist_name=MR_NR_BTS_NAME_ENB2, parameter='actHoWoSnChg', value='intraEnbAndX2HoEnabled')]

GNB_Common_Parameter_001_reconvery = [
    dict(dist_name=MR_NR_BTS_NAME_GNB, parameter='actInterMeNBMobility', value='true')]

GNB_Common_Parameter_007 = [
    dict(dist_name=MR_NR_BTS_NAME_GNB, parameter='actDlDataForwardingX2', value='true'),
    dict(dist_name=MR_NR_BTS_NAME_NRDRB, parameter='nsaDrbParam',
         value=[{"actPrioritizeX2AfterInactivity": 'True',
                 "actX2DuplicateTxNSA3x": 'False',
                 "dlDataSplitBufferBuildUpThreshold": '5',
                 "dlDataSplitBufferBuildUpThresholdPrioritizeX2": '5',
                 "dlDataSplitGainThreshold": 5,
                 "dlDataSplitMode": 'dlOverF1UX2U',
                 "inactivityThresholdForPrioritizeX2": '300',
                 "inactivityThresholdForRestartPrioritizeX2": '100',
                 "initialDLTrafficRouting": 'initDLoverX2U',
                 "nsa3xBearerAllowed": 'True',
                 "prioritizeX2Period": '500',
                 "ulDataPath": 'ulOverLteNr_PrimaryPathOverNr',
                 "ulDataSplitThreshold": 'b102400'}])
]

GNB_Common_Parameter_103 = [
    dict(dist_name=MR_NR_BTS_NAME_GNB, parameter='actInterMeNBMobility', value='true'),
    dict(dist_name=MR_NR_BTS_NAME_GNB, parameter='actDlDataForwardingX2', value='true'),
    dict(dist_name=MR_NR_BTS_NAME_NRDRB, parameter='nsaDrbParam',
         value=[{"actPrioritizeX2AfterInactivity": 'True',
                 "actX2DuplicateTxNSA3x": 'False',
                 "dlDataSplitBufferBuildUpThreshold": '5',
                 "dlDataSplitBufferBuildUpThresholdPrioritizeX2": '5',
                 "dlDataSplitGainThreshold": '5',
                 "dlDataSplitMode": 'dlOverF1U',
                 "inactivityThresholdForPrioritizeX2": '300',
                 "inactivityThresholdForRestartPrioritizeX2": '100',
                 "initialDLTrafficRouting": 'initDLoverX2U',
                 "nsa3xBearerAllowed": 'True',
                 "prioritizeX2Period": '500',
                 "ulDataPath": 'ulOverNr',
                 "ulDataSplitThreshold": 'infinity'}])
]
