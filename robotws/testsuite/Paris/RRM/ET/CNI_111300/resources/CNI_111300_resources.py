"""
:author: Aleksandra Zbieg
:maintainer: Aleksandra Zbieg
:owner_email: aleksandra.zbieg@nokia.com
:team: I_5G_SW_MMW_PLKRK_04
:email: I_5G_SW_MMW_PLKRK_04@nokia.com
:description: Internal resurces for CNI_111300
"""

import os
import shutil
import subprocess as sp
import xml.etree.ElementTree as Et
import time
import sys
from types import ModuleType

from taf.config.wts import wts
from taf.transport.ssh.exceptions import FileProtocolClientError
from taf.internal.sbts.admin.exceptions import (
    AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException
)
from robot.libraries.BuiltIn import BuiltIn

from testsuite.Paris.RRM.ET.resources_KRK.python.common_wts import (
    setup_x2_link, run_egate_cmd, calculate_ue_sum_throughput
)
from testsuite.Paris.RRM.ET.resources_KRK.python.common_gnb import (
    wait_for_requested_bts_state, update_parameter_value, get_cells_info, run_on_ap,
    perform_recomissioning_with_delta, perform_gnb_commissioning, collect_scf_file
)
from testsuite.Paris.RRM.ET.resources_KRK.python.common_airphone import load_template_iphy
from testsuite.Paris.RRM.ET.resources_KRK.python.utilities import (
    logger_info, logger_console_info, logger_warning
)
from testsuite.Paris.RRM.ET.resources_KRK.python.file_management import (
    copy_files_from_ap, upload_files_to_ap, change_file_name
)
from testsuite.Paris.RRM.ET.CNI_111300.resources.variables import *


def validate_info_block_messages(msg_dict=None, info_block_type='MasterInformationBlock'):
    """
    :param msg_dict: (dict) e.g. {2: [1, 2, 3, 4, 5, 6, 7, 8]}
    :param info_block_type: (str) e.g. 'MasterInformationBlock' or 'SystemInformationBlockType1'
    """

    if not msg_dict:
        logger_info('Info block messages validation skipped.')
        return

    ta5g_enb_instance = BuiltIn().get_library_instance("ta5g_egate")
    ta5g_enb_instance.wait_for_information_block_reception_for_given_cells(
        cells=msg_dict,
        infoblocktype=info_block_type,
        timeout=300
    )


def setup_x2_link_and_wait_for_cells_onair():
    setup_x2_link(timeout=15)
    wait_for_requested_bts_state('onair')


def setup_xp_link():
    run_egate_cmd('enb_xp_param id=2 ignore_xp=off xp_listening_socket=on')
    run_egate_cmd('enb_xp_param id=2 xp_peers=1')
    run_egate_cmd('enb_xp_link_up enb=2 target=1')


def wait_for_traffic_running(duration=10):
    time.sleep(int(duration))


def get_log_dir():
    """
    Get default directory for storing logs.
    """

    output_dir = BuiltIn().get_variable_value("${OUTPUT_DIR}")
    try:
        return os.path.join(output_dir, BuiltIn().get_variable_value("${TEST_NAME}"))
    except TypeError:
        logger_info('Logs collected in suite logs dir.')
        return os.path.join(output_dir, BuiltIn().get_variable_value("${SUITE_NAME}"))


