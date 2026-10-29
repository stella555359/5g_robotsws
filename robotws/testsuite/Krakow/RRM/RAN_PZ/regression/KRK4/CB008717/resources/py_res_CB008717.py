import csv


def get_the_special_item_value(file_path, special_item="3gpp.slot"):
    with open(file_path, 'r') as csv_file:
        reader = list(csv.reader(csv_file))

    item_column = 0
    for item in reader[0]:
        if item == special_item:
            break
        item_column += 1

    special_item_value_list = []
    for item in reader[1:]:
        special_item_value_list.append(item[item_column])

    special_item_value_list = list(set(special_item_value_list))
    list.sort(special_item_value_list)

    return special_item_value_list
