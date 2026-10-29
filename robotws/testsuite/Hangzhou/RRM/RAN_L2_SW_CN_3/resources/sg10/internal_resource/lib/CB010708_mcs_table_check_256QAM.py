import csv
import os

# 5G_UP_ALG_20212
mcs_table_ptrson_data_256QAM_Rank1 = {
    '2': {0: 2.0, 1: 3.0, 2: 4.0, 3: 5.0, 4: 6.2, 5: 7.9, 6: 8.6, 7: 9.3, 8: 10.1, 9: 11.0, 10: 11.8,
          11: 12.9, 12: 13.8, 13: 14.8, 14: 15.9, 15: 16.8, 16: 17.9, 17: 18.9, 18: 20.0, 19: 21.1, 20: 21.9,
          21: 22.8, 22: 24.0, 23: 24.9, 24: 25.9, 25: 28.6, 26: 32.0, 27: 33.0},
    '3': {0: 0.9, 1: 1.9, 2: 3.1, 3: 4.4, 4: 5.9, 5: 7.6, 6: 8.3, 7: 9.0, 8: 9.9, 9: 10.9, 10: 11.7,
          11: 12.8, 12: 13.7, 13: 14.6, 14: 15.7, 15: 16.7, 16: 17.6, 17: 18.7, 18: 20.0, 19: 21.1, 20: 21.9,
          21: 22.8, 22: 23.9, 23: 24.8, 24: 25.7, 25: 28.4, 26: 30.5, 27: 32.0},
    '4': {0: -0.1, 1: 0.9, 2: 2.2, 3: 3.6, 4: 5.2, 5: 6.9, 6: 7.6, 7: 8.4, 8: 9.4, 9: 10.4, 10: 11.2,
          11: 12.3, 12: 13.2, 13: 14.3, 14: 15.2, 15: 16.3, 16: 17.2, 17: 18.3, 18: 19.3, 19: 20.6, 20: 21.4,
          21: 22.3, 22: 23.2, 23: 24.4, 24: 25.4, 25: 28.4, 26: 29.5, 27: 31.5},
    '8': {0: -0.8, 1: 0.3, 2: 1.7, 3: 3.3, 4: 4.8, 5: 6.6, 6: 7.3, 7: 8.0, 8: 8.9, 9: 9.8, 10: 10.6,
          11: 12.0, 12: 12.8, 13: 13.6, 14: 14.5, 15: 15.4, 16: 16.6, 17: 17.5, 18: 18.7, 19: 19.8, 20: 20.7,
          21: 21.5, 22: 22.5, 23: 23.7, 24: 24.8, 25: 26.2, 26: 27.4, 27: 29.3},
    '16': {0: -1.3, 1: -0.1, 2: 1.3, 3: 2.9, 4: 4.4, 5: 6.3, 6: 7.0, 7: 7.8, 8: 8.6, 9: 9.6, 10: 10.4,
           11: 11.6, 12: 12.5, 13: 13.4, 14: 14.3, 15: 15.2, 16: 16.5, 17: 17.5, 18: 18.7, 19: 19.8, 20: 20.7,
           21: 21.5, 22: 22.5, 23: 23.5, 24: 24.6, 25: 26.0, 26: 27.2, 27: 29.3},
    '32': {0: -1.6, 1: -0.3, 2: 1.1, 3: 2.6, 4: 4.2, 5: 6.1, 6: 6.9, 7: 7.7, 8: 8.6, 9: 9.5, 10: 10.3,
           11: 11.4, 12: 12.4, 13: 13.2, 14: 14.1, 15: 15.0, 16: 16.1, 17: 17.2, 18: 18.4, 19: 19.4, 20: 20.4,
           21: 21.3, 22: 22.3, 23: 23.3, 24: 24.3, 25: 25.6, 26: 26.6, 27: 28.2},
    '64': {0: -1.7, 1: -0.4, 2: 1.0, 3: 2.5, 4: 4.2, 5: 6.0, 6: 6.8, 7: 7.7, 8: 8.6, 9: 9.5, 10: 10.3,
           11: 11.4, 12: 12.4, 13: 13.2, 14: 14.1, 15: 15.0, 16: 16.1, 17: 17.2, 18: 18.4, 19: 19.4, 20: 20.3,
           21: 21.2, 22: 22.2, 23: 23.1, 24: 24.1, 25: 25.3, 26: 26.4, 27: 28.2},
    '273': {0: -1.8, 1: -0.5, 2: 0.9, 3: 2.5, 4: 4.0, 5: 6.0, 6: 6.8, 7: 7.7, 8: 8.5, 9: 9.4, 10: 10.2,
            11: 11.3, 12: 12.2, 13: 13.2, 14: 14.0, 15: 14.9, 16: 16.1, 17: 17.2, 18: 18.3, 19: 19.3, 20: 20.2,
            21: 21.1, 22: 22.0, 23: 23.0, 24: 24.1, 25: 25.3, 26: 26.4, 27: 28.2},
}
# 5G_UP_ALG_20210
mcs_table_ptrsoff_data_256QAM_rank1 = {
    '2': {0: 0.5, 1: 1.5, 2: 2.5, 3: 3.7, 4: 5.1, 5: 6.9, 6: 7.6, 7: 8.3, 8: 9.0, 9: 9.8, 10: 10.6,
          11: 12.0, 12: 12.8, 13: 13.6, 14: 14.6, 15: 15.7, 16: 16.7, 17: 17.8, 18: 18.7, 19: 19.6, 20: 20.4,
          21: 21.2, 22: 22.1, 23: 23.3, 24: 24.4, 25: 25.4, 26: 26.5, 27: 28.0},
    '3': {0: -0.6, 1: 0.5, 2: 1.9, 3: 3.3, 4: 4.7, 5: 6.5, 6: 7.2, 7: 7.9, 8: 8.8, 9: 9.7, 10: 10.5,
          11: 11.8, 12: 12.6, 13: 13.4, 14: 14.3, 15: 15.2, 16: 16.3, 17: 17.4, 18: 18.4, 19: 19.4, 20: 20.2,
          21: 21.0, 22: 21.9, 23: 23.0, 24: 24.0, 25: 25.0, 26: 26.0, 27: 27.7},
    '4': {0: -1.5, 1: -0.3, 2: 1.1, 3: 2.7, 4: 4.1, 5: 5.9, 6: 6.6, 7: 7.4, 8: 8.3, 9: 9.2, 10: 10.0,
          11: 11.4, 12: 12.2, 13: 13.0, 14: 13.9, 15: 15.0, 16: 16.0, 17: 17.0, 18: 18.2, 19: 19.0, 20: 19.9,
          21: 20.7, 22: 21.6, 23: 22.6, 24: 23.8, 25: 24.8, 26: 26.0, 27: 27.5},
    '8': {0: -2.1, 1: -0.8, 2: 0.7, 3: 2.1, 4: 3.5, 5: 5.7, 6: 6.4, 7: 7.2, 8: 8.1, 9: 9.1,
          10: 9.9, 11: 11.2, 12: 12.0, 13: 12.8, 14: 13.6, 15: 14.4, 16: 15.3, 17: 16.4, 18: 17.4,
          19: 18.3, 20: 19.4, 21: 20.2, 22: 21.2, 23: 22.2, 24: 23.2, 25: 24.2, 26: 25.2, 27: 26.7},
    '16': {0: -2.5, 1: -1.1, 2: 0.4, 3: 2.0, 4: 3.4, 5: 5.5, 6: 6.3, 7: 7.1, 8: 7.9, 9: 8.8,
           10: 9.6, 11: 10.9, 12: 11.7, 13: 12.7, 14: 13.5, 15: 14.4, 16: 15.3, 17: 16.4, 18: 17.4,
           19: 18.3, 20: 19.4, 21: 20.2, 22: 21.2, 23: 22.2, 24: 23.2, 25: 24.2, 26: 25.2, 27: 26.7},
    '32': {0: -2.6, 1: -1.2, 2: 0.4, 3: 1.8, 4: 3.3, 5: 5.4, 6: 6.1, 7: 6.9, 8: 7.9, 9: 8.7,
           10: 9.5, 11: 10.8, 12: 11.7, 13: 12.6, 14: 13.4, 15: 14.2, 16: 15.3, 17: 16.4, 18: 17.4,
           19: 18.3, 20: 19.4, 21: 20.2, 22: 21.1, 23: 22.1, 24: 23.1, 25: 24.2, 26: 25.2, 27: 26.7},
    '64': {0: -2.8, 1: -1.3, 2: 0.2, 3: 1.8, 4: 3.2, 5: 5.4, 6: 6.1, 7: 6.9, 8: 7.9, 9: 8.7,
           10: 9.5, 11: 10.8, 12: 11.6, 13: 12.5, 14: 13.3, 15: 14.2, 16: 15.3, 17: 16.4, 18: 17.4,
           19: 18.3, 20: 19.4, 21: 20.2, 22: 21.1, 23: 22.1, 24: 23.1, 25: 24.2, 26: 25.2, 27: 26.6},
    '273': {0: -2.8, 1: -1.3, 2: 0.2, 3: 1.8, 4: 3.2, 5: 5.4, 6: 6.1, 7: 6.9, 8: 7.9, 9: 8.7,
            10: 9.5, 11: 10.8, 12: 11.6, 13: 12.5, 14: 13.3, 15: 14.2, 16: 15.3, 17: 16.4, 18: 17.4,
            19: 18.3, 20: 19.4, 21: 20.2, 22: 21.1, 23: 22.1, 24: 23.1, 25: 24.1, 26: 25.1, 27: 26.2},
}
mcs_table_ptrson_data_256QAM_Rank2 = {
    '2': {0: 2.1, 1: 3.1, 2: 4.1, 3: 5.3, 4: 6.7, 5: 8.6, 6: 9.3, 7: 10.1, 8: 11.0, 9: 11.8, 10: 12.6,
          11: 13.6, 12: 14.4, 13: 15.4, 14: 16.4, 15: 17.4, 16: 18.4, 17: 19.4, 18: 20.4, 19: 21.7, 20: 22.5,
          21: 23.3, 22: 24.2, 23: 25.6, 24: 26.8, 25: 30.4, 26: 33.0, 27: 35.0},
    '3': {0: 1.1, 1: 2.2, 2: 3.5, 3: 4.8, 4: 6.1, 5: 8.1, 6: 8.9, 7: 9.7, 8: 10.6, 9: 11.5, 10: 12.3,
          11: 13.4, 12: 14.2, 13: 15.1, 14: 16.0, 15: 17.1, 16: 18.1, 17: 19.3, 18: 20.3, 19: 21.3, 20: 22.1,
          21: 22.9, 22: 23.8, 23: 25.0, 24: 26.3, 25: 28.7, 26: 30.6, 27: 32.5},
    '4': {0: -0.2, 1: 1.0, 2: 2.4, 3: 3.9, 4: 5.3, 5: 7.1, 6: 7.9, 7: 8.7, 8: 9.5, 9: 10.3, 10: 11.3,
          11: 12.6, 12: 13.5, 13: 14.4, 14: 15.4, 15: 16.4, 16: 17.5, 17: 18.5, 18: 19.7, 19: 20.7, 20: 21.5,
          21: 22.3, 22: 23.3, 23: 24.5, 24: 26.3, 25: 28.2, 26: 29.6, 27: 32.5},
    '8': {0: -0.8, 1: 0.3, 2: 1.8, 3: 3.3, 4: 4.8, 5: 6.7, 6: 7.4, 7: 8.2, 8: 9.0, 9: 9.9, 10: 10.7,
          11: 11.9, 12: 12.8, 13: 13.8, 14: 14.7, 15: 15.7, 16: 16.8, 17: 17.8, 18: 19.0, 19: 20.2, 20: 21.0,
          21: 22.1, 22: 23.3, 23: 24.2, 24: 25.4, 25: 26.6, 26: 28.0, 27: 30.0},
    '16': {0: -1.3, 1: -0.1, 2: 1.4, 3: 3.1, 4: 4.6, 5: 6.5, 6: 7.3, 7: 8.1, 8: 8.9, 9: 9.8, 10: 10.6,
           11: 11.9, 12: 12.8, 13: 13.7, 14: 14.6, 15: 15.5, 16: 16.7, 17: 17.7, 18: 18.9, 19: 20.2, 20: 21.0,
           21: 21.8, 22: 22.9, 23: 23.9, 24: 25.0, 25: 26.4, 26: 27.5, 27: 29.5},
    '32': {0: -1.5, 1: -0.4, 2: 1.2, 3: 2.7, 4: 4.5, 5: 6.4, 6: 7.1, 7: 7.9, 8: 8.7, 9: 9.6, 10: 10.4,
           11: 11.6, 12: 12.5, 13: 13.5, 14: 14.4, 15: 15.3, 16: 16.4, 17: 17.5, 18: 18.6, 19: 19.9, 20: 20.8,
           21: 21.8, 22: 22.8, 23: 23.8, 24: 24.8, 25: 26.1, 26: 27.2, 27: 28.5},
    '64': {0: -1.6, 1: -0.4, 2: 1.1, 3: 2.7, 4: 4.4, 5: 6.3, 6: 7.0, 7: 7.8, 8: 8.7, 9: 9.6, 10: 10.4,
           11: 11.6, 12: 12.5, 13: 13.5, 14: 14.4, 15: 15.3, 16: 16.4, 17: 17.5, 18: 18.6, 19: 19.9, 20: 20.8,
           21: 21.6, 22: 22.5, 23: 23.4, 24: 24.5, 25: 25.7, 26: 26.8, 27: 28.5},
    '273': {0: -1.6, 1: -0.4, 2: 1.1, 3: 2.7, 4: 4.4, 5: 6.3, 6: 7.0, 7: 7.8, 8: 8.7, 9: 9.5, 10: 10.3,
            11: 11.6, 12: 12.5, 13: 13.4, 14: 14.4, 15: 15.3, 16: 16.4, 17: 17.5, 18: 18.6, 19: 19.9, 20: 20.8,
            21: 21.6, 22: 22.5, 23: 23.4, 24: 24.5, 25: 25.6, 26: 26.7, 27: 28.5},
}
# 5G_UP_ALG_20210
mcs_table_ptrsoff_data_256QAM_rank2 = {
    '2': {0: 0.6, 1: 1.6, 2: 2.8, 3: 4.1, 4: 5.5, 5: 7.3, 6: 8.0, 7: 8.7, 8: 9.5, 9: 10.3, 10: 11.1,
          11: 12.4, 12: 13.2, 13: 14.0, 14: 14.9, 15: 16.0, 16: 16.9, 17: 17.9, 18: 19.1, 19: 20.1, 20: 20.9,
          21: 21.7, 22: 22.6, 23: 23.6, 24: 24.8, 25: 26.0, 26: 27.0, 27: 28.6},
    '3': {0: -0.4, 1: 0.8, 2: 2.0, 3: 3.5, 4: 4.9, 5: 6.8, 6: 7.5, 7: 8.3, 8: 9.1, 9: 9.8, 10: 10.6,
          11: 11.9, 12: 12.7, 13: 13.6, 14: 14.5, 15: 15.4, 16: 16.5, 17: 17.5, 18: 18.5, 19: 19.6, 20: 20.4,
          21: 21.2, 22: 22.1, 23: 23.1, 24: 24.1, 25: 25.3, 26: 26.4, 27: 27.9},
    '4': {0: -1.5, 1: -0.3, 2: 1.1, 3: 2.7, 4: 4.2, 5: 6.1, 6: 6.8, 7: 7.6, 8: 8.5, 9: 9.5, 10: 10.3,
          11: 11.6, 12: 12.5, 13: 13.4, 14: 14.3, 15: 15.2, 16: 16.2, 17: 17.2, 18: 18.1, 19: 19.1, 20: 20.0,
          21: 20.8, 22: 21.8, 23: 22.9, 24: 23.9, 25: 25.0, 26: 26.1, 27: 27.7},
    '8': {0: -2.1, 1: -0.7, 2: 0.8, 3: 2.4, 4: 3.9, 5: 5.8, 6: 6.5, 7: 7.3, 8: 8.1, 9: 9.0,
          10: 9.8, 11: 11.1, 12: 11.9, 13: 12.8, 14: 13.7, 15: 14.6, 16: 15.7, 17: 16.7, 18: 17.6,
          19: 18.6, 20: 19.7, 21: 20.5, 22: 21.4, 23: 22.4, 24: 23.6, 25: 24.6, 26: 25.6, 27: 27.0},
    '16': {0: -2.4, 1: -1.0, 2: 0.6, 3: 2.1, 4: 3.6, 5: 5.6, 6: 6.3, 7: 7.1, 8: 8.0, 9: 8.9,
           10: 9.7, 11: 11.1, 12: 11.9, 13: 12.8, 14: 13.7, 15: 14.6, 16: 15.7, 17: 16.6, 18: 17.6,
           19: 18.6, 20: 19.7, 21: 20.5, 22: 21.4, 23: 22.4, 24: 23.5, 25: 24.5, 26: 25.5, 27: 27.0},
    '32': {0: -2.7, 1: -1.2, 2: 0.3, 3: 2.0, 4: 3.6, 5: 5.6, 6: 6.3, 7: 7.1, 8: 8.0, 9: 8.9,
           10: 9.7, 11: 11.1, 12: 11.9, 13: 12.7, 14: 13.6, 15: 14.6, 16: 15.7, 17: 16.6, 18: 17.6,
           19: 18.6, 20: 19.7, 21: 20.5, 22: 21.4, 23: 22.4, 24: 23.4, 25: 24.5, 26: 25.5, 27: 26.9},
    '64': {0: -2.7, 1: -1.3, 2: 0.3, 3: 2.0, 4: 3.6, 5: 5.6, 6: 6.3, 7: 7.1, 8: 8.0, 9: 8.9,
           10: 9.7, 11: 11.1, 12: 11.9, 13: 12.7, 14: 13.6, 15: 14.6, 16: 15.7, 17: 16.6, 18: 17.6,
           19: 18.6, 20: 19.7, 21: 20.5, 22: 21.4, 23: 22.4, 24: 23.4, 25: 24.5, 26: 25.5, 27: 26.9},
    '273': {0: -2.7, 1: -1.3, 2: 0.3, 3: 2.0, 4: 3.6, 5: 5.5, 6: 6.3, 7: 7.1, 8: 8.0, 9: 8.8,
            10: 9.6, 11: 11.0, 12: 11.8, 13: 12.7, 14: 13.6, 15: 14.6, 16: 15.7, 17: 16.6, 18: 17.6,
            19: 18.6, 20: 19.7, 21: 20.5, 22: 21.4, 23: 22.4, 24: 23.4, 25: 24.4, 26: 25.5, 27: 26.6},
}


