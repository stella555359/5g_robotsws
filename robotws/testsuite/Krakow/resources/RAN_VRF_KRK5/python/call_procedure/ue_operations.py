import re
import time
import taf.rfrl.utilities.logger.custom_logger as logger
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.ue.helpers.data_transfer import start_data_transfer_on_real_ue
from testsuite.Krakow.resources.RAN_VRF_KRK5.python.call_procedure.call_exceptions \
    import DataTransferException, AdditionalActionNotDefined
from testsuite.Krakow.resources.RAN_VRF_KRK5.python.call_procedure.common_operations import save_data_to_json


class UeOperations:
    failed_cells = []
    data_transfer_statistics = {}
    deviation_per_cell_type = {
        "NR": "40%",
        "LN": "20%",
    }

    def __init__(self):
        pass

    @staticmethod
    def clear_failed_cells_list():
        """
        Clears the list of cells where call failed.

        This method resets the `failed_cells` list to an empty list, effectively clearing any previously recorded
        failed cells.

        Returns:
        None
        """
        UeOperations.failed_cells = []

    @staticmethod
    def clear_data_transfer_statistics():
        """
        Clears the data transfer statistics.

        This method resets the `data_transfer_statistics` dictionary to an empty dictionary, effectively clearing any
        previously recorded data transfer statistics.

        Returns:
        None
        """
        UeOperations.data_transfer_statistics = {}

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
        if clear_data.lower() == 'failed_cells':
            UeOperations.clear_failed_cells_list()
        elif clear_data.lower() == 'data_transfer':
            UeOperations.clear_data_transfer_statistics()
        else:
            UeOperations.clear_failed_cells_list()
            UeOperations.clear_data_transfer_statistics()
        ue_instance = BuiltIn().get_library_instance("ue")
        ue_instance.require_ue(alias, capabilities=ue_capabilities)
        ue_instance.detach_ue(alias)
        if reboot_ue is True:
            ue_instance.reboot_ue(alias)
            logger.log_info_to_console(f"UE is rebooted.", log_hierarchy=int(log_hierarchy)+1)

    @staticmethod
    def try_to_make_attach(cell_id, traffic_matrix, alias="UE"):
        """
        Attempts to attach a UE (User Equipment) to a specified cell.

        This method tries to attach a UE to a cell defined by `cell_id` using the provided `traffic_matrix`.
        It performs multiple attempts with different repair options if the initial attach attempt fails.

        Parameters:
        cell_id (str): The identifier of the cell to which the UE should attach.
        traffic_matrix (dict): A dictionary containing traffic configuration and parameters for the cells.
        alias (str): The alias name of the UE. Default is "UE".

        Returns:
        str: 'succeed' if the attach procedure is successful, 'failed' otherwise.
        """
        logger.log_info_to_console(f"Attach Procedure", log_hierarchy=2)
        attach_repair_options = [None, UeOperations.ue_reboot]
        if 'attenuators' in traffic_matrix[cell_id].keys():
            attach_repair_options.append(UeOperations.again_set_attenuation)
        ue_instance = BuiltIn().get_library_instance("ue")
        for attach_num, repair_option in enumerate(attach_repair_options, start=1):
            try:
                logger.log_info_to_console(f"Attach attempt {attach_num}", log_hierarchy=3)
                UeOperations.make_attach(ue_instance, cell_id, traffic_matrix, alias, repair_option)
                time.sleep(10)
                if UeOperations.verify_attach(ue_instance, cell_id, traffic_matrix, alias=alias):
                    UeOperations.get_signal_strength(cell_id=cell_id, alias=alias)
                    return 'succeed'

            except Exception as e:
                if 'cell id is not changed for ue' in str(e).lower() and \
                        UeOperations.verify_attach(ue_instance, cell_id, traffic_matrix, alias=alias):
                    logger.log_info_to_console('Cell id is not changed for UE')
                    UeOperations.get_signal_strength(cell_id=cell_id, alias=alias)
                    return 'succeed'
                else:
                    logger.log_warn_to_console(f"Some error with attach: {e}", log_hierarchy=4)

        UeOperations.failed_cells.append(cell_id)
        logger.log_warn_to_console(f"Problem with attach. Add to failed_cells {cell_id}", log_hierarchy=4)
        return 'failed'

    @staticmethod
    def verify_attach(ue_instance, cell_id, traffic_matrix, alias="UE", timeout=60, interval=5):
        """
        Verifies if the UE (User Equipment) is attached to the correct cell.

        This method checks if the UE is attached to the cell specified by `cell_id` using the provided `traffic_matrix`.
        It verifies the cell ID and the IP address of the UE.

        Parameters:
        ue_instance: The instance of the UE library.
        cell_id (str): The identifier of the cell to which the UE should be attached.
        traffic_matrix (dict): A dictionary containing traffic configuration and parameters for the cells.
        alias (str): The alias name of the UE. Default is "UE".

        Returns:
        bool: True if the UE is attached to the correct cell and has a valid IP address, False otherwise.
        """
        actual_cell_id = ue_instance.get_ue_info(alias, "CELL_ID")
        expected_cell_id = traffic_matrix[cell_id]['real_cell_id']
        if int(actual_cell_id) != int(expected_cell_id):
            UeOperations.report_problem_with_attach_to_wrong_cell(cell_id=actual_cell_id)
            return False
        logger.log_info_to_console(f"UE is attached to correct cell: {cell_id} with cell_id {expected_cell_id}",
                                   log_hierarchy=4)
        start_time = time.time()
        while time.time() < start_time + timeout:
            ue_ip = ue_instance.get_ue_info(alias, "IP")
            if ue_ip is None or ue_ip == '0.0.0.0':
                logger.log_info_to_console(f"UE waits for ip address: `{ue_ip}`", log_hierarchy=4)
                time.sleep(interval)
            else:
                logger.log_info_to_console(f"UE ip address: `{ue_ip}`", log_hierarchy=4)
                time.sleep(5)
                return True
        logger.log_info_to_console(f"UE didn't get ip address", log_hierarchy=4)
        return False

    @staticmethod
    def make_attach(ue_instance, cell_id, traffic_matrix, alias="UE", action_before_attach=None):
        """
        Attaches a UE (User Equipment) to a specified cell.

        This method attempts to attach a UE to a cell defined by `cell_id` using the provided `traffic_matrix`.
        It optionally performs an action before attempting the attach.

        Parameters:
        ue_instance: The instance of the UE library.
        cell_id (str): The identifier of the cell to which the UE should attach.
        traffic_matrix (dict): A dictionary containing traffic configuration and parameters for the cells.
        alias (str): The alias name of the UE. Default is "UE".
        action_before_attach (callable, optional): A function to be called before attempting the attach.
        Default is None.
        """
        if action_before_attach is not None:
            logger.log_info_to_console(f"Try repair option: {action_before_attach.__name__.replace('_', ' ')} "
                                       f"for correct attach", log_hierarchy=4)
            action_before_attach(ue_instance=ue_instance, cell_id=cell_id, traffic_matrix=traffic_matrix, alias=alias)
        ue_instance.attach_ue(alias, timeout=60)

    @staticmethod
    def release_resources(alias="UE"):
        """
        Releases the resources used by the UE (User Equipment).

        This method stops the usage of the UE and releases any resources associated with it.

        Parameters:
        alias (str): The alias name of the UE. Default is "UE".
        """
        time.sleep(5)
        ue_instance = BuiltIn().get_library_instance("ue")
        ue_instance.stop_using_ue(alias)

    @staticmethod
    def ue_reboot(ue_instance, alias, cell_id=None, traffic_matrix=None):
        """
        Reboots the UE (User Equipment).

        This method reboots the UE specified by `alias`. The `cell_id` and `traffic_matrix` parameters are optional
        and not used in this method.

        Parameters:
        ue_instance: The instance of the UE library.
        alias (str): The alias name of the UE.
        """
        ue_instance.reboot_ue(alias)

    @staticmethod
    def try_to_make_detach(alias="UE"):
        """
        Attempts to detach the UE (User Equipment).

        This method tries to detach the UE specified by `alias`.

        Parameters:
        alias (str): The alias name of the UE. Default is "UE".
        """
        ue_instance = BuiltIn().get_library_instance("ue")
        ue_instance.detach_ue(alias)

    @staticmethod
    def again_set_attenuation(cell_id, traffic_matrix, ue_instance=None, alias=None):
        """
        Adjusts the attenuation settings for a specified cell.

        This method performs a series of operations to adjust the attenuation for the cell identified by `cell_id`
        using the provided `traffic_matrix`. It prepares the BTS (Base Transceiver Station) before the call,
        adjusts the attenuation to the maximum level, performs QRXLEV (Quality of Received Signal Level)
        recommissioning, and then sets the attenuation to an average level.

        Parameters:
        cell_id (str): The identifier of the cell for which the attenuation is to be adjusted.
        traffic_matrix (dict): A dictionary containing traffic configuration and parameters for the cells.
        """
        from attenuator_operations import adjust_attenuation_for_cells
        from bts_operations import prepare_bts_before_call, perform_qrxlev_recommissioning
        prepare_bts_before_call(log_hierarchy=4)
        adjust_attenuation_for_cells(attenuator_matrix=traffic_matrix, attenuation_level="max", log_hierarchy=4)
        cell_list = [{
            'cell_name': cell_id,
            'global_cell_id': traffic_matrix[cell_id]['global_cell_id']

        }]
        perform_qrxlev_recommissioning(cell_list=cell_list, qrx_level="min",
                                       log_hierarchy=4)
        adjust_attenuation_for_cells(attenuator_matrix=traffic_matrix, cell_ids=[cell_id], attenuation_level="avg",
                                     log_hierarchy=4)

    @staticmethod
    def get_traffic_params(traffic_matrix, cell_name, direction):
        """
        Retrieves traffic parameters for a specified cell and direction.

        This method extracts and returns the traffic parameters from the `traffic_matrix` for the given `cell_name`
        and `direction`.

        Parameters:
        traffic_matrix (dict): A dictionary containing traffic configuration and parameters for the cells.
        cell_name (str): The name of the cell for which the traffic parameters are to be retrieved.
        direction (str): The direction of the traffic (e.g., 'DL' for downlink, 'UL' for uplink).

        Returns:
        dict: A dictionary containing the traffic parameters for the specified cell and direction.
        """
        direction = direction.upper()

        cell_traffic_params = traffic_matrix[cell_name][direction]
        traffic_params = {
            'tput': cell_traffic_params['tput'],
            'protocol': cell_traffic_params.get('protocol', traffic_matrix[cell_name].get('protocol')),
            'linux_congestion': cell_traffic_params.get('linux_congestion', traffic_matrix['linux_congestion']),
            'parallel_streams': cell_traffic_params.get('parallel_streams', traffic_matrix['parallel_streams']),
            'buffer_client': cell_traffic_params.get('buffer_client', traffic_matrix['buffer_client']),
            'buffer_server': cell_traffic_params.get('buffer_server', traffic_matrix['buffer_server']),
            'size_packet': cell_traffic_params.get('size_packet', traffic_matrix['size_packet']),
            'interval': cell_traffic_params.get('interval', traffic_matrix['interval']),
            'tput_target': cell_traffic_params.get('tput_target', cell_traffic_params['tput'])
        }
        logger.log_info_to_console(
            f"Traffic parameters for cell: {cell_name} in direction {direction} are: {traffic_params}")
        return traffic_params

    @staticmethod
    def check_if_dt_names_already_exists(dt_name, direction):
        """
        Checks if the data transfer name already exists and appends an index if necessary.

        This method verifies if the data transfer name for the specified direction already exists in the
        `data_transfer_statistics` dictionary. If it exists, it appends an index to the name to make it unique.

        Parameters:
        dt_name (dict): A dictionary containing data transfer names for different directions.
        direction (str): The direction of the data transfer (e.g., 'DL' for downlink, 'UL' for uplink).

        Returns:
        dict: The updated `dt_name` dictionary with a unique name for the specified direction.
        """

        existing_dt_names = UeOperations.data_transfer_statistics.keys()
        if dt_name[direction] in existing_dt_names:
            dt_name_pattern = r'^{}$'.format(dt_name[direction])
            matching_dt_names = \
                [existing_dt_name for existing_dt_name in existing_dt_names
                 if re.match(dt_name_pattern, existing_dt_name)]
            if matching_dt_names:
                dt_name[direction] += f'_att{len(matching_dt_names)+1}'
        return dt_name

    @staticmethod
    def perform_data_transfer(directions, duration, traffic_matrix, deviation, cell_name, run_num, alias='UE',
                              raise_errors=True, rerun=False, additional_action=None, additional_action_params=None):
        """
        Performs data transfer for specified directions and duration.

        This method initiates data transfer for the given `directions` and `duration` using the provided
        `traffic_matrix`. It handles multiple directions, verifies throughput, and logs the results. Optionally,
        it can rerun the transfer and perform additional actions.

        Parameters:
        directions (str): Comma-separated directions for data transfer (e.g., 'DL,UL').
        duration (int): Duration of the data transfer in seconds.
        traffic_matrix (dict): A dictionary containing traffic configuration and parameters for the cells.
        deviation (str): Allowed deviation percentage for throughput verification.
        cell_name (str): The name of the cell for which the data transfer is performed.
        run_num (int): The run number for the data transfer.
        alias (str): The alias name of the UE. Default is 'UE'.
        raise_errors (bool): Whether to raise errors if data transfer fails. Default is True.
        rerun (bool): Whether to rerun the data transfer. Default is False.
        additional_action (callable, optional): An additional action to be performed before data transfer.
                                                Default is None.
        additional_action_params (dict, optional): Parameters for the additional action. Default is None.

        Raises:
        AdditionalActionNotDefined: If additional actions are specified but not defined.
        DataTransferException: If data transfer fails and `raise_errors` is True.
        """
        if additional_action or additional_action_params:
            raise AdditionalActionNotDefined("You have to override method `perform_data_transfer` "
                                             "and add handling of additional actions.")

        logger.log_info_to_console(f"Performing {directions} data transfer", log_hierarchy=4)
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
                start_data_transfer_on_real_ue(dt_name=dt_name[actual_direction],
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

            for direction in directions:
                actual_direction = direction.upper()
                logger.log_info_to_console(f"Awaiting {actual_direction} data transfer finish", log_hierarchy=5)
                ue_instance.await_data_transfer_finish(dt_name=dt_name[actual_direction])

            message = ""
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
                    logger.log_warn_to_console(f"{actual_direction} problem. {cell_name} added to failed_cells")
                    if cell_name not in UeOperations.failed_cells:
                        UeOperations.failed_cells.append(cell_name)
                    message += f"Some problem with {actual_direction} data transfer. \n" \
                               f"Error occurs:\n{e} Please Check logs for more details."

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
            if message:
                logger.log_warn_to_console(message, log_hierarchy=5)
                if raise_errors is True:
                    raise DataTransferException(message)

        except Exception as e:
            if cell_name not in UeOperations.failed_cells:
                logger.log_warn_to_console(f"{actual_direction} problem. Add to failed_cells")
                UeOperations.failed_cells.append(cell_name)
            message = f"Some problem with {actual_direction} data transfer. \n" \
                      f"Error occur:\n{e} Please Check logs for more details."
            logger.log_warn_to_console(message, log_hierarchy=5)
            if raise_errors is True:
                raise DataTransferException(message)

    @staticmethod
    def get_signal_strength(cell_id, alias="UE"):
        """
        Retrieves the signal strength for a specified cell.

        This method fetches and logs the signal strength of the UE (User Equipment) attached to the cell identified
        by `cell_id`.

        Parameters:
        cell_id (str): The identifier of the cell for which the signal strength is to be retrieved.
        alias (str): The alias name of the UE. Default is "UE".
        """
        try:
            ue_instance = BuiltIn().get_library_instance("ue")
            signal_strength = ue_instance.get_ue_info(alias, "signal_strength")
            if signal_strength is not None:
                logger.log_info_to_console(f"UE hears cell: {cell_id}, with signal strength: {signal_strength}",
                                           log_hierarchy=4)
            else:
                logger.log_info_to_console(f"UE is attached to cell: {cell_id}, but cannot get signal strength value. "
                                           f"It is probably not implemented in library on UE PC",
                                           log_hierarchy=4)
        except Exception:
            logger.log_info_to_console(f"UE is attached to cell: {cell_id}, but cannot get signal strength value.",
                                       log_hierarchy=4)

    @staticmethod
    def get_ue_ip(cell_id, alias="UE"):
        """
        Retrieves the IP address of the UE (User Equipment) attached to a specified cell.

        This method fetches and logs the IP address of the UE attached to the cell identified by `cell_id`.

        Parameters:
        cell_id (str): The identifier of the cell for which the UE's IP address is to be retrieved.
        alias (str): The alias name of the UE. Default is "UE".
        """
        try:
            ue_instance = BuiltIn().get_library_instance("ue")
            ue_ip = ue_instance.get_ue_info(alias, "ip")
            if ue_ip is not None:
                logger.log_info_to_console(f"UE ip address: {ue_ip}",
                                           log_hierarchy=4)
            else:
                logger.log_info_to_console(f"UE is attached to cell: {cell_id}, but cannot get ip address value."
                                           f"It is probably not implemented in library on UE PC",
                                           log_hierarchy=4)
        except Exception:
            logger.log_info_to_console(f"UE is attached to cell: {cell_id}, but cannot get ip address.",
                                       log_hierarchy=4)

    @staticmethod
    def check_if_need_recall(recall=True):
        """
        Determines if a cell recall is needed based on the presence of failed cells.

        This method checks if there are any failed calls in cells and returns True if a recall is needed.
        The recall is considered necessary if the `recall` parameter is True and there are failed cells in list.

        Parameters:
        recall (bool): A flag indicating whether to check for recall necessity. Default is True.

        Returns:
        bool: True if a cell recall is needed and there are failed cells, False otherwise.
        """
        if recall:
            return True if len(UeOperations.failed_cells) > 0 else False
        return False

    @staticmethod
    def get_failed_cells_list():
        """
        Retrieves the list of cells where call failed.

        This method returns the list of cells where call failed.

        Returns:
        list: A list of failed cell identifiers.
        """
        return UeOperations.failed_cells

    @staticmethod
    def get_data_transfer_statistics():
        """
        Retrieves the data transfer statistics.

        This method returns the statistics of data transfers performed, including actual throughput,
        expected throughput, and deviation for each data transfer.

        Returns:
        dict: A dictionary containing data transfer statistics.
        """
        return UeOperations.data_transfer_statistics

    @staticmethod
    def prepare_num_run_before_recall(run_num, add_val=100):
        """
        Prepares the run number for the next recall.

        This method increments the given `run_num` by the specified `add_val` to prepare for the next recall.

        Parameters:
        run_num (int): The current run number.
        add_val (int): The value to add to the current run number. Default is 100.

        Returns:
        int: The new run number after adding `add_val`.
        """
        return int(run_num) + int(add_val)

    @staticmethod
    def report_problem_with_attach_to_wrong_cell(cell_id):
        """
        Reports a problem with the UE (User Equipment) attaching to the wrong cell.

        This method logs a warning message indicating that the UE has attached to a cell with an incorrect cell ID.
        It calculates the BTS (Base Transceiver Station) ID based on the provided `cell_id` and includes this
        information in the warning message.

        Parameters:
        cell_id (int): The identifier of the cell to which the UE has incorrectly attached.
        """
        cell_id = int(cell_id)
        if cell_id != -1:
            if cell_id > 1000000000:
                bts_id = int(cell_id / 16384)
            else:
                bts_id = int(cell_id / 256)
            warn_printout = "UE attached to cell with id: {}, this cell might be connected to BTS with id: {}" \
                .format(cell_id, bts_id)
        else:
            warn_printout = "UE didn't attach to any cell."
        logger.log_warn_to_console(warn_printout, log_hierarchy=4)

    @staticmethod
    def get_proper_deviation(deviation, cell):
        """
        Retrieves the proper deviation value for a specified cell.

        This method returns the deviation value for the given `cell`. If the `deviation` parameter is None,
        it determines the deviation based on the cell type.

        Parameters:
        deviation (str or None): The deviation value to be used. If None, the deviation is determined based
                                 on the cell type.
        cell (str): The identifier of the cell, which includes the cell type.

        Returns:
        str: The deviation value for the specified cell.
        """
        if deviation is None:
            cell_type, x = cell.split('CEL')
            return UeOperations.deviation_per_cell_type[cell_type]
        return deviation
