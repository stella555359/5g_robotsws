import json
import csv


def write_to_json_file(filepath, data):
    with open(filepath, mode="w") as data_file:
        data_file.write(json.dumps(data))


def get_average_current_tp_for_all_ues(traffic_dict_sa, traffic_dict_nsa):
    if type(traffic_dict_nsa) != str and type(traffic_dict_sa) != str:
        traffic_dict = traffic_dict_sa.update(traffic_dict_nsa)
    elif type(traffic_dict_sa) == str and type(traffic_dict_nsa) != str:
        traffic_dict = traffic_dict_nsa
    elif type(traffic_dict_nsa) == str and type(traffic_dict_sa) != str:
        traffic_dict = traffic_dict_sa
    else:
        log_string = "no useful data from bearer stats"
        return log_string
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
