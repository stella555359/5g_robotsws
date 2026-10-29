from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'jiang johnny'
__team__ = 'I_MN_5G_RAN_IV4_LINE_HZG_7_GMS <I_MN_5G_RAN_IV4_LINE_HZG_7@internal.nsn.com>'
__email__ = 'johnny.1.jiang@nokia-sbell.com'

_gnb_id = str(tl.gnbs[0].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id

_class_name = 'com.nokia.srbts.mnl:MPLANENW'

PARAMS_TO_MODIFY_2426_A_2 = [
    dict(value='80', dist_name='NRBTS-867' + "/NRCELL-3", parameter='maxNumOfUsersNRCell'),
    dict(value='80', dist_name='NRBTS-867' + "/NRCELL-4", parameter='maxNumOfUsersNRCell'),
    dict(value='80', dist_name='NRBTS-867' + "/NRCELL-5", parameter='maxNumOfUsersNRCell'),
    dict(value='80', dist_name='NRBTS-867' + "/NRCELL-6", parameter='maxNumOfUsersNRCell'),
    dict(value='slots40', dist_name='NRBTS-867' + "/NRCELL-2", parameter='srPeriodicity'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-1", parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-2", parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-3", parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-4", parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-5", parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-6", parameter='numOfRadioResReservForEmergency'),
]

PARAMS_TO_MODIFY_2426_A_3 = [
    dict(value='80', dist_name='NRBTS-867' + "/NRCELL-3", parameter='maxNumOfUsersNRCell'),
    dict(value='80', dist_name='NRBTS-867' + "/NRCELL-4", parameter='maxNumOfUsersNRCell'),
    dict(value='80', dist_name='NRBTS-867' + "/NRCELL-5", parameter='maxNumOfUsersNRCell'),
    dict(value='80', dist_name='NRBTS-867' + "/NRCELL-6", parameter='maxNumOfUsersNRCell'),
    dict(value=[dict(csiReportPeriodicity='slots40')], dist_name='NRBTS-867' + "/NRCELL-2",
         parameter='periodicCsiAcquisition'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-1", parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-2", parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-3", parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-4", parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-5", parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-6", parameter='numOfRadioResReservForEmergency'),
]

PARAMS_TO_MODIFY_2426_D_232 = [
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-1", parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-2", parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-3", parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-4", parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-5", parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-6", parameter='numOfRadioResReservForEmergency'),
]

