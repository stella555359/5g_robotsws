import os
import time
from taf.config.scf import scf
from robot.api import logger
import testsuite.Wroclaw.RRM.resources.webUI_operations as webui
from testsuite.Wroclaw.RRM.resources.rrm_fixture import (
    get_robot_variable,
    webUI,
    get_oam_ip,
    get_oam_user,
    get_oam_pass
)
from testsuite.Wroclaw.RRM.resources.preconditions_py import mrbts_id, nrbts_id
from testsuite.Wroclaw.RRM.resources.etws_cmas.ngap_checkers import ue_released, ue_attached
from taf.transport.ssh import ssh
from testsuite.Wroclaw.RRM.resources.rrm_fixture import wait_for_method
from ute_admin_infomodel import ute_admin_infomodel


def prepare_cell_deletion_delta(cell_id, scf_obj, actual, target, output_dir):
    delta_filepath = os.path.join(output_dir, 'del_cell_{}.json'.format(cell_id))
    scf_obj.calculate_delta_scf(target_scf_path=target, actual_scf_path=actual,
                                delta_scf_path=delta_filepath)
    return delta_filepath


def prepare_cell_addition_delta(cell_id, scf_obj, actual, target, output_dir):
    delta_filepath = os.path.join(output_dir, 'add_cell_{}.json'.format(cell_id))
    scf_obj.calculate_delta_scf(target_scf_path=target, actual_scf_path=actual,
                                delta_scf_path=delta_filepath)
    return delta_filepath


def prepare_delta_files(cell_id, group=None):
    output_dir = get_robot_variable("${LOG_PATH}")
    modified_scf = os.path.join(output_dir, 'removed_cell.xml')
    original_scf = webui.download_current_scf('original_scf.xml')
    new_scf = scf()
    new_scf.load_scf(original_scf)
    new_scf.remove_mo_with_descendant_mos(dist_name='MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-{}'
                                          .format(mrbts_id, cell_id))
    new_scf.remove_mo_with_descendant_mos(dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(mrbts_id, nrbts_id, cell_id))
    delete_cell_relations(cell_id, new_scf)
    if not group:
        nr_cell_grp = new_scf.get_all_values_from_scf_by_pattern(dist_name='MRBTS-{}/NRBTS-{}/NRCELLGRP-*'
                                                                 .format(mrbts_id, mrbts_id),
                                                                 list_name='nrCellList').index(str(cell_id))
        group = nr_cell_grp
    new_scf.remove_mo_with_descendant_mos(dist_name='MRBTS-{}/NRBTS-{}/NRCELLGRP-{}'
                                          .format(mrbts_id, nrbts_id, group))
    ref_nr_cell_group_list = new_scf.get_all_values_from_scf(
        dist_name='MRBTS-{}/NRBTS-{}/NRDU-1'.format(mrbts_id, nrbts_id),
        list_name='refNrCellGroup')
    ref_nr_cell_index = ref_nr_cell_group_list.index(str(group))
    new_scf.remove_element_from_scf(dist_name='MRBTS-{}/NRBTS-{}/NRDU-1'.format(mrbts_id, nrbts_id),
                                    list_name='refNrCellGroup',
                                    index=ref_nr_cell_index)

    new_scf.save_scf(modified_scf)
    prepare_cell_deletion_delta(cell_id, new_scf, actual=original_scf, target=modified_scf, output_dir=output_dir)
    prepare_cell_addition_delta(cell_id, new_scf, actual=modified_scf, target=original_scf, output_dir=output_dir)


def delete_cell_relations(cell_id, new_scf):
    admin = ute_admin_infomodel()
    alias = 'del_rel_{}'.format(cell_id)
    try:
        admin.setup_infomodel(alias=alias)
        admin.connect_infomodel(alias=alias)
        nrrels = admin.query_infomodel(query='get list /MRBTS-*//NRBTS_A-*/NRCELL_A-*/NRREL_A-* is [lcrId={}]'
                                       .format(cell_id), allow_negative_result=True, alias=alias)

        for nrrel in nrrels:
            logger.debug("nrrel: {}".format(nrrel))
            mrbts_index = nrrel['dist_name'].find('MRBTS_A')
            relation = nrrel['dist_name'][mrbts_index:].replace('_A', '')
            logger.debug("Dist name: {}".format(relation))
            new_scf.remove_element_from_scf(dist_name=relation)
    finally:
        admin.teardown_infomodel(alias=alias)


def remove_cell(cell_id, group=None):
    output_dir = get_robot_variable("${LOG_PATH}")
    delta_filepath = os.path.join(output_dir, 'del_cell_{}.json'.format(cell_id))
    if not os.path.exists(delta_filepath):
        prepare_delta_files(cell_id, group)
    with webUI.WebUIOperations() as coam:
        coam.perform_delta_recommissioning(delta_file=delta_filepath, skip_parameter_relation_errors=False,
                                           should_activate=True, timeout=300)


def add_cell(cell_id):
    output_dir = get_robot_variable("${LOG_PATH}")
    delta_filepath = os.path.join(output_dir, 'add_cell_{}.json'.format(cell_id))
    with webUI.WebUIOperations() as coam:
        coam.perform_delta_recommissioning(delta_file=delta_filepath, skip_parameter_relation_errors=False,
                                           should_activate=True, timeout=300)


def restore_cell_if_needed(cell_id):
    if webui.get_cells_number() != 7:
        add_cell(cell_id)


def wait_for_ue_idle_state(inactivity_timer):
    ssh_client = ssh()
    alias = 'idle_check'
    time.sleep(int(inactivity_timer))
    ssh_client.connect_to(get_oam_ip(), get_oam_user(), get_oam_pass(), alias=alias)
    try:
        __check_ue_idle_state(ssh_client, alias)
    finally:
        ssh_client.disconnect(connection=alias)


def wait_for_ue_attach():
    ssh_client = ssh()
    alias = 'attach_check'
    ssh_client.connect_to(get_oam_ip(), get_oam_user(), get_oam_pass(), alias=alias)
    try:
        wait_for_method(__check_attach, method_args=(ssh_client, alias), timeout=60, retry_timeout=20,
                        failure_msg='Ue was not attached!')
    finally:
        ssh_client.disconnect(connection=alias)


def __find_pcap_by_name(name, ssh_client, alias):
    r_path = ssh_client.execute('ls -d -1 /tmp/*{}*.pcap'.format(name.replace('[1]', '')), alias).strip()
    if not r_path.startswith('/'):
        raise RuntimeError('Pcap file for test {} was not found on GNB'.format(name))
    return r_path


def __check_ue_idle_state(ssh_client, alias):
    test_name = get_robot_variable("${TEST_NAME}")
    pcap_file = __get_pcap_from_gnb(test_name, 'idle_confirmation.pcap', ssh_client, alias)
    return ue_released(pcap_file)


def __check_attach(ssh_client, alias):
    filename = 'attach_confirmation'
    pcap_file = __get_pcap_from_gnb(filename, '{}.pcap'.format(filename), ssh_client, alias)
    return ue_attached(pcap_file)


def __get_pcap_from_gnb(filename, destination, ssh_client, alias):
    output_dir = get_robot_variable("${LOG_PATH}")
    pcap_file = os.path.join(output_dir, destination)
    remote_path = __find_pcap_by_name(filename, ssh_client, alias)
    ssh_client.download_file(remote_path, pcap_file, alias)
    return pcap_file