def establish_dss_partnership():
    """
    Establish DSS partnership.
    """

    run_egate_cmd(cmd='enb_dss_param id=2 feature_flag=on message_sets=DMS3')
    run_egate_cmd(cmd='enb_cell_param enb=2 id=1 lte_nr_dss_mode=DSS_PHASE_3 antenna_ports_num=2')
    run_egate_cmd(cmd='enb_cell_dss_feature enb=2 id=1 nr_dl_peak_rate_increase=on')
    run_egate_cmd(cmd='enb_cell_dss_feature enb=2 id=1 superfast_allocation=off')
    run_egate_cmd(cmd='enb_dss_cell_param enb=2 id=1 dl_resource_sharing_algo=dl_prb_load_based')

    run_egate_cmd(cmd='enb_dss_configure_partnership enb=2 cell=1 dss_peer=1:1')

    run_egate_cmd(cmd='enb_crm_cell_resource_reservation enb=2 cell=1 tgt_enb=1 tgt_cell=1 '
                      'assigned_dl_minimum_share_to_nr=30 assigned_dl_maximum_share_to_nr=70 '
                      'assigned_dl_minimum_share_to_lte=15 assigned_dl_maximum_share_to_lte=70 '
                      'assigned_ul_minimum_share_to_nr=20 assigned_ul_maximum_share_to_nr=70')
    run_egate_cmd(cmd='enb_crm_param id=2 ul_qos_load_meas_timer=200 dl_qos_load_meas_timer=200')

    run_egate_cmd(cmd='enb_dss_establish_partnership enb=2 cell=1 tgt_enb=1 tgt_cell=1', timeout=120,
                  pass_regexp='EN DSS DL Cell Resource Area Coordination success on remote NE')

    run_egate_cmd(cmd='enb_dss_status enb=1 cell=1')
    run_egate_cmd(cmd='enb_dss_cell_resource_reservation_dl enb=2 cell=1 reset')
    run_egate_cmd(cmd='enb_dss_dl_resource_cell_reservation cell=1 enb=2 '
                      'prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none')
    run_egate_cmd(cmd='enb_dss_dl_resource_cell_reservation cell=1 enb=2 reserved_fixed_normal_subframes='
                      '0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000')
    run_egate_cmd(cmd='enb_dss_dl_resource_cell_reservation cell=1 enb=2 min_lte_nr_dss_ratio=30 '
                      'max_lte_nr_dss_ratio=100')

    run_egate_cmd(cmd='enb_dss_cell_resource_coordination enb=2 cell=1 tgt_enb=1 tgt_cell=1 dir=DL',
                  pass_regexp='EN DSS DL Cell Resource Area Coordination: both NEs synchronized', timeout=120)

    run_egate_cmd(cmd='enb_dss_ul_resource_cell_reservation cell=1 enb=2 minimum_prb_share=30 maximum_prb_share=70')

    run_egate_cmd(cmd='enb_dss_cell_resource_coordination enb=2 cell=1 tgt_enb=1 tgt_cell=1 dir=UL', timeout=120,
                  pass_regexp='EN DSS UL Cell Subcarrier Resource Coordination: both NEs synchronized')

    run_egate_cmd(cmd='enb_dss_resource_allocation enb=2 cell=1 tgt_enb=1 tgt_cell=1 dir=DL allocation_start_time='
                      'immediate dl_allocated_normal_subframes=0111101110-0111101110-0111101110-0111101110-0111101110'
                      '-0111101110-0111101110-0111101110 dl_prb_area_allocation_list=0:0,106+1:0,106+2:0,106+3:0,106+'
                      '4:0,106+5:0,106+6:0,106+7:0,106+8:0,106+9:0,106+10:0,106+11:0,106+12:0,106+13:0,106+14:0,106+1'
                      '5:0,106+16:0,106+17:0,106+18:0,106+19:0,106+20:0,106+21:0,106+22:0,106+23:0,106+24:0,106+25:0,'
                      '106+26:0,106+27:0,106+28:0,106+29:0,106+30:0,106+31:0,106+32:0,106+33:0,106+34:0,106+35:0,106+'
                      '36:0,106+37:0,106+38:0,106+39:0,106+40:0,106+41:0,106+42:0,106+43:0,106+44:0,106+45:0,106+46:0'
                      ',106+47:0,106+48:0,106+49:0,106+50:0,106+51:0,106+52:0,106+53:0,106+54:0,106+55:0,106+56:0,106'
                      '+57:0,106+58:0,106+59:0,106+60:0,106+61:0,106+62:0,106+63:0,106+64:0,106+65:0,106+66:0,106+67:'
                      '0,106+68:0,106+69:0,106+70:0,106+71:0,106+72:0,106+73:0,106+74:0,106+75:0,106+76:0,106+77:0,10'
                      '6+78:0,106+79:0,106',
                  pass_regexp='Received DSS DL Resource Area Allocation Response SequenceNumber=0', timeout=120)
    run_egate_cmd(cmd='enb_dss_resource_allocation enb=2 cell=1 tgt_enb=1 tgt_cell=1 dir=UL '
                      'allocation_start_time=immediate ul_allocated_prb_list=0,3|5,70|103,3')

    validate_info_block_messages(
        msg_dict=SIB_DICT_FR1,
        info_block_type='SystemInformationBlockType1'
    )
    logger_console_info('DSS configured successfully')


def modify_iphy(reboot=False, backup_iphy_filename='default_iphy.xml'):
    """
    Based on a running testcase perform iphy reconfiguration:
        - CNI111300-A-B1-06: change all RUs
    Backup iphy is saved at default log dir. This file is later used by restore_default_iphy function.
    """

    test_name = BuiltIn().get_variable_value('${TEST_NAME}')
    if any(test_prefix in test_name for test_prefix in ['CNI111300-A-B1-06']):
        copy_files_from_ap(
            files=['/rom/simmode/iphy.xml'],
            local_path=get_log_dir()
        )
        change_file_name(
            old_name=os.path.join(get_log_dir(), 'iphy.xml'),
            new_name=os.path.join(get_log_dir(), backup_iphy_filename)
        )
        load_template_iphy(template_filepath=IPHY_CNI111300_A_B1_06)
    else:
        logger_info('Iphy modification skipped.')
    if reboot:
        run_on_ap('system-module-reboot')


