import os
import testsuite.Wroclaw.RRM.resources.webUI_operations as webui
from taf.config.scf import scf
from testsuite.Wroclaw.RRM.resources.rrm_fixture import get_robot_variable
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession

IP_VM_5G = '127.0.0.1'


def prepare_beamforming_configuration(cell_ids):
    cell_ids = cell_ids.split(',')
    output_dir = get_robot_variable("${LOG_PATH}")
    current_scf = 'scf_nr.xml'
    target_scf = os.path.join(output_dir, 'scf_nr_beamforming.xml')
    delta_filepath = os.path.join(output_dir, 'delta_nr_beamforming.json')
    revert_delta = os.path.join(output_dir, 'revert_delta_nr_beamforming.json')

    current_scf = webui.download_current_scf(current_scf)

    new_scf = scf()
    new_scf.load_scf(current_scf)
    cell_specific_params = _prepare_beamforming_for_nr_cell(cell_ids)
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


def _prepare_beamforming_for_nr_cell(cell_ids):
    cell_specific_params = []
    logger.info("Cell ids: {}".format(cell_ids), also_console=True)
    for cell_id in cell_ids:
        cell_specific_params.extend(
            [
                'modify:NRCELL-{}:actBeamforming=false'.format(cell_id),
                'modify:NRCELL-{}:numberOfRxBeamforming=2Rx'.format(cell_id),
                'modify:NRCELL-{}:basicBeamSet=beamSet_1'.format(cell_id),
                'modify:NRCELLGRP-{}:numberOfTransmittedSsBlocks=1 beam'.format(cell_id),
            ]
        )
    return cell_specific_params


def deactivate_beamforming(cell_ids):
    delta_filepath = prepare_beamforming_configuration(cell_ids)
    with AdminSession(remote_host=IP_VM_5G) as admin:
        admin.perform_delta_recommissioning(delta_file=delta_filepath, skip_parameter_relation_errors=False,
                                            should_activate=True, timeout=300)


def restore_beamforming(cell_ids):
    output_dir = get_robot_variable("${LOG_PATH}")
    revert_delta = 'revert_delta_nr_beamforming.json'
    delta_filepath = os.path.join(output_dir, revert_delta)
    if not os.path.exists(delta_filepath):
        prepare_beamforming_configuration(cell_ids)
    with AdminSession(remote_host=IP_VM_5G) as admin:
        admin.perform_delta_recommissioning(delta_file=delta_filepath, skip_parameter_relation_errors=False,
                                            should_activate=True, timeout=300)
