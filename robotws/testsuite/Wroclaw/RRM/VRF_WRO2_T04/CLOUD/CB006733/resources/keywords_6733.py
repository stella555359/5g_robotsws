import os
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.aic_variables import mrbts_id, nrbts_id
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.delta import activate_delta_on_vcu, load_delta_template
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.aic_commissioning import wait_for_all_cells_onair

DELTA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'delta_files')


def change_a4_measmaxnumber(cell_id, max_num=5, retry_timer=10):
    template = load_delta_template(f'{DELTA_DIR}/a4_meas_max.json')
    delta = template.render(cell_id=cell_id, mrbts_id=mrbts_id, nrbts_id=nrbts_id, a4_max_number=max_num,
                            a4_retry_timer=retry_timer)
    activate_delta_on_vcu(delta)


def disable_a4_scelladd_for_nrhoifs(cell_id, nrhoifs):
    nrhoifs = nrhoifs.split(',')
    template = load_delta_template(f'{DELTA_DIR}/a4_scell_add.jinja2')
    delta = template.render(cell_id=cell_id, mrbts_id=mrbts_id, nrbts_id=nrbts_id,
                            nrhoifs=nrhoifs, value='none')
    activate_delta_on_vcu(delta)


def first_reconfiguration(cell_id):
    template = load_delta_template(f'{DELTA_DIR}/first_reconfig.json')
    delta = template.render(cell_id=cell_id, mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    activate_delta_on_vcu(delta)


def enable_a4_scelladd_for_nrhoifs(cell_id, nrhoifs, value='rsrp'):
    nrhoifs = nrhoifs.split(',')
    template = load_delta_template(f'{DELTA_DIR}/a4_scell_add.jinja2')
    delta = template.render(cell_id=cell_id, mrbts_id=mrbts_id, nrbts_id=nrbts_id,
                            nrhoifs=nrhoifs, value=value)
    activate_delta_on_vcu(delta)


def second_reconfiguration(cell_id):
    template = load_delta_template(f'{DELTA_DIR}/second_reconfig.json')
    delta = template.render(cell_id=cell_id, mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    activate_delta_on_vcu(delta)


def deactivate_feature(cell_id):
    disable_a4_scelladd_for_nrhoifs(cell_id, nrhoifs='1,2,3,4,5')


def restore_a4_default_values(cell_id):
    template = load_delta_template(f'{DELTA_DIR}/a4_default_values.json')
    delta = template.render(cell_id=cell_id, mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    activate_delta_on_vcu(delta)


def prepare_config_for_tc_04(cell_id=10):
    change_scell_addition_method_for_nrrels(cell_id, nrrels='20,30', scell_add_method="covBasedA4")


def restore_tc4_changes(cell_id=10,):
    change_scell_addition_method_for_nrrels(cell_id, nrrels='20,30', scell_add_method="covBasedA1")


def prepare_config_for_tc_26(cell_id=10):
    template = load_delta_template(f'{DELTA_DIR}/tc26_delta.json')
    delta = template.render(cell_id=cell_id, mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    activate_delta_on_vcu(delta)


def change_scell_addition_method_for_nrrels(cell_id, nrrels, scell_add_method):
    nrrels = nrrels.split(',')
    template = load_delta_template(f'{DELTA_DIR}/scell_add_delta.jinja2')
    delta = template.render(cell_id=cell_id, mrbts_id=mrbts_id, nrbts_id=nrbts_id,
                            nrrels=nrrels, scell_add_method=scell_add_method)
    activate_delta_on_vcu(delta)
    wait_for_all_cells_onair()
