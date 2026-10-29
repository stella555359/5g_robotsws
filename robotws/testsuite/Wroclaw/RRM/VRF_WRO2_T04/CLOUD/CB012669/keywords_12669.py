import os
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.aic_variables import mrbts_id, nrbts_id
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.delta import activate_delta_on_vdu, load_delta_template

DELTA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'delta_files')


def activate_feature_deprioritization(cell_id, num_deprioritized):
    template = load_delta_template(f'{DELTA_DIR}/feature_activation.json')
    delta = template.render(cell_id=cell_id, mrbts_id=mrbts_id, nrbts_id=nrbts_id,
                            num_deprioritized=num_deprioritized, status='enhanced')
    activate_delta_on_vdu(delta)


def deactivate_feature_deprioritization(cell_id):
    template = load_delta_template(f'{DELTA_DIR}/feature_activation.json')
    delta = template.render(cell_id=cell_id, mrbts_id=mrbts_id, nrbts_id=nrbts_id,
                            num_deprioritized='0', status='disabled')
    activate_delta_on_vdu(delta)
