from robot.libraries.BuiltIn import BuiltIn
tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_NAME = 'NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_CELL_NAME = NR_NAME + '/NRCELL-1'

PARAMS_TO_MODIFY = [
    dict(value='5min', dist_name=NR_NAME + '/NRPMRNL-1', p_name='miNrX2CC'),
    dict(value='5min', dist_name='MNL-1/MNLENT-1/PMCADM-1', p_name='reportingIntervalPm'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actA2SgnbRelease'),
    dict(value='true', dist_name=MR_NR_BTS_NAME, p_name='actUeInitRlf'),
    dict(value='0',
         list_name='a2MeasReleaseSsbRsrp',
         dist_name=NR_CELL_NAME,
         p_name='a2HysteresisReleaseSsbRsrp'),
    dict(value='120',
         list_name='a2MeasReleaseSsbRsrp',
         dist_name=NR_CELL_NAME,
         p_name='a2ThresholdReleaseSsbRsrp'),
    dict(value='ms512',
         list_name='a2MeasReleaseSsbRsrp',
         dist_name=NR_CELL_NAME,
         p_name='a2TimeToTriggerReleaseSsbRsrp')
]

PARAMS_TO_ADD = [
    dict(dist_name=NR_CELL_NAME, value='rsrp', p_name='a2MeasReleaseEnabled'),
    dict(value='127', dist_name=NR_CELL_NAME, p_name='sMeasConfigSsbRsrp'),
    dict(dist_name=NR_CELL_NAME, list_name='a2MeasReleaseSsbRsrp',
         elements={"a2HysteresisReleaseSsbRsrp": "0",
                   "a2ThresholdReleaseSsbRsrp": "120",
                   "a2TimeToTriggerReleaseSsbRsrp": "ms512"})
]
