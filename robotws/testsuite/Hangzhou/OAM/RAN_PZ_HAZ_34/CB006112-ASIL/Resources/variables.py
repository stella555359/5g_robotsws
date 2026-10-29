from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value("${tl}")

__maintainer__ = 'Wang lei'
__team__ = 'I_NSB_MN_5GSC_5GPZ_HZ_07_S3_GMS <I_NSB_MN_5GSC_5GPZ_HZ_07_S3_GMS@internal.nsn.com>'
__email__ = 'lei.24.wang@nokia-sbell.com'

_gnb_id = str(tl.gnbs[1].instance_id)
_MRBTSname = 'MRBTS-'+_gnb_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb_id
_NRCELLname = _NRBTSname+'/NRCELL-2'
_NRDRB15name = _NRBTSname+'/NRDRB-15'

PATH_TO_SCF = ''

PARAMS_TO_MODIFY_6112_A01_0 = [
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actVoipPacketAggr'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actVoipPacketAggr'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='ulVoipPacketAggrSinrThreshold'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actCDrx'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actCDrx'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actCDrxVoNR'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actCDrxVoNR'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}'+"/NRCELLGRP-0", parameter='actProactUlScheduling'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}'+"/NRCELLGRP-1", parameter='actProactUlScheduling'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actAdaptVoipTbs'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actAdaptVoipTbs'),
]

PARAMS_TO_MODIFY_6112_A01_1 = [
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actVoipPacketAggr'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actVoipPacketAggr'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='ulVoipPacketAggrSinrThreshold'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actCDrx'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actCDrx'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actCDrxVoNR'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actCDrxVoNR'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}'+"/NRCELLGRP-0", parameter='actProactUlScheduling'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}'+"/NRCELLGRP-1", parameter='actProactUlScheduling'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actAdaptVoipTbs'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actAdaptVoipTbs'),
]

PARAMS_TO_MODIFY_6112_A07_0 = [
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actVoipPacketAggr'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actVoipPacketAggr'),
    dict(value='400', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='ulVoipPacketAggrSinrThreshold'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actCDrx'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actCDrx'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actCDrxVoNR'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actCDrxVoNR'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}'+"/NRCELLGRP-0", parameter='actProactUlScheduling'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}'+"/NRCELLGRP-1", parameter='actProactUlScheduling'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actAdaptVoipTbs'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actAdaptVoipTbs'),
]

PARAMS_TO_MODIFY_6112_A07_1 = [
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actVoipPacketAggr'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actVoipPacketAggr'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='ulVoipPacketAggrSinrThreshold'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actCDrx'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actCDrx'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actCDrxVoNR'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actCDrxVoNR'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}'+"/NRCELLGRP-0", parameter='actProactUlScheduling'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}'+"/NRCELLGRP-1", parameter='actProactUlScheduling'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actAdaptVoipTbs'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actAdaptVoipTbs'),
]

PARAMS_TO_MODIFY_6112_A09_0 = [
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actVoipPacketAggr'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actVoipPacketAggr'),
    dict(value='400', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='ulVoipPacketAggrSinrThreshold'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actCDrx'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actCDrx'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actCDrxVoNR'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actCDrxVoNR'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}'+"/NRCELLGRP-0", parameter='actProactUlScheduling'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}'+"/NRCELLGRP-1", parameter='actProactUlScheduling'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actAdaptVoipTbs'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actAdaptVoipTbs'),
]

PARAMS_TO_MODIFY_6112_A09_1 = [
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actVoipPacketAggr'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actVoipPacketAggr'),
    dict(value='400', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='ulVoipPacketAggrSinrThreshold'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actCDrx'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actCDrx'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actCDrxVoNR'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actCDrxVoNR'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}'+"/NRCELLGRP-0", parameter='actProactUlScheduling'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}'+"/NRCELLGRP-1", parameter='actProactUlScheduling'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actAdaptVoipTbs'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actAdaptVoipTbs'),
]

PARAMS_TO_MODIFY_6112_A09_2 = [
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actVoipPacketAggr'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actVoipPacketAggr'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='ulVoipPacketAggrSinrThreshold'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actCDrx'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actCDrx'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actCDrxVoNR'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actCDrxVoNR'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}'+"/NRCELLGRP-0", parameter='actProactUlScheduling'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}'+"/NRCELLGRP-1", parameter='actProactUlScheduling'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actAdaptVoipTbs'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actAdaptVoipTbs'),
]

