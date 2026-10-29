import os
import json
from jinja2 import Template
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.CB007517.resources.neighbour_gnb import \
    prepare_neighbour_scf_for_multignb_test, delete_nradjgnb_from_neighbour_scf

DELTA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)))


def activate_a1_meas_ho_pref_nr_layer(rsrp, cell_id):
    template = load_delta_template('activate_a1_meas_ho_pref_nr_layer.json')
    delta = template.render(rsrp=rsrp, cell_id=cell_id)
    __perform_delta(delta)


def deactivate_a1_meas_ho_pref_nr_layer(cell_id):
    template = load_delta_template('deactivate_a1_meas_ho_pref_nr_layer.json')
    delta = template.render(cell_id=cell_id)
    __perform_delta(delta)


def prepare_scf_for_multignb_test():
    __perform_delta(os.path.join(DELTA_DIR, 'add_nradjgnb.json'))


def delete_nradjgnb_from_scf():
    __perform_delta(os.path.join(DELTA_DIR, 'delete_nradjgnb.json'))


def __perform_delta(delta):
    with AdminSession() as admin:
        admin.perform_delta_recommissioning(delta_file=delta, skip_parameter_relation_errors=False,
                                            should_activate=True, timeout=300)


def load_delta_template(filename):
    delta_filepath = os.path.join(DELTA_DIR, filename)
    with open(delta_filepath) as f:
        return Template(json.dumps(json.load(f)))


def setup_inter_gnb_configuration():
    prepare_neighbour_scf_for_multignb_test()
    prepare_scf_for_multignb_test()


def disable_inter_gnb_configuration():
    delete_nradjgnb_from_scf()
    delete_nradjgnb_from_neighbour_scf()
