import os
import logging
import time
import yaml
import testsuite.Bangalore.ORAN.resources.python.Macro.\
    Python.helpers.tl_config as tl_config
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    bts.common.scf import GnbScf
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    bts.common.bbu import GnbBbu
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    bts.common.cu import GnbCu
from testsuite.Bangalore.ORAN.resources.python.Macro.Python\
    .bts.common.alarm import GnbAlarm
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    bts.common.log import GnbLog
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.\
    bts.common.sw_update import GnbSwUpdate
from taf.internal.sbts.admin.exceptions \
    import (AdminApiConnectionClosedException,
            AdminApiProcedureFailureException,
            AdminApiProcedureTimeoutException)
from testsuite.Bangalore.ORAN.resources.python.Macro.Python \
    import connection_names
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.utilities \
    import get_commissioning_dir, \
    get_custom_config_yaml_path, get_repository_path
from testsuite.Bangalore.ORAN.resources.python.Macro.Python.exceptions \
    import WrongApiException


def perform_full_commissioning_on_classical_gnb(bts_id=0, scf_path=None,
                                                prefix_tag=None,
                                                awaiting_time=600,
                                                readiness_timeout=600,
                                                custom_config=False):
    """
    Perform full commissioning on gNB
    :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
    :param scf_path: scf_path to gNB - if not set then default will be selected
    :param prefix_tag: scf_path to gNB - if scf_path not passed then default
     with specific prefix_tag will be selected
    :param awaiting_time: Time in seconds to wait for the Incompatible software
    alarm to occur
    :param readiness_timeout: Time in seconds to wait for BTS availability
    :param custom_config: Flag for enabling scf collection from custom-config
     directory
    """
    choosing_fun = _get_default_scf_for_du_from_yaml if custom_config else \
        _get_default_scf_for_classical_gnb
    scf_path = scf_path if scf_path else choosing_fun(bts_id=bts_id,
                                                      prefix_tag=prefix_tag)[0]
    GnbScf().perform_bts_full_commissioning(
        scf_file=scf_path,
        bts_id=bts_id,
        skip_parameter_relation_errors=True,
        should_activate=True,
        validate_scf=False,
        timeout=300,
        du_id=0)
    _verify_if_another_sw_upload_is_needed(awaiting_time=awaiting_time,
                                           readiness_timeout=readiness_timeout,
                                           bts_id=0)


def perform_full_commissioning_on_cloud_gnb(bts_id=0, cu_scf_path=None,
                                            du_scf_path=None,
                                            prefix_tag=None,
                                            awaiting_time=600,
                                            readiness_timeout=600,
                                            custom_config=False,
                                            except_ongoing_operation=False):
    """
    Perform full commissioning on cloud gNB(CU and all DUs)
    :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
    :param cu_scf_path: scf_path to CU - Common Unit - if not set then default
    will be selected
    :param du_scf_path: list of scf_path to all DUs -  if not set then default
    will be selected
    :param prefix_tag: scf_path to gNB - if scf_path not passed then default
    with specific tag will be selected
    :param awaiting_time: Time in seconds to wait for the Incompatible software
    alarm to occur
    :param readiness_timeout: Time in seconds to wait for BTS availability
    :param custom_config: Flag for enabling scf collection from custom-config
    directory
    :param except_ongoing_operation: set to True if you want to except
     test failure
    due to ongoing operation
    """
    perform_full_commissioning_on_all_dus(bts_id=bts_id, scf_path=du_scf_path,
                                          prefix_tag=prefix_tag,
                                          custom_config=custom_config)
    perform_full_commissioning_on_cu(
        bts_id=bts_id, scf_path=cu_scf_path,
        prefix_tag=prefix_tag,
        custom_config=custom_config,
        except_ongoing_operation=except_ongoing_operation)
    _verify_if_another_sw_upload_is_needed(awaiting_time=awaiting_time,
                                           readiness_timeout=readiness_timeout,
                                           bts_id=bts_id)


