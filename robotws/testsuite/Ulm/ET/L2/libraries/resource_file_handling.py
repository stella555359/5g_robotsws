
import json
import string
import logging
import taf.ccs.aashell
import deepdiff


def compare_resource_results(file_paths):
    """Compares two resource files and returns a dictionary with the result.

    Args:
        file_paths (list): List of Paths to the .json Files to compare.

    Returns:
        Dictionary: diff of the given Files
    """
    if type(file_paths) != list:
        logging.error("please provide a list of paths")
    dictionaries_list = []
    for file_path in file_paths:
        with open(file_path, "r") as file:
            dictionaries_list.append(json.load(file))
    ddiff = deepdiff.DeepDiff(dictionaries_list[0], dictionaries_list[1], ignore_order=True)
    return ddiff
    result = compare_resources_data_deepdiff(dictionaries_list[0], dictionaries_list[1])
    return result


def get_resources_for_current_scenario(scenario, ts_log_dir):
    return_dicts = []
    logging.info("reading file:\t"+ts_log_dir+"/resource_stats/"+scenario+"_before_scenario.json")
    with open(ts_log_dir+"/resource_stats/"+scenario+"_before_scenario.json") as file:
        return_dicts.append(json.load(file))
    logging.info("reading file:\t"+ts_log_dir+"/resource_stats/"+scenario+"_after_scenario.json")
    with open(ts_log_dir+"/resource_stats/"+scenario+"_after_scenario.json") as file:
        return_dicts.append(json.load(file))
    return return_dicts


if __name__ == "__main__":
    base_path = "/home/ute/logs/CB006064/20220706-141535-P/CB006064/\
        SBTS00_ENB_9999_220705_000006/20220706_141551/Logs/resource_stats/"
    file_paths = [
        base_path + "scenario_2_before_scenario.json",
        base_path + "scenario_2_after_scenario.json"
    ]
    result = compare_resource_results(file_paths)
    with open("result_file.json", "w") as file:
        json.dump(result, fp=file)
