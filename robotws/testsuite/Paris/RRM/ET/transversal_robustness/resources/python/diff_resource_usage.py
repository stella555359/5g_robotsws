import os
from operator import itemgetter
from taf.ccs.aashell import ResourcesUsage


def _read_tolerance_file(tolerance_file_name, tolerance_list):
    tolerance_file = open(tolerance_file_name, "r")
    file_content = tolerance_file.readlines()
    tolerance_file.close()
    for line in file_content:
        if not line.startswith("#"):
            if line.startswith("include"):
                current_path = os.path.dirname(tolerance_file_name)
                included_file_name = line.split("include")[1].strip()
                _read_tolerance_file(current_path + "/" + included_file_name, tolerance_list)
            else:
                tolerance_pattern = line.split(";", 1)[0].strip()
                tolerance_string = line.split(";", 1)[1].strip()
                tolerance_list[tolerance_pattern] = tolerance_string


def _sort_by_values(input_object):
    if isinstance(input_object, list) and len(input_object) > 0:
        if isinstance(input_object[0], dict):
            names_for_sorting = ["l2NrtPoolId", "l2hiPoolId", "l2loPoolId", "l2psPoolId", "cpUeAppId", "nrCellGrpId",
                                 "nrCellIdentity", "resourceType"]
            for name_for_sorting in names_for_sorting:
                if name_for_sorting in input_object[0]:
                    input_object.sort(key=itemgetter(name_for_sorting))
                    break
        for item in input_object:
            _sort_by_values(item)
    elif isinstance(input_object, dict):
        for item in input_object:
            _sort_by_values(input_object[item])


def _get_resource_obj(resources_usage):
    _sort_by_values(resources_usage)
    resource_obj = ResourcesUsage(resources_usage)
    print("ResourcesUsage object:")
    for path in resource_obj.paths():
        print(path, resource_obj.xpath(path))
    return resource_obj


def diff_resource_usage(resources_usage1, resources_usage2, tolerance_file_name):
    print("resources_usage1", resources_usage1)
    print("resources_usage2", resources_usage2)
    differences = []
    tolerances = {}
    _read_tolerance_file(tolerance_file_name, tolerances)
    resource1_obj = _get_resource_obj(resources_usage1)
    resource2_obj = _get_resource_obj(resources_usage2)
    resource1_paths = resource1_obj.paths()
    resource2_paths = resource2_obj.paths()
    if resource1_paths != resource2_paths:
        differences.append("Paths differ")
    for path in resource1_paths:
        if path in resource2_paths:
            value1 = resource1_obj.xpath(path)
            value2 = resource2_obj.xpath(path)
            if value1 != value2:
                if path in tolerances:
                    tolerance = tolerances[path]
                    if tolerance == "NO_CHECK":
                        print(f"Difference cfg NO_CHECK for {path}: {value1} vs {value2}")
                        continue
                    if abs(float(value1[0]) - float(value2[0])) <= float(tolerance):
                        print(f"Difference in tolerance for {path}: {value1} vs {value2}")
                        continue
                differences.append(f"Difference found for {path}: {value1} vs {value2}")
        else:
            differences.append(f"Missing path in 2nd object: {path}")
    return differences


if __name__ == '__main__':
    resources_list = [
        {'CPNRT': {'activeUes': 1, 'ueIdList': {'ueIdentifiers': [4, 5]}}},
        {'CPNRT': {'activeUes': 0, 'ueIdList': {'ueIdentifiers': [4, 6]}}},
    ]
    print(diff_resource_usage(resources_list[0], resources_list[1], "../../config/resource_usage/tolerance.csv"))
