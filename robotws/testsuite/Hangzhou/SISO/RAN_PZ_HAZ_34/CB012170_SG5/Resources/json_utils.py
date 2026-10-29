import json
import re

from collections import defaultdict


class Filter:
    def __init__(self, path, key, value):
        """
        Initialize a filter condition.

        :param path: The search path of the key, separated by '->'.
        :param key: The key of the filter condition.
        :param value: The value of the filter condition.
        """
        self.path = path
        self.key = key
        self.value = value


def custom_json_load_with_duplicates(json_file_path):
    """
    Load JSON data while preserving duplicate keys by grouping them into lists.

    :param json_file_path: Path to the JSON file.
    :return: JSON data as a nested structure with duplicate keys stored in lists.
    """

    def handle_duplicates(pairs):
        """Convert duplicate keys into lists."""
        result = defaultdict(list)
        for key, value in pairs:
            result[key].append(value)
        return {key: value[0] if len(value) == 1 else value for key, value in result.items()}

    with open(json_file_path, 'r', encoding='utf-8') as f:
        return json.load(f, object_pairs_hook=handle_duplicates)


def get_values_from_json(json_file_path, key_path, filters=None):
    """
    Retrieve all values corresponding to a specific key path from a JSON file, optionally filtering the results.

    :param json_file_path: Path to the JSON file.
    :param key_path: The search path of the key, separated by '->'.
    :param filters: A list of filter conditions, each represented by a Filter object.
    :return: A list of all matching values.
    """
    data = custom_json_load_with_duplicates(json_file_path)

    # Convert key_path into a list
    keys = key_path.split('->')

    def recursive_search(json_data, path_keys):
        """Recursively search the JSON data for the specified path."""
        if not path_keys:
            return [json_data]

        current_key = path_keys[0]
        results = []

        if isinstance(json_data, list):
            for item in json_data:
                results.extend(recursive_search(item, path_keys))
        elif isinstance(json_data, dict):
            if current_key in json_data:
                if isinstance(json_data[current_key], list):
                    for item in json_data[current_key]:
                        results.extend(recursive_search(item, path_keys[1:]))
                else:
                    results.extend(recursive_search(json_data[current_key], path_keys[1:]))

        return results

    def apply_filters(results, filters):
        """Apply multiple filter conditions to the results."""
        if not filters:
            return results

        filtered_results = []
        for item in results:
            if isinstance(item, dict):
                match = True
                for filter_obj in filters:
                    filter_path_keys = filter_obj.path.split('->')
                    current_data = item
                    for key in filter_path_keys:
                        if isinstance(current_data, dict) and key in current_data:
                            current_data = current_data[key]
                        else:
                            match = False
                            break
                    if not match or current_data.get(filter_obj.key) != filter_obj.value:
                        match = False
                        break

                if match:
                    filtered_results.append(item)

        return filtered_results

    # First, apply filters to the messages
    filtered_data = apply_filters(data, filters)

    # print(filtered_data)

    # Convert key_path into a list
    keys = key_path.split('->')

    # Then, search for the key path in the filtered messages
    all_results = []
    for message in filtered_data:
        all_results.extend(recursive_search(message, keys))

    return all_results


def process_list(input_list):
    """
    Sort the first 8 elements of a list in ascending order, remove zero values, and return the result.

    :param input_list: The list to be processed.
    :return: A sorted list of the first 8 non-zero elements.
    """
    return sorted(filter(lambda x: x != "0", input_list[:8]))


def get_pattern_id_from_ssblocksendreq(file_name, sub_cell="0"):
    print("get_pattern_id_from_ssblocksendreq: subcellid={}".format(sub_cell))
    filter_conditions = [Filter("_source->layers->icom_5g->nr_l1dl_l2ps->dldata_ssblocksendreq->"
                                "nr_l1dl_l2ps_dldata_ssblocksendreq_t", "3gpp.subcellid", sub_cell)]
    patternIds = JsonUtils.find_values_in_json(
        json_file_path=file_name,
        key_path="_source->layers->icom_5g->nr_l1dl_l2ps->dldata_ssblocksendreq->"
                 "nr_l1dl_l2ps_dldata_ssblocksendreq_t"
                 "->patternId (StaticFixedSizedArray)->DlData_SsBlockSendReq_t.patternId_item",
        filters=filter_conditions)

    return process_list(patternIds)


def get_pattern_id_from_csirssendreq(file_name, sub_cell="0"):
    print("get_pattern_id_from_csirssendreq: subcellid={}".format(sub_cell))
    filter_conditions = [Filter("_source->layers->icom_5g->nr_l1dl_l2ps->dldata_csirssendreq->"
                                "nr_l1dl_l2ps_dldata_csirssendreq_t", "3gpp.subcellid", sub_cell)]
    patternIds = JsonUtils.find_values_in_json(
        json_file_path=file_name,
        key_path="_source->layers->icom_5g->nr_l1dl_l2ps->dldata_csirssendreq->"
                 "nr_l1dl_l2ps_dldata_csirssendreq_t->csiRsResources (DynamicVariableSizedArray)"
                 "->nr_l1dl_l2ps_dldata_csirsresource_t"
                 "->patternId (StaticFixedSizedArray)->DlData_CsiRsResource_t.patternId_item",
        filters=filter_conditions)

    return sorted(set(filter(lambda x: int(x) > 1, patternIds)))[:4]


def replace_l1sw_in_file(file_name):
    """
    Replace all occurrences of 'l1sw' in a file with an empty string, ignoring case.

    :param file_name: Path to the file.
    """
    with open(file_name, 'r', encoding='utf-8') as file:
        content = file.read()

    content = re.sub(r'(?i)l1sw', '', content)

    with open(file_name, 'w', encoding='utf-8') as file:
        file.write(content)


def change_format_for_utr_time(utc_time):
    # 2024-12-27 22:43:43.296-->2024_12_27_22_43_43_296
    return utc_time.replace(" ", "_").replace(":", "_").replace("-", "_").replace(".", "_")


class JsonUtils:
    @staticmethod
    def find_values_in_json(json_file_path, key_path, filters=None):
        """
        Robot Framework keyword: Retrieve all values corresponding to a specific key path from a JSON file,
        optionally filtering the messages first.

        :param json_file_path: Path to the JSON file.
        :param key_path: The search path of the key, separated by '->'.
        :param filters: A list of filter conditions, each represented by a Filter object.
        :return: A list of all matching values.
        """
        return get_values_from_json(json_file_path, key_path, filters)


if __name__ == '__main__':
    patternIds = get_pattern_id_from_ssblocksendreq("test.json")
    print(patternIds)

    patternIds = get_pattern_id_from_csirssendreq("test.json")
    print(patternIds)
