import json
from pprint import pprint
from collections import defaultdict
from helpful_scripts.utilities import get_robot_output_dir


def get_failed_kpis(file, output):
    try:
        with open(file, "r", encoding="utf-8") as f:
            clean_data = json.load(f)[0]
        kpi_template_name = clean_data["comparator_template"]["name"]
        num_of_kpis = len(clean_data["report"]["kpis"].keys())
        if num_of_kpis:
            for kpi in clean_data["report"]["kpis"].keys():
                for cell in clean_data["report"]["kpis"][kpi]["data"].keys():
                    status = clean_data["report"]["kpis"][kpi]["data"][cell]["calculations"]["status"]
                    current_dict = clean_data["report"]["kpis"][kpi]["data"][cell]["current_period"]
                    reference_dict = clean_data["report"]["kpis"][kpi]["data"][cell]["reference_period"]
                    current_average = current_dict.get('average', None)
                    reference_average = reference_dict.get('average', None)
                    if status == "failed":
                        values = [current_average, reference_average]
                        output[kpi_template_name][kpi][cell][clean_data["id"]] = values
                    elif status == "out of range":
                        pprint(f"out of range: {kpi}")
                        if not current_average == reference_average:
                            values = [current_average, reference_average]
                            output[kpi_template_name][kpi][cell][clean_data["id"]] = values
        else:
            for pm in clean_data["report"]["pms"].keys():
                for cell in clean_data["report"]["pms"][pm]["data"].keys():
                    status = clean_data["report"]["pms"][pm]["data"][cell]["calculations"]["status"]
                    current_dict = clean_data["report"]["pms"][pm]["data"][cell]["current_period"]
                    reference_dict = clean_data["report"]["pms"][pm]["data"][cell]["reference_period"]
                    current_average = current_dict.get('average', None)
                    reference_average = reference_dict.get('average', None)
                    if status == "failed":
                        values = [current_average, reference_average]
                        output[kpi_template_name][pm][cell][clean_data["id"]] = values
                    elif status == "out of range":
                        pprint(f"out of range: {pm}")
                        if not current_average == reference_average:
                            values = [current_average, reference_average]
                            output[kpi_template_name][pm][cell][clean_data["id"]] = values
    except Exception as e:
        print(e)


def find_failed_kpis(kpi_report_list):
    try:
        output = defaultdict(lambda: defaultdict(lambda: defaultdict(dict)))
        to_del = list()
        for i in kpi_report_list:
            get_failed_kpis(f"{get_robot_output_dir()}{i}_kpi.json", output)
        template_name = next(iter(output))
        kpis = output[template_name].keys()
        for kpi in kpis:
            for cell in output[template_name][kpi].keys():
                data = output[template_name][kpi][cell]
                if len(data.keys()) < len(kpi_report_list):
                    to_del.append({kpi: cell})
        for pair in to_del:
            for kpi, cell in pair.items():
                del output[template_name][kpi][cell]
                if len(output[template_name][kpi].keys()) == 0:
                    del output[template_name][kpi]
        if len(output[template_name].keys()) == 0 or not output:
            pprint("Didn't found any errors")
            return None
        else:
            pprint(output)
            return output
    except Exception as e:
        print(e)
