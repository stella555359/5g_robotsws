import time
import os
from robot.api import logger
import testsuite.Wroclaw.RRM.resources.webUI_operations as webui
from testsuite.Wroclaw.RRM.resources.preconditions_py import mrbts_id
from taf.config.scf import scf
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession, get_scf_from_lte
from ca_variables import LNBTS_ID, IP_VM_5G, IP_VM_LTE, LTE_CELLS
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import get_robot_output_dir


def prepare_dss_delta(min_dss_ratio, max_dss_ratio, lte_bandwith=None, dss_cells=LTE_CELLS,
                      lnbts_id=LNBTS_ID, vm_ip=IP_VM_LTE):
    output_dir = get_robot_output_dir()
    current_scf = 'scf_lte.xml'
    target_scf = os.path.join(output_dir, 'scf_lte_{}_{}.xml'.format(min_dss_ratio, max_dss_ratio))
    delta_filepath = os.path.join(output_dir, 'delta_lte_{}_{}.json'.format(min_dss_ratio, max_dss_ratio))
    revert_delta = os.path.join(output_dir, 'revert_delta_lte_{}_{}.json'.format(min_dss_ratio, max_dss_ratio))

    current_scf = get_scf_from_lte(output_dir, current_scf, vm_ip)

    new_scf = scf()
    new_scf.load_scf(current_scf)
    logger.info("LNBTS_ID: {}".format(lnbts_id), also_console=True)
    new_scf.modify_scf_element(value='true', dist_name='LNBTS-{}'.format(lnbts_id), p_name='actLteNrDss')
    cell_specific_params = _prepare_cell_params(min_dss_ratio, max_dss_ratio, lte_bandwith, dss_cells)
    logger.debug("PARAMS: {}".format(cell_specific_params))
    new_scf.perform_scf_modification(cell_specific_params)
    new_scf.save_scf(target_scf)
    new_scf.calculate_delta_scf(target_scf_path=target_scf, actual_scf_path=current_scf,
                                delta_scf_path=delta_filepath)

    new_scf.calculate_delta_scf(target_scf_path=current_scf, actual_scf_path=target_scf,
                                delta_scf_path=revert_delta)
    os.remove(current_scf)
    os.remove(target_scf)
    return delta_filepath


def _prepare_cell_params(min_dss_ratio, max_dss_ratio, lte_bandwith, dss_cells):
    cell_specific_params = []
    blanked_pucch = {'10': 8, '20': 4}
    for cell_id in dss_cells:
        cell_specific_params.extend(
            ['modify:LNCEL-{}/DSSNR-0:lteNrDssDlRatio:minNrDssRatio={}'.format(cell_id, min_dss_ratio),
             'modify:LNCEL-{}/DSSNR-0:lteNrDssDlRatio:maxNrDssRatio={}'.format(cell_id, max_dss_ratio),
             'modify:LNCEL-{}:administrativeState=unlocked'.format(cell_id)
             ]
        )
        if lte_bandwith:
            cell_specific_params.extend([
                'modify:LNCEL-{}:ulChBw={} MHz'.format(cell_id, lte_bandwith),
                'modify:LNCEL-{}:dlChBw={} MHz'.format(cell_id, lte_bandwith),
                'modify:LNCEL-{}/LNCEL_FDD-0:blankedPucch={}'.format(cell_id, blanked_pucch[str(lte_bandwith)])
            ])
    return cell_specific_params


def _prepare_nr_cell_params(min_dss_ratio, max_dss_ratio):
    cell_specific_params = []
    for cell_id in (2, 3):
        cell_specific_params.extend(
            [
                'modify:NRCELL-{}:actDlPtrs=false'.format(cell_id),
                'modify:NRCELL-{}:actUlPtrs=false'.format(cell_id),
                'modify:NRCELL-{}:lteNrDssMode=DSS_Phase_3'.format(cell_id),
                'modify:NRCELL-{}/NRDSSLTE-1:lteNrDssDlRatio:minNrDssRatio={}'.format(cell_id, min_dss_ratio),
                'modify:NRCELL-{}/NRDSSLTE-1:lteNrDssDlRatio:maxNrDssRatio={}'.format(cell_id, max_dss_ratio),
            ]

        )
    return cell_specific_params


