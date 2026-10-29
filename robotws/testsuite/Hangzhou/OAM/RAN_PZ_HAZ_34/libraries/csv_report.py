import os
import csv


def list_convert(list_origin, list_number):
    list2 = []
    addition_number = 0
    if len(list_origin) <= list_number:
        list2 = list_origin
    else:
        while addition_number < len(list_origin):
            addition_number2 = addition_number + list_number
            list1 = list_origin[addition_number:addition_number2]
            addition_number += list_number
            list2.append(list1)
    return list2


def create_report(result_dir, list_origin, table_list, list_number):
    # Create CSV Report and write the value to the CSV
    # table_list : a list, the table title,
    # result_dir,a str,where the csv created in
    # list_origin, a list to write in csv
    # list_number,the list number in csv
    new_list = list_convert(list_origin, list_number)
    file_path = os.path.join(result_dir, 'report.csv')  # Default File Path

    with open(file_path, 'wb') as csvfile:
        spamwriter = csv.writer(csvfile, dialect='excel')
        spamwriter.writerow(table_list)
        for row in new_list:
            spamwriter.writerow(row)
    csvfile.close()
    return file_path
