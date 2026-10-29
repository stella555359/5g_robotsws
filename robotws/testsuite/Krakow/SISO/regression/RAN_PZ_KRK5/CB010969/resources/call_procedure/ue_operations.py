import os
import time
import json
from taf.ue import ue
from robot.libraries.BuiltIn import BuiltIn
from ue_proxy import restart_ue_proxy_on_ue_pc
import taf.rfrl.utilities.logger.custom_logger as logger
import call_tmp_vars
from call_exceptions import BadCellAttach, DataTransferException
from taf.rfrl.ue.helpers.data_transfer import start_data_transfer_on_real_ue


def prepare_ue_for_test(alias="UE", capabilities="REAL_UE", reboot_ue=False, clear_data=True):
    if clear_data is True:
        call_tmp_vars.failed_cells = []
    ue_instance = BuiltIn().get_library_instance("ue")
    ue_instance.require_ue(alias, capabilities=capabilities)
    ue_instance.detach_ue(alias)
    if reboot_ue is True:
        ue_instance.reboot_ue(alias)


def try_to_make_attach(expected_cell, alias="UE"):
    logger.log_info_to_console(f"Attach Procedure", log_hierarchy=2)
    attach_repair_options = [None, restart_ue_proxy, ue_reboot, again_set_attenuation]
    ue_instance = BuiltIn().get_library_instance("ue")

    for attach_num, repair_option in enumerate(attach_repair_options, start=1):
        try:
            logger.log_info_to_console(f"Attach attempt {attach_num}", log_hierarchy=3)
            make_attach(ue_instance, expected_cell, alias, repair_option)

            if verify_attach(ue_instance, expected_cell, alias=alias):
                return True

        except Exception as e:
            logger.log_warn_to_console(f"Some error with attach: {e}", log_hierarchy=4)

    logger.log_warn_to_console(f"[mbugaj] Attach problem. Add to failed_cells {expected_cell}")
    call_tmp_vars.failed_cells.append(expected_cell)
    return False


def verify_attach(ue_instance, expected_cell, alias="UE"):
    ATTENUATOR_MATRIX = json.loads(os.environ.get("attenuator_matrix"))
    cell_id = ue_instance.get_ue_info(alias, "CELL_ID")
    logger.log_info_to_console(f"UE is attached to cell: {cell_id}, should be: "
                               f"{ATTENUATOR_MATRIX[expected_cell]['real_cell_id']}", log_hierarchy=4)
    if int(cell_id) != int(ATTENUATOR_MATRIX[expected_cell]["real_cell_id"]):
        return False
    return True


def make_attach(ue_instance, expected_cell, alias="UE", action_before_attach=None):
    if action_before_attach is not None:
        logger.log_info_to_console(f"Try repair option: {action_before_attach.__name__.replace('_', ' ')} "
                                   f"for correct attach", log_hierarchy=3)
        action_before_attach(ue_instance, alias, expected_cell)
    ue_instance.attach_ue(alias)


def release_resources(alias="UE"):
    time.sleep(5)
    ue_instance = BuiltIn().get_library_instance("ue")
    ue_instance.stop_using_ue(alias)


def restart_ue_proxy(ue_instance, alias, expected_cell=None):
    ue_instance.stop_using_ue(alias)
    restart_ue_proxy_on_ue_pc()
    prepare_ue_for_test(alias=alias, clear_data=False)


def ue_reboot(ue_instance, alias, expected_cell=None):
    ue_instance.reboot_ue(alias)


def try_to_make_detach(alias="UE"):
    ue_instance = BuiltIn().get_library_instance("ue")
    ue_instance.detach_ue(alias)


def again_set_attenuation(expected_cell, ue_instance=None, alias=None):
    from attenuator_operations import adjust_attenuation
    from bts_operations import prepare_bts_before_call, perform_parameter_recommisioning
    prepare_bts_before_call()
    adjust_attenuation(attenuation_level="max")
    perform_parameter_recommisioning(cell_list=[expected_cell], param_level="min")
    adjust_attenuation(cell_ids=[expected_cell], attenuation_level="avg")


def perform_data_transfer_in_specific_direction(direction, duration, tput, protocol, deviation, cell_name, run_num,
                                                buffer_client, buffer_server, parallel_streams, size_packet, interval,
                                                linux_congestion, alias, raise_errors, rerun):
    logger.log_info_to_console(f"Performing data transfer in direction: {direction.upper()}", log_hierarchy=4)
    ue_instance = BuiltIn().get_library_instance("ue")
    if rerun is True:
        rerun = "_rerun"
    else:
        rerun = ""
    dt_name = "DT_" + cell_name + "_" + direction.upper() + "_" + str(run_num) + rerun
    try:
        start_data_transfer_on_real_ue(dt_name=dt_name, ue_alias=alias, direction=direction, protocol=protocol,
                                       duration=duration, tput=tput, parallel_streams=parallel_streams,
                                       size_packet=size_packet, buffer_client=buffer_client,
                                       buffer_server=buffer_server,
                                       interval=interval, linux_congestion=linux_congestion)
        logger.log_info_to_console(f"Checking if data transfer is alive", log_hierarchy=5)
        ue_instance.check_data_transfer_is_alive(dt_name=dt_name)
        logger.log_info_to_console(f"Awaiting data transfer finish", log_hierarchy=5)
        ue_instance.await_data_transfer_finish(dt_name=dt_name)
        ue_instance.verify_average_throughput_with_deviation(dt_name, tput=tput, deviation=deviation)
        logger.log_info_to_console(f"Average Tput for cell: {cell_name} in direction {direction.upper()} is: "
                                   f"{ue_instance.get_average_throughput(dt_name=dt_name) / 1000} Mbits/sec, "
                                   f"expected tput: {tput}", log_hierarchy=5)
    except Exception as e:
        if cell_name not in call_tmp_vars.failed_cells:
            logger.log_warn_to_console(f"[mbugaj] DT problem {dt_name}. Add to failed_cells")
            call_tmp_vars.failed_cells.append(cell_name)
        message = f"Some problem with data transfer dt_name: {dt_name}. \n" \
                  f"Error occured:\n{e}Please Check logs for more details."
        logger.log_warn_to_console(message, log_hierarchy=5)
        if raise_errors is True:
            raise DataTransferException(message)
    finally:
        try:
            call_tmp_vars.data_transfer_statistics[dt_name] = {
                "actual_tput": ue_instance.get_average_throughput(dt_name=dt_name) / 1000,
                "expected_tput": tput,
                "deviation": deviation
            }
        except Exception:
            call_tmp_vars.data_transfer_statistics[dt_name] = {
                "actual_tput": 0,
                "expected_tput": tput,
                "deviation": deviation
            }


def check_if_need_recall():
    return True if len(call_tmp_vars.failed_cells) > 0 else False


def get_failed_cells_list():
    return call_tmp_vars.failed_cells


def prepare_num_run_before_recall(run_num, add_val=100):
    return int(run_num) + int(add_val)
