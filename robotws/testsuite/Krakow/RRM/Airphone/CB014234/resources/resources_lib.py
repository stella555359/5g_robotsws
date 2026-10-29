import json
from typing import Any, Dict


def find_root_information_element(data: Any, info_element: str):
    """
    This function looks recursively inside the json data for the configRestrictInfo structure

    """
    if isinstance(data, dict):
        for k, v in data.items():
            if k == info_element:
                return v
            found = find_root_information_element(data=v, info_element=info_element)
            if found is not None:
                return found
    elif isinstance(data, list):
        for element in data:
            found = find_root_information_element(data=element, info_element=info_element)
            if found is not None:
                return found
    else:
        return None


def validate_config_restrict_info(config_restrict_info: Dict, expected_cri: Dict[str, Any]) -> Dict[str, bool]:
    """" """

    results: Dict[str, bool] = {}
    actual_bc = config_restrict_info.get("nr-rrc.allowedBC_ListMRDC")
    results["allowedBC_ListMRDC"] = (actual_bc == expected_cri["allowedBC_ListMRDC"])
    allowed_bc_list_tree = config_restrict_info.get("nr-rrc.allowedBC_ListMRDC_tree", {})
    expected_bcs = expected_cri.get("bandCombinations", [])
    if len(allowed_bc_list_tree) != len(expected_bcs):
        results["bandCombinations"] = False
    else:
        all_ok = True
        for (item_key, bc_container), exp in zip(sorted(allowed_bc_list_tree.items()), expected_bcs):
            bc_info = bc_container.get("nr-rrc.BandCombinationInfo_element", {})
            if bc_info.get("nr-rrc.bandCombinationIndex") != exp["nr-rrc.bandCombinationIndex"]:
                all_ok = False
            if bc_info.get("nr-rrc.allowedFeatureSetsList") != exp["nr-rrc.allowedFeatureSetsList"]:
                all_ok = False
            fs_tree = bc_info.get("nr-rrc.allowedFeatureSetsList_tree", {})
            actual_indices = [fs_count.get("nr-rrc.FeatureSetEntryIndex") for _, fs_count in sorted(fs_tree.items())]
            if actual_indices != exp.get("FeatureSetEntryIndices", []):
                all_ok = False
        results["bandCombinations"] = all_ok
    serv_range = config_restrict_info.get("nr-rrc.servCellIndexRangeSCG_element", {})
    exp_range = expected_cri.get("servCellIndexRangeSCG_element", {})
    low_ok = (serv_range.get("nr-rrc.lowBound") == exp_range.get("nr-rrc.lowBound"))
    up_ok = (serv_range.get("nr-rrc.upBound") == exp_range.get("nr-rrc.upBound"))
    results["servCellIndexRangeSCG_element"] = (low_ok and up_ok)
    return results


def verify_the_config_restrict_info_structure_match_expected_values(json_file_path, expected_cfg):
    with open(json_file_path) as f:
        data = json.load(f)
    cfg = find_root_information_element(data, info_element="nr-rrc.configRestrictInfo_element")
    if cfg is None:
        raise ValueError("no-rrc.configRestrictInfo_element found")
    results = validate_config_restrict_info(cfg, expected_cfg)
    for k, v in results.items():
        if v is False:
            raise ValueError(f"One of IE inside configRestrictInfo_element does not match expected values. "
                             f"The field {k} does not match expected")


def generate_specific_number_of_bc_indexes_and_fsei(max_num_iteractions: str, even_bc: str, odd_bc: str):
    bc_indexes_fsei = []
    for n in range(1, int(max_num_iteractions)):
        if n % 2:
            bc_indexes_fsei.append(even_bc)
        else:
            bc_indexes_fsei.append(odd_bc)
    return bc_indexes_fsei


def verify_if_ScellToAddModList_is_present_or_not(json_file, should_be_present, rrc_reconfig):
    try:
        with open(json_file, 'r', encoding='utf-8') as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"Error: File not found: {json_file}")
        data = {}
    except json.JSONDecodeError as e:
        print(f"Error parsing JSON: {e}")
        data = {}
    cell_group = find_root_information_element(data=data, info_element="nr-rrc.CellGroupConfig_element")
    should_be_present = should_be_present.strip().lower()
    rrc_reconfig = rrc_reconfig.strip().lower()
    if should_be_present == "yes":
        assert isinstance(cell_group, dict), "Expected a dict in cell_group"
        assert "nr-rrc.sCellToAddModList" in cell_group, (
            "Key nr-rrc.sCellToAddModList must be present"
        )
    elif should_be_present == "no" and rrc_reconfig == "no":
        assert cell_group is None, "Expected cell_group None"
    elif should_be_present == "no" and rrc_reconfig == "yes":
        assert "nr-rrc.sCellToAddModList" not in cell_group, (
            "nr-rrc.sCellToAddModList must not be present"
        )
