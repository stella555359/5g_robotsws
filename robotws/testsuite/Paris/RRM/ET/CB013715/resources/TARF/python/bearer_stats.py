import json
import csv
import logging
import traceback

from testsuite.Paris.RRM.ET.resources.common.TtiTrace.python.tti_analyzer_framework import pandas_gate
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.tti_analysis.helper_functions import display_df_as_html, \
    display_df_as_table

# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

rbi = BuiltIn()
pd = None


def write_to_json_file(filepath, data):
    with open(filepath, mode="w") as data_file:
        data_file.write(json.dumps(data))


def get_average_current_tp_for_all_ues(traffic_dict_sa, traffic_dict_nsa):
    nsa_data_present = True if isinstance(traffic_dict_nsa, dict) else False
    sa_data_present = True if isinstance(traffic_dict_sa, dict) else False
    if nsa_data_present and sa_data_present:
        traffic_dict = traffic_dict_sa.update(traffic_dict_nsa)  # combines both traffic dicts
    elif not sa_data_present and nsa_data_present:
        traffic_dict = traffic_dict_nsa
    elif not nsa_data_present and sa_data_present:
        traffic_dict = traffic_dict_sa
    if not traffic_dict:
        return "no useful data from bearer stats"
    try:
        log_string = traffic_dict["timestamp"]
    except KeyError:
        log_string = ""
    ul_list = []
    dl_list = []
    for key, value in traffic_dict.items():
        if "UE" in key:
            ul_list.append(value["UL"]["Current_Throughput"])
            dl_list.append(value["DL"]["Current_Throughput"])
    average_current_ul = sum(ul_list)/len(ul_list)
    average_current_dl = sum(dl_list)/len(dl_list)
    log_string += "\t UL "
    log_string += str(float(average_current_ul)/10**6)
    log_string += " mbps"
    log_string += "\t DL "
    log_string += str(float(average_current_dl)/10**6)
    log_string += " mbps"
    return log_string


def get_headers(json_dict):
    headers = []
    for row in json_dict:
        try:
            headers += row.keys()
        except AttributeError:
            pass
    headers = list(set(headers))
    headers.sort()
    headers_copy = list(headers)
    for item in headers_copy:
        if "UE" in item:
            headers.append(item + "_UL_Average")
            headers.append(item + "_DL_Average")
            headers.append(item + "_UL_Current")
            headers.append(item + "_DL_Current")
            headers.remove(item)
    return headers


def write_csv(file_path, json_dict):
    with open(file_path, mode="w") as file:
        headers = get_headers(json_dict)
        writer = csv.DictWriter(file, fieldnames=headers)
        writer.writeheader()
        for row in json_dict:
            try:
                write_dict = {"timestamp": row["timestamp"]}
                for key, value in row.items():
                    if "UE" in key:
                        write_dict.update({key + "_UL_Average": value["UL"]["Average_Throughput"]})
                        write_dict.update({key + "_DL_Average": value["DL"]["Average_Throughput"]})
                        write_dict.update({key + "_UL_Current": value["UL"]["Current_Throughput"]})
                        write_dict.update({key + "_DL_Current": value["DL"]["Current_Throughput"]})
                        writer.writerow(write_dict)
            except TypeError:
                pass


def convert_bearer_stats_to_df(json_file, write_to_pickle=False, target_path=None):
    """ This function converts the bearer stats output from JSON file into
        a data frame

        :param json_file: Json file produced by the function 'Collect Bearer Stats and save to Json'
        :param write_to_pickle: boolean option to save df into a pickle file
        :param target_path: target path where to save pickle

        :returns: data frame with sample output below
        :rtype: df

        Sample output:
                    Timestamp	          UE	Direction	Average data rate
        1	2023-06-27 14:28:37.695013	UE_101	    DL	        4980000
        2	2023-06-27 14:28:37.695013	UE_101	    UL	        267072760
        3	2023-06-27 14:28:37.695013	UE_102	    DL	        4980000
        4	2023-06-27 14:28:37.695013	UE_102	    UL	        267072760
    """
    # for evaluation dont cut df prints
    pd.set_option('display.max_columns', None)

    # Read the JSON file into a pandas DataFrame
    df = pd.read_json(json_file)

    # Initialize an empty list to store the row data
    data_rows = []

    # Initialize an empty set to store the unique column names
    column_names = set()

    # Extract all unique column names from the JSON data
    for _, row in df.iterrows():
        timestamp = row.get('timestamp')
        for ue, ue_data in row.items():
            if ue == 'timestamp':
                continue
            if isinstance(ue_data, dict):
                for direction, direction_data in ue_data.items():
                    if isinstance(direction_data, dict):
                        column_names.update(set(direction_data.keys()))

                        # Create a dictionary for the row data
                        row_data = {
                            'Timestamp': timestamp,
                            'UE': ue,
                            'Direction': direction
                        }
                        row_data.update(direction_data)
                        data_rows.append(row_data)

    # Create a new DataFrame with the desired structure
    new_df = pd.DataFrame(data_rows, columns=['Timestamp', 'UE', 'Direction'] + list(column_names))

    if write_to_pickle:
        new_df.to_pickle(target_path)

    display_df_as_html(new_df)
    display_df_as_table(new_df)

    return df