def restore_default_iphy(backup_iphy_filename='default_iphy.xml'):
    """
    Upload backup iphy file to AP if available. File should be stored at default log dir.
    """

    test_name = BuiltIn().get_variable_value('${TEST_NAME}')
    if any(test_prefix in test_name for test_prefix in ['CNI111300-A-B1-06']):
        logger_console_info('Restoring default Iphy...')
        try:
            upload_files_to_ap(files=[os.path.join(get_log_dir(), backup_iphy_filename)], remote_path='/rom/simmode')
            run_on_ap('cd /rom/simmode; ln -fs {} iphy.xml'.format(backup_iphy_filename))
        except FileProtocolClientError:
            logger_warning('Backup Iphy file not found. Reconfiguration skipped')
    else:
        logger_info('Iphy modification skipped.')


def perform_scf_reconfiguration(delta_path=None, scell_activation_method=None):
    """
    A few different types of SCF reconfiguration are handled:
        - If delta_path is provided -> perform delta reconfiguration
        - If scell_activation_method is provided -> reconfigure SCells activation and disable CNI
        - In any other case disable CNI
    """

    if delta_path:
        logger_console_info(f'Performing delta reconfiguration: {delta_path}')
        perform_recomissioning_with_delta(path_to_delta=delta_path)
    elif scell_activation_method:
        cells_info = get_cells_info()
        change_scell_activation_method(cells_info, scell_activation_method)
        change_actoptimizedflowcontrol_value('nonOptimized', cells_info)
    else:
        cells_info = get_cells_info()
        change_actoptimizedflowcontrol_value('nonOptimized', cells_info)


def change_actoptimizedflowcontrol_value(value, cells=None):
    """
    Changes value of scf parameter actOptimizedFlowControl.

    :param cells: Output of function get_cells_info()
    :param value: (str) Value of actOptimizedFlowControl, nonOptimized or optimizedAllUe
    """

    logger_console_info(f'Reconfigure actOptimizedFlowControl parameter to {value} for all cells.')
    cells = cells if cells is not None else get_cells_info()
    for cell in cells:
        update_parameter_value(
            dist_name=f"MRBTS-1/NRBTS-1/NRCELL-{cell['globalCellId']}",
            parameter='actOptimizedFlowControl',
            value=value
        )


def change_scell_activation_method(cells, activation_method):
    """
    Reconfigure sCellActivationMethod and sCellDeactivationTimerGNB.

    :param cells: Output of function get_cells_info()
    :param activation_method: (str) Value of sCellActivationMethod, bufferBased or blind
    """

    logger_console_info(f'Performing SCell activation method reconfiguration to {activation_method}')
    deactivation_timer = 'infinity' if activation_method == 'blind' else 'ms1280'
    update_parameter_value(parameter='sCellActivationMethod', value=activation_method, dist_name='MRBTS-1/NRBTS-1')
    for cell in cells:
        update_parameter_value(parameter='sCellDeactivationTimerGNB', value=deactivation_timer,
                               dist_name=f"MRBTS-1/NRBTS-1/NRCELL-{cell['globalCellId']}")


def send_scf_to_change_cell_technology(retry=3):
    """
    Change NRCELL-4 technology to TDD. Applicable only for CNI111300-A-B1-06 TC.
    """

    def perform_recommissioning():
        attempt = 0
        while attempt < retry:
            logger_console_info(f'Executing {attempt + 1} attempt of gNB recommissioning')
            try:
                perform_gnb_commissioning(scf_path)
                break
            except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
                    AdminApiNoResponseException) as error:
                logger_warning(error)
                attempt += 1
        else:
            raise RuntimeError('Commissioning failure: Could not perform SCF reconfiguration')

    test_name = BuiltIn().get_variable_value('${TEST_NAME}')
    if any(test_prefix in test_name for test_prefix in ['CNI111300-A-B1-06']):
        logger_console_info('Reconfiguring MRBTS-1/NRBTS-1/NRCELL-4/cellTechnology to "TDD"')
        scf_path = os.path.join(get_log_dir(), 'scf_before_onair.xml')
        collect_scf_file(final_path=scf_path)
        Et.register_namespace('', 'raml21.xsd')
        tree = Et.parse(scf_path)
        root = tree.getroot()
        nrcell_p_obj = root.find("./{raml21.xsd}cmData/{raml21.xsd}managedObject[@distName='MRBTS-1/NRBTS-1/NRCELL-4']"
                                 "/{raml21.xsd}p[@name='cellTechnology']")
        nrcell_p_obj.text = 'TDD'
        tree.write(scf_path)
        perform_recommissioning()
        logger_console_info('MRBTS-1/NRBTS-1/NRCELL-4/cellTechnology reconfiguration has finished successfully')
    else:
        logger_info('Reconfiguration skipped.')