def perform_commissioning_on_gnb_to_onair_state(bts_id=0, cu_scf_path=None,
                                                du_scf_path=None,
                                                prefix_tag=None,
                                                readiness_timeout=600,
                                                awaiting_time=600):
    """
    Perform full commissioning on Cloud or Classical gNB with CU error fix and
    same SW upload in case of
    'Incompatible SW version detected' alarm detection.
    :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
    :param cu_scf_path: scf_path to CU - Common Unit - if not set then default
    will be selected
    :param du_scf_path: list of scf_path to all DUs -  if not set then default
    will be selected
    :param prefix_tag: scf_path to gNB - if scf_path not passed then default
    with specific tag will be selected
    :param readiness_timeout: Time in seconds to wait for BTS availability
    :param awaiting_time: Time in seconds to wait for the Incompatible software
    alarm to occur
    """
    if tl_config.is_testline_of_cloud_type(bts_id=bts_id):
        cu_path = cu_scf_path if cu_scf_path else _get_default_scf_for_cu(
            bts_id=bts_id,
            prefix_tag=prefix_tag)
        cu = GnbCu()
        cu.validate_cu_configuration(file_path=cu_path)
        cu.fix_errors_with_uploaded_configuration(True, True, 60, True, False,
                                                  bts_id)
        cu.activate_planned_cu_configuration(cu.get_latest_plan_id())
        perform_full_commissioning_on_all_dus(bts_id=bts_id,
                                              scf_path=du_scf_path,
                                              prefix_tag=prefix_tag,
                                              timeout=900)
        _wait_for_admin_api_connection(bts_id=bts_id)
        _verify_if_another_sw_upload_is_needed(
            awaiting_time=awaiting_time,
            readiness_timeout=readiness_timeout,
            bts_id=bts_id)
    else:
        _wait_for_admin_api_connection(bts_id=bts_id)
        perform_full_commissioning_on_classical_gnb(
            bts_id=bts_id,
            scf_path=du_scf_path,
            prefix_tag=prefix_tag,
            awaiting_time=awaiting_time,
            custom_config=False)
    wait_for_onair_on_all_dus(bts_id=0, timeout=30 * 60)
    GnbLog().setup_btslog_collector()


def perform_full_commissioning_on_cu(bts_id=0, scf_path=None, prefix_tag=None,
                                     custom_config=False,
                                     except_ongoing_operation=False):
    """
    Perform full commissioning on all DUs under CU
    :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
    :param scf_path: scf_path to CU - Common Unit - if not set then default
    will be selected
    :param prefix_tag: scf_path to gNB - if scf_path not passed then default
    with specific prefix_tag will be selected
    :param custom_config: Flag for enabling scf collection from custom-config
    directory
    :param except_ongoing_operation: set to True if you want to except test
    failure due to ongoing operation
    """
    choosing_fun = _get_default_scf_for_cu_from_yaml if custom_config \
        else _get_default_scf_for_cu
    scf_path = scf_path if scf_path else choosing_fun(bts_id=bts_id,
                                                      prefix_tag=prefix_tag)[0]
    GnbCu().perform_cu_commissioning(
        bts_id=bts_id, file_path=scf_path,
        except_ongoing_operation=except_ongoing_operation)


def perform_full_commissioning_on_all_dus(bts_id=0, scf_path=None,
                                          prefix_tag=None,
                                          timeout=300,
                                          custom_config=False):
    """
    Perform full commissioning on all DUs under CU
    :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
    :param scf_path: list of scf_path to all dus  - if not set then default
    will be selected
    :param prefix_tag: scf_path to gNB - if scf_path not passed then default
    with specific prefix_tag will be selected
    :param timeout: timeout for gNB commissioning
    :param custom_config: Flag for enabling scf collection from custom-config
    directory

    """
    choosing_fun = _get_default_scf_for_du_from_yaml if custom_config \
        else _get_default_scf_for_dus
    scf_paths = scf_path if scf_path else choosing_fun(bts_id=bts_id,
                                                       prefix_tag=prefix_tag)
    for du_id, scf_path in enumerate(scf_paths):
        GnbScf().perform_bts_full_commissioning(
            scf_file=scf_path,
            bts_id=bts_id,
            skip_parameter_relation_errors=True,
            should_activate=True,
            validate_scf=False,
            timeout=timeout,
            du_id=du_id)


def upload_swconfig_on_classical_gnb(bts_id=0, sw_config_path=None,
                                     prefix_tag=None,
                                     reboot_after_upload=False):
    """
    Upload swconfig.txt file to gNB
    :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
    :param sw_config_path: path to swconfig.txt to be uploaded  -
    if not set then default will be selected
    :param prefix_tag: prefix of swconfig.txt file - if sw_config_path
    not passed then default with specific prefix_tag will be selected
    :param reboot_after_upload: flag to trigger gNB reboot or not after
    swconfig.txt upload
    """
    sw_config_path = sw_config_path if sw_config_path \
        else _get_default_swconfig_for_classical_gnb(bts_id=bts_id,
                                                     prefix_tag=prefix_tag)
    GnbBbu().upload_swconfig(sw_config_path=sw_config_path, bts_id=bts_id,
                             du_id=0,
                             reboot_after_upload=reboot_after_upload)


def wait_for_onair_on_all_dus(bts_id=0, timeout=20 * 60):
    """
    Wait for all DUs be onAir
    :param bts_id: BTS(eNB/gNB) id - related to Test Line configuration.
    :param timeout:  Time in seconds to wait for site to go onair
    """
    number_of_dus = tl_config.get_count_of_distributed_units(bts_id=bts_id)
    for du_id in range(number_of_dus):
        GnbBbu().wait_for_site_to_be_onair(bts_id=bts_id,
                                           du_id=du_id,
                                           timeout=timeout)


