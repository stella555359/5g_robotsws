from robot.libraries.BuiltIn import BuiltIn
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.NIDD_modify_scf_common import *
# ${PROGRAM}: is get via method: gnb_classical_hangzhou.Get program version based on stream version
program = BuiltIn().get_variable_value('${PROGRAM}')
# ${tl}: open in testline config file stored on gerrit
tl = BuiltIn().get_variable_value('${tl}')

# ${GNB_INFO}: Define in NIDD_modify_scf.py
GNB_INFO = BuiltIn().get_variable_value('${GNB_INFO}')

# Parameter dedined in 5GC002329_variables.robot
carrierAggregationSupportList_With_T_F = BuiltIn().get_variable_value('${carrierAggregationSupportList_With_T_F}')
carrierAggregationSupportList_without_T_F = BuiltIn().get_variable_value(
    '${carrierAggregationSupportList_without_T_F}')

DELETE_MO_NRREL_RESTAPI = [dict(dist_name=DN_CA_REL)]

MODIFY_ACTIVE_T_F_2329_RESTAPI = [
    dict(
        value=carrierAggregationSupportList_With_T_F,
        dist_name=DN_NRBTS + '/NRDU-1',
        parameter='carrierAggregationSupportList')
]
MODIFY_DEACTIVE_T_F_2329_RESTAPI = [
    dict(
        value=carrierAggregationSupportList_without_T_F,
        dist_name=DN_NRBTS + '/NRDU-1',
        parameter='carrierAggregationSupportList')]

RESTAPI_ENABLE_DRX = [
    dict(
        dist_name=DN_PCELL,
        parameter='actCDrx',
        value='true'),
    dict(
        dist_name=DN_PCELL,
        parameter='drxProfile1',
        value=[dict(drxInactivityTimer='80ms', drxLongCycle='160ms', drxOnDurationTimer='10ms',
                    drxRetransTimerDl='0slot', drxRetransTimerUl='0slot')]),
]

RESTAPI_ENABLE_DRX_BELOW80 = [
    dict(
        dist_name=DN_PCELL,
        parameter='actCDrx',
        value='true'),
    dict(
        dist_name=DN_PCELL,
        parameter='drxProfile1',
        value=[dict(drxInactivityTimer='4ms', drxLongCycle='40ms', drxOnDurationTimer='6ms',
                    drxRetransTimerDl='0slot', drxRetransTimerUl='0slot')]),
]

RESTAPI_DISABLE_DRX = [
    dict(
        dist_name=DN_PCELL,
        parameter='actCDrx',
        value='false'),
]

RESTAPI_DISABLE_A2_PCELL_CHANGE = [
    dict(
        dist_name=DN_TDDCELL_HOIF,
        parameter='a2BasedPCellSwitchEnabled',
        value='false'),
    dict(
        dist_name=DN_TDDCELLS,
        parameter='a2MeasPCellSwitchEnabled',
        value='none'),
    dict(
        dist_name=DN_FDDCELLS,
        parameter='a2MeasSCellRelEnabled',
        value='none'),
]
