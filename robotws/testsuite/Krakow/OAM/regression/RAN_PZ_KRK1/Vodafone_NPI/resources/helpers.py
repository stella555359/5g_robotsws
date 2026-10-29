import logging
from taf.rfrl.utilities.tl_config import (get_count_of_radios,
                                          get_radio,
                                          get_testline_configuration_directory_path,
                                          get_netact_ssh_credentials,
                                          get_netact_web_credentials)
from pathlib import Path
from robot.libraries.BuiltIn import BuiltIn


def prepare_pdus_for_radios():
    ru_pdu_mapping = []
    number_of_radios = get_count_of_radios()
    logging.warning(number_of_radios)
    for i in range(number_of_radios):
        ru = get_radio(ru_id=i)
        ru_pdu_mapping.append({
            ru.serial_number: ru.pdu_port
        })
    logging.warning(ru_pdu_mapping)
    return ru_pdu_mapping


def load_certificates_configuration(prefix_tag=None):
    if not prefix_tag:
        logging.info('No certificates given, skipping...')
        BuiltIn().set_global_variable("$CERTIFICATES", None)
        return

    tl_config_path = Path(get_testline_configuration_directory_path())

    for path in tl_config_path.iterdir():
        if path.match(f'{prefix_tag}_certificates.yaml') or path.match(f'{prefix_tag}_certificates.yml'):
            logging.info(f'Importing variables from: {path}')
            BuiltIn().import_variables(path)
            break
    else:
        raise ValueError(f'No _certificates file for prefix_tag={prefix_tag} inside {tl_config_path}')


def prepare_netact_dict(netact_name=None):
    if netact_name:
        try:
            ssh_info = get_netact_ssh_credentials()
            netact_dict = {
                'name': netact_name,
                'netact_host_ip': ssh_info['addr'],
                'username': ssh_info['username'],
                'password': ssh_info['password']
            }
            BuiltIn().set_global_variable("$NETACT_DICT", netact_dict)
        except AttributeError as e:
            logging.warning(e)
            BuiltIn().set_global_variable("$NETACT_DICT", None)
