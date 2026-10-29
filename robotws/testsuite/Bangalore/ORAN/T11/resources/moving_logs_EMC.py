import sys
import datetime
import glob
import os
import copy


def current_week():
    # Get Current Weeek Number
    current_time = datetime.datetime.now()
    return datetime.date(
        current_time.year, current_time.month, current_time.day
    ).isocalendar()[1]


def delete_before_1_month_logs(del_path, week):
    dirs = [d for d in os.listdir(del_path) if os.path.isdir(os.path.join(del_path, d))]
    # print("\tAll_directories:", dirs)
    dirs.sort()
    # print(dirs)
    dir_tmp = copy.deepcopy(dirs)
    length = len(dirs)
    # print("\tLength", length)
    # print("\tIndex of week:", dirs.index(week))
    cur_index = dirs.index(week)
    if length <= 4:
        return
    if cur_index + 1 == length:
        index = -1
    else:
        index = cur_index
    i = 1
    while i <= 4:
        value = dir_tmp[index]
        dirs.remove(value)
        i = i + 1
        index = index - 1

    print("\tFolders present in EMC path:", dir_tmp)
    print("\tFolders to delete:", dirs)
    # Delete before 1 month old logs
    for dir in dirs:
        path = os.path.join(del_path, dir)
        os.system("sudo rm -rf {}".format(path))
        print("\tFolder deleted:", path)


def get_setup_id(folder_path):
    setup_id = folder_path.split(r"/")[-2]
    return setup_id


def find_folder_from_EMC(new_path, EMC_path):
    if os.path.exists(EMC_path):
        print("\tEMC Path exist")
    else:
        print("\tProvided EMC path:{} is not exist".format(EMC_path))
        sys.exit()
    dirs = new_path.split("/")
    # print("\tdirs=", dirs)
    path = EMC_path
    for dir in dirs:
        path = os.path.join(path, dir)
        if not os.path.exists(path):
            os.system("sudo mkdir {}".format(path))
        else:
            continue
    return path


def copy_folder_to_EMC(src_path, des_path):
    os.system("sudo cp -r {} {}".format(src_path, des_path))


# python /home/ute/btsauto/moving_logs_EMC.py $CONFIG_FILE $Site_Config
# /home/ute/btsauto/AutoTest/$TIMESTAMP /EMC_Logs/CI_Team/FWK/

if __name__ == "__main__":
    wk = current_week()
    week = "Week_" + str(wk)
    # week = "Week_45"
    print("\tCurrent week: {}".format(week))
    folder_path = sys.argv[1]
    print("\tConfiguration file path:", folder_path)
    setup_id = get_setup_id(folder_path)
    config_path = sys.argv[2]
    config_path1 = config_path.split("/")
    # new_path=os.path.join(setup_id, config_path, week)
    new_path = os.path.join(config_path1[0], setup_id, week, config_path1[1])
    # print("\tLogs path created using configuration file:", new_path)
    EMC_path = sys.argv[4]
    path_existance = find_folder_from_EMC(new_path, EMC_path)
    print("\tLogs path in EMC:", path_existance)
    del_path = path_existance.split(path_existance.split("/")[-2])[0]
    # print("\tDelete_path=", del_path)
    delete_before_1_month_logs(del_path, week)
    Log_path = sys.argv[3]
    path_existance = path_existance + "/"
    copy_folder_to_EMC(Log_path, path_existance)
