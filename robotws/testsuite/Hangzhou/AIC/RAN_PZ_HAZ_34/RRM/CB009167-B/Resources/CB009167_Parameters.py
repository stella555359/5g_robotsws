
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value('${tl}')
MR_BTS_NAME = 'MRBTS-' + str(tl.gnbs[0].instance_id)
MR_NR_BTS_NAME = MR_BTS_NAME + '/NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_NAME = 'NRBTS-' + str(tl.gnbs[0].global_bts_id)
NR_CELL_NAME = MR_NR_BTS_NAME + '/NRCELL-1'
NR_CELL_NAME_2 = MR_NR_BTS_NAME + '/NRCELL-2'
NRE2NODE = MR_NR_BTS_NAME + '/NRE2NODE-1'
NRE2LINK = MR_NR_BTS_NAME + '/NRE2LINK-1'
NRNEARRTRIC = MR_NR_BTS_NAME + '/NRNEARRTRIC-1'
NRRANFUNCTION_IMLB = MR_NR_BTS_NAME + '/NRE2NODE-1/NRRANFUNCTION-1'
NRRANFUNCTION_CA = MR_NR_BTS_NAME + '/NRE2NODE-1/NRRANFUNCTION-2'
IPADDRESSV4_1 = MR_BTS_NAME + '/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1'
NRSCTP = MR_NR_BTS_NAME + '/NRSCTP-1'

IMLB_OBJ = {
    NRE2NODE: {},
    NRRANFUNCTION_IMLB: {'id': '1', 'shortName': 'ORAN-E2SM-RC-IMLB'}}
CA_OBJ = {
    NRE2NODE: {},
    NRRANFUNCTION_CA: {'id': '2', 'shortName': 'ORAN-E2SM-RC-CA'}}
CA_Enable = {
    MR_NR_BTS_NAME: {'actE2CA': 'true'}}
CA_Disable = {
    MR_NR_BTS_NAME: {'actE2CA': 'false'}}
IMLB_Enable = {
    MR_NR_BTS_NAME: {'actE2IMLB': 'true'}}
IMLB_Disable = {
    MR_NR_BTS_NAME: {'actE2IMLB': 'false'}}
E2_OBJ = {
    NRE2LINK: {'administrativeState': 'Unlocked'},
    NRNEARRTRIC: {'nrNearRTRICIPAddress': '10.70.222.115', 'nrNearRTRICSCTPPort': '32163'}}
E2_PARA = {
    MR_NR_BTS_NAME: {'actE2Interface': 'true', 'actE2CA': 'false', 'actE2IMLB': 'false',
                     'e2Plane': [{'e2TnlId': '1', 'ipV4AddressDN1': IPADDRESSV4_1}]},
    NRSCTP: {'e2SctpProfileId': '1'}}

E2_Enable = {
    MR_NR_BTS_NAME: {'actE2Interface': 'true'}}
E2_LOCK = {
    NRE2LINK: {'administrativeState': 'Locked'}}
IdleMMSteering_Enable = {
    MR_NR_BTS_NAME: {'actIdleMMSteering': 'true'}}
drbInactivityTimerSA_5 = {
    MR_NR_BTS_NAME: {'drbInactivityTimerSA': '5'}}
srbInactivityTimerSA_5 = {
    MR_NR_BTS_NAME: {'srbInactivityTimerSA': '5'}}
idleMMSteeringAlgo_CA_aware = {
    NR_CELL_NAME: {'idleMMSteeringAlgo': 'CA aware'},
    NR_CELL_NAME_2: {'idleMMSteeringAlgo': 'CA aware'}}
idleMMSteeringAlgo_no_CA_aware = {
    NR_CELL_NAME: {'idleMMSteeringAlgo': 'non CA aware'},
    NR_CELL_NAME_2: {'idleMMSteeringAlgo': 'non CA aware'}}
IdleMMSteering_profile_Enable = {
    MR_NR_BTS_NAME: {'actMobilityProfile': 'true'}}
E2_UNLOCK = {
    NRE2LINK: {'administrativeState': 'Unlocked'}}

DSCP_Value_46 = {
    MR_NR_BTS_NAME: {'cPlaneDscp': '46'}}

DSCP_Value_48 = {
    MR_NR_BTS_NAME: {'cPlaneDscp': '48'}}
ATTENUATION_VALUE_case15_cell1_0 = {
    'atten_value_of_port0': 127,
    'atten_value_of_port1': 127,
    'atten_value_of_port2': 127,
    'atten_value_of_port3': 127,
}
ATTENUATION_VALUE_case15_cell2_0 = {
    'atten_value_of_port0': 0,
    'atten_value_of_port1': 0,
    'atten_value_of_port2': 0,
    'atten_value_of_port3': 0,
}

ATTENUATION_VALUE_case23_cell1_0 = {
    'atten_value_of_port0': 40,
    'atten_value_of_port1': 40,
    'atten_value_of_port2': 40,
    'atten_value_of_port3': 40,
}
ATTENUATION_VALUE_case23_cell2_0 = {
    'atten_value_of_port0': 127,
    'atten_value_of_port1': 127,
    'atten_value_of_port2': 127,
    'atten_value_of_port3': 127,
}
ATTENUATION_VALUE_case23_cell2_1 = {
    'atten_value_of_port0': 40,
    'atten_value_of_port1': 40,
    'atten_value_of_port2': 40,
    'atten_value_of_port3': 40,
}
ATTENUATION_VALUE_case23_cell1_2 = {
    'atten_value_of_port0': 15,
    'atten_value_of_port1': 15,
    'atten_value_of_port2': 15,
    'atten_value_of_port3': 15,
}