def CB010708_check_mcs_sinr_256qam(csv_filename, rach_slot):
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
                    deltaMPR256QAM = 3
                    qam256UlRequiredSinrDelta_mcs22_mcs27 = 0.6
                    qam256UlRequiredSinrDelta_mcs21 = 0.4
                    qam256UlRequiredSinrDelta_mcs0_mcs20 = 0.0
                    if ptrsFlagUlProposedMcs == 'PTRS_ON' and numOfLayers == 'RANK1':
                        df_mcs = mcs_table_ptrson_data_256QAM_Rank1
                        print('Select base on mcs_table_ptrson_data_256QAM_Rank1')
                    elif ptrsFlagUlProposedMcs == 'PTRS_OFF' and numOfLayers == 'RANK1':
                        df_mcs = mcs_table_ptrsoff_data_256QAM_rank1
                        print('Select base on mcs_table_ptrsoff_data_256QAM_rank1')
                    elif ptrsFlagUlProposedMcs == 'PTRS_ON' and numOfLayers == 'RANK2':
                        df_mcs = mcs_table_ptrson_data_256QAM_Rank2
                        print('Select base on mcs_table_ptrson_data_256QAM_Rank2')
                    elif ptrsFlagUlProposedMcs == 'PTRS_OFF' and numOfLayers == 'RANK2':
                        df_mcs = mcs_table_ptrsoff_data_256QAM_rank2
                        print('Select base on mcs_table_ptrsoff_data_256QAM_rank2')
                    else:
                        continue
                    required_sinr = get_requied_sinr(df_mcs, UlProposedMcs, numofPrb)
                    requird_sinr_usedmcs = get_requied_sinr(df_mcs, rrmUlUsedMcs, numofPrb)
                    if not required_sinr:
                        continue
                    if 22 < UlProposedMcs + 1 < 28:
                        sinr_end_mcs22_mcs27 = \
                            float(reScaledCorrAvgSinrAtb - deltaMPR256QAM - qam256UlRequiredSinrDelta_mcs22_mcs27
                                  - sinrOffsetUciInPusch)
                        next_required_sinr = get_requied_sinr(df_mcs, UlProposedMcs + 1, numofPrb)
                        if (required_sinr <= sinr_end_mcs22_mcs27 < next_required_sinr) \
                                and (rrmUlUsedMcs == UlProposedMcs):
                            # ERR_flag = False
                            sinr_check_list.append('True')
                        elif (sinr_end_mcs22_mcs27 < required_sinr) and (rrmUlUsedMcs == UlProposedMcs):
                            # ERR_flag = True
                            sinr_check_list.append('False')
                            print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                                  "actual_sinr should bigger than required_sinr, actual_sinr:", sinr_end_mcs22_mcs27,
                                  "required_sinr:", required_sinr, "numofprb:", numofPrb)
                        elif (sinr_end_mcs22_mcs27 > next_required_sinr) and (rrmUlUsedMcs == UlProposedMcs):
                            # ERR_flag = True
                            sinr_check_list.append('False')
                            print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                                  "actual_sinr should less than next_required_sinr, actual_sinr:", sinr_end_mcs22_mcs27,
                                  "next_required_sinr:", next_required_sinr, "numofprb:", numofPrb)
                        elif (UlProposedMcs > rrmUlUsedMcs) and (sinr_end_mcs22_mcs27 > requird_sinr_usedmcs):
                            sinr_check_list.append('True')
                        elif (UlProposedMcs > rrmUlUsedMcs) and (sinr_end_mcs22_mcs27 < requird_sinr_usedmcs):
                            sinr_check_list.append('False')
                            print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                                  "actual sinr should bigger than required_sinr_usedmcs:", sinr_end_mcs22_mcs27,
                                  "required_sinr_usedmcs:", requird_sinr_usedmcs, "numofprb:", numofPrb)
                        else:
                            continue
                    elif UlProposedMcs == 21:
                        sinr_end_mcs21 = \
                            float(reScaledCorrAvgSinrAtb - deltaMPR256QAM - qam256UlRequiredSinrDelta_mcs21
                                  - sinrOffsetUciInPusch)
                        sinr_end_mcs21_next = \
                            float(reScaledCorrAvgSinrAtb - deltaMPR256QAM - qam256UlRequiredSinrDelta_mcs22_mcs27
                                  - sinrOffsetUciInPusch)
                        next_required_sinr = get_requied_sinr(df_mcs, UlProposedMcs + 1, numofPrb)
                        if (required_sinr <= sinr_end_mcs21 < next_required_sinr) \
                                and (rrmUlUsedMcs == UlProposedMcs):
                            sinr_check_list.append('True')
                        elif (sinr_end_mcs21 < required_sinr) and (rrmUlUsedMcs == UlProposedMcs):
                            sinr_check_list.append('False')
                            print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                                  "actual_sinr should bigger than required_sinr, actual_sinr:", sinr_end_mcs21,
                                  "required_sinr:", required_sinr, "numofprb:", numofPrb)
                        elif (sinr_end_mcs21_next > next_required_sinr) and (rrmUlUsedMcs == UlProposedMcs):
                            sinr_check_list.append('False')
                            print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                                  "actual_sinr should less than next_required_sinr, actual_sinr:", sinr_end_mcs21_next,
                                  "next_required_sinr:", next_required_sinr, "numofprb:", numofPrb)
                        else:
                            continue
                    elif UlProposedMcs == 20:
                        sinr_end_mcs20 = \
                            float(reScaledCorrAvgSinrAtb - deltaMPR256QAM - qam256UlRequiredSinrDelta_mcs0_mcs20
                                  - sinrOffsetUciInPusch)
                        sinr_end_mcs20_next = \
                            float(reScaledCorrAvgSinrAtb - deltaMPR256QAM - qam256UlRequiredSinrDelta_mcs21
                                  - sinrOffsetUciInPusch)
                        next_required_sinr = get_requied_sinr(df_mcs, UlProposedMcs + 1, numofPrb)
                        if (required_sinr <= sinr_end_mcs20 < next_required_sinr) \
                                and (rrmUlUsedMcs == UlProposedMcs):
                            sinr_check_list.append('True')
                        elif (sinr_end_mcs20 < required_sinr) and (rrmUlUsedMcs == UlProposedMcs):
                            sinr_check_list.append('False')
                            print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                                  "actual_sinr should bigger than required_sinr, actual_sinr:", sinr_end_mcs20,
                                  "required_sinr:", required_sinr, "numofprb:", numofPrb)
                        elif (sinr_end_mcs20_next > next_required_sinr) and (rrmUlUsedMcs == UlProposedMcs):
                            sinr_check_list.append('False')
                            print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                                  "actual_sinr should less than next_required_sinr, actual_sinr:", sinr_end_mcs20_next,
                                  "next_required_sinr:", next_required_sinr, "numofprb:", numofPrb)
                        else:
                            continue
                    elif UlProposedMcs == 19:
                        sinr_end_mcs19 = \
                            float(reScaledCorrAvgSinrAtb - qam256UlRequiredSinrDelta_mcs0_mcs20
                                  - sinrOffsetUciInPusch)
                        sinr_end_mcs19_next = \
                            float(reScaledCorrAvgSinrAtb - deltaMPR256QAM - qam256UlRequiredSinrDelta_mcs0_mcs20
                                  - sinrOffsetUciInPusch)
                        next_required_sinr = get_requied_sinr(df_mcs, UlProposedMcs + 1, numofPrb)
                        if (required_sinr <= sinr_end_mcs19 < next_required_sinr) \
                                and (rrmUlUsedMcs == UlProposedMcs):
                            sinr_check_list.append('True')
                        elif (sinr_end_mcs19 < required_sinr) and (rrmUlUsedMcs == UlProposedMcs):
                            sinr_check_list.append('False')
                            print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                                  "actual_sinr should bigger than required_sinr, actual_sinr:", sinr_end_mcs19,
                                  "required_sinr:", required_sinr, "numofprb:", numofPrb)
                        elif (sinr_end_mcs19_next > next_required_sinr) and (rrmUlUsedMcs == UlProposedMcs):
                            sinr_check_list.append('False')
                            print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                                  "actual_sinr should less than next_required_sinr, actual_sinr:", sinr_end_mcs19_next,
                                  "next_required_sinr:", next_required_sinr, "numofprb:", numofPrb)
                        else:
                            continue
                    if 0 < UlProposedMcs + 1 < 20:
                        sinr_end_mcs0_mcs18 = \
                            float(reScaledCorrAvgSinrAtb - qam256UlRequiredSinrDelta_mcs0_mcs20
                                  - sinrOffsetUciInPusch)
                        next_required_sinr = get_requied_sinr(df_mcs, UlProposedMcs + 1, numofPrb)
                        if (required_sinr <= sinr_end_mcs0_mcs18 < next_required_sinr) \
                                and (rrmUlUsedMcs == UlProposedMcs):
                            # ERR_flag = False
                            sinr_check_list.append('True')
                        elif (sinr_end_mcs0_mcs18 < required_sinr) and (rrmUlUsedMcs == UlProposedMcs):
                            # ERR_flag = True
                            sinr_check_list.append('False')
                            print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                                  "actual_sinr should bigger than required_sinr, actual_sinr:", sinr_end_mcs0_mcs18,
                                  "required_sinr:", required_sinr, "numofprb:", numofPrb)
                        elif (sinr_end_mcs0_mcs18 > next_required_sinr) and (rrmUlUsedMcs == UlProposedMcs):
                            # ERR_flag = True
                            sinr_check_list.append('False')
                            print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                                  "actual_sinr should less than next_required_sinr, actual_sinr:", sinr_end_mcs0_mcs18,
                                  "next_required_sinr:", next_required_sinr, "numofprb:", numofPrb)
                        elif (UlProposedMcs > rrmUlUsedMcs) and (sinr_end_mcs0_mcs18 > requird_sinr_usedmcs):
                            sinr_check_list.append('True')
                        elif (UlProposedMcs > rrmUlUsedMcs) and (sinr_end_mcs0_mcs18 < requird_sinr_usedmcs):
                            sinr_check_list.append('False')
                            print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                                  "actual sinr should bigger than required_sinr_usedmcs:", sinr_end_mcs0_mcs18,
                                  "required_sinr_usedmcs:", requird_sinr_usedmcs, "numofprb:", numofPrb)
                        else:
                            continue
                    elif UlProposedMcs == 0 and rrmUlUsedMcs == 0:
                        sinr_end_mcs0_mcs18 = \
                            float(reScaledCorrAvgSinrAtb - qam256UlRequiredSinrDelta_mcs0_mcs20
                                  - sinrOffsetUciInPusch)
                        next_required_sinr = get_requied_sinr(df_mcs, UlProposedMcs + 1, numofPrb)
                        if (required_sinr <= sinr_end_mcs0_mcs18) and (sinr_end_mcs0_mcs18 < next_required_sinr):
                            sinr_check_list.append('True')
                        elif sinr_end_mcs0_mcs18 < required_sinr:
                            sinr_check_list.append('False')
                            print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                                  "actual_sinr should bigger than required_sinr, actual_sinr:", sinr_end_mcs0_mcs18,
                                  "next_required_sinr:", next_required_sinr, "numofprb:", numofPrb)
                        elif sinr_end_mcs0_mcs18 > next_required_sinr:
                            sinr_check_list.append('False')
                            print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                                  "actual_sinr should less than next_required_sinr, actual_sinr:", sinr_end_mcs0_mcs18,
                                  "next_required_sinr:", next_required_sinr, "numofprb:", numofPrb)
                        else:
                            continue
                    elif rrmUlUsedMcs == 27:
                        sinr_end_mcs22_mcs27 = \
                            float(reScaledCorrAvgSinrAtb - deltaMPR256QAM - qam256UlRequiredSinrDelta_mcs22_mcs27
                                  - sinrOffsetUciInPusch)
                        if sinr_end_mcs22_mcs27 >= requird_sinr_usedmcs:
                            sinr_check_list.append('True')
                        elif sinr_end_mcs22_mcs27 < requird_sinr_usedmcs:
                            sinr_check_list.append('False')
                            print("Mcs error for sfn:", sfn, "error slot:", slot, "rrmUlUsedMcs:", rrmUlUsedMcs,
                                  "actual sinr should bigger than requird_sinr_usedmcs:", sinr_end_mcs22_mcs27,
                                  "requird_sinr_usedmcs:", requird_sinr_usedmcs, "numofprb:", numofPrb)
                        else:
                            continue
                    else:
                        continue
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
    if UlProposedMcs > 27:
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
    result = CB010708_check_mcs_sinr_256qam(
        r'C:\personal\Project\5G_project\3_Feature\CB010708\02_testcase\TC6\test\tti_pathloss_ul.csv', 19)
    print(result)
