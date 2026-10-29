import re


def get_tput_e500(e500_response):
    regex_dl_sch = r"DL-SCH.*\r\n.*\r\n.*(Throughput:.*)\r\n(.*\r\n)*.*BLER.*\r\n.*([0-1]\.\d{10})"
    regex_ul_sch = r"UL-SCH.*\r\n.*(Throughput:.*)\r\n(.*\r\n)*.*BLER.*\r\n.*([0-1]\.\d{10})"
    regex_dl_logch = r"DL LogCh.*\r\n.*(Throughput:.*)\r\n"
    regex_ul_logch = r"UL LogCh.*\r\n.*(Throughput:.*)\r\n"
    result = {}
    res_key = ["dl_sch", "ul_sch", "dl_logch", "ul_logch"]
    for i, regex in enumerate([regex_dl_sch, regex_ul_sch, regex_dl_logch, regex_ul_logch]):
        res = re.findall(regex, e500_response)
        tput_info = res[0]
        if type(tput_info) == str or type(tput_info) == unicode:
            tput_res = __tput_result(tput_info)
        else:
            tput_res = __tput_result(tput_info[0])
            tput_res.update({"bler": tput_info[-1]})
        result.update({res_key[i]: tput_res})
    return result


def __tput_result(tput_info):
    res = {}
    res["avg"] = re.findall(r"Average:\s*(\d+)", tput_info)
    res["max"] = re.findall(r"Max:\s*(\d+)", tput_info)
    return res
