import yaml
import os
import re
import sys
import pathlib
import shutil
import scf_mod as scf_mod
import xml_mod as xml_mod
import lua_mod as lua_mod
import txt_mod as txt_mod


CONFIG_YAML = "params_update.yaml"


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
                            if "scf" in each_stream:
                                if "ADD" in each_stream['scf']:
                                    scf_mod.add_data(file_path=file_path, to_add=each_stream["scf"]['ADD'])
                                if "MOD" in each_stream['scf']:
                                    scf_mod.modify_data(file_path=file_path, to_modify=each_stream["scf"]['MOD'])
                                if "DEL" in each_stream['scf']:
                                    scf_mod.delete_data(file_path=file_path, to_delete=each_stream["scf"]['DEL'])
                        if 'swconfig' in file_path.lower():
                            print(file_path.lower())
                            if "gnb_sw" in each_stream and 'gnb_swconfig' in file_path.lower():
                                print("in here")
                                print(each_stream["gnb_sw"])
                                if "ADD" in each_stream["gnb_sw"]:
                                    txt_mod.append_file(
                                        file_path=file_path,
                                        to_add=each_stream["gnb_sw"]["ADD"],
                                    )
                                if "MOD" in each_stream["gnb_sw"]:
                                    txt_mod.modify_data(
                                        file_path=file_path,
                                        to_modify=each_stream["gnb_sw"]["MOD"],
                                    )
                                if "DEL" in each_stream["gnb_sw"]:
                                    txt_mod.delete_data(
                                        file_path=file_path,
                                        to_delete=each_stream["gnb_sw"]["DEL"],
                                    )
                            if 'ap_sw' in each_stream and 'swconfig' in file_path.lower():
                                print("in here gap_Sw")
                                if "ADD" in each_stream["ap_sw"]:
                                    txt_mod.append_file(
                                        file_path=file_path,
                                        to_add=each_stream["ap_sw"]["ADD"],
                                    )
                                if "MOD" in each_stream["ap_sw"]:
                                    txt_mod.modify_data(
                                        file_path=file_path,
                                        to_modify=each_stream["ap_sw"]["MOD"],
                                    )
                                if "DEL" in each_stream["ap_sw"]:
                                    txt_mod.delete_data(
                                        file_path=file_path,
                                        to_delete=each_stream["ap_sw"]["DEL"],
                                    )
                        if 'iphy' in file_path:
                            if 'iphy' in each_stream:
                                if 'MOD' in each_stream['iphy']:
                                    xml_mod.replace_value(file_path, each_stream['iphy']['MOD'])
                                if 'DEL' in each_stream["iphy"]:
                                    xml_mod.delete_list(file_path, each_stream["iphy"]["DEL"])
                                if 'ADD' in each_stream["iphy"]:
                                    xml_mod.add_data(file_path, each_stream["iphy"]["ADD"])
                                else:
                                    raise Exception("ERROR: Unsupported option")
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


def fetch_all_folders(folder, keyword, config_type=None):
    """ Finds folders or files with a certain search keyword inside given path """
    path_list = []
    path = pathlib.Path(folder)
    for folder_path in path.rglob(keyword):
        if 'topology-configs' in str(folder_path):
            if 'CLOUD_5G_I_' in str(folder_path):
                if config_type is None:
                    path_list.append(folder_path)
                else:
                    if config_type in str(folder_path):
                        path_list.append(folder_path)
        else:
            path_list.append(folder_path)
    return path_list


if __name__ == "__main__":
    file_path = sys.argv[1]
    stream = sys.argv[2]
    file_p = file_path
    if stream in ['All']:
        file_p = fetch_all_folders(file_path, 'scfc.xml')
    elif stream in ['FDD', 'TDD']:
        file_p = fetch_all_folders(file_path, 'scfc.xml', stream)
    if isinstance(file_p, list):
        for file in file_p:
            modify_config_files(str(file), stream)
    else:
        modify_config_files(file_path, stream)
