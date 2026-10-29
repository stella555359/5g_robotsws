import re
import logging
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.RRM.resources.etws_cmas.yaml_loader import load_ues
from testsuite.Wroclaw.RRM.resources.rrm_fixture import get_robot_variable


def get_apn_id_from_query(apn_data, apn_name, plmn):
    """
    Gets an APN ID from the string returned by adb shell command
    content query --uri content://telephony/carriers --where "name='APN_NAME'"
    :param apn_data: Apn data get by adb shell by above query
    """
    search_result = re.search('_id=(.*), name={}, numeric={}'.format(apn_name, plmn), apn_data)
    apn_id = search_result.group(1) if search_result is not None else None
    logging.info('APN id from content query is equal %s', apn_id)
    return apn_id


def find_ue_by_ue_alias(ue_name):
    ues = load_ues()
    return next((ue for ue in ues if ue_name in ue.capabilities), None)


def enable_band_config(ue_name, band_config='DEFAULT', service_code='*#2263#'):
    current_setting = get_robot_variable(f"${{CURRENT_{ue_name}_SCF}}")
    if current_setting != band_config:
        ue = find_ue_by_ue_alias(ue_name)
        try:
            BuiltIn().wait_until_keyword_succeeds('2x', '2s',
                                                  'ute_ue.set_service_mode',
                                                  ue_name, service_code, ue.bands[band_config])
            BuiltIn().set_suite_variable(f"${{CURRENT_{ue_name}_CONFIG}}", band_config)
        except AttributeError:
            raise RuntimeError(f"Selected band_config {band_config} does not exist in ue config! "
                               f"Possible bands configs: {ue.bands.keys()}")
    else:
        logger.info("Band config is the same as expected.", also_console=True)


def get_imsi(ue_name):
    ue = find_ue_by_ue_alias(ue_name)
    return ue.imsi