PARAMS_TO_MODIFY_2426_D_341 = [
    dict(value='30', dist_name='NRBTS-867' + "/NRCELL-1", parameter='maxNumOfUsersNRCell'),
    dict(value='false', dist_name='NRBTS-867' + "/NRCELL-2", parameter='actEmergencyCall'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-3", parameter='numOfRadioResReservForEmergency'),
]

PARAMS_TO_MODIFY_2426_D_421 = [
    dict(value='40', dist_name='NRBTS-867' + "/NRCELL-1", parameter='maxNumOfUsersNRCell'),
    dict(value='40', dist_name='NRBTS-867' + "/NRCELL-2", parameter='maxNumOfUsersNRCell'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-1", parameter='numOfRadioResReservForEmergency'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-2", parameter='numOfRadioResReservForEmergency'),
]

PARAMS_TO_MODIFY_2426_L_141 = [
    dict(value='true', dist_name='NRBTS-867' + "/NRCELL-1", parameter='actAdaptiveSr'),
    dict(value='true', dist_name='NRBTS-867' + "/NRCELL-2", parameter='actAdaptiveSr'),
    dict(value='slots5', dist_name='NRBTS-867' + "/NRCELL-1", parameter='srPeriodicityMin'),
    dict(value='slots5', dist_name='NRBTS-867' + "/NRCELL-2", parameter='srPeriodicityMin'),
    dict(value='60', dist_name='NRBTS-867' + "/NRCELL-1", parameter='adaptiveSrLoadThresholdUp'),
    dict(value='60', dist_name='NRBTS-867' + "/NRCELL-2", parameter='adaptiveSrLoadThresholdUp'),
    dict(value='40', dist_name='NRBTS-867' + "/NRCELL-1", parameter='adaptiveSrLoadThresholdDown'),
    dict(value='40', dist_name='NRBTS-867' + "/NRCELL-2", parameter='adaptiveSrLoadThresholdDown'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-1", parameter='lowLatencyReservation'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-2", parameter='lowLatencyReservation'),
    dict(value='slots20', dist_name='NRBTS-867' + "/NRCELL-1", parameter='preferredVoNrSrPeriod'),
    dict(value='slots20', dist_name='NRBTS-867' + "/NRCELL-2", parameter='preferredVoNrSrPeriod'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-1", parameter='vonrReservation'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-2", parameter='vonrReservation'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-1", parameter='adaptiveSrBlockingMinimization'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-2", parameter='adaptiveSrBlockingMinimization'),
]

PARAMS_TO_MODIFY_2426_L_142 = [
    dict(value='true', dist_name='NRBTS-867' + "/NRCELL-1", parameter='actAdaptiveSr'),
    dict(value='true', dist_name='NRBTS-867' + "/NRCELL-2", parameter='actAdaptiveSr'),
    dict(value='slots5', dist_name='NRBTS-867' + "/NRCELL-1", parameter='srPeriodicityMin'),
    dict(value='slots5', dist_name='NRBTS-867' + "/NRCELL-2", parameter='srPeriodicityMin'),
    dict(value='60', dist_name='NRBTS-867' + "/NRCELL-1", parameter='adaptiveSrLoadThresholdUp'),
    dict(value='60', dist_name='NRBTS-867' + "/NRCELL-2", parameter='adaptiveSrLoadThresholdUp'),
    dict(value='40', dist_name='NRBTS-867' + "/NRCELL-1", parameter='adaptiveSrLoadThresholdDown'),
    dict(value='40', dist_name='NRBTS-867' + "/NRCELL-2", parameter='adaptiveSrLoadThresholdDown'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-1", parameter='lowLatencyReservation'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-2", parameter='lowLatencyReservation'),
    dict(value='slots20', dist_name='NRBTS-867' + "/NRCELL-1", parameter='preferredVoNrSrPeriod'),
    dict(value='slots20', dist_name='NRBTS-867' + "/NRCELL-2", parameter='preferredVoNrSrPeriod'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-1", parameter='vonrReservation'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-2", parameter='vonrReservation'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-1", parameter='adaptiveSrBlockingMinimization'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-2", parameter='adaptiveSrBlockingMinimization'),
]

PARAMS_TO_MODIFY_2426_L_143 = [
    dict(value='true', dist_name='NRBTS-867' + "/NRCELL-1", parameter='actAdaptiveSr'),
    dict(value='true', dist_name='NRBTS-867' + "/NRCELL-2", parameter='actAdaptiveSr'),
    dict(value='slots5', dist_name='NRBTS-867' + "/NRCELL-1", parameter='srPeriodicityMin'),
    dict(value='slots5', dist_name='NRBTS-867' + "/NRCELL-2", parameter='srPeriodicityMin'),
    dict(value='60', dist_name='NRBTS-867' + "/NRCELL-1", parameter='adaptiveSrLoadThresholdUp'),
    dict(value='60', dist_name='NRBTS-867' + "/NRCELL-2", parameter='adaptiveSrLoadThresholdUp'),
    dict(value='40', dist_name='NRBTS-867' + "/NRCELL-1", parameter='adaptiveSrLoadThresholdDown'),
    dict(value='40', dist_name='NRBTS-867' + "/NRCELL-2", parameter='adaptiveSrLoadThresholdDown'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-1", parameter='lowLatencyReservation'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-2", parameter='lowLatencyReservation'),
    dict(value='slots20', dist_name='NRBTS-867' + "/NRCELL-1", parameter='preferredVoNrSrPeriod'),
    dict(value='slots20', dist_name='NRBTS-867' + "/NRCELL-2", parameter='preferredVoNrSrPeriod'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-1", parameter='vonrReservation'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-2", parameter='vonrReservation'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-1", parameter='adaptiveSrBlockingMinimization'),
    dict(value='0', dist_name='NRBTS-867' + "/NRCELL-2", parameter='adaptiveSrBlockingMinimization'),
]
