#!/usr/bin/env python3

""" This function read test line PB info from csv file, to output a dictionary

For example, the output will be as follows:
[{'TL_NAME': '7_5_UTE5G402T661'},{'TL_NAME': '7_5_UTE5G402T681'}]
"""

import csv


def get_pb_info_from_csv(path):
    file_tl = open(path)
    reader = csv.reader(file_tl, delimiter=',')
    header = next(reader)
    data_pb = [row for row in reader]
    tl_list = []

    """ Extract each row to list"""
    for item_itr in range(len(data_pb)):
        tl_dict = {}
        for col_num in range(len(header)):
            header_name = header[col_num].strip().replace(" ", "_")
            tl_dict.update({header_name: data_pb[item_itr][col_num]})
        tl_list.append(tl_dict)
    return tl_list


def update_pb_info_to_csv(source_path, target_path, tl_list):
    file_tl = open(source_path)
    reader = csv.reader(file_tl, delimiter=',')
    header = next(reader)
    data_pb = [row for row in reader]
    new_tl_list = []

    header.append("Result")

    """ Extract each row to list"""

    for item_itr in range(len(data_pb)):
        tl_dict = tl_list[item_itr]
        result = tl_dict.get("Result")
        if result not in ["Fail", "Pass"]:
            result = "Fail"
        new_row = data_pb[item_itr]
        new_row.append(result)
        new_tl_list.append(new_row)

#    with open(target_path, 'w', newline='') as csvfile:
    with open(target_path, 'w') as csvfile:
        excel_writer = csv.writer(csvfile, dialect='excel')
        print("---new header----")
        print(header)
        try:
            excel_writer.writerow(header)
            for row in new_tl_list:
                excel_writer.writerow(row)
        except TypeError as e:
            print(e)
        csvfile.close()
    return target_path


""" Test Function """

if __name__ == "__main__":
    path = 'AutoPowerOff.csv'
    data = get_pb_info_from_csv(path)
    for entry in data:
        print(entry)
    update_pb_info_to_csv(path, data)