tput_convertion_table = {
    'Gbps': 1000,
    'Mbps': 1,
    'Kbps': .001,
    'bps': .000001,
}


def get_tput_from_ue_stats(ue_stats_str, UeId=1, dir='PDSCH'):
    """
    ue_stats_str
        result of egate command
            ue_stats_nr id=${index} scell=${scell} type=${dir} size_unit=bytes
    Return
        0 - Current
        1 - Minimum
        2 - Maximum
        3 - Average
    """
    # ue_stats_nr id=${index} scell=${scell} type=${dir} size_unit=bytes
    # CellIndex    Current    Minimum    Maximum    Average
    # CellIndex-0  17.9 Mbps  17.9 Mbps  19.3 Mbps  18.6 Mbps
    #     0          1   2     3    4     5    6      7   8
    # for evaluation dont cut df prints
    pd.set_option('display.max_columns', None)

    # Initialize an empty list to store the row data
    data_rows = []

    # Initialize an empty set to store the unique column names
    column_names = set()

    type = 'NR ' + dir + ' Tput'
    try:
        total_mbps = [0, 0, 0, 0]
        ues = [line for line in ue_stats_str.split('\n') if "UE-" in line]
        cells = [line for line in ue_stats_str.split('\n') if "CellIndex-" in line]
        columns_cells = cells[0].split()
        cellId = columns_cells[0].strip()
        list_cellId = []
        for ue in ues:
            columns = ue.split()
            ueId = columns[0].strip()
        for cell in cells:
            perma_shift = 0
            for i in range(0, 4):
                column_index = (i*2)+1-perma_shift
                columns = cell.split()
                cellId = columns[0]
                if cellId not in list_cellId:
                    list_cellId.append(cellId)
                tput = float(columns[column_index].strip())
                rate = columns[column_index+1].strip()
                if rate.isnumeric():
                    rate = 'bps'
                    perma_shift = perma_shift+1
                mbps_tput = round(tput * tput_convertion_table[rate], 2)
                total_mbps[i] = total_mbps[i] + mbps_tput
        # Create a dictionary for the row data
        row_data = {
            'UeId':   UeId,
            'CellIndex-': list_cellId,
            'Direction': type,
            'Current': total_mbps[0],
            'Minimum': total_mbps[1],
            'Maximum': total_mbps[2],
            'Average': total_mbps[3]
        }
        data_rows.append(row_data)
        # Create a new DataFrame with the desired structure
        new_df = pd.DataFrame(data_rows,
                              columns=['UeId', 'CellIndex-', 'Direction', 'Current', 'Minimum', 'Maximum', 'Average'])
        display_df_as_table(new_df)
    except Exception as e:
        print(f"{e}\n {traceback.format_exc()}")
        return total_mbps
    return total_mbps


def test_ue_stats_str():
    content = """
    =====================================================================
    CellIndex    Current       Minimum       Maximum       Average
    ---------------------------------------------------------------------
    CellIndex-0  284.6 Mbps    157.1 Mbps    284.6 Mbps    206.1 Mbps
    CellIndex-1  54.1 Mbps     13.6 Mbps     54.1 Mbps     36.8 Mbps
    ---------------------------------------------------------------------
    Total
    ---------------------------------------------------------------------
    2 cells      338.703 Mbps  170.726 Mbps  338.703 Mbps  242.847 Mbps
    ---------------------------------------------------------------------
    =====================================================================
    """
    global pd
    pd = pandas_gate.install_and_import_pandas()
    total_mbps = get_tput_from_ue_stats(content, UeId=1, dir='PDSCH')
    print(f"total_mbps = {total_mbps}")


if __name__ == "__main__":
    logging.basicConfig(level=logging.DEBUG)
    test_ue_stats_str()
