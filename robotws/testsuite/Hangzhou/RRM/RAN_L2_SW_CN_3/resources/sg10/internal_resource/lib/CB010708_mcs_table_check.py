import csv
import os

# 5G_UP_ALG_20212
mcs_table_ptrson_data_64QAM_Rank1 = {
    '2': {0: 2.0, 1: 2.5, 2: 3.0, 3: 3.5, 4: 4.0, 5: 4.5, 6: 5.0, 7: 5.6, 8: 6.2, 9: 6.8, 10: 7.4,
          11: 8.0, 12: 8.6, 13: 9.3, 14: 10.1, 15: 11.0, 16: 12.2, 17: 12.2, 18: 12.9, 19: 13.8, 20: 14.8,
          21: 15.9, 22: 16.8, 23: 17.9, 24: 18.9, 25: 20.0, 26: 21.1, 27: 22.6, 28: 28.0},
    '3': {0: 0.9, 1: 1.4, 2: 1.9, 3: 2.5, 4: 3.1, 5: 3.7, 6: 4.4, 7: 5.1, 8: 5.9, 9: 6.5, 10: 7.1,
          11: 7.7, 12: 8.3, 13: 9.0, 14: 9.9, 15: 10.9, 16: 11.6, 17: 12.2, 18: 12.8, 19: 13.6, 20: 14.5,
          21: 15.8, 22: 16.7, 23: 17.6, 24: 18.7, 25: 20.0, 26: 21.1, 27: 22.2, 28: 26.0},
    '4': {0: -0.1, 1: 0.4, 2: 0.9, 3: 1.5, 4: 2.2, 5: 2.9, 6: 3.6, 7: 4.4, 8: 5.2, 9: 5.8, 10: 6.4,
          11: 7.0, 12: 7.6, 13: 8.4, 14: 9.4, 15: 10.4, 16: 11.1, 17: 11.7, 18: 12.3, 19: 13.1, 20: 14.4,
          21: 15.2, 22: 16.3, 23: 17.2, 24: 18.3, 25: 19.3, 26: 20.7, 27: 21.7, 28: 26.0},
    '8': {0: -0.8, 1: -0.3, 2: 0.3, 3: 1.0, 4: 1.7, 5: 2.5, 6: 3.3, 7: 4.1, 8: 4.8, 9: 5.5, 10: 6.1,
          11: 6.7, 12: 7.3, 13: 8.0, 14: 8.9, 15: 9.8, 16: 10.6, 17: 11.3, 18: 12.0, 19: 12.8, 20: 13.6,
          21: 14.5, 22: 15.4, 23: 16.6, 24: 17.5, 25: 18.7, 26: 19.8, 27: 21.5, 28: 24.7},
    '16': {0: -1.3, 1: -0.7, 2: -0.1, 3: 0.6, 4: 1.3, 5: 2.1, 6: 2.9, 7: 3.6, 8: 4.4, 9: 5.1, 10: 5.7,
           11: 6.3, 12: 7.0, 13: 7.8, 14: 8.6, 15: 9.6, 16: 10.2, 17: 10.9, 18: 11.6, 19: 12.5, 20: 13.4,
           21: 14.3, 22: 15.2, 23: 16.5, 24: 17.5, 25: 18.7, 26: 19.8, 27: 21.5, 28: 24.6},
    '32': {0: -1.6, 1: -1.0, 2: -0.3, 3: 0.4, 4: 1.1, 5: 1.8, 6: 2.6, 7: 3.4, 8: 4.2, 9: 4.9, 10: 5.5,
           11: 6.1, 12: 6.9, 13: 7.7, 14: 8.6, 15: 9.5, 16: 10.1, 17: 10.7, 18: 11.4, 19: 12.4, 20: 13.2,
           21: 14.1, 22: 15.0, 23: 16.1, 24: 17.2, 25: 18.4, 26: 19.4, 27: 20.7, 28: 22.4},
    '64': {0: -1.7, 1: -1.1, 2: -0.4, 3: 0.3, 4: 1.0, 5: 1.7, 6: 2.5, 7: 3.4, 8: 4.2, 9: 4.9, 10: 5.5,
           11: 6.1, 12: 6.8, 13: 7.7, 14: 8.6, 15: 9.5, 16: 10.1, 17: 10.7, 18: 11.4, 19: 12.4, 20: 13.2,
           21: 14.1, 22: 15.0, 23: 16.1, 24: 17.2, 25: 18.4, 26: 19.4, 27: 20.5, 28: 22.2},
    '273': {0: -1.8, 1: -1.2, 2: -0.5, 3: 0.2, 4: 0.9, 5: 1.7, 6: 2.5, 7: 3.2, 8: 4.0, 9: 4.8, 10: 5.4,
            11: 6.0, 12: 6.8, 13: 7.7, 14: 8.5, 15: 9.4, 16: 10.0, 17: 10.7, 18: 11.4, 19: 12.2, 20: 13.2,
            21: 14.0, 22: 14.9, 23: 16.1, 24: 17.2, 25: 18.3, 26: 19.3, 27: 20.3, 28: 22.0},
}
# 5G_UP_ALG_20210
mcs_table_ptrsoff_data_64QAM_rank1 = {
    '2': {0: 0.5, 1: 0.9, 2: 1.3, 3: 1.9, 4: 2.5, 5: 3.1, 6: 3.7, 7: 4.4, 8: 5.1, 9: 5.7, 10: 6.3,
          11: 6.9, 12: 7.5, 13: 8.2, 14: 9.0, 15: 9.8, 16: 10.6, 17: 11.3, 18: 12.0, 19: 12.7, 20: 13.6,
          21: 14.6, 22: 15.7, 23: 16.6, 24: 17.8, 25: 18.7, 26: 19.6, 27: 20.6, 28: 22.2},
    '3': {0: -0.6, 1: -0.1, 2: 0.5, 3: 1.2, 4: 1.9, 5: 2.6, 6: 3.3, 7: 4.0, 8: 4.7, 9: 5.3, 10: 5.9,
          11: 6.5, 12: 7.2, 13: 7.9, 14: 8.8, 15: 9.7, 16: 10.4, 17: 11.1, 18: 11.8, 19: 12.5, 20: 13.3,
          21: 14.3, 22: 15.2, 23: 16.3, 24: 17.4, 25: 18.4, 26: 19.4, 27: 20.4, 28: 21.8},
    '4': {0: -1.5, 1: -0.9, 2: -0.3, 3: 0.4, 4: 1.1, 5: 1.9, 6: 2.7, 7: 3.5, 8: 4.1, 9: 4.7, 10: 5.3,
          11: 5.9, 12: 6.6, 13: 7.4, 14: 8.3, 15: 9.2, 16: 10.0, 17: 10.7, 18: 11.4, 19: 12.2, 20: 13.0,
          21: 13.9, 22: 15.0, 23: 16.0, 24: 16.9, 25: 18.2, 26: 19.0, 27: 20.1, 28: 21.5},
    '8': {0: -2.1, 1: -1.5, 2: -0.8, 3: 0.0, 4: 0.7, 5: 1.4, 6: 2.1, 7: 2.8, 8: 3.5, 9: 4.3,
          10: 5.0, 11: 5.7, 12: 6.4, 13: 7.2, 14: 8.1, 15: 9.1, 16: 9.8, 17: 10.5, 18: 11.2,
          19: 11.9, 20: 12.8, 21: 13.6, 22: 14.4, 23: 15.3, 24: 16.4, 25: 17.4, 26: 18.3, 27: 19.5, 28: 21.0},
    '16': {0: -2.5, 1: -1.8, 2: -1.1, 3: -0.3, 4: 0.4, 5: 1.2, 6: 2.0, 7: 2.7, 8: 3.4, 9: 4.1,
           10: 4.8, 11: 5.5, 12: 6.3, 13: 7.1, 14: 7.9, 15: 8.8, 16: 9.5, 17: 10.2, 18: 10.9,
           19: 11.7, 20: 12.7, 21: 13.5, 22: 14.4, 23: 15.3, 24: 16.4, 25: 17.4, 26: 18.3, 27: 19.4, 28: 21.0},
    '32': {0: -2.6, 1: -1.9, 2: -1.2, 3: -0.4, 4: 0.4, 5: 1.1, 6: 1.8, 7: 2.5, 8: 3.3, 9: 4.0,
           10: 4.7, 11: 5.4, 12: 6.1, 13: 6.9, 14: 7.9, 15: 8.7, 16: 9.4, 17: 10.1, 18: 10.8,
           19: 11.7, 20: 12.6, 21: 13.4, 22: 14.2, 23: 15.3, 24: 16.4, 25: 17.4, 26: 18.3, 27: 19.3, 28: 21.0},
    '64': {0: -2.8, 1: -2.1, 2: -1.3, 3: -0.5, 4: 0.2, 5: 1.0, 6: 1.8, 7: 2.5, 8: 3.2, 9: 4.0,
           10: 4.7, 11: 5.4, 12: 6.1, 13: 6.9, 14: 7.9, 15: 8.7, 16: 9.4, 17: 10.1, 18: 10.8,
           19: 11.6, 20: 12.5, 21: 13.3, 22: 14.2, 23: 15.3, 24: 16.4, 25: 17.4, 26: 18.3, 27: 19.3, 28: 20.9},
    '273': {0: -2.8, 1: -2.1, 2: -1.3, 3: -0.5, 4: 0.2, 5: 1.0, 6: 1.8, 7: 2.5, 8: 3.2, 9: 4.0,
            10: 4.7, 11: 5.4, 12: 6.1, 13: 6.9, 14: 7.9, 15: 8.7, 16: 9.4, 17: 10.1, 18: 10.8,
            19: 11.6, 20: 12.5, 21: 13.3, 22: 14.2, 23: 15.3, 24: 16.4, 25: 17.4, 26: 18.3, 27: 19.3, 28: 20.5},
}
mcs_table_ptrson_data_64QAM_Rank2 = {
    '2': {0: 2.1, 1: 2.5, 2: 3.0, 3: 3.5, 4: 4.1, 5: 4.7, 6: 5.3, 7: 6.0, 8: 6.7, 9: 7.3, 10: 7.9,
          11: 8.6, 12: 9.3, 13: 10.1, 14: 11.0, 15: 11.8, 16: 12.4, 17: 13.0, 18: 13.6, 19: 14.4, 20: 15.4,
          21: 16.4, 22: 17.4, 23: 18.4, 24: 19.4, 25: 20.4, 26: 21.7, 27: 22.8, 28: 28.0},
    '3': {0: 1.1, 1: 1.6, 2: 2.2, 3: 2.8, 4: 3.5, 5: 4.2, 6: 4.8, 7: 5.4, 8: 6.1, 9: 6.9, 10: 7.5,
          11: 8.1, 12: 8.8, 13: 9.6, 14: 10.6, 15: 11.5, 16: 12.2, 17: 12.8, 18: 13.4, 19: 14.1, 20: 15.0,
          21: 16.0, 22: 17.1, 23: 18.1, 24: 19.3, 25: 20.3, 26: 21.3, 27: 22.7, 28: 26.5},
    '4': {0: -0.2, 1: 0.4, 2: 1.0, 3: 1.7, 4: 2.4, 5: 3.3, 6: 3.9, 7: 4.6, 8: 5.3, 9: 6.0, 10: 6.6,
          11: 7.2, 12: 7.8, 13: 8.5, 14: 9.4, 15: 10.3, 16: 11.2, 17: 11.9, 18: 12.6, 19: 13.5, 20: 14.4,
          21: 15.4, 22: 16.4, 23: 17.5, 24: 18.5, 25: 19.7, 26: 20.7, 27: 22.0, 28: 26.1},
    '8': {0: -0.8, 1: -0.3, 2: 0.3, 3: 1.0, 4: 1.8, 5: 2.6, 6: 3.3, 7: 4.0, 8: 4.8, 9: 5.5, 10: 6.1,
          11: 6.7, 12: 7.4, 13: 8.1, 14: 9.0, 15: 9.9, 16: 10.6, 17: 11.2, 18: 11.9, 19: 12.8, 20: 13.8,
          21: 14.7, 22: 15.7, 23: 16.8, 24: 17.8, 25: 19.0, 26: 20.2, 27: 22.0, 28: 25.1},
    '16': {0: -1.3, 1: -0.7, 2: -0.1, 3: 0.7, 4: 1.4, 5: 2.2, 6: 3.1, 7: 3.8, 8: 4.6, 9: 5.3, 10: 5.9,
           11: 6.5, 12: 7.2, 13: 7.9, 14: 8.9, 15: 9.8, 16: 10.5, 17: 11.2, 18: 11.9, 19: 12.8, 20: 13.7,
           21: 14.6, 22: 15.5, 23: 16.7, 24: 17.7, 25: 18.9, 26: 20.2, 27: 21.5, 28: 24.5},
    '32': {0: -1.5, 1: -0.9, 2: -0.4, 3: 0.5, 4: 1.2, 5: 2.0, 6: 2.7, 7: 3.7, 8: 4.5, 9: 5.2, 10: 5.8,
           11: 6.4, 12: 7.1, 13: 7.8, 14: 8.7, 15: 9.6, 16: 10.3, 17: 10.9, 18: 11.6, 19: 12.5, 20: 13.5,
           21: 14.4, 22: 15.3, 23: 16.4, 24: 17.5, 25: 18.6, 26: 19.9, 27: 21.0, 28: 23.0},
    '64': {0: -1.6, 1: -1.0, 2: -0.4, 3: 0.4, 4: 1.1, 5: 1.9, 6: 2.7, 7: 3.6, 8: 4.4, 9: 5.1, 10: 5.7,
           11: 6.3, 12: 7.0, 13: 7.8, 14: 8.7, 15: 9.6, 16: 10.3, 17: 10.9, 18: 11.6, 19: 12.5, 20: 13.5,
           21: 14.4, 22: 15.3, 23: 16.4, 24: 17.5, 25: 18.6, 26: 19.9, 27: 21.0, 28: 22.7},
    '273': {0: -1.6, 1: -1.0, 2: -0.4, 3: 0.4, 4: 1.1, 5: 1.9, 6: 2.7, 7: 3.6, 8: 4.4, 9: 5.1, 10: 5.7,
            11: 6.3, 12: 7.0, 13: 7.8, 14: 8.7, 15: 9.5, 16: 10.2, 17: 10.9, 18: 11.6, 19: 12.4, 20: 13.4,
            21: 14.4, 22: 15.3, 23: 16.4, 24: 17.5, 25: 18.5, 26: 19.8, 27: 20.9, 28: 22.5},
}
# 5G_UP_ALG_20210
mcs_table_ptrsoff_data_64QAM_rank2 = {
    '2': {0: 0.6, 1: 1.1, 2: 1.6, 3: 2.2, 4: 2.8, 5: 3.4, 6: 4.1, 7: 4.8, 8: 5.5, 9: 6.1, 10: 6.7,
          11: 7.3, 12: 8.0, 13: 8.7, 14: 9.5, 15: 10.3, 16: 11.0, 17: 11.7, 18: 12.4, 19: 13.1, 20: 14.0,
          21: 14.9, 22: 16.0, 23: 16.9, 24: 17.9, 25: 19.1, 26: 20.1, 27: 21.1, 28: 22.2},
    '3': {0: -0.4, 1: 0.2, 2: 0.8, 3: 1.4, 4: 2.0, 5: 2.7, 6: 3.5, 7: 4.2, 8: 4.9, 9: 5.6, 10: 6.2,
          11: 6.8, 12: 7.5, 13: 8.3, 14: 9.1, 15: 9.8, 16: 10.5, 17: 11.2, 18: 11.9, 19: 12.7, 20: 13.6,
          21: 14.5, 22: 15.4, 23: 16.5, 24: 17.5, 25: 18.5, 26: 19.6, 27: 20.6, 28: 21.8},
    '4': {0: -1.5, 1: -0.9, 2: -0.3, 3: 0.4, 4: 1.1, 5: 1.9, 6: 2.7, 7: 3.5, 8: 4.2, 9: 4.9, 10: 5.5,
          11: 6.1, 12: 6.8, 13: 7.6, 14: 8.5, 15: 9.5, 16: 10.2, 17: 10.9, 18: 11.6, 19: 12.5, 20: 13.4,
          21: 14.3, 22: 15.2, 23: 16.2, 24: 17.2, 25: 18.1, 26: 19.1, 27: 20.1, 28: 21.5},
    '8': {0: -2.1, 1: -1.4, 2: -0.7, 3: 0.1, 4: 0.8, 5: 1.6, 6: 2.4, 7: 3.2, 8: 3.9, 9: 4.6,
          10: 5.2, 11: 5.8, 12: 6.5, 13: 7.3, 14: 8.1, 15: 9.0, 16: 9.7, 17: 10.4, 18: 11.1,
          19: 11.9, 20: 12.8, 21: 13.7, 22: 14.6, 23: 15.7, 24: 16.7, 25: 17.6, 26: 18.6, 27: 19.7, 28: 21.4},
    '16': {0: -2.4, 1: -1.7, 2: -1.0, 3: -0.2, 4: 0.6, 5: 1.3, 6: 2.1, 7: 2.8, 8: 3.6, 9: 4.3,
           10: 5.0, 11: 5.6, 12: 6.3, 13: 7.1, 14: 8.0, 15: 8.9, 16: 9.7, 17: 10.4, 18: 11.1,
           19: 11.9, 20: 12.8, 21: 13.7, 22: 14.6, 23: 15.7, 24: 16.6, 25: 17.6, 26: 18.6, 27: 19.7, 28: 21.3},
    '32': {0: -2.7, 1: -1.9, 2: -1.2, 3: -0.4, 4: 0.3, 5: 1.1, 6: 2.0, 7: 2.8, 8: 3.6, 9: 4.3,
           10: 5.0, 11: 5.6, 12: 6.3, 13: 7.1, 14: 8.0, 15: 8.9, 16: 9.7, 17: 10.4, 18: 11.1,
           19: 11.8, 20: 12.7, 21: 13.6, 22: 14.6, 23: 15.7, 24: 16.6, 25: 17.6, 26: 18.6, 27: 19.7, 28: 21.3},
    '64': {0: -2.7, 1: -2.0, 2: -1.3, 3: -0.5, 4: 0.3, 5: 1.1, 6: 2.0, 7: 2.8, 8: 3.6, 9: 4.2,
           10: 4.9, 11: 5.6, 12: 6.3, 13: 7.1, 14: 8.0, 15: 8.9, 16: 9.7, 17: 10.4, 18: 11.1,
           19: 11.8, 20: 12.7, 21: 13.6, 22: 14.6, 23: 15.7, 24: 16.6, 25: 17.6, 26: 18.6, 27: 19.7, 28: 21.2},
    '273': {0: -2.7, 1: -2.0, 2: -1.3, 3: -0.5, 4: 0.3, 5: 1.1, 6: 2.0, 7: 2.8, 8: 3.6, 9: 4.2,
            10: 4.8, 11: 5.5, 12: 6.3, 13: 7.1, 14: 8.0, 15: 8.8, 16: 9.6, 17: 10.3, 18: 11.0,
            19: 11.8, 20: 12.7, 21: 13.6, 22: 14.6, 23: 15.7, 24: 16.6, 25: 17.6, 26: 18.6, 27: 19.7, 28: 20.9},
}


