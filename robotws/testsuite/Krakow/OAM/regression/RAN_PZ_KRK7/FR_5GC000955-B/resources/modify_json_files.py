import re
import os


def modify_json_files(mrbts_value, sfp_connector, qsfp_connector, sfp2_connector):
    current_path = os.getcwd()
    json_folder_path = os.path.join(current_path, "testsuite/Krakow/OAM/regression/RAN_PZ_KRK7/"
                                                  "FR_5GC000955-B/resources/")
    json_files = [x for x in os.listdir(json_folder_path) if x.endswith("json")]
    for json_file in json_files:
        json_file_path = os.path.join(json_folder_path, json_file)

        with open(json_file_path, "r+") as f:
            source_content = f.read()
            modified_content = re.sub("(?<=MRBTS-)[0-9]+", str(mrbts_value), source_content)
            if 'SFP_object_create' in json_file_path:
                modified_content = re.sub('(?<=value":")[A-Z]_[A-Z]{2}[1-9]', sfp_connector, modified_content)
            if 'QSFP_object_create' in json_file_path:
                modified_content = re.sub('(?<=value":")[A-Z]_[A-Z]{2}[1-9]', qsfp_connector, modified_content)
            if 'SFP2_object_create' in json_file_path:
                modified_content = re.sub('(?<=value":")[A-Z]_[A-Z]{2}[1-9]', sfp2_connector, modified_content)
            f.seek(0)
            f.write(modified_content)