def activate_dss_on_lte_side(min_dss_ratio, max_dss_ratio, lte_bandwith=None, vm_ip=IP_VM_LTE,
                             dss_cells=LTE_CELLS, lnbts_id=LNBTS_ID):
    delta_filepath = prepare_dss_delta(min_dss_ratio, max_dss_ratio, lte_bandwith, dss_cells, lnbts_id, vm_ip=vm_ip)
    with AdminSession(remote_host=vm_ip) as admin:
        admin.perform_delta_recommissioning(delta_file=delta_filepath, skip_parameter_relation_errors=False,
                                            should_activate=True, timeout=300)


def deactivate_dss_on_lte_side(min_dss_ratio, max_dss_ratio, vm_ip=IP_VM_LTE, dss_cells=LTE_CELLS, lnbts_id=LNBTS_ID):
    output_dir = get_robot_output_dir()
    revert_delta = 'revert_delta_lte_{}_{}.json'.format(min_dss_ratio, max_dss_ratio)
    delta_filepath = os.path.join(output_dir, revert_delta)
    if not os.path.exists(delta_filepath):
        prepare_dss_delta(min_dss_ratio, max_dss_ratio, dss_cells=dss_cells, lnbts_id=lnbts_id, vm_ip=vm_ip)
    with AdminSession(remote_host=vm_ip) as admin:
        admin.perform_delta_recommissioning(delta_file=delta_filepath, skip_parameter_relation_errors=False,
                                            should_activate=True, timeout=300)


def activate_dss_on_5g_side(min_dss_ratio=70, max_dss_ratio=70):
    delta_filepath = prepare_nr_dss_delta(min_dss_ratio, max_dss_ratio)
    with AdminSession(remote_host=IP_VM_5G) as admin:
        admin.perform_delta_recommissioning(delta_file=delta_filepath, skip_parameter_relation_errors=False,
                                            should_activate=True, timeout=300)


def deactivate_dss_on_5g_side(min_dss_ratio=70, max_dss_ratio=70):
    output_dir = get_robot_output_dir()
    revert_delta = 'revert_delta_nr_{}_{}.json'.format(min_dss_ratio, max_dss_ratio)
    delta_filepath = os.path.join(output_dir, revert_delta)
    if not os.path.exists(delta_filepath):
        prepare_nr_dss_delta(min_dss_ratio, max_dss_ratio)
    with AdminSession(remote_host=IP_VM_5G) as admin:
        admin.perform_delta_recommissioning(delta_file=delta_filepath, skip_parameter_relation_errors=False,
                                            should_activate=True, timeout=300)


def prepare_nr_dss_delta(min_dss_ratio, max_dss_ratio):
    output_dir = get_robot_output_dir()
    current_scf = 'scf_nr.xml'
    target_scf = os.path.join(output_dir, 'scf_nr_{}_{}.xml'.format(min_dss_ratio, max_dss_ratio))
    delta_filepath = os.path.join(output_dir, 'delta_nr_{}_{}.json'.format(min_dss_ratio, max_dss_ratio))
    revert_delta = os.path.join(output_dir, 'revert_delta_nr_{}_{}.json'.format(min_dss_ratio, max_dss_ratio))

    current_scf = webui.download_current_scf(current_scf)

    new_scf = scf()
    new_scf.load_scf(current_scf)
    new_scf.modify_scf_element(value='true', dist_name='NRBTS-{}'.format(mrbts_id), p_name='actLteNrDss')
    cell_specific_params = _prepare_nr_cell_params(min_dss_ratio, max_dss_ratio)
    logger.debug("PARAMS: {}".format(cell_specific_params))
    new_scf.perform_scf_modification(cell_specific_params)
    new_scf.save_scf(target_scf)
    new_scf.calculate_delta_scf(target_scf_path=target_scf, actual_scf_path=current_scf,
                                delta_scf_path=delta_filepath)

    new_scf.calculate_delta_scf(target_scf_path=current_scf, actual_scf_path=target_scf,
                                delta_scf_path=revert_delta)
    os.remove(current_scf)
    os.remove(target_scf)
    return delta_filepath


