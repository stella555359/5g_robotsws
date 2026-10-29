import os
import logging
from moler.device import DeviceFactory
from moler.exceptions import CommandFailure
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.bts.devices.exceptions import FileNotFound
from taf.rfrl.utilities import tl_config
from taf.rfrl.bts.connections import device_aliases as connection_names
import taf.rfrl.bts.devices.ru.ru_operations as ru_functions


@load_moler_configuration_from_tl()
def make_backup_of_file(file_path, bts_id=0, du_id=0, ru_id=0):
    """
    Make backup of file
    :param file_path: path to file to backup
    :param bts_id: id of BTS related to configuration
    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    :param ru_id:  id of Radio Unit related to configuration
    :return:
    """
    ru = DeviceFactory.get_device(name=connection_names.ssh_bts_du_ru.format("GNB", bts_id, du_id, ru_id))
    ru.goto_state(state="RU")

    content_of_original_file = ru.get_cmd(cmd_name="cat", cmd_params={'path': file_path})()
    logging.debug("Content of original file {} before create backup: {}".format(file_path, content_of_original_file))

    backup_file = ru.get_cmd(cmd_name="cp", cmd_params={'src': file_path, 'dst': "{}_bckp".format(file_path)})
    ru_functions.GenericRuOperations()._run_cmd_with_sudo_su(ru_obj=ru, cmd=backup_file)


@load_moler_configuration_from_tl()
def change_values_of_ru_config_to_null(files, bts_id=0, du_id=0, ru_id=0):
    """
    Change values of config files of Radio Unit to null
    :param files: path to configuration files of Radio Unit
    :param bts_id: id of BTS related to configuration
    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    :param ru_id:  id of Radio Unit related to configuration
    :return:
    """
    ru = DeviceFactory.get_device(name=connection_names.ssh_bts_du_ru.format("GNB", bts_id, du_id, ru_id))
    ru.goto_state(state="RU")
    change_values_to_null = ru.get_cmd(cmd_name="sed", cmd_params={'options': r'-i -e "s/\"RF.*\"/\"null\"/" '
                                                                              r'-e "s/\"5G.*\"/\"null\"/"',
                                                                   'input_files': files})
    ru_functions.GenericRuOperations()._run_cmd_with_sudo_su(ru_obj=ru, cmd=change_values_to_null)


@load_moler_configuration_from_tl()
def restore_backup_file(file_path, bts_id=0, du_id=0, ru_id=0):
    """
    Restore backup of file
    :param file_path: path to file to backup
    :param bts_id: id of BTS related to configuration
    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    :param ru_id:  id of Radio Unit related to configuration
    :return:
    """
    ru = DeviceFactory.get_device(name=connection_names.ssh_bts_du_ru.format("GNB", bts_id, du_id, ru_id))
    ru.goto_state(state="RU")
    remove_source_file = ru.get_cmd(cmd_name="rm", cmd_params={'options': "-f", 'file': "{}".format(file_path)})
    restore_original_file = ru.get_cmd(cmd_name="mv", cmd_params={'src': "{}_bckp".format(file_path),
                                                                  'dst': file_path})
    find_backup_file = ru.get_cmd(cmd_name="find", cmd_params={'options': "{}_bckp".format(file_path)})
    try:
        find_backup_file()
    except CommandFailure:
        raise FileNotFound("There is no backup file: {}_bckp".format(file_path))

    ru_functions.GenericRuOperations()._run_cmd_with_sudo_su(ru_obj=ru, cmd=remove_source_file)
    ru_functions.GenericRuOperations()._run_cmd_with_sudo_su(ru_obj=ru, cmd=restore_original_file)

    content_of_original_file = ru.get_cmd(cmd_name="cat", cmd_params={'path': file_path})()
    logging.debug("Content of original file {} after restore backup {}".format(file_path,
                                                                               content_of_original_file))


@load_moler_configuration_from_tl()
def make_backup_all_files(files_paths, bts_id=0, du_id=0):
    """
        Make backup of files
        :param files_paths: path to files to backup
        :param bts_id: id of BTS related to configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return:
        """
    all_radio_ids = tl_config.get_count_of_radios(bts_id=bts_id, du_id=du_id)
    for radio_id in range(all_radio_ids):
        for file_path in files_paths:
            make_backup_of_file(file_path=file_path, bts_id=bts_id, du_id=du_id, ru_id=radio_id)


@load_moler_configuration_from_tl()
def change_values_of_all_rus_config_to_null(files_paths, bts_id=0, du_id=0):
    """
        Change values of config files of Radio Unit to null
        :param files_paths: path to files to change values to NULL
        :param bts_id: id of BTS related to configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return:
        """
    all_radio_ids = tl_config.get_count_of_radios(bts_id=bts_id, du_id=du_id)
    for radio_id in range(all_radio_ids):
        change_values_of_ru_config_to_null(files=files_paths, bts_id=bts_id,
                                           du_id=du_id, ru_id=radio_id)


@load_moler_configuration_from_tl()
def restore_all_backup_files(files_paths, bts_id=0, du_id=0):
    """
        Restore backup of file
        :param files_paths: path to files to backup
        :param bts_id: id of BTS related to configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return:
        """
    all_radio_ids = tl_config.get_count_of_radios(bts_id=bts_id, du_id=du_id)
    for radio_id in range(all_radio_ids):
        for file_path in files_paths:
            restore_backup_file(file_path=file_path, bts_id=bts_id, du_id=du_id, ru_id=radio_id)


@load_moler_configuration_from_tl()
def get_ru_files_from_path(directions, bts_id=0, du_id=0, ru_id=0):
    """
        Return all files from given direction
        :param directions: files paths
        :param bts_id: id of BTS related to configuration
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param ru_id:  id of Radio Unit related to configuration
        :return: only_files_dir: List of files paths under given directions
    """
    ru = DeviceFactory.get_device(name=connection_names.ssh_bts_du_ru.format("GNB", bts_id, du_id, ru_id))
    ru.goto_state(state="RU")
    paths = ' '.join(directions)
    ru_files = ru.get_cmd(cmd_name="find", cmd_params={'options': "{} -maxdepth 1 -type f".format(paths)})()
    return ru_files['RESULT']