def cb010708_check_mcs_sinr(csv_filename, rach_slot):
    sinr_check_list = []
    with open(csv_filename, 'r') as csvfile:
        list_reader = list(csv.DictReader(csvfile))
        list_reader_copy = list_reader
        for i_line in list_reader:
            # puschTPstate = i_line['ulFdSchedData.puschTPstate']
            # mcsTable = i_line['ulFdSchedData.mcsTable']
            numOfLayers = i_line['ulFdSchedData.numOfLayers']
            ptrsFlagUlProposedMcs = i_line['ulFdSchedData.ptrsFlagUlProposedMcs']
            reScaledCorrAvgSinrPreAtb = i_line['ulFdSchedData.ueData.reScaledCorrAvgSinrPreAtb']
            UlProposedMcs = i_line['ulFdSchedData.rrmUlProposedMcs']
            rrmUlUsedMcs = i_line['ulFdSchedData.rrmUlUsedMcs']
            numofPrb = i_line['ulFdSchedData.numOfPrb']
            reScaledCorrAvgSinrAtb = i_line['ulFdSchedData.ueData.reScaledCorrAvgSinrAtb']
            sinrOffsetUciInPusch = i_line['ulFdSchedData.ueData.sinrOffsetUciInPusch']
            isScalingDone = i_line['ulFdSchedData.isScalingDone']
            ulHarqProcessIndex = i_line["ulFdSchedData.ulHarqProcessIndex"]
            sfn = int(float(i_line['sfn']))
            slot = int(float(i_line['slot']))
            rnti = i_line['rnti']

            if numOfLayers and reScaledCorrAvgSinrPreAtb and UlProposedMcs and numofPrb \
                    and reScaledCorrAvgSinrAtb and sinrOffsetUciInPusch and slot:
                if ptrsFlagUlProposedMcs != 'PTRS_VOID' and slot != rach_slot:
                    reScaledCorrAvgSinrPreAtb = float(reScaledCorrAvgSinrPreAtb)
                    UlProposedMcs = int(float(UlProposedMcs))
                    rrmUlUsedMcs = int(float(rrmUlUsedMcs))
                    numofPrb = int(float(numofPrb))
                    reScaledCorrAvgSinrAtb = float(reScaledCorrAvgSinrAtb)
                    sinrOffsetUciInPusch = float(sinrOffsetUciInPusch)
                    isScalingDone = int(float(isScalingDone))
                    sinr_end = reScaledCorrAvgSinrAtb - sinrOffsetUciInPusch
                    if ptrsFlagUlProposedMcs == 'PTRS_ON' and numOfLayers == 'RANK1':
                        df_mcs = mcs_table_ptrson_data_64QAM_Rank1
                        print('Select base on mcs_table_ptrson_data_64QAM_Rank1')
                    elif ptrsFlagUlProposedMcs == 'PTRS_OFF' and numOfLayers == 'RANK1':
                        df_mcs = mcs_table_ptrsoff_data_64QAM_rank1
                        print('Select base on mcs_table_ptrsoff_data_64QAM_rank1')
                    elif ptrsFlagUlProposedMcs == 'PTRS_ON' and numOfLayers == 'RANK2':
                        df_mcs = mcs_table_ptrson_data_64QAM_Rank2
                        print('Select base on mcs_table_ptrson_data_64QAM_Rank2')
                    elif ptrsFlagUlProposedMcs == 'PTRS_OFF' and numOfLayers == 'RANK2':
                        df_mcs = mcs_table_ptrsoff_data_64QAM_rank2
                        print('Select base on mcs_table_ptrsoff_data_64QAM_rank2')
                    else:
                        continue
                    required_sinr = get_requied_sinr(df_mcs, UlProposedMcs, numofPrb)
                    requird_sinr_usedmcs = get_requied_sinr(df_mcs, rrmUlUsedMcs, numofPrb)
                    if not required_sinr:
                        continue
                    if (0 < UlProposedMcs + 1 < 29) and (UlProposedMcs != 9) and (UlProposedMcs != 16):
                        next_required_sinr = get_requied_sinr(df_mcs, UlProposedMcs + 1, numofPrb)
                        if (required_sinr <= sinr_end < next_required_sinr) and (rrmUlUsedMcs == UlProposedMcs):
                            # ERR_flag = False
                            sinr_check_list.append('True')
                        elif (sinr_end < required_sinr) and (rrmUlUsedMcs == UlProposedMcs):
                            # ERR_flag = True
                            sinr_check_list.append('False')
                            print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                                  "actual_sinr should bigger than required_sinr, actual_sinr:", sinr_end,
                                  "required_sinr:", required_sinr, "numofprb:", numofPrb)
                        elif (sinr_end > next_required_sinr) and (rrmUlUsedMcs == UlProposedMcs):
                            # ERR_flag = True
                            sinr_check_list.append('False')
                            print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                                  "actual_sinr should less than next_required_sinr, actual_sinr:", sinr_end,
                                  "next_required_sinr:", next_required_sinr, "numofprb:", numofPrb)
                        else:
                            continue
                    elif UlProposedMcs == 9 and rrmUlUsedMcs == 9:
                        # ("QAM64 SINR-MCS-Mapping-Table MCS 10 and MCS 17 NO Used(5G_UP_ALG_26338)")
                        next_required_sinr = get_requied_sinr(df_mcs, 11, numofPrb)
                        if required_sinr <= sinr_end < next_required_sinr:
                            sinr_check_list.append('True')
                        elif sinr_end < required_sinr:
                            sinr_check_list.append('False')
                            print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                                  "actual_sinr should bigger than required_sinr, actual_sinr:", sinr_end,
                                  "required_sinr:", required_sinr, "numofprb:", numofPrb)
                        elif sinr_end > next_required_sinr:
                            sinr_check_list.append('False')
                            print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                                  "actual_sinr should less than next_required_sinr, actual_sinr:", sinr_end,
                                  "next_required_sinr:", next_required_sinr, "numofprb:", numofPrb)
                        else:
                            continue
                    elif UlProposedMcs == 16 and rrmUlUsedMcs == 16:
                        # ("QAM64 SINR-MCS-Mapping-Table MCS 10 and MCS 17 NO Used(5G_UP_ALG_26338)")
                        next_required_sinr = get_requied_sinr(df_mcs, 18, numofPrb)
                        if required_sinr <= sinr_end < next_required_sinr:
                            sinr_check_list.append('True')
                        elif sinr_end < required_sinr:
                            sinr_check_list.append('False')
                            print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                                  "actual_sinr should bigger than required_sinr, actual_sinr:", sinr_end,
                                  "required_sinr:", required_sinr, "numofprb:", numofPrb)
                        elif sinr_end > next_required_sinr:
                            sinr_check_list.append('False')
                            print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                                  "actual_sinr should less than next_required_sinr, actual_sinr:", sinr_end,
                                  "next_required_sinr:", next_required_sinr, "numofprb:", numofPrb)
                        else:
                            continue
                    elif (UlProposedMcs == 0 and rrmUlUsedMcs == 0) and (reScaledCorrAvgSinrPreAtb < sinr_end) \
                            and (sinr_end > required_sinr):
                        print("Mcs 0 for sfn:", sfn, "error slot:", slot)
                    elif (UlProposedMcs > rrmUlUsedMcs) and (sinr_end > requird_sinr_usedmcs):
                        sinr_check_list.append('True')
                    elif (UlProposedMcs > rrmUlUsedMcs) and (sinr_end < requird_sinr_usedmcs):
                        sinr_check_list.append('False')
                        print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                              "actual sinr should bigger than requird_sinr_usedmcs:", sinr_end,
                              "requird_sinr_usedmcs:", requird_sinr_usedmcs, "numofprb:", numofPrb)
                    elif rrmUlUsedMcs == 28 and sinr_end > requird_sinr_usedmcs:
                        sinr_check_list.append('True')
                    elif rrmUlUsedMcs == 28 and sinr_end < requird_sinr_usedmcs:
                        sinr_check_list.append('False')
                        print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                              "actual sinr should bigger than requird_sinr_usedmcs:", sinr_end,
                              "requird_sinr_usedmcs:", requird_sinr_usedmcs, "numofprb:", numofPrb)
                    elif sinr_end < required_sinr:
                        # ERR_flag = True
                        sinr_check_list.append('False')
                        print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                              "actual sinr should bigger than required sinr, actual sinr:", sinr_end,
                              "required sinr:", required_sinr, "numofprb:", numofPrb)
                elif ptrsFlagUlProposedMcs == 'PTRS_VOID':
                    PTRS_VOID_FLAG = False
                    ulHarqProcessIndex = int(float(ulHarqProcessIndex))
                    rnti = int(i_line['rnti'])
                    rrmUlUsedMcs = int(float(rrmUlUsedMcs))
                    curr_index = list_reader.index(i_line)
                    for index in range(curr_index, 1, -1):
                        re_rnti = int(list_reader_copy[index]['rnti'])
                        re_harq = int(float(list_reader_copy[index]['ulFdSchedData.ulHarqProcessIndex']))
                        re_rrmUlUsedMcs = int(float(list_reader_copy[index]['ulFdSchedData.rrmUlUsedMcs']))
                        if re_rnti == rnti and re_harq == ulHarqProcessIndex and re_rrmUlUsedMcs == rrmUlUsedMcs:
                            print("PTRS_VOID, rrmUlUsedMcs:", rrmUlUsedMcs, "sfn:", sfn, "slot:", slot)
                            PTRS_VOID_FLAG = True
                            break
                    if not PTRS_VOID_FLAG:
                        sinr_check_list.append('False')
                        print("MCS err while PTRS_VOID,sfn:", sfn, "slot:", slot)
                        continue
    if 'False' in sinr_check_list:
        print(" MCS-Sinr table check failed!")
        return (False)
    else:
        print("Mcs table check all pass! ")
        return (True)


