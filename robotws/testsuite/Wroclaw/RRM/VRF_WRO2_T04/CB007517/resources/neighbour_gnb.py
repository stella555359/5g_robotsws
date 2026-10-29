import os
from operator import gt, ge, eq
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import get_robot_variable
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession


NEIGH_GNB_VM_IP = '10.44.178.123'
NEIGH_GNB_MPLANE = '10.44.88.189'
NEIGH_GNB_MRBTS_ID = 50861

DELTA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)))


def assert_target_bts_counter_has_correct_value(counter, operator='==', expected_value=None, cell_id=1):
    counters = get_robot_variable("${TARGET_BTS_COUNTER_VALUES}")
    _assert_counter_has_correct_value(counters[f'NRCELL-{cell_id}'][counter], operator, value=expected_value)


def _assert_counter_has_correct_value(counter_value, operator, value):
    operators = {'>': gt, '>=': ge, '==': eq}
    assert operator in operators, 'Unexpected operator! Allowed: {}'.format(operators.keys())
    comp = operators[operator]
    assert comp(counter_value, int(value)), \
        "Counter has incorrect value: {}, but expected is: {}{}".format(counter_value, operator, value)


def prepare_neighbour_scf_for_multignb_test():
    with AdminSession(remote_host=NEIGH_GNB_VM_IP) as admin:
        admin.perform_delta_recommissioning(os.path.join(DELTA_DIR, 'add_nradjgnb_tl26.json'))


def delete_nradjgnb_from_neighbour_scf():
    with AdminSession(remote_host=NEIGH_GNB_VM_IP) as admin:
        admin.perform_delta_recommissioning(os.path.join(DELTA_DIR, 'delete_nradjgnb_tl26.json'))
