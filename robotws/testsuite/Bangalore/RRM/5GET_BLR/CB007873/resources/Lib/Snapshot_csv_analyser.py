import os
import shutil
import zipfile
import os
import subprocess
import openpyxl
import csv
import time
import re
import requests


def L2HiTraces():

    path = "/home/ute/Downloads/"  # Path where snapshot.zip file is present
    file_list = []
    file_name_to_find = "L2TraceHi_DU.dat.xz"  # File name which needs to be extracted from snapshot
    Extracted_path = path + "Extracted_Snapshot/"

    for r, d, f in os.walk(path):
        for file in f:
            if ("napshot") in file:
                f = zipfile.ZipFile(path + file, 'r')
                f.extractall(Extracted_path)
                print("Snapshot files extracted to path : " + Extracted_path)

    for r, d, f in os.walk(Extracted_path):
        for filename in f:
            if "snapshot_file_list.txt" in filename:
                logTxt = open(os.path.join(r, filename), 'r')
                content = logTxt.readlines()
                logTxt.close()

    for line in content:
        if ":" in line:
            temp = line.strip(":")
        if file_name_to_find in line:
            print(line.strip("\n") + " is present in " + temp.strip("\n"))
            file_list.append(Extracted_path + temp.strip("\n").strip(":"))

    if not file_list:
        print("No matching files found in snapshot.zip")
        exit(0)

    for Extract_file in file_list:
        f = zipfile.ZipFile(Extract_file)
        for file in f.namelist():
            if file_name_to_find in file:
                f.extract(file, path)
                subprocess.call = (["unxz", path+file])
                print(file + " extracted to path " + path)
        f.close()
    shutil.rmtree(Extracted_path)

    download_path = "/home/ute/Downloads/dat/"
    for r, d, f in os.walk(download_path):
        for file in f:
            if "luashark.zip" in file:
                build_name = file.split("_luashark.zip")
    os.chdir(download_path)

    for r, d, f in os.walk(path):
        for file in f:
            if ".dat" in file:
                print("./L2TraceDecodeToCSV.py", build_name[0], path + file)
                subprocess.call(["./L2TraceDecodeToCSV.py", build_name[0], path + file])

    # 21 coulmn
    # itf_L2Log_Du_Hi_Events_Tx_DuFlowControlData_t_sorted.csv
    Source_load = download_path+"itf_L2Log_Du_Hi_Events_Tx_DuFlowControlData_t_sorted.xlsx"
    # read_file = pd.read_csv(download_path+"itf_L2Log_Du_Hi_Eventsl_Tx_DuFlowControlData_t_sorted.csv")
    # read_file.to_excel(Source_load)
    with open(download_path+"itf_L2Log_Du_Hi_Eventsl_Tx_DuFlowControlData_t_sorted.csv") as f:
        reader = csv.reader(f, delimiter=':')
        for row in reader:
            ws.append(row)
    wb.save(Source_load)
    wb = openpyxl.load_workbook(Source_load)
    # print(wb.sheetnames)
    src_sheet = wb.get_sheet_by_name('Sheet1')
    lists = []

    for i in range(1, 1500):
        if not src_sheet.cell(row=i, column=21).value == 0:
            lists.append(src_sheet.cell(i, 21).value)
    # print(lists)
    if len(lists) > 1:
        return "PASS"
    return "FAIL"


if __name__ == "__main__":
    result = L2HiTraces()
    print(result)