def get_requied_sinr(df_file_mcs, UlProposedMcs, numofprb):
    requied_sinr = False
    if UlProposedMcs > 28:
        print("UlProposedMcs bigger than the table,UlProposedMcs", UlProposedMcs)
        return requied_sinr
    if numofprb > 64 and numofprb < 273:
        requied_sinr = \
            float(float((df_file_mcs['273'][UlProposedMcs] - df_file_mcs['64'][UlProposedMcs]) / 209)
                  * (numofprb - 64) + df_file_mcs['64'][UlProposedMcs])
    elif numofprb > 32 and numofprb < 64:
        requied_sinr = \
            float(float((df_file_mcs['64'][UlProposedMcs] - df_file_mcs['32'][UlProposedMcs]) / 32) * (numofprb - 32)
                  + df_file_mcs['32'][UlProposedMcs])
    elif numofprb > 16 and numofprb < 32:
        requied_sinr = \
            float(float((df_file_mcs['32'][UlProposedMcs] - df_file_mcs['16'][UlProposedMcs]) / 16) * (numofprb - 16)
                  + df_file_mcs['16'][UlProposedMcs])
    elif numofprb > 8 and numofprb < 16:
        requied_sinr = \
            float(float((df_file_mcs['16'][UlProposedMcs] - df_file_mcs['8'][UlProposedMcs]) / 8) * (numofprb - 8)
                  + df_file_mcs['8'][UlProposedMcs])
    elif numofprb > 4 and numofprb < 8:
        requied_sinr = \
            float(float((df_file_mcs['8'][UlProposedMcs] - df_file_mcs['4'][UlProposedMcs]) / 4) * (numofprb - 4)
                  + df_file_mcs['4'][UlProposedMcs])
    elif numofprb == 273 or numofprb == 64 or numofprb == 32 or numofprb == 16 or numofprb == 8 \
            or numofprb == 4 or numofprb == 3 or numofprb == 2:
        numofprb = str(int(numofprb))
        requied_sinr = df_file_mcs[numofprb][UlProposedMcs]
    return requied_sinr


if __name__ == "__main__":
    result = cb010708_check_mcs_sinr(
        r'C:\personal\Project\5G_project\3_Feature\CB010708\02_testcase\TC6\test\tti_pathloss_ul2.csv', 19)
    print(result)
