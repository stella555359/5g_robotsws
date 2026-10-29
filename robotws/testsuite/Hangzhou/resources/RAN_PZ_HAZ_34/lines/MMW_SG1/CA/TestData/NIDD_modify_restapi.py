from robot.libraries.BuiltIn import BuiltIn
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.lines.MMW_SG1.CA.TestData.NIDD_modify_scf_common import *
gnb_info = BuiltIn().get_variable_value('${gnb_info}')
carrierAggregationSupportList = BuiltIn().get_variable_value('${carrierAggregationSupportList}')
tl = BuiltIn().get_variable_value('${tl}')
BTS_ID = str(tl.gnbs[0].instance_id)

ACT_1390_CA = [
    dict(
        value='ca_Fdd_Fr1Tdd',
        dist_name=DN_NRBTS + '/NRDU-1',
        parameter='carrierAggregationSupportList'),
]

ACTIVE_5GC002255_5GC001390_RESTAPI = [
    dict(
        value='true',
        dist_name=DN_NRBTS + '/NRDU-1',
        parameter='actInterNumerologyCa'),
    dict(
        value=carrierAggregationSupportList,
        dist_name=DN_NRBTS + '/NRDU-1',
        parameter='carrierAggregationSupportList')
]

DEACTIVE_5GC002255_5GC001390_RESTAPI = [
    dict(
        value='false',
        dist_name=DN_NRBTS + '/NRDU-1',
        parameter='actInterNumerologyCa'),
    dict(
        value=['none'],
        dist_name=DN_NRBTS + '/NRDU-1',
        parameter='carrierAggregationSupportList')
]

DEACTIVE_5GC001390_RESTAPI = [
    dict(
        value=['none'],
        dist_name=DN_NRBTS + '/NRDU-1',
        parameter='carrierAggregationSupportList')
]

# new parmater of MO NRREL in TRUNK
ADD_MO_NRREL_HANDOVER_API = [
    {'dist_name': DN_CA_REL, 'parameter': 'handoverAllowedSA', 'value': 'allowed'},
]

ADD_MO_NRREL_RESTAPI = [
    {'dist_name': DN_CA_REL, 'parameter': 'cellIndividualSsbRsrpOffset', 'value': '0dB'},
    {'dist_name': DN_CA_REL, 'parameter': 'cellIndividualSsbRsrqOffset', 'value': '0dB'},
    {'dist_name': DN_CA_REL, 'parameter': 'gNbId', 'value': gnb_info['gNbId']},
    {'dist_name': DN_CA_REL, 'parameter': 'gNbIdLength', 'value': gnb_info['gNbIdLength']},
    {'dist_name': DN_CA_REL, 'parameter': 'lcrId', 'value': SCELL_LIST[CA_GROUP_INDEX]['lcrId']},
    {'dist_name': DN_CA_REL, 'parameter': 'removeNotAllowed', 'value': 'false'},
    {'dist_name': DN_CA_REL, 'parameter': 'sCellAdditionMethod', 'value': 'blind'},
    {'dist_name': DN_CA_REL, 'parameter': 'nrRelId', 'value': '1'},
    {'dist_name': DN_CA_REL, 'parameter': 'gnbPlmn',
     'value': [{'mcc': gnb_info['mcc'], 'mnc': gnb_info['mnc'], 'mncLength': gnb_info['mncLength']}]}
]

if program != '21A' and program != '21B':
    ADD_MO_NRREL_RESTAPI = ADD_MO_NRREL_RESTAPI + ADD_MO_NRREL_HANDOVER_API

DELETE_MO_NRREL_RESTAPI = [dict(dist_name=DN_CA_REL)]

ACTIVE_BEAM_REFINEMENT_RESTAPI = [
    dict(
        value=[dict(nrBtsBeamRefinementP2='true')],
        dist_name=DN_SCELL,
        parameter='beamSet'),
]

RESTAPI_SCELL_ACTIVATION_BUFFER_BASED = [
    dict(
        value='bufferBased',
        dist_name=DN_NRBTS,
        parameter='sCellActivationMethod'),
]


if program == '25R1' or program == '25R2':
    RESTAPI_ENABLE_ProactUlSched = [
        dict(
            dist_name=DN_PCELL,
            parameter='actProactUlScheduling',
            value='true'),
    ]
    RESTAPI_DISABLE_ProactUlSched = [
        dict(
            dist_name=DN_PCELL,
            parameter='actProactUlScheduling',
            value='false'),
    ]
