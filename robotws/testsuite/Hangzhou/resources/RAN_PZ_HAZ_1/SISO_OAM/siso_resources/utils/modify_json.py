# -*- coding: utf-8 -*-
import json


def process_json(input_file, search_key, modify_value):
    with open(input_file, 'r') as f:
        data = json.load(f)
        keys_list = search_key.split('.')
        modify_dic(data, keys_list, modify_value)
        out_data = json.dumps(data, indent=2)

    f1 = open(input_file, 'w')
    f1.write(out_data)
    f1.close()


def modify_dic(dic, keys, value):
    for key in keys[:-1]:
        dic = dic.setdefault(key, {})

    if isinstance(type(dic[keys[-1]]), float):
        dic[keys[-1]] = float(value)
    elif isinstance(type(dic[keys[-1]]), int):
        dic[keys[-1]] = int(value)
    elif isinstance(type(dic[keys[-1]]), str):
        dic[keys[-1]] = str(value)
    elif isinstance(type(dic[keys[-1]]), bool):
        dic[keys[-1]] = bool(value)
    else:
        dic[keys[-1]] = value


def check_antenna_line_online_monitoring(input_file, para):
    with open(input_file, 'r') as f:
        datas = json.loads(f.read())
        check_para = datas['%s' % para]
        for subpara in check_para:
            antalines = subpara['antennaLines']
            for subant in antalines:
                meas = subant['measureDatas']
                for k, v in meas.items():
                    if 'LNCEL-' in k:
                        para_values = v.values()
                        if '-' in para_values or '0' in para_values:
                            raise Exception("%s[%s] value is %s" % (k, para, para_values))


if __name__ == "__main__":
    pass
