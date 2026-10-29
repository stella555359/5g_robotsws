import os
import glob
import logging
from pyparsing import Word, alphas, oneOf
from robot.libraries.BuiltIn import BuiltIn


def get_specific_resource_list(resource_list, parameters):
    comparators = {
        '=': lambda x, y: x == y,
        '!=': lambda x, y: x != y,
    }
    word = Word(alphas + " " + alphas)
    symbol = oneOf("= !=")
    parsed = word + symbol + word
    parameter_list = parameters.split(",")
    specific_resource_list = []
    for resource_info in resource_list:
        flag = True
        for parameter in parameter_list:
            parsed_expression = parsed.parseString(parameter)
            comparator = comparators[parsed_expression[1]]
            if parsed_expression[0] == "availabilityStatus" \
                    and "availabilityStatus" not in resource_info["status"].keys():
                resource_info["status"]["availabilityStatus"] = "online"
            if not comparator(resource_info["status"][parsed_expression[0]], parsed_expression[2]):
                flag = False
                break
        if flag:
            specific_resource_list.append(resource_info)
    return specific_resource_list


def compare_ru_status(ru_status_before, ru_status_after, apart=None):
    if apart:
        apart = apart.strip(":").split(":")
        ru_status_before = [ru for ru in ru_status_before if ru["serialNumber"] not in apart]
        ru_status_after = [ru for ru in ru_status_after if ru["serialNumber"] not in apart]
    before_length = len(ru_status_before)
    after_length = len(ru_status_after)
    if before_length != after_length:
        raise Exception("ru count not equal after action ")
    ru_status_before.sort(key=lambda ru: ru["serialNumber"])
    ru_status_after.sort(key=lambda ru: ru["serialNumber"])
    for index in range(after_length):
        if ru_status_before[index]["status"]["administrativeState"] \
                != ru_status_after[index]["status"]["administrativeState"]:
            raise Exception("ru{} status not equal before and after, before:{}, after:{}".format(
                ru_status_before[index]["serialNumber"], ru_status_before[index]["status"]["administrativeState"],
                ru_status_after[index]["status"]["administrativeState"]))
        if "availabilityStatus" in ru_status_before[index]["status"]:
            if ru_status_before[index]["status"]["availabilityStatus"] \
                    != ru_status_after[index]["status"]["availabilityStatus"]:
                raise \
                    Exception("ru{} status not equal before and after, before:{}, after:{}".format(
                        ru_status_before[index]["serialNumber"],
                        ru_status_before[index]["status"]["availabilityStatus"],
                        ru_status_after[index]["status"]["availabilityStatus"]))
        if ru_status_before[index]["status"]["operationalState"] \
                != ru_status_after[index]["status"]["operationalState"]:
            raise Exception("ru{} status not equal before and after, before:{}, after:{}".format(
                ru_status_before[index]["serialNumber"], ru_status_before[index]["status"]["operationalState"],
                ru_status_after[index]["status"]["operationalState"]))


