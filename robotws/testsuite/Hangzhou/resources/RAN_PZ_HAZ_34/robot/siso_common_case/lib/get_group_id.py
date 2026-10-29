def get_unlocked_cell(cell_list, cellid):
    i = cell_list.index(cellid)
    if i == 0:
        return [cell_list[i + 1]][0]
    else:
        return [cell_list[i-1]][0]


def get_group_id(cell_info, idx):
    print(cell_info)
    empty_dict = dict()
    for key in cell_info:
        result = cell_info[key]
        for subkey in result:
            print(subkey)
            empty_dict[subkey] = key
    groupid = empty_dict["NRCELL-" + str(idx)].split('-')[1]
    return groupid


def change_time_stamp_value(time_value, timestamp):
    if time_value < 0:
        timestamp = None
    return timestamp
