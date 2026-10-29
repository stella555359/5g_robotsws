# usr/bin/python
# _*_ coding:utf-8 _*_
# Check BlockUeListAfterStep1
import re
import csv
import sys
import os


def Check_Slot6_7_And_Slot16_17_PDSCH_no_used_data(Ttitrace):
    with open(Ttitrace, 'r') as f1:
        reader = csv.reader(f1)
        first_row = next(reader)
        print(first_row)
        slot_index = first_row.index('slot')
        numOfPrb_index = first_row.index('dlFdSchedData.numOfPrb')
        numAllocCellPrbDl_index = first_row.index('dlTdSchedSubcellData.numAllocCellPrbDl')
        numOfPrb_Slot6_7_16_17 = []
        numAllocCellPrbDl_Slot6_7_16_17 = []
        numOfPrb_Slot5_15 = []
        numAllocCellPrbDl_Slot5_15 = []
        for row in reader:
            if (int(row[slot_index]) == 6) or (int(row[slot_index]) == 7) or (int(row[slot_index]) == 16) \
                    or (int(row[slot_index]) == 17):
                numOfPrb_Slot6_7_16_17.append(row[numOfPrb_index])
                numAllocCellPrbDl_Slot6_7_16_17.append(row[numAllocCellPrbDl_index])
            elif (int(row[slot_index]) == 5) or (int(row[slot_index]) == 15):
                numOfPrb_Slot5_15.append(row[numOfPrb_index])
                numAllocCellPrbDl_Slot5_15.append(row[numAllocCellPrbDl_index])
            else:
                continue
        null_numOfPrb_Slot6_7_16_17 = list(set(numOfPrb_Slot6_7_16_17))
        null_numAllocCellPrbDl_Slot6_7_16_17 = list(set(numAllocCellPrbDl_Slot6_7_16_17))
        data_numOfPrb_Slot5 = list(set(numOfPrb_Slot5_15))
        data_numAllocCellPrbDl_Slot5_15 = list(set(numAllocCellPrbDl_Slot5_15))
        print(null_numOfPrb_Slot6_7_16_17)
        print(null_numAllocCellPrbDl_Slot6_7_16_17)
        print(data_numOfPrb_Slot5)
        print(data_numAllocCellPrbDl_Slot5_15)
        if (len(null_numOfPrb_Slot6_7_16_17) == null_numOfPrb_Slot6_7_16_17.count('')) and \
                (len(null_numAllocCellPrbDl_Slot6_7_16_17) == null_numAllocCellPrbDl_Slot6_7_16_17.count('')):
            print('Slot6_7_and_Slot16_17_check_result is True,no data in PDSCH')
            Slot6_7_and_Slot16_17_check_result = True
        else:
            print("Slot6_7_and_Slot16_17_check_result is False,data has been scheduled in PDSCH")
            Slot6_7_and_Slot16_17_check_result = False
        if (len(data_numOfPrb_Slot5) != data_numOfPrb_Slot5.count('')) and \
                (len(data_numAllocCellPrbDl_Slot5_15) != data_numAllocCellPrbDl_Slot5_15.count('')):
            print("Slot5_and_Slot15 has data been scheduled in PDSCH")
            Slot5_and_Slot15_check_result = True
        else:
            print("Slot5_and_Slot15 no data has been scheduled in PDSCH")
            Slot5_and_Slot15_check_result = False

        if (Slot6_7_and_Slot16_17_check_result and Slot5_and_Slot15_check_result):
            print('CNI110347 check result is pass')
            return (True)
        else:
            print('CNI110347 check result is fail')
            return (False)


def Check_Slot8_9_And_Slot18_PUSCH_Used_data(Ttitrace):
    with open(Ttitrace, 'r') as f1:
        reader = csv.reader(f1)
        first_row = next(reader)
        print(first_row)
        slot_index = first_row.index('slot')
        ul_numOfPrb_index = first_row.index('ulFdSchedData.numOfPrb')
        numOfPrb_Slot8 = []
        numOfPrb_Slot9 = []
        numOfPrb_Slot18 = []
        for row in reader:
            if (int(row[slot_index]) == 8):
                numOfPrb_Slot8.append(row[ul_numOfPrb_index])
            elif (int(row[slot_index]) == 9):
                numOfPrb_Slot9.append(row[ul_numOfPrb_index])
            elif (int(row[slot_index]) == 18):
                numOfPrb_Slot18.append(row[ul_numOfPrb_index])
            else:
                continue
        data_numOfPrb_Slot8 = list(set(numOfPrb_Slot8))
        data_numOfPrb_Slot9 = list(set(numOfPrb_Slot9))
        data_numOfPrb_Slot18 = list(set(numOfPrb_Slot18))
        print(data_numOfPrb_Slot8)
        print(data_numOfPrb_Slot9)
        print(data_numOfPrb_Slot18)
        if (len(data_numOfPrb_Slot8) != data_numOfPrb_Slot8.count('')) and \
                (len(data_numOfPrb_Slot9) != data_numOfPrb_Slot9.count('')) and \
                (len(data_numOfPrb_Slot18) != data_numOfPrb_Slot18.count('')):
            print('Slot8_9_and_Slot18 has data been scheduled in PUSCH')
            return (True)
        elif (len(data_numOfPrb_Slot8) == data_numOfPrb_Slot8.count('')):
            print('Slot8 no data has been scheduled in PUSCH')
            return (False)
        elif (len(data_numOfPrb_Slot9) == data_numOfPrb_Slot9.count('')):
            print('Slot9 no data has been scheduled in PUSCH')
            return (False)
        elif (len(data_numOfPrb_Slot18) != data_numOfPrb_Slot18.count('')):
            print('Slot18 no data has been scheduled in PUSCH')
            return (False)
        else:
            print("Slot8_9_and_Slot18 no data been scheduled in PUSCH")
            return (False)
