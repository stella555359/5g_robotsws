import re
import datetime
import taf.rfrl.utilities.logger.custom_logger as logger
from taf.rfrl.bts.devices.du.logs_collecting.basic_logs import GnbLog
from taf.rfrl.bts.parsers.snapshot_analyzer import _get_bts_zip_files_list, _get_specific_snapshot_file
from resources import get_correct_pernament_file_info, ItemsNotFound, save_file_content_to_file, get_output_dir, \
    verify_last_write
from ru_resources import get_ru_info
import gzip
import base64
import zipfile


def collect_snapshot(path_to_save):
    logger.log_info_to_console(f"Performing collect snapshot", log_hierarchy=2)
    gnb_log = GnbLog()
    snapshot_path = gnb_log.collect_snapshot(log_dir=path_to_save, snapshot_name="snapshot_CB010655")
    logger.log_info_to_console(f"Snapshot saved in {snapshot_path}", log_hierarchy=2)
    return snapshot_path


def get_bbbox_file_from_snapshot(file_to_check):
    snapshot_path = collect_snapshot(get_output_dir())
    bts_part_files = _get_bts_zip_files_list(snapshot_path)
    file = _get_specific_snapshot_file(bts_part_files, file_to_check)
    with zipfile.ZipFile(file, 'r').open("BBOX5") as file_content:
        file_content = file_content.read().decode().splitlines()
    save_file_content_to_file(file_content, "_snapshot_file_content")
    return file_content


def get_permanent_file_from_snapshot(file_to_check):
    snapshot_path = collect_snapshot(get_output_dir())
    bts_part_files = _get_bts_zip_files_list(snapshot_path)
    file = _get_specific_snapshot_file(bts_part_files, file_to_check)
    with gzip.open(file, 'r') as file_content:
        file_content = file_content.read().decode().splitlines()
    save_file_content_to_file(file_content, "_snapshot_file_content")
    return file_content


def verify_fault_history(file_to_check, state="1"):
    bbox5_file = get_bbbox_file_from_snapshot(file_to_check)
    if "List of events: " in bbox5_file:
        if verify_event_in_file(bbox5_file, "1152", state) is False:
            raise ItemsNotFound("Cannot find alarm 1152 in list of events")
    else:
        raise ItemsNotFound("Cannot find List of events in bbox5 file")


def verify_bts_alarm_history(file_to_check: str, event_id: str, state: str, type_of_event: str = "critical"):
    bbox5_file = get_bbbox_file_from_snapshot(file_to_check)
    is_event = False
    events_index = bbox5_file.index("Item type: BtsAlarmHistory")
    now = datetime.datetime.utcnow()
    date = now - datetime.timedelta(hours=4)
    formatted_date = date.strftime("%Y-%m-%dT%H:%M:%S+00:00")
    for line in range(events_index, len(bbox5_file)):
        if bbox5_file[line] == '---':
            break
        else:
            if event_id in bbox5_file[line] and type_of_event in bbox5_file[line]:
                line_tab = bbox5_file[line].split(",")
                if line_tab[3] == state and line_tab[4] > formatted_date:
                    is_event = True
                    break
    return is_event


def verify_event_in_file(bbox5_file, event_id, state):
    is_event = False
    events_index = bbox5_file.index("List of events: ")
    now = datetime.datetime.utcnow()
    date = now - datetime.timedelta(hours=4)
    formatted_date = date.strftime("%Y-%m-%dT%H:%M:%S+00:00")
    for line in range(events_index, len(bbox5_file)):
        if bbox5_file[line] == '---':
            break
        else:
            if event_id in bbox5_file[line]:
                line = bbox5_file[line]
                date = line[line.index("-,") + 2: len(line) - 2]
                act_state = line[len(line) - 1:]
                if date > formatted_date and act_state == state:
                    is_event = True
                    break
    return is_event


def verify_support_bts_id_and_bts_sw_version(file_to_check):
    permanent_file = get_permanent_file_from_snapshot(file_to_check)
    bts_id = base64.b64decode(find_value_by_key_in_pernament_file("BtsId", permanent_file)).decode('utf-8')
    correct_pernament_info = get_correct_pernament_file_info()
    if bts_id != correct_pernament_info:
        raise Exception(f"Expected values does not match. From snapshot file {bts_id}, "
                        f"from __init__.py and WebEM {correct_pernament_info}")
    else:
        logger.log_info_to_console("Expected values match", log_hierarchy=2)


def find_value_by_key_in_pernament_file(key, file_content):
    file = file_content[0].split("><")
    for line_num, line in enumerate(file):
        if key in line:
            output = file[line_num + 1]
            return output[output.index(">") + 1: output.index("<")]
    return ""


def verify_reset_counter_in_bbox5_file_in_snapshot(file_to_check, reset_count):
    bbox5_file = get_bbbox_file_from_snapshot(file_to_check)
    reset_count = int(reset_count) + 2
    count = 0
    now = datetime.datetime.utcnow()
    date = now - datetime.timedelta(hours=4)
    formatted_date = date.strftime("%Y-%m-%dT%H:%M:%S+00:00")
    if "Item type: resets" in bbox5_file:
        reset_counter = bbox5_file.index("Item type: resets")
        for line in range(reset_counter + 4, len(bbox5_file), 5):
            if count < reset_count:
                if f"Reset[{count}] Reset Reason" in bbox5_file[line]:
                    if f"Reset[{count}] Write:" in bbox5_file[line - 2] and \
                            f"Reset[{count}] Write: {formatted_date}" < bbox5_file[line - 2]:
                        logger.log_info_to_console(bbox5_file[line])
                        count += 1
                    else:
                        raise ItemsNotFound(f"Cannot find correct date for reset write")
                else:
                    raise ItemsNotFound(f"Cannot find Reset[{count}].. in file")


