"""
:copyright: Nokia Networks
:author: Jakub Pisarczyk
:maintainer: Marcin Trebunia
:contact: marcin.trebunia@nokia.com
:team: MN_RAN_L2_SW_2_KRK_CntDlv_SG
"""

import subprocess as sp

from variables import *
from traceback import format_exc
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
from robot.errors import ExecutionFailed
from ute_syslog import ute_syslog
from taf.config.wts import wts

from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import logger_console
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.pm_counters import \
    verify_any_counters, get_scell_addition_counter
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_airphone import \
    delete_additional_radio_heads_in_iphy_file, change_produt_code_value_in_iphy_file, add_optlink_to_iphy_file, \
    change_radio_unit_iphy
from iphy_modification import change_numberofsubcellsul_in_iphy
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_gnb import \
    download_and_upload_bsr_package
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.wts_config_modification import \
     configure_second_plmn_in_wts_cfg_file, configure_additional_qosflow, configure_second_plmn_for_ues, \
     configure_additional_qosrules, configure_nwslices_in_wts_cfg_file, \
     configure_additional_bearer, set_custom_ue_cap, modify_arfcn_gscn, \
     configure_mu_mimo, remove_cell_and_its_ues


def start_collecting_syslog(log_dir, raise_exception=False):
    """
    Start collecting logs for the duration of the test case
    :param log_dir: Path to directory where logs will be stored.
    :param raise_exception: (bool) Determine if function should be able to raise an exception
    :return: Absolute path to syslog file
    """
    syslog_filename = 'syslog.log'
    try:
        syslog_instance = ute_syslog()
        syslog_instance.start_syslog(
            log_dir=log_dir,
            log_name=syslog_filename,
            ip='192.168.255.126',
        )
        assert os.path.exists(os.path.join(log_dir, syslog_filename))
    except AssertionError:
        logger.info(format_exc())
        if raise_exception:
            raise RuntimeError(f"Collecting {syslog_filename} has failed to start.")
        logger.warn(f"Collecting {syslog_filename} has failed to start.")
    return os.path.join(log_dir, syslog_filename)


def stop_collecting_syslog(raise_exception=False):
    """
    Stop collecting logs and gather more basic logs.
    :param raise_exception: (bool) Determine if function should be able to raise an exception
    :return:
    """
    syslog_filename = 'syslog.log'
    try:
        kill_syslog_process(syslog_filename)
    except Exception:
        logger.info(format_exc())
        if raise_exception:
            raise RuntimeError("Collecting syslog has failed.")
        logger.warn("Collecting syslog has failed.")


def kill_syslog_process(syslog_filename):
    """
    Kill syslog process based on filename.
    """
    try:
        pid = sp.check_output(['pgrep', '-f', syslog_filename]).decode('ascii')
        if '\n' in pid:
            for num in pid.strip().split('\n'):
                sp.call(['kill', '-9', num])
        else:
            sp.call(['kill', '-9', pid.strip()])
        logger.info('Killed syslog process ({}) with pid {}'.format(syslog_filename, pid.strip().replace('\n', ',')))
    except sp.CalledProcessError:
        logger.info('Syslog process already stopped')


def validate_ca_syslog_prints():
    test_name = BuiltIn().get_variable_value('${TEST_NAME}')
    syslog_prints = ['ScellUeSchedulingResp fill PCellNrCellIdentity:16385 SCellNrCellIdentity:16386']
    logger_console('Start syslog validation')
    with open(f'{OUTPUT_DIR}/{SUITE_NAME}/{test_name}/syslog.log', 'r') as syslog_file:
        read_data = syslog_file.read()
    for syslog_print in syslog_prints:
        if syslog_print not in read_data:
            raise ExecutionFailed(f'Syslog validation failed! Syslog print: {syslog_print} not found')
        else:
            logger_console(f'Syslog print: {syslog_print} validated successfully')


