from taf.sw.scout import scout
from robot.api import logger
from helpful_scripts.utilities import get_robot_output_dir, get_machine_name
import subprocess
import sys
import os
from datetime import datetime, timezone, timedelta
import json


sc = scout()


def clean_test_time_file():
    file = f"{get_robot_output_dir()}times.csv"
    if os.path.exists(file):
        os.remove(file)


def save_test_time(name, start, end):
    try:
        import pandas as pd
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "pandas"])
        import pandas as pd
    file = f"{get_robot_output_dir()}times.csv"

    row = pd.DataFrame([{
        "testname": name,
        "start": start,
        "end": end
    }])

    row.to_csv(
        file,
        mode="a",
        header=not pd.io.common.file_exists(file),
        index=False
    )


def connect_to_scout(api_key):
    sc.setup_scout(scout_testline_name=get_machine_name().replace("-", "_"), api_key=api_key, timeout=600)
    sc.enable_full_kpi_pm_collection()


def prepare_kpi_report(template_id):
    try:
        import pandas as pd
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "pandas"])
        import pandas as pd

    file = f"{get_robot_output_dir()}times.csv"
    df = pd.read_csv(file)
    start_str = df.iloc[0]["start"]
    end_str = df.iloc[-1]["end"]
    start = pd.to_datetime(start_str).floor("5min")
    end = pd.to_datetime(end_str).ceil("5min")
    diff = end - start
    if diff < pd.Timedelta(minutes=15):
        logger.info(f"Scout report will not be created, run time was shorter than min. 15 minutes")
    else:
        report_name = "skywatch_kpi_report"
        kpi_report = sc.generate_kpi_report(report_name,
                                            template_id,
                                            start_time=start.isoformat(),
                                            end_time=end.isoformat(),
                                            alias='default')
        logger.info(kpi_report)


def generate_pairs(df):
    idx = list(df.index)
    pairs = []
    for i in range(len(idx) - 1):
        pairs.append((idx[i], idx[i + 1]))

    if len(idx) > 2:
        pairs.append((idx[0], idx[-1]))
    return pairs


def prepare_kpi_comparator_report():
    try:
        import pandas as pd
    except ImportError:
        subprocess.check_call([sys.executable, "-m", "pip", "install", "pandas"])
        import pandas as pd

    comparator_template_dict = {
        "Additional_KPIs_Others_26R3": 1788,
        "Additional_KPIs_User_throughput_26R3": 1787,
        "Additional_KPIs_Retainability_26R3": 1786,
        "Additional_KPIs_Resource_utilization_26R3": 1785,
        "Additional_KPIs_Radio_quality_26R3": 1784,
        "Additional_KPIs_Mobility_26R3": 1783,
        "Additional_KPIs_Latency_26R3": 1782,
        "Additional_KPIs_Cell_throughput_26R3": 1781,
        "Additional_KPIs_Capacity_26R3": 1780,
        "Additional_KPIs_Accessibility_26R3": 1779,
        "Mandatory_KPIs_User_throughput_26R3": 1777,
        "Mandatory_KPIs_Retainability_26R3": 1776,
        "Mandatory_KPIs_Resource_utilization_26R3": 1775,
        "Mandatory_KPIs_Radio_quality_26R3": 1774,
        "Mandatory_KPIs_Others_26R3": 1773,
        "Mandatory_KPIs_Mobility_26R3": 1772,
        "Mandatory_KPIs_Latency_26R3": 1771,
        "Mandatory_KPIs_Energy_Efficiency_26R3": 1770,
        "Mandatory_KPIs_Cell_throughput_26R3": 1769,
        "Mandatory_KPIs_Accessibility_26R3": 1768,
        "Additional_Counters_TMO_US_counter_L3": 1550,
        "Additional_Counters_TMO_US_counter_L2": 1549,
        "Additional_Counters_TMO_US_counter_L1": 1548,
        "Additional_Counters_TMO_US_counter_gNB": 1547,
    }

    template_ids = list(comparator_template_dict.values())
    report_name = "Skywatch_report"
    file = f"{get_robot_output_dir()}times.csv"
    df = pd.read_csv(file)
    pairs = generate_pairs(df)
    logger.info(f"actual pairs: {pairs}")
    for id1, id2 in pairs:
        start_str = df.iloc[id1]["start"]
        end_str = df.iloc[id1]["end"]
        start = pd.to_datetime(start_str)
        end = pd.to_datetime(end_str)
        start2_str = df.iloc[id2]["start"]
        end2_str = df.iloc[id2]["end"]
        start2 = pd.to_datetime(start2_str)
        end2 = pd.to_datetime(end2_str)
        start_rounded = start.floor("5min")
        end_rounded = end.floor("5min") - pd.Timedelta(minutes=10)
        start2_rounded = start2.floor("5min")
        end2_rounded = end2.floor("5min") - pd.Timedelta(minutes=10)

        diff = end_rounded - start_rounded
        if diff < pd.Timedelta(minutes=15):
            logger.info(f"Scout comparator report will not be created, run time was shorter than min. 15 minutes")
        else:
            comparator_report = sc.generate_comparator_report(report_name, template_ids,
                                                              reference_start_time=start_rounded.isoformat(),
                                                              reference_end_time=end_rounded.isoformat(),
                                                              current_start_time=start2_rounded.isoformat(),
                                                              current_end_time=end2_rounded.isoformat(),
                                                              reference_period_description=None,
                                                              current_period_description=None,
                                                              alpha_factor=0.05,
                                                              block_until_ready=True, timeout=500, alias='default')
            comparator_report_json = json.dumps(comparator_report)
            # logger.info(comparator_report_json)
            file_path = f"{get_robot_output_dir()}Run{id1 + 1}_vs_Run{id2 + 1}_{comparator_report[0]['id']}_aggr.json"
            with open(file_path, "w", encoding="utf-8") as f:
                f.write(comparator_report_json)


def get_kpi_values_from_report(report_id_list):
    for report_id in report_id_list:
        endpoint = f"comparator_reports/{report_id}/"
        params = {
            "fields[comparator_template]": "name",
            "fields[testline]": "name,archived",
            "include": "author,testline,comparator_template"
        }
        # connect_to_scout("2_16_UTE5GCLASSICAL4673")
        # connect_to_scout(get_machine_name().replace("-", "_"))
        output = sc.store.get_alias_value('default').connection.get(endpoint, params=params)
        output_json = json.dumps(output)
        file_path = f"{get_robot_output_dir()}{report_id}_kpi.json"
        with open(file_path, "w", encoding="utf-8") as f:
            f.write(output_json)
