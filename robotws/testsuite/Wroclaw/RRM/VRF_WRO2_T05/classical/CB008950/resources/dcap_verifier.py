def find_scell_phycellid_id_value(data) -> list:
    cell_list = _extract_scell_phys_cell_ids(data)
    return cell_list


def _get_last_configurred_scell_id(cell_list):
    if cell_list:
        return cell_list[-1]
    return None


def _extract_scell_phys_cell_ids(json_data):
    if not isinstance(json_data, dict):
        raise TypeError("Input data must be a dictionary")

    phys_cell_ids = []

    def recursive_extract(json_data):
        if isinstance(json_data, dict):
            if 'sCellToAddModList' in json_data:
                if isinstance(json_data['sCellToAddModList'], list):
                    for json_item in json_data['sCellToAddModList']:
                        if 'sCellConfigCommon' in json_item:
                            phys_cell_ids.append(json_item['sCellConfigCommon']['physCellId'])
                        recursive_extract(json_item)
                elif isinstance(json_data['sCellToAddModList'], dict):
                    recursive_extract(json_data['sCellToAddModList'])
            else:
                for value in json_data.values():
                    recursive_extract(value)
        elif isinstance(json_data, list):
            for json_item in json_data:
                recursive_extract(json_item)

    try:
        recursive_extract(json_data)
    except Exception as e:
        raise ValueError("Invalid input data") from e

    return phys_cell_ids


def extract_values(data, parent_key, child_key):
    values = []

    def recursive_extract(data):
        if isinstance(data, dict):
            if parent_key in data:
                if child_key in data[parent_key]:
                    values.append(data[parent_key][child_key])
                recursive_extract(data[parent_key])
            else:
                for value in data.values():
                    recursive_extract(value)
        elif isinstance(data, list):
            for item in data:
                recursive_extract(item)

    recursive_extract(data)
    return values