def validate_enh_mu_mimo_counters(cell_id=1, nr_layers=16):
    if nr_layers == 16:
        logger_console('Ensure Enhanced MU MIMO with 16 layers counters contain correct values')
        verify_any_counters('M55308C34023', '> 0', f'NRCELL-{cell_id}')  # PRBs for 16 layer
    elif nr_layers == 8:
        logger_console('Ensure Enhanced MU MIMO with 8 layers counters contain correct values')
        verify_any_counters('M55308C34011', '> 0', f'NRCELL-{cell_id}')  # PRBs for 8 layer
    verify_any_counters('M55308C34015', '> 0', f'NRCELL-{cell_id}')  # PRBs for 4 UE pair
    verify_any_counters('M55308C34014', '> 0', f'NRCELL-{cell_id}')  # PRBs for 3 UE pair
    verify_any_counters('M55308C34013', '> 0', f'NRCELL-{cell_id}')  # PRBs for 2 UE pair
    verify_any_counters('M55308C34012', '> 0', f'NRCELL-{cell_id}')  # PRBs for non paired UE


def validate_pdsch_transmissions(cell_id=1, rank_adaptation=False):
    if not rank_adaptation:
        logger_console('Ensure PDSCH transmissions are sent with rank4 when UEs are paired')
        verify_any_counters('M55301C10004', '> 0', f'NRCELL-{cell_id}')  # PDSCH_4TX_RI_04
        verify_any_counters('M55301C10003', '== 0', f'NRCELL-{cell_id}')  # PDSCH_4TX_RI_03
        verify_any_counters('M55301C10002', '== 0', f'NRCELL-{cell_id}')  # PDSCH_4TX_RI_02
        verify_any_counters('M55301C10001', '== 0', f'NRCELL-{cell_id}')  # PDSCH_4TX_RI_01
    elif rank_adaptation:
        logger_console('Ensure PDSCH transmissions are sent with rank2 when UEs are paired')
        verify_any_counters('M55301C10003', '== 0', f'NRCELL-{cell_id}')  # PDSCH_4TX_RI_03
        verify_any_counters('M55301C10002', '> 0', f'NRCELL-{cell_id}')  # PDSCH_4TX_RI_02
        verify_any_counters('M55301C10001', '== 0', f'NRCELL-{cell_id}')  # PDSCH_4TX_RI_01


def verify_scell_addition_counters(scell_addition_ues=6):
    """
    Verifies the number of successful radio admission for 1 Scell additions.
    """
    counter_values = get_scell_addition_counter()
    assert sum(counter_values) == scell_addition_ues, \
        f"The number of successful radio admissions is equal to {sum(counter_values)}" \
        f" but it should be equal to {scell_addition_ues}"
    logger_console(f"The number of successful scell additions is equal to {sum(counter_values)}")


def adjust_iphy_file_for_mu_mimo(optlink_obj, ru_type, resource_build_key, product_code, subcells_ul_value={},
                                 index=1):
    delete_additional_radio_heads_in_iphy_file(site_reset=False)
    change_produt_code_value_in_iphy_file(product_code=product_code, site_reset=False)
    add_optlink_to_iphy_file(optlink_obj=optlink_obj, site_reset=False, index=index)
    change_numberofsubcellsul_in_iphy(subcells_ul_value=subcells_ul_value)
    change_radio_unit_iphy(ru_type, resource_build_key=resource_build_key, site_reset=False)


def download_bsr_package_and_upload_to_gnb():
    """
    Download BSR package zip from artifactory. Unzip and load to gNB designated package
    """
    download_and_upload_bsr_package(
        artifactory_url=ARTIFACTORY_REPO_URL,
        bsr_artifactory_filename=BSR_ARTIFACTORY_FILENAME,
        bsr_package_to_upload=BSR_PACKAGE_NAME,
        logs_dir=OUTPUT_DIR
    )


