import os
import testsuite.Wroclaw.RRM.resources.webUI_operations as webui
from taf.config.scf import scf
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from ca_variables import IP_VM_5G
from testsuite.Wroclaw.RRM.resources.preconditions_py import mrbts_id
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import get_robot_output_dir

DEFAULT_CELL_IDS = (100, 101, 106)


def prepare_buffer_based_configuration(scell_act_method, num_scells, cell_ids=DEFAULT_CELL_IDS):
    """
    :param scell_act_method: bufferAndRLQualityBased or bufferBased
    :return:
    """
    if not isinstance(cell_ids, tuple):
        cell_ids = cell_ids.split(',')
    output_dir = get_robot_output_dir()
    current_scf = 'scf_nr.xml'
    target_scf = os.path.join(output_dir, 'scf_nr_{}.xml'.format(scell_act_method))
    delta_filepath = os.path.join(output_dir, 'delta_nr_{}.json'.format(scell_act_method))
    revert_delta = os.path.join(output_dir, 'revert_delta_nr_{}.json'.format(scell_act_method))

    current_scf = webui.download_current_scf(current_scf)

    new_scf = scf()
    new_scf.load_scf(current_scf)
    new_scf.modify_scf_element(value=scell_act_method, dist_name='NRBTS-{}'.format(mrbts_id),
                               p_name='sCellActivationMethod')
    cell_specific_params = _prepare_nr_cell_for_buffer_based(num_scells, cell_ids)
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


def _prepare_nr_cell_for_buffer_based(num_scells, cell_ids):
    cell_specific_params = []
    logger.info("Cell ids: {}".format(cell_ids), also_console=True)
    for cell_id in cell_ids:
        cell_specific_params.extend(
            [
                'modify:NRCELL-{}:sCellDeactivationTimerGNB=ms320'.format(cell_id),
                'modify:NRCELL-{}:iniNumSCellsToActivate={}'.format(cell_id, num_scells)
            ]

        )
    return cell_specific_params


def activate_buffer_based_configuration(scell_act_method, num_scells=1, cell_ids=DEFAULT_CELL_IDS):
    delta_filepath = prepare_buffer_based_configuration(scell_act_method, num_scells, cell_ids)
    with AdminSession(remote_host=IP_VM_5G) as admin:
        admin.perform_delta_recommissioning(delta_file=delta_filepath, skip_parameter_relation_errors=False,
                                            should_activate=True, timeout=300)


def deactivate_buffer_based_configuration(scell_act_method, num_scells=1, cell_ids=DEFAULT_CELL_IDS):
    output_dir = get_robot_output_dir()
    revert_delta = 'revert_delta_nr_{}.json'.format(scell_act_method)
    delta_filepath = os.path.join(output_dir, revert_delta)
    if not os.path.exists(delta_filepath):
        prepare_buffer_based_configuration(scell_act_method, num_scells, cell_ids=cell_ids)
    with AdminSession(remote_host=IP_VM_5G) as admin:
        admin.perform_delta_recommissioning(delta_file=delta_filepath, skip_parameter_relation_errors=False,
                                            should_activate=True, timeout=300)
