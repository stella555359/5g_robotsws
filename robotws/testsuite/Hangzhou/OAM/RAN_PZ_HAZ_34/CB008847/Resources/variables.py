from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'jiang johnny'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_7_GMS <I_MN_5G_RAN_IV4_LINE_HZG_7@internal.nsn.com>'
__email__ = 'johnny.1.jiang@nokia-sbell.com'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

PARAMS_TO_MODIFY_8847_A_2 = [
    dict(value='80', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-3",
         parameter='maxNumOfUsersPerNRCell'),
    dict(value='slots80', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='srPeriodicity'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-3",
         parameter='numOfRadioResReservForEmergency'),
]

PARAMS_TO_MODIFY_8847_A_2_X = [
    dict(value='80', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-3",
         parameter='maxNumOfUsersNRCell'),
    dict(value='slots80', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='srPeriodicity'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-3",
         parameter='numOfRadioResReservForEmergency'),
]

PARAMS_TO_MODIFY_8847_A_3 = [
    dict(value='80', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-3",
         parameter='maxNumOfUsersPerNRCell'),
    dict(value=[dict(csiReportPeriodicity='slots80')], dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='periodicCsiAcquisition'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-3",
         parameter='numOfRadioResReservForEmergency'),
]

PARAMS_TO_MODIFY_8847_A_3_X = [
    dict(value='80', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-3",
         parameter='maxNumOfUsersNRCell'),
    dict(value=[dict(csiReportPeriodicity='slots80')], dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='periodicCsiAcquisition'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-3",
         parameter='numOfRadioResReservForEmergency'),
]

PARAMS_TO_MODIFY_8847_C_232 = [
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-1", parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-2", parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-3", parameter='numOfRadioResReservForEmergency'),
]

PARAMS_TO_MODIFY_8847_C_341 = [
    dict(value='30', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='maxNumOfUsersPerNRCell'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='actEmergencyCall'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-3",
         parameter='numOfRadioResReservForEmergency'),
]

PARAMS_TO_MODIFY_8847_C_341_X = [
    dict(value='30', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='maxNumOfUsersNRCell'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='actEmergencyCall'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-3",
         parameter='numOfRadioResReservForEmergency'),
]

PARAMS_TO_MODIFY_8847_C_421 = [
    dict(value='40', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='maxNumOfUsersPerNRCell'),
    dict(value='40', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='maxNumOfUsersPerNRCell'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='numOfRadioResReservForEmergency'),
]

PARAMS_TO_MODIFY_8847_C_421_X = [
    dict(value='40', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='maxNumOfUsersNRCell'),
    dict(value='40', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='maxNumOfUsersNRCell'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='numOfRadioResReservForEmergency'),
]

PARAMS_TO_MODIFY_8847_C_511 = [
    dict(value='blind', dist_name='NRBTS-860' + "/NRCELL-1" + "/NRREL-1", parameter='sCellAdditionMethod'),
    dict(value='blind', dist_name='NRBTS-860' + "/NRCELL-2" + "/NRREL-1", parameter='sCellAdditionMethod'),
]

PARAMS_TO_MODIFY_8847_F_141 = [
    dict(value='true', dist_name='NRBTS-860' + "/NRCELL-1", parameter='actAdaptiveSr'),
    dict(value='true', dist_name='NRBTS-860' + "/NRCELL-2", parameter='actAdaptiveSr'),
    dict(value='slots10', dist_name='NRBTS-860' + "/NRCELL-1", parameter='srPeriodicityMin'),
    dict(value='slots10', dist_name='NRBTS-860' + "/NRCELL-2", parameter='srPeriodicityMin'),
    dict(value='80', dist_name='NRBTS-860' + "/NRCELL-1", parameter='adaptiveSrLoadThresholdUp'),
    dict(value='80', dist_name='NRBTS-860' + "/NRCELL-2", parameter='adaptiveSrLoadThresholdUp'),
    dict(value='40', dist_name='NRBTS-860' + "/NRCELL-1", parameter='adaptiveSrLoadThresholdDown'),
    dict(value='40', dist_name='NRBTS-860' + "/NRCELL-2", parameter='adaptiveSrLoadThresholdDown'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-1", parameter='lowLatencyReservation'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-2", parameter='lowLatencyReservation'),
    dict(value='slots40', dist_name='NRBTS-860' + "/NRCELL-1", parameter='preferredVoNrSrPeriod'),
    dict(value='slots40', dist_name='NRBTS-860' + "/NRCELL-2", parameter='preferredVoNrSrPeriod'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-1", parameter='vonrReservation'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-2", parameter='vonrReservation'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-1", parameter='adaptiveSrBlockingMinimization'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-2", parameter='adaptiveSrBlockingMinimization'),
]

