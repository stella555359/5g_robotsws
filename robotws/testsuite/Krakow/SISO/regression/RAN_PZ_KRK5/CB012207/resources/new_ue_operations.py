import datetime
import paramiko
import time
import taf.rfrl.utilities.logger.custom_logger as logger
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.ue.helpers.data_transfer import start_data_transfer_on_real_ue
from testsuite.Krakow.resources.RAN_VRF_KRK5.python.call_procedure.call_exceptions \
    import DataTransferException
from testsuite.Krakow.resources.RAN_VRF_KRK5.python.call_procedure.ue_operations import UeOperations
from testsuite.Krakow.resources.RAN_VRF_KRK5.python.call_procedure.common_operations import save_data_to_json
from testsuite.Krakow.resources.RAN_VRF_KRK5.python.bts_operations.bts_additional_logs.bts_additional_logs \
    import BtsAdditionalLogs
from testsuite.Krakow.resources.RAN_VRF_KRK5.python.bts_operations.bts_operations import load_bts_delta_from_file
from testsuite.Krakow.resources.RAN_VRF_KRK5.python.call_procedure.bts_operations import prepare_bts_before_call, \
    perform_qrxlev_recommissioning
from .resources import ue_power_reset


deltas_repo_path = 'testsuite/Krakow/SISO/regression/RAN_PZ_KRK5/CB012207/resources/deltas'