def restore_default_scf():
    """
    Restore default gNB configuration only for specified test cases.
    """

    test_name = BuiltIn().get_variable_value('${TEST_NAME}')
    if any(test_prefix in test_name for test_prefix in
           ['CNI111300-A-B1-03', 'CNI111300-A-B1-04', 'CNI111300-A-B1-05', 'CNI111300-A-B1-06']):
        logger_console_info('Restoring default SCF...')
        output_dir = BuiltIn().get_variable_value('${OUTPUT_DIR}')
        suite_name = BuiltIn().get_variable_value('${SUITE_NAME}')
        perform_gnb_commissioning(os.path.join(output_dir, suite_name, 'basic_scf.xml'))
    else:
        logger_info('SCF modification skipped.')


def add_enb_xp_ip_address(xp_address='10.0.1.121'):
    """
    Required to establish DSS.
    """

    sp.call([f'sudo ip addr add {xp_address}/24 dev eth3'], shell=True)
    logger_info(f'sudo ip addr add {xp_address}/24 dev eth3')


def get_ue_throughput_sum(ue_id=1, cells='0-16'):
    """
    Calculate sum of DL and UL traffic separately for single UE.
    """

    dl_tput_sum = calculate_ue_sum_throughput(ue_id=ue_id, cells=cells)
    ul_tput_sum = calculate_ue_sum_throughput(ue_id=ue_id, cells=cells, traffic_type='pusch')
    return dl_tput_sum, ul_tput_sum


def prepare_wts_configuration_file(wts_filename='wts_cfg.cfg'):
    """
    CNI111300-A-B1-06: Add XP management configuration to enable DSS. Replace eNB and gNB IDs
    """

    wts_cfg_path = os.path.join(get_log_dir(), wts_filename)
    shutil.copyfile(src=EPCSIM_CFG_PATH, dst=wts_cfg_path)
    test_name = BuiltIn().get_variable_value('${TEST_NAME}')
    wts_instance = wts()
    wts_instance.load_wts_cfg(wts_cfg_path)
    if any(test_prefix in test_name for test_prefix in ['CNI111300-A-B1-06']):
        wts_instance = configure_xp_management(wts_instance)
        wts_instance = configure_gnb_id_and_cells(
            wts_instance, cells_config=TC6_CELLS_CONFIGURATION, gnb_id=1, cell_id=3
        )
        wts_instance = configure_ue_capabilities(
            wts_instance, first_ue_id=1, ues_num=1, ue_cap=TC6_UE_CAP_SA_2T3F_BWP_L
        )
        wts_instance = configure_ue_capabilities(
            wts_instance, first_ue_id=2, ues_num=1, ue_cap=TC6_UE_CAP_SA_3T2F_BWP_L
        )
    if any(test_prefix in test_name for test_prefix in ['CNI111300-A-B1-04']):
        wts_instance = add_ue_for_sa(wts_instance)
    wts_instance.save_wts_cfg(file_path=wts_cfg_path)
    return wts_cfg_path


def add_ue_for_sa(wts_instance):
    """
    Add ue id=1 for SA to wts config
    """

    wts_instance.insert(
        command='set_ue simulated id=1 uec=1 release=15 idle_edrx_cycle_len=2 ptw=2.56 opc_key=0ED47545168EAFE2C39C0758'
                '29A7B61F nia=null+zuc nea=null+zuc sec_key=0102030405060708090A0B0C0D0EFF00 suci=0:311:489:0000:0:0:02'
                '1645400 mode=nr enb=2 cell=1',
        location='after',
        reference='ue_param id=11'
    )
    wts_instance.insert(
            command=f'ue_param id=1 ue_nr_capabilities={TC4_UE_CAP_SA}',
            location='after',
            reference='set_ue simulated id=1'
    )
    wts_instance.insert(
        command='set_pdu_gateway id=1 ue_nat_ip=72.23.0.1 dl_nat_gw=$SERVER_IP ul_nat_gw=$SERVER_IP',
        location='after',
        reference='ue_param id=1'
    )
    return wts_instance


