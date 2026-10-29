import re
import os


def file_write(file_data, file_path):
    try:
        file_lst = file_path.split('.')
        file_path_temp = file_lst[0]+'_temp.'+file_lst[1]
        with open(file_path_temp, 'w+') as f:
            f.writelines(file_data)
            f.truncate()
        os.rename(file_path_temp, file_path)
    except Exception as e:
        print("exception during file_write of {} - {}".format(file_path, e))


def file_read(file_path):
    try:
        with open(file_path, 'r+') as f:
            file = f.readlines()
        return file
    except Exception as e:
        print("exception during file_read of {} - {}".format(file_path, e))


def modify_lue_info(file_data, sa_nsa, replace_text, ref_str, regex):
    modified_file = []
    for line in file_data:
        if sa_nsa in line:
            r = re.search(ref_str+regex, line)
            if r:
                modified_file.append(re.sub(str(r.group(1)), str(replace_text), line))
            else:
                modified_file.append(line)
        else:
            modified_file.append(line)
    return modified_file


def modify_entries(file_path, to_modify=None):
    if to_modify is None:
        return
    if file_path is None:
        raise Exception("imporper inputs - file_path :{}, params to modify:{}".format(file_path, to_modify))
    print(to_modify)
    try:
        file_data = file_read(file_path)
        for key, val in to_modify.items():
            if isinstance(val, dict):
                for subkey, subval in val.items():
                    if subkey == 'ue_nr_capabilities':
                        file_data = modify_lue_info(file_data, key, subval, subkey, "=([\\d\\w]+)[\\)\\s]*")
                    if subkey == 'nr_arfcn':
                        key = 'set_cell id='+key.split("_")[-1]+' gnb='
                        file_data = modify_lue_info(file_data, key, subval, subkey, "=([\\d\\w]+)[\\)\\s]*")
            if isinstance(val, str) or isinstance(val, int):
                file_data = modify_lue_info(file_data, key, val, key, "\\s*=\\s*([\\d]+)\\s*")
        file_write(file_data, file_path)
    except Exception as e:
        print("Skipped modify_entries due to error - {}".format(e))