def compare_cell_status(cell_before, cell_after, apart=None):
    if apart:
        apart = apart.strip(":").split(":")
        cell_before = [cell for cell in cell_before if str(cell["physicalCellId"]) not in apart]
        cell_after = [cell for cell in cell_after if str(cell["physicalCellId"]) not in apart]
    before_length = len(cell_before)
    after_length = len(cell_after)
    if before_length != after_length:
        raise Exception("cell count not equal after action ")
    cell_before.sort(key=lambda cell: cell["physicalCellId"])
    cell_after.sort(key=lambda cell: cell["physicalCellId"])
    print(cell_before)
    print(cell_after)
    for index in range(after_length):
        if cell_before[index]["status"]["administrativeState"] \
                != cell_after[index]["status"]["administrativeState"]:
            raise Exception("cell{} status not equal before and after, before:{}, after:{}".format(
                cell_after[index]["physicalCellId"], cell_before[index]["status"]["administrativeState"],
                cell_after[index]["status"]["administrativeState"]))
        if "availabilityStatus" in cell_before[index]["status"]:
            if "availabilityStatus" not in cell_after[index]["status"]:
                raise \
                    Exception("cell{} status not equal before and after, before:{}, after:{}".format(
                        cell_after[index]["physicalCellId"], cell_before[index]["status"], cell_after[index]["status"]))
            if cell_before[index]["status"]["availabilityStatus"] \
                    != cell_after[index]["status"]["availabilityStatus"]:
                raise \
                    Exception("cell{} status not equal before and after, before:{}, after:{}".format(
                        cell_after[index]["physicalCellId"], cell_before[index]["status"]["availabilityStatus"],
                        cell_after[index]["status"]["availabilityStatus"]))
        if cell_before[index]["status"]["operationalState"] \
                != cell_after[index]["status"]["operationalState"]:
            raise Exception("cell{} status not equal before and after, before:{}, after:{}".format(
                cell_after[index]["physicalCellId"], cell_before[index]["status"]["operationalState"],
                cell_after[index]["status"]["operationalState"]))
        if cell_before[index]["status"]["blockingState"] \
                != cell_after[index]["status"]["blockingState"]:
            raise Exception("ru{} status not equal before and after, before:{}, after:{}".format(
                cell_after[index]["serialNumber"], cell_before[index]["status"]["blockingState"],
                cell_after[index]["status"]["blockingState"]))


def remove_keys(para_list, key_list):
    new_para_list = []
    for para_dict in para_list:
        para_dict = {key: para_dict[key] for key in para_dict.keys() if key not in key_list}
        new_para_list.append(para_dict)
    return new_para_list


def intersection(para_list1, para_list2, key="serialNumber"):
    para_set1 = set()
    for para_info in para_list1:
        if isinstance(para_info, dict) and key in para_info.keys():
            para_set1.add(para_info[key])
        else:
            para_set1.add(para_info)
    para_set2 = set()
    for para_info in para_list2:
        if isinstance(para_info, dict) and key in para_info.keys():
            para_set2.add(para_info[key])
        else:
            para_set2.add(para_info)
    inter_list = list(para_set1 & para_set2)
    return inter_list


def get_link_map(ggmap, unlinkmap):
    unlink_fr = intersection(ggmap.keys(), unlinkmap.keys())
    linkmap = {}
    for key in ggmap.keys():
        if key not in unlink_fr:
            linkmap[key] = ggmap[key]
        else:
            linkmap[key] = {}
            for port in ggmap[key].keys():
                if ggmap[key][port] not in str(unlinkmap[key]):
                    linkmap[key][port] = ggmap[key][port]
    return linkmap


def get_snapshot_file(btsid, file_path):
    snapshots = glob.glob("{}/Snapshot_*.zip".format(file_path))
    snapshots = [snapshot for snapshot in snapshots if btsid in snapshot]
    snapshots.sort(key=lambda fn: os.path.getmtime(fn))
    return snapshots[-1]


def start_logging(logfile):
    logger = logging.getLogger(__name__)
    logger.setLevel(level=logging.INFO)

    handler = logging.FileHandler(logfile, mode='w')
    formatter = logging.Formatter("%(asctime)s-%(message)s")
    handler.setFormatter(formatter)
    logger.addHandler(handler)

    return logger


def logging_info(message):
    logger = robot_var("LOGGER")
    logger.info(message)
    BuiltIn().log_to_console(message)


def robot_var(variable_name):
    return BuiltIn().get_variable_value("${{{}}}".format(variable_name))


def get_ru_cells(ru_sn, all_cells):
    ru_cells = []
    for cell_info in all_cells:
        rf_list = cell_info["RF"]
        for ru_info in rf_list:
            if ru_info["serialNumber"] == ru_sn:
                ru_cells.append(cell_info)
    return ru_cells


def lists_intersection(list1, list2):
    onair_cell_list = []
    intersection_cell = [x for x in list1 if x in list2]
    [onair_cell_list.append(i) for i in intersection_cell if i not in onair_cell_list]
    return onair_cell_list
