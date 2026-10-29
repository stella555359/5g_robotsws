import csv
import os


def getsubcellid(csv_filename, cellid):
    subcellid = 0
    with open(csv_filename, 'r') as csvfile:
        reader = csv.DictReader(csvfile)
        list_reader = list(reader)
        for i_line in list_reader:
            if int(i_line["physCellId"]) == int(cellid) and i_line["csiRsSchedData.subcellId"] != '':
                subcellid = int(float(i_line["csiRsSchedData.subcellId"]))
                print("get subcellid successed!", "physCellId:", cellid, "subcellId:", subcellid)
                return subcellid
    if subcellid == 0:
        print("get subcellid failed!")
