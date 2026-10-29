from robot.libraries.BuiltIn import BuiltIn
import taf.rfrl.utilities.logger.custom_logger as logger
import datetime


from taf.rfrl.bts.devices.du.sw_update import GnbSwUpdate
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.helpers.sw_versions import SwVersionFactory
import os


class ItemsNotFound(Exception):
    pass


class OccurencesHaveWrongValues(Exception):
    pass


def get_output_dir():
    return BuiltIn().get_variable_value("${OUTPUT DIR}")


def get_gnb_sw_version():
    gnb_sw = GnbDuOperations()
    return gnb_sw.get_bts_sw_version()


def check_sw_version(expected_sw_version, partition="active"):
    gnb_sw = GnbDuOperations()
    return gnb_sw.check_bts_sw_version(sw_version=expected_sw_version, partition=partition)


def check_and_download_if_needed_sw_package(gnb_sw_update, sw_version, target_dir="/tmp"):
    if not os.path.isfile(target_dir + "/" + SwVersionFactory.create_sw_version(sw_version).raw_with_release +
                          "_release_BTSSM_downloadable_A54.zip"):
        logger.log_info_to_console(f"SW build not found on VM. Performing download build {sw_version}.",
                                   log_hierarchy=2)
        gnb_sw_update.download_sw_package(sw_version=sw_version, target_dir=target_dir)
    return target_dir + "/" + SwVersionFactory.create_sw_version(sw_version).raw_with_release + \
        "_release_BTSSM_downloadable_A54.zip"


def generate_build_name_older(main_sw_version, num_of_days=0):
    sw_len = len(main_sw_version)
    main_sw_version[sw_len - 2] = str(int(main_sw_version[sw_len - 2]) - num_of_days).zfill(6)
    if "9999" in main_sw_version:
        date_str = main_sw_version[sw_len - 2]
        if int(date_str[len(date_str) - 2:]) > 30:
            date_str = date_str[:-2] + "30"
            main_sw_version[sw_len - 2] = date_str
    return main_sw_version


def try_to_update_sw(main_sw_version):
    logger.log_info_to_console(main_sw_version)
    gnb_sw_update = GnbSwUpdate()
    sw_build_separator = "_"
    if main_sw_version.split("_") == get_gnb_sw_version().split("_"):
        if "9999" in main_sw_version:
            logger.log_info_to_console("Trunk build found", log_hierarchy=2)
            num_of_days = 5
        else:
            logger.log_info_to_console("Branch build found", log_hierarchy=2)
            num_of_days = 20
        main_sw_version = generate_build_name_older(main_sw_version.split(sw_build_separator), num_of_days=num_of_days)
        main_sw_version = sw_build_separator.join(main_sw_version)
        logger.log_info_to_console(main_sw_version)
    if check_sw_version(main_sw_version, "passive") is True:
        logger.log_info_to_console("Sw build found on passive partition. Performing rollback", log_hierarchy=2)
        gnb_sw = GnbDuOperations()
        gnb_sw.rollback_software()
    else:
        for i in range(0, 10):
            try:
                _try_to_update_sw(gnb_sw_update, main_sw_version)
                break
            except Exception as e:
                logger.log_info_to_console(f"Probably cannot find gNB build ({main_sw_version}) on WFT. "
                                           f"Checking one more day older.... Error Message: {e}", log_hierarchy=3)
                main_sw_version = generate_build_name_older(main_sw_version.split(sw_build_separator), num_of_days=1)
                main_sw_version = sw_build_separator.join(main_sw_version)


def _try_to_update_sw(gnb_sw_update, main_sw_version):
    sw_build_path = check_and_download_if_needed_sw_package(gnb_sw_update, sw_version=main_sw_version)
    logger.log_info_to_console("Performing update software", log_hierarchy=2)
    gnb_sw_update.update_software(sw_build_path, timeout=3600)


def get_tl_variable():
    return BuiltIn().get_variable_value("${tl}")