def prepare_wts_config_file(net_arch=None, nr_ue_caps=None, mrdc_ue_caps=None, first_sa_ue=1, first_nsa_ue=101,
                            target_number_of_nsa_ues=2, target_number_of_sa_ues=2, snssai=(), plmn=(),
                            reconfigure_nsa_ue_to_second_plmn=(), reconfigure_sa_ue_to_second_plmn=(),
                            qos_flows=(), qos_rules=(), bearers=(), additional_bearer_pdn=1, additional_bearer_qci=8,
                            path_to_basic_cfg='/opt/wts/latest/basic_setup.cfg',
                            target_path='/opt/wts/latest/new_basic_setup.cfg',
                            arfcn_gscn_change=None, mu_mimo=None, remove_cell=()):
    """
    Prepares the WTS configuration file by applying various configurations.

    Args:
        net_arch (str, optional): The network architecture. Defaults to None.
        nr_ue_caps (dict, optional): The capabilities of NR UEs. Defaults to None.
        mrdc_ue_caps (dict, optional): The capabilities of MRDC UEs. Defaults to None.
        first_sa_ue (int, optional): The ID of the first SA UE. Defaults to 1.
        first_nsa_ue (int, optional): The ID of the first NSA UE. Defaults to 101.
        target_number_of_nsa_ues (int, optional): The target number of NSA UEs. Defaults to 2.
        target_number_of_sa_ues (int, optional): The target number of SA UEs. Defaults to 2.
        snssai (tuple, optional): The list of SNSSAI values. Defaults to ().
        plmn (tuple, optional): The list of PLMN values. Defaults to ().
        reconfigure_nsa_ue_to_second_plmn (tuple, optional): The list of NSA UEs to reconfigure to the second PLMN.
                                                             Defaults to ().
        reconfigure_sa_ue_to_second_plmn (tuple, optional): The list of SA UEs to reconfigure to the second PLMN.
                                                            Defaults to ().
        qos_flows (tuple, optional): The list of QoS flows. Defaults to ().
        qos_rules (tuple, optional): The list of QoS rules. Defaults to ().
        bearers (tuple, optional): The list of bearers. Defaults to ().
        additional_bearer_pdn (int, optional): The PDN ID for additional bearers. Defaults to 1.
        additional_bearer_qci (int, optional): The QCI for additional bearers. Defaults to 8.
        path_to_basic_cfg (str, optional): The path to the basic configuration file. Defaults to
                                           '/opt/wts/latest/basic_setup.cfg'.
        target_path (str, optional): The target path for the new configuration file. Defaults to
                                           '/opt/wts/latest/new_basic_setup.cfg'.
        arfcn_gscn_change (bool, optional): Whether to modify ARFCN GSCN. Defaults to None.
        mu_mimo (bool, optional): Whether to configure MU-MIMO. Defaults to None.
        remove_cell (tuple, optional): The list of cells to remove. Defaults to ().

    Returns:
        str: The target path of the new configuration file.
    """
    wts_instance = wts()
    wts_instance.load_wts_cfg(path_to_basic_cfg)

    if plmn:
        configure_second_plmn_in_wts_cfg_file(wts_instance, plmn=plmn)
    if reconfigure_nsa_ue_to_second_plmn:
        configure_second_plmn_for_ues(wts_instance=wts_instance, net_arch='nsa', plmn=plmn,
                                      ue_list=reconfigure_nsa_ue_to_second_plmn)
    if reconfigure_sa_ue_to_second_plmn:
        configure_second_plmn_for_ues(wts_instance=wts_instance, net_arch='sa', plmn=plmn,
                                      ue_list=reconfigure_sa_ue_to_second_plmn)
    if qos_flows:
        configure_additional_qosflow(wts_instance=wts_instance, qos_flows=qos_flows)
    if qos_rules:
        configure_additional_qosrules(wts_instance=wts_instance, qos_rules=qos_rules)
    if snssai:
        configure_nwslices_in_wts_cfg_file(wts_instance=wts_instance, snssai=snssai)
    if bearers:
        configure_additional_bearer(wts_instance=wts_instance, bearers=bearers, first_nsa_ue=first_nsa_ue,
                                    target_number_of_nsa_ues=target_number_of_nsa_ues,
                                    pdn=additional_bearer_pdn, qci=additional_bearer_qci)
    if nr_ue_caps:
        set_custom_ue_cap(wts_instance=wts_instance, net_arch=net_arch, nr_ue_caps=nr_ue_caps,
                          mrdc_ue_caps=mrdc_ue_caps, first_sa_ue=first_sa_ue, first_nsa_ue=first_nsa_ue,
                          num_of_sa_ues=target_number_of_sa_ues, num_of_nsa_ues=target_number_of_nsa_ues)
    if arfcn_gscn_change:
        modify_arfcn_gscn(wts_instance)
    if mu_mimo:
        configure_mu_mimo(wts_instance=wts_instance)
    if remove_cell:
        remove_cell_and_its_ues(wts_instance=wts_instance, remove_cell=remove_cell)
    wts_instance.save_wts_cfg(target_path)
    return target_path