PARAMS_TO_MODIFY_6112_A09_3 = [
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actVoipPacketAggr'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actVoipPacketAggr'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='ulVoipPacketAggrSinrThreshold'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actCDrx'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actCDrx'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actCDrxVoNR'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actCDrxVoNR'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}'+"/NRCELLGRP-0", parameter='actProactUlScheduling'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}'+"/NRCELLGRP-1", parameter='actProactUlScheduling'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actAdaptVoipTbs'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actAdaptVoipTbs'),
]

PARAMS_TO_MODIFY_6112_A11_0 = [
    dict(value='100ms', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRDRB-15", parameter='discardTimer'),
]

PARAMS_TO_MODIFY_6112_A11_1 = [
    dict(value='20ms', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRDRB-15", parameter='discardTimer'),
]

PARAMS_TO_MODIFY_6112_A16_0 = [
    dict(value='30', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='drbInactivityTimerSA5qi5'),
]

PARAMS_TO_MODIFY_6112_A16_1 = [
    dict(value='15', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='drbInactivityTimerSA5qi5'),
]

PARAMS_TO_MODIFY_6112_A16_2 = [
    dict(value='150', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='drbInactivityTimerSA5qi5'),
]

PARAMS_TO_MODIFY_6112_B15_0 = [
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actCDrxVoNR'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actCDrxVoNR'),
]

PARAMS_TO_MODIFY_6112_B15_1 = [
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actCDrxVoNR'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actCDrxVoNR'),
]


PARAMS_TO_MODIFY_6112_C03_0 = [
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actVoipPacketAggr'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actVoipPacketAggr'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='ulVoipPacketAggrSinrThreshold'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actCDrx'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actCDrx'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actCDrxVoNR'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actCDrxVoNR'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}'+"/NRCELLGRP-0", parameter='actProactUlScheduling'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}'+"/NRCELLGRP-1", parameter='actProactUlScheduling'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actAdaptVoipTbs'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actAdaptVoipTbs'),
]

PARAMS_TO_MODIFY_6112_C03_1 = [
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actVoipPacketAggr'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actVoipPacketAggr'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='ulVoipPacketAggrSinrThreshold'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actCDrx'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actCDrx'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actCDrxVoNR'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actCDrxVoNR'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}'+"/NRCELLGRP-0", parameter='actProactUlScheduling'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}'+"/NRCELLGRP-1", parameter='actProactUlScheduling'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='actAdaptVoipTbs'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='actAdaptVoipTbs'),
]

PARAMS_TO_MODIFY_6112_C08_0 = [
    dict(value='0', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='addNumOfGBRBearers'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='addNumOfGBRBearers'),
    dict(value='200', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='maxNumOfGBRBearersSA'),
    dict(value='200', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='maxNumOfGBRBearersSA'),
]

PARAMS_TO_MODIFY_6112_C08_1 = [
    dict(value='40', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='addNumOfGBRBearers'),
    dict(value='40', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='addNumOfGBRBearers'),
    dict(value='200', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='maxNumOfGBRBearersSA'),
    dict(value='200', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='maxNumOfGBRBearersSA'),
]

PARAMS_TO_MODIFY_6112_C09_0 = [
    dict(value='0', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='addNumOfGBRBearers'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='addNumOfGBRBearers'),
    dict(value='200', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='maxNumOfGBRBearersSA'),
    dict(value='200', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='maxNumOfGBRBearersSA'),
]

PARAMS_TO_MODIFY_6112_C09_1 = [
    dict(value='0', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='addNumOfGBRBearers'),
    dict(value='0', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='addNumOfGBRBearers'),
    dict(value='1', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-1", parameter='maxNumOfGBRBearersSA'),
    dict(value='1', dist_name='NRBTS-${tl.gnbs[1].instance_id}' + "/NRCELL-2", parameter='maxNumOfGBRBearersSA'),
]

PARAMS_TO_MODIFY_6112_C12_0 = [
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='actInterFreqHoSA'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='actInterRatHoSA'),
]

PARAMS_TO_MODIFY_6112_C12_1 = [
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='actInterFreqHoSA'),
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='actInterRatHoSA'),
]

PARAMS_TO_MODIFY_6112_C19_0 = [
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='actInterFreqHoSA'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='actInterRatHoSA'),
]

PARAMS_TO_MODIFY_6112_C19_1 = [
    dict(value='false', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='actInterFreqHoSA'),
    dict(value='true', dist_name='NRBTS-${tl.gnbs[1].instance_id}', parameter='actInterRatHoSA'),
]

AMOUNT_OF_CELLS = 1
