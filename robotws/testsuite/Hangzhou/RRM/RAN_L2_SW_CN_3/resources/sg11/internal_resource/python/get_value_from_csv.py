import csv
import sys
import os


def get_value_from_cellSetup(file):
    with open(file, 'r') as infile:
        csv_reader = csv.DictReader(infile)
        for item in csv_reader:
            ulTaperingFlag = item["itf_UlMuMimoConfig.actUlMuMimoTapering"]
            patternidStart = item["itf_l2_ps_cell_DftBeamSet.dftBeamStartPatternId_item"]
            item_sp = patternidStart.split(',')
            ulStartPatternidDft = item_sp[0]
            ulStartPatternidTapered = item_sp[1]
        return ulStartPatternidDft, ulStartPatternidTapered


def get_single_value_from_csv(file, param):
    with open(file, 'r') as infile:
        csv_reader = csv.DictReader(infile)
        for item in csv_reader:
            field = item[param]
        return field


# if __name__ == "__main__":
#     get_value_from_cellSetup("/home/ute/log/cellSetup.csv")
