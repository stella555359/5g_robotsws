import yaml
import os
import re
import sys
from delta_scfc_generator import *
import xml_mod
import lua_mod

CONFIG_YAML = "params_update_perf.yaml"


def modify_config_files(file_path, stream):
    try:
        print("\nfile_path: {0}\n".format(file_path))
        config_file = os.path.join(os.path.dirname(os.path.realpath(__file__)), CONFIG_YAML)
        with open(config_file, 'r') as cfg_file:
            try:
                yaml_data = yaml.load(cfg_file, Loader=yaml.FullLoader)
                for each_stream in yaml_data["streams"]:
                    if each_stream["name"] == stream:
                        if 'scfc' in file_path:
                            file_data = file_read(file_path)
                            if "scf_update" in each_stream:
                                for key, value in each_stream["scf_update"].items():
                                    if isinstance(value, str):
                                        file_data = modify_param_value(file_data, key, value)
                                    if isinstance(value, dict):
                                        for subkey, val in value.items():
                                            file_data = modify_param_value(file_data, subkey, val, dist_name=key)
                                    if isinstance(value, list):

                                        file_data = list_include(file_data, key, value)
                            if "scf_delete" in each_stream:
                                for key, value in each_stream["scf_delete"].items():
                                    if value is None:
                                        file_data = delete_DistName(file_data, key)
                                    else:
                                        file_data = delete_param(file_data, value, key)
                            if "scf_add" in each_stream:
                                for key, value in each_stream["scf_add"].items():
                                    for subkey, val in value.items():
                                        if isinstance(val, str):
                                            file_data = add_new_param(file_data, subkey, val, dist_name=key)
                            if "scf_list" in each_stream:
                                for key, value in each_stream["scf_list"].items():
                                    for subkey, val in value.items():
                                        print(subkey, val)
                                        file_data = add_new_list(file_data, subkey, val, dist_name=key)
                            file_write(file_data, file_path)
                        if 'swconfig' in file_path:
                            if "gnb_sw_update" in each_stream:
                                for key, value in each_stream["gnb_sw_update"].items():
                                    print(key, value)
                                    add_param(file_path, value)
                        if 'iphy' in file_path:
                            if 'iphy' in each_stream:
                                if 'MOD' in each_stream['iphy']:
                                    xml_mod.replace_value(file_path, each_stream['iphy']['MOD'])
                        if file_path.lower().endswith(('.lua')) or file_path.lower().endswith(('.cfg')):
                            if 'lua' in each_stream:
                                if 'MOD' in each_stream['lua']:
                                    lua_mod.modify_entries(file_path, each_stream['lua']['MOD'])
                                else:
                                    raise Exception("ERROR: Unsupported option")

            except yaml.YAMLError as exc:
                raise Exception("ERROR: ", exc)
    except Exception as e:
        print("exception during modify_config_files of {}, {} - {}".format(file_path, stream, e))


def add_new_param(file_data, subkey, val, dist_name=None):
    try:
        if dist_name is not None:
            start_dn, end_dn = fetch_dn_lines(file_data, dist_name)
            if start_dn == -1 or end_dn == -1:
                raise Exception("DN not found in the input scf")
            else:
                if subkey not in file_data[start_dn:end_dn]:
                    file_data.insert(start_dn+1, '<p name="'+subkey+'">'+val+'</p>\n')
                else:
                    raise Exception("parameter already present")
        else:
            raise Exception("DN is not defined")
        return file_data
    except Exception as e:
        print("exception during add_new_param of {}, {} - {}".format(subkey, val, e))


def add_new_list(file_data, subkey, val, dist_name=None):
    print(subkey, val)
    try:
        if dist_name is not None:
            start_dn, end_dn = fetch_dn_lines(file_data, dist_name)
            if start_dn == -1 or end_dn == -1:
                raise Exception("DN not found in the input scf")
            else:
                file_data.insert(start_dn+1, '<list name="'+subkey+'">\n')
                print('val is {}'.format(val))
                if isinstance(val, list):
                    count = start_dn+1
                    for entries in val:
                        file_data.insert(count+1, '<p>'+entries+'</p>\n')
                        count += 1
                    file_data.insert(count+1, '</list>\n')
        else:
            raise Exception("DN is not defined")
        return file_data
    except Exception as e:
        print("exception during add_new_list of {}, {} - {}".format(subkey, val, e))


