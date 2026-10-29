import glob
import csv


def check_pingpong_triggered(csv_filename, column_name):
    # 获取所有要读取的csv文件名
    all_files = glob.glob(csv_filename)
    # 创建一个空的列表来存储读取到的数据
    column_list = []
    # 遍历所有csv文件
    for filename in all_files:
        # 读取csv文件
        with open(filename, 'r') as file:
            reader = csv.DictReader(file)
            column_values = [row[column_name] for row in reader]
            column_list.append(column_values)
    print(column_list)
    first_value = []
    if all(not sublist for sublist in column_list):
        print("log check failed! No event triggered.")
        raise Exception('Fail')
    else:
        for sublists in column_list:
            # 判断sublists是否为空
            if sublists:
                first_value.append(sublists[0])
                for sublist in sublists:
                    # 判断sublist是否包含58
                    if '58' in sublist:
                        print("Case pass! eventNb contain 58.")
                    else:
                        print("log check failed!")
                        raise Exception('Fail')


# check_pingpong_triggered('pingpong_switch*.csv','l1_common_FastAntennaSnapshotEventsList_t.eventNb')
