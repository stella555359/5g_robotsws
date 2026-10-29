import os
import testsuite.Wroclaw.RRM.resources.webUI_operations as webui
from taf.config.scf import scf
from testsuite.Wroclaw.RRM.resources.rrm_fixture import get_robot_variable
from robot.api import logger
from beamforming import AdminSession, IP_VM_5G
from taf.internal.sbts.admin.exceptions import AdminApiProcedureFailureException
from variables_2640 import SCELLS_IDS, FFT_SCELLS, FTT_SCELLS


def prepare_scell_configuration(scell_ids):
    output_dir = get_robot_variable("${LOG_PATH}")
    current_scf = 'scf_nr.xml'
    target_scf = os.path.join(output_dir, 'scf_nr_scell_config.xml')
    delta_filepath = os.path.join(output_dir, 'delta_nr_scell_config.json')
    revert_delta = os.path.join(output_dir, 'revert_delta_nr_scell_config.json')

    current_scf = webui.download_current_scf(current_scf)

    new_scf = scf()
    new_scf.load_scf(current_scf)
    scell_params = _prepare_scells(scell_ids)
    logger.debug("PARAMS: {}".format(scell_params))
    new_scf.perform_scf_modification(scell_params)
    new_scf.save_scf(target_scf)
    new_scf.calculate_delta_scf(target_scf_path=target_scf, actual_scf_path=current_scf,
                                delta_scf_path=delta_filepath)

    new_scf.calculate_delta_scf(target_scf_path=current_scf, actual_scf_path=target_scf,
                                delta_scf_path=revert_delta)
    os.remove(current_scf)
    os.remove(target_scf)
    return delta_filepath


def _prepare_scells(scell_ids):
    cell_specific_params = []
    logger.info("Cell ids: {}".format(scell_ids), also_console=True)
    for cell_id in scell_ids:
        cell_specific_params.extend(
            [
                'modify:NRCELL-{}:maxNumOfSCellAlloc=250'.format(cell_id),
            ]

        )
    for cell_id in SCELLS_IDS.difference(scell_ids):
        cell_specific_params.extend(
            [
                'modify:NRCELL-{}:maxNumOfSCellAlloc=0'.format(cell_id),
            ]

        )
    return cell_specific_params


def enable_ftt_configuration():
    _change_scell_configuration(FTT_SCELLS)


def enable_fft_configuration():
    _change_scell_configuration(FFT_SCELLS)


def _change_scell_configuration(configuration):
    delta_filepath = prepare_scell_configuration(configuration)
    with AdminSession(remote_host=IP_VM_5G) as admin:
        try:
            admin.perform_delta_recommissioning(delta_file=delta_filepath, skip_parameter_relation_errors=False,
                                                should_activate=True, timeout=300)
        except AdminApiProcedureFailureException as e:
            if "no modified objects!" not in e.message:
                raise RuntimeError("Delta commissioning was not performed! {}".format(e.message))
            else:
                logger.debug("Scell configuration is the same.. Ignoring delta..")

    os.remove(delta_filepath)
