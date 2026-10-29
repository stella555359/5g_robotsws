import re
import warnings


def check_9920_activation(nr_cell_id: int, *lnrelgnbcells: dict) -> bool:
    wanted_status = False
    for cell in lnrelgnbcells:
        if str(cell['parameters']['nrCellId']) == str(nr_cell_id):
            if cell['parameters']['nrStatus'] == 'unavailable' and cell['parameters']['pwSavingDeactInd']:
                wanted_status = True
            else:
                wanted_status = False
    return wanted_status


def get_lte_cell_list(cells_id: list) -> list:
    return ['LNCEL-' + elem for elem in cells_id]


def get_counter_for_all_lte_cells(higher_r: bool, lte_bts_id: str, data: dict, counter: str, lte_cells: list) -> dict:
    result = {}

    if higher_r:
        items = data['BTS'][f"MRBTS-{lte_bts_id}"][f"LNBTS-{lte_bts_id}"].items()
    else:
        items = data['BTS']['CELLS'].items()

    for key, value in items:
        if key in lte_cells:
            if higher_r:
                inner_dict = value['MCC-310']['MNC-260']['LTE_X2_gNB_per_LNCEL'][counter]
            else:
                inner_dict = value['MCC-310_MNC-260']['LTE_X2_gNB_per_LNCEL'][counter]
            last_key = list(inner_dict.keys())[-1]
            last_value = inner_dict[last_key]
            result[key] = {last_key: last_value}

    return result


def return_counter_sum_value_from_all_lte_cells(last_counter_value: dict) -> int:
    print(last_counter_value.values())
    return sum([sum(value.values()) for value in last_counter_value.values()])


def check_where_ue_should_be_attached(nr_cell_id: int, *data: list) -> list:
    cells_to_attenuate = []

    # TODO: move hardcoded ports to robot variable and give it as argument
    cells_lte = {
        "LNCEL_40044": [13, 14],
        "LNCEL_40045": [15, 16]
    }
    for i in data:
        if str(i['parameters']['nrCellId']) == str(nr_cell_id):
            lncel = i['distName'].split("/")[-2]
            lncel = re.sub(r'LNCEL_A-', 'LNCEL_', lncel)
            if i['parameters']['nrStatus'] == 'unavailable' and i['parameters']['pwSavingDeactInd']:
                cells_to_attenuate.extend(cells_lte[lncel])
        if len(cells_to_attenuate) == 4:
            warnings.warn("Test Case can fails due to improper params values on all LTE cells", Warning)
    return sorted(cells_to_attenuate)


def verify_lnrelgnbcell(cell_id: str, expected_value: bool, *data: dict) -> bool:
    matched_objects_counter = 0

    for lnrelgnbcell in data:
        data_cell_id = lnrelgnbcell["parameters"]["nrCellId"]
        data_param_value = lnrelgnbcell["parameters"]["pwSavingDeactInd"]

        if data_cell_id == cell_id:
            matched_objects_counter += 1
            if data_param_value != expected_value:
                return False  # value is not ok so return false
        else:
            if data_param_value != (not expected_value):
                return False  # value is not ok so return false

    return matched_objects_counter > 0  # check if objects for given cell exist


def verify_lnrelgnbcell_removal(cell_id: str, *data: dict) -> bool:
    for lnrelgnbcell in data:
        if lnrelgnbcell["parameters"]["nrCellId"] == cell_id:
            return False  # there should be no such object

    return True