PARAMS_TO_MODIFY_8847_F_142 = [
    dict(value='true', dist_name='NRBTS-860' + "/NRCELL-1", parameter='actAdaptiveSr'),
    dict(value='true', dist_name='NRBTS-860' + "/NRCELL-2", parameter='actAdaptiveSr'),
    dict(value='slots10', dist_name='NRBTS-860' + "/NRCELL-1", parameter='srPeriodicityMin'),
    dict(value='slots10', dist_name='NRBTS-860' + "/NRCELL-2", parameter='srPeriodicityMin'),
    dict(value='80', dist_name='NRBTS-860' + "/NRCELL-1", parameter='adaptiveSrLoadThresholdUp'),
    dict(value='80', dist_name='NRBTS-860' + "/NRCELL-2", parameter='adaptiveSrLoadThresholdUp'),
    dict(value='40', dist_name='NRBTS-860' + "/NRCELL-1", parameter='adaptiveSrLoadThresholdDown'),
    dict(value='40', dist_name='NRBTS-860' + "/NRCELL-2", parameter='adaptiveSrLoadThresholdDown'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-1", parameter='lowLatencyReservation'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-2", parameter='lowLatencyReservation'),
    dict(value='slots40', dist_name='NRBTS-860' + "/NRCELL-1", parameter='preferredVoNrSrPeriod'),
    dict(value='slots40', dist_name='NRBTS-860' + "/NRCELL-2", parameter='preferredVoNrSrPeriod'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-1", parameter='vonrReservation'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-2", parameter='vonrReservation'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-1", parameter='adaptiveSrBlockingMinimization'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-2", parameter='adaptiveSrBlockingMinimization'),
]

PARAMS_TO_MODIFY_8847_F_143 = [
    dict(value='true', dist_name='NRBTS-860' + "/NRCELL-1", parameter='actAdaptiveSr'),
    dict(value='true', dist_name='NRBTS-860' + "/NRCELL-2", parameter='actAdaptiveSr'),
    dict(value='slots10', dist_name='NRBTS-860' + "/NRCELL-1", parameter='srPeriodicityMin'),
    dict(value='slots10', dist_name='NRBTS-860' + "/NRCELL-2", parameter='srPeriodicityMin'),
    dict(value='80', dist_name='NRBTS-860' + "/NRCELL-1", parameter='adaptiveSrLoadThresholdUp'),
    dict(value='80', dist_name='NRBTS-860' + "/NRCELL-2", parameter='adaptiveSrLoadThresholdUp'),
    dict(value='40', dist_name='NRBTS-860' + "/NRCELL-1", parameter='adaptiveSrLoadThresholdDown'),
    dict(value='40', dist_name='NRBTS-860' + "/NRCELL-2", parameter='adaptiveSrLoadThresholdDown'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-1", parameter='lowLatencyReservation'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-2", parameter='lowLatencyReservation'),
    dict(value='slots40', dist_name='NRBTS-860' + "/NRCELL-1", parameter='preferredVoNrSrPeriod'),
    dict(value='slots40', dist_name='NRBTS-860' + "/NRCELL-2", parameter='preferredVoNrSrPeriod'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-1", parameter='vonrReservation'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-2", parameter='vonrReservation'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-1", parameter='adaptiveSrBlockingMinimization'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-2", parameter='adaptiveSrBlockingMinimization'),
]

PARAMS_TO_MODIFY_8847_G_341 = [
    dict(value='false', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='actEmergencyCall'),
    dict(value='30', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='maxNumOfUsersPerNRCell'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-3",
         parameter='numOfRadioResReservForEmergency'),
]

PARAMS_TO_MODIFY_8847_G_341_X = [
    dict(value='false', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-1",
         parameter='actEmergencyCall'),
    dict(value='30', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-2",
         parameter='maxNumOfUsersNRCell'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[0].instance_id}' + "/NRCELL-3",
         parameter='numOfRadioResReservForEmergency'),
]

PARAMS_TO_MODIFY_8847_J_11 = [
    dict(value='true', dist_name='NRBTS-860', parameter='actUserPreemption'),
    dict(value='true', dist_name='NRBTS-860', parameter='actDrbPreemption'),
    dict(value='1', dist_name='NRBTS-860', parameter='maxNumOfPreemptions'),
    dict(value='false', dist_name='NRBTS-860' + "/NRCELL-1", parameter='allowEmergencyReservForTempUse'),
    dict(value='false', dist_name='NRBTS-860' + "/NRCELL-2", parameter='allowEmergencyReservForTempUse'),
    dict(value='1', dist_name='NRBTS-860' + "/NRCELL-1", parameter='numOfRadioResReservForTempUse'),
    dict(value='1', dist_name='NRBTS-860' + "/NRCELL-2", parameter='numOfRadioResReservForTempUse'),
    dict(value='true', dist_name='NRBTS-860' + "/NRCELL-1", parameter='preferNsaPreemption'),
    dict(value='true', dist_name='NRBTS-860' + "/NRCELL-2", parameter='preferNsaPreemption'),
    dict(value='4', dist_name='NRBTS-860' + "/NRDU-1", parameter='numOfDrbsReservForTempUse'),
]

