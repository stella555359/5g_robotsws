import logging
import os
import json
from taf.config.scf import scf
from taf.rfrl.utilities.robot.general import get_builtin_value, set_robot_test_variable
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from rmod_deltas import rmod_deltas


def get_all_ru_ids():
    ru_ids = GnbRuOperations()._get_all_radio_ids()
    return ru_ids['rmod']


def backup_bts_configuration_before_test():
    scf_dir = os.path.join(get_builtin_value('LOG_PATH'), 'scf')
    scf_path = GnbDuOperations().get_bts_configuration_file(filename='bts_config.xml', local_dir=scf_dir)

    set_robot_test_variable('scf_dir', scf_dir)
    set_robot_test_variable('full_bts_config', scf_path)


def delete_rmod_from_configuration(rmod_id):
    delete_delta = rmod_deltas['del_rmod{}'.format(rmod_id)]
    GnbCommissioning().perform_bts_delta_commissioning(delete_delta)

    logging.debug("Download SCF configuration after deleting RMOD-{}".format(rmod_id))
    scf_path = GnbDuOperations().get_bts_configuration_file(filename='bts_config_rmod{}_deleted.xml'.format(rmod_id),
                                                            local_dir=get_builtin_value('scf_dir'))
    logging.debug("Configuration saved in {}".format(scf_path))

    logging.debug("Generate delta for adding RMOD-{}".format(rmod_id))
    add_rmod_delta = os.path.join(get_builtin_value('scf_dir'), 'add_rmod{}_delta.json'.format(rmod_id))
    scf().calculate_delta_scf(actual_scf_path=scf_path,
                              target_scf_path=get_builtin_value('full_bts_config'),
                              delta_scf_path=add_rmod_delta)
    logging.debug("Delta saved in {}".format(add_rmod_delta))
    set_robot_test_variable('add_rmod{}_delta'.format(rmod_id), add_rmod_delta)


def add_rmod_to_configuration(rmod_id):
    add_delta = get_builtin_value('add_rmod{}_delta'.format(rmod_id))
    with open(add_delta, 'r') as file:
        data = json.load(file)
        GnbCommissioning().perform_bts_delta_commissioning(data, adjust_dist_name=False)


# TODO Move to RFRL
def verify_radio_unit_is_offline(bts_id=0, du_id=0, rmod_id=1, radio_type='rmod'):
    """
    Verify RU is offline.

    :param bts_id:  ID of gNB/eNB, default 0
    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    :param rmod_id:                ID of radio unit. Default: 1
    :param radio_type:           "rmod" or "asirmod"
    :return:        None
    """

    ru_name = "{}-{}".format(radio_type.upper(), rmod_id)
    # podobno nie zawsze jest widoczne w runtime
    GnbRuOperations().verify_radio_unit_statuses(bts_id=bts_id, du_id=du_id, ru_id=rmod_id, radio_type=radio_type,
                                                 availability_status="offline",
                                                 operational_state="disabled",
                                                 administrative_state="unlocked",
                                                 procedural_status="configured")
    logging.info("RU '{}' is 'offline'".format(ru_name))
