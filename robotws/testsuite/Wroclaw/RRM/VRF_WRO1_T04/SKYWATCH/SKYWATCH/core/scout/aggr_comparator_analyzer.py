import json
from pprint import pprint
import glob
from core.scout.kpi_reports import get_kpi_values_from_report
from core.scout.kpi_analyzer import find_failed_kpis
from helpful_scripts.utilities import get_robot_output_dir


def single_aggregated_comparator_report_analysis(filename: str):
    """This function reads single json aggregated report.
    Then filters out only those, which are marked as Tester_Analysis needed
    Then returns it in format like:
    {'93471': {'1550': 1213363,
               '1769': 1213361,
               '1771': 1213359,
               '1774': 1213356,
               '1784': 1213347,
               '1785': 1213346,
               '1788': 1213343}
    rule like:
    aggr_rep_id: {comp_kpi_template_id: comp_kpi_report_id}"""
    try:
        output = {}
        with open(filename, "r", encoding="utf-8") as f:
            json_data = json.load(f)[0]
        aggr_rep_id = json_data['id']
        print(f"{filename.rsplit('_', 1)[0]} -> "
              f"https://scout.nsn-rdnet.net/comparator/aggregated-reports/{aggr_rep_id}")
        for comp_kpi_template_id in json_data["meta"]['report_display'].keys():
            if json_data['meta']['report_display'][comp_kpi_template_id]['tester_analysis'] is None:
                num_failed = json_data['meta']['report_display'][comp_kpi_template_id]['summary']['failed']
                comp_kpi_report_id = json_data['meta']['report_display'][comp_kpi_template_id]['comparator_report_pk']
                if num_failed > 0:
                    output[comp_kpi_template_id] = comp_kpi_report_id

        return {aggr_rep_id: output}
    except Exception as e:
        print(e)


def filter_all_aggr_comparator_reports():
    """This function filters out from all aggregated reports only those which are present
    in every single aggregated report, example output:
    {'93471': {'1550': 1213363,
               '1769': 1213361,
    '93472': {'1550': 1213387,
              '1769': 1213385,
    '93473': {'1550': 1213411,
              '1769': 1213409,
    }"""
    output = {}
    json_files = glob.glob(f"{get_robot_output_dir()}*_aggr.json")
    for file in json_files:
        output.update(single_aggregated_comparator_report_analysis(file))
    unique_keys = {k for d in output.values() for k in d}

    for key in unique_keys:
        if not all(key in d for d in output.values()):
            for d in output.values():
                d.pop(key, None)
    pprint(output)
    return output


def get_kpi_reports_from_comparator():
    all_temps = filter_all_aggr_comparator_reports()
    unique_temp_ids = {k for d in all_temps.values() for k in d}

    template_list = sorted(list(unique_temp_ids))
    kpi_dict = {}

    for template in template_list:
        id_list = []
        for key in sorted(all_temps.keys()):
            temp_data = all_temps[key]
            if template in temp_data:
                id_list.append(temp_data[template])
        kpi_dict[template] = id_list
    return kpi_dict


def run_kpi_comparator():
    kpi_dict = get_kpi_reports_from_comparator()
    if kpi_dict:
        for temp_id in kpi_dict:
            get_kpi_values_from_report(kpi_dict[temp_id])
            find_failed_kpis(kpi_dict[temp_id])
    else:
        pprint("Not found any errors")