class NewUeOperations(UeOperations):
    def __init__(self):
        super(UeOperations, self).__init__()

    @staticmethod
    def prepare_ue_for_test(alias="UE", ue_capabilities="REAL_UE", reboot_ue=False, clear_data='all', log_hierarchy=2):
        """
        Prepares the UE (User Equipment) for testing.

        This method sets up the UE for testing by clearing the failed cells list, requiring the UE with specified
        capabilities, detaching the UE, and optionally rebooting it.

        Parameters:
        alias (str): The alias name of the UE. Default is "UE".
        ue_capabilities (str): The capabilities of the UE. Default is "REAL_UE".
        reboot_ue (bool): Whether to reboot the UE. Default is False.
        clear_data (str): Whether to clear the failed cells list or/and data transfer statistics dictionary.
                          Default is 'all'.
        log_hierarchy (int): The logging hierarchy level. Default is 2.

        Returns:
        None
        """
        logger.log_info_to_console(f"Preparing Ue for test", log_hierarchy=log_hierarchy)

        logger.log_info_to_console(f"UE power reset", log_hierarchy=log_hierarchy)
        ue_power_reset()
        time.sleep(60)

        if clear_data.lower() == 'failed_cells':
            UeOperations.clear_failed_cells_list()
        elif clear_data.lower() == 'data_transfer':
            UeOperations.clear_data_transfer_statistics()
        else:
            UeOperations.clear_failed_cells_list()
            UeOperations.clear_data_transfer_statistics()
        ue_instance = BuiltIn().get_library_instance("ue")
        ue_instance.require_ue(alias, capabilities=ue_capabilities)
        if reboot_ue is True:
            ue_instance.reboot_ue(alias)
            logger.log_info_to_console(f"UE is rebooted.", log_hierarchy=int(log_hierarchy) + 1)
            time.sleep(10)

    @staticmethod
    def perform_data_transfer(directions, duration, traffic_matrix, deviation, cell_name, run_num, alias='UE',
                              raise_errors=True, rerun=False, additional_action=None, additional_action_params=None):

        directions = directions.split(',')
        ue_instance = BuiltIn().get_library_instance("ue")
        if rerun is True:
            rerun = "_rerun"
        else:
            rerun = ""

        traffic_params = dict()
        dt_name = dict()
        dt_name['DL'] = "DT_" + cell_name + "_DL_" + str(run_num) + rerun
        dt_name['UL'] = "DT_" + cell_name + "_UL_" + str(run_num) + rerun
        actual_direction = directions[0]
        try:
            for direction in directions:
                actual_direction = direction.upper()
                traffic_params[actual_direction] = UeOperations.get_traffic_params(traffic_matrix=traffic_matrix,
                                                                                   cell_name=cell_name,
                                                                                   direction=direction)
                dt_name = UeOperations.check_if_dt_names_already_exists(dt_name=dt_name, direction=actual_direction)
                start_data_transfer_on_real_ue(
                    dt_name=dt_name[actual_direction],
                    ue_alias=alias,
                    direction=actual_direction,
                    duration=duration,
                    protocol=traffic_params[actual_direction]['protocol'],
                    tput=traffic_params[actual_direction]['tput'],
                    parallel_streams=traffic_params[actual_direction]['parallel_streams'],
                    size_packet=traffic_params[actual_direction]['size_packet'],
                    buffer_client=traffic_params[actual_direction]['buffer_client'],
                    buffer_server=traffic_params[actual_direction]['buffer_server'],
                    interval=traffic_params[actual_direction]['interval'],
                    linux_congestion=traffic_params[actual_direction]['linux_congestion'])

            for direction in directions:
                actual_direction = direction.upper()
                logger.log_info_to_console(f"Checking if {actual_direction} data transfer is alive", log_hierarchy=5)
                ue_instance.check_data_transfer_is_alive(dt_name=dt_name[actual_direction])

            if additional_action and 'during' in additional_action.keys():
                NewUeOperations.call_function(func_name=additional_action['during'],
                                              func_args=additional_action_params['during'])

            for direction in directions:
                actual_direction = direction.upper()
                logger.log_info_to_console(f"Awaiting {actual_direction} data transfer finish", log_hierarchy=5)
                ue_instance.await_data_transfer_finish(dt_name=dt_name[actual_direction])

            for direction in directions:
                actual_direction = direction.upper()
                try:
                    ue_instance.verify_average_throughput_with_deviation(
                        dt_name=dt_name[actual_direction], tput=traffic_params[actual_direction]['tput_target'],
                        deviation=deviation)
                    tput_target = traffic_params[actual_direction]['tput_target']
                    target_min = (100.0 - float(deviation.replace('%', ''))) * float(tput_target.split(' ')[0]) / 100.0
                    target_max = (100.0 + float(deviation.replace('%', ''))) * float(tput_target.split(' ')[0]) / 100.0
                    logger.log_info_to_console(
                        f"Average Tput for cell: {cell_name} in direction {actual_direction} is: "
                        f"{ue_instance.get_average_throughput(dt_name=dt_name[actual_direction]) / 1000} Mbits/sec, "
                        f"target tput is: {tput_target}, expected tput range {target_min}...{target_max} "
                        f"{tput_target.split(' ')[1]}", log_hierarchy=5)

                except Exception as e:
                    if cell_name not in NewUeOperations.failed_cells:
                        logger.log_warn_to_console(f"{actual_direction} problem. {cell_name} added to failed_cells")
                        NewUeOperations.failed_cells.append(cell_name)
                    message = f"Some problem with {actual_direction} data transfer. \n" \
                              f"Error occurs:\n{e} Please Check logs for more details."
                    logger.log_warn_to_console(message, log_hierarchy=5)
                    if raise_errors is True:
                        raise DataTransferException(message)

                finally:
                    try:
                        UeOperations.data_transfer_statistics[dt_name[actual_direction]] = {
                            "actual_tput": ue_instance.get_average_throughput(dt_name=dt_name[actual_direction]) / 1000,
                            "expected_tput": traffic_params[actual_direction]['tput_target'],
                            "deviation": deviation,
                            "iperf_data": ue_instance.get_data_transfer_statistics(dt_name[actual_direction])
                        }
                    except Exception:
                        UeOperations.data_transfer_statistics[dt_name[actual_direction]] = {
                            "actual_tput": 0,
                            "expected_tput": traffic_params[actual_direction]['tput_target'],
                            "deviation": deviation,
                            "iperf_data": []
                        }
                    save_data_to_json(data=UeOperations.data_transfer_statistics, run_num=run_num)

        except Exception as e:
            if cell_name not in NewUeOperations.failed_cells:
                logger.log_warn_to_console(f"{actual_direction} problem. Add to failed_cells")
                NewUeOperations.failed_cells.append(cell_name)
            message = f"Some problem with {actual_direction} data transfer. \n" \
                      f"Error occur:\n{e} Please Check logs for more details."
            logger.log_warn_to_console(message, log_hierarchy=5)
            if raise_errors is True:
                raise DataTransferException(message)

    @staticmethod
    def call_function(func_name, func_args=None):
        func = [attribute for attribute in dir(NewUeOperations) if callable(getattr(NewUeOperations, attribute))
                and attribute.startswith('__') is False]
        if func_name not in func:
            raise ValueError(f"Function '{func_name}' not found in NewUeOperations class")
        function_mapping = {
            'block_cell': NewUeOperations.block_cell,
            'collect_bip_logs': NewUeOperations.collect_bip_logs,
            'perform_intra_freq_intra_bts_ho': NewUeOperations.perform_intra_freq_intra_bts_ho,
            'lmf_trigger': NewUeOperations.lmf_trigger
        }
        copy_of_additional_action_params = {**func_args}
        if 'wait_time' in copy_of_additional_action_params:
            logger.log_info_to_console('Sleep for {}s'.format(copy_of_additional_action_params['wait_time']))
            time.sleep(int(copy_of_additional_action_params['wait_time']))
            del copy_of_additional_action_params['wait_time']
        logger.log_info_to_console('Function `{}` started.'.format(function_mapping[func_name].__name__))
        function_mapping[func_name](**copy_of_additional_action_params)
        logger.log_info_to_console('Function `{}` finished.'.format(function_mapping[func_name].__name__))

    @staticmethod
    def block_cell(bts_id=0, cell_id=1):
        logger.log_warn_to_console(f"BLOCK_CELL", log_hierarchy=5)
        gnb_cell = GnbCellOperations()
        gnb_cell.block_cell(bts_id=bts_id, cell_id=cell_id)
        time.sleep(10)
        gnb_cell.unblock_cell(bts_id=bts_id, cell_id=cell_id)

    @staticmethod
    def collect_bip_logs(logs_dir, period, bts_id=0):
        host = BuiltIn().get_variable_value(f"${{tl.gnbs[{bts_id}].cu.oam_http_connection_details.addr}}")
        logger.log_info_to_console('HOST: {}'.format(host))
        now = datetime.datetime.now()
        now = now.strftime('%Y%m%d_%H%M%S')
        logs_dir = '{}_{}'.format(logs_dir, now)
        logger.log_info_to_console('Collect BIP logs from {} to: {}'.format(host, logs_dir))
        addit_logs = BtsAdditionalLogs()
        addit_logs.start_gnb_bip_trace(host=host)
        time.sleep(float(period))
        addit_logs.stop_gnb_bip_trace(logs_dir=logs_dir)
        logger.log_info_to_console('Download BIP logs to: {}'.format(logs_dir))

    @staticmethod
    def perform_inter_bts_handover_with_emil_logs(source_cell_id, target_cell_id, traffic_matrix,
                                                  ue_capabilities, ue_alias='UE', collect_emil=True,
                                                  dcap_host='p04-utf-064.p04.ska-lab.nsn-rdnet.net',
                                                  gnb_ip='10.84.164.220', bts_id=76220):

        prepare_bts_before_call()
        cell_to_adjust_qrxlev = {'cell_name': source_cell_id,
                                 'global_cell_id': traffic_matrix[source_cell_id]['global_cell_id']}
        source_bts_id = traffic_matrix[source_cell_id].get('bts_id', 0)
        perform_qrxlev_recommissioning(cell_list=[cell_to_adjust_qrxlev], bts_id=source_bts_id, qrx_level='min')
        ue_instance = BuiltIn().get_library_instance("ue")
        NewUeOperations.prepare_ue_for_test(alias=ue_alias, ue_capabilities=ue_capabilities, reboot_ue=False)
        time.sleep(10)
        NewUeOperations.make_attach(ue_instance=ue_instance, cell_id=source_cell_id, traffic_matrix=traffic_matrix,
                                    alias=ue_alias)
        time.sleep(10)
        NewUeOperations.verify_attach(ue_instance=ue_instance, cell_id=source_cell_id, traffic_matrix=traffic_matrix,
                                      alias=ue_alias)
        add_logs = BtsAdditionalLogs()
        trace_id = None
        if collect_emil:
            add_logs.delete_bts_from_dcap(bts_id=bts_id, dcap_host=dcap_host)
            trace_id = add_logs.start_dcap_logs(dcap_host=dcap_host, gnb_ip=gnb_ip)
        load_bts_delta_from_file(
            delta_json_file='{}/locking_cell.json'.format(deltas_repo_path),
            bts_id=source_bts_id, delta_purpose='Shutting down cell {} to trigger Xn handover'.format(source_cell_id))
        time.sleep(120)
        NewUeOperations.verify_attach(ue_instance=ue_instance, cell_id=target_cell_id, traffic_matrix=traffic_matrix,
                                      alias=ue_alias)
        trace_file_path = None
        if collect_emil:
            trace_file_path = add_logs.stop_dcap_logs(trace_id=trace_id, dcap_host=dcap_host, trace_file_name='emil')
            add_logs.delete_bts_from_dcap(bts_id=bts_id, dcap_host=dcap_host)
        NewUeOperations.try_to_make_detach(alias=ue_alias)
        NewUeOperations.release_resources(alias=ue_alias)
        time.sleep(120)
        load_bts_delta_from_file(
            delta_json_file='{}/unlocking_cell.json'.format(deltas_repo_path),
            bts_id=source_bts_id, delta_purpose="Unlocking cell {}".format(source_cell_id))
        return trace_file_path

    @staticmethod
    def perform_intra_freq_intra_bts_ho(target_cell, traffic_matrix, bts_id=0, ue_alias='UE'):
        gnb_cell = GnbCellOperations()
        logger.log_info_to_console(f"Unlock {target_cell}")
        gnb_cell.unlock_cell(bts_id=bts_id, cell_id=traffic_matrix[target_cell]['global_cell_id'])
        time.sleep(10)
        ue_instance = BuiltIn().get_library_instance("ue")
        logger.log_info_to_console(f"Verify attach")
        NewUeOperations.verify_attach(ue_instance=ue_instance, cell_id=target_cell, traffic_matrix=traffic_matrix,
                                      alias=ue_alias)

    @staticmethod
    def lmf_trigger(ip_address, username, password):
        ssh = paramiko.SSHClient()
        ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        directory = r"/root/CB012207"
        command = f"curl -v http://{ip_address}:9210 -d @gnala-001019001210459.xml"
        logger.log_info_to_console('LMF TRIGGER: {}'.format(command))
        try:
            ssh.connect(ip_address, username=username, password=password, timeout=60)
            stdin, stdout, stderr = ssh.exec_command(f'cd {directory} && {command}')
            stdout.channel.recv_exit_status()
            logger.log_info_to_console('LMF2: {}__{}__{}  '.format(stdin, stdout, stderr))
        finally:
            ssh.close()

    @staticmethod
    def perform_xn_handover(source_cell_id, source_bts_id, target_cell_id, traffic_matrix,
                            ue_capabilities, ue_alias='UE'):
        gnb_cell = GnbCellOperations()
        gnb_cell.lock_cell(bts_id=1, cell_id=3)
        time.sleep(10)
        gnb_cell.lock_cell(bts_id=1, cell_id=4)
        time.sleep(10)
        load_bts_delta_from_file(delta_json_file='{}/lock_xnlink.json'.format(deltas_repo_path), bts_id=1,
                                 delta_purpose='Xn link locked')
        ue_instance = BuiltIn().get_library_instance("ue")
        NewUeOperations.prepare_ue_for_test(alias=ue_alias, ue_capabilities=ue_capabilities, reboot_ue=True)
        NewUeOperations.make_attach(ue_instance=ue_instance, cell_id=source_cell_id, traffic_matrix=traffic_matrix,
                                    alias=ue_alias)
        time.sleep(10)
        NewUeOperations.verify_attach(ue_instance=ue_instance, cell_id=source_cell_id, traffic_matrix=traffic_matrix,
                                      alias=ue_alias)
        load_bts_delta_from_file(delta_json_file='{}/unlock_xnlink.json'.format(deltas_repo_path), bts_id=1,
                                 delta_purpose='XN link is unlocked')
        time.sleep(10)
        gnb_cell.lock_cell(bts_id=0, cell_id=traffic_matrix[target_cell_id]['global_cell_id'])
        time.sleep(30)
        gnb_cell.unlock_cell(bts_id=0, cell_id=traffic_matrix[target_cell_id]['global_cell_id'])
        time.sleep(60)
        NewUeOperations.verify_attach(ue_instance=ue_instance, cell_id=target_cell_id, traffic_matrix=traffic_matrix,
                                      alias=ue_alias)
        time.sleep(20)
        gnb_cell.unlock_cell(bts_id=1, cell_id=3)
        time.sleep(10)
        gnb_cell.unlock_cell(bts_id=1, cell_id=4)
        time.sleep(10)
        NewUeOperations.try_to_make_detach(alias=ue_alias)
        NewUeOperations.release_resources(alias=ue_alias)