def get_correct_pernament_file_info():
    return get_tl_name() + "_" + get_smod_info() + "_" + get_bbmod_info()


def get_tl_name():
    tl = get_tl_variable().test_pc.default_ssh_connection_details.addr
    return str(tl[:tl.index(".")].replace("-", "_"))


def get_smod_info():
    gnb_du = GnbDuOperations()
    product_code = gnb_du.get_gnb_parameter_value_via_gui(
        dist_name="MRBTS-76007/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1",
        param_name="Product code", param_abbr="productCode")
    serial_number = gnb_du.get_gnb_parameter_value_via_gui(
        dist_name="MRBTS-76007/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1",
        param_name="Serial number", param_abbr="serialNumber")
    return product_code + "_" + serial_number


def get_bbmod_info():
    gnb_du = GnbDuOperations()
    product_code = gnb_du.get_gnb_parameter_value_via_gui(
        dist_name="MRBTS-76007/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1",
        param_name="Product code", param_abbr="productCode")
    serial_number = gnb_du.get_gnb_parameter_value_via_gui(
        dist_name="MRBTS-76007/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1",
        param_name="Serial number", param_abbr="serialNumber")
    return product_code + "_" + serial_number


def get_smod_serial_number():
    gnb_du = GnbDuOperations()
    return gnb_du.get_gnb_parameter_value_via_gui(dist_name="MRBTS-76007/EQM_R-1/APEQM_R-1/CABINET_R-1/SMOD_R-1",
                                                  param_name="Product code", param_abbr="productCode")


def save_file_content_to_file(file_content, file_end_name):
    path_to_save = BuiltIn().get_variable_value("${OUTPUT DIR}") + "/"
    file_name = BuiltIn().get_variable_value("${TEST NAME}") + file_end_name + ".txt"
    with open(path_to_save + file_name, "w") as file:
        for item in file_content:
            file.write(item + "\n")


def verify_if_number_of_occurences_are_updated(trigger_occur):
    for trigger in trigger_occur:
        if trigger["change"] is True:
            if int(trigger["first_occurence"]) < int(trigger["second_occurence"]):
                logger.log_info_to_console(f"Occurences for item {trigger['item']} have correct values",
                                           log_hierarchy=2)
            else:
                raise OccurencesHaveWrongValues(f"Something wrong with checking occurences for item {trigger['item']}"
                                                f"First occurence has value: '{trigger['first_occurence']}', "
                                                f"Second occurence has value: '{trigger['second_occurence']}.' "
                                                f"Should be [Second Occurence] = [First occurence] + 1 ")
        else:
            if int(trigger["first_occurence"]) == int(trigger["second_occurence"]):
                logger.log_info_to_console(f"Occurences for item {trigger['item']} have correct values",
                                           log_hierarchy=2)
            else:
                raise OccurencesHaveWrongValues(f"Something wrong with checking occurences for item {trigger['item']}"
                                                f"First occurence has value: '{trigger['first_occurence']}', "
                                                f"Second occurence has value: '{trigger['second_occurence']}'. "
                                                f"Should be [Second Occurence] = [First occurence]")


def verify_if_temperature_is_changed(temperature_first_occurence, temperature_second_occurence):
    for temperature in temperature_first_occurence:
        if temperature_first_occurence[temperature] != "" and temperature_second_occurence[temperature] != "":
            if temperature_first_occurence[temperature] != temperature_second_occurence[temperature]:
                logger.log_info_to_console(f"{temperature} Values of temperature are updated correctly",
                                           log_hierarchy=2)
            else:
                raise ItemsNotFound(f"{temperature} Values of temperature are not updated correctly")


def verify_last_write(last_write_time, time_delta=24):
    now = datetime.datetime.utcnow()
    date = now - datetime.timedelta(hours=time_delta)
    formatted_date = date.strftime("%Y-%m-%dT%H:%M:%S+00:00")
    return last_write_time.strip() >= formatted_date