def _get_default_scf_for_dus(bts_id=0, prefix_tag=None):
    number_of_dus = tl_config.get_count_of_distributed_units(bts_id=bts_id)
    commission_dir = get_commissioning_dir()
    prefix = '{}_'.format(prefix_tag) if prefix_tag else ''
    scf_path = os.path.join(commission_dir, '{}GNB{}_DU{}_SCF.xml')
    scf_dus = [scf_path.format(prefix, bts_id, du_id)
               for du_id in range(number_of_dus)]

    return scf_dus


def _get_default_scf_for_cu(bts_id=0, prefix_tag=None):
    commission_dir = get_commissioning_dir()
    prefix = '{}_'.format(prefix_tag) if prefix_tag else ''
    scf_path = os.path.join(commission_dir, '{}GNB{}_CU_SCF.xml'.
                            format(prefix, bts_id))

    return [scf_path]


def _get_default_scf_for_classical_gnb(bts_id=0, prefix_tag=None):
    commission_dir = get_commissioning_dir()
    prefix = '{}_'.format(prefix_tag) if prefix_tag else ''
    scf_path = os.path.join(commission_dir, '{}GNB{}_SCF.xml'.
                            format(prefix, bts_id))

    return [scf_path]


def _get_default_swconfig_for_classical_gnb(bts_id=0, prefix_tag=None):
    commission_dir = get_commissioning_dir()
    prefix = '{}_'.format(prefix_tag) if prefix_tag else ''
    swconfig_path = os.path.join(commission_dir, '{}GNB{}_swconfig.txt'.
                                 format(prefix, bts_id))

    return swconfig_path


def _verify_if_another_sw_upload_is_needed(awaiting_time=600,
                                           readiness_timeout=600, bts_id=0):
    dus_number = tl_config.get_count_of_distributed_units(bts_id=bts_id)
    bts = GnbBbu()
    for du_id in range(dus_number):
        alias = connection_names.rest_bts_du.format("GNB", bts_id, du_id)
        for i in range(5):
            if GnbAlarm().check_if_sw_incompatible_alarm_occurred(
                    awaiting_time=awaiting_time, bts_id=bts_id,
                    du_id=du_id):
                try:
                    sw_path = GnbSwUpdate().download_sw_package(
                        GnbBbu().get_bts_sw_version(), "/tmp")
                    bts.connect(du_id=du_id)
                    bts.admin.wait_sw_update_possible(
                        readiness_timeout=readiness_timeout,
                        timeout=(readiness_timeout + 100),
                        connection=alias)
                    GnbSwUpdate().update_software(sw_package_dir=sw_path,
                                                  bts_id=bts_id, du_id=du_id)
                    logging.info('Software package {} uploaded'.
                                 format(sw_path.split('/')[-1]))
                    awaiting_time = 300
                except (AdminApiConnectionClosedException,
                        AdminApiProcedureFailureException):
                    logging.warning('The BTS is not ready for update yet')
                    continue
                finally:
                    bts.disconnect(du_id=du_id)
            else:
                break
        else:
            logging.error('The BTS is still busy after {} minutes'.
                          format((5 * readiness_timeout)/60))
            raise WrongApiException("Software could not have been uploaded")


def _wait_for_admin_api_connection(bts_id=0, du_id=0):
    admin_api_connection_attempts = 0
    while admin_api_connection_attempts < 10:
        try:
            GnbAlarm().check_if_sw_incompatible_alarm_occurred(bts_id=bts_id)
            break
        except (AdminApiConnectionClosedException,
                AdminApiProcedureFailureException,
                AdminApiProcedureTimeoutException):
            admin_api_connection_attempts = admin_api_connection_attempts + 1
        time.sleep(30)
    else:
        scf_path = _get_default_scf_for_classical_gnb()
        GnbScf().perform_bts_full_commissioning_via_gui(bts_id=0, du_id=0,
                                                        scf_path=scf_path)


def _get_default_scf_for_from_yaml(gnb_part):
    yaml_path = get_custom_config_yaml_path()
    hws = []
    with open(yaml_path) as yf:
        content = yaml.load(yf, Loader=yaml.FullLoader)
        for item in content['nodes']:
            if isinstance(item, dict):
                for f in item['files']:
                    if f['hw_type'] == gnb_part and f['file_type'] == 'scfc':
                        hws.append(f)
    hws.sort(key=lambda x: x['hw_id'])
    scf_paths = [os.path.join(get_repository_path(), 'custom-config',
                              hw['file_path']) for hw in hws]
    return scf_paths


def _get_default_scf_for_cu_from_yaml(**kwargs):
    return _get_default_scf_for_from_yaml(gnb_part='cu')


def _get_default_scf_for_du_from_yaml(**kwargs):
    return _get_default_scf_for_from_yaml(gnb_part='du')
