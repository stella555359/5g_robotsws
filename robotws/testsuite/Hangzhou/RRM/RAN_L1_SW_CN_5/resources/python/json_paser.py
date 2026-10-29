import json


def get_json_content(file):
    with open(file) as fp:
        json_dict = json.load(fp)
    return json_dict


def calculate_iperf_bd_average(json_output):
    tmp_tp_list = []
    for i in json_output['intervals']:
        tmp_tp = 0.0
        for j in i["streams"]:
            tmp_tp = tmp_tp + j["bits_per_second"]
        tmp_tp_list.append(tmp_tp)
    return(float(sum(tmp_tp_list[30:])) / (len(tmp_tp_list)-30))