else:
    RESTAPI_ENABLE_ProactUlSched = [
        dict(
            dist_name=DN_PCELL,
            parameter='actProactUlSchedulingEnh',
            value='allUes'),
    ]
    RESTAPI_DISABLE_ProactUlSched = [
        dict(
            dist_name=DN_PCELL,
            parameter='actProactUlSchedulingEnh',
            value='disabled'),
    ]

RESTAPI_ENABLE_DRX = [
    dict(
        value='true',
        dist_name=DN_NRBTS,
        parameter='actDrbDrx'),
    dict(
        dist_name=DN_PCELL,
        parameter='actCDrx',
        value='true'),
    dict(
        value='80ms',
        dist_name=DN_NRBTS + '/NRDRX-4',
        parameter='drxInactivityTimer'),
    dict(
        value='160ms',
        dist_name=DN_NRBTS + '/NRDRX-4',
        parameter='drxLongCycle'),
    dict(
        value='10ms',
        dist_name=DN_NRBTS + '/NRDRX-4',
        parameter='drxOnDurationTimer'),
    dict(
        value='0slot',
        dist_name=DN_NRBTS + '/NRDRX-4',
        parameter='drxRetransTimerDl'),
    dict(
        value='0slot',
        dist_name=DN_NRBTS + '/NRDRX-4',
        parameter='drxRetransTimerUl'),
    dict(
        value='NonGbr',
        dist_name=DN_NRBTS + '/NRDRX-4',
        parameter='userLabel'),
    dict(
        value=DN_NRBTS + '/NRDRX-4',
        dist_name=DN_NRBTS + '/NRDRB-12',
        parameter='nrDrxDN'),
] + RESTAPI_DISABLE_ProactUlSched

RESTAPI_ENABLE_DRX_BELOW80 = [
    dict(
        dist_name=DN_PCELL,
        parameter='actCDrx',
        value='true'),
    dict(
        value=DN_NRBTS + '/NRDRX-4',
        dist_name=DN_PCELL,
        parameter='nonGbrNrDrxDN'),
    dict(
        value='40ms',
        dist_name=DN_NRBTS + '/NRDRX-4',
        parameter='drxInactivityTimer'),
    dict(
        value='80ms',
        dist_name=DN_NRBTS + '/NRDRX-4',
        parameter='drxLongCycle'),
    dict(
        value='10ms',
        dist_name=DN_NRBTS + '/NRDRX-4',
        parameter='drxOnDurationTimer'),
    dict(
        value='0slot',
        dist_name=DN_NRBTS + '/NRDRX-4',
        parameter='drxRetransTimerDl'),
    dict(
        value='0slot',
        dist_name=DN_NRBTS + '/NRDRX-4',
        parameter='drxRetransTimerUl'),
    dict(
        value='NonGbr',
        dist_name=DN_NRBTS + '/NRDRX-4',
        parameter='userLabel'),
] + RESTAPI_DISABLE_ProactUlSched

RESTAPI_DISABLE_DRX = [
    dict(
        dist_name=DN_PCELL,
        parameter='actCDrx',
        value='false')
] + RESTAPI_ENABLE_ProactUlSched

RESTAPI_TDD_RRC_TIMER = [
    dict(
        dist_name=DN_SCELL,
        parameter='t300',
        value='2000ms'),
    dict(
        dist_name=DN_SCELL,
        parameter='t311',
        value='30000ms'),
]

RESTAPI_EABLE_GRACEFUL_SHUTDOWN = [
    dict(
        dist_name=DN_NRBTS,
        parameter='actGrflShdn',
        value='true'),
    dict(
        dist_name=DN_NRBTS,
        parameter='shutdownStepAmount',
        value='16'),
    dict(
        dist_name=DN_NRBTS,
        parameter='shutdownWindow',
        value='180'),
]

# FEATURE CNI71694 CA aware PSCell selection
ACTIVE_CNI71694_RESTAPI = [
    dict(dist_name=DN_PCELL,
         parameter='actCaAwarePsCellSelectionFr1',
         value='true'),
    dict(
        dist_name=DN_SCELL,
        parameter='actCaAwarePsCellSelectionFr1',
        value='true'),
]

DEACTIVE_CNI71694_RESTAPI = [
    dict(dist_name=DN_PCELL,
         parameter='actCaAwarePsCellSelectionFr1',
         value='false'),
    dict(
        dist_name=DN_SCELL,
        parameter='actCaAwarePsCellSelectionFr1',
        value='false'),
]