PARAMS_TO_MODIFY_8847_J_12 = [
    dict(value='true', dist_name='NRBTS-860', parameter='actUserPreemption'),
    dict(value='true', dist_name='NRBTS-860', parameter='actDrbPreemption'),
    dict(value='1', dist_name='NRBTS-860', parameter='maxNumOfPreemptions'),
    dict(value='false', dist_name='NRBTS-860' + "/NRCELL-1", parameter='allowEmergencyReservForTempUse'),
    dict(value='false', dist_name='NRBTS-860' + "/NRCELL-2", parameter='allowEmergencyReservForTempUse'),
    dict(value='1', dist_name='NRBTS-860' + "/NRCELL-1", parameter='numOfRadioResReservForTempUse'),
    dict(value='1', dist_name='NRBTS-860' + "/NRCELL-2", parameter='numOfRadioResReservForTempUse'),
    dict(value='true', dist_name='NRBTS-860' + "/NRCELL-1", parameter='preferNsaPreemption'),
    dict(value='true', dist_name='NRBTS-860' + "/NRCELL-2", parameter='preferNsaPreemption'),
    dict(value='4', dist_name='NRBTS-860' + "/NRDU-1", parameter='numOfDrbsReservForTempUse'),
]

PARAMS_TO_MODIFY_8847_J_14 = [
    dict(value='true', dist_name='NRBTS-860', parameter='actUserPreemption'),
    dict(value='true', dist_name='NRBTS-860', parameter='actDrbPreemption'),
    dict(value='1', dist_name='NRBTS-860', parameter='maxNumOfPreemptions'),
    dict(value='false', dist_name='NRBTS-860' + "/NRCELL-1", parameter='allowEmergencyReservForTempUse'),
    dict(value='false', dist_name='NRBTS-860' + "/NRCELL-2", parameter='allowEmergencyReservForTempUse'),
    dict(value='1', dist_name='NRBTS-860' + "/NRCELL-1", parameter='numOfRadioResReservForTempUse'),
    dict(value='1', dist_name='NRBTS-860' + "/NRCELL-2", parameter='numOfRadioResReservForTempUse'),
    dict(value='true', dist_name='NRBTS-860' + "/NRCELL-1", parameter='preferNsaPreemption'),
    dict(value='true', dist_name='NRBTS-860' + "/NRCELL-2", parameter='preferNsaPreemption'),
    dict(value='4', dist_name='NRBTS-860' + "/NRDU-1", parameter='numOfDrbsReservForTempUse'),
]

PARAMS_TO_MODIFY_8847_J_16 = [
    dict(value='true', dist_name='NRBTS-860', parameter='actUserPreemption'),
    dict(value='true', dist_name='NRBTS-860', parameter='actDrbPreemption'),
    dict(value='1', dist_name='NRBTS-860', parameter='maxNumOfPreemptions'),
    dict(value='true', dist_name='NRBTS-860' + "/NRCELL-1", parameter='allowEmergencyReservForTempUse'),
    dict(value='true', dist_name='NRBTS-860' + "/NRCELL-2", parameter='allowEmergencyReservForTempUse'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-1", parameter='numOfRadioResReservForTempUse'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-2", parameter='numOfRadioResReservForTempUse'),
    dict(value='true', dist_name='NRBTS-860' + "/NRCELL-1", parameter='preferNsaPreemption'),
    dict(value='true', dist_name='NRBTS-860' + "/NRCELL-2", parameter='preferNsaPreemption'),
    dict(value='4', dist_name='NRBTS-860' + "/NRDU-1", parameter='numOfDrbsReservForTempUse'),
]

PARAMS_TO_MODIFY_8847_TEST = [
    dict(value='100', dist_name='NRBTS-860' + "/NRCELL-1", parameter='maxNumOfUsersNRCell'),
    dict(value='0', dist_name='NRBTS-860' + "/NRCELL-1", parameter='numOfRadioResReservForEmergency'),
    dict(value='slots80', dist_name='NRBTS-860' + "/NRCELL-2", parameter='srPeriodicity'),
    dict(value=[dict(csiReportPeriodicity='slots80')], dist_name='NRBTS-860' + "/NRCELL-2",
         parameter='periodicCsiAcquisition'),
]