def prepare_prb_blanking_params():
    output_dir = get_robot_output_dir()
    current_scf = 'scf_before_prb.xml'
    target_scf = os.path.join(output_dir, 'scf_prb.xml')
    delta_filepath = os.path.join(output_dir, 'delta_prb.json')
    revert_delta = os.path.join(output_dir, 'revert_delta_prb.json')

    current_scf = webui.download_current_scf(current_scf)

    new_scf = scf()
    new_scf.load_scf(current_scf)
    common_params = []
    cell_specific_params = _prepare_prb_cell_params()
    params = common_params + cell_specific_params
    logger.debug("PARAMS: {}".format(params))
    new_scf.perform_scf_modification(params)
    new_scf.save_scf(target_scf)
    new_scf.calculate_delta_scf(target_scf_path=target_scf, actual_scf_path=current_scf,
                                delta_scf_path=delta_filepath)

    new_scf.calculate_delta_scf(target_scf_path=current_scf, actual_scf_path=target_scf,
                                delta_scf_path=revert_delta)
    os.remove(current_scf)
    os.remove(target_scf)
    return delta_filepath


def _prepare_prb_cell_params():
    cell_specific_params = []
    for cell_id in (2, 3):
        cell_specific_params.extend(
            [
                'modify:NRCELL-{}:msg1FrequencyStart=8'.format(cell_id),
                'modify:NRCELL-{}:actPRBBlanking=true'.format(cell_id),
                'modify:NRCELL-{}:nbrOfBlankedPRBsHighEdgeDL=1'.format(cell_id),
                'modify:NRCELL-{}:nbrOfBlankedPRBsLowEdgeUL=1'.format(cell_id)
            ]

        )
    return cell_specific_params


def prepare_prb_blanking_params_lte():
    output_dir = get_robot_output_dir()
    current_scf = 'scf_before_prb_lte.xml'
    target_scf = os.path.join(output_dir, 'scf_prb_lte.xml')
    delta_filepath = os.path.join(output_dir, 'delta_prb_lte.json')
    revert_delta = os.path.join(output_dir, 'revert_delta_prb_lte.json')

    current_scf = get_scf_from_lte(output_dir, current_scf, IP_VM_LTE)

    new_scf = scf()
    new_scf.load_scf(current_scf)
    common_params = []
    cell_specific_params = _prepare_prb_cell_params_lte()
    params = common_params + cell_specific_params
    logger.debug("PARAMS: {}".format(params))
    new_scf.perform_scf_modification(params)
    new_scf.save_scf(target_scf)
    new_scf.calculate_delta_scf(target_scf_path=target_scf, actual_scf_path=current_scf,
                                delta_scf_path=delta_filepath)

    new_scf.calculate_delta_scf(target_scf_path=current_scf, actual_scf_path=target_scf,
                                delta_scf_path=revert_delta)
    os.remove(current_scf)
    os.remove(target_scf)
    return delta_filepath


def _prepare_prb_cell_params_lte():
    cell_specific_params = []
    for cell_id in LTE_CELLS:
        cell_specific_params.extend(
            [
                'modify:LNCEL-{}:blankedPucch=10'.format(cell_id),
            ]

        )
    return cell_specific_params


def activate_prb_blanking():
    delta_filepath = prepare_prb_blanking_params()
    with AdminSession(remote_host=IP_VM_5G) as admin:
        admin.perform_delta_recommissioning(delta_file=delta_filepath, skip_parameter_relation_errors=False,
                                            should_activate=True, timeout=300)
    delta_filepath_lte = prepare_prb_blanking_params_lte()
    with AdminSession(remote_host=IP_VM_LTE) as admin:
        admin.perform_delta_recommissioning(delta_file=delta_filepath_lte, skip_parameter_relation_errors=False,
                                            should_activate=True, timeout=300)
    webui.wait_for_all_cells_on_air_state(timeout=160)
    time.sleep(100)


