import datetime as dt
import re
import os
from testsuite.Wroclaw.RRM.VRF_WRO2_T01.resources.legacy.qxdm.utils.logs_exceptions import EmptyParsedFiles


def parse_date(string_date):
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    string_date = string_date.replace("  ", " ")
    month_re = r'[A-za-z-az]{3}'
    month_name = re.findall(month_re, string_date)[0]
    month_number = months.index(month_name) + 1

    string_date = string_date.replace(month_name, str(month_number))
    return dt.datetime.strptime(string_date, '%Y %m %d %H:%M:%S')


def parse_tput(tput_line):
    def _get_number_value(string_to_get):
        return "".join(re.findall(r'[0-9]', string_to_get))

    params_d = {'AvgPHY': 0, 'BLER': None, 'AvgMCS': None, 'CA_ID': None}

    tput_params_t = tput_line.split("|")

    for param in tput_params_t:
        for param_key in params_d.keys():
            if param_key in param:
                params_d[param_key] = _get_number_value(param)
    return params_d


def split_file(path):
    files_to_create = ["5g_dl.txt", "5g_ul.txt", "lte_dl.txt", "lte_ul.txt"]
    split_to_5g_dl = """cat {} | grep -B 1 "NR5GMAC  | DL since last" > 5g_dl.txt""".format(path)
    split_to_5g_ul = """cat {} | grep -B 1 "NR5GMAC  | UL since last | CA_ID" > 5g_ul.txt""".format(path)
    split_to_lte_dl = """cat {} | grep -B 1 "LML1     | DL since last" > lte_dl.txt""".format(path)
    split_to_lte_ul = """cat {} | grep -B 1 "LML1     | UL since last" > lte_ul.txt""".format(path)
    os.system(split_to_5g_dl)
    os.system(split_to_5g_ul)
    os.system(split_to_lte_dl)
    os.system(split_to_lte_ul)
    files_with_logs = []
    for file in files_to_create:
        if os.stat(file).st_size > 0:
            files_with_logs.append(file)
    if not files_with_logs:
        raise EmptyParsedFiles()
    return files_with_logs
