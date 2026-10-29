import os
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.VduSession import VduAdminSession
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.delta_utils import load_delta_template
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.aic_variables import mrbts_id, nrbts_id
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cloud.delta import activate_delta_on_vdu


DELTA_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'delta_templates')


def set_preferred_cell_on_vdu(cell_id, vdu_id=0):
    with VduAdminSession(vdu_id) as admin:
        cell_ids = [int(cell['name'].split('-')[-1]) for cell in admin.get_vdu_cells_status()]
    cell_ids.remove(int(cell_id))
    qrx_preffered = -65
    qrx_not_preffered = -22
    logger.info("Setting preferred cell to: {}".format(cell_id))
    logger.info(f"Setting qRxLevMin={qrx_preffered} for cell: {cell_id}", also_console=True)
    logger.info(f"Setting qRxLevMin={qrx_not_preffered} for cells: {cell_ids}", also_console=True)
    delta_template = 'qrx_delta.jinja2'
    template = load_delta_template(os.path.join(DELTA_DIR, delta_template))
    delta = template.render(cell_id=cell_id, cell_ids=cell_ids, mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    logger.debug(delta)
    activate_delta_on_vdu(delta)
