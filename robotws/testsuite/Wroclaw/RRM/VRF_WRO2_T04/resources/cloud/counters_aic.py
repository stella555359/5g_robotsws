from operator import gt, ge, eq
from taf.gnb.oam.coam.vdu import vdu
from taf.gnb.oam.coam.cu import cu
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl as TL_CONFIG
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.aic_variables import mrbts_id, nrbts_id


def get_vdu_counter(counter, distname, vdu_id=0):
    v = vdu()
    v.connect_to(host=TL_CONFIG.gnbs[0].dus[vdu_id].oam_http_connection_details.addr,
                 port=TL_CONFIG.gnbs[0].dus[vdu_id].oam_http_connection_details.port,
                 username=TL_CONFIG.gnbs[0].dus[vdu_id].oam_http_connection_details.username,
                 password=TL_CONFIG.gnbs[0].dus[vdu_id].oam_http_connection_details.password,
                 connection_name=counter, secure=True)
    try:
        value = v.get_counter_values(counter, dimension_dn=distname, vdu_connection=counter)
        print(value)
        value = value[-1]['value']

    finally:
        v.disconnect(vdu_connection=counter)
    return value


def get_vcu_counter(counter, distname):
    v = cu()
    v.connect_to(host=TL_CONFIG.gnbs[0].cu.oam_http_connection_details.addr,
                 port=TL_CONFIG.gnbs[0].cu.oam_http_connection_details.port,
                 username=TL_CONFIG.gnbs[0].cu.oam_http_connection_details.username,
                 password=TL_CONFIG.gnbs[0].cu.oam_http_connection_details.password,
                 alias=counter, secure=True)
    try:
        value = v.get_counter(measurement_id=None, dimension_dist_name=distname, counter_id=counter,
                              connection=counter)
        print(value)
        value = value['values'][-1]['value']
    finally:
        v.disconnect(connection=counter)
    return value


def vdu_counter_incremented_successfully_for_cell(counter, cell_id, operator='==', expected_value=1, vdu_id=0,
                                                  profile=None):
    distname = f'MRBTS-{nrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell_id}'
    if profile:
        distname += f'/{profile}'
    operators = {'>': gt, '>=': ge, '==': eq}
    assert operator in operators, 'Unexpected operator! Allowed: {}'.format(operators.keys())
    comp = operators[operator]
    counter_value = get_vdu_counter(counter, distname=distname,
                                    vdu_id=vdu_id)
    assert comp(int(counter_value), int(expected_value)), \
        f'Incorrect value for counter: {counter} cell_id: {cell_id},' \
        f'Should be {operator}{expected_value}, but current value is {counter_value}'


def vcu_counter_incremented_successfully_for_cell(counter, cell_id, operator='==', expected_value=1, profile=None):
    distname = f'MRBTS-{nrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell_id}'
    if profile:
        distname += f'/{profile}'
    operators = {'>': gt, '>=': ge, '==': eq}
    assert operator in operators, 'Unexpected operator! Allowed: {}'.format(operators.keys())
    comp = operators[operator]
    counter_value = get_vcu_counter(counter, distname=distname)
    assert comp(int(counter_value), int(expected_value)), \
        f'Incorrect value for counter: {counter} cell_id: {cell_id},' \
        f'Should be {operator}{expected_value}, but current value is {counter_value}'