def deactivate_prb_blanking():
    output_dir = get_robot_output_dir()
    delta_filepath = os.path.join(output_dir, 'revert_delta_prb.json')
    if not os.path.exists(delta_filepath):
        prepare_prb_blanking_params()
    with AdminSession(remote_host=IP_VM_5G) as admin:
        admin.perform_delta_recommissioning(delta_file=delta_filepath, skip_parameter_relation_errors=False,
                                            should_activate=True, timeout=300)
    delta_filepath_lte = os.path.join(output_dir, 'revert_delta_prb_lte.json')
    with AdminSession(remote_host=IP_VM_LTE) as admin:
        admin.perform_delta_recommissioning(delta_file=delta_filepath_lte, skip_parameter_relation_errors=False,
                                            should_activate=True, timeout=300)


class DeltaCreator:
    def __init__(self, name, bts_type):
        self.name = name
        self.common_params = None
        self.cell_params = None
        self.output_dir = self.get_output_dir()
        self.bts_type = bts_type
        self.scf = scf()

    @property
    def current_scf(self):
        return '/tmp/scf_{}_original.xml'.format(self.name)

    @property
    def target_scf(self):
        return '{}/scf_{}_modified.xml'.format(self.output_dir, self.name)

    @property
    def target_delta(self):
        return '{}/delta_{}.json'.format(self.output_dir, self.name)

    @property
    def revert_delta(self):
        return '{}/revert_delta_{}.json'.format(self.output_dir, self.name)

    def get_output_dir(self):
        if not self.output_dir:
            return get_robot_output_dir()

    def set_common_params(self, common_params):
        self.common_params = common_params

    def set_cell_params(self, cell_params):
        self.cell_params = cell_params

    def _collect_scf(self):
        if self.bts_type == 'NR':
            return webui.download_current_scf(self.target_scf)
        elif self.bts_type == 'LTE':
            return get_scf_from_lte(self.output_dir, self.target_scf, IP_VM_LTE)
        else:
            raise RuntimeError("Incorrect BTS type! Allowed types: NR, LTE.")

    def _load_scf(self):
        self.scf.load_scf(self.current_scf)
        return self.scf

    def create_delta(self):
        self._collect_scf()
        params = self.common_params + self.cell_params
        self.scf.perform_scf_modification(params)
        self.scf.save_scf(self.target_scf)
        self.scf.calculate_delta_scf(target_scf_path=self.target_scf, actual_scf_path=self.current_scf,
                                     delta_scf_path=self.target_delta)

        self.scf.calculate_delta_scf(target_scf_path=self.current_scf, actual_scf_path=self.target_scf,
                                     delta_scf_path=self.revert_delta)

    def _cleanup(self):
        os.remove(self.current_scf)
        os.remove(self.target_scf)


def activate_dss_on_lte_side_new(min_dss_ratio, max_dss_ratio, lte_bandwith=None):
    delta_filepath = prepare_dss_delta(min_dss_ratio, max_dss_ratio, lte_bandwith)
    with AdminSession() as admin:
        admin.perform_delta_recommissioning(delta_file=delta_filepath, skip_parameter_relation_errors=False,
                                            should_activate=True, timeout=300)


def deactivate_dss_on_lte_side_new(min_dss_ratio, max_dss_ratio):
    output_dir = get_robot_output_dir()
    revert_delta = 'revert_delta_lte_{}_{}.json'.format(min_dss_ratio, max_dss_ratio)
    delta_filepath = os.path.join(output_dir, revert_delta)
    if not os.path.exists(delta_filepath):
        prepare_dss_delta(min_dss_ratio, max_dss_ratio)
    with AdminSession() as admin:
        admin.perform_delta_recommissioning(delta_file=delta_filepath, skip_parameter_relation_errors=False,
                                            should_activate=True, timeout=300)
