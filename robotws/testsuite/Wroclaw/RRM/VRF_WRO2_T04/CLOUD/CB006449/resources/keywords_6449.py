import os
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.aic_variables import mrbts_id, nrbts_id
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.delta import (
    activate_delta_on_vcu, load_delta_template, activate_delta_on_vdu)
DELTA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'delta_files')


def activate_buffer_based_scell_addition():
    template = load_delta_template(f'{DELTA_DIR}/buffer_based.jinja2')
    delta = template.render(buffer_based_value='oneShot_Dl_Fr1', vcu=False,
                            mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    activate_delta_on_vdu(delta)

    delta = template.render(buffer_based_value='oneShot_Dl_Fr1',
                            meas_based_scell_add_value=['A1-based', 'A4-based'], vcu=True,
                            mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    logger.info(delta, also_console=True)
    activate_delta_on_vcu(delta)


def disable_buffer_based_scell_addition():
    template = load_delta_template(f'{DELTA_DIR}/buffer_based.jinja2')
    delta = template.render(buffer_based_value='disabled',
                            meas_based_scell_add_value=['A1-based'], vcu=True,
                            mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    activate_delta_on_vcu(delta)

    delta = template.render(buffer_based_value='disabled', vcu=False, mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    activate_delta_on_vdu(delta)