def configure_xp_management(wts_instance):
    """
    Add XP management, necessary for DSS.
    """
    wts_instance.insert(
        command='set GNB_XP_ADDR="10.0.1.2"',
        location='after',
        reference='set GNB_NG_ADDR="10.0.1.2"'
    )
    wts_instance.insert(
        command='set ENB_XP_ADDR="10.0.1.121"',
        location='after',
        reference='set PROXY_SERVER_IP="10.0.2.80"'
    )
    wts_instance.insert(
        command='set ENB_XPU_ADDR="10.0.1.121"',
        location='after',
        reference='set ENB_XP_ADDR="10.0.1.121"'
    )
    wts_instance.modify(
        command='set_enb plmn=311:489',
        modification='id=2 xp_management=on xp=$ENB_XP_ADDR:32742 xpu=$ENB_XPU_ADDR:32742'
    )
    wts_instance.modify(
        command='enb_param drb_id_begin=3',
        modification='id=2'
    )
    wts_instance.delete(command='set_cell enb=1')
    wts_instance.insert(
        command='set_cell id=1 enb=2 bw=20MHz eci=0x1234601 pci=3:2 tac=222 '
                'proxy=$SERVER_IP:12219 earfcn=68761:133297',
        location='after',
        reference='enb_param id=2'
    )
    wts_instance.modify(
        command='enb_endc_param control_flow_period=3gpp1',
        modification='id=2'
    )
    wts_instance.modify(
        command='set_sgw id=1',
        modification='gtpu_read_packets_threshold=10'
    )
    return wts_instance


def configure_gnb_id_and_cells(wts_instance, cells_config, gnb_id=2, cell_id=None, ues_num=10):
    """
    Change gNB ID and cells configuration.

    :param wts_instance: (taf.config.wts)
    :param cells_config: (dict) Cells configuration for example check variables/TC6_CELLS_CONFIGURATION
    :param gnb_id: (int)
    :param cell_id: (int)
    :param ues_num: (int) Number of UEs to be modified
    """

    wts_instance.modify(
        command='set_gnb plmn=311:489',
        modification=f'id={gnb_id}'
    )
    for cell_id, modificators in cells_config.items():
        modification = f'gnb={gnb_id}'
        for parameter, value in modificators.items():
            modification += f' {parameter}={value}'
        logger_info(f'Modify cell-{cell_id} with {modificators}')
        wts_instance.modify(
            command=f'set_cell id={cell_id} gnb=2',
            modification=modification
        )
    for ue_id in range(1, ues_num+1):
        modification = f'enb={gnb_id}' if not cell_id else f'enb={gnb_id} cell={cell_id}'
        wts_instance.modify(
            command=f'set_ue simulated id={ue_id}',
            modification=modification
        )
    return wts_instance


def configure_ue_capabilities(wts_instance, ue_cap, ues_num=10, first_ue_id=1):
    """
    Change UE Capabilities for 1-<ues_num> UEs.
    """

    for ue_id in range(first_ue_id, ues_num + first_ue_id):
        wts_instance.modify(
            command=f'ue_param id={ue_id}',
            modification=f'ue_nr_capabilities={ue_cap}'
        )
    return wts_instance


def modify_sctp_timeout():
    """
    Run command on VM
    """

    sp.call(['sudo sysctl -w net.sctp.rto_min=100'], shell=True)


def get_average_ue_tput_sum_from_intervals(ue_id=1, cells='0-16', num_intervals=4, wait_time=30):
    """
    Calculate sum of DL and UL traffic separately for single UE
    averaged from num_intervals times in wait_time intervals.
    """

    dl_tput_sum = 0
    ul_tput_sum = 0
    interval = 0
    while interval < int(num_intervals):
        dl_tput, ul_tput = get_ue_throughput_sum(ue_id=ue_id, cells=cells)
        dl_tput_sum += dl_tput
        ul_tput_sum += ul_tput
        if interval < int(num_intervals)-1:
            wait_for_traffic_running(duration=int(wait_time))
        interval += 1
    return dl_tput_sum/num_intervals, ul_tput_sum/num_intervals


def get_testline_name():
    # Returns the name of the Testline. Ex: 2_16_UTE5GCLASSICAL4246
    for module in sys.modules.copy().values():
        if type(module) is ModuleType:
            if "tl" in dir(module):
                return os.path.basename(os.path.dirname(module.__file__))
    raise Exception('No Testline Module Loaded!')


def check_if_cm_execution():
    # returns False if the test was launched by the CloudManager, otherwise returns True.
    return False if os.environ.get("CM_EXECUTION_ID") is None else True