def fetch_dn_lines(file_data, dist_name):
    line_number = 0
    dn_start_line = 0
    dn_end_line = 0
    found_dn = False
    db_string = 'distName="'+dist_name+'" version='
    for line in file_data:
        line_number += 1
        if re.search(db_string, line):
            dn_start_line = line_number
            found_dn = True
        if dn_start_line > 0 and '</managedObject>' in line and found_dn is True:
            dn_end_line = line_number
            found_dn = False
    return (dn_start_line-1, dn_end_line-1)


def modify_dn_param(file_data, search_param, search_text, replace_text, dist_name):
    try:
        modified_file = []
        dn_start_line, dn_end_line = fetch_dn_lines(file_data, dist_name)
        for line_number in range(dn_start_line, dn_end_line):
            if search_param in file_data[line_number]:
                file_data[line_number] = re.sub(search_text, replace_text, file_data[line_number])
        return file_data
    except Exception as e:
        print("exception during modify_dn_param of {} - {}".format(file_path, e))


def modify_param_value(file_data, search_param, value, dist_name=None):
    print("modify_param_value")
    search_text = 'name="' + search_param + '">' + "\\S+.*\\S*" + '<'
    replace_text = 'name="' + search_param + '">' + str(value) + '<'
    if dist_name is not None:
        return (modify_dn_param(file_data, search_param, search_text, replace_text, dist_name))
    else:
        modified_file = []
        for line in file_data:
            modified_file.append(re.sub(search_text, replace_text, line))
        return modified_file


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


def delete_DistName(file_data, key):
    start_dn, end_dn = fetch_dn_lines(file_data, key)
    del file_data[start_dn:end_dn+1]
    return file_data


def search_param(file_data, param, start_dn, end_dn):
    ret_line = -1
    for line_number in range(start_dn, end_dn):
        if param in file_data[line_number]:
            ret_line = line_number
    return ret_line


def delete_param(file_data, value, key):
    start_dn, end_dn = fetch_dn_lines(file_data, key)
    line = -1
    for subkey, val in value.items():
        if val is None:
            param_string = 'name="{}">'.format(subkey)
            line = search_param(file_data, param_string, start_dn, end_dn)
            print(line)
            if line == -1:
                print(" param - {} is not present under the DN - {}".format(subkey, key))
            else:
                file_data.pop(line)
        else:
            print("implimentation pending")
    return file_data


def remove_none(file, count):
    if 'none' in file[count]:
        file.pop(count)
    return file


def insert_listitems(file, count, value):
    print("insideeeee:list")
    line_count = count
    for val in value:
        include_str = '<p>' + val + '</p>\n'
        file.insert(line_count, include_str)
        line_count += 1
    return file


def list_include(file, search_param, value):
    print("list include")
    try:
        count = 0
        search_text = 'list name="' + search_param + '">'
        for lines in file:
            count += 1
            if re.search(search_text, lines):
                break
        file = remove_none(file, count)
        file = insert_listitems(file, count, value)
        return file
    except Exception as e:
        print("exception during list_include - {}".format(e))


def add_param(file_path, value):
    try:
        with open(file_path, "a") as f:
            f.write(value + " #MiMo")
            f.close()
    except Exception as e:
        print(file_path, e)
        print("exception during add_param - {}".format(e))


stream_delta_mapping = {
                        "fs_tdd_sansa_eCpri_cmwv_LO_AP_LO_2S_1CC_P1Perf": "delta.xml",
                        "SA20": "new_delta.xml",
                        "20UEDLCA": "3CC_delta.xml"
                        }

if __name__ == "__main__":
    file_path = sys.argv[1]
    stream = sys.argv[2]
    print("hellow world")
    modify_config_files(file_path, stream)
    if "fs_tdd_sansa_eCpri_cmwv_LO_AP_LO_2S_1CC_P1Perf" in stream or \
            "SA20" in stream or \
            "20UEDLCA" in stream and 'scfc' in file_path:
        print("Enter tc7")
        try:
            delta_file = os.path.join(os.path.dirname(os.path.realpath(__file__)), stream_delta_mapping[stream])
            print(delta_file, file_path)
            scfc_file_path = os.path.join(os.getcwd(), file_path)
            scf_generator(scfc_file_path, delta_file)
            updated_comm_file = os.path.join(os.getcwd(), "commissioning.xml")
            os.rename(updated_comm_file, scfc_file_path)
        except Exception as e:
            print(e)