def verify_sw_version_after_enhancement_of_radio(file_to_check, ru_sw_versions):
    bbox5_file = get_bbbox_file_from_snapshot(file_to_check)
    line_count = 0
    ru_sw_versions.reverse()
    if "Item type: SW_version_history" in bbox5_file:
        sw_history = bbox5_file.index("Item type: SW_version_history") + 3
        for line_num in range(sw_history, len(bbox5_file)):
            if line_count < len(ru_sw_versions):
                if f"File[{line_count}] version: {ru_sw_versions[line_count]}" in bbox5_file[line_num]:
                    logger.log_info_to_console("OK: " + bbox5_file[line_num])
                elif f"File[{line_count}] ISTI time:" in bbox5_file[line_num]:
                    isti_time = float(bbox5_file[line_num][bbox5_file[line_num].index(": ") + 1:])
                    if isti_time != 0:
                        logger.log_info_to_console("OK: " + bbox5_file[line_num])
                        line_count += 1
                    else:
                        line_count += 1
                        raise ItemsNotFound("Isti time is equal to 0")
                elif f"File[{line_count}] write: " in bbox5_file[line_num]:
                    continue
                else:
                    raise ItemsNotFound("Cannot found correct values. Please check file manually")
    else:
        raise ItemsNotFound("Cannot found 'Item type: SW_version_history' in bbox5 file")


def verify_temperature_in_snapshot(file_to_check):
    bbox5_file = get_bbbox_file_from_snapshot(file_to_check)
    res_dict = {
        "act_val": "",
    }
    if "Item id: module:CORE" in bbox5_file:
        line_num = bbox5_file.index("Item id: module:CORE")
        for line in range(line_num, len(bbox5_file)):
            if "Values:" in bbox5_file[line]:
                res_dict["act_val"] = bbox5_file[line]
                break
        return res_dict


def verify_support_nvm_updating_in_file_in_snapshot(file_to_check):
    bbox5_file = get_bbbox_file_from_snapshot(file_to_check)
    now = datetime.datetime.utcnow()
    date = now - datetime.timedelta(hours=1)
    formatted_date = date.strftime("%Y-%m-%dT%H:%M:%S+00:00")
    data_to_check = ["BlackBox ver: 5.1", "Last save: " + formatted_date]
    logger.log_info_to_console(f"{bbox5_file[0]}, {data_to_check[0]}")
    logger.log_info_to_console(f"{bbox5_file[1]}, {data_to_check[1]}")
    if bbox5_file[0] == data_to_check[0] and bbox5_file[1] > data_to_check[1]:
        logger.log_info_to_console("All expected items are avaliable in BBOX5 file from snapshot", log_hierarchy=2)
    else:
        raise ItemsNotFound("Cannot find all expecten items in BBOX5 file from snapshot")


def verify_product_code_and_serial_number_in_bbox5_file_in_snapshot(file_to_check):
    bbox5_file = get_bbbox_file_from_snapshot(file_to_check)
    if "Item type: HW_information" in bbox5_file:
        hw_info = bbox5_file.index("Item type: HW_information")
        if bbox5_file[hw_info + 1] == f"radio product code: {get_ru_info('productCode')}":
            logger.log_info_to_console("Product code is available in BBOX5 file and is correct", log_hierarchy=2)
        else:
            raise ItemsNotFound("Product code is not found in BBOX5 file or is incorrect")
        if bbox5_file[hw_info + 2] == f"radio serial number: {get_ru_info('serialNumber')}":
            logger.log_info_to_console("Serial number is available in BBOX5 file and is correct", log_hierarchy=2)
        else:
            raise ItemsNotFound("Serial Number is not found in BBOX5 file or is incorrect")
    else:
        raise ItemsNotFound("Cannot find HW information in BBOX5 file in snapshot")


def verify_trigger_occur(expected_items, file_to_check, occurence):
    bbox5_file = get_bbbox_file_from_snapshot(file_to_check)
    for item in expected_items:
        for line in bbox5_file:
            match = re.search(item["item"] + r" (\d+)", line)
            if match:
                item[occurence] = match.group(1)
    return expected_items


def verify_all_items_are_avaliable_in_file(file_to_check, expected_items):
    bbox5_file = get_bbbox_file_from_snapshot(file_to_check)
    logger.log_info_to_console(bbox5_file)
    for item in expected_items:
        for line_num, line in enumerate(bbox5_file):
            if re.match(item, line):
                logger.log_info_to_console(f"Item '{item}' found in file {file_to_check}", log_hierarchy=2)
                count = 0
                for last_write in range(line_num, len(bbox5_file)):
                    if count < 5:
                        if "Reset Counter" not in item and "Item type: Voltage" not in item:
                            if "Last write: " in bbox5_file[last_write]:
                                lw_time = bbox5_file[last_write]
                                lw_time = lw_time[lw_time.index(':') + 1:]
                                if verify_last_write(lw_time):
                                    logger.log_info_to_console(
                                        f"Found Last write and is correct, for item '{item}' - {lw_time}",
                                        log_hierarchy=2)
                                    break
                                else:
                                    raise ItemsNotFound(f"Wrong Last write time  for item '{item}' - {lw_time}.")
                            else:
                                count += 1
                        elif "Reset Counter" in item:
                            r_c = bbox5_file[last_write]
                            reset_count = int(r_c[r_c.index(':') + 1:])
                            if reset_count == 0:
                                raise ItemsNotFound(f"Wrong value of: '{item}'")
                            else:
                                logger.log_info_to_console(f"Found correct value of '{item}' - '{str(reset_count)}'",
                                                           log_hierarchy=2)
                            break
                    else:
                        raise ItemsNotFound(f"Cannot find Last write time for item '{item}'")
                break
